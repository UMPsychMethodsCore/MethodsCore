% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% A routine to read mask information
%
% function maskName = SOM_ReadMasks(maskName)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function maskName = SOM_MaskRead(maskName)

maskName.ImgHDR   = spm_vol(maskName.File);
maskName.ImgVol   = spm_read_vols(spm_vol(maskName.File));
maskName.ImgMask  = maskName.ImgVol > maskName.ImgThreshold;
maskName.ROIIDX   = find(maskName.ImgMask);

return

%
% all done.
% 
