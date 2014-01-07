% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2005
% Ann Arbor MI.
%
% function results = SOM_Write(SOMResults)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_WriteIMGS(SOMResults)

curDIR = pwd;

wts = SOM_Weighted_SUM(SOMResults);

[oWTS oI] = sort(wts);

iIMG = 0;

for ix = 100:-1:96
    iIMG = iIMG + 1;
    hdr = SOMResults.header;
    hdr.fname = fullfile(curDIR,sprintf('som_%03d.img',iIMG));
    hdr.dim(4) = 64;
    hdr.pinfo = [1;0;0];
    vol = zeros(hdr.dim(1:3));
    vol(:,:,:) = nan;
    ii = find(SOMResults.IDX == oI(ix));
    vol(SOMResults.iMask(ii)) = SOMResults.WTS(ii);
    spm_write_vol(hdr,vol);
end

clear vol
clear SOMResults

return

%
% All done.
%
    
