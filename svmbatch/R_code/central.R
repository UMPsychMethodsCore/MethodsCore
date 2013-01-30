# Load functions
source('func.R')

# Path Stuff

if(exists('outputTemplate')){outputPath = dirname(outputTemplate)}
dir.create(outputPath, showWarnings=FALSE,recursive=TRUE)


# Masterdatafile

## Load it

master = read.csv(masterpath,colClasses = 'character')

if (!(length(numeric.columns)==1 && numeric.columns=='')){ # Only do it if you have some content
  master[,numeric.columns] = apply(master[,numeric.columns],c(1,2),as.numeric) # Coerce numeric columns to be numeric
}

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
vars = switch(model.approach,lm = all.vars(model.formula)[-1], lme = c(all.vars(model.random),all.vars(model.fixed)[-1]))

miniframe = master[,vars]

if (sum(is.na(miniframe)) > 0){
  stop('Not all of your included subjects have valid values for all of the terms in your model.')
}

# Load connectomes

## Source some useful libraries
library('R.matlab') #Make sure you are able to load matlab files
library('Matrix')
library(nlme)

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

## Convert the R's to z's
superflatmat.orig = superflatmat
superflatmat = fisherz(superflatmat.orig)

## Save what you've loaded so far

save(superflatmat.orig,superflatmat,file=file.path(outputPath,'superflat.RData'))

## Do the modeling

nBeta = length(vars)
t.array = matrix(nrow = nBeta, ncol = nFeat, rep(0,nBeta * nFeat))
p.array = matrix(nrow = nBeta, ncol = nFeat, rep(0,nBeta * nFeat))
if (model.approach == 'lme'){
  nGrp = length(unique(master[,vars[1]]))
  int.array = matrix(nrow = nGrp, ncol = nFeat, rep(0,nGrp * nFeat))
} else {
  int.array = 0
}

for (iFeat in 1:nFeat){
  mini = data.frame(R = superflatmat[,iFeat],master)

  model.fit = model.call(mini,model.formula,model.fixed,model.random,model.approach)
  if(model.approach=='lm'){
    t.array[,iFeat] = summary(model.fit)$coef[,'t value']
    p.array[,iFeat] = summary(model.fit)$coef[,'Pr(>|t|)']
  }
  if(model.approach=='lme'){
    t.array[,iFeat] = summary(model.fit)$tTable[,'t-value']
    p.array[,iFeat] = summary(model.fit)$tTable[,'p-value']
    int.array[,iFeat] = coef(model.fit)[,1]
  }

  if (iFeat == 1){
    save(model.fit,file=file.path(outputPath,'FirstModel.RData'))
  }
  if(iFeat %% 1000 == 0){
    print(iFeat)
  }
}
  
## Write out the results

writeMat(file.path(outputPath,'Results.mat'),tvals = t.array,pvals = p.array,intercepts = int.array, terms = vars)
