flatten.upper.triangle = function (squaremat){

  squaremat.protected = squaremat
  squaremat.protected[squaremat.protected==0] = Inf  # Set any of the zeros to infinte to protect them for now

  squaremat.triu = as.matrix(triu(squaremat.protected,1))
  flatmat.full = c(squaremat.triu)
  flatmat = flatmat.full[flatmat.full!=0] # Drop all zero elements
  
  flatmat[is.infinite(flatmat)] = 0;

  return(flatmat)
}


unflatten.upper.triangle = function (flatmat){
  nROI = ( (8*length(flatmat) + 1) ^ (1/2) + 1 ) / 2

  connectomeIDx = matrix(nrow = nROI, ncol = nROI, 1:(nROI)^2 )
  connectomeIDx.flat = flatten.upper.triangle(connectomeIDx)
  squaremat = matrix(nrow = nROI, ncol = nROI, rep(0,nROI^2))
  squaremat[connectomeIDx.flat] = flatmat
  return(squaremat)
}


fisherz = function(r){
  z = .5*(log(1 + r) - log(1-r))
  return(z)
}


massuni = function ( Y, X){
  # This function will do mass univariate linear modeling, in the same mode as mc_CovariateCorrection.
  # See the help there for more details.
  # It is analagous to running mc_CovariateCorrection in fully raw mode (3)
  Y = as.matrix(Y)
  X = as.matrix(X)

  betas = pseudoinverse(X) %*% Y

  residuals = Y - X %*% betas

  intercepts = X[,1,drop=F] %*% betas[1,,drop=F]
  corrected = intercepts + residuals
  
  C = solve(aperm(X) %*% X)
  tvals=matrix(nrow = dim(X)[2] , ncol = dim(Y)[2], rep(0,dim(X)[2] * dim(Y)[2]))
  for (j in 1:dim(X)[2]){
    tvals[j,] = betas[j,] / sqrt(C[j,j] * apply(residuals^2,2,sum) / (dim(Y)[1] - dim(betas)[1]) )
  }

  pvals = 2 * (1 - pt(abs(tvals),dim(Y)[1] - dim(betas)[1]))
  results = list ( corrected = corrected , residuals = residuals, betas = betas, intercepts = intercepts, tvals = tvals, pvals = pvals)
  return(results)
}

lmeMCfit = function(ind, model.fixed,model.random,data,master,output){
  mini = data.frame(R = data[,ind],master)
  model.fit = lme(fixed = model.fixed, random = model.random, data = mini)
  out=data.frame(t = summary(model.fit)$tTable[,'t-value'])
  out$p = summary(model.fit)$tTable[,'p-value']
  out$int = coef(model.fit)[,1]
  if(ind %% 1000 == 0){
      print(ind)
    }
  switch(output,simple=return(out),full=return(model.fit))
}

lmeMCcorrection = function(ind,model.fixed,model.random,data,master){
  if(ind %% 1000 == 0){ # report progress
      print(ind)
    }

  mini = data.frame(R = data[,ind],master)
  model.fit = lme(fixed = model.fixed, random = model.random, data = mini)
  X.real = mini[,all.vars(model.fixed)] # subset to only variables in model
  X.real = model.matrix(model.fixed,X.real) # code into a design matrix
  X.ctr = apply(X.real,2,mean) # find the ctr point (mean) of the design matrix
  X.ctr = aperm(as.matrix(X.ctr)) # make it a proper matrix
  X.ctr.Lev0 = X.ctr # use the center point, but set the Fx of interest to level 0
  X.ctr.Lev0[2] = 0
  X.ctr.Lev1 = X.ctr # use the center point, but set the Fx of interest to level 1
  X.ctr.Lev1[2] = 1
  X.ctr.rep = X.ctr[rep(1,nrow(X.real)),] # repeat the center point
  X.ctr.rep[,2] = X.real[,2] # replace the Fx of interest with the real values

  betas = as.matrix(apply(coef(model.fit),2,mean)) # extract the betas for fixed effects

  typical.Lev0 <- X.ctr.Lev0 %*% betas # estimate the "typical" level 0 observation
  typical.Lev1 <- X.ctr.Lev1 %*% betas # estimate the "typical" level 1 observation
  cleansed = as.matrix(as.vector(X.ctr.rep %*% betas + residuals(model.fit))) #predict the values at "typical" settings for nuisance factors, and real settings for Fx of interest, add in the residuals, and coerce to drop extra attributes

  out = list(typical.Lev0 = typical.Lev0,
    typical.Lev1 = typical.Lev1,
    cleansed = cleansed)

  return(out)
}
