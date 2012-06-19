function [normalise] = ft_volumenormalise(cfg, interp)

% FT_VOLUMENORMALISE normalises anatomical and functional volume data
% to a template anatomical MRI.
%
% Use as
%   [volume] = ft_volumenormalise(cfg, volume)
%
% The input volume should be the result from FT_SOURCEINTERPOLATE.
% Alternatively, the input can contain a single anatomical MRI that
% was read with FT_READ_MRI, or you can specify a filename of an
% anatomical MRI.
%
% Configuration options are:
%   cfg.spmversion  = 'spm8' (default) or 'spm2'
%   cfg.template    = filename of the template anatomical MRI (default is the 'T1.mnc' (spm2) or 'T1.nii' (spm8)
%                     in the (spm-directory)/templates/)
%   cfg.parameter   = cell-array with the functional data which has to
%                     be normalised, can be 'all'
%   cfg.downsample  = integer number (default = 1, i.e. no downsampling)
%   cfg.coordinates = 'spm, 'ctf' or empty for interactive (default = [])
%   cfg.name        = string for output filename
%   cfg.write       = 'no' (default) or 'yes', writes the segmented volumes to SPM2
%                     compatible analyze-file, with the suffix
%                     _anatomy for the anatomical MRI volume
%                     _param   for each of the functional volumes
%   cfg.nonlinear   = 'yes' (default) or 'no', estimates a nonlinear transformation
%                     in addition to the linear affine registration. If a reasonably
%                     accurate normalisation is sufficient, a purely linearly transformed
%                     image allows for 'reverse-normalisation', which might come in handy
%                     when for example a region of interest is defined on the normalised
%                     group-average.
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

% Undocumented local options:
%   cfg.keepintermediate = 'yes' or 'no'
%   cfg.intermediatename = prefix of the the coregistered images and of the
%                          original images in the original headcoordinate system
%   cfg.spmparams        = one can feed in parameters from a prior
%   normalisation
%
% See also FT_SOURCEINTERPOLATE, FT_READ_MRI

% Copyright (C) 2004-2006, Jan-Mathijs Schoffelen
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
% $Id: ft_volumenormalise.m 3226 2011-03-25 13:40:08Z jansch $

ft_defaults

cfg = ft_checkconfig(cfg, 'trackconfig', 'on');
cfg = ft_checkconfig(cfg, 'renamed', {'coordinates', 'coordsys'});

%% ft_checkdata see below!!! %%

% set the defaults
cfg.spmversion       = ft_getopt(cfg, 'spmversion',       'spm8');
cfg.parameter        = ft_getopt(cfg, 'parameter',        'all'); 
cfg.downsample       = ft_getopt(cfg, 'downsample',       1); 
cfg.write            = ft_getopt(cfg, 'write',            'no'); 
cfg.keepinside       = ft_getopt(cfg, 'keepinside',       'yes');
cfg.keepintermediate = ft_getopt(cfg, 'keepintermediate', 'no');
cfg.coordsys         = ft_getopt(cfg, 'coordsys',         '');
cfg.units            = ft_getopt(cfg, 'units',            'mm');
cfg.nonlinear        = ft_getopt(cfg, 'nonlinear',        'yes');
cfg.smooth           = ft_getopt(cfg, 'smooth',           'no');
cfg.inputfile        = ft_getopt(cfg, 'inputfile',        []);
cfg.outputfile       = ft_getopt(cfg, 'outputfile',       []);

% load optional given inputfile as data
hasdata      = (nargin>1);
hasinputfile = ~isempty(cfg.inputfile);
if hasdata && hasinputfile
  error('cfg.inputfile should not be used in conjunction with giving input data to this function');
elseif hasinputfile
  interp = loadvar(cfg.inputfile, 'interp');
end

% load mri if second input is a string
if ischar(interp),
  fprintf('reading source MRI from file\n');
  interp = ft_read_mri(interp);
  if ~isfield(interp, 'coordsys') && ft_filetype(filename, 'ctf_mri')
    % based on the filetype assume that the coordinates correspond with CTF convention
    interp.coordsys = 'ctf';
  end
end

% check if the input data is valid for this function
interp = ft_checkdata(interp, 'datatype', 'volume', 'feedback', 'yes');

