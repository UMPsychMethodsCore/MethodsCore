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
