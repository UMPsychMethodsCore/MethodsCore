% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% A routine to loop on the different masks that are potentially
% used in the SOM code and to check them for correctness etc.
%
% function masks = SOM_CheckMasks(parameters)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function masks = SOM_CheckMasks(parameters)

global SOM

% Does 'masks' field exist?

if isfield(parameters,'masks') == 0
  SOM_LOG('WARNING : You have not specified a ".masks" structure. Using defaults, which is all empty');
  masks.epi   = [];
  masks.grey  = [];
  masks.csf   = [];
  masks.white = [];
else
  masks = parameters.masks;
end

% Default is error state

masks.OK = -1;

% Files needed for masking?

if isfield(masks,'grey') == 0
    masks.grey = [];
end

SOM_LOG('STATUS : Checking for grey matter mask.');
masks.grey.name = 'grey';

masks.grey = SOM_ParseFileParam(masks.grey);

if masks.grey.OK == -1
    SOM_LOG('FATAL ERROR : You specified an grey mask that doesn''t exist');
    return
end

% White Matter ROI for regression?

if isfield(masks,'white') == 0
    masks.white = [];
end

SOM_LOG('STATUS : Checking for white matter mask.');
masks.white.name = 'white';
masks.white = SOM_ParseFileParam(masks.white);

if masks.white.OK == -1
    SOM_LOG('FATAL ERROR : You specified an white mask that doesn''t exist');
    return
end

% CSF ROI?

if isfield(masks,'csf') == 0
    masks.csf = [];
end

SOM_LOG('STATUS : Checking for CSF matter mask.');
masks.csf.name = 'csf';
masks.csf = SOM_ParseFileParam(masks.csf);

if masks.csf.OK == -1
    SOM_LOG('FATAL ERROR : You specified an csf mask that doesn''t exist');
    return
end

% If no common epi mask then we will use one create on the fly.

if isfield(masks,'epi') == 0 
    masks.epi = [];
else
    SOM_LOG('STATUS : Checking for EPI matter mask.');
    masks.epi.name = 'epi';
    masks.epi = SOM_ParseFileParam(masks.epi);
    if masks.epi.OK == -1
        SOM_LOG('FATAL ERROR : You specified an epi mask that doesn''t exist');
        return
    end
end

% Okay, we made it this far so all good.

masks.OK = 1;

%
% all done.
%