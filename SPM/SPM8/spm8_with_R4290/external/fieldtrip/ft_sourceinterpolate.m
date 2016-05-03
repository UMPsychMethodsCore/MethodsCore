function [interp] = ft_sourceinterpolate(cfg, functional, anatomical)

% FT_SOURCEINTERPOLATE reslices and interpolates a source reconstruction
% or a statistical distribution as an overlay onto an anatomical MRI.
%
% Both the functional data and the anatomical data can either describe a
% 3-dimensional volume, an arbitrary cloud of points, or a triangulated
% mesh.
%
% The following scenarios are possible:
%
% -The functional data is defined on a low resolution 2-dimensional triangulated
%  mesh, the vertices being a subset of the high resolution 2-dimensional
%  triangulated anatomical mesh. This allows for mesh based interpolation. The
%  algorithm currently implemented is so-called 'smudging' as it is also
%  applied by the MNE-suite software.
%
% -Both the functional and the anatomical data are defined on an irregular
%  point cloud (can be a 2D triangulated mesh).
%
% -The functional data is defined on an irregular point cloud (can be a 2D
%  triangulated mesh), and the anatomical data is a volumetric image.
%
% -The functional data is defined on a 3D regular grid of source positions
%  and the anatomical data is defined on an irregular point cloud (can be a
%  2D triangulated mesh).
%
% -The functional data is defined on a 3D regular grid of source positions
%  and the anatomical data is a volumetric image.
%
% The functional and anatomical data should be expressed in the same
% coordinate sytem, i.e. either both in CTF coordinates (NAS/LPA/RPA)
% or both in SPM coordinates (AC/PC).
%
% The output data will contain a description of the functional data at the
% locations at which the anatomical data are defined. For example, if the
% anatomical data was volumetric, the output data is a volume-structure,
% containing the resliced source and the anatomical volume that can be
% plotted together, using FT_SOURCEPLOT or FT_SLICEINTERP,
% or that can be written to file using FT_SOURCEWRITE.
%
% Use as
%   [interp] = ft_sourceinterpolate(cfg, source, mri)   or
%   [interp] = ft_sourceinterpolate(cfg, stat, mri)
% where
%   source is the output of FT_SOURCEANALYSIS
%   stat   is the output of FT_SOURCESTATISTICS
%   mri    is the output of FT_READ_MRI or the filename of a MRI,
%            or
%          the output of FT_READ_HEADSHAPE or the filename of a file
%            containing the description of a cortical sheet.
% and cfg is a structure with any of the following fields
%   cfg.parameter     = string, default is 'all'
%   cfg.interpmethod  = 'linear', 'cubic', 'nearest' or 'spline' when
%                          interpolating two 3D volumes onto each other
%   cfg.interpmethod  = 'nearest', 'sphere_avg' or 'smudge' when
%                          interpolating a point cloud onto a 3D volume, a
%                          3D volume onto a point cloud, or a point cloud
%                          with another point cloud
%   cfg.downsample    = integer number (default = 1, i.e. no downsampling)
%
% To facilitate data-handling and distributed computing with the peer-to-peer
% module, this function has the following options:
%   cfg.inputfile   =  ...
%   cfg.outputfile  =  ...
% If you specify one of these (or both) the input data will be read from a *.mat
% file on disk and/or the output data will be written to a *.mat file. These mat
% files should contain only a single variable, corresponding with the
% input/output structure.
%
% See also FT_SOURCEANALYSIS, FT_SOURCESTATISTICS, FT_READ_MRI,
% FT_READ_HEADSHAPE

% Undocumented options
%   cfg.voxelcoord = 'yes' (default) or 'no' determines whether the
%   downsampled output anatomical MRI will have the x/y/zgrid converted or
%   the homogeneous transformation matrix

