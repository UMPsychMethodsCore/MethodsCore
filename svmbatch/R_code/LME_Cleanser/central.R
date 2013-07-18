# Load functions
source('func.R')

# Path Stuff

if(exists('outputTemplate')){outputPath = dirname(outputTemplate)}
dir.create(outputPath, showWarnings=FALSE,recursive=TRUE)


# Masterdatafile

## Load it

master = read.csv(masterpath,colClasses = 'character')

### Coerce some columns back to numeric

if (!(length(numeric.columns)==1 && numeric.columns=='')){ # Only do it if you have some content
  master[,numeric.columns] = apply(master[,numeric.columns],c(1,2),as.numeric) # Coerce numeric columns to be numeric
}

### Subset to only subjects intended for analysis

if( includefactor != '' ){
  master[,includefactor] = as.logical(master[,includefactor])
  master[,includefactor] [is.na(master[,includefactor])] = FALSE
  master = master[master[,includefactor] == 1,] #Subset only to those subjects intended for this analysis
}

nSub = nrow(master)

## Potential Error Checking

### Make sure all the files actually exist
name=c()
exist=c()

for (iSub in 1:nSub){
  SubjPath = master[iSub,connTemplate.SubjField]
  connPath = paste(connTemplate.prefix,SubjPath,connTemplate.suffix,sep='')
  name[iSub]=SubjPath
  exist[iSub] = file.exists(connPath)

}

filecheck=data.frame(name,exist)

if(nrow(master) != sum(filecheck$exist)){
  stop(sprintf('Your file asked me to analyze %f subjects, and I was able to load %f of them',nrow(master),sum(filecheck$exist)))
}


### Make sure all of the factors in your model are defined
vars =  c(all.vars(model.random),all.vars(model.fixed)[-1])

miniframe = master[,vars]

if (sum(is.na(miniframe)) > 0){
  stop('Not all of your included subjects have valid values for all of the terms in your model.')
}

# Load connectomes

## Source some useful libraries
library('R.matlab') #Make sure you are able to load matlab files
library('Matrix')
library('nlme')
library('multicore')

## Do the actual loading
for (iSub in 1:nSub){
  SubjPath = master[iSub,connTemplate.SubjField]
  connPath = paste(connTemplate.prefix,SubjPath,connTemplate.suffix,sep='')
  connectome.file = readMat( connPath )
  connectome = connectome.file$rMatrix
  if (iSub==1){
    nFeat = length(flatten.upper.triangle(connectome))
    superflatmat = matrix(nrow = nSub,ncol = nFeat, rep(0,nSub * nFeat)) # Preallocate superflatmat
    row.names(superflatmat) = rep('Null',nSub)
  }
  superflatmat[iSub,] = flatten.upper.triangle(connectome)
  row.names(superflatmat)[iSub] = SubjPath # Label the row of the matrix with the subject
  if(iSub %% 10 == 0){
    print(iSub)
  }
}

## Save what you've loaded so far

save(superflatmat,file=file.path(outputPath,'superflat.RData'))

## Convert the R's to z's
if(FisherZ==1){
  superflatmat = fisherz(superflatmat)
}

## Clean up anything out of range
superflatmat[abs(superflatmat) > 2] = NA

## Do the modeling

### LME Approach
#### Do correction on all models
  correction = mclapply(1:nFeat,lmeMCcorrection,model.fixed,model.random,superflatmat,master,mc.cores=multicore.cores)

  

#### Now get that stuff out of the list (thank you SO)
  arrays <- sapply(c('typical.Lev0','typical.Lev1','cleansed'),function(E){
    do.call(cbind,
            lapply(correction,function(x) {
              x[[E]]
            }))
  },simplify=FALSE)

  cleansed = arrays$cleansed
  typical.Lev0 = arrays$typical.Lev0
  typical.Lev1 = arrays$typical.Lev1


rhs = model.fixed
rhs[[2]] = c()

design=model.matrix(rhs,master)

## Write out the results

varnames = colnames(design)

varnames = strtrim(varnames,29)
varnames = make.unique(varnames)
varnames = gsub('.','_',varnames,fixed=TRUE)

names(master) = strtrim(names(master),29)
names(master) = make.unique(names(master))
names(master) = gsub('.','_',names(master),fixed=TRUE)



res = writeMat(file.path(outputPath,'Results.mat'),
  typical_Lev0 = typical.Lev0,
  typical_Lev1 = typical.Lev1,
  design = design,
  master = master,
  varnames = varnames)

chunk = 100

iter = ceiling(nrow(cleansed)/chunk)

for (i in 1:iter){
  writepath = file.path(outputPath,paste('Results_Cleansed_Part',i,'.mat',sep=''))
  myrange = ((i-1)*chunk + 1) : ((i*chunk))
  myrange = myrange[1] : min(myrange[chunk],nrow(cleansed))
  args= list(con=writepath,cleansed = cleansed[myrange,])
  names(args)[2] = paste('Cleansed_Part',i,sep='')
  do.call(writeMat,args)
}


