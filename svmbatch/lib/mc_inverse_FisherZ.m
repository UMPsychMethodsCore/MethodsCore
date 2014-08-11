function  [r] = mc_inverse_FisherZ(z)
% A simple function to do the inverse of Fisher's Z transformation

r = (exp(2.*z)-1)./(exp(2.*z)+1);
