% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2005-2007
%
% Routine to write time-series data.
%
% function [results] = SOM_WriteData(theData,maskInfo,volumeWild)
%
% Write out the data from the Space x Time array using the
% volume information contained in maskInfo and the name prefix 
% from volumeWild
% 
% theData   = theData(nSpace,nTime);
%
% maskInfo.iMask = indices back into 3-D array.
%
% further maskInfo can be 1 of two types
% 
%   SPM style information
%
%       maskInfo 
%           .analyzeFMT == 1
%           .header  - spm style header
%
%   Plain ".mat" style
%
%           .analyzeFMT  = 0 (or not 1)
%           .dim         = [x y z] voxels
%           .path        = path where data should go.
%           .output      = 3 - for 3d files, 4 - for 4d file.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_WriteData(theData,maskInfo,volumeWild);

fprintf('Writing Data\n\n');

if maskInfo.analyzeFMT == 1
  genHdr = maskInfo.header;
  [genDir genNam] = fileparts(genHdr.fname);
  vDIM = maskInfo.header.dim;
  maskInfo.output = 3;
else
  genDir = maskInfo.path;
  vDIM = maskInfo.dim;
  if isfield(maskInfo,'output') == 0
    fprintf('Going to write time-series as 3D mats.\n');
    maskInfo.output = 3;
  end  
end

% Write out a 3D or 4D file.

if maskInfo.output == 3
  Volume = zeros(vDIM);
  for iP = 1:size(theData,2);
    Volume = 0*Volume;
    Volume(maskInfo.iMask) = theData(:,iP);
    if maskInfo.analyzeFMT == 1
      volHdr = genHdr;
      volHdr.fname = fullfile(genDir,sprintf('%s%04d.img',volumeWild,iP));
      volHdr.pinfo = [1;0;0];  
      spm_write_vol(volHdr,Volume);
    else
      save(fullfile(genDir,sprintf('%s%04d',volumeWild,iP)),'Volume');
    end
  end
else
  Volume = zeros(prod(vDIM),size(theData,2));
  Volume(maskInfo.iMask,:) = theData;
  Volume = reshape(Volume,[vDIM size(theData,2)]);
  save(fullfile(genDir,sprintf('%s_4D',volumeWild)),'Volume');
end

fprintf('\nDone\n');
clear Volume;
clear theData;

return

%
% All done.
%