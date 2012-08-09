%% Load dataset


% data - nExample x nFeat matrix of features

%% Calculate aggregate discriminative power of edges

discrim=mc_calc_discrim_power(data,labels,'t-test');

%% Array in square matrix

discrim_square = mc_unflatten_upper_triangle(discim);

%% Permute edges to follow labels

% Load ROI file

% Sort ROIs on labels, return idx

% Sort square matrix on idx

%% Make heatmap


%% Add overlap to heatmap

