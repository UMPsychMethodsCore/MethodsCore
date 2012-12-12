## Load


## Load masterdatafile

master = read.csv(masterpath,colClasses = 'character')

if( includefactor != '' ){
  master = master[,includefactor] #Subset only to those subjects intended for this analysis
}

nSub = nrow(master)

## Load connectomes

library('R.matlab') #Make sure you are able to load matlab files

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
}

## Do the modeling

model.formula = R ~ TYPE + AGE

nBeta = length(all.vars(x))

t.array = matrix(nrow = nBeta, ncol = nFeat, rep(0,nBeta * nFeat))

for (iFeat in 1:nFeat){
  mini = data.frame(R = superflatmat[,iFeat],master)
  mini$AGE = as.numeric(mini$AGE)
  model.fit = lm(model.formula,mini)
  t.array[,iFeat] = summary(model.fit)$coef[,'t value']
  if(iFeat %% 1000 == 0){
    print(iFeat)
  }
}