% Copyright (C) 2003-2007, Robert Oostenveld
% Copyright (C) 2011,      Jan-Mathijs Schoffelen
%
% This file is part of FieldTrip, see http://www.ru.nl/neuroimaging/fieldtrip
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id: ft_sourceinterpolate.m 3268 2011-04-04 11:05:07Z jansch $

ft_defaults

%% ft_checkdata see below!!! %%

% check if the input cfg is valid for this function
cfg = ft_checkconfig(cfg, 'trackconfig', 'on');
cfg = ft_checkconfig(cfg, 'unused',     {'keepinside'});
cfg = ft_checkconfig(cfg, 'deprecated', {'sourceunits', 'mriunits'});

% set the defaults
if ~isfield(cfg, 'parameter'),    cfg.parameter    = 'all';     end
if ~isfield(cfg, 'interpmethod'), cfg.interpmethod = 'linear';  end
if ~isfield(cfg, 'sphereradius'), cfg.sphereradius = [];        end
if ~isfield(cfg, 'downsample');   cfg.downsample   = 1;         end
if ~isfield(cfg, 'voxelcoord'),   cfg.voxelcoord   = 'yes';     end
if ~isfield(cfg, 'feedback'),     cfg.feedback     = 'text';    end
if ~isfield(cfg, 'inputfile'),    cfg.inputfile    = [];        end
if ~isfield(cfg, 'outputfile'),   cfg.outputfile   = [];        end

hasdata      = (nargin>1);
hasinputfile = ~isempty(cfg.inputfile);

if hasdata && hasinputfile
  error('cfg.inputfile should not be used in conjunction with giving input data to this function');
end

% load optional given *.mat inputfile as data
if hasinputfile
  functional = loadvar(cfg.inputfile{1});
  anatomical = loadvar(cfg.inputfile{2});
end

% read the anatomical MRI or cortical mesh from file
if ischar(anatomical)
  try
    fprintf('trying to read anatomical MRI from file\n');
    anatomical = ft_read_mri(anatomical);
  catch
    fprintf('anatomical file does not seem to be an anatomical MRI\n');
  end
end % if ischar

if ischar(anatomical)
  try
    fprintf('trying to read cortical mesh from file\n');
    anatomical = ft_read_headshape(anatomical);
  catch
    fprintf('anatomical file does not seem to be a cortical mesh\n');
  end
end % if ischar

if ischar(anatomical)
  % if it ends up here, it means that all previous attempts failed
  error('the anatomical file does not seem to contain an anatomical MRI, nor a cortical mesh');
end % if ischar


if isfield(anatomical, 'pnt')
  % anatomical data consists of a mesh, but no smudging possible
  is2Dana  = 1;
elseif isfield(anatomical, 'transform') && isfield(anatomical, 'dim')
  is2Dana  = 0;
end

if isfield(functional, 'dim') && numel(functional.dim)==3
  is2Dfun  = 0;
else
  is2Dfun  = 1;
end

if is2Dfun && is2Dana && isfield(anatomical, 'orig') && isfield(anatomical.orig, 'pnt') && isfield(anatomical.orig, 'tri'),
  % anatomical data consists of a decimated triangulated mesh, containing
  % the original description, allowing for smudging. The coordinate systems
  % do not necessarily have to align. Should this be imposed?
  dosmudge = 1;
else
  dosmudge = 0;
end

if dosmudge && is2Dana && is2Dfun
  
  % smudge the low resolution functional data according to the strategy in
  % MNE-suite (chapter 8.3 of the manual)
  
  % hmmmm, if the input data contains a time dimension, then the output
  % may be terribly blown up; most convenient would be to output only the
  % smudging matrix, and project the data when plotting
  if ~isfield(anatomical, 'orig')
    error('this is not yet implemented');
  end
  interpmat = interp_ungridded(anatomical.pnt, anatomical.orig.pnt, 'projmethod', 'smudge', 'triout', anatomical.orig.tri);
  
  interp     = [];
  interp.pos = anatomical.orig.pnt;
  interp.tri = anatomical.orig.tri;
  if isfield(interp, 'dim'),
    interp = rmfield(interp, 'dim');
  end
  interp.inside = (1:size(interp.pos,1))';
  interp.outside = [];
  
  for k = 1:numel(cfg.parameter)
    interp = setsubfield(interp, cfg.parameter{k}, interpmat*getsubfield(functional, cfg.parameter{k}));
  end
  
