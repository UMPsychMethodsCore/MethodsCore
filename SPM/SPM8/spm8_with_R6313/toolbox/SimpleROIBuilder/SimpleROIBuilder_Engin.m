%+---------------------------------------
%|
%| Robert C. Welsh
%| 2006.09.26 - 2011
%|
%| Ann Arbor, MICHIGAN
%|
%| Point to a reference image and drop an
%| ROI. - Sphere or box. You can drop as 
%| many as you want.
%|
%+---------------------------------------
%
% function SimpleROIBuilder_Engin(refImage,roiINFO,maskIMGName)
%
% Input parameters:
%
%
% refImage
%    The reference image name, which defines the space.
%
% roiINFO
%    A structure for each ROI to be defined in this space
%   
%      roiINFO{iROI}.center_mm   in mm coordinates in the image defining
%                                the space.
%
%      roiINFO{iROI}.type        'sphere' or 'box'
%
%      roiINFO{iROI}.size
%
% mergeROI
%    Collapse all of the roi info in "roiINFO" into a single
%    output image or one image per roi defined.
%

function SimpleROIBuilder_Engin(refImage,roiINFO,maskIMGName)

%
%
%

global SimpleROIBuilderBatch

SCCSid  = '1.0';

global BCH; %- used as a flag to know if we are in batch mode or not.

%-GUI setup
%-----------------------------------------------------------------------

% Pick up the header.
try
    P_HDR        = spm_vol(refImage);
catch
    fprintf('Error attempting to reference image : %s\n',refImage);
    return
end

maskIMG         = zeros(P_HDR.dim(1:3));
maskHDR.dim     = P_HDR.dim;
maskHDR.mat     = P_HDR.mat;
maskHDR.descrip = 'SimpleROIBuilder Binary Image w/ ROIs';

% Now build the name of the output image, but place in the pwd.

[pn fn en] = fileparts(maskIMGName);

% Lets assume we are making analze image/header.

if length(en) < 1
  en = '.img';
end

switch lower(en)
    case {'.img','.nii'}
    otherwise
        fprintf('Only .img and .nii are supported\n');
        return
end

maskHDR.fname   = fullfile(pn,[fn en]);
 
% Create a matrix of coordinates for each voxel.

xOrds = (1:P_HDR.dim(1))'*ones(1,P_HDR.dim(2));
yOrds = ones(P_HDR.dim(1),1)*(1:P_HDR.dim(2));
xOrds = xOrds(:)';
yOrds = yOrds(:)';

Coords = zeros(3,prod(P_HDR.dim(1:3)));

for iZ = 1:P_HDR.dim(3)
    zOrds = iZ*ones(1,length(xOrds));
    Coords(:,(iZ-1)*length(xOrds)+1:iZ*length(xOrds)) = [xOrds; yOrds; zOrds];
end

% Now put them into mm's

mmCoords = P_HDR.mat*[Coords;ones(1,size(Coords,2))];
mmCoords = mmCoords(1:3,:);

boxBIT   = zeros(4,size(mmCoords,2));

% Now loop on the ROI definitions and drop them
% into the mask image volume matrix.

% How many ROIs to process?

nROIS         = length(roiINFO);

for iROI = 1:nROIS
    % Found the center of this ROI in voxels
    % and then build it.
    xs = mmCoords(1,:) - roiINFO{iROI}.center_mm(1);
    ys = mmCoords(2,:) - roiINFO{iROI}.center_mm(2);
    zs = mmCoords(3,:) - roiINFO{iROI}.center_mm(3);
    switch lower(roiINFO{iROI}.type)
        case 'sphere'
            radii           = sqrt(xs.^2+ys.^2+zs.^2);
            VOXIdx          = find(radii<=roiINFO{iROI}.size);
        case 'box'
            xsIDX           = find(abs(xs)<=roiINFO{iROI}.size(1));
            ysIDX           = find(abs(ys)<=roiINFO{iROI}.size(2));
            zsIDX           = find(abs(zs)<=roiINFO{iROI}.size(3));
            boxBIT          = 0*boxBIT;
            boxBIT(1,xsIDX) = 1;
            boxBIT(2,ysIDX) = 1;
            boxBIT(3,zsIDX) = 1;
            boxBIT(4,:)     = boxBIT(1,:).*boxBIT(2,:).*boxBIT(3,:);
            VOXIdx          = find(boxBIT(4,:));
    end
    maskIMG(VOXIdx) = 1;
end

% Now write out the image.

switch lower(spm('Ver'))
    case 'spm2'
        maskHDR.pinfo = [1; 0; 0];
        spm_write_vol(maskHDR,maskIMG);
    case {'spm5','spm8'}
        maskHDR.dt    = [2 0];
        spm_write_vol(maskHDR,maskIMG);
    otherwise
        fprintf('I do not recognize that current version of spm : %s',spm('Ver'));
        return
end

fprintf('\nFinished Building ROI Image.\n');

%
% All done.
%