% check whether the input has an anatomy
if ~isfield(interp,'anatomy'),
  error('no anatomical information available, this is required for normalisation');
end

% ensure that the data has interpretable units and that the coordinate
% system is in approximate spm space and keep track of an initial transformation
% matrix that approximately does the co-registration
if ~isfield(interp, 'unit'),     interp.unit     = cfg.units;    end
if ~isfield(interp, 'coordsys'), interp.coordsys = cfg.coordsys; end
interp  = ft_convert_units(interp,    'mm');
orig    = interp.transform;
interp  = ft_convert_coordsys(interp, 'spm');
initial = interp.transform / orig;

% check if the required spm is in your path:
if strcmpi(cfg.spmversion, 'spm2'),
  ft_hastoolbox('SPM2',1);
elseif strcmpi(cfg.spmversion, 'spm8'),
  ft_hastoolbox('SPM8',1);
end

if ~isfield(cfg, 'template'),
  spmpath      = spm('dir');
  if strcmpi(cfg.spmversion, 'spm8'), cfg.template = [spmpath,filesep,'templates',filesep,'T1.nii']; end
  if strcmpi(cfg.spmversion, 'spm2'), cfg.template = [spmpath,filesep,'templates',filesep,'T1.mnc']; end
end

if strcmp(cfg.keepinside, 'yes')
  % add inside to the list of parameters
  if ~iscell(cfg.parameter),
    cfg.parameter = {cfg.parameter 'inside'};
  else
    cfg.parameter(end+1) = {'inside'};
  end
end

if ~isfield(cfg,'intermediatename')
  cfg.intermediatename = tempname;
end

if ~isfield(cfg,'name') && strcmp(cfg.write,'yes')
  error('you must specify the output filename in cfg.name');
end

if isempty(cfg.template),
  error('you must specify a template anatomical MRI');
end

% the template anatomy should always be stored in a SPM-compatible file
template_ftype = ft_filetype(cfg.template);
if strcmp(template_ftype, 'analyze_hdr') || strcmp(template_ftype, 'analyze_img') || strcmp(template_ftype, 'minc') || strcmp(template_ftype, 'nifti')
  % based on the filetype assume that the coordinates correspond with MNI/SPM convention
  % this is ok
else
  error('the head coordinate system of the template does not seem to be correspond with the mni/spm convention');
end

% select the parameters that should be normalised
cfg.parameter = parameterselection(cfg.parameter, interp);

% the anatomy should always be normalised as the first volume
sel = strcmp(cfg.parameter, 'anatomy');
if ~any(sel)
  cfg.parameter = {'anatomy' cfg.parameter{:}};
else
  [dum, indx] = sort(sel);
  cfg.parameter = cfg.parameter(fliplr(indx));
end

% downsample the volume
tmpcfg            = [];
tmpcfg.downsample = cfg.downsample;
tmpcfg.parameter  = cfg.parameter;
tmpcfg.smooth     = cfg.smooth;
tmpcfg.outputfile = cfg.outputfile;
interp = ft_volumedownsample(tmpcfg, interp);

