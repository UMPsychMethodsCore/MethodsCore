function mc_graphtheory_threedmap(template,tempmask,VnewPath,data,roiMNI)
% MC_GRAPHTHEORY_THREEDMAP 
% Reconstruct 3d nii image with node-wise data.
% 
% INPUT
% template   - Template for building 3D map. Usually use one of the preprocessed functional
%              image.
% tempmask   - Mask for building 3D map 
% VnewPath   - The new nii file path
% data       - nVoxel x 1 (or 1 x nVoxel) vector, the data that being written in
%              the new nii file.
% roiMNI     - mni coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Select template file
V    = spm_vol(template);
Vnew = V(1);
Vnew=rmfield(Vnew,'descrip');
Vnew=rmfield(Vnew,'pinfo');

% Select and read mask file
Vmask = spm_vol(tempmask);
mask  = spm_read_vols(Vmask);

% convert coordinates
roiVoxels = inv(Vnew.mat)*[roiMNI ones(size(roiMNI,1),1)]';
roiVoxels = round(roiVoxels(1:3,:))';
lidx = sub2ind(Vnew.dim,roiVoxels(:,1),roiVoxels(:,2),roiVoxels(:,3));

% write masked data to the new file
Vnew.fname = VnewPath;
mtx       = zeros(Vnew.dim);
mtx(lidx) = data;
mtx       = mtx.*mask;
spm_write_vol(Vnew,mtx);

end

