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
%                                       D3 - Network 1 Side (Left, MidLine, Right)
%                                       D4 - Network 2 Side (Left, Midline, Right)


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
        mask(in.nets == unets(inet), in.nets == unets(jnet)) = 1; % this has been sorted, so just grab the upper piece
        cedgemat = triu(cedgemat .* mask);
        [net1roi net2roi] = find(cedgemat);
        net1x = in.roiMM(net1roi,1);
        net2x = in.roiMM(net2roi,1);
        net1side = zeros(size(net1x)
        net2side = zeros(size(net2x);
        net1size(net1x<0) = 1; % left
        net1size(net1x==0) = 2; % midline
        net1size(net1x>0) = 3; %right
        net2size(net2x<0) = 1; % left
        net2size(net2x==0) = 2; %midline
        net2size(net2x>0) = 3; % right
        
        for n1side = 1:3
            for n2side = 1:3
                out(inet,jnet,n1side,n2side) = sum(net2size(net1size==n1side)==n2side);
            end
        end
    end
end
