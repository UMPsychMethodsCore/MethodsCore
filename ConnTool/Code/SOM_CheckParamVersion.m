% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2013
%
% Ann Arbor, MI
%
% Check the version of the parameters is compatible with this 
% version.
%
% function parameters = SOM_CheckParamVersion(parameters)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function parameters = SOM_CheckParamVersion(inParameters)

parameters = inParameters;

validVersions = [3];

OK = false;

if isfield(inParameters,'version') 
    if ~isempty(find(floor(inParameters.version),validVersions))
        OK = true;
    end
end

parameters.OK = OK;

return
