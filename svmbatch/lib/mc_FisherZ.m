function [ z ] = mc_FisherZ(r,Inv)
% A simple function to convert a matrix of Pearson R's into Z
% scores using Fisher's Z Transformation
% If Inv is set to true, it will do inverse fisher z
if ~exist('Inv','var')
    Inv = 0;
end

if Inv==0
    z = 0.5 * log( (1+r) ./ (1-r) );
elseif Inv==1
    z = (exp(2 * r) - 1) ./ (exp(2 * r) + 1);
end
