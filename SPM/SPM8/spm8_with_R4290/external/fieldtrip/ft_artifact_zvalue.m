function [cfg, artifact] = ft_artifact_zvalue(cfg,data)

% FT_ARTIFACT_ZVALUE reads the interesting segments of data from file and
% identifies artifacts by means of thresholding the z-transformed value
% of the preprocessed raw data. Depending on the preprocessing options,
% this method will be sensitive to EOG, muscle or jump artifacts.
% This procedure only works on continuously recorded data.
%
% Use as
%   [cfg, artifact] = ft_artifact_zvalue(cfg)
% or
%   [cfg, artifact] = ft_artifact_zvalue(cfg, data)
%
% The output argument "artifact" is a Nx2 matrix comparable to the
% "trl" matrix of FT_DEFINETRIAL. The first column of which specifying the
% beginsamples of an artifact period, the second column contains the
% endsamples of the artifactperiods.
%
% If you are calling FT_ARTIFACT_ZVALUE with only the configuration as first
% input argument and the data still has to be read from file, you should
% specify:
%   cfg.headerfile
%   cfg.headerfile
%   cfg.datafile
%   cfg.ft_datatype
%
% If you are calling FT_ARTIFACT_ZVALUE with also the second input argument
% "data", then that should contain data that was already read from file in
% a call to FT_PREPROCESSING.
%
% The required configuration settings are:
%   cfg.trl
%   cfg.artfctdef.zvalue.channel
%   cfg.artfctdef.zvalue.cutoff
%   cfg.artfctdef.zvalue.trlpadding
%   cfg.artfctdef.zvalue.fltpadding
%   cfg.artfctdef.zvalue.artpadding
%   cfg.continuous
%
% Configuration settings related to the preprocessing of the data are
%   cfg.artfctdef.zvalue.lpfilter      = 'no' or 'yes'  lowpass filter
%   cfg.artfctdef.zvalue.hpfilter      = 'no' or 'yes'  highpass filter
%   cfg.artfctdef.zvalue.bpfilter      = 'no' or 'yes'  bandpass filter
%   cfg.artfctdef.zvalue.lnfilter      = 'no' or 'yes'  line noise removal using notch filter
%   cfg.artfctdef.zvalue.dftfilter     = 'no' or 'yes'  line noise removal using discrete fourier transform
%   cfg.artfctdef.zvalue.medianfilter  = 'no' or 'yes'  jump preserving median filter
%   cfg.artfctdef.zvalue.lpfreq        = lowpass  frequency in Hz
%   cfg.artfctdef.zvalue.hpfreq        = highpass frequency in Hz
%   cfg.artfctdef.zvalue.bpfreq        = bandpass frequency range, specified as [low high] in Hz
%   cfg.artfctdef.zvalue.lnfreq        = line noise frequency in Hz, default 50Hz
%   cfg.artfctdef.zvalue.lpfiltord     = lowpass  filter order
%   cfg.artfctdef.zvalue.hpfiltord     = highpass filter order
%   cfg.artfctdef.zvalue.bpfiltord     = bandpass filter order
%   cfg.artfctdef.zvalue.lnfiltord     = line noise notch filter order
%   cfg.artfctdef.zvalue.medianfiltord = length of median filter
%   cfg.artfctdef.zvalue.lpfilttype    = digital filter type, 'but' (default) or 'fir'
%   cfg.artfctdef.zvalue.hpfilttype    = digital filter type, 'but' (default) or 'fir'
%   cfg.artfctdef.zvalue.bpfilttype    = digital filter type, 'but' (default) or 'fir'
%   cfg.artfctdef.zvalue.detrend       = 'no' or 'yes'
%   cfg.artfctdef.zvalue.demean        = 'no' or 'yes'
%   cfg.artfctdef.zvalue.baselinewindow = [begin end] in seconds, the default is the complete trial
%   cfg.artfctdef.zvalue.hilbert       = 'no' or 'yes'
%   cfg.artfctdef.zvalue.rectify       = 'no' or 'yes'
%
% See also FT_REJECTARTIFACT

% Copyright (c) 2003-2005, Jan-Mathijs Schoffelen, Robert Oostenveld
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
% $Id: ft_artifact_zvalue.m 2439 2010-12-15 16:33:34Z johzum $

ft_defaults

