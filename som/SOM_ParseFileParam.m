% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% Validate the time parameters
% pass for SOM_PreProcessData
%
%
% function type = SOM_ParseFileParam(type)
%
%   type.
%      File         = full directory path and name to file.
%      MaskFLAG     = 0 no masking, 1 = masking.
%      ImgThreshold = 0.75 (default)
%
%
%   return 0 if no parameters passed
%         -1 if File passed but doesn't exist.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function type = SOM_ParseFileParam(type);

% Need access to standard masking value.

global SOM

% Did they pass the file name?

type.OK = 1;

if isfield(type,'File') == 0
    SOM_LOG('WARNING : No file information, skipping.');
    type.File = [];
    type.MaskFLAG = 0;
    type.ImgThreshold = SOM.defaults.MaskImgThreshold;
    return
end

if isempty(type.File)
    SOM_LOG('WARNING : No file information, skipping.');
    return
end

% Is the file name valid?

if exist(type.File,'file') == 0
    type.OK = -1;
    SOM_LOG('FATAL Error : Masking file specified doesn''t exist');
    return
end

% Did they pass a flag? If they pass a valid name but did not pass the flag
% then assume that they wanted the flag to be on.

if isfield(type,'MaskFLAG') == 0
    SOM_LOG('WARNING : Missing MaskFLAG, setting to 1.');
    type.MaskFLAG = 1;
end

% Did they pass an image threshold?

if isfield(type,'ImgThreshold') == 0
    SOM_LOG('WARNING : Missing ImgThreshold, setting to SOM.defaults.MaskImgThreshold');
    type.ImgThreshold = SOM.defaults.MaskImgThreshold;
end

% Now check to see if numeric.
if isnumeric(type.MaskFLAG) == 0
    SOM_LOG('WARNING : MaskFLAG not numeric, setting to 1.');
    type.MaskFLAG = 1;
end

% Force it to be 0 or 1.

if type.MaskFLAG ~= 0
    type.MaskFLAG = 1;
end

% If not numeric force it to be the default.

if isnumeric(type.ImgThreshold) == 0
    SOM_LOG('WARNING : ImgThreshold not numeric, setting to SOM.defaults.MaskImgThreshold');
    type.ImgThreshold = SOM.defaults.MaskImgThreshold;
end

return

