% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2006-2007
%
% Routine to extract time-series from 4D using 3D mask.
%
% function [results, maskInfo] = SOM_MaskData(4d-data,3d-mask,[othervoxels]);
%
% Input : 
%     
%        FourDData  - X * Y * Z * t
%        ThreeDMask -  X * Y * Z (binary image)
% 
%        otherVoxels -   See SOM_PrepData.
%
% Oupput : 
%      
%        results  - (space x time)
%        maskInfo - see SOM_PrepData.
%
% Only those voxels that are included in the mask are read.
%
%  NOTE : Eventually this needs to support NIFTI (nii) files.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function [results maskInfo] = SOM_MaskData(FourDData,ThreeDMask,otherVoxels);

% Did they pass any requests for 
% specific voxels to be extracted?

if exist('otherVoxels') ~= 1
  otherVoxels = [];
end

[xd yd zd nTime] = size(FourDData);

[xdm ydm zdm] = size(ThreeDMask);

if any([xdm ydm zdm]-[xd yd zd])
    fprintf('Data size doesn''t match mask size.\n');
    results  = -1;
    maskInfo = -1;
    return
end

indices = [];

maskInfo.size       = [xd yd zd];
maskInfo.analyzeFMT = 0;

% Use the current directory.

maskInfo.fPath      = pwd;

if size(otherVoxels,1) > 0
  indices = xd*yd*(otherVoxels(:,3)-1)+...
	    xd*(otherVoxels(:,2)-1)+...
	    otherVoxels(:,1);
end

% Find the indices of all voxels
% to be included in analysis.

maskInfo.iMask = find(ThreeDMask);

% How many to remove from the end.

maskInfo.remove  = 0;
maskInfo.indices = indices;   % index of other data.

% Are the requested voxels already included, 
% if not add to the list but mark for removal 
% before actual SOM calculation.

% Build a list of pointers to the data in the reduced set
% to where the voxels now live.
indexOfIndex = [];

for ii = 1:size(indices)
  if length(find(maskInfo.iMask == indices(ii))) == 0
    maskInfo.iMask = [maskInfo.iMask ;indices(ii)];
    maskInfo.remove = maskInfo.remove+1;
    indexOfIndex = [indexOfIndex length(maskInfo.iMask)];
  end
    indexOfIndex = [indexOfIndex find(maskInfo.iMask==indices(ii))];
end

maskInfo.indexOfIndex = indexOfIndex;

% Now extract it all.

fprintf('Extracting data...');

FourDData = reshape(FourDData,[prod([xd yd zd]) nTime]);

results = FourDData(maskInfo.iMask,:);

fprintf('\nDone\n');

clear FourDData
clear ThreeDMask

return

%
% All done.
%

