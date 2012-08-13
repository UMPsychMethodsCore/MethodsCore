function [ discrimpower ] = mc_calc_discrim_power_unpaired( data, labels, DiscrimType )
%MC_CALC_DISCRIM_POWER Summary of this function goes here
%   INPUT
%       data        -   nExamples x nFeatures matrix of data
%       labels      -   nExamples * 1 matrix of labels
%       DiscrimType -   string
%           'tau-b'     -   Use tau-beta (very slow!)
%           'mutinfo'   -   Use mutual information criteria
%           'fracfit'   -   Use fractional fitness approach
%           't-test'    -   Do t-test
%
%   OUTPUT
%       discrimpower    -   1 * nFeatures matrix of discrim power.
%
% NOTE - Discrim power is always expressed in terms of greater value =
% greater discrim power. For results that return p-values, we will take the
% complement, so a p of .05 will become .95.
%
% NOTE - Labels should +1 or -1. For one-class cases, provide only +1's and
% only provide one of the cases (no need to give both positive and
% negations).


% Determine if this is a one class problem or not

oneclass=0;

if all(unique(labels)==1)
    oneclass=1;
end



switch DiscrimType
    case 't-test'% In ttest mode, do a 2-sample (groupwise) t-test on all features
        
        [h,p] = ttest2(data(labels==+1,:),data(labels==-1,:));
        
        % Clean out NaNs by setting to 1 (no significance)
        p(isnan(p))=1;
        
        
        % To keep the direction of discriminative power consistent,
        % (i.e larger values indicate MORE discriminant power),
        % take complement of p-values so small values (more
        % significant) become large (more discriminant)
        discrimpower=1-p;
        
        
        
    case 'tau-b'
        % Initialize the fractions object which will store the
        % tau-b's
        discrimpower=zeros(1,size(data,2));
        
        % Loop over features
        for iFeat=1:size(data,2)
            
            if any(diff(data(:,iFeat))) % Check to be sure that all elements aren't the same
                discrimpower(iFeat)=ktaub([labels(:,1) data(:,iFeat)],.05,0);
                
            end
        end
        discrimpower = abs(featurefitness);
        
    case 'mutinfo'
        %|------------------- Mutual Information ----------------------------------------|%
        
        discrimpower = mc_compute_mi( data, labels );
        %%
        
    case 'fractfit'
        discrimpower=max( [...
            sum(data>0,1)/size(data,1) ;
            sum(data<0,1)/size(data,1)
            ]);
        
end

end

