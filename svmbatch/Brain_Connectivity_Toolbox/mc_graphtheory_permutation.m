function [ output ] = mc_graphtheory_permutation( network,input,nNet,nMetric)
%MC_GRAPHTHEORY_PERMUTATION Summary of this function goes here
%   Detailed explanation goes here
%% Create random labels with fixed group sizes

Label = input.types;
ind = randperm(length(Label));
permLabel = Label(ind)';
input.types = permLabel;

%% mean difference
[permresults] = mc_graphtheory_meandiff(network,input,nNet,nMetric);

output = permresults.meandiff;

end

