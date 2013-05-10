% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2005
% Ann Arbor MI.
%
% function results = SOM_Fix(SOMResults,maskName)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_Fix(SOMResults,maskName)

maskHDR           = spm_vol(maskName);

maskVOL           = spm_read_vols(maskHDR);

SOMResults.iMask  = find(maskVOL);

SOMResults.header = maskHDR;

results = SOMResults;

return

%
% All done.
% 