elseif is2Dana && is2Dfun
  
  % 'interp_ungridded'
  error('not yet implemented');
  
elseif ~is2Dana && is2Dfun
  
  % interpolate onto a 3D volume, ensure that the anatomical is indeed a
  % volume
  anatomical = ft_checkdata(anatomical, 'datatype', 'volume', 'inside', 'logical', 'feedback', 'yes', 'hasunits', 'yes');
  functional = ft_convert_units(functional, anatomical.unit);
  
  % get voxel indices and use interp_ungridded
  dim       = anatomical.dim;
  [X, Y, Z] = ndgrid(1:dim(1), 1:dim(2), 1:dim(3));
  
  interpmat = interp_ungridded(functional.pos, warp_apply(anatomical.transform, [X(:) Y(:) Z(:)]), ...
    'projmethod', cfg.interpmethod, 'sphereradius', cfg.sphereradius); %FIXME include other key-value pairs as well
  clear X Y Z;
  
  interp = [];
  interp.dim       = dim;
  interp.transform = anatomical.transform;
  interp.inside    = anatomical.inside;
  
  interpmat(~anatomical.inside(:), :) = 0;
  for k = 1:numel(cfg.parameter)
    interp = setsubfield(interp, cfg.parameter{k}, reshape(interpmat*getsubfield(functional, cfg.parameter{k}),dim));
  end
  
elseif is2Dana && ~is2Dfun
  
  % interpolate the 3D volume onto the anatomy
  anatomical = ft_convert_units(anatomical);
  functional = ft_checkdata(functional, 'datatype', 'volume', 'inside', 'logical', 'feedback', 'yes', 'hasunits', 'yes');
  functional = ft_convert_units(functional, anatomical.unit);
  
  % get voxel indices and use interp_ungridded
  dim       = functional.dim;
  [X, Y, Z] = ndgrid(1:dim(1), 1:dim(2), 1:dim(3));
  
  interpmat  = interp_ungridded([X(:) Y(:) Z(:)], warp_apply(inv(functional.transform), anatomical.pnt), ...,
    'projmethod', cfg.interpmethod, 'sphereradius', cfg.sphereradius);
  clear X Y Z;
  
  interp = [];
  interp.pos       = anatomical.pnt;
  interp.inside    = (1:size(anatomical.pnt,1))';
  interp.outside   = [];
  if isfield(anatomical, 'tri'), interp.tri = anatomical.tri; end
  
  for k = 1:numel(cfg.parameter)
    tmp    = getsubfield(functional, cfg.parameter{k});
    interp = setsubfield(interp, cfg.parameter{k}, interpmat*reshape(tmp, [prod(dim) numel(tmp)./prod(dim)]));
  end
  
