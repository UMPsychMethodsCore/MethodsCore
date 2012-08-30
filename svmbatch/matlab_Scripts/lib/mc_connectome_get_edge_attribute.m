function [ attr ] = mc_connectome_get_edge_attribute(nConEl,ParamPath,attrIdx,NetMapPath)
%MC_CONNECTOME_GET_EDGE_ATTRIBUTES Retrieve node attributes for a set of edges
% 
% 
%   INPUT
%       nConEl      -   The number of elements in your connectome
%       ParamPath   -   A full file path to a "parameters" file as might be
%                       produced by SOM
%       attrIdx     -   Index of the attribute you want to retrieve
%               1   -   X Coordinate (MNI Space)
%               2   -   Y Coordinate (MNI Space)
%               3   -   Z Coordinate (MNI Space)
%               4   -   Network (must also provide NetworkMapPath)
%       NetMapPath  -   A full file path to an image in the same space as
%                       yours with values for each voxel that indicate
%                       network membership
% 
%   OUTPUT
%       attr        -   2 * nConEl Matrix. Row 1 is selected attribute for
%                       node 1 of the corresponding edge. Row 2 is selected
%                       attribute for node 2 of corresponding edge.
%                       NOTE: Which node is 1 and which is 2 is somewhat
%                       arbitrary.


%% Load up Parameter File

param=load(ParamPath);

roiMNI=param.parameters.rois.mni.coordinates;

nRoi=size(roiMNI,1);

% Figure out number of connectome elements

nConEl = (nRoi * (nRoi - 1)) / 2;

%% Initialize attr matrix

attr=zeros(2,nConEl);

%% Figure out indices into Node1 and Node2

[Node1Idx Node2Idx] = find(mc_unflatten_upper_triangle(ones(nConEl)));

%% If trying to get Network info, look it up

if attrIdx == 4
    roiMNI = mc_network_lookup(NetMapPath,roiMNI);
end

%% Grab the attributes

attr(1,:) = roiMNI(Node1Idx,attrIdx)';
attr(2,:) = roiMNI(Node2Idx,attrIdx)';

end