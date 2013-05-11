% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% Calculate correlation matrix.
% 
% 2013-02-06
%
%   Added ability to calculate the partial correlation.
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
pMatrix  =  ones(parameters.rois.nroisRequested,parameters.rois.nroisRequested);

% Array of ROI time courses.

roiTC = zeros(size(D0,2),parameters.rois.nroisRequested);

% Create an array of our data that is Time x ROI#

for iROI = 1 : parameters.rois.nroisRequested
  roiTC(:,iROI) = mean(D0(parameters.rois.IDX{iROI},:),1);
end

% Corr wants data as NxP1 and NxP2 and returns the correlation
% matrix of P1 x P2.

% N is time and P is voxel

% 2013-02-06 Change the call to just be a single parameter of the data array
% And put in hook for partial correlation versus full correlation.

if strcmp(parameters.Output.correlationType,'full');
  % Full correlation
  [rMatrix pMatrix] = corr(roiTC);
  nameOption = '_corr';
else
  % Partial correlation
  [rMatrix pMatrix] = partialcorr(roiTC);
  nameOption = '_paritalcorr';
end

% It is quite possible that some of the ROI's are messed up? That
% is they don't really exist, even though specified. We can easily 
% known those out.

for iROI = 1 : parameters.rois.nroisRequested
  if parameters.rois.ROIOK(iROI) == 0
    rMatrix(iROI,:) = 0;
    pMatrix(iROI,:) = 1;
    rMatrix(:,iROI) = 0;
    pMatrix(:,iROI) = 1;
    if parameters.Output.saveroiTC ~= 0
      roiTC(:,iROI) = 0; % also zero out the time course if the rMat is censored
    end
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

corrName = fullfile(parameters.Output.directory,[parameters.Output.name nameOption]);

%
% Now recalculate the p-values based on fewer degrees of freedom.
%

if parameters.Output.power
  save(corrName,'rMatrix','pMatrix','power');
else
  save(corrName,'rMatrix','pMatrix');
end

results = corrName;

if parameters.Output.saveroiTC ~= 0
  roiTCName = fullfile(parameters.Output.directory,[parameters.Output.name '_roiTC']);
  save(roiTCName,'roiTC');
  results=strvcat(results,roiTCName);
end



return

%
% All done.
%