% set default rejection parameters
if ~isfield(cfg,'artfctdef'),                   cfg.artfctdef                    = [];       end
if ~isfield(cfg.artfctdef,'zvalue'),            cfg.artfctdef.zvalue             = [];       end
if ~isfield(cfg, 'headerformat'),               cfg.headerformat                 = [];       end
if ~isfield(cfg, 'dataformat'),                 cfg.dataformat                   = [];       end

% for backward compatibility
if isfield(cfg.artfctdef.zvalue,'sgn')
  cfg.artfctdef.zvalue.channel = cfg.artfctdef.zvalue.sgn;
  cfg.artfctdef.zvalue         = rmfield(cfg.artfctdef.zvalue, 'sgn');
end
cfg.artfctdef = ft_checkconfig(cfg.artfctdef, 'renamed',    {'blc', 'demean'});
cfg.artfctdef = ft_checkconfig(cfg.artfctdef, 'renamed',    {'blcwindow' 'baselinewindow'});

if isfield(cfg.artfctdef.zvalue, 'artifact')
  fprintf('zvalue artifact detection has already been done, retaining artifacts\n');
  artifact = cfg.artfctdef.zvalue.artifact;
  return
end

if ~isfield(cfg.artfctdef.zvalue,'channel'),    cfg.artfctdef.zvalue.channel     = {};       end
if ~isfield(cfg.artfctdef.zvalue,'trlpadding'), cfg.artfctdef.zvalue.trlpadding  = 0;        end
if ~isfield(cfg.artfctdef.zvalue,'artpadding'), cfg.artfctdef.zvalue.artpadding  = 0;        end
if ~isfield(cfg.artfctdef.zvalue,'fltpadding'), cfg.artfctdef.zvalue.fltpadding  = 0;        end
if ~isfield(cfg.artfctdef.zvalue,'feedback'),   cfg.artfctdef.zvalue.feedback    = 'no';     end
if ~isfield(cfg.artfctdef.zvalue,'cumulative'), cfg.artfctdef.zvalue.cumulative  = 'yes';    end

thresholdsum = strcmp(cfg.artfctdef.zvalue.cumulative, 'yes');

if nargin > 1
  % data given as input
  isfetch = 1;
  hdr = ft_fetch_header(data);
elseif nargin == 1
  % only cfg given
  isfetch = 0;
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

trl           = cfg.trl;
trlpadding    = round(cfg.artfctdef.zvalue.trlpadding*hdr.Fs);
fltpadding    = round(cfg.artfctdef.zvalue.fltpadding*hdr.Fs);
artpadding    = round(cfg.artfctdef.zvalue.artpadding*hdr.Fs);
trl(:,1)      = trl(:,1) - trlpadding;       % pad the trial with some samples, in order to detect
trl(:,2)      = trl(:,2) + trlpadding;       % artifacts at the edges of the relevant trials.
trl(:,3)      = nan;                         % the offset is not correct any more
trllength     = trl(:,2) - trl(:,1) + 1;     % length of each trial
numtrl        = size(trl,1);
cfg.artfctdef.zvalue.trl = trl;              % remember where we are going to look for artifacts
cfg.artfctdef.zvalue.channel = ft_channelselection(cfg.artfctdef.zvalue.channel, hdr.label);
sgnind        = match_str(hdr.label, cfg.artfctdef.zvalue.channel);
numsgn        = length(sgnind);

if numsgn<1
  error('no channels selected');
else
  fprintf('searching for artifacts in %d channels\n', numsgn);
end

% read the data and apply preprocessing options
sumval = zeros(numsgn, 1);
sumsqr = zeros(numsgn, 1);
numsmp = zeros(numsgn, 1);
fprintf('searching trials');
for trlop = 1:numtrl
  fprintf('.');
  if isfetch
    dat{trlop} = ft_fetch_data(data,        'header', hdr, 'begsample', trl(trlop,1)-fltpadding, 'endsample', trl(trlop,2)+fltpadding, 'chanindx', sgnind, 'checkboundary', strcmp(cfg.continuous,'no'));
  else
    dat{trlop} = ft_read_data(cfg.datafile, 'header', hdr, 'begsample', trl(trlop,1)-fltpadding, 'endsample', trl(trlop,2)+fltpadding, 'chanindx', sgnind, 'checkboundary', strcmp(cfg.continuous,'no'), 'dataformat', cfg.dataformat);
  end
  dat{trlop} = preproc(dat{trlop}, cfg.artfctdef.zvalue.channel, hdr.Fs, cfg.artfctdef.zvalue, [], fltpadding, fltpadding);
  % accumulate the sum and the sum-of-squares
  sumval = sumval + sum(dat{trlop},2);
  sumsqr = sumsqr + sum(dat{trlop}.^2,2);
  numsmp = numsmp + size(dat{trlop},2);
end % for trlop

% compute the average and the standard deviation
datavg = sumval./numsmp;
datstd = sqrt(sumsqr./numsmp - (sumval./numsmp).^2);

for trlop = 1:numtrl
  % initialize some matrices
  zmax{trlop}  = -inf + zeros(1,size(dat{trlop},2));
  zsum{trlop}  = zeros(1,size(dat{trlop},2));
  zindx{trlop} = zeros(1,size(dat{trlop},2));
  
  nsmp          = size(dat{trlop},2);
  zdata         = (dat{trlop} - datavg(:,ones(1,nsmp)))./datstd(:,ones(1,nsmp));  % convert the filtered data to z-values
  zsum{trlop}   = sum(zdata,1);                   % accumulate the z-values over channels
  [zmax{trlop},ind] = max(zdata,[],1);            % find the maximum z-value and remember it
  zindx{trlop}      = sgnind(ind);                % also remember the channel number that has the largest z-value

  % This alternative code does the same, but it is much slower
  %   for i=1:size(zmax{trlop},2)
  %       if zdata{trlop}(i)>zmax{trlop}(i)
  %         % update the maximum value and channel index
  %         zmax{trlop}(i)  = zdata{trlop}(i);
  %         zindx{trlop}(i) = sgnind(sgnlop);
  %       end
  %     end
end % for trlop 

%for sgnlop=1:numsgn
%  % read the data and apply preprocessing options
%  sumval = 0;
%  sumsqr = 0;
%  numsmp = 0;
%  fprintf('searching channel %s ', cfg.artfctdef.zvalue.channel{sgnlop});
%  for trlop = 1:numtrl
%    fprintf('.');
%    if isfetch
%      dat{trlop} = ft_fetch_data(data,        'header', hdr, 'begsample', trl(trlop,1)-fltpadding, 'endsample', trl(trlop,2)+fltpadding, 'chanindx', sgnind(sgnlop), 'checkboundary', strcmp(cfg.continuous,'no'));
%    else
%      dat{trlop} = read_data(cfg.datafile, 'header', hdr, 'begsample', trl(trlop,1)-fltpadding, 'endsample', trl(trlop,2)+fltpadding, 'chanindx', sgnind(sgnlop), 'checkboundary', strcmp(cfg.continuous,'no'));
%    end
%    dat{trlop} = preproc(dat{trlop}, cfg.artfctdef.zvalue.channel(sgnlop), hdr.Fs, cfg.artfctdef.zvalue, [], fltpadding, fltpadding);
%    % accumulate the sum and the sum-of-squares
%    sumval = sumval + sum(dat{trlop},2);
%    sumsqr = sumsqr + sum(dat{trlop}.^2,2);
%    numsmp = numsmp + size(dat{trlop},2);
%  end % for trlop
%
%  % compute the average and the standard deviation
%  datavg = sumval./numsmp;
%  datstd = sqrt(sumsqr./numsmp - (sumval./numsmp).^2);
%
%  for trlop = 1:numtrl
%    if sgnlop==1
%      % initialize some matrices
%      zdata{trlop} = zeros(size(dat{trlop}));
%      zmax{trlop}  = -inf + zeros(size(dat{trlop}));
%      zsum{trlop}  = zeros(size(dat{trlop}));
%      zindx{trlop} = zeros(size(dat{trlop}));
%    end
%    zdata{trlop}  = (dat{trlop} - datavg)./datstd;              % convert the filtered data to z-values
%    zsum{trlop}   = zsum{trlop} + zdata{trlop};                 % accumulate the z-values over channels
%    zmax{trlop}   = max(zmax{trlop}, zdata{trlop});             % find the maximum z-value and remember it
%    zindx{trlop}(zmax{trlop}==zdata{trlop}) = sgnind(sgnlop);   % also remember the channel number that has the largest z-value
%
%    % This alternative code does the same, but it is much slower
%    %   for i=1:size(zmax{trlop},2)
%    %       if zdata{trlop}(i)>zmax{trlop}(i)
%    %         % update the maximum value and channel index
%    %         zmax{trlop}(i)  = zdata{trlop}(i);
%    %         zindx{trlop}(i) = sgnind(sgnlop);
%    %       end
%    %     end
%  end
%  fprintf('\n');
%end % for sgnlop

for trlop = 1:numtrl
  zsum{trlop} = zsum{trlop} ./ sqrt(numsgn);
