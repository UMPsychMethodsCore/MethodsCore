% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% Calculate correlation images.
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
% function results = SOM_CalculateCorrelationImages(D0,parameters)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_CalculateCorrelationImages(D0,parameters)

global SOM

%
% Figure out if stats toolbox present.
%

MatlabVer = ver;

SOM.StatsToolBox = any(strcmp('Statistics Toolbox',{MatlabVer.Name}));

if SOM.StatsToolBox
  SOM_LOG('INFO : Statistics Toolbox Ppresent');
else
  SOM_LOG('INFO : Statistics Toolbox NOT present, this will take longer.');
end

%
% Initialize the output matrix.
%

results = [];

rMap    = zeros(size(D0,1),1);
rMapVol = zeros(parameters.maskHdr.dim(1:3)); %this fails if user specified no masking %% This should now be fixed with change in SOM_PreProcessData - 2012-03-29 - RCWelsh

for iROI = 1 : parameters.rois.nroisRequested
    
    if parameters.rois.ROIOK(iROI)
        roiTC = mean(D0(parameters.rois.IDX{iROI},:),1);
        
        SOM_LOG('STATUS : Entering CorrCoeff Image Calculation');
        
        rMap = 0*rMap;
        pMap = 0*rMap;
        
	if SOM.StatsToolBox
	  % Much faster!
	  [rMap pMap] = corr(D0',roiTC');
	else
	  % 
	  % Have to use corrcoef which is slower
	  %
	  for iV = 1:size(D0,1);
	    [rTmp pTmp]         = corrcoef(D0(iV,:)',roiTC');
	    rMap(iV)            = rTmp(1,2);
	    pMap(iV)            = pTmp(1,2);
	  end
        end
	
	% Now turn into maps (r and p) and write out.
        
        rMapVol                            = 0*rMapVol;
        pMapVol                            = ones(size(rMapVol));

        rMapVol(parameters.maskInfo.iMask) = rMap;
        pMapVol(parameters.maskInfo.iMask) = pMap;
        
        clear rMapHdr;
        
        rMapHdr.fname = fullfile(parameters.Output.directory,sprintf('rmap_%s_%04d.nii',parameters.Output.name,iROI));
        rMapHdr.mat   = parameters.maskHdr.mat;
        
        % Make sure we write out float32.....
        
        rMapHdr.dim     = parameters.maskHdr.dim(1:3);
        rMapHdr.dt      = [16 0];
        rMapHdr.descrip = sprintf('%s : %d',parameters.Output.description,iROI);

	% Now the probability map.

        pMapHdr       = rMapHdr;
	pMapHdr.fname = fullfile(parameters.Output.directory,sprintf('pmap_%s_%04d.nii',parameters.Output.name,iROI));

        spm_write_vol(rMapHdr,rMapVol);
        spm_write_vol(pMapHdr,pMapVol);
        
        % now transform the results to a z score.
        
        if exist(rMapHdr.fname) == 2
            clear Vo
            Vi         = spm_vol(rMapHdr.fname);
            Vo.fname   = fullfile(parameters.Output.directory,sprintf('zmap_%s_%04d.nii',parameters.Output.name,iROI));
            Vo.mat     = Vi.mat;
            Vo.dim     = Vi.dim;
            Vo.dt      = [16 0];
            Vo.descrip = ['z-score for ' rMapHdr.descrip];
            spm_imcalc(Vi,Vo,'1/2*log((1+i1)./(1-i1))');
        else
            SOM_LOG(sprintf('WARNING : I guess the corr didn''t work for ROI %d',iROI));
        end
    end
    results = strvcat(results,rMapHdr.fname);
end

return

%
% All done.
%