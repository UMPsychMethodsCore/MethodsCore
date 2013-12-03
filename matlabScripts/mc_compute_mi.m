function mi = mc_compute_mi( train, trainlabels )
% mi = mc_compute_mi( train, trainlabels )
%|------------------------------------------------------------------------------|%
%| Description:
%|  Compute the mutual information between the individual features and the
%|  output labels.
%|  
%|  Code is still under revision, as it assumes the features are continuous
%|  in the range of [-1, +1] (since we are using correlations as features), 
%|  and discretization is done over [-1:0.1:1]
%|
%|  The code assumes the file "estmutualinfo.mexa64" is within the path.
%|  This file can be downloaded from 
%|  http://www.mathworks.com/matlabcentral/fileexchange/14888
%|
%|  See the following paper written by the authors of "estmutualinfo.mexa64" 
%|   (seems very relevant to our work)
%|  "Feature Seleciton based on Mutual Information: Criteria of Max-Dependency, 
%|   Max-Relevance, and Min-Redundancy", IEEE-PAMI 2005
%|   http://ieeexplore.ieee.org/iel5/34/31215/01453511.pdf
%|------------------------------------------------------------------------------|%
%| Input: 
%|   train (ntrain x numFeat)
%|          - Matrix containing the training data
%|            (Features are stacked in a row-wise fashion)
%|   trainlabels (ntrain x 1)
%|          - Labels associated with the "train".  
%|------------------------------------------------------------------------------|%
%| Output: 
%|   mi (numFeat x 1)
%|          - mutual information between the individual features and the
%|            output label.
%|------------------------------------------------------------------------------|%
%| 6/25/2012
%|------------------------------------------------------------------------------|%
[numTrain, numFeatures] = size(train);

mi = zeros(numFeatures,1);

%| p_label = marginal distribution of the labels {-1 or +1}
p_label = zeros(1,2);
p_label(1) = sum( trainlabels == -1 )/numTrain;
p_label(2) = sum( trainlabels == +1 )/numTrain;

indYm1 = trainlabels == -1; %| indices with 'm'inus labels (y = -1)
indYp1 = trainlabels == +1; %| indices with 'p'lus  labels (y = +1)

for i = 1:numFeatures
    x = train(:,i);    
    %| Use histogram approach (ie, rect-kernel function for the parzen window)
    %|-----------------------------------------------------------------------|%
    %| Brute force...quite slow
    %|          p_joint = [hist( x( trainlabels ==-1), [-1:0.1:1]); ...'
    %|                     hist( x( trainlabels == 1), [-1:0.1:1])] /numTrain;
    %|-----------------------------------------------------------------------|%
    %| The following is a much faster way to create the histogram
    xm1 = x(indYm1); %| features with negative label
    xp1 = x(indYp1); %| features with positive label
    
    %| Joint probability distribution matrix
    p_joint = full([ sparse(1, round(10*xm1)+11, 1, 1, 21); ...
                     sparse(1, round(10*xp1)+11, 1, 1, 21)]) / numTrain;

    %| Marginal distribution of the feature
    p_feature = sum(p_joint,1);
    mi(i) = estmutualinfo( p_joint, p_feature, p_label);
end