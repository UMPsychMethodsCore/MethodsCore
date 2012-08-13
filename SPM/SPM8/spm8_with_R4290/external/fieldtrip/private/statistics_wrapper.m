function [stat, cfg] = statistics_wrapper(cfg, varargin)

% STATISTICS_WRAPPER performs the selection of the biological data for
% timelock, frequency or source data and sets up the design vector or
% matrix.
%
% The specific configuration options for selecting timelock, frequency
% of source data are described in TIMELOCKSTATISTICS, FREQSTATISTICS and
% SOURCESTATISTICS, respectively.
%
% After selecting the data, control is passed on to a data-independent
% statistical subfunction that computes test statistics plus their associated
% significance probabilities and critical values under some null-hypothesis. The statistical
% subfunction that is called is STATISTICS_xxx, where cfg.method='xxx'. At
% this moment, we have implemented two statistical subfunctions:
% STATISTICS_ANALYTIC, which calculates analytic significance probabilities and critical
% values (exact or asymptotic), and STATISTICS_MONTECARLO, which calculates
% Monte-Carlo approximations of the significance probabilities and critical values.
%
% The specific configuration options for the statistical test are
% described in STATISTICS_xxx.

% This function depends on PREPARE_TIMEFREQ_DATA which has the following options:
% cfg.avgoverchan
% cfg.avgoverfreq
% cfg.avgovertime
% cfg.channel
% cfg.channelcmb
% cfg.datarepresentation (set in STATISTICS_WRAPPER cfg.datarepresentation = 'concatenated')
% cfg.frequency
% cfg.latency
% cfg.precision
% cfg.previous (set in STATISTICS_WRAPPER cfg.previous = [])
% cfg.version (id and name set in STATISTICS_WRAPPER)

% Copyright (C) 2005-2006, Robert Oostenveld
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
% $Id: statistics_wrapper.m 3056 2011-03-04 07:53:56Z jorhor $

% check if the input cfg is valid for this function
cfg = ft_checkconfig(cfg, 'renamed',     {'approach',   'method'});
cfg = ft_checkconfig(cfg, 'required',    {'method'});
cfg = ft_checkconfig(cfg, 'forbidden',   {'transform'});

% set the defaults
if ~isfield(cfg, 'channel'),              cfg.channel = 'all';                     end
if ~isfield(cfg, 'latency'),              cfg.latency = 'all';                     end
if ~isfield(cfg, 'frequency'),            cfg.frequency = 'all';                   end
if ~isfield(cfg, 'roi'),                  cfg.roi = [];                            end
if ~isfield(cfg, 'avgoverchan'),          cfg.avgoverchan = 'no';                  end
if ~isfield(cfg, 'avgovertime'),          cfg.avgovertime = 'no';                  end
if ~isfield(cfg, 'avgoverfreq'),          cfg.avgoverfreq = 'no';                  end
if ~isfield(cfg, 'avgoverroi'),           cfg.avgoverroi = 'no';                   end

% determine the type of the input and hence the output data
if ~exist('OCTAVE_VERSION')
  [s, i] = dbstack;
  if length(s)>1
    [caller_path, caller_name, caller_ext] = fileparts(s(2).name);
  else
    caller_path = '';
    caller_name = '';
    caller_ext  = '';
  end
  % evalin('caller', 'mfilename') does not work for Matlab 6.1 and 6.5
  istimelock = strcmp(caller_name,'ft_timelockstatistics');
  isfreq     = strcmp(caller_name,'ft_freqstatistics');
  issource   = strcmp(caller_name,'ft_sourcestatistics');
else
  % cannot determine the calling function in Octave, try looking at the
  % data instead
  istimelock  = isfield(varargin{1},'time') && ~isfield(varargin{1},'freq') && isfield(varargin{1},'avg');
  isfreq      = isfield(varargin{1},'time') && isfield(varargin{1},'freq');
  issource    = isfield(varargin{1},'pos') || isfield(varargin{1},'transform');
