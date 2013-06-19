function [ output ] = mc_graphtheory_permutation( types,unitype,covtype,data,netinclude,nNet,nMetric)
%MC_GRAPHTHEORY_PERMUTATION Summary of this function goes here
%   Detailed explanation goes here
%% Create random labels with fixed group sizes
ind = randperm(length(types));
permLabel = types(ind)';

%% 2 sample t-test  
[~,output,~,~,~,~] = mc_graphtheory_ttest(permLabel,unitype,covtype,data,netinclude,nNet,nMetric);




end

