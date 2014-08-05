function [ data_delta, label, SubjIDs, ContrastAvail ] = mc_calc_deltas_paired( data_conditions, SubjAvail, ContrastVec)
%MC_CALC_DELTAS_PAIRED After loading up your paired data, calculate some
% deltas. This routine will calculate both the positive linear combination
% you provide in ContrastVec and its negation.
%
%   INPUT
%       data_conditions     -   Should come straight out of
%                               mc_load_connectomes_paired
%       SubjAvail           -   Also from mc_load_connectomes_paired
%       ContrastVec         -   How do you want to combine your conditions.
%                               Provide weights for each. Should be 1 x
%                               nCondition matrix. Example: You have three
%                               conditions, and want to calculate the delta
%                               between the first and third. Provide [1 0
%                               -1]
% 
%   OUTPUT
%       data_delta          -   A nSub*2 x nFeature matrix. Rows index examples,
%                               columns index features. The top half of the
%                               matrix holds the positive half of the linear
%                               combinations, the bottom half of the matrix
%                               holds the negations of the top half in the
%                               same order.
%       label               -   In case there was any confusion as to the
%                               row-wise sort-order of data_delta, labels
%                               provides further clarification as to the
%                               positive and negative examples. nSub*2 x 1
%                               matrix.
%       SubjIDs             -   nSub*2 x 1 matrix. This indicates subject
%                               reusage. Provided so that if you want to do
%                               some crazier leave three out cross
%                               validation or something, there's some
%                               record of the paired structure in
%                               data_delta.
%       ContrastAvail       -   Which subjects were used in data_delta

nCond = size(data_conditions,3);

ContrastAvail = all(SubjAvail(:,find(ContrastVec)),2); % Figure out contrast availability

data_weighted=zeros(size(data_conditions));

for iCond=1:nCond
    data_weighted(:,:,iCond) = data_conditions(:,:,iCond) * ContrastVec(iCond);
end

% Prune based on contrast availability
data_weighted = data_weighted(logical(ContrastAvail),:,:);

data_delta_pos=sum(data_weighted,3);
data_delta_neg=data_delta_pos * -1;

data_delta = [data_delta_pos ; data_delta_neg];

label = [repmat(1,size(data_delta_pos,1),1) ;repmat(-1,size(data_delta_neg,1),1)];

nSub = size(data_delta_pos,1);

SubjIDs = [1:nSub 1:nSub]';