ws = warning('off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% here the normalisation starts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create an spm-compatible header for the anatomical volume data
VF = ft_write_volume([cfg.intermediatename,'_anatomy.img'], interp.anatomy, 'transform', interp.transform, 'spmversion', cfg.spmversion);

% create an spm-compatible file for each of the functional volumes
for parlop=2:length(cfg.parameter)  % skip the anatomy
  tmp  = cfg.parameter{parlop};
  data = reshape(getsubfield(interp, tmp), interp.dim);
  tmp(find(tmp=='.')) = '_';
  ft_write_volume([cfg.intermediatename,'_' tmp '.img'], data, 'transform', interp.transform, 'spmversion', cfg.spmversion);
end

% read the template anatomical volume
switch template_ftype
  case 'minc'
    VG    = spm_vol_minc(cfg.template);
  case {'analyze_img', 'analyze_hdr', 'nifti'},
    VG    = spm_vol(cfg.template);
  otherwise
    error('Unknown template');
end

fprintf('performing the normalisation\n');
% do spatial normalisation according to these steps
% step 1: read header information for template and source image
% step 2: compute transformation parameters
% step 3: write the results to a file with prefix 'w'

if ~isfield(cfg, 'spmparams') && strcmp(cfg.nonlinear, 'yes'),
  fprintf('warping the invdividual anatomy to the template anatomy\n');
  % compute the parameters by warping the individual anatomy
  VF        = spm_vol([cfg.intermediatename,'_anatomy.img']);
  params    = spm_normalise(VG,VF);
elseif ~isfield(cfg, 'spmparams') && strcmp(cfg.nonlinear, 'no'),
  fprintf('warping the invdividual anatomy to the template anatomy, using only linear transformations\n');
  % compute the parameters by warping the individual anatomy
  VF         = spm_vol([cfg.intermediatename,'_anatomy.img']);
  flags.nits = 0; %put number of non-linear iterations to zero
  params     = spm_normalise(VG,VF,[],[],[],flags);
else
  fprintf('using the parameters specified in the configuration\n');
  % use the externally specified parameters
  params = cfg.spmparams;
end
flags.vox = [cfg.downsample,cfg.downsample,cfg.downsample];
files     = {};

% determine the affine source->template coordinate transformation
final = VG.mat * inv(params.Affine) * inv(VF.mat) * initial;

% apply the normalisation parameters to each of the volumes
for parlop=1:length(cfg.parameter)
  fprintf('creating normalised analyze-file for %s\n', cfg.parameter{parlop});
  tmp = cfg.parameter{parlop};
  tmp(find(tmp=='.')) = '_';
  files{parlop} = sprintf('%s_%s.img', cfg.intermediatename, tmp);
  [p, f, x] = fileparts(files{parlop});
  wfiles{parlop} = fullfile(p, ['w' f x]);
end
spm_write_sn(char(files),params,flags);  % this creates the 'w' prefixed files

normalise = [];

% read the normalised results from the 'w' prefixed files
V = spm_vol(char(wfiles));
for vlop=1:length(V)
  normalise = setsubfield(normalise, cfg.parameter{vlop}, spm_read_vols(V(vlop)));
end

normalise.transform = V(1).mat;
normalise.dim       = size(normalise.anatomy);

if isfield(normalise, 'inside')
  % convert back to a logical volume
  normalise.inside  = abs(normalise.inside-1)<=10*eps;
end

% flip and permute the dimensions to align the volume with the headcoordinate axes
normalise = align_ijk2xyz(normalise);

if strcmp(cfg.write,'yes')
  % create an spm-compatible file for each of the normalised volumes
  for parlop=1:length(cfg.parameter)  % include the anatomy
    tmp  = cfg.parameter{parlop};
    data = reshape(getsubfield(normalise, tmp), normalise.dim);
    tmp(find(tmp=='.')) = '_';
    ft_write_volume([cfg.name,'_' tmp '.img'], data, 'transform', normalise.transform, 'spmversion', cfg.spmversion);
  end
end

if strcmp(cfg.keepintermediate,'no')
  % remove the intermediate files
  for flop=1:length(files)
    [p, f, x] = fileparts(files{flop});
    delete(fullfile(p, [f, '.*']));
    [p, f, x] = fileparts(wfiles{flop});
    delete(fullfile(p, [f, '.*']));
  end
end

% accessing this field here is needed for the configuration tracking
% by accessing it once, it will not be removed from the output cfg
cfg.outputfile;

% get the output cfg
cfg = ft_checkconfig(cfg, 'trackconfig', 'off', 'checksize', 'yes');

% remember the normalisation parameters in the configuration
cfg.spmparams = params;
cfg.final     = final;

% add version information to the configuration
cfg.version.name = mfilename('fullpath');
cfg.version.id = '$Id: ft_volumenormalise.m 3226 2011-03-25 13:40:08Z jansch $';

% add information about the Matlab version used to the configuration
cfg.version.matlab = version();

% remember the configuration details of the input data
try, cfg.previous = interp.cfg; end

% remember the exact configuration details in the output
normalise.cfg = cfg;

% the output data should be saved to a MATLAB file
if ~isempty(cfg.outputfile)
  savevar(cfg.outputfile, 'data', normalise); % use the variable name "data" in the output file
end
