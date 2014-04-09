function [data] = ft_rejectvisual(cfg, data);

% FT_REJECTVISUAL shows the preprocessed data in all channels and/or trials to
% allow the user to make a visual selection of the data that should be
% rejected. The data can be displayed in a "summary" mode, in which case
% the variance (or another metric) in each channel and each trial is
% computed. Alternatively, all channels can be shown at once allowing
% paging through the trials, or all trials can be shown, allowing paging
% through the channels.
%
% Use as
%   [data] = ft_rejectvisual(cfg, data)
%
% The configuration can contain
%   cfg.channel     = Nx1 cell-array with selection of channels (default = 'all'),
%                     see FT_CHANNELSELECTION for details
%   cfg.trials      = 'all' or a selection given as a 1xN vector (default = 'all')
%   cfg.latency     = [begin end] in seconds, or 'minperlength', 'maxperlength',
%                     'prestim', 'poststim' (default = 'maxperlength')
%   cfg.method      = string, describes how the data should be shown, this can be
%                     'summary'  show a single number for each channel and trial (default)
%                     'channel'  show the data per channel, all trials at once
%                     'trial'    show the data per trial, all channels at once
%   cfg.keepchannel = string, determines how to deal with channels that are
%                     not selected, can be
%                     'no'     completely remove unselected channels from the data (default)
%                     'yes'    keep unselected channels in the output data
%                     'nan'    fill the channels that are unselected with NaNs
%   cfg.metric      = string, describes the metric that should be computed in summary mode
%                     for each channel in each trial, can be
%                     'var'       variance within each channel (default)
%                     'min'       minimum value in each channel
%                     'max'       maximum value each channel
%                     'maxabs'    maximum absolute value in each channel
%                     'range'     range from min to max in each channel
%                     'kurtosis'  kurtosis, i.e. measure of peakedness of the amplitude distribution
%                     'zvalue'    mean and std computed over all time and trials, per channel
%   cfg.alim        = value that determines the amplitude scaling for the
%                     channel and trial display, if empty then the amplitude
%                     scaling is automatic (default = [])
%   cfg.eegscale    = number, scaling to apply to the EEG channels prior to display
%   cfg.eogscale    = number, scaling to apply to the EOG channels prior to display
%   cfg.ecgscale    = number, scaling to apply to the ECG channels prior to display
%   cfg.megscale    = number, scaling to apply to the MEG channels prior to display
%
% The scaling to the EEG, EOG, ECG and MEG channels is optional and can
% be used to bring the absolute numbers of the different channel types in
% the same range (e.g. fT and uV). The channel types are determined from
% the input data using FT_CHANNELSELECTION.
%
% Optionally, the raw data is preprocessed (filtering etc.) prior to
% displaying it or prior to computing the summary metric. The
% preprocessing and the selection of the latency window is NOT applied
% to the output data.
%
% The following settings are usefull for identifying EOG artifacts:
%   cfg.bpfilter    = 'yes'
%   cfg.bpfilttype  = 'but'
%   cfg.bpfreq      = [1 15]
%   cfg.bpfiltord   = 4
%   cfg.rectify     = 'yes'
%
% The following settings are usefull for identifying muscle artifacts:
%   cfg.bpfilter    = 'yes'
%   cfg.bpfreq      = [110 140]
%   cfg.bpfiltord   = 10
%   cfg.bpfilttype  = 'but'
%   cfg.rectify     = 'yes'
%   cfg.boxcar      = 0.2
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
% See also FT_REJECTARTIFACT, FT_REJECTCOMPONENT

% Undocumented local options:
% cfg.feedback
%
% This function depends on PREPROC which has the following options:
% cfg.absdiff
% cfg.demean
% cfg.baselinewindow
% cfg.boxcar
% cfg.bpfilter
% cfg.bpfiltord
% cfg.bpfilttype
% cfg.bpfreq
% cfg.derivative
% cfg.detrend
% cfg.dftfilter
% cfg.dftfreq
% cfg.hilbert
% cfg.hpfilter
% cfg.hpfiltord
% cfg.hpfilttype
% cfg.hpfreq
% cfg.implicitref
% cfg.lnfilter
% cfg.lnfiltord
% cfg.lnfreq
% cfg.lpfilter
% cfg.lpfiltord
% cfg.lpfilttype
% cfg.lpfreq
% cfg.medianfilter
% cfg.medianfiltord
% cfg.rectify
% cfg.refchannel
% cfg.reref

% Copyright (C) 2005-2006, Markus Bauer, Robert Oostenveld
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
% $Id: ft_rejectvisual.m 3171 2011-03-18 12:18:44Z johzum $

% Undocumented options
% cfg.plotlayout = 'square' (default) or '1col', plotting every channel/trial under each other

ft_defaults

cfg = ft_checkconfig(cfg, 'trackconfig', 'on');

if ~isfield(cfg, 'channel'),     cfg.channel = 'all';          end
if ~isfield(cfg, 'trials'),      cfg.trials = 'all';           end
if ~isfield(cfg, 'latency'),     cfg.latency = 'maxperlength'; end
if ~isfield(cfg, 'keepchannel'), cfg.keepchannel = 'no';       end
if ~isfield(cfg, 'feedback'),    cfg.feedback = 'textbar';     end
if ~isfield(cfg, 'method'),      cfg.method = 'summary';       end
if ~isfield(cfg, 'alim'),        cfg.alim = [];                end
if ~isfield(cfg, 'eegscale'),    cfg.eegscale = [];            end
if ~isfield(cfg, 'eogscale'),    cfg.eogscale = [];            end
if ~isfield(cfg, 'ecgscale'),    cfg.ecgscale = [];            end
if ~isfield(cfg, 'megscale'),    cfg.megscale = [];            end
if ~isfield(cfg, 'inputfile'),   cfg.inputfile = [];           end
if ~isfield(cfg, 'outputfile'),  cfg.outputfile = [];          end
if ~isfield(cfg, 'plotlayout'),  cfg.plotlayout = 'square';    end


% load optional given inputfile as data
hasdata = (nargin>1);
if ~isempty(cfg.inputfile)
  % the input data should be read from file
  if hasdata
    error('cfg.inputfile should not be used in conjunction with giving input data to this function');
  else
    data = loadvar(cfg.inputfile, 'data');
  end
end

% check if the input data is valid for this function
data = ft_checkdata(data, 'datatype', 'raw', 'feedback', 'yes', 'hastrialdef', 'yes', 'hasoffset', 'yes');

% for backward compatibility
cfg = ft_checkconfig(cfg, 'renamedval',  {'metric',  'absmax',  'maxabs'});
cfg = ft_checkconfig(cfg, 'renamedval',  {'method',  'absmax',  'maxabs'});
if ~isfield(cfg, 'metric') && any(strcmp(cfg.method, {'var', 'min', 'max', 'maxabs', 'range'}))
  cfg.metric = cfg.method;
  cfg.method = 'summary';
end

if ~isfield(cfg, 'metric')
  cfg.metric = 'var';
end

% select trials of interest
if ~strcmp(cfg.trials, 'all')
  fprintf('selecting %d trials\n', length(cfg.trials));
  data = ft_selectdata(data, 'rpt', cfg.trials);
end

% determine the duration of each trial
for i=1:length(data.time)
  begsamplatency(i) = min(data.time{i});
  endsamplatency(i) = max(data.time{i});
end

% determine the latency window which is possible in all trials
minperlength = [max(begsamplatency) min(endsamplatency)];
maxperlength = [min(begsamplatency) max(endsamplatency)];

% latency window for averaging and variance computation is given in seconds
if (strcmp(cfg.latency, 'minperlength'))
  cfg.latency = [];
  cfg.latency(1) = minperlength(1);
  cfg.latency(2) = minperlength(2);
elseif (strcmp(cfg.latency, 'maxperlength'))
  cfg.latency = [];
  cfg.latency(1) = maxperlength(1);
  cfg.latency(2) = maxperlength(2);
elseif (strcmp(cfg.latency, 'prestim'))
  cfg.latency = [];
  cfg.latency(1) = maxperlength(1);
  cfg.latency(2) = 0;
elseif (strcmp(cfg.latency, 'poststim'))
  cfg.latency = [];
  cfg.latency(1) = 0;
  cfg.latency(2) = maxperlength(2);
end

% ensure that the preproc specific options are located in the cfg.preproc substructure
cfg = ft_checkconfig(cfg, 'createsubcfg',  {'preproc'});

% apply scaling to the selected channel types to equate the absolute numbers (i.e. fT and uV)
% make a seperate copy to prevent the original data from being scaled
tmpdata = data;
scaled  = 0;
if ~isempty(cfg.eegscale)
  scaled = 1;
  chansel = match_str(tmpdata.label, ft_channelselection('EEG', tmpdata.label));
  for i=1:length(tmpdata.trial)
    tmpdata.trial{i}(chansel,:) = tmpdata.trial{i}(chansel,:) .* cfg.eegscale;
  end
end
if ~isempty(cfg.eogscale)
  scaled = 1;
  chansel = match_str(tmpdata.label, ft_channelselection('EOG', tmpdata.label));
  for i=1:length(tmpdata.trial)
    tmpdata.trial{i}(chansel,:) = tmpdata.trial{i}(chansel,:) .* cfg.eogscale;
  end
end
if ~isempty(cfg.ecgscale)
  scaled = 1;
  chansel = match_str(tmpdata.label, ft_channelselection('ECG', tmpdata.label));
  for i=1:length(tmpdata.trial)
    tmpdata.trial{i}(chansel,:) = tmpdata.trial{i}(chansel,:) .* cfg.ecgscale;
  end
end
if ~isempty(cfg.megscale)
  scaled = 1;
  chansel = match_str(tmpdata.label, ft_channelselection('MEG', tmpdata.label));
  for i=1:length(tmpdata.trial)
    tmpdata.trial{i}(chansel,:) = tmpdata.trial{i}(chansel,:) .* cfg.megscale;
  end
end

if strcmp(cfg.method, 'channel')
  if scaled
    fprintf('showing the scaled data per channel, all trials at once\n');
  else
    fprintf('showing the data per channel, all trials at once\n');
  end
  [chansel, trlsel, cfg] = rejectvisual_channel(cfg, tmpdata);
elseif strcmp(cfg.method, 'trial')
  if scaled
    fprintf('showing the scaled per trial, all channels at once\n');
  else
    fprintf('showing the data per trial, all channels at once\n');
  end
  [chansel, trlsel, cfg] = rejectvisual_trial(cfg, tmpdata);
elseif strcmp(cfg.method, 'summary')
  if scaled
    fprintf('showing a summary of the scaled data for all channels and trials\n');
  else
    fprintf('showing a summary of the data for all channels and trials\n');
  end
  
  [chansel, trlsel, cfg] = rejectvisual_summary(cfg, tmpdata);
end

fprintf('%d trials marked as GOOD, %d trials marked as BAD\n', sum(trlsel), sum(~trlsel));
fprintf('%d channels marked as GOOD, %d channels marked as BAD\n', sum(chansel), sum(~chansel));

% trl is not specified in the function call, but the data is given ->
% try to locate the trial definition (trl) in the nested configuration
if isfield(data, 'sampleinfo')
   trl  = [data.sampleinfo data.offset(:)];
else
  % a trial definition is expected in each continuous data set
  trl  = [];
  warning('could not locate the trial definition ''trl'' in the data structure');
end

% construct an artifact matrix from the trl matrix
if ~isempty(trl)
  % remember the sample numbers (begin and end) of each trial and each artifact
  % updating the trl and creating a trlold makes it compatible with FT_REJECTARTIFACT
  cfg.artifact = trl(~trlsel,1:2);
  cfg.trl      = trl( trlsel,:);
else
  % since sample numbers are unknown, it is not possible to remember them here
  cfg.artifact = [];
  cfg.trl      = [];
end

% show the user which trials are removed
removed = find(~trlsel);
if ~isempty(removed)
  fprintf('the following trials were removed: ');
  for i=1:(length(removed)-1)
    fprintf('%d, ', removed(i));
  end
  fprintf('%d\n', removed(end));
else
  fprintf('no trials were removed\n');
end

% remove the selected trials from the data
data.time  = data.time(trlsel);
data.trial = data.trial(trlsel);
if isfield(data, 'trialinfo'), data.trialinfo = data.trialinfo(trlsel,:); end;
if isfield(data, 'sampleinfo'),  data.sampleinfo  = data.sampleinfo(trlsel,:);  end;

% remove the offset vector if present (only applies to datasets that have been preprocessed a long time ago)
if isfield(data, 'offset')
  data = rmfield(data, 'offset');
end

if ~all(chansel)
  switch cfg.keepchannel
    case 'no'
      % show the user which channels are removed
      removed = find(~chansel);
      fprintf('the following channels were removed: ');
      for i=1:(length(removed)-1)
        fprintf('%s, ', data.label{removed(i)});
      end
      fprintf('%s\n', data.label{removed(end)});
      
      % remove channels that are not selected
      for i=1:length(data.trial)
        data.trial{i} = data.trial{i}(chansel,:);
      end
      data.label = data.label(chansel);
    case 'nan'
      % show the user which channels are removed
      removed = find(~chansel);
      fprintf('the following channels were filled with NANs: ');
      for i=1:(length(removed)-1)
        fprintf('%s, ', data.label{removed(i)});
      end
      fprintf('%s\n', data.label{removed(end)});
      
      % fill the data from the bad channels with nans
      for i=1:length(data.trial)
        data.trial{i}(~chansel,:) = nan;
      end
    case 'yes'
      % keep all channels, also when they are not selected
  end
end

cfg.outputfile;

% get the output cfg
cfg = ft_checkconfig(cfg, 'trackconfig', 'off', 'checksize', 'yes');

% add version information to the configuration
cfg.version.name = mfilename('fullpath');
cfg.version.id = '$Id: ft_rejectvisual.m 3171 2011-03-18 12:18:44Z johzum $';

% add information about the Matlab version used to the configuration
cfg.version.matlab = version();

% remember the configuration details of the input data
try, cfg.previous = data.cfg; end

% remember the exact configuration details in the output
data.cfg = cfg;

% the output data should be saved to a MATLAB file
if ~isempty(cfg.outputfile)
  savevar(cfg.outputfile, 'data', data); % use the variable name "data" in the output file
end

