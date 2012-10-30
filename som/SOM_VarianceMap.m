% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2005
%
%
% A program to calculate the variance map of the 
% time series date. 
%
% function [results] = SOM_VarianceMap(theData,maskInfo)
%
% theData   -  space x time array of fcMRI data
% maskInfo  -  structure used for the mask. See SOM_PrepData
%
% A Variance Map will be written in the source directory with 
% the name of "variance.img"
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


function [results, varHdr] = SOM_VarianceMap(theData,maskInfo)

% Calculate the variance

% Modified on 2007-3-29 to speed up the code and reduce memory
% load. R.C. Welsh

varMap = var(theData,[],2);

% Create a dummy volume of correct dimensions.

varVol = zeros(maskInfo.header.dim(1:3));

% Fill the values.

varVol(maskInfo.iMask) = varMap;

if maskInfo.analyzeFMT == 1
  % Create a new header.
  
  varHdr = maskInfo.header;
  
  [pn pf] = fileparts(varHdr.fname);
  
  varHdr.fname = fullfile(pn,'variance.img');
  
  % Write the analyze image.
  
  spm_write_vol(varHdr,varVol);
else
  save(fullfile(maskInfo.fPath,'varMap')','varMap');
end

results = varMap;

return

%
% All done
% 