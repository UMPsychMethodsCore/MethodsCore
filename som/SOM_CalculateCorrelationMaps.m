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

function results = SOM_CalculateCorrelationMaps(D0,parameters)

global SOM

%
% Initialize the output matrix.
%

SOM_LOG('STATUS : Entering CorrCoeff Map Calculation');

rMatrix  = zeros(parameters.rois.nroisRequested,parameters.rois.nroisRequested);
pMatrix  = ones(parameters.rois.nroisRequested,parameters.rois.nroisRequested);

% Array of ROI time courses.

roiTC = zeros(size(D0,2),parameters.rois.nroisRequested);

% Create an array of our data that is Time x ROI#

for iROI = 1 : parameters.rois.nroisRequested
  roiTC(:,iROI) = mean(D0(parameters.rois.IDX{iROI},:),1);
end

% Corr wants data as NxP1 and NxP2 and returns the correlation
% matrix of P1 x P2.

[rMatrix pMatrix] = corr(roiTC,roiTC);

% It is quite possible that some of the ROI's are messed up? That
% is they don't really exist, even though specified. We can easily 
% known those out.

for iROI = 1 : parameters.rois.nroisRequested
  if parameters.rois.ROIOK(iROI) == 0
    rMatrix(iROI,:) = 0;
    pMatrix(iROI,:) = 1;
    rMatrix(:,iROI) = 0;
    pMatrix(:,iROI) = 1;
  end
end

% 
% Did they ask for power spectrum of each ROI?
%

% We make the assumption about only a single run! 

if parameters.Output.power
  [power.spectrum power.parameters] = SOM_PowerSpect(roiTC',parameters.TIME.run(1).TR);
end

%
% Now save the matrix and parameters.
%

corrName = fullfile(parameters.Output.directory,[parameters.Output.name '_corr']);

%
% Now recalculate the p-values based on fewer degrees of freedom.
%

if parameters.Output.power
  save(corrName,'rMatrix','pMatrix','power');
else
  save(corrName,'rMatrix','pMatrix');
end


results = corrName;

return

%
% All done.
%