end

if (istimelock+isfreq+issource)~=1
  error('Could not determine the type of the input data');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% collect the biological data (the dependent parameter)
%  and the experimental design (the independent parameter)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if issource

  % test that all source inputs have the same dimensions and are spatially aligned
  for i=2:length(varargin)
    if isfield(varargin{1}, 'dim') && (length(varargin{i}.dim)~=length(varargin{1}.dim) || ~all(varargin{i}.dim==varargin{1}.dim))
      error('dimensions of the source reconstructions do not match, use NORMALISEVOLUME first');
    end
    if isfield(varargin{1}, 'pos') && (length(varargin{i}.pos(:))~=length(varargin{1}.pos(:)) || ~all(varargin{i}.pos(:)==varargin{1}.pos(:)))
      error('grid locations of the source reconstructions do not match, use NORMALISEVOLUME first');
    end
    if isfield(varargin{1}, 'transform') && ~all(varargin{i}.transform(:)==varargin{1}.transform(:))
      error('spatial coordinates of the source reconstructions do not match, use NORMALISEVOLUME first');
    end
  end

  Nsource = length(varargin);
  Nvoxel  = length(varargin{1}.inside) + length(varargin{1}.outside);

  if ~isempty(cfg.roi)
    if ischar(cfg.roi)
      cfg.roi = {cfg.roi};
    end
    % the source representation should specify the position of each voxel in MNI coordinates
    x = varargin{1}.pos(:,1);  % this is from left (negative) to right (positive)
    % determine the mask to restrict the subsequent analysis
    % process each of the ROIs, and optionally also left and/or right seperately
    roimask  = {};
    roilabel = {};
    for i=1:length(cfg.roi)
      tmpcfg.roi = cfg.roi{i};
      tmpcfg.inputcoord = cfg.inputcoord;
      tmpcfg.atlas = cfg.atlas;
      tmp = volumelookup(tmpcfg, varargin{1});
      if strcmp(cfg.avgoverroi, 'no') && ~isfield(cfg, 'hemisphere')
        % no reason to deal with seperated left/right hemispheres
        cfg.hemisphere = 'combined';
      end

      if     strcmp(cfg.hemisphere, 'left')
        tmp(x>=0)    = 0;  % exclude the right hemisphere
        roimask{end+1}  = tmp;
        roilabel{end+1} = ['Left '  cfg.roi{i}];

      elseif strcmp(cfg.hemisphere, 'right')
        tmp(x<=0)    = 0;  % exclude the right hemisphere
        roimask{end+1}  = tmp;
        roilabel{end+1} = ['Right ' cfg.roi{i}];

      elseif strcmp(cfg.hemisphere, 'both')
        % deal seperately with the voxels on the left and right side of the brain
        tmpL = tmp; tmpL(x>=0) = 0;  % exclude the right hemisphere
        tmpR = tmp; tmpR(x<=0) = 0;  % exclude the left hemisphere
        roimask{end+1}  = tmpL;
        roimask{end+1}  = tmpR;
        roilabel{end+1} = ['Left '  cfg.roi{i}];
        roilabel{end+1} = ['Right ' cfg.roi{i}];
        clear tmpL tmpR

      elseif strcmp(cfg.hemisphere, 'combined')
        % all voxels of the ROI can be combined
        roimask{end+1}  = tmp;
        roilabel{end+1} = cfg.roi{i};

      else
        error('incorrect specification of cfg.hemisphere');
      end
      clear tmp
    end % for each roi

    % note that avgoverroi=yes is implemented differently at a later stage
    % avgoverroi=no is implemented using the inside/outside mask
    if strcmp(cfg.avgoverroi, 'no')
      for i=2:length(roimask)
        % combine them all in the first mask
        roimask{1} = roimask{1} | roimask{i};
      end
      roimask = roimask{1};  % only keep the combined mask
      % the source representation should have an inside and outside vector containing indices
      sel = find(~roimask);
      varargin{1}.inside  = setdiff(varargin{1}.inside, sel);
      varargin{1}.outside = union(varargin{1}.outside, sel);
      clear roimask roilabel
    end % if avgoverroi=no
  end

  % get the source parameter on which the statistic should be evaluated
  if strcmp(cfg.parameter, 'mom') && isfield(varargin{1}, 'avg') && isfield(varargin{1}.avg, 'csdlabel') && isfield(varargin{1}, 'cumtapcnt')
    [dat, cfg] = get_source_pcc_mom(cfg, varargin{:});
  elseif strcmp(cfg.parameter, 'mom') && isfield(varargin{1}, 'avg') && ~isfield(varargin{1}.avg, 'csdlabel')
    [dat, cfg] = get_source_lcmv_mom(cfg, varargin{:});
  elseif isfield(varargin{1}, 'trial')
    [dat, cfg] = get_source_trial(cfg, varargin{:});
  else
    [dat, cfg] = get_source_avg(cfg, varargin{:});
  end
  cfg.dimord = 'voxel';

  % note that avgoverroi=no is implemented differently at an earlier stage
  if strcmp(cfg.avgoverroi, 'yes')
    tmp = zeros(length(roimask), size(dat,2));
    for i=1:length(roimask)
      % the data only reflects those points that are inside the brain,
      % the atlas-based mask reflects points inside and outside the brain
      roi = roimask{i}(varargin{1}.inside);
      tmp(i,:) = mean(dat(roi,:), 1);
    end
    % replace the original data with the average over each ROI
    dat = tmp;
    clear tmp roi roimask
    % remember the ROIs
    cfg.dimord = 'roi';
  end

elseif isfreq || istimelock
  % get the ERF/TFR data by means of PREPARE_TIMEFREQ_DATA
  cfg.datarepresentation = 'concatenated';
  [cfg, data] = prepare_timefreq_data(cfg, varargin{:});
  cfg = rmfield(cfg, 'datarepresentation');

  dim = size(data.biol);
  if length(dim)<3
    % seems to be singleton frequency and time dimension
    dim(3)=1;
    dim(4)=1;
  elseif length(dim)<4
    % seems to be singleton time dimension
    dim(4)=1;
  end
  cfg.dimord = 'chan_freq_time';

  % the dimension of the original data (excluding the replication dimension) has to be known for clustering
  cfg.dim = dim(2:end);
  % all dimensions have to be concatenated except the replication dimension and the data has to be transposed
  dat = transpose(reshape(data.biol, dim(1), prod(dim(2:end))));

  % remove to save some memory
  data.biol = [];

  % add gradiometer/electrode information to the configuration
  if ~isfield(cfg,'neighbours') && isfield(cfg, 'correctm') && strcmp(cfg.correctm, 'cluster')
    cfg.neighbours = ft_neighbourselection(cfg,varargin{1});
  end

end

% get the design from the information in cfg and data.
if ~isfield(cfg,'design')
  cfg.design = data.design;
  [cfg] = prepare_design(cfg);
end

if size(cfg.design,2)~=size(dat,2)
  cfg.design = transpose(cfg.design);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute the statistic, using the data-independent statistical subfunction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% determine the function handle to the intermediate-level statistics function
if exist(['statistics_' cfg.method])
  statmethod = str2func(['statistics_' cfg.method]);
else
  error(sprintf('could not find the corresponding function for cfg.method="%s"\n', cfg.method));
end
fprintf('using "%s" for the statistical testing\n', func2str(statmethod));

% check that the design completely describes the data
if size(dat,2) ~= size(cfg.design,2)
  error('the size of the design matrix does not match the number of observations in the data');
end

% determine the number of output arguments
try
  % the nargout function in Matlab 6.5 and older does not work on function handles
  num = nargout(statmethod);
catch
  num = 1;
end

