% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2005
% Ann Arbor MI.
%
% function results = SOM_WriteByMask(SOMResults)
%
% Take the order from the most populous map to the least
% and look for activation according to the mask.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_WriteIMGSByMask(SOMResults,maskingVol,name_extra)

if exist('name_extra') ~= 1
  name_extra = 'byMask';
end

curDIR = pwd;

[wts awt] = SOM_Weighted_SUM(SOMResults);

[oWTS oI] = sort(awt);

iIMG = 0;

if SOMResults.maskInfo.analyzeFMT == 1
  % Get the header.
  hdr = SOMResults.header;
  % Make the temp volume.
  somMap = zeros(hdr.dim(1:3));
else
  somMap = zeros(SOMResults.maskInfo.size);
end

for ix = size(SOMResults.SOM,2):-1:1
    % Assume all is nan.
    somMap(:,:,:) = nan;
    % Fill with the results.
    ii = find(SOMResults.IDX == oI(ix));
    somMap(SOMResults.iMask(ii)) = SOMResults.WTS(ii);
    % Make a mask of the valid numbers.
    nonNANSomMap = 1-isnan(somMap);
    % Are there values in the mask that are non-nans?
    if sum(sum(sum(maskingVol.*nonNANSomMap))) > 0
        iIMG = iIMG + 1;
        if SOMResults.maskInfo.analyzeFMT == 1
          hdr = SOMResults.header;
          % Make the name the order it was written and which examplar it
          % belongs.
          hdr.fname = fullfile(curDIR,sprintf('som_%s_%03d_%03d.img',name_extra,iIMG,oI(ix)));
          hdr.pinfo = [1;0;0];
          spm_write_vol(hdr,somMap);
        else
          save(fullfile(curDIR,sprintf('som_%s_%03d_%03d',name_extra,iIMG,oI(ix))),'somMap');
        end
    else
      fprintf('Image is empty : %s\n',name_extra);
    end
end

fprintf('Wrote %d images.\n',iIMG);

results = iIMG;

clear SOMResults
clear somMap
clear maskingVol

return

%
% All done.
%