elseif ~is2Dana && ~is2Dfun
  
  % original implementation interpolate a 3D volume onto another 3D volume
  
  % check if the input data is valid for this function and ensure that the structures correctly describes a volume
  functional = ft_checkdata(functional, 'datatype', 'volume', 'inside', 'logical', 'feedback', 'yes', 'hasunits', 'yes');
  anatomical = ft_checkdata(anatomical, 'datatype', 'volume', 'inside', 'logical', 'feedback', 'yes', 'hasunits', 'yes');
  
  if ~strcmp(functional.unit, anatomical.unit)
    fprintf('converting functional data from %s into %s\n', functional.unit, anatomical.unit);
    functional = ft_convert_units(functional, anatomical.unit);
  end
  
  % select the parameters that should be interpolated
  cfg.parameter = parameterselection(cfg.parameter, functional);
  cfg.parameter = setdiff(cfg.parameter, 'inside'); % inside is handled separately
  
  if ~isequal(cfg.downsample, 1)
    % downsample the anatomical volume
    tmpcfg = [];
    tmpcfg.downsample = cfg.downsample;
    tmpcfg.parameter  = 'anatomy';
    anatomical = ft_volumedownsample(tmpcfg, anatomical);
  end
  
  % collect the functional volumes that should be converted
  vol_name = {};
  vol_data = {};
  for i=1:length(cfg.parameter)
    if ~iscell(getsubfield(functional, cfg.parameter{i}))
      vol_name{end+1} = cfg.parameter{i};
      vol_data{end+1} = getsubfield(functional, cfg.parameter{i});
    else
      fprintf('not interpolating %s, since it is not a scalar field\n', cfg.parameter{i});
    end
  end
  
  % remember the coordinate trandsformation for both
  transform_ana = anatomical.transform;
  transform_fun = functional.transform;
  
  % convert the anatomical voxel positions into voxel indices into the functional volume
  anatomical.transform = functional.transform \ anatomical.transform;
  functional.transform = eye(4);
  
  [fx, fy, fz] = voxelcoords(functional);
  [ax, ay, az] = voxelcoords(anatomical);
  
  % estimate the subvolume of the anatomy that is spanned by the functional volume
  minfx = 1;
  minfy = 1;
  minfz = 1;
  maxfx = functional.dim(1);
  maxfy = functional.dim(2);
  maxfz = functional.dim(3);
  sel = ax(:)>=minfx & ...
    ax(:)<=maxfx & ...
    ay(:)>=minfy & ...
    ay(:)<=maxfy & ...
    az(:)>=minfz & ...
    az(:)<=maxfz;
  fprintf('selecting subvolume of %.1f%%\n', 100*sum(sel)./prod(anatomical.dim));
  
  % start with an empty output structure
  interp = [];
  
  dimf  = [functional.dim 1 1];
  allav = zeros([anatomical.dim dimf(4:end)]);
  functional.inside = functional.inside(:,:,:,1,1);
  
  if all(functional.inside(:))
    % keep all voxels marked as inside
    interp.inside = true(anatomical.dim);
  else
    % reslice and interpolate inside
    interp.inside = zeros(anatomical.dim);
    % interpolate with method nearest
    interp.inside( sel) = my_interpn(double(functional.inside), ax(sel), ay(sel), az(sel), 'nearest', cfg.feedback);
    interp.inside(~sel) = 0;
    interp.inside = logical(interp.inside);
  end
  
  % prepare the grid that is used in the interpolation
  fg = [fx(:) fy(:) fz(:)];
  clear fx fy fz
  
  % reslice and interpolate all functional volumes
  for i=1:length(vol_name)
    fprintf('reslicing and interpolating %s\n', vol_name{i});
    for k=1:dimf(4)
      for m=1:dimf(5)
        fv = vol_data{i}(:,:,:,k,m);
        if ~isa(fv, 'double')
          % only convert if needed, this saves memory
          fv = double(fv);
        end
        av = zeros(anatomical.dim);
        % av( sel) = my_interpn(fx, fy, fz, fv, ax(sel), ay(sel), az(sel), cfg.interpmethod, cfg.feedback);
        if islogical(vol_data{i})
          % interpolate always with method nearest
          av( sel) = my_interpn(fv, ax(sel), ay(sel), az(sel), 'nearest', cfg.feedback);
          av = logical(av);
        else
          if ~all(functional.inside(:))
            % extrapolate the outside of the functional volumes for better interpolation at the edges
            fv(~functional.inside) = griddatan(fg(functional.inside(:), :), fv(functional.inside(:)), fg(~functional.inside(:), :), 'nearest');
          end
          % interpolate functional onto anatomical grid
          av( sel) = my_interpn(fv, ax(sel), ay(sel), az(sel), cfg.interpmethod, cfg.feedback);
          clear fv
          av(~sel) = nan;
          av(~interp.inside) = nan;
        end
        allav(:,:,:,k,m) = av;
        clear av
      end
    end
    interp = setsubfield(interp, vol_name{i}, allav);
  end
  
  % add the other parameters to the output
  interp.dim       = anatomical.dim;
  interp.transform = transform_ana; % the original coordinate system
  if ~any(strcmp(cfg.parameter, 'anatomy'))
    % copy the anatomy into the functional data
    interp.anatomy   = anatomical.anatomy;
  end
