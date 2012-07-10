function [segment] = ft_volumesegment(cfg, mri)

% FT_VOLUMESEGMENT segments an anatomical MRI. The behaviour depends on the
% output requested. It can return probabilistic tissue maps of
% gray/white/csf compartments, a skull-stripped anatomy, or binary masks
% representing the brain surface, skull, or scalp surface.
%
% This function uses the SPM8 toolbox, see http://www.fil.ion.ucl.ac.uk/spm/
%
% Use as
%   [segment] = ft_volumesegment(cfg, mri)
%
% The input arguments are a configuration structure (see below) and an
% anatomical MRI structure. Instead of an MRI structure, you can also
% specify a string with a filename of an MRI file. You can also provide an
% already segmented volume in the input for the purpose of creating a
% binary mask.
%
% The configuration options are
%   cfg.output      = 'tpm' (default), 'brain', 'skull', 'skullstrip', 'scalp', or any
%                        combination of these in a cell-array
%   cfg.spmversion  = 'spm8' (default) or 'spm2'
%   cfg.template    = filename of the template anatomical MRI (default is the 'T1.nii' 
%                     (spm8) or 'T1.mnc' (spm2) in the (spm-directory)/templates/)
%   cfg.name        = string for output filename
%   cfg.write       = 'no' or 'yes' (default = 'no'),
%                     writes the probabilistic tissue maps to SPM compatible analyze (spm2),
%                     or nifti (spm8) files,
%                     with the suffix (spm2)
%                     _seg1, for the gray matter segmentation
%                     _seg2, for the white matter segmentation
%                     _seg3, for the csf segmentation
%                     or with the prefix (spm8)
%                     c1, for the gray matter segmentation
%                     c2, for the white matter segmentation
%                     c3, for the csf segmentation
%                   
%   cfg.smooth      = 'no', or scalar, the FWHM of the gaussian kernel in
%                       voxels, default depends on the requested output
%   cfg.threshold   = 'no', or scalar, relative threshold value which is
%                       used to threshold the data in order to create a
%                       volumetric mask (see below).
%                       the default depends on the requested output 
%   cfg.downsample  = integer, amount of downsampling before segmentation
%                       (default = 1; i.e., no downsampling)
%   cfg.coordsys    = string, specifying the coordinate system in which the
%                       anatomical data is defined. This will be used if
%                       the input mri does not contain a coordsys-field.
%                       (default = '', which results in the user being
%                       forced to evaluate the coordinate system)
%   cfg.units       = the physical units in which the output will be
%                       expressed. (default = 'mm')
%
% Example use:
%
%   segment = ft_volumesegment([], mri) will segment the anatomy and will output
%               the segmentation result as 3 probabilistic masks in 
%               segment.gray/.white/.csf
%
%   cfg.output = 'skullstrip';
%   segment    = ft_volumesegment(cfg, mri) will generate a skullstripped anatomy
%                  based on a brainmask generated from the probabilistic
%                  tissue maps. The skull-stripped anatomy is be stored in
%                  the field segment.anatomy.
%
%
%   cfg.output = {'brain' 'scalp' 'skull'};
%   segment    = ft_volumesegment(cfg, mri) will produce a volume with 3 binary
%                  masks, representing the brain surface, scalp surface, and skull
%
% For the SPM-based segmentation to work, the coordinate frame of the input
% MRI needs to be approximately coregistered to the templates of the
% probabilistic tissue maps. The templates are defined in SPM/MNI-space.
% FieldTrip attempts to do an automatic alignment based on the
% coordsys-field in the mri, and if this is not present, based on the
% coordsys-field in the cfg. If none of them is specified the
% FT_DETERMINE_COORDSYS function is used to interactively assess the
% coordinate system in which the MRI is expressed.
%
% The template mri is defined in SPM/MNI-coordinates:
%   x-axis pointing to the right ear
%   y-axis along the acpc-line
%   z-axis pointing to the top of the head
%   origin in the anterior commissure.
% Note that the segmentation only works if the template MRI is in SPM
% coordinates.
% 
% If the input mri is a string pointing to a CTF *.mri file, the
% x-axis is assumed to point to the nose, and the origin is assumed
% to be on the interauricular line. In this specific case, when ft_read_mri
% is used to read in the mri, the coordsys field is automatically attached.
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
% See also FT_READ_MRI FT_DETERMINE_COORDSYS

% undocumented options
%   cfg.keepintermediate = 'yes' or 'no'

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
% $Id: ft_volumesegment.m 3735 2011-06-29 08:22:09Z jorhor $

ft_defaults

