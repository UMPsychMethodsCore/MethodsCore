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

OK = -1;

if isfield(inParameters,'version') 
    if ~isempty(find(inParameters.version,validVersions))
        OK = 1;
    end
end

parameters.OK = OK;

return