end

% accessing this field here is needed for the configuration tracking
% by accessing it once, it will not be removed from the output cfg
cfg.outputfile;

% get the output cfg
cfg = ft_checkconfig(cfg, 'trackconfig', 'off', 'checksize', 'yes');

% add version information to the configuration
cfg.version.name = mfilename('fullpath');
cfg.version.id = '$Id: ft_sourceinterpolate.m 3268 2011-04-04 11:05:07Z jansch $';

% add information about the Matlab version used to the configuration
cfg.version.matlab = version();

% remember the configuration details of the input data
cfg.previous = [];
if isfield(functional, 'cfg'), cfg.previous{1} = functional.cfg; end
if isfield(anatomical, 'cfg'), cfg.previous{2} = anatomical.cfg; end

% remember the exact configuration details in the output
interp.cfg = cfg;

% the output data should be saved to a MATLAB file
if ~isempty(cfg.outputfile)
  savevar(cfg.outputfile, 'data', interp); % use the variable name "data" in the output file
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION this function computes the location of all voxels in head
% coordinates in a memory efficient manner
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, y, z] = voxelcoords(volume)

dim       = volume.dim;
transform = volume.transform;
if isfield(volume, 'xgrid')
  xgrid = volume.xgrid;
  ygrid = volume.ygrid;
  zgrid = volume.zgrid;
else
  xgrid = 1:dim(1);
  ygrid = 1:dim(2);
  zgrid = 1:dim(3);
end
npix = prod(dim(1:2));  % number of voxels in a single slice

x = zeros(dim);
y = zeros(dim);
z = zeros(dim);
X = zeros(1,npix);
Y = zeros(1,npix);
Z = zeros(1,npix);
E = ones(1,npix);
% determine the voxel locations per slice
for i=1:dim(3)
  [X(:), Y(:), Z(:)] = ndgrid(xgrid, ygrid, zgrid(i));
  tmp = transform*[X; Y; Z; E];
  x((1:npix)+(i-1)*npix) = tmp(1,:);
  y((1:npix)+(i-1)*npix) = tmp(2,:);
  z((1:npix)+(i-1)*npix) = tmp(3,:);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION for memory efficient interpolation
% the only reason for this function is that it does the interpolation in smaller chuncks
% this prevents memory problems that I often encountered here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [av] = my_interpn(fx, fy, fz, fv, ax, ay, az, interpmethod, feedback);
function [av] = my_interpn(fv, ax, ay, az, interpmethod, feedback)

num = numel(ax);            % total number of voxels
blocksize = floor(num/20);  % number of voxels to interpolate at once, split it into 20 chuncks
lastblock = 0;              % boolean flag for while loop
sel = 1:blocksize;          % selection of voxels that are interpolated, this is the first chunck
av  = zeros(size(ax));
ft_progress('init', feedback, 'interpolating');
while (1)
  ft_progress(sel(1)/num, 'interpolating %.1f%%\n', 100*sel(1)/num);
  if sel(end)>num
    sel = sel(1):num;
    lastblock = 1;
  end
  av(sel) = interpn(fv, ax(sel), ay(sel), az(sel), interpmethod);
  if lastblock
    break
  end
  sel = sel + blocksize;
end
ft_progress('close');
