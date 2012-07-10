function [grandavg] = ft_timelockgrandaverage(cfg, varargin)

% FT_TIMELOCKGRANDAVERAGE computes ERF/ERP average and variance
% over multiple subjects
%
% Use as
%   [grandavg] = ft_timelockgrandaverage(cfg, avg1, avg2, avg3, ...)
%
% where
%   avg1..N are the ERF/ERP averages as obtained from FT_TIMELOCKANALYSIS
%
% and cfg is a configuration structure with
%  cfg.channel        = Nx1 cell-array with selection of channels (default = 'all'),
%                       see FT_CHANNELSELECTION for details
%  cfg.latency        = [begin end] in seconds or 'all' (default = 'all')
%  cfg.keepindividual = 'yes' or 'no' (default = 'no')
%  cfg.normalizevar   = 'N' or 'N-1' (default = 'N-1')
%
% To facilitate data-handling and distributed computing with the peer-to-peer
% module, this function has the following options:
%   cfg.inputfile   =  ...
%   cfg.outputfile  =  ...
% If you specify one of these (or both) the input data will be read from a *.mat
% file on disk and/or the output data will be written to a *.mat file. These mat
% files should contain only a single variable, corresponding with the
% input/output structure. For this particular function, the input should be
% structured as a cell array.
%
% See also FT_TIMELOCKANALYSIS, FT_TIMELOCKSTATISTICS

% Copyright (C) 2003-2006, Jens Schwarzbach
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
% $Id: ft_timelockgrandaverage.m 3016 2011-03-01 19:09:40Z eelspa $

ft_defaults

cfg = ft_checkconfig(cfg, 'trackconfig', 'on');

% set the defaults
if ~isfield(cfg, 'inputfile'),    cfg.inputfile  = []; end
if ~isfield(cfg, 'outputfile'),   cfg.outputfile = []; end

hasdata      = nargin>2;
hasinputfile = ~isempty(cfg.inputfile); 

if hasdata && hasinputfile
    error('cfg.inputfile should not be used in conjunction with giving input data to this function');
elseif hasinputfile
  for i=1:numel(cfg.inputfile)
    varargin{i} = loadvar(cfg.inputfile{i}, 'data'); % read datasets from array inputfile
  end
end

% check if the input data is valid for this function
for i=1:length(varargin)
  varargin{i} = ft_checkdata(varargin{i}, 'datatype', 'timelock', 'feedback', 'no');
end

% set the defaults
if ~isfield(cfg, 'channel'),        cfg.channel        = 'all'; end
if ~isfield(cfg, 'keepindividual'), cfg.keepindividual = 'no';  end
if ~isfield(cfg, 'latency'),        cfg.latency        = 'all'; end
if ~isfield(cfg, 'normalizevar'),   cfg.normalizevar   = 'N-1'; end

% varargin{1} ... varargin{end} contain the individual ERFs
Nsubj = length(varargin);

if isfield(varargin{1}, 'grad')
  warning('discarding gradiometer information because it cannot be averaged');
end
if isfield(varargin{1}, 'elec')
  warning('discarding electrode information because it cannot be averaged');
end

% replace string latency selection by a timerange based on the range of all subjects
if ischar(cfg.latency) && strcmp(cfg.latency, 'all')
  cfg.latency = [];
  cfg.latency(1) = min(varargin{1}.time);
  cfg.latency(2) = max(varargin{1}.time);
  for s=2:Nsubj
    % reset min/max latency (for variable trial length over subjects)
    if min(varargin{s}.time) > cfg.latency(1)
      cfg.latency(1) = min(varargin{s}.time);
    end
    if max(varargin{s}.time) < cfg.latency(2)
      cfg.latency(2) = max(varargin{s}.time);
    end
  end
end

%SELECT TIME WINDOW
idxs = nearest(varargin{1}.time, min(cfg.latency));
idxe = nearest(varargin{1}.time, max(cfg.latency));
% shift start and end index in case of flipped time axis
% (potentially introduced for response time locked data)
if idxe < idxs
  ResultsTimeSelectCases = idxe:idxs;
else
  ResultsTimeSelectCases = idxs:idxe;
end
ResultsNTimePoints = length(ResultsTimeSelectCases);
ResultsTime = varargin{1}.time(ResultsTimeSelectCases);

%UPDATE CFG STRUCTURE WITH TIME THAT WAS FINALLY USED
cfg.latency = [ResultsTime(1), ResultsTime(end)];

%DETERMINE WHICH CHANNELS ARE AVAILABLE FOR ALL SUBJECTS
for i=1:Nsubj
  cfg.channel = ft_channelselection(cfg.channel, varargin{i}.label);
end
ResultNChannels = size(cfg.channel, 1);

%REDUCE DATASET TO INTERSECTION OF DESIRED AND AVAILABLE CHANNELS
for i=1:Nsubj
  % select channel indices in this average, sorted according to configuration
  [dum, chansel]    = match_str(cfg.channel, varargin{i}.label);
  varargin{i}.avg   = varargin{i}.avg(chansel,:);
  varargin{i}.label = varargin{i}.label(chansel);
  try, varargin{i}.trial = varargin{i}.trial(chansel,:,:); end
end

%PREALLOCATE
avgmat = zeros(Nsubj, ResultNChannels, ResultsNTimePoints);
%FILL MATRIX, MAY BE DONE MORE EFFECTIVELY WITH DEAL COMMAND
for s = 1:Nsubj
  avgmat(s, :, :) = varargin{s}.avg(:, ResultsTimeSelectCases);
end

if strcmp(cfg.keepindividual, 'no')
  %AVERAGE ACROSS SUBJECT DIMENSION
  ResultGrandavg = mean(avgmat, 1);
  ResultGrandavg = reshape(ResultGrandavg, [ResultNChannels, ResultsNTimePoints]);

  %COMPUTE VARIANCE ACROSS SUBJECT DIMENSION
  %THIS LOOKS AWKWARD (std.^2) BUT IS FAST DUE TO BUILT IN FUNCTIONS
  switch cfg.normalizevar
    case 'N-1'
      sdflag = 0;
    case 'N'
      sdflag = 1;
  end
  ResultVar = std(avgmat, sdflag, 1).^2;
  ResultVar = reshape(ResultVar, [ResultNChannels, ResultsNTimePoints]);
else
  % do nothing
end

%--------------------------------------------
% % collect the results
%--------------------------------------------

grandavg           = [];
grandavg.label     = cfg.channel;       % cell-array
%grandavg.fsample   = varargin{1}.fsample; % fsample is obsolete
grandavg.time      = ResultsTime;       % 1 x Nsamples

%KEEP INDIVIDUAL MEANS?
if strcmp(cfg.keepindividual, 'yes')
  grandavg.individual = avgmat;         % Nsubj x Nchan x Nsamples
  grandavg.dimord = 'subj_chan_time';
else
  grandavg.avg    = ResultGrandavg;     % Nchan x Nsamples
  grandavg.var    = ResultVar;          % Nchan x Nsamples
  grandavg.dimord = 'chan_time';
end

% accessing this field here is needed for the configuration tracking
% by accessing it once, it will not be removed from the output cfg
cfg.outputfile;

% get the output cfg
cfg = ft_checkconfig(cfg, 'trackconfig', 'off', 'checksize', 'yes');

% add version information to the configuration
cfg.version.name = mfilename('fullpath');
cfg.version.id = '$Id: ft_timelockgrandaverage.m 3016 2011-03-01 19:09:40Z eelspa $';

% add information about the Matlab version used to the configuration
cfg.version.matlab = version();

% remember the configuration details of the input data
cfg.previous = [];
for i=1:length(varargin)
  try, cfg.previous{i} = varargin{i}.cfg; end
end

% remember the exact configuration details in the output
grandavg.cfg = cfg;

% the output data should be saved to a MATLAB file
if ~isempty(cfg.outputfile)
  savevar(cfg.outputfile, 'data', grandavg); % use the variable name "data" in the output file
end
