% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% Build array of linear indices.
% 
% This routine should only be called from SOM_CalculateCorrelations
%
%
% INPUT
%
%   parameters -- see SOM_PreProcessData and SOM_CalculateCorrelations
%
% OUTPUT
%
%   rois       -- with full linear indices.
%
% function rois = SOM_BuildROILinearIDX(parameters)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function rois = SOM_BuildROILinearIDX(parameters)

%
% Read in the mask of the brain
%

rois = parameters.rois;

MVol = spm_read_vols(parameters.maskInfo.header);

% Rebinerize it.

MVol = MVol > 0;

%
% Load the ROI voxel indices for the calculation.
%

rois.IDX = {};

for iROI = 1:rois.nroisRequested
    
    if rois.ROIOK(iROI)
        
        switch rois.type
            
            %
            % this case is mni coordinates
            %
            
            case 0
                
                
                % Get the MNI coordinates of the middle of this ROI.
                
                ROICoordsMM = rois.mni.coordinates(iROI,:);
                
                % Convert to voxel indices.
                ROICoordsVoxel = round((inv(parameters.maskHdr.mat)*([ROICoordsMM 1]')));
                
                % Build the actual ROI into an array of indices
                VOXELIDX = [
                    rois.mni.size.XROI+ROICoordsVoxel(1)
                    rois.mni.size.YROI+ROICoordsVoxel(2)
                    rois.mni.size.ZROI+ROICoordsVoxel(3)] ;
                
                % Convert back to MNI
                VOXELMM = parameters.maskHdr.mat*([VOXELIDX;ones(1,size(VOXELIDX,2))]);
                
                % Now check the ones that are inside the mask, we have to do
                % this in the event that the ROI has expanded past the center
                % to be outside of the image.
                
                THISROI_inIDX = round(SOM_roiPointsInMask(parameters.maskInfo.header.fname,(VOXELMM(1:3,:))'));
                
                % Convert to linear indices
                rois.IDX{iROI} = sub2ind(parameters.maskHdr.dim(1:3),VOXELIDX(1,THISROI_inIDX),VOXELIDX(2,THISROI_inIDX),VOXELIDX(3,THISROI_inIDX));
                
                % Recount how many voxels survived the masking in this ROI.
                rois.nvoxels(iROI) = length(rois.IDX{iROI});
            case 1
                
                % Read in the image and "AND" it with the ROI
                ROIVOL = spm_read_vols(rois.hdr(iROI));
                ROIVOL = ROIVOL.*MVol;
                
                % Determine linear indices
                rois.IDX{iROI} = find(ROIVOL);
                
                % Recount how many voxels survived the masking in this ROI.
                rois.nvoxels(iROI) = length(rois.IDX{iROI});
                
        end
        
        %
        % Now find out where these exist in the data stream
        %
        
        rois.IDX{iROI} = SOM_ROIIDXnMASK(parameters,rois.IDX{iROI});
        
        % Redetermine if this ROI really survived masking etc.
        rois.ROIOK(iROI) = (length(rois.IDX{iROI}) > 0);
    end
end

return

%
% All done
%
