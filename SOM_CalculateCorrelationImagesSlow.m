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

function results = SOM_CalculateCorrelationImagesSlow(D0,parameters)

global SOM

%
% Initialize the output matrix.
%

results = [];

rMap    = zeros(size(D0,1),1);
rMapVol = zeros(parameters.maskHdr.dim(1:3));

for iROI = 1 : parameters.rois.nroisRequested
    
    if parameters.rois.ROIOK(iROI)
        roiTC = mean(D0(parameters.rois.IDX{iROI},:),1);
        
        SOM_LOG('STATUS : Entering CorrCoeff Image Calculation');
        
        rMap = 0*rMap;
        pMap = 0*rMap;
        
        for iV = 1:size(D0,1);
            [rMap(iV) pMap(iV)] = corr(D0(iV,:)',roiTC');
        end
        
        % Now turn into maps (r and p) and write out.
        
        rMapVol                            = 0*rMapVol;
        pMapVol                            = ones(size(rMapVol));

        rMapVol(parameters.maskInfo.iMask) = rMap;
        pMapVol(parameters.maskInfo.iMask) = pMap;
        
        clear rMapHdr;
        
        rMapHdr.fname = fullfile(parameters.Output.directory,sprintf('rmap_%s_%03d.nii',parameters.Output.name,iROI));
        rMapHdr.mat   = parameters.maskHdr.mat;
        
        % Make sure we write out float32.....
        
        rMapHdr.dim   = parameters.maskHdr.dim(1:3);
        rMapHdr.dt    = [16 0];
        rMapHdr.descrip = sprintf('%s : %d',parameters.Output.description,iROI);

	% Now the probability map.

        pMapHdr       = rMapHdr;
	pMapHdr.fname = fullfile(parameters.Output.directory,sprintf('pmap_%s_%03d.nii',parameters.Output.name,iROI));

        spm_write_vol(rMapHdr,rMapVol);
        spm_write_vol(pMapHdr,pMapVol);
        
        % now transform the results to a z score.
        
        if exist(rMapHdr.fname) == 2
            Vi = spm_vol(rMapHdr.fname);
            clear Vo
            Vo.fname = sprintf('zmap_%s_%03d.nii',parameters.Output.name,iROI);
            Vo.mat = Vi.mat;
            Vo.dim = Vi.dim;
            Vo.dt  = [16 0];
            Vo.descrip = ['z-score for ' rMapHdr.descrip];
            spm_imcalc(Vi,Vo,'1/2*log((1+i1)./(1-i1))');
        else
            SOM_LOG(sprintf('WARNING : I guess the corr didn''t work for ROI %d',iROI));
        end
    end
    results = strvcat(results,rMapHdr.fname);
end

parameters.stopCPU = cputime;

paraName = fullfile(parameters.Output.directory,[parameters.Output.name '_parameters']);

save(paraName,'parameters','SOM');

results = strvcat(results,paraName);

return

%
% All done.
%