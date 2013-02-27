function [ a ] = mc_Network_mediator( a )
% mc_Network_FeatRestruct - restructure your vector of features into a square matrix, 
% and permute the square matrix to follow network structure
% 
%       INPUTS
% 
%               REQUIRED
%                       a.values                -       1 x nFeat matrix of feature values
%                                                       For downstream functions to work, only allowed values are...
%                                                               1 - Edge Not Significant
%                                                               2 - Edge Significant & Positive
%                                                               3 - Edge Significant & Negative    
%                       a.NetworkLabels         -       1 x nROI matrix of network labels. This will be used as is (no network expansion)
%
%               OPTIONAL
%                       a.pruneColor.map        -       A colormap object that will be directly indexed by a.values. Not
%                                                       required for this function, but useful downstream.
%              
%       OUTPUTS(New subfields of a)
% 
%               a.mediator                      -       A set of variables that are useful for the many downstream functions, containing
%                       a.mediator.square       -       a.values restructured as network-sorted upper triangular matrix (nROI x nROI)
%                       a.mediator.sorted       -       1 x nROI matrix of sorted network labels.
% 

% Make your square matrix
square       = mc_unflatten_upper_triangle(a.values);

% Sort the square by networks
[sorted, sortIDX] = sort(a.NetworkLabels);

square       = square(sortIDX,sortIDX);

% Get it all back on the upper triangle
square       = triu(square + square',1); 

% Save the result back to a
a.mediator.square       = square;
a.mediator.sorted       = sorted;

end

