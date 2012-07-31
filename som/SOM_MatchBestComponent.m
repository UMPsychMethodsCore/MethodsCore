% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2010
%
% Find the SOM component that best matches the template being
% passed.
%
% function results = SOM_MatchBestComponent(BinaryConnectivityMap,TheTemplate)
%
%  BinaryConnectivityMap  = the binarized connectivity map, 
%                              1 = connection
%                              0 = none.
%
%  TheTemplate            = masking image with ROI.
%
%  results = the count of the voxels in and out of the ROI, but containted to the brain.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_MatchBestComponent(BinaryConnectivityMap,TheTemplate)

global SOMMem

results = [];

if isfield(SOMMem{1},'maskInfo') == 0
    return
end

maskDim = size(TheTemplate);

if sum(any(size(TheTemplate) - SOMMem{1}.maskInfo.size)) ~= 0
    fprintf('Masking template doesn''t match the size of the original data.\n');
    return
end

BrainMask = zeros(SOMMem{1}.maskInfo.size);

BrainMask(SOMMem{1}.maskInfo.iMask) = 1;

NTheTemplate = TheTemplate .* BrainMask;

ROIRemoved = sum(TheTemplate(:)-NTheTemplate(:));

NotTemplate = BrainMask.*(1 - NTheTemplate);

InCount = sum(BinaryConnectivityMap(find(NTheTemplate)));
OutCount = sum(BinaryConnectivityMap(find(NotTemplate)));

results = [InCount OutCount ROIRemoved];

return

%
% All done.
%

