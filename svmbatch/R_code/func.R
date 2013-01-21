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
  Y = as.matrix(Y)
  X = as.matrix(X)
  X = cbind(rep(1,dim(x)[1]),x)  # add an intercept term

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

model.call = function(data,formula,fixed,random,mode){
  # mode refers to standard lm calls versus fancier modeling approaches and may be either lm or lme for now
  out = switch(mode,
  lm = lm(formula,data),
  lme = lme(fixed=model.fixed,random=random,data=data)
    )
return(out)  
}