cfg = ft_checkconfig(cfg, 'trackconfig', 'on');
cfg = ft_checkconfig(cfg, 'renamed',  {'coordinates', 'coordsys'});

% set the defaults
cfg.output           = ft_getopt(cfg, 'output',           'tpm');
cfg.downsample       = ft_getopt(cfg, 'downsample',       1);
cfg.spmversion       = ft_getopt(cfg, 'spmversion',       'spm8');
cfg.write            = ft_getopt(cfg, 'write',            'no');
cfg.keepintermediate = ft_getopt(cfg, 'keepintermediate', 'no');
cfg.coordsys         = ft_getopt(cfg, 'coordsys',         '');
cfg.units            = ft_getopt(cfg, 'units',            '');
cfg.inputfile        = ft_getopt(cfg, 'inputfile',        []);
cfg.outputfile       = ft_getopt(cfg, 'outputfile',       []);

% check if the required spm is in your path:
if strcmpi(cfg.spmversion, 'spm2'),
  ft_hastoolbox('SPM2',1);
elseif strcmpi(cfg.spmversion, 'spm8'),
  ft_hastoolbox('SPM8',1);
end

% get the names of the templates for the segmentation
if ~isfield(cfg, 'template'),
  spmpath      = spm('dir');
  if strcmpi(cfg.spmversion, 'spm8'), cfg.template = [spmpath,filesep,'templates',filesep,'T1.nii']; end
  if strcmpi(cfg.spmversion, 'spm2'), cfg.template = [spmpath,filesep,'templates',filesep,'T1.mnc']; end
end

if ~isfield(cfg,'name') 
  if ~strcmp(cfg.write,'yes')
    tmp = tempname;
    cfg.name = tmp;
  else
    error('you must specify the output filename in cfg.name');
  end
end 

if ~iscell(cfg.output)
  % ensure it to be cell, to allow for multiple outputs
  cfg.output = {cfg.output};
end

for k = 1:numel(cfg.output)
  % set defaults for the smoothing and thresholding if needed
  switch cfg.output{k}
    case 'tpm'
      tmp = ft_getopt(cfg, 'smooth',    nan);
      if ischar(tmp) && strcmp(tmp, 'no')
        cfgsmooth(k)    = nan;
      elseif ischar(tmp)
        error('invalid value %s for cfg.smooth', tmp);
      else
        cfgsmooth(k)   = tmp;
      end
      cfgthreshold(k) = ft_getopt(cfg, 'threshold', nan); 
    case {'skullstrip' 'brain' 'skull'}
      tmp = ft_getopt(cfg, 'smooth',    5);
      if ischar(tmp) && strcmp(tmp, 'no')
        cfgsmooth(k)    = nan;
      elseif ischar(tmp)
        error('invalid value %s for cfg.smooth', tmp);
      else
        cfgsmooth(k)   = tmp;
      end
      cfgthreshold(k) = ft_getopt(cfg, 'threshold', 0.5); 
    case 'scalp'
      tmp = ft_getopt(cfg, 'smooth',    5);     
      if ischar(tmp) && strcmp(tmp, 'no')
        cfgsmooth(k)    = nan;
      elseif ischar(tmp)
        error('invalid value %s for cfg.smooth', tmp);
      else
        cfgsmooth(k)   = tmp;
      end
      cfgthreshold(k) = ft_getopt(cfg, 'threshold', 0.1);
    otherwise
      error('unknown output %s requested', cfg.output);
  end
end
cfg.smooth    = cfgsmooth;
cfg.threshold = cfgthreshold;

hasdata      = (nargin>1);
hasinputfile = ~isempty(cfg.inputfile);
if hasdata && hasinputfile
  error('cfg.inputfile should not be used in conjunction with giving input data to this function');
elseif hasinputfile
  % the input data should be read from file
  mri = loadvar(cfg.inputfile, 'mri');
elseif hasdata
  if ischar(mri),
    % read the anatomical MRI data from file
    filename = mri;
    fprintf('reading MRI from file\n');
    mri = ft_read_mri(filename);
    if ft_filetype(filename, 'ctf_mri') && isempty(cfg.coordsys)
      % based on the filetype assume that the coordinates correspond with CTF convention
      cfg.coordsys = 'ctf';
    end
  end
else
  error('neither a data structure, nor a cfg.inputfile is provided');
end

% check if the input data is valid for this function
mri = ft_checkdata(mri, 'datatype', 'volume', 'feedback', 'yes');

% check whether spm is needed to generate tissue probability maps
needtpm    = any(ismember(cfg.output, {'tpm' 'brain' 'skullstrip'}));
hastpm     = isfield(mri, 'gray') && isfield(mri, 'white') && isfield(mri, 'csf');

if needtpm && ~hastpm
  % spm needs to be used for the creation of the tissue probability maps  
  dotpm = 1;
else
  dotpm = 0;
end

needana    = any(ismember(cfg.output, {'scalp' 'skullstrip'})) || dotpm;
hasanatomy = isfield(mri, 'anatomy');
if needana && ~hasanatomy
  error('the input volume needs an anatomy-field');
end

% perform optional downsampling before segmentation
if cfg.downsample ~= 1
  tmpcfg            = [];
  tmpcfg.downsample = cfg.downsample;
  tmpcfg.smooth     = 'no'; % smoothing is done in ft_volumesegment itself
  mri = ft_volumedownsample(tmpcfg, mri);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create the tissue probability maps if needed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if dotpm 
  
  % ensure that the data has interpretable units and that the coordinate
  % system is in approximate spm space
  if ~isfield(mri, 'unit'),     mri.unit     = cfg.units;    end
  if ~isfield(mri, 'coordsys'), mri.coordsys = cfg.coordsys; end
  
  % remember the original transformation matrix coordinate system
  original.transform = mri.transform;
  original.coordsys  = mri.coordsys; 
  
  mri = ft_convert_units(mri,    'mm');
  mri = ft_convert_coordsys(mri, 'spm');
  
  % flip and permute the 3D volume itself, so that the voxel and 
  % headcoordinates approximately correspond this improves the convergence
  % of the segmentation algorithm
  [mri,permutevec,flipflags] = align_ijk2xyz(mri);
  
  Va = ft_write_volume([cfg.name,'.img'], mri.anatomy, 'transform', mri.transform, 'spmversion', cfg.spmversion);

  % spm is quite noisy, prevent the warnings from displaying on screen
  % warning off;

  if strcmpi(cfg.spmversion, 'spm2'),
    % set the spm segmentation defaults (from /opt/spm2/spm_defaults.m script)
    defaults.segment.estimate.priors = str2mat(...
      fullfile(spm('Dir'),'apriori','gray.mnc'),...
      fullfile(spm('Dir'),'apriori','white.mnc'),...
      fullfile(spm('Dir'),'apriori','csf.mnc'));
    defaults.segment.estimate.reg    = 0.01;
    defaults.segment.estimate.cutoff = 30;
    defaults.segment.estimate.samp   = 3;
    defaults.segment.estimate.bb     =  [[-88 88]' [-122 86]' [-60 95]'];
    defaults.segment.estimate.affreg.smosrc = 8;
    defaults.segment.estimate.affreg.regtype = 'mni';
    %defaults.segment.estimate.affreg.weight = fullfile(spm('Dir'),'apriori','brainmask.mnc'); 
    defaults.segment.estimate.affreg.weight = '';
    defaults.segment.write.cleanup   = 1;
    defaults.segment.write.wrt_cor   = 1;
    
    flags = defaults.segment;

    % perform the segmentation
    fprintf('performing the segmentation on the specified volume\n');
    spm_segment(Va,cfg.template,flags);
    Vtmp = spm_vol({[cfg.name,'_seg1.img'];...
                    [cfg.name,'_seg2.img'];...
                    [cfg.name,'_seg3.img']});

    % read the resulting volumes
    for j = 1:3
      vol = spm_read_vols(Vtmp{j});
      Vtmp{j}.dat = vol;
      V(j) = struct(Vtmp{j});
    end

    % keep or remove the files according to the configuration
    if strcmp(cfg.keepintermediate,'no'),
      delete([cfg.name,'.img']);
      delete([cfg.name,'.hdr']);
      delete([cfg.name,'.mat']);
    end
    if strcmp(cfg.write,'no'),
       delete([cfg.name,'_seg1.hdr']);
       delete([cfg.name,'_seg2.hdr']);
       delete([cfg.name,'_seg3.hdr']);
       delete([cfg.name,'_seg1.img']);
       delete([cfg.name,'_seg2.img']);
       delete([cfg.name,'_seg3.img']);
       delete([cfg.name,'_seg1.mat']);
       delete([cfg.name,'_seg2.mat']);
       delete([cfg.name,'_seg3.mat']);
    elseif strcmp(cfg.write,'yes'),
      for j = 1:3
        % put the original transformation-matrix in the headers
        V(j).mat = original.transform;
        % write the updated header information back to file ???????
        V(j) = spm_create_vol(V(j));
      end
    end

  elseif strcmpi(cfg.spmversion, 'spm8'),
    
    fprintf('performing the segmentation on the specified volume\n');
    if isfield(cfg, 'tpm')
      px.tpm   = cfg.tpm;
      p        = spm_preproc(Va, px);
    else
      p        = spm_preproc(Va);
    end
    [po,pin] = spm_prep2sn(p);
    
    % I took these settings from a batch
    opts     = [];
    opts.GM  = [0 0 1];
    opts.WM  = [0 0 1];
    opts.CSF = [0 0 1];
    opts.biascor = 1;
    opts.cleanup = 0;
    spm_preproc_write(po, opts);
     
    [pathstr,name,ext] = fileparts(cfg.name);
    Vtmp = spm_vol({fullfile(pathstr,['c1',name,'.img']);...
                    fullfile(pathstr,['c2',name,'.img']);...
                    fullfile(pathstr,['c3',name,'.img'])});

    % read the resulting volumes
    for j = 1:3
      vol = spm_read_vols(Vtmp{j});
      Vtmp{j}.dat = vol;
      V(j) = struct(Vtmp{j});
    end

    % keep or remove the files according to the configuration
    if strcmp(cfg.keepintermediate,'no'),
      delete([cfg.name,'.img']);
      delete([cfg.name,'.hdr']);
      if exist([cfg.name,'.mat'], 'file'), 
        delete([cfg.name,'.mat']);
      end %does not always exist
    end
    
    % keep the files written to disk or remove them
    % FIXME check whether this works at all
    if strcmp(cfg.write,'no'),
       delete(fullfile(pathstr,['c1',name,'.hdr'])); %FIXME this may not be needed in spm8
       delete(fullfile(pathstr,['c1',name,'.img']));
       delete(fullfile(pathstr,['c2',name,'.hdr']));
       delete(fullfile(pathstr,['c2',name,'.img']));
       delete(fullfile(pathstr,['c3',name,'.hdr']));
       delete(fullfile(pathstr,['c3',name,'.img']));
       delete(fullfile(pathstr,['m',name,'.hdr']));
       delete(fullfile(pathstr,['m',name,'.img']));
    elseif strcmp(cfg.write,'yes'),
      for j = 1:3
        % put the original transformation-matrix in the headers
        V(j).mat = original.transform;
        % write the updated header information back to file ???????
        V(j) = spm_create_vol(V(j));
      end
    end
    
  end

  % collect the results
  segment.dim       = size(V(1).dat);
  segment.dim       = segment.dim(:)';    % enforce a row vector
  segment.transform = original.transform; % use the original transform
  segment.coordsys  = original.coordsys;  % use the original coordsys
  if isfield(mri, 'unit')
    segment.unit = mri.unit;
  end
  segment.gray      = V(1).dat;
  if length(V)>1, segment.white     = V(2).dat; end
  if length(V)>2, segment.csf       = V(3).dat; end
  segment.anatomy   = mri.anatomy;

  % flip the volumes back according to the changes introduced by align_ijk2xyz
  for k = 1:3
    if flipflags(k)
      segment.gray    = flipdim(segment.gray, k);
      segment.anatomy = flipdim(segment.anatomy, k);
      if isfield(segment, 'white'), segment.white = flipdim(segment.white, k); end
      if isfield(segment, 'csf'),   segment.csf   = flipdim(segment.csf, k);   end
    end
  end

  if ~all(permutevec == [1 2 3])
    segment.gray    = ipermute(segment.gray,    permutevec);
    segment.anatomy = ipermute(segment.anatomy, permutevec);
    if isfield(segment, 'white'), segment.white = ipermute(segment.white, permutevec); end
    if isfield(segment, 'csf'),   segment.csf   = ipermute(segment.csf,   permutevec); end
    segment.dim  = size(segment.gray);
  end

else
  % rename the data
  segment = mri;
  clear mri;  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% now the data contains the tissue probability maps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create the requested output fields
removefields = {'anatomy' 'csf' 'gray' 'white'};
for k = 1:numel(cfg.output)
  dosmooth = isfinite(cfg.smooth(k));
  dothresh = isfinite(cfg.threshold(k));
  switch cfg.output{k}
    case 'tpm'
      % do nothing
      if dosmooth, warning_once('You requested the tpms to be smoothed, which is not possible because does not make sense');      end
      if dothresh, warning_once('You requested the tpms to be thresholded, which is not possible because it does not make sense');end
      removefields = intersect(removefields, {'anatomy'});

    case 'skullstrip'
      % create brain surface from tissue probability maps
      fprintf('creating brainmask\n');
      brain = segment.gray + segment.white + segment.csf;
      if dosmooth, brain = dosmoothing(brain,  cfg.smooth(k), 'brainmask'); end
      if dothresh, brain = threshold(brain, cfg.threshold(k), 'brainmask'); end
      
      fprintf('creating skullstripped anatomy\n');
      brain = cast(brain, class(segment.anatomy));
      segment.anatomy = segment.anatomy.*brain;
      removefields    = intersect(removefields, {'gray' 'white' 'csf'});
      clear brain;      
  
    case 'brain'
      % create brain surface from tissue probability maps
      fprintf('creating brainmask\n');
      brain = segment.gray + segment.white + segment.csf;
      if dosmooth, brain = dosmoothing(brain,  cfg.smooth(k), 'brainmask'); end
      if dothresh, brain = threshold(brain, cfg.threshold(k), 'brainmask'); end
      segment.brain = brain>0;
      removefields  = intersect(removefields, {'gray' 'white' 'csf' 'anatomy'});
      clear brain;      

    case 'skull'
      % create brain surface from tissue probability maps
      fprintf('creating brainmask\n');
      brain = segment.gray + segment.white + segment.csf;
      if dosmooth, brain = dosmoothing(brain,  cfg.smooth(k), 'brainmask'); end
      if dothresh, brain = threshold(brain, cfg.threshold(k), 'brainmask'); end
      
      % create skull from brain mask FIXME check this (e.g. strel_bol) 
      fprintf('creating skullmask\n');
      braindil      = imdilate(brain>0, strel_bol(6));
      segment.skull = braindil & ~brain;
      removefields  = intersect(removefields, {'gray' 'white' 'csf' 'anatomy'});
      clear brain braindil; 

    case 'scalp'
      % create scalp surface from anatomy
      fprintf('creating scalpmask\n');
      anatomy = segment.anatomy;
      anatomy(1) = anatomy(1)+1-1; % ensure that spm's smoothing does not affect
      % the original segment.anatomy
      if dosmooth, anatomy = dosmoothing(anatomy, cfg.smooth(k), 'anatomy'); end
      if dothresh, anatomy = threshold(anatomy,  cfg.threshold(k), 'anatomy'); end
      % fill in the holes
      anatomy = fill(anatomy); 

      segment.scalp = anatomy>0;
      removefields  = intersect(removefields, {'gray' 'white' 'csf' 'anatomy'});
      clear anatomy;    

    otherwise
      error('unknown output %s requested', cfg.output);
  end
end

% remove unnecessary fields
for k = 1:numel(removefields)
  try, segment = rmfield(segment, removefields{k}); end
end

% accessing this field here is needed for the configuration tracking
% by accessing it once, it will not be removed from the output cfg
cfg.outputfile;

% get the output cfg
cfg = ft_checkconfig(cfg, 'trackconfig', 'off', 'checksize', 'yes'); 

% add version information to the configuration
cfg.version.name = mfilename('fullpath');
cfg.version.id = '$Id: ft_volumesegment.m 3735 2011-06-29 08:22:09Z jorhor $';

% add information about the Matlab version used to the configuration
cfg.callinfo.matlab = version();

% remember the configuration details of the input data
if isfield(segment, 'cfg'),
  cfg.previous = segment.cfg;
end

% remember the exact configuration details in the output 
segment.cfg = cfg;

% the output data should be saved to a MATLAB file
if ~isempty(cfg.outputfile)
  savevar(cfg.outputfile, 'segment', segment); % use the variable name "segment" in the output file
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [output] = dosmoothing(input, fwhm, str)

fprintf('smoothing %s with a %d-voxel FWHM kernel\n', str, fwhm);
spm_smooth(input, input, fwhm);
output = input;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [output] = threshold(input, thresh, str)
  
fprintf('thresholding %s at a relative threshold of %0.3f\n', str, thresh);
    
% mask by taking the negative of the brain, thus ensuring
% that no holes are within the compartment and do a two-pass 
% approach to eliminate potential vitamin E capsules etc.

output   = double(input>(thresh*max(input(:))));
[tmp, N] = spm_bwlabel(output, 6);
for k = 1:N
  n(k,1) = sum(tmp(:)==k);
end
output   = double(tmp~=find(n==max(n))); clear tmp;
[tmp, N] = spm_bwlabel(output, 6);
for k = 1:N
  m(k,1) = sum(tmp(:)==k);
end
output   = double(tmp~=find(m==max(m))); clear tmp;

function [output] = fill(input)
  output = input;
  dim = size(input);
  for i=1:dim(2)
    slice=squeeze(input(:,i,:));
    im = imfill(slice,8,'holes');
    output(:,i,:) = im;
  end
  