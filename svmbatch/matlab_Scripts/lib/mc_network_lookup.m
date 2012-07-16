function [ labeled_voxels ] = mc_network_lookup( mapFile, mmlist )
%mc_network_lookup  A function that, given a list of MNI coords, will
%retrieve the value at corresponding voxel from an image
%   Input Args
%       mapFile     -   A path to a hdr file that will be used for network
%                       lookup
%       mmlist      -   A nROI*3 matrix of MNI coords
%   Output Args
%       labeled_voxels  -   An nROI*4 matrix, same as input, but with
%                           looked up values tacked on in 4th column

labeled_voxels = zeros(size(mmlist,1),4);
labeled_voxels(:,1:3) = mmlist;

hdr=spm_vol(mapFile);
map=spm_read_vols(hdr);

v2m=spm_get_space(hdr.fname);
m2v=inv(v2m);



for i=1:size(mmlist,1)
    temp = m2v*[mmlist(i,:) 1]';
    ind(1:3) = temp(1:3)';
    xind=ind(1);
    yind=ind(2);
    zind=ind(3);
    
    labeled_voxels(i,4)=map(xind,yind,zind);
end