% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2012
%
% Ann Arbor, MI
%
% Code to take a 2D data array (space by time) that is read by SOM_PrepData
% and reconstitute the data into a 4D array based on the 
% masking image.
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function D04D = SOM_PrepNII(D0,parameters);

% Default is to return error.

D04D = -1;

if exist('parameters') == 0
  SOM_LOG('ERROR : You need to specficy the "parameters" variable');
  return
end

if isfield(parameters,'maskInfo') == 0
  SOM_LOG('ERROR : "maskInfo" field missing from "parameters"');
  return
end

if isfield(parameters.maskInfo,'iMask') == 0
  SOM_LOG('ERROR : "iMask" field missing from "parameters.maskInfo"');
  return
end

if isfield(parameters.maskInfo,'size') == 0
  SOM_LOG('ERROR : "size" field missing from "parameters.maskInfo"');
  return
end

if size(D0,1) ~= length(parameters.maskInfo.iMask)
  SOM_LOG(sprintf('ERROR : Number of space points in D0 (%d) do not match those in parameters.maskInfo.iMask (%d)',size(D0,1),length(parameters.maskInfo.iMask)));
  return
end

% Now build the array.

D04D   = zeros([parameters.maskInfo.size size(D0,2)]);
tmpVol = zeros(parameters.maskInfo.size);

for iTime = 1:size(D0,2)
    tmpVol(parameters.maskInfo.iMask) = D0(:,iTime);
    D04D(:,:,:,iTime) = tmpVol;
end

clear tmpVol

return

%
% all done
%
