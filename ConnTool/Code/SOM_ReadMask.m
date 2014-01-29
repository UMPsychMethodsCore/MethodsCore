% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2006
%
% Routine to read time-series data.
%
% function [results, maskInfo] = SOM_ReadMask(PMask)
%
%     P is array of file names (like that returned from spm_get)
%     PMask is a file name for a binary mask.
%     otherVoxels is an array of explicitly desired voxels.
% 
% Only those voxels that are included in the mask are read.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function [results, maskInfo, analyzeFMT] = SOM_ReadMask(PMask)

[fPath fName fExt] = fileparts(PMask);

if strcmp(lower(fExt),'.img') == 1
  analyzeFMT = 1;
else
  analyzeFMT = 0;
end

if analyzeFMT == 1
  maskInfo.header = spm_vol(PMask);
  maskInfo.analyzeFMT = 1;
  results = spm_read_vols(maskInfo.header);
else
  maskInfo.analyzeFMT = 1;
  maskInfo.fPath = fPath;  
  load(PMask);
end

maskInfo.iMask = find(results);

return
