% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2013
%
% Ann Arbor, MI
%
% Calculate variance images.
%
% Based off discussion with Randy McIntosh -- still need to find the 
% proper reference in which they use this method.

% INPUT
%
%   D0         -- see SOM_PreProcessData
%   parameters -- see SOM_PreProcessData and SOM_CalculateCorrelations
%
% OUTPUT
%
%     results = -1 error
%                array of output written.
%
%
% function results = SOM_CalculateVarianceImage(D0,parameters)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_CalculateVarianceImage(D0,parameters)

global SOM

%
% Initialize the output matrix.
%

results = [];

vMap    = zeros(size(D0,1),1);
vMapVol = zeros(parameters.maskHdr.dim(1:3)); %this fails if user specified no masking %% This should now be fixed with change in SOM_PreProcessData - 2012-03-29 - RCWelsh

% Calculate the variance along the first dimension.
% and load back up in the volume.
vMapVol(parameters.maskInfo.iMask) = var(D0,0,1);

% Clear any header (shouldn't exist)
clear vMapHdr;

% Build the header
vMapHdr.fname   = fullfile(parameters.Output.directory,sprintf('vmap_%s.nii',parameters.Output.name));
vMapHdr.mat     = parameters.maskHdr.mat;

% Make sure we write out float32.....
vMapHdr.dim     = parameters.maskHdr.dim(1:3);
vMapHdr.dt      = [16 0];
vMapHdr.descrip = parameters.Output.description;

% Write the volume.
spm_write_vol(vMapHdr,vMapVol);

% Report back the name.
results         = strvcat(results,vMapHdr.fname);

return

%
% All done.
%