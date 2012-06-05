function [ labeled_voxels ] = mc_network_lookup( mapFile, mmlist )
%UNTITLED1 Summary of this function goes here
%   Detailed explanation goes here

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