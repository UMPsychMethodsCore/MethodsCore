% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
%
% A process to calculate correlations in time-series data.
% 
% It is assumed that the data being passed in has be pre-processed using
% SOM_PreProcessData. 
%
% You have multiple options for specifying what to do with the correlations
% 
% 1) If you pass a single ROI (either as a MNI coordinate or a ROI
% file) then it will produce a correlation map image and the
% Fisher-transform r-z Z image.
%
% 2) If you pass multiple ROI (either as MNI coordinates or ROI files) then
% it will produce either multiple output images in the results directory or
% a correlation map between the ROIs.
%
% INPUT
%
%   D0         -- data table from SOM_PreProcessData
%
%   parameters -- see SOM_PreProcesData
% 
%      .rois
%          [ specify one or the other: "mni" or "files"]
%         .mni
%              .coordinates   - table of n coordinates (x,y,z)
%              .size          - which size, 1, 7, 19, 27 voxels
%                  .XROI      - optional array of user specficied size.
%                  .YROI        see below on how to build it.
%                  .ZROI       
%         .files              - table of ROI files
%
%         .mask
%               .File         - full directory path and name to file.
%               .MaskFLAG     - 0 no mask, 1 mask
%
%      
%      .Output   
%               .correlation  - 'maps'    - save a single correlation matrix
%                               'images'  - save a single correlation image
%                                           per ROI
%
%               .directory    - full directory path to output
%               .name         - name of output file (generic)
%         
%
% OUTPUT
%
%     results = -1 error
%                array of output written.
%
%
% function results = SOM_CalculateCorrelations(D0,parameters)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


function results = SOM_CalculateCorrelations(D0,parameters)

global SOM

results = -1;

% Which output types require an ROI as input.

outputTypesRequireROI = [0 1];

% Track the time we spend here.

parameters.startCPU.corr = cputime;

%
% Check the output information, this is first because variance maps do not require ROIs.
%

parameters.Output = SOM_CheckOutput(parameters);

if parameters.Output.OK == -1
    SOM_LOG('FATAL ERROR : parameters.Output failed to meet criteria');
    return
end

%
% Check the roi parameters, only if needed.
%

if ismember(parameters.Output.type,outputTypesRequireROI)
  parameters.rois = SOM_CheckROIParameters(parameters);
  
  if parameters.rois.OK == -1
    SOM_LOG('FATAL ERROR : parameters.rois failed to meet criteria');
    return
  end  
  %
  % Sanity check, if Output.type = 0, which is a correlation map, then you
  % need at least 2 ROIs that survived any cleaning up.
  %  
  if parameters.Output.type == 0 & parameters.rois.nrois < 2
    SOM_LOG('FATAL ERROR : You specified output to be a correlation matrix, but insufficient number of ROIS');
    return
  end
  % Take the ROI definitions and turn them into linear indices for
  % calculations.
  parameters.rois = SOM_BuildROILinearIDX(parameters);
end

%
% Okay - we can do the work now.
%


% Now do the correlation work, either making (corr or partialcorr) maps or (corr or variance) images.

switch parameters.Output.type
    
    case 0
        %
        % Correlation maps.
        %
        SOM_LOG('STATUS : Calling SOM_CalculateCorrelationMaps');
        results = SOM_CalculateCorrelationMaps(D0,parameters);
        
    case 1
        %
        % Correlation images and Z-images
        %
        SOM_LOG('STATUS : Calling SOM_CalculateCorrelationImages');
        results = SOM_CalculateCorrelationImages(D0,parameters);
        
    case 2
        %
        % Variance image.
        %
        SOM_LOG('STATUS : Calling SOM_CalculateVarianceImage');
        results = SOM_CalculateVarianceImage(D0,parameters);
        
    case 3
        %
        % fALFF image.
        %
        SOM_LOG('STATUS : Calling SOM_CalculatefALFF');
        results = SOM_CalculatefALFF(D0,parameters);
        
    case 4
        %
        % ALFF image.
        %
        SOM_LOG('STATUS : Calling SOM_CalculateALFF');
        results = SOM_CalculateALFF(D0,parameters);
        
    otherwise
        %
        % Error case, go ahead and save the parameter file, maybe will help with debug.
        %
        SOM_LOG('FATAL ERROR : Somehow we are not doing correlation map or image output');
	paraName = fullfile(parameters.Output.directory,[parameters.Output.name '_FATALERROR_parameters']);
	results  = strvcat(results,paraName);
	return
end

parameters.stopCPU.corr = cputime;

% Now write out the parameters to a file.

paraName = fullfile(parameters.Output.directory,[parameters.Output.name '_parameters']);
results  = strvcat(results,paraName);

save(paraName,'parameters','SOM');

return

%
% All done.
%
