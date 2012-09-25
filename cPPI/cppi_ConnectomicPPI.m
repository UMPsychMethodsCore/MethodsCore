function results = cppi_ConnectomicPPI(D0,parameters)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%
%%%
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initial setup and check code borrow from Robert's
% SOM_CalculateCorrelations.m code

global SOM;

results = -1;

parameters.startCPU.cppi = cputime;

%
% Check the roi parameters
%

parameters.rois = SOM_CheckROIParameters(parameters);

if parameters.rois.OK == -1
    SOM_LOG('FATAL ERROR : parameters.rois failed to meet criteria');
    return
end
    
%
% Check the output information
%

parameters.Output = SOM_CheckOutput(parameters);

if parameters.Output.OK == -1
    SOM_LOG('FATAL ERROR : parameters.Output failed to meet criteria');
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

%
% Okay - we can do the work now.
%

% Take the ROI definitions and turn them into linear indices for
% calculations.

parameters.rois = SOM_BuildROILinearIDX(parameters);

% Now do the correlation work, either making maps or images.

switch parameters.Output.type
    
    case 0
        %
        % Correlation maps.
        %
        SOM_LOG('STATUS : Calculating Connectomic PPI');
        % Array of ROI time courses.

        roiTC = zeros(size(D0,2),parameters.rois.nroisRequested);

        % Create an array of our data that is Time x ROI#

        for iROI = 1 : parameters.rois.nroisRequested
          roiTC(:,iROI) = mean(D0(parameters.rois.IDX{iROI},:),1);
        end
 
        % Now loop on the ROIs and calculate PPI models for each one
        % separately to build up the cPPI grid.
        cppi_grid = [];
        load(parameters.cppi.SPM);
        for iROI = 1:parameters.rois.nroisRequested
            roiTCscaled(:,iROI) = roiTC(:,iROI).*SPM.xGX.gSF;
        end
        for iROI = 1:parameters.rois.nroisRequested
           %[cppiregressors betanames] =
           %cppi_CreateRegressors_spm(parameters.rois.mni.coordinates(iROI,:),parameters,roiTC(:,iROI));
           %roiTCtemp = roiTC(:,iROI).*SPM.xGX.gSF;
           [cppiregressors betanames] = cppi_CreateRegressors(roiTCscaled(:,iROI),parameters);
           for iB = 1:size(betanames,2)
               cppi_grid{1,iB} = betanames{iB};
           end
           
           model = cppi_CreateModel(cppiregressors,roiTC,parameters);

           [cppi_grid result] = cppi_Extract(cppiregressors,model,parameters,cppi_grid,iROI);
           
           if (result)
               [status result] = system(sprintf('rm -rf %s',model));
               if (status ~= 0)
                   mc_Error('There was an error deleting temporary files: %s',result);
               end
           else
               mc_Error('There was an error during cPPI calculation.  Only 0s were returned.');
           end
           
        end
        %now save cppi grid results
        GridFilename = [parameters.Output.name '_cppi_grid'];
        GridPath = mc_GenPath(fullfile(parameters.Output.directory,GridFilename));
        save(GridPath,'cppi_grid');      
    otherwise
        %
        % Error case
        %
        SOM_LOG('FATAL ERROR : parameters.Output.type was not 0');
	return
end

parameters.stopCPU.cppi = cputime;

% Now write out the parameters to a file.

paraName = fullfile(parameters.Output.directory,[parameters.Output.name '_parameters']);

save(paraName,'parameters','SOM');

results = 'ok';
return;
