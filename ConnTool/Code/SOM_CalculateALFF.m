% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2013
%
% Ann Arbor, MI
%
% Calculate fALFF images.
%

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
% function results = SOM_CalculateALFF(D0,parameters)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_CalculateALFF(D0,parameters)

global SOM

%
% Initialize the output matrix.
%

results = [];

ALFF    = SOM_ALFF(D0,parameters.TIME.run(1).TR,parameters.TIME.run(1).FreqBand1);

D03D    = SOM_PrepNII(ALFF,parameters);

results = SOM_WriteNII(parameters.data.run(1).P,fullfile(parameters.Output.directory,sprintf('ALFF_%s.nii',parameters.Output.name)),D03D,'float32');

return

%
% All done.
%