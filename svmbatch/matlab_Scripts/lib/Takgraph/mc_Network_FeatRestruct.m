function [ a ] = mc_Network_FeatRestruct( a )
% mc_Network_FeatRestruct - restructure your vector of features into a square matrix, 
% and permute the square matrix to follow network structure
% 
%       INPUTS
% 
%               REQUIRED
%                       a.tvalues               -       1 x nFeat matrix of feature t values
%                                                       For downstream functions to work, only allowed values are...
%                                                               1 - Edge Not Significant
%                                                               2 - Edge Significant & Positive
%                                                               3 - Edge Significant & Negative  
%                       a.bvalues               -       1 x nFeat matrix of feature beta values
%                       a.NetworkLabels         -       1 x nROI matrix of network labels. This will be used as is (no network expansion)
%
%              
%       OUTPUTS(New subfields of a)
% 
%               a.mediator                      -       A set of variables that are useful for the many downstream functions, containing
%                       a.mediator.tsquare      -       a.tvalues restructured as network-sorted upper triangular matrix (nROI x nROI)
%                       a.mediator.bsquare      -       a.bvalues restructured as network-sorted upper triangular matrix (nROI x nROI)
%                       a.mediator.sorted       -       1 x nROI matrix of sorted network labels.
%                       a.mediator.sortIDX      -       1 x nROI of indices used to resort Network labels into a.mediator.sorted    
% 

% Make your square matrix
tsquare       = mc_unflatten_upper_triangle(a.tvalues);
bsquare       = mc_unflatten_upper_triangle(a.bvalues);

% Sort the square by networks
[sorted, sortIDX] = sort(a.NetworkLabels);

tsquare       = tsquare(sortIDX,sortIDX);
bsquare       = bsquare(sortIDX,sortIDX);

% Get it all back on the upper triangle
tsquare       = triu(tsquare + tsquare',1); 
bsquare       = triu(bsquare + bsquare',1); 

% Save the result back to a
a.mediator.tsquare       = tsquare;
a.mediator.bsquare       = bsquare;
a.mediator.sorted       = sorted;
a.mediator.sortIDX      = sortIDX;

end

