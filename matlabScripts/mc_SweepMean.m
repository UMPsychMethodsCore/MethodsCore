function [ y ] = mc_SweepMean( x )
%MC_SWEEPMEAN Subtract the columnwise mean out of a matrix
%   X - Rectangular matrix. 

xbar=mean(x,1);
xbar=repmat(xbar,size(x,1),1);
y=x-xbar;

end

