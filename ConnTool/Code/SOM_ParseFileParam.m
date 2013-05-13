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
% In general you should just set the ".File" field and let the code
% determine the rest of the fields.
%
% function type = SOM_ParseFileParam(type)
%
%   type.
%      File         = full directory path and name to file.
%      MaskFLAG     = 0 no masking, 1 = masking.
%      ImgThreshold = 0.75 (default)
%      name         = this name should be either "csf", "grey", "white" 
%                     or "epi". It is only used for error reporting.
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
    SOM_LOG('WARNING : No file information, skipping validation of this mask.');
    type.File         = [];
    type.MaskFLAG     = 0;
    type.ImgThreshold = SOM.defaults.MaskImgThreshold;
    type.name         = 'unknown';
    return
end

% Check that they name of the mask has been passed.

if isfield(type.name,'name') == 0
    type.name = 'unknown';
    SOM_LOG('WARNING : Assuming an "unknown" mask type');
    SOM_LOG(sprintf('WARNING : File name is %s',type.File));
end

if isempty(type.File)
    SOM_LOG(sprintf('WARNING : No file information, skipping validation of this mask of type : %s',type.name));
    type.MaskFLAG     = 0;     % Since the file name is empty, force the flag to be 0.
    return
end

% Is the file name valid?

if exist(type.File,'file') == 0
    type.OK = -1;
    SOM_LOG(sprintf('FATAL Error : Masking file %s specified doesn''t exist, expect for mask of type : %s',type.File,type.name));
    return
end

% Did they pass a flag? If they pass a valid name but did not pass the flag
% then assume that they wanted the flag to be on.

if isfield(type,'MaskFLAG') == 0
    SOM_LOG(sprintf('WARNING : Missing MaskFLAG, setting to 1 (1=use mask) for mask of type : %s',type.name));
    SOM_LOG(sprintf('WARNING : File name is %s',type.File));
    type.MaskFLAG = 1;
end

% Did they pass an image threshold?

if isfield(type,'ImgThreshold') == 0
    SOM_LOG(sprintf('WARNING : Missing ImgThreshold to determine what is inside mask, setting to SOM.defaults.MaskImgThreshold for mask of type : %s',type.name));
    SOM_LOG(sprintf('WARNING : File name is %s',type.File));
    type.ImgThreshold = SOM.defaults.MaskImgThreshold;
end

% Now check to see if numeric.
if isnumeric(type.MaskFLAG) == 0
    SOM_LOG(sprintf('WARNING : MaskFLAG not numeric, setting to 1. for mask of type : %s',type.name));
    SOM_LOG(sprintf('WARNING : File name is %s',type.File));
    type.MaskFLAG = 1;
end

% Force it to be 0 or 1.

if type.MaskFLAG ~= 0
    type.MaskFLAG = 1;
end

% If not numeric force it to be the default.

if isnumeric(type.ImgThreshold) == 0
    SOM_LOG(sprintf('WARNING : ImgThreshold not numeric, setting to SOM.defaults.MaskImgThreshold for mask of type : %s',type.name));
    SOM_LOG(sprintf('WARNING : File name is %s',type.File));
    type.ImgThreshold = SOM.defaults.MaskImgThreshold;
end

return

