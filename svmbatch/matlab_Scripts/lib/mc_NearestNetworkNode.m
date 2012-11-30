function [ labels ] = mc_NearestNetworkNode(voxlist, radius)
%MC_NEARESTNETWORKNODE A function to map unlabeled network nodes to
%network of their nearest neighbor
%
%       Input Args      
%               voxlist -       nROI*3 matrix of coordinates in MNI
%                               space 
%               radius  -       Radius of sphere to search in MNI distance
%       Output Args
%       
%               labels  -       1*nRoi list of values taken from
%                               nearest neighbor
% NOTES
%       Currently hardcoded to use the YeoNetwork Map

%% Get the space
refimage='/net/data4/MAS/ROIS/Yeo/YeoPlus.hdr';
    
v2m=spm_get_space(refimage);
m2v=inv(v2m);

VoxSize=spm_imatrix(v2m);
VoxSize=VoxSize(7:9);
VoxSize=abs(VoxSize);

minSize=min(VoxSize);

%% Convert radius to voxels in smallest direction

VoxRad=ceil(radius/minSize);

offset=buildsphere(VoxRad);

%% Loop over stuff
for iNode = 1:size(voxlist,1)
    labels(iNode) = spherecheck(voxlist(iNode,:),offset,v2m,m2v,refimage);
end


function network_win=spherecheck(mni_anchor,offset,v2m,m2v,refimage)
% This function does the heavy lifting. Given an anchor point in mni and offset, it finds the winning network
vox_anchor = mni2vox(mni_anchor,m2v);
sphere_vox = offset + repmat(vox_anchor,size(offset,1),1);
sphere_vox = prune_vox(sphere_vox,refimage); % Prune to only include voxels that are in the bounding box
if size(sphere_vox,1) == 0
    network_win=0;
    return
end
sphere_mni = vox2mni(sphere_vox,v2m);
distances = calc_mni_dist_mni(sphere_mni,mni_anchor);
networks = mc_network_lookup(refimage,sphere_mni);
networks = networks(:,4);
if nnz(networks) == 0
    network_win=0;
    return
end
nnz_networks = networks(find(networks),:);
nnz_sphere_mni = sphere_mni(find(networks),:);
nnz_distances = distances(find(networks),:);
[mindist, min_nnz_distances_idx] = min(nnz_distances);
network_win = nnz_networks(min_nnz_distances_idx);

end

function pruned = prune_vox(voxlist,refimage)
hdr=spm_vol(refimage);
pass1=voxlist(:,1)>=1 & voxlist(:,1)<=hdr.dim(1);
pass2=voxlist(:,2)>=1 & voxlist(:,2)<=hdr.dim(2);
pass3=voxlist(:,3)>=1 & voxlist(:,3)<=hdr.dim(3);
pass=pass1 & pass2 & pass3;
pruned=voxlist(pass,:);
end
    
function mnidistance = calc_mni_dist_vox(vox1,vox2,v2m)
mni1=vox2mni(vox1,v2m);
mni2=vox2mni(vox2,v2m);
mnidistance=calc_dist_generic(mni1,mni2);
end

function mnidistance = calc_mni_dist_mni(mni1,mni2)
mnidistance=calc_dist_generic(mni1,mni2);
end

function voxdistance = calc_vox_dist_vox(vox1,vox2)
voxdistance=calc_dist_generic(vox1,vox2);
end

function voxdistance = calc_vox_dist_mni(mni1,mni2,m2v)
vox1=mni2vox(mni1,m2v);
vox2=mni2vox(mni2,m2v);
voxdistance=calc_dist_generic(vox1,vox2);
end

function distance = calc_dist_generic(coord1,coord2)
% Calculate the distance between one or more points and a reference point in arbitrary space
coord2=repmat(coord2,size(coord1,1),1);
distance = sqrt(sum((coord1-coord2).^2,2));
end

function vox = mni2vox(mni,m2v)
vox = m2v*[mni repmat(1,size(mni,1),1)]';
vox = vox(1:3,:)';
end

function mni = vox2mni(vox,v2m)
mni = v2m*[vox repmat(1,size(vox,1),1)]';
mni = mni(1:3,:)';
end

function results  = buildsphere(R)
% Borrowed from SOM_MakeSphereROI.m from Robert Welsh

Rbox = round(R);
    
if R < 1
    results = [0; 0; 0];
    return
end

Xs = [-Rbox:Rbox];
Ys = [-Rbox:Rbox];
Zs = [-Rbox:Rbox];

XGrid = repmat(Xs,[length(Ys) 1]);
YGrid = repmat(Ys',[1 length(Xs)]);

results = [];

% Now loop on the Z's and find out if in the radius.

for iZ = 1:length(Zs)
    rDist = sqrt(XGrid(:).^2 + YGrid(:).^2 + Zs(iZ)^2);
    RIDX = find(R>=rDist);
    results = [results; XGrid(RIDX) YGrid(RIDX) Zs(iZ)*ones(length(RIDX),1)];
end


end
end
