function resized_img_path = normalize_image_dimensions(reference_image, target_image, output_directory, ismask)
%returns the path to an image that has been linearly interp'd to be the same dimensions as 
%the reference image

%if there is already a resized image in this dir we remove it
if( exist([output_directory '/' 'r' target_image]) )
	delete([output_directory '/' 'r' target_image])
end

ismask=0;

reference_vol = spm_vol(reference_image);
target_vol = spm_vol(target_image);

%Load the pixel dimensions of the target
target_pix_dim = get_pixel_dimensions(target_vol);
reference_pix_dim = get_pixel_dimensions(reference_vol);



reference_bb = get_world_bb(reference_vol);
target_bb = get_world_bb(target_vol);

same_pix_dim = target_pix_dim == reference_pix_dim;
same_pix_dim = all(same_pix_dim(:));

same_bb = reference_bb == target_bb;
same_bb = all(same_bb(:));

same_shape = target_vol.dim == reference_vol.dim;
same_shape = all(same_shape(:));

if( same_pix_dim & same_bb & same_shape)
	resized_img_path = target_image;
	return;
end


%at this point we know that the target and reference are different, so we resize the target 
%with respect to the reference's BB and pixel dimensions

% reslice images one-by-one

% (copy to allow defaulting of NaNs differently for each volume)
voxdim = reference_pix_dim;

mn = reference_bb(1,:);
mx = reference_bb(2,:);


% voxel [1 1 1] of output should map to BB mn
% (the combination of matrices below first maps [1 1 1] to [0 0 0])
mat = spm_matrix([mn 0 0 0 voxdim])*spm_matrix([-1 -1 -1]);
% voxel-coords of BB mx gives number of voxels required
% (round up if more than a tenth of a voxel over)
imgdim = ceil(mat \ [mx 1]' - 0.1)';

if(isempty(ismask))
	ismask = false;
end

V = target_vol;

% output image
VO            = V;
[pth,nam,ext] = fileparts(V.fname);
VO.fname      = fullfile(output_directory,['r' nam ext]);
VO.dim(1:3)   = imgdim(1:3);
VO.mat        = mat;
if(V.mat(1,1)<0)
	VO.mat(1,1) = -VO.mat(1,1);
	VO.mat(1,4) = -VO.mat(1,4);
end

VO = spm_create_vol(VO);

for i = 1:imgdim(3)
	M = inv(spm_matrix([0 0 -i])*inv(VO.mat)*V.mat);
	img = spm_slice_vol(V, M, imgdim(1:2), 1); % (linear interp)
	if ismask
		img = round(img); 
	end
	spm_write_plane(VO, img, i);
	
end



resized_img_path = VO.fname;

function pixel_dimensions = get_pixel_dimensions(image_volume)
%takes in a spm_vol and returns the pixel dimensions

all_dimensions = spm_imatrix(image_volume.mat);
pixel_dimensions = all_dimensions(7:9);
pixel_dimensions = abs(pixel_dimensions);

function bb = get_world_bb(V)
%  world-bb -- get bounding box in world (mm) coordinates

d = V.dim(1:3);
% corners in voxel-space
c = [ 1    1    1    1
    1    1    d(3) 1
    1    d(2) 1    1
    1    d(2) d(3) 1
    d(1) 1    1    1
    d(1) 1    d(3) 1
    d(1) d(2) 1    1
    d(1) d(2) d(3) 1 ]';
% corners in world-space
tc = V.mat(1:3,1:4)*c;

% bounding box (world) min and max
mn = min(tc,[],2)';
mx = max(tc,[],2)';
bb = [mn; mx];