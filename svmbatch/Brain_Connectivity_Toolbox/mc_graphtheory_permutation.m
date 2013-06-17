function [ perm ] = mc_graphtheory_permutation( Types,ReadPath )
%MC_GRAPHTHEORY_PERMUTATION Summary of this function goes here
%   Detailed explanation goes here
%% Create random labels with fixed group sizes
ind = randperm(length(Types));
permLabel = Types(ind);

%% Call R script to do t-test
Rcmd = []
Rstatus = system(Rcmd);


end

