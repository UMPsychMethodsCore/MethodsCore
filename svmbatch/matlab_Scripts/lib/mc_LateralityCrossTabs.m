function [ out ] = mc_LateralityCrossTabs.m (in)
%MC_LATERALITYCROSSTABS A function to calculate left/right laterality of edges
%
%       INPUTS
%               in.roiMM        -       nROI x 3 matrix of ROI coordinates in MM (MNI)
%               in.edgemat      -       nROI x nROI matrix of which edges are "on"
%               in.nets         -       nROI x 1 matrix of network affiliations
%
%       OUTPUT
%               out             -       4D array of laterality. Dimensions are as follows
%                                       D1 - Network 1
%                                       D2 - Network 2
%                                       D3 - Network 1 Side (Left, Right)
%                                       D4 - Network 2 Side (Left, Right)


% figure out basic properties
unets = sort(unique(in.nets);
nnets = numel(unets);
nROI = size(in.nets,1);

%identify unique nets
out = zeros(nnets,nnets,2,2);

for inet = 1:nnets
    for jnet = inet:nnets
        cedgemat = in.edgemat
        mask = zeros(size(cedgemat));
        mask(in.nets == unets(inet), in.nets == unets(jnet)) = 1;
        mask(in.nets == unets(jnet), in.nets == unets(inet)) = 1;
        cedgemat = triu(cedgemat .* mask);
        [crow ccol] = find(cedgemat);
        
        
        
        
