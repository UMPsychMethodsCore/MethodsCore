% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2013
%
% Ann Arbor, MI
%
% Set the version of the parameters is compatible with this 
% version.
%
% function parameters = SOM_CheckParamVersion(parameters)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function parameters = SOM_SetParamVersion(inParameters)

global SOM

parameters = inParameters;

parameters.version = SOM.defaults.version;

SOM_LOG(sprintf('STATUS : Setting version of the parameters to be %f',parameters.version));

return
