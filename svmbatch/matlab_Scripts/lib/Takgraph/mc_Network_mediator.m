function [ a ] = mc_Network_mediator( a )
% MC_NETWORK_MEDIATOR
% 
% This function will implement the cell counting based on network distributions. This is usually used as the first step
% of TakGraph generation. 
% 
%       INPUTS
% 
%               REQUIRED
%                       a.prune                 -       1 x nFeat logical matrix of features to plot
%                       a.NetworkLabels         -       1 x nROI matrix of network labels. This will be used literally.
%
%               OPTIONAL
%                       a.pruneColor.values     -       1 x nFeat matrix of color values that will index into a.pruneColor.map
%                       a.pruneColor.map        -       A colormap object that will be directly indexed by pruneColor.values. 
%              
%       OUTPUTS(New subfields of a)
% 
%               a.mediator                      -       A set of variables that are useful for the following functions, and these variables contain:
%                       a.mediator.square       -       Transform a.pruneColor.values from a 1 x nFeat matrix to a sorted upper triangular matrix. 
%                       a.mediator.square_prune -       Transform a.prune from a 1 x nFeat matrix to a sorted upper triangular matrix.      
%                       a.mediator.sorted       -       1 x nROI matrix of sorted network labels.
% 

% Deal with coloration, if enabled
if(isfield(a,'pruneColor'))
    a.pruneColor.values(~logical(a.prune)) = 1; % Set colors outside of prune to 1, so they will use first colormap color
else % If no a.pruneColor passed, set it up as if the colormap goes white, black, and the values are 1s and 2s
    a.pruneColor.values                    = zeros(size(a.prune));
    a.pruneColor.values(logical(a.prune))  = 2;
    a.pruneColor.values(~logical(a.prune)) = 1;
    a.pruneColor.map                       = [1 1 1; 0 0 0]; % Define a colormap where 1 = white, 2 = black
end

% Make your square matrix
square       = mc_unflatten_upper_triangle(a.pruneColor.values);
square_prune = mc_unflatten_upper_triangle(a.prune);

% Sort the square by networks
[sorted, sortIDX] = sort(a.NetworkLabels);

square       = square(sortIDX,sortIDX);
square_prune = square_prune(sortIDX,sortIDX);

% Get it all back on the upper triangle
square       = triu(square + square',1); 
square_prune = triu(square_prune + square_prune');

% Save the result back to a
a.mediator.square       = square;
a.mediator.square_prune = square_prune;
a.mediator.sorted       = sorted;


end

