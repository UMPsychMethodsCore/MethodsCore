function [ output ] = mc_graphtheory_permutation( network,input,nNet,nMetric)
% MC_GRAPHTHEORY_PERMUTATION 
% Calculating group mean difference with permuted label
% INPUT
%       nNet                     -   Number of networks
%       nMetric                  -   Number of metrics
%       input 
%             input.netcol       -   Number of columns with extra info like
%                                    network and threshold
%             input.subdata      -   nSub x (nMetric + input.netcol) matrix,
%                                    first input.netcol columns contains extra 
%                                    info, the rest each column is measures of
%                                    one kind of metric.
%             input.types        -   nSub x 1 vector with info of subject type
%             input.unitype      -   number of subject types
%
%       network
%             network.covtype    -   0 -- alphabetically, control group name 
%                                         in the front, like 'H' and 'O'
%                                    1 -- alphabetically, experiment group 
%                                         name in the front, like 'A' and 'H'
%             network.netinclude -   Which networks to include
%                                    -1 -- Whole Brain;
%                                    Array of intergers ranging from 1 to 13 -- SubNetworks
% OUTPUT
%        output                  -   Group mean difference with permuted
%                                    label
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create random labels with fixed group sizes

Label = input.types;
ind = randperm(length(Label));
permLabel = Label(ind)';
input.types = permLabel;

% mean difference
[permresults] = mc_graphtheory_meandiff(network,input,nNet,nMetric);

output = permresults.meandiff;

end

