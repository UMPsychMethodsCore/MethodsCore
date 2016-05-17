function mc_3DMap(in)
% 
% INPUT
% in.RefImage   -       Reference image. Used to get space, bounding box, etc
% in.Mask       -       Mask for building 3D map  (optional)
% in.OutImage   -       Output image file path
% in.Coord      -       Coordinates in image space (typically MNI): nVoxels x 3
% in.Values     -       nVoxel length vector, values to be written out correspond to in.Coord
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Select template file
V    = spm_vol(in.RefImage);
Vnew = V(1);
Vnew =rmfield(Vnew,'descrip');
Vnew =rmfield(Vnew,'pinfo');


% convert coordinates
roiVoxels = inv(Vnew.mat)*[in.Coord ones(size(in.Coord,1),1)]';
roiVoxels = round(roiVoxels(1:3,:))';
lidx      = sub2ind(Vnew.dim,roiVoxels(:,1),roiVoxels(:,2),roiVoxels(:,3));

% write masked data to the new file
Vnew.fname = in.OutImage;
mtx        = zeros(Vnew.dim);
if ~isfield(in,'Values')
    in.Values = ones(size(in.Coord,1),1);
end
mtx(lidx)  = in.Values;

if isfield(in,'Mask')
% Select and read mask file
    Vmask = spm_vol(in.Mask);
    mask  = spm_read_vols(Vmask);
    mtx   = mtx.*mask;
end

spm_write_vol(Vnew,mtx);

end

