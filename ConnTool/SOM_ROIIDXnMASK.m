% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% SOM_ROIIDXnMASK
%
% Determine the indices to the ROI that is in the mask that is provided
%
% function IDX = SOM_ROIIDXnMASK(parameters,ROIIDX)
%
% INPUT
% 
% parameters          = input to SOM_PreProcessData
% 
% ROIIDX              = linear indices of the above ROI
%
%
% OUTPUT
%
% IDX   = indices of the ROI into the masking image.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function IDX = SOM_ROIIDXnMASK(parameters,ROIIDX)

nVOXELS = prod(parameters.maskInfo.size);

maskIMG = zeros(nVOXELS,1);
roiIMG  = zeros(nVOXELS,1);

% Create an array of the masking image.
maskIMG(parameters.maskInfo.iMask) = 1;

% Create an array of the ROI image.
roiIMG(ROIIDX)                     = 1;

% Take the product of the two such that a "1" is only there both the ROI
% and the masking image are present.

combinedIMG = maskIMG.*roiIMG;

% Now extract all bits from the combined image (the "1"'s and "0"'s).
roiBITS = combinedIMG(parameters.maskInfo.iMask);

% Find the location of the surviving "1"'s. The values returned are the
% indices of the ROI in the mask. 

IDX = find(roiBITS);

return