% perform the statistical test 
if strcmp(func2str(statmethod),'statistics_montecarlo') % because statistics_montecarlo (or to be precise, clusterstat) requires to know whether it is getting source data, 
                                                        % the following (ugly) work around is necessary                                             
  if num>1
    [stat, cfg] = statmethod(cfg, dat, cfg.design, 'issource',issource);
  else
    [stat] = statmethod(cfg, dat, cfg.design, 'issource', issource);
  end
else
  if num>1
    [stat, cfg] = statmethod(cfg, dat, cfg.design);
  else
    [stat] = statmethod(cfg, dat, cfg.design);
  end
end

if isstruct(stat)
  % the statistical output contains multiple elements, e.g. F-value, beta-weights and probability
  statfield = fieldnames(stat);
else
  % only the probability was returned as a single matrix, reformat into a structure
  dum = stat; stat = []; % this prevents a Matlab warning that appears from release 7.0.4 onwards
  stat.prob = dum;
  statfield = fieldnames(stat);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% add descriptive information to the output and rehape into the input format
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if issource
  if isempty(cfg.roi) || strcmp(cfg.avgoverroi, 'no')
    % remember the definition of the volume, assume that they are identical for all input arguments
    try stat.dim       = varargin{1}.dim;        end
    try stat.xgrid     = varargin{1}.xgrid;      end
    try stat.ygrid     = varargin{1}.ygrid;      end
    try stat.zgrid     = varargin{1}.zgrid;      end
    try stat.inside    = varargin{1}.inside;     end
    try stat.outside   = varargin{1}.outside;    end
    try stat.pos       = varargin{1}.pos;        end
    try stat.transform = varargin{1}.transform;  end
  else
    stat.inside  = 1:length(roilabel);
    stat.outside = [];
    stat.label   = roilabel(:);
  end
  for i=1:length(statfield)
    tmp = getsubfield(stat, statfield{i});
    if isfield(varargin{1}, 'inside') && numel(tmp)==length(varargin{1}.inside)
      % the statistic was only computed on voxels that are inside the brain
      % sort the inside and outside voxels back into their original place
      if islogical(tmp)
        tmp(varargin{1}.inside)  = tmp;
        tmp(varargin{1}.outside) = false;
      else
        tmp(varargin{1}.inside)  = tmp;
        tmp(varargin{1}.outside) = nan;
      end
    end
    if numel(tmp)==prod(varargin{1}.dim)
      % reshape the statistical volumes into the original format
      stat = setsubfield(stat, statfield{i}, reshape(tmp, varargin{1}.dim));
    end
  end
