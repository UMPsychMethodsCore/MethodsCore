function [ discrimpower ] = mc_calc_discrim_power_paired( data, label, DiscrimType )
%MC_CALC_DISCRIM_POWER_PAIRED Calculative feature-wise discriminative power
%for paired connectomic data
% 
%   INPUT
%       data        -   Data produced after mc_calc_deltas_paired, and likely
%                       run through mc_connectome_clean.
%                       nSubject*2 x nFeature matrix of data.
%       label       -   nExamples*2 x 1 matrix of labels. Only positive (+1)
%                       examples as indexed by labels will be used
%       discrimtype -   string
%           't-test'    -   do one sample t-test
%           'fracfit'   -   use "fractional fitness" approach


data=data(label==+1,:); % subset data to only grab positive examples

switch DiscrimType
    case 'fractfit'
        discrimpower=max( [...
            sum(data>0,1)/size(data,1) ;
            sum(data<0,1)/size(data,1)
            ]);
        
    case 't-test'
        [h, p] = ttest(data);
        
        discrimpower = 1 - p ; %take the complement of p
        

end

mc_bigsmall