function mc_graphtheory_threedmap(template,tempmask,VnewPath,data,roiMNI,varargin)
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
%
% OPTIONAL INPUT
% graph      - graph.expand, 0 is no expansion, 1 is expanding single voxel
%              to cross. Defaults to 0.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if nargin~=6 
    expand = 0;
else   
    expand = varargin{1};
end

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

% Initiate output data
Vnew.fname = VnewPath; 
mtx        = zeros(Vnew.dim);

if ~expand
    % convert 3d coordinates to 1d coordinates
    lidx = sub2ind(Vnew.dim,roiVoxels(:,1),roiVoxels(:,2),roiVoxels(:,3));
    
    % write masked data to the new file       
    mtx(lidx) = data;
    
else    
    % add expansion
    xlim = Vnew.dim(1);
    ylim = Vnew.dim(2);
    zlim = Vnew.dim(3);
    for i = 1:length(data)
        lidx = [];
        idxx = roiVoxels(i,1);
        idxy = roiVoxels(i,2);
        idxz = roiVoxels(i,3);
        lidx = sub2ind(Vnew.dim,idxx,idxy,idxz);
        if (idxx-1)>0
            newlidx = sub2ind(Vnew.dim,idxx-1,idxy,idxz);
            lidx = [lidx newlidx];
        end
        if (idxx+1)<=xlim
            newlidx = sub2ind(Vnew.dim,idxx+1,idxy,idxz);
            lidx = [lidx newlidx];
        end
        if (idxy-1)>0
            newlidx = sub2ind(Vnew.dim,idxx,idxy-1,idxz);
            lidx = [lidx newlidx];
        end
        if (idxy+1)<=ylim
            newlidx = sub2ind(Vnew.dim,idxx,idxy+1,idxz);
            lidx = [lidx newlidx];
        end
        if (idxz-1)>0
            newlidx = sub2ind(Vnew.dim,idxx,idxy,idxz-1);
            lidx = [lidx newlidx];
        end
        if (idxz+1)<=zlim
            newlidx = sub2ind(Vnew.dim,idxx,idxy,idxz+1);
            lidx = [lidx newlidx];
        end
        mtx(lidx) = data(i);
    end
end

% write out results
mtx       = mtx.*mask;
spm_write_vol(Vnew,mtx);

end