else
  haschan    = isfield(data, 'label');    % this one remains relevant, even after averaging over channels
  haschancmb = isfield(data, 'labelcmb'); % this one remains relevant, even after averaging over channels
  hasfreq = strcmp(cfg.avgoverfreq, 'no') && ~any(isnan(data.freq));
  hastime = strcmp(cfg.avgovertime, 'no') && ~any(isnan(data.time));
  stat.dimord = '';

  if haschan
    stat.dimord = [stat.dimord 'chan_'];
    stat.label  = data.label;
    chandim = dim(2);
  elseif haschancmb
    stat.dimord   = [stat.dimord 'chancmb_'];
    stat.labelcmb = data.labelcmb;
    chandim = dim(2);
  end

  if hasfreq
    stat.dimord = [stat.dimord 'freq_'];
    stat.freq   = data.freq;
    freqdim = dim(3);
  end

  if hastime
    stat.dimord = [stat.dimord 'time_'];
    stat.time   = data.time;
    timedim = dim(4);
  end

  if ~isempty(stat.dimord)
    % remove the last '_'
    stat.dimord = stat.dimord(1:(end-1));
  end

  for i=1:length(statfield)
    try
      % reshape the fields that have the same dimension as the input data
      if     strcmp(stat.dimord, 'chan')
        stat = setfield(stat, statfield{i}, reshape(getfield(stat, statfield{i}), [chandim 1]));
      elseif strcmp(stat.dimord, 'chan_time')
        stat = setfield(stat, statfield{i}, reshape(getfield(stat, statfield{i}), [chandim timedim]));
      elseif strcmp(stat.dimord, 'chan_freq')
        stat = setfield(stat, statfield{i}, reshape(getfield(stat, statfield{i}), [chandim freqdim]));
      elseif strcmp(stat.dimord, 'chan_freq_time')
        stat = setfield(stat, statfield{i}, reshape(getfield(stat, statfield{i}), [chandim freqdim timedim]));
      elseif strcmp(stat.dimord, 'chancmb_time')
        stat = setfield(stat, statfield{i}, reshape(getfield(stat, statfield{i}), [chandim timedim]));
      elseif strcmp(stat.dimord, 'chancmb_freq')
        stat = setfield(stat, statfield{i}, reshape(getfield(stat, statfield{i}), [chandim freqdim]));
      elseif strcmp(stat.dimord, 'chancmb_freq_time')
        stat = setfield(stat, statfield{i}, reshape(getfield(stat, statfield{i}), [chandim freqdim timedim]));
      elseif strcmp(stat.dimord, 'time')
        stat = setfield(stat, statfield{i}, reshape(getfield(stat, statfield{i}), [1 timedim]));
      elseif strcmp(stat.dimord, 'freq')
        stat = setfield(stat, statfield{i}, reshape(getfield(stat, statfield{i}), [1 freqdim]));
      elseif strcmp(stat.dimord, 'freq_time')
        stat = setfield(stat, statfield{i}, reshape(getfield(stat, statfield{i}), [freqdim timedim]));
      end
    end
  end
end

return % statistics_wrapper main()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION for extracting the data of interest
% data resemples PCC beamed source reconstruction, multiple trials are coded in mom
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dat, cfg] = get_source_pcc_mom(cfg, varargin)
Nsource = length(varargin);
Nvoxel  = length(varargin{1}.inside) + length(varargin{1}.outside);
Ninside = length(varargin{1}.inside);
dim     = varargin{1}.dim;
for i=1:Nsource
  dipsel  = find(strcmp(varargin{i}.avg.csdlabel, 'scandip'));
  ntrltap = sum(varargin{i}.cumtapcnt);
  dat{i}  = zeros(Ninside, ntrltap);
  for j=1:Ninside
    k = varargin{1}.inside(j);
    dat{i}(j,:) = reshape(varargin{i}.avg.mom{k}(dipsel,:), 1, ntrltap);
  end
end
% concatenate the data matrices of the individual input arguments
dat = cat(2, dat{:});
% remember the dimension of the source data
cfg.dim = dim;
% remember which voxels are inside the brain
cfg.inside = varargin{1}.inside;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION for extracting the data of interest
% data resemples LCMV beamed source reconstruction, mom contains timecourse
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dat, cfg] = get_source_lcmv_mom(cfg, varargin)
Nsource = length(varargin);
Nvoxel  = length(varargin{1}.inside) + length(varargin{1}.outside);
Ntime   = length(varargin{1}.avg.mom{varargin{1}.inside(1)});
Ninside = length(varargin{1}.inside);
dim     = [varargin{1}.dim Ntime];
dat     = zeros(Ninside*Ntime, Nsource);
for i=1:Nsource
  % collect the 4D data of this input argument
  tmp = nan*zeros(Ninside, Ntime);
  for j=1:Ninside
    k = varargin{1}.inside(j);
    tmp(j,:) = reshape(varargin{i}.avg.mom{k}, 1, dim(4));
  end
  dat(:,i) = tmp(:);
end
% remember the dimension of the source data
cfg.dim = dim;
% remember which voxels are inside the brain
cfg.inside = varargin{1}.inside;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION for extracting the data of interest
% data contains single-trial or single-subject source reconstructions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dat, cfg] = get_source_trial(cfg, varargin)
Nsource = length(varargin);
Nvoxel  = length(varargin{1}.inside) + length(varargin{1}.outside);

for i=1:Nsource
  Ntrial(i) = length(varargin{i}.trial);
end
k = 1;
for i=1:Nsource
  for j=1:Ntrial(i)
    tmp = getsubfield(varargin{i}.trial(j), cfg.parameter);
    if ~iscell(tmp),
      %dim = size(tmp);
      dim = [Nvoxel 1];
    else
      dim = [Nvoxel size(tmp{varargin{i}.inside(1)})];
    end
    if i==1 && j==1 && numel(tmp)~=Nvoxel,
      warning('the input-data contains more entries than the number of voxels in the volume, the data will be concatenated');
      dat    = zeros(prod(dim), sum(Ntrial)); %FIXME this is old code should be removed
    elseif i==1 && j==1 && iscell(tmp),
      warning('the input-data contains more entries than the number of voxels in the volume, the data will be concatenated');
      dat    = zeros(Nvoxel*numel(tmp{varargin{i}.inside(1)}), sum(Ntrial));
    elseif i==1 && j==1,
      dat = zeros(Nvoxel, sum(Ntrial));
    end
    if ~iscell(tmp),
      dat(:,k) = tmp(:);
    else
      Ninside   = length(varargin{i}.inside);
      %tmpvec    = (varargin{i}.inside-1)*prod(size(tmp{varargin{i}.inside(1)}));
      tmpvec    = varargin{i}.inside;
      insidevec = [];
      for m = 1:numel(tmp{varargin{i}.inside(1)})
        insidevec = [insidevec; tmpvec(:)+(m-1)*Nvoxel];
      end
      insidevec = insidevec(:)';
      tmpdat  = reshape(permute(cat(3,tmp{varargin{1}.inside}), [3 1 2]), [Ninside numel(tmp{varargin{1}.inside(1)})]);
      dat(insidevec, k) = tmpdat(:);
    end
    % add original dimensionality of the data to the configuration, is required for clustering
    %FIXME: this was obviously wrong, because often trial-data is one-dimensional, so no dimensional information is present
    %cfg.dim = dim(2:end);
    k = k+1;
  end
end
if isfield(varargin{1}, 'inside')
  fprintf('only selecting voxels inside the brain for statistics (%.1f%%)\n', 100*length(varargin{1}.inside)/prod(varargin{1}.dim));
  for j=prod(dim(2:end)):-1:1
    dat((j-1).*dim(1) + varargin{1}.outside, :) = [];
  end
end
% remember the dimension of the source data
if ~isfield(cfg, 'dim')
  warning('for clustering on trial-based data you explicitly have to specify cfg.dim');
end
% remember which voxels are inside the brain
cfg.inside = varargin{1}.inside;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION for extracting the data of interest
% get the average source reconstructions, the repetitions are in multiple input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dat, cfg] = get_source_avg(cfg, varargin)
Nsource = length(varargin);
Nvoxel  = length(varargin{1}.inside) + length(varargin{1}.outside);
dim     = varargin{1}.dim;
dat = zeros(Nvoxel, Nsource);
for i=1:Nsource
  tmp = getsubfield(varargin{i}, cfg.parameter);
  dat(:,i) = tmp(:);
end
if isfield(varargin{1}, 'inside')
  fprintf('only selecting voxels inside the brain for statistics (%.1f%%)\n', 100*length(varargin{1}.inside)/prod(varargin{1}.dim));
  dat = dat(varargin{1}.inside,:);
end
% remember the dimension of the source data
cfg.dim = dim;
% remember which voxels are inside the brain
cfg.inside = varargin{1}.inside;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION for creating a design matrix
% should be called in the code above, or in prepare_design
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cfg] = get_source_design_pcc_mom(cfg, varargin)
% should be implemented

function [cfg] = get_source_design_lcmv_mom(cfg, varargin)
% should be implemented

function [cfg] = get_source_design_trial(cfg, varargin)
% should be implemented

function [cfg] = get_source_design_avg(cfg, varargin)
% should be implemented