function [cfg, artifact] = ft_artifact_clip(cfg,data)

% FT_ARTIFACT_CLIP scans the data segments of interest for channels that
% clip. A clipping artifact is detected by the signal being completely
% flat for some time.
%
% Use as
%   [cfg, artifact] = ft_artifact_clip(cfg)
%   required configuration options:
%   cfg.dataset or both cfg.headerfile and cfg.datafile
% or
%   [cfg, artifact] = ft_artifact_clip(cfg, data)
%   forbidden configuration options:
%   cfg.dataset, cfg.headerfile and cfg.datafile
%
% In both cases the configuration should also contain:
%   cfg.artfctdef.clip.channel  = Nx1 cell-array with selection of channels, see FT_CHANNELSELECTION for details
%   cfg.artfctdef.clip.pretim   = 0.000;  pre-artifact rejection-interval in seconds
%   cfg.artfctdef.clip.psttim   = 0.000;  post-artifact rejection-interval in seconds
%   cfg.artfctdef.clip.thresh   = 0.010;  minimum duration in seconds of a datasegment with consecutive identical samples to be considered as 'clipped'
%   cfg.continuous              = 'yes' or 'no' whether the file contains continuous data
%
% To facilitate data-handling and distributed computing with the peer-to-peer
% module, this function has the following option:
%   cfg.inputfile   =  ...
% If you specify this option the input data will be read from a *.mat
% file on disk. This mat files should contain only a single variable named 'data',
% corresponding to the input structure.
%
% See also FT_REJECTARTIFACT

% Copyright (C) 2005, Robert Oostenveld
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
% $Id: ft_artifact_clip.m 3016 2011-03-01 19:09:40Z eelspa $

ft_defaults

% check if the input cfg is valid for this function
cfg = ft_checkconfig(cfg, 'trackconfig', 'on');
cfg = ft_checkconfig(cfg, 'renamed',    {'datatype', 'continuous'});
cfg = ft_checkconfig(cfg, 'renamedval', {'continuous', 'continuous', 'yes'});

% set default rejection parameters for clip artifacts if necessary.
if ~isfield(cfg,'artfctdef'),               cfg.artfctdef               = [];              end;
if ~isfield(cfg.artfctdef,'clip'),          cfg.artfctdef.clip          = [];              end;
if ~isfield(cfg.artfctdef.clip,'channel'),  cfg.artfctdef.clip.channel  = 'all';           end;
if ~isfield(cfg.artfctdef.clip,'thresh'),   cfg.artfctdef.clip.thresh   = 0.010;           end;
if ~isfield(cfg.artfctdef.clip,'pretim'),   cfg.artfctdef.clip.pretim   = 0.000;           end;
if ~isfield(cfg.artfctdef.clip,'psttim'),   cfg.artfctdef.clip.psttim   = 0.000;           end;
if ~isfield(cfg, 'headerformat'),           cfg.headerformat            = [];              end;
if ~isfield(cfg, 'dataformat'),             cfg.dataformat              = [];              end;
if ~isfield(cfg, 'inputfile'),              cfg.inputfile               = [];              end;

% for backward compatibility
if isfield(cfg.artfctdef.clip,'sgn')
  cfg.artfctdef.clip.channel = cfg.artfctdef.clip.sgn;
  cfg.artfctdef.clip         = rmfield(cfg.artfctdef.clip, 'sgn');
end

% start with an empty artifact list
artifact = [];

hasdata = (nargin>1);
if ~isempty(cfg.inputfile)
  % the input data should be read from file
  if hasdata
    error('cfg.inputfile should not be used in conjunction with giving input data to this function');
  else
    data = loadvar(cfg.inputfile, 'data');
    hasdata = true;
  end
end

if hasdata
  % read the header
  % isfetch = 1;
  cfg = ft_checkconfig(cfg, 'forbidden', {'dataset', 'headerfile', 'datafile'});
  hdr = ft_fetch_header(data);
else
  %   isfetch = 0;
  cfg = ft_checkconfig(cfg, 'dataset2files', {'yes'});
  cfg = ft_checkconfig(cfg, 'required', {'headerfile', 'datafile'});
  hdr = ft_read_header(cfg.headerfile, 'headerformat', cfg.headerformat);
end

% set default cfg.continuous
if ~isfield(cfg, 'continuous')
  if hdr.nTrials==1
    cfg.continuous = 'yes';
  else
    cfg.continuous = 'no';
  end
end

% find the channel labels present in the data and their indices
label = ft_channelselection(cfg.artfctdef.clip.channel, hdr.label);
sgnindx = match_str(hdr.label, label);

% make a local copy for convenience
artfctdef = cfg.artfctdef.clip;

ntrl = size(cfg.trl,1);
nsgn = length(sgnindx);
for trlop=1:ntrl
  fprintf('searching for clipping artifacts in trial %d\n', trlop);
  % read the data of this trial
  if hasdata
    dat = ft_fetch_data(data,        'header', hdr, 'begsample', cfg.trl(trlop,1), 'endsample', cfg.trl(trlop,2), 'chanindx', sgnindx);
  else
    dat = ft_read_data(cfg.datafile, 'header', hdr, 'begsample', cfg.trl(trlop,1), 'endsample', cfg.trl(trlop,2), 'chanindx', sgnindx, 'checkboundary', strcmp(cfg.continuous, 'no'), 'dataformat', cfg.dataformat);
  end
  % apply filtering etc to the data
  datflt = preproc(dat, label, hdr.Fs, artfctdef, cfg.trl(trlop,3));
  % detect all samples that have the same value as the previous sample
  identical = (datflt(:,1:(end-1)) == datflt(:,2:end));
  % ensure that the number of samples does not change
  identical = [identical zeros(nsgn,1)];
  
  % determine the number of consecutively identical samples
  clip = zeros(size(dat));
  for sgnlop=1:length(sgnindx)
    up = find(diff([0 identical(sgnlop,:)], 1, 2)== 1);
    dw = find(diff([identical(sgnlop,:) 0], 1, 2)==-1);
    for k=1:length(up)
      clip(sgnlop,up(k):dw(k)) = dw(k)-up(k);
    end
  end
  % collapse over cannels
  clip = max(clip,[],1);
  
  % detect whether there are intervals in which the number of consecutive
  % identical samples is larger than the threshold
  thresh = (clip>=artfctdef.thresh*hdr.Fs);
  
  % remember the thresholded parts as artifacts
  artup = find(diff([0 thresh])== 1) + cfg.trl(trlop,1) - 1;
  artdw = find(diff([thresh 0])==-1) + cfg.trl(trlop,1) - 1;
  for k=1:length(artup)
    artifact(end+1,:) = [artup(k) artdw(k)];
  end
end

if ~isempty(artifact)
  % add the pretim and psttim to the detected artifacts
  artifact(:,1) = artifact(:,1) - artfctdef.pretim * hdr.Fs;
  artifact(:,2) = artifact(:,2) + artfctdef.psttim * hdr.Fs;
end

% remember the details that were used here
cfg.artfctdef.clip          = artfctdef;
cfg.artfctdef.clip.label    = label;
cfg.artfctdef.clip.trl      = cfg.trl;
cfg.artfctdef.clip.artifact = artifact;

% get the output cfg
cfg = ft_checkconfig(cfg, 'trackconfig', 'off', 'checksize', 'yes');

% add version information to the configuration
cfg.version.name = mfilename('fullpath');
cfg.version.id = '$Id: ft_artifact_clip.m 3016 2011-03-01 19:09:40Z eelspa $';

% add information about the Matlab version used to the configuration
cfg.version.matlab = version();

