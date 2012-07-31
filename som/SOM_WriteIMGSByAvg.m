% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2005
% Ann Arbor MI.
%
% function results = SOM_Write(SOMResults)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_WriteIMGSByAvg(SOMResults)

curDIR = pwd;

[wts awt] = SOM_Weighted_SUM(SOMResults);

[oWTS oI] = sort(awt);

iIMG = 0;

for ix = size(SOMResults.SOM,2):-1:max([1 size(SOMResults.SOM,2)-9])
  iIMG = iIMG + 1;
  if SOMResults.maskInfo.analyzeFMT == 1
    hdr = SOMResults.header;
    hdr.fname = fullfile(curDIR,sprintf('som_byAvg_%03d.img',iIMG));
    hdr.pinfo = [1;0;0];
    somMap = zeros(hdr.dim(1:3));
  else
    somMap = zeros(SOMResults.maskInfo.size);
  end
  somMap(:,:,:) = nan;
  ii = find(SOMResults.IDX == oI(ix));
  somMap(SOMResults.iMask(ii)) = SOMResults.WTS(ii);
  if SOMResults.maskInfo.analyzeFMT == 1
    spm_write_vol(hdr,somMap);
  else
    save(fullfile(SOMResults.maskInfo.fPath,sprintf('som_byAvg_%03d',iIMG)),'somMap');
  end
end
clear SOMResults
clear somMap

return

%
% All done.
%
    
