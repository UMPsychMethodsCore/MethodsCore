% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% Routine to make a grid of rois.
%
% function results = SOM_MakeGrid(gridSpacing,[BB])
%
% gridSpacing = the grid spacing in mm
%  
% BB          = the bounding box, optional.
%               X, Y, Z as in defaults.normalise.write.bb from SPM8
%  
%  
% Typically you,d call SOM_MakeGrid and then after you get your list of 
% candidate locations you can pass to "SOM_roiPointsInMask" if you want to 
% mask for gray matter.
%
% The grid created will straddle the left-right hemispheric fissure, but 
% will start at Y=0 and Z=0.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_MakeGrid(gridSpacing,BB)

% Make sure grid is > 0

if gridSpacing < 0
  SOM_LOG('FATAL : Grid spacing must be > 0');
  results = -1;
  return
end

% Did they define a bouding box>
if exist('BB') == 0
  BB = [-76, -112, -50; 76, 73, 84];
end

% Build the grid.
xvals1 = [gridSpacing/2:gridSpacing:BB(2,1)];
xvals2 = [-gridSpacing/2:-gridSpacing:BB(1,1)];
xvals  = sort([xvals1 xvals2]);

yvals1 = [0:gridSpacing:BB(2,2)];
yvals2 = [-gridSpacing:-gridSpacing:BB(1,2)];
yvals  = sort([yvals1 yvals2]);

zvals1 = [0:gridSpacing:BB(2,3)];
zvals2 = [-gridSpacing:-gridSpacing:BB(1,3)];
zvals  = sort([zvals1 zvals2]);

xgrid  = repmat(xvals,[length(yvals) 1]);
ygrid  = repmat(yvals',[1 length(xvals)]);

mni_xcoords = zeros([size(xgrid) length(zvals)]);
mni_ycoords = zeros([size(xgrid) length(zvals)]);
mni_zcoords = zeros([size(xgrid) length(zvals)]);

for iZ = 1:length(zvals)
    mni_xcoords(:,:,iZ) = xgrid;
    mni_ycoords(:,:,iZ) = ygrid;
    mni_zcoords(:,:,iZ) = zvals(iZ);
end

mni_coords_cand = [mni_xcoords(:) mni_ycoords(:) mni_zcoords(:) ];

results = mni_coords_cand;

return

%
% All done.
% 