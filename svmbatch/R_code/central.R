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
vars = switch(model.approach,lm = all.vars(model.formula)[-1], lme = c(all.vars(model.random),all.vars(model.fixed)[-1]))

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

save(superflatmat,superflatmat,file=file.path(outputPath,'superflat.RData'))

## Convert the R's to z's
if(FisherZ==1){
  superflatmat = fisherz(superflatmat)
}

## Do the modeling

### LM Approach
if (model.approach == 'lm'){
  #### Build a simple lm model, and save the results for later inspection
  mini = data.frame(R = superflatmat[,1],master)
  model.fit = lm(model.formula,mini)
  save(model.fit,file=file.path(outputPath,'FirstModel.RData'))

  #### Fit the big model
  design = model.matrix(model.formula,mini) # create a design matrix
  results = massuni(superflatmat, design) # do the mass univariate modeling
  t.array = results$tvals # grab the t values
  p.array = results$pvals # grab the p values
  int.array = 0
}

### LME Approach
if (model.approach == 'lme'){
#### Fit the first model, save it for reference
  model.fit = lmeMCfit(1,model.fixed,model.random,superflatmat,master,'full')
  
#### Fit all the models with multicore if possible
  models = mclapply(1:nFeat,lmeMCfit,model.fixed,model.random,superflatmat,master,'out',mc.cores=multicore.cores)

#### Now get that stuff out of the list (thank you SO)
  arrays <- sapply(c('t','p','int'),function(E){
    do.call(cbind,
            lapply(models,function(x) {
              x[[E]]
            }))
  },simplify=FALSE)

  t.array = arrays$t
  p.array = arrays$p
  int.array = arrays$int
}
  
## Write out the results

writeMat(file.path(outputPath,'Results.mat'),tvals = t.array,pvals = p.array,intercepts = int.array, terms = vars)
