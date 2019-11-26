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
global mcLog

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

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %ADJUST DATA FOR CONTRAST
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %need contrast struct from SPM
        %need betas from SPM.Vbeta
        curwd = pwd;
        cd(fileparts(parameters.cppi.SPM));
        load(parameters.cppi.SPM);

        beta = spm_read_vols(SPM.Vbeta);
        rbeta = reshape(beta,prod(size(beta(:,:,:,1))),size(beta,4));
        mrbeta = rbeta(parameters.maskInfo.iMask,:);
        cd(curwd);

        for iROI = 1 : parameters.rois.nroisRequested
            y = D0(parameters.rois.IDX{iROI},:)';
            y = spm_filter(SPM.xX.K,SPM.xX.W*y);
            beta = mrbeta(parameters.rois.IDX{iROI},:)';
            
            y = y - spm_FcUtil('Y0',SPM.xCon(parameters.cppi.adjust),SPM.xX.xKXs,beta);
            
            y(isnan(y)) = 0;
            %loop over runs
            fy = [];
            for iRun = 1:size(SPM.Sess,2)
                xY.X0     = SPM.xX.xKXs.X(:,[SPM.xX.iB SPM.xX.iG]);
                i     = SPM.Sess(iRun).row;
                ty     = y(i,:);
                xY.X0 = xY.X0(i,:);
                try
                    xY.X0 = [xY.X0 SPM.xX.K(iRun).X0];
                end
                try
                    xY.X0 = [xY.X0 SPM.xX.K(iRun).KH]; % Compatibility check
                end

                %-Remove null space of X0
                %--------------------------------------------------------------------------
                xY.X0     = xY.X0(:,any(xY.X0));

                %-Compute regional response in terms of first eigenvariate
                %--------------------------------------------------------------------------
                [m n]   = size(ty);
                if m > n
                    [v s v] = svd(ty'*ty);
                    s       = diag(s);
                    v       = v(:,1);
                    u       = ty*v/sqrt(s(1));
                else
                    [u s u] = svd(ty*ty');
                    s       = diag(s);
                    u       = u(:,1);
                    v       = ty'*u/sqrt(s(1));
                end
                d       = sign(sum(v));
                u       = u*d;
                v       = v*d;
                Y       = u*sqrt(s(1)/n);
                ty = Y;
                fy = [fy;ty];
            end
            fy(isnan(fy)) = 0;
            roiTC(:,iROI) = fy;
          %roiTC(:,iROI) = mean(D0(parameters.rois.IDX{iROI},:),1);
        end
 
        % Now loop on the ROIs and calculate PPI models for each one
        % separately to build up the cPPI grid.
        cppi_grid = [];
        load(parameters.cppi.SPM);
        for iROI = 1:parameters.rois.nroisRequested
            roiTCscaled(:,iROI) = roiTC(:,iROI).*SPM.xGX.gSF;
        end
        cppi_CreateImages(roiTC,parameters);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %attempt to filter out bad timepoints
        pctnonconstant = sum(diff(roiTCscaled)~=0)./(size(roiTCscaled,1)-1);
        badmask = pctnonconstant<.75;
        roiTCscaled(:,badmask) = 0;
        roiTC(:,badmask) = 0;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        logstring = sprintf('%s: %d ROIs total',datestr(now),parameters.rois.nroisRequested);
        mc_Logger('log',logstring,3);
        for iROI = 1:parameters.rois.nroisRequested
           logstring = sprintf('%s: Working on ROI %d',datestr(now),iROI);
           mc_Logger('log',logstring,3);
           %[cppiregressors betanames] =
           %cppi_CreateRegressors_spm(parameters.rois.mni.coordinates(iROI,:),parameters,roiTC(:,iROI));
           %roiTCtemp = roiTC(:,iROI).*SPM.xGX.gSF;
           roiTCscaled(isnan(roiTCscaled)) = 0;
           [cppiregressors betanames] = cppi_CreateRegressors(roiTCscaled(:,iROI),parameters);
           for iB = 1:size(betanames,2)
               cppi_grid{1,iB} = betanames{iB};
           end
           
           try
               model = cppi_CreateModel(cppiregressors,roiTC,parameters);
               [cppi_grid result] = cppi_Extract(cppiregressors,model,parameters,cppi_grid,iROI,roiTC);
           catch err
               model = parameters.cppi.sandbox;
               
               nummotion = size(parameters.data.run(1).MotionParameters,2);
               domotion = parameters.cppi.domotion;
               numrun = size(parameters.data.run,2);
               numregressors = size(cppiregressors,2);
               goodbeta = repmat([ones(1,numregressors) zeros(1,domotion*nummotion)],1,numrun);
               index = 1;
               for iB = 1:size(goodbeta,2)
                   if (goodbeta(iB) == 1)
                       cppi_grid{2,index}(iROI,:) = NaN*zeros(1,size(roiTC,2));
                       cppi_grid{3,index}(iROI,:) = NaN*zeros(1,size(roiTC,2));
                       if (parameters.cppi.StandardizeBetas)
                           cppi_grid{4,index}(iROI,:) = NaN*zeros(1,size(roiTC,2));
                       end
                       index = index + 1;
                   end
               end
               result = 1;
               mc_Logger('log',err.message);
           end
           if (result)
               %[status result] = system(sprintf('rm -rf %s',model));
               [status(1) result] = system(sprintf('rm -rf %s',fullfile(model,'spmT*')));
               [status(2) result] = system(sprintf('rm -rf %s',fullfile(model,'con*')));
               [status(3) result] = system(sprintf('rm -rf %s',fullfile(model,'SPM*')));
               [status(4) result] = system(sprintf('rm -rf %s',fullfile(model,'mask*')));
               [status(5) result] = system(sprintf('rm -rf %s',fullfile(model,'beta*')));
               [status(6) result] = system(sprintf('rm -rf %s',fullfile(model,'ResMS*')));
               [status(7) result] = system(sprintf('rm -rf %s',fullfile(model,'RPV*')));
               if (any(status) ~= 0)
                   mc_Error('There was an error deleting temporary files: %s',result);
               end
           else
               mc_Error('There was an error during cPPI calculation.  Only 0s were returned.');
           end
           
        end
        %now save cppi grid results
        GridFilename = [parameters.Output.name '_cppi_grid'];
        GridPath = mc_GenPath(fullfile(parameters.Output.directory,GridFilename));
        save(GridPath,'cppi_grid','-v7.3');      
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
