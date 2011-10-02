% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
%
% To determine if MNI coordinates are inside
% a binary mask image, looking at the sagital plane.
%
% 
% function inOutMask = roiPointsInMask(PMask,ROICoords)
%
%    PMask     = masking image
%    ROICoords = coordinates of the ROI in MNI to be checked.
%
% Return an array of indices that point to the coordinates in ROICoords
% that are within the mask.
%
%
% function inOutMask = SOM_roiPointsInMask(PMask,ROICoords)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function inOutMask = SOM_roiPointsInMask(PMask,ROICoords)

% Default is nothing in the mask.

inOutMask = [];

% Make sure that the coordinates are a n x 3 array

if size(ROICoords,2) ~= 3
    SOM_LOG('FATAL ERROR : Coordinates need to be x,y,z');
    return
end

inOutMask = zeros(size(ROICoords,1),1);

% Make sure that the masking file exists and can be read.

if exist(PMask,'file') == 0
    SOM_LOG('FATAL ERROR : Masking image is missing');
    return
end

try
    MVol = spm_read_vols(spm_vol(PMask));
catch
    SOM_LOG(sprintf('FATAL ERROR : spm can not read the masking file %s',PMask));
    return
end

% Let's re-binerize the mask

MVol = MVol > 0;

% We need the header so that we can get into the reference frame of the
% image.

MHdr = spm_vol(PMask);

% Get the voxel numbers.

ROICoordsVoxel = round((inv(MHdr.mat)*([ROICoords ones(size(ROICoords,1),1)]'))');

% Make a volume and use the index numbers as the values in the volume and
% then mask that with the masking volume and then search for remaining
% values. These are then the ROI indices that will be in the mask.

VALIDIDX = ones(length(ROICoordsVoxel(:,1)),1);

% Any voxels that are outside image we set to zero.

BADIDX1 = find(ROICoordsVoxel(:,1)>size(MVol,1));
BADIDX2 = find(ROICoordsVoxel(:,2)>size(MVol,2));
BADIDX3 = find(ROICoordsVoxel(:,3)>size(MVol,3));

ROICoordsVoxel(BADIDX1,1) = 0;
ROICoordsVoxel(BADIDX2,2) = 0;
ROICoordsVoxel(BADIDX3,3) = 0;

BADIDX1 = find(ROICoordsVoxel(:,1)<1);
BADIDX2 = find(ROICoordsVoxel(:,2)<1);
BADIDX3 = find(ROICoordsVoxel(:,3)<1);

ROICoordsVoxel(BADIDX1,1) = 0;
ROICoordsVoxel(BADIDX2,2) = 0;
ROICoordsVoxel(BADIDX3,3) = 0;

% The good voxels will have a "1" while bad will be a zero.

GOODCALC = ROICoordsVoxel(:,1).*ROICoordsVoxel(:,2).*ROICoordsVoxel(:,3);

% Now find the indices of the ones that are good.

IDXGood = find(GOODCALC);

% Now find out where they would appear in the image.

LINEARIDX = sub2ind(size(MVol),ROICoordsVoxel(IDXGood,1),ROICoordsVoxel(IDXGood,2),ROICoordsVoxel(IDXGood,3));

IDXVOL = 0*MVol;

% Set the voxel that is within the bounds of the image to have the value of
% the index from the array ROICoords.

IDXVOL(LINEARIDX) = IDXGood;

% Now mask this image with the masking image.

MaskIDX = IDXVOL.*MVol;

% Those that survive will have a value of the index from ROICoords and thus
% will be in the image.

inOutMask = MaskIDX(find(MaskIDX));

%
% All done.
%
