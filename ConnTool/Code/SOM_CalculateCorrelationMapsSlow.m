% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% Calculate correlation matrix.
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
% function results = SOM_CalculateCorrelationMaps(D0,parameters)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_CalculateCorrelationMapsSlow(D0,parameters)

global SOM

%
% Initialize the output matrix.
%

SOM_LOG('STATUS : Entering CorrCoeff Map Calculation');

rMatrix  = zeros(parameters.rois.nroisRequested,parameters.rois.nroisRequested);
pMatrix  = ones(parameters.rois.nroisRequested,parameters.rois.nroisRequested);

for iROI = 1 : parameters.rois.nroisRequested - 1
    if parameters.rois.ROIOK(iROI)
        for jROI = iROI+1 : parameters.rois.nroisRequested
            if parameters.rois.ROIOK(jROI)
                tc1 = mean(D0(parameters.rois.IDX{iROI},:),1)';
                tc2 = mean(D0(parameters.rois.IDX{jROI},:),1)';
                [rMatrix(iROI,jROI) pMatrix(iROI,jROI)] = corr(tc1,tc2);
            else
                rMatrix(iROI,jROI) = -3;  % Error
            end
        end
    else
        rMatrix(iROI,:) = -2;             % Error
    end
end

%
% Now save the matrix and parameters.
%

corrName = fullfile(parameters.Output.directory,[parameters.Output.name '_corr']);
paraName = fullfile(parameters.Output.directory,[parameters.Output.name '_parameters']);

parameters.stopCPU = cputime;

save(corrName,'rMatrix','pMatrix');
save(paraName,'parameters','SOM');

results = strvcat(corrName,paraName);

return

%
% All done.
%