function [chansel, trlsel, cfg] = rejectvisual_channel(cfg, data);

% SUBFUNCTION for rejectvisual

% Copyright (C) 2006, Robert Oostenveld
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
% $Id: rejectvisual_channel.m 2622 2011-01-20 15:32:41Z jorhor $

% determine the initial selection of trials and channels
nchan = length(data.label);
ntrl  = length(data.trial);
cfg.channel = ft_channelselection(cfg.channel, data.label);
trlsel  = logical(ones(1,ntrl));
chansel = logical(zeros(1,nchan));
chansel(match_str(data.label, cfg.channel)) = 1;

% compute the sampling frequency from the first two timepoints
fsample = 1/(data.time{1}(2) - data.time{1}(1));

% compute the offset from the time axes
offset = zeros(ntrl,1);
for i=1:ntrl
  offset(i) = time2offset(data.time{i}, fsample);
end

ft_progress('init', cfg.feedback, 'filtering data');
for i=1:ntrl
  ft_progress(i/ntrl, 'filtering data in trial %d of %d\n', i, ntrl);
  [data.trial{i}, label, time, cfg.preproc] = preproc(data.trial{i}, data.label, fsample, cfg.preproc, offset(i));
end
ft_progress('close');

% select the specified latency window from the data
% this is done AFTER the filtering to prevent edge artifacts
for i=1:ntrl
  begsample = nearest(data.time{i}, cfg.latency(1));
  endsample = nearest(data.time{i}, cfg.latency(2));
  data.time{i} = data.time{i}(begsample:endsample);
  data.trial{i} = data.trial{i}(:,begsample:endsample);
end

h = figure;
axis([0 1 0 1]);
axis off

% the info structure will be attached to the figure
% and passed around between the callback functions
if strcmp(cfg.plotlayout,'1col') % hidden config option for plotting trials differently
  info         = [];
  info.ncols   = 1;
  info.nrows   = ntrl;
  info.trlop   = 1;
  info.chanlop = 1;
  info.quit    = 0;
  info.ntrl    = ntrl;
  info.nchan   = nchan;
  info.data    = data;
  info.cfg     = cfg;
  info.offset  = offset;
  info.chansel = chansel;
  info.trlsel  = trlsel;
  % determine the position of each subplot within the axis
  for row=1:info.nrows
    for col=1:info.ncols
      indx = (row-1)*info.ncols + col;
      if indx>info.ntrl
        continue
      end
      info.x(indx)     = (col-0.9)/info.ncols;
      info.y(indx)     = 1 - (row-0.45)/(info.nrows+1);
      info.label{indx} = sprintf('trial %03d', indx);
    end
  end
elseif strcmp(cfg.plotlayout,'square')
  info         = [];
  info.ncols   = ceil(sqrt(ntrl));
  info.nrows   = ceil(sqrt(ntrl));
  info.trlop   = 1;
  info.chanlop = 1;
  info.quit    = 0;
  info.ntrl    = ntrl;
  info.nchan   = nchan;
  info.data    = data;
  info.cfg     = cfg;
  info.offset  = offset;
  info.chansel = chansel;
  info.trlsel  = trlsel;
  % determine the position of each subplot within the axis
  for row=1:info.nrows
    for col=1:info.ncols
      indx = (row-1)*info.ncols + col;
      if indx>info.ntrl
        continue
      end
      info.x(indx)     = (col-0.9)/info.ncols;
      info.y(indx)     = 1 - (row-0.45)/(info.nrows+1);
      info.label{indx} = sprintf('trial %03d', indx);
    end
  end
end

guidata(h,info);

uicontrol(h,'units','pixels','position',[5 5 40 18],'String','quit','Callback',@stop);
uicontrol(h,'units','pixels','position',[50 5 25 18],'String','<','Callback',@prev);
uicontrol(h,'units','pixels','position',[75 5 25 18],'String','>','Callback',@next);
uicontrol(h,'units','pixels','position',[105 5 25 18],'String','<<','Callback',@prev10);
uicontrol(h,'units','pixels','position',[130 5 25 18],'String','>>','Callback',@next10);
uicontrol(h,'units','pixels','position',[160 5 50 18],'String','bad','Callback',@markbad);
uicontrol(h,'units','pixels','position',[210 5 50 18],'String','good','Callback',@markgood);
uicontrol(h,'units','pixels','position',[270 5 50 18],'String','bad>','Callback',@markbad_next);
uicontrol(h,'units','pixels','position',[320 5 50 18],'String','good>','Callback',@markgood_next);
set(gcf, 'WindowButtonUpFcn', @button);
set(gcf, 'KeyPressFcn', @key);

interactive = 1;
while interactive && ishandle(h)
  redraw(h);
  info = guidata(h);
  if info.quit == 0,
    uiwait;
  else
    chansel = info.chansel;
    trlsel = info.trlsel;
    delete(h);
    break
  end
end % while interactive

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function varargout = markbad_next(varargin)
markbad(varargin{:});
next(varargin{:});

function varargout = markgood_next(varargin)
markgood(varargin{:});
next(varargin{:});

function varargout = next(h, eventdata, handles, varargin)
info = guidata(h);
if info.chanlop < info.nchan,
  info.chanlop = info.chanlop + 1;
end;
guidata(h,info);
uiresume;

function varargout = prev(h, eventdata, handles, varargin)
info = guidata(h);
if info.chanlop > 1,
  info.chanlop = info.chanlop - 1;
end;
guidata(h,info);
uiresume;

function varargout = next10(h, eventdata, handles, varargin)
info = guidata(h);
if info.chanlop < info.nchan - 10,
  info.chanlop = info.chanlop + 10;
else
  info.chanlop = info.nchan;
end;
guidata(h,info);
uiresume;

function varargout = prev10(h, eventdata, handles, varargin)
info = guidata(h);
if info.chanlop > 10,
  info.chanlop = info.chanlop - 10;
else
  info.chanlop = 1;
end;
guidata(h,info);
uiresume;

function varargout = markgood(h, eventdata, handles, varargin)
info = guidata(h);
info.chansel(info.chanlop) = 1;
fprintf(description_channel(info));
title(description_channel(info));
guidata(h,info);
% uiresume;

function varargout = markbad(h, eventdata, handles, varargin)
info = guidata(h);
info.chansel(info.chanlop) = 0;
fprintf(description_channel(info));
title(description_channel(info));
guidata(h,info);
% uiresume;

function varargout = key(h, eventdata, handles, varargin)
switch lower(eventdata.Key)
  case 'rightarrow'
    next(h);
  case 'leftarrow'
    prev(h);
  case 'g'
    markgood(h);
  case 'b'
    markbad(h);
  case 'q'
    stop(h);
  otherwise
    fprintf('unknown key pressed\n');
end

function varargout = button(h, eventdata, handles, varargin)
pos = get(gca, 'CurrentPoint');
x = pos(1,1);
y = pos(1,2);
info = guidata(h);
dx = info.x - x;
dy = info.y - y;
dd = sqrt(dx.^2 + dy.^2);
[d, i] = min(dd);
if d<0.5/max(info.nrows, info.ncols) && i<=info.ntrl
  info.trlsel(i) = ~info.trlsel(i); % toggle
  info.trlop = i;
  fprintf(description_trial(info));
  guidata(h,info);
  uiresume;
else
  fprintf('button clicked\n');
  return
end

function varargout = stop(h, eventdata, handles, varargin)
info = guidata(h);
info.quit = 1;
guidata(h,info);
uiresume;

function str = description_channel(info);
if info.chansel(info.chanlop)
  str = sprintf('channel %s marked as GOOD\n', info.data.label{info.chanlop});
else
  str = sprintf('channel %s marked as BAD\n', info.data.label{info.chanlop});
end

function str = description_trial(info);
if info.trlsel(info.trlop)
  str = sprintf('trial %d marked as GOOD\n', info.trlop);
else
  str = sprintf('trial %d marked as BAD\n', info.trlop);
end

function redraw(h)
if ~ishandle(h)
  return
end
info = guidata(h);
fprintf(description_channel(info));
cla;
title('');
drawnow
hold on
% determine the maximum value for this channel over all trials
amax = -inf;
tmin =  inf;
tmax = -inf;
for trlindx=find(info.trlsel)
  tmin = min(info.data.time{trlindx}(1)  , tmin);
  tmax = max(info.data.time{trlindx}(end), tmax);
  amax = max(max(abs(info.data.trial{trlindx}(info.chanlop,:))), amax);
end
if ~isempty(info.cfg.alim)
  % use fixed amplitude limits for the amplitude scaling
  amax = info.cfg.alim;
end
for row=1:info.nrows
  for col=1:info.ncols
    trlindx = (row-1)*info.ncols + col;
    if trlindx>info.ntrl || ~info.trlsel(trlindx)
      continue
    end
    % scale the time values between 0.1 and 0.9
    time = info.data.time{trlindx};
    time = 0.1 + 0.8*(time-tmin)/(tmax-tmin);
    % scale the amplitude values between -0.5 and 0.5, offset should not be removed
    dat = info.data.trial{trlindx}(info.chanlop,:);
    dat = dat ./ (2*amax);
    % scale the time values for this subplot
    tim = (col-1)/info.ncols + time/info.ncols;
    % scale the amplitude values for this subplot
    amp = dat./info.nrows + 1 - row/(info.nrows+1);
    plot(tim, amp, 'k')
  end
end
text(info.x, info.y, info.label);
title(description_channel(info));
hold off