end

if strcmp(cfg.artfctdef.zvalue.feedback, 'yes')
  % give graphical feedback and allow the user to modify the threshold
  interactiveloop = 1;
  while interactiveloop
    h = figure;
    hold on
    for trlop=1:numtrl
      xval = trl(trlop,1):trl(trlop,2);
      if thresholdsum,
        yval = zsum{trlop};
      else
        yval = zmax{trlop};
      end
      plot(xval, yval, 'b-');
      dum = yval<=cfg.artfctdef.zvalue.cutoff;
      yval(dum) = nan;
      plot(xval, yval, 'r-');
    end
    hline(cfg.artfctdef.zvalue.cutoff, 'color', 'r', 'linestyle', ':');
    xlabel('sample number');
    ylabel('cumulative z-value');
    [response, interactiveloop] = smartinput('\nwould you like to page through the data [y/N]? ', 'n');
    artval = {};
    for trlop=1:numtrl
      if thresholdsum,
        % threshold the accumulated z-values
        artval{trlop} = zsum{trlop}>cfg.artfctdef.zvalue.cutoff;
      else
        % threshold the max z-values
        artval{trlop} = zmax{trlop}>cfg.artfctdef.zvalue.cutoff;
      end
      % pad the artifacts
      artbeg = find(diff([0 artval{trlop}])== 1);
      artend = find(diff([artval{trlop} 0])==-1);
      artbeg = artbeg - artpadding;
      artend = artend + artpadding;
      artbeg(artbeg<1) = 1;
      artend(artend>length(artval{trlop})) = length(artval{trlop});
      for artlop=1:length(artbeg)
        artval{trlop}(artbeg(artlop):artend(artlop)) = 1;
      end
    end
    % show the z-values, the artifacts and a selection of the original data
    if interactiveloop
      if nargin==1,
        if ~thresholdsum, zsum = zmax; end;
        artifact_viewer(cfg, cfg.artfctdef.zvalue, zsum, artval, zindx);
        cfg.artfctdef.zvalue.cutoff = smartinput(sprintf('\ngive new cutoff value, or press enter to accept current value [%g]: ', cfg.artfctdef.zvalue.cutoff), cfg.artfctdef.zvalue.cutoff);
      else
        if ~thresholdsum, zsum = zmax; end;
        artifact_viewer(cfg, cfg.artfctdef.zvalue, zsum, artval, zindx, data);
        cfg.artfctdef.zvalue.cutoff = smartinput(sprintf('\ngive new cutoff value, or press enter to accept current value [%g]: ', cfg.artfctdef.zvalue.cutoff), cfg.artfctdef.zvalue.cutoff);
      end
    end
    if ishandle(h), close(h), end;
  end % interactiveloop
else
  % this code snippet is the same as above, but without the plotting
  artval = {};
  for trlop=1:numtrl
    if thresholdsum,
      % threshold the accumulated z-values
      artval{trlop} = zsum{trlop}>cfg.artfctdef.zvalue.cutoff;
    else
      % threshold the max z-values
      artval{trlop} = zmax{trlop}>cfg.artfctdef.zvalue.cutoff;
    end
    % pad the artifacts
    artbeg = find(diff([0 artval{trlop}])== 1);
    artend = find(diff([artval{trlop} 0])==-1);
    artbeg = artbeg - artpadding;
    artend = artend + artpadding;
    artbeg(artbeg<1) = 1;
    artend(artend>length(artval{trlop})) = length(artval{trlop});
    for artlop=1:length(artbeg)
      artval{trlop}(artbeg(artlop):artend(artlop)) = 1;
    end
  end
end % feedback

% convert to one long vector
dum = zeros(1,max(trl(:,2)));
for trlop=1:numtrl
  dum(trl(trlop,1):trl(trlop,2)) = artval{trlop};
end
artval = dum;

% find the padded artifacts and put them in a Nx2 trl-like matrix
artbeg = find(diff([0 artval])== 1);
artend = find(diff([artval 0])==-1);
artifact = [artbeg(:) artend(:)];

% remember the artifacts that were found
cfg.artfctdef.zvalue.artifact = artifact;

fprintf('detected %d artifacts\n', size(artifact,1));

% add version information to the configuration
cfg.artfctdef.zvalue.version.name = mfilename('fullpath');
cfg.artfctdef.zvalue.version.id = '$Id: ft_artifact_zvalue.m 2439 2010-12-15 16:33:34Z johzum $';

