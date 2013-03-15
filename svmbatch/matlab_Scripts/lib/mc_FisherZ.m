function [ z ] = mc_FisherZ(r)
% A simple function to convert a matrix of Pearson R's into Z
% scores using Fisher's Z Transformation

z = 0.5 * log( (1+r) ./ (1-r) );
