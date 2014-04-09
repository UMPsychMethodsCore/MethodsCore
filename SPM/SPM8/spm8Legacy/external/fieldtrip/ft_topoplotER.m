function [cfg] = ft_topoplotER(cfg, varargin)

% FT_TOPOPLOTER plots the topographic distribution of 2-Dimensional datatypes as
% event-related fields (ERF), potentials (ERP), the powerspectrum or coherence spectum
% that was computed using the FT_TIMELOCKALYSIS, FT_TIMELOCKGRANDAVERAGE, FT_FREQANALYSIS or
% FT_FREQDESCRIPTIVES functions, as a 2-D circular view (looking down at the top of the head).
%
% Use as:
%   ft_topoplotER(cfg, data)
%
% cfg.xparam             = first dimension in data in which a selection is made
%                         'time' or 'freq' (default depends on data.dimord)
% cfg.zparam             = field that contains the data to be plotted as color
%                         'avg', 'powspctrm' or 'cohspctrm' (default depends on data.dimord)
% cfg.xlim               = 'maxmin' or [xmin xmax] (default = 'maxmin')
% cfg.zlim               = 'maxmin', 'maxabs' or [zmin zmax] (default = 'maxmin')
% cfg.cohrefchannel      = name of reference channel for visualising coherence, can be 'gui'
% cfg.baseline           = 'yes','no' or [time1 time2] (default = 'no'), see FT_TIMELOCKBASELINE or FT_FREQBASELINE
% cfg.baselinetype       = 'absolute' or 'relative' (default = 'absolute')
% cfg.trials             = 'all' or a selection given as a 1xN vector (default = 'all')
% cfg.colormap           = any sized colormap, see COLORMAP
% cfg.marker             = 'on', 'labels', 'numbers', 'off'
% cfg.markersymbol       = channel marker symbol (default = 'o')
% cfg.markercolor        = channel marker color (default = [0 0 0] (black))
% cfg.markersize         = channel marker size (default = 2)
% cfg.markerfontsize     = font size of channel labels (default = 8 pt)
% cfg.highlight          = 'on', 'labels', 'numbers', 'off'
% cfg.highlightchannel   =  Nx1 cell-array with selection of channels, or vector containing channel indices see FT_CHANNELSELECTION
% cfg.highlightsymbol    = highlight marker symbol (default = 'o')
% cfg.highlightcolor     = highlight marker color (default = [0 0 0] (black))
% cfg.highlightsize      = highlight marker size (default = 6)
% cfg.highlightfontsize  = highlight marker size (default = 8)
% cfg.colorbar           = 'yes'
%                          'no' (default)
%                          'North'              inside plot box near top
%                          'South'              inside bottom
%                          'East'               inside right
%                          'West'               inside left
%                          'NorthOutside'       outside plot box near top
%                          'SouthOutside'       outside bottom
%                          'EastOutside'        outside right
%                          'WestOutside'        outside left
% cfg.interplimits       = limits for interpolation (default = 'head')
%                          'electrodes' to furthest electrode
%                          'head' to edge of head
% cfg.interpolation      = 'linear','cubic','nearest','v4' (default = 'v4') see GRIDDATA
% cfg.style              = plot style (default = 'both')
%                          'straight' colormap only
%                          'contour' contour lines only
%                          'both' (default) both colormap and contour lines
%                          'fill' constant color between lines
%                          'blank' only the head shape
% cfg.gridscale          = scaling grid size (default = 67)
%                          determines resolution of figure
% cfg.shading            = 'flat' 'interp' (default = 'flat')
% cfg.comment            = string 'no' 'auto' or 'xlim' (default = 'auto')
%                          'auto': date, xparam and zparam limits are printed
%                          'xlim': only xparam limits are printed
% cfg.commentpos         = string or two numbers, position of comment (default 'leftbottom')
%                          'lefttop' 'leftbottom' 'middletop' 'middlebottom' 'righttop' 'rightbottom'
%                          'title' to place comment as title
%                          'layout' to place comment as specified for COMNT in layout
%                          [x y] coordinates
% cfg.interactive        = Interactive plot 'yes' or 'no' (default = 'no')
%                          In a interactive plot you can select areas and produce a new
%                          interactive plot when a selected area is clicked. Multiple areas
%                          can be selected by holding down the SHIFT key.
% cfg.layout             = specification of the layout, see below
%
% The layout defines how the channels are arranged. You can specify the
% layout in a variety of ways:
%  - you can provide a pre-computed layout structure (see prepare_layout)
%  - you can give the name of an ascii layout file with extension *.lay
%  - you can give the name of an electrode file
%  - you can give an electrode definition, i.e. "elec" structure
%  - you can give a gradiometer definition, i.e. "grad" structure
% If you do not specify any of these and the data structure contains an
% electrode or gradiometer structure, that will be used for creating a
% layout. If you want to have more fine-grained control over the layout
% of the subplots, you should create your own layout file.
%
%
% See also:
%  ft_topoplotTFR, ft_topoplotIC, ft_singleplotER, ft_multiplotER, ft_prepare_layout

% Undocumented local options:
% The following additional cfg parameters are used when plotting 3-dimensional
% data (i.e. when ft_topoplotTFR calls ft_topoplotER):
% cfg.yparam          field to be plotted on y-axis
% cfg.ylim            'maxmin' or [ymin ymax]         (default = 'maxmin')
% cfg.inputfile  = one can specifiy preanalysed saved data as input
%                  The data should be provided in a cell array

% It is possible to use multiple highlight-selections (e.g.: multiple statistical clusters of channels)
% To do this, all the content of the highlight-options (including cfg.highlight) should be placed in a cell-array
% (even if the normal content was already in a cell-array). Specific marker settings (e.g. color, size) are defaulted when
% not present.
% Example (3 selections):
% cfg.highlight          = {'labels', 'labels', 'numbers'}
% cfg.highlightchannel   = {{'MZF03','MZC01','MRT54'}, [1:5], 'C*'}
% cfg.highlightsymbol    = {'o',[],'+'}        % the empty option will be defaulted
% cfg.highlightcolor     = {'r',[0 0 1]};      % the missing option will be defaulted
% cfg.highlightsize      = [];                 % will be set to default, as will the missing cfg.highlightfontsize
%
% Other options:
% cfg.labeloffset (offset of labels to their marker, default = 0.005)
% cfg.inputfile  = one can specifiy preanalysed saved data as input
%                   The data should be provided in a cell array

% This function depends on FT_TIMELOCKBASELINE which has the following options:
% cfg.baseline, documented
% cfg.channel
% cfg.blcwindow
%
% This function depends on FT_FREQBASELINE which has the following options:
% cfg.baseline, documented
% cfg.baselinetype

% Copyright (C) 2005-2006, F.C. Donders Centre
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
% $Id: ft_topoplotER.m 1430 2010-07-20 07:41:41Z roboos $

fieldtripdefs

cfg = checkconfig(cfg, 'trackconfig', 'on');
cfg = checkconfig(cfg, 'unused',  {'cohtargetchannel'});

cla

% Multiple data sets are not supported for topoplot:
if length(varargin)>1
  error('Multiple data sets are not supported for topoplotER/topoplotTFR.');
end

% set default for inputfile
if ~isfield(cfg, 'inputfile'),  cfg.inputfile = [];    end

hasdata = nargin>1;
if ~isempty(cfg.inputfile) % the input data should be read from file
  if hasdata
    error('cfg.inputfile should not be used in conjunction with giving input data to this function');
  else
    for i=1:numel(cfg.inputfile)
      varargin{i} = loadvar(cfg.inputfile{i}, 'data'); % read datasets from array inputfile
      data = varargin{i};
    end
  end
else
  data = varargin{1};
end

% For backward compatibility with old data structures:
data = checkdata(data);

% check for option-values to be renamed
cfg = checkconfig(cfg, 'renamedval',     {'electrodes',   'dotnum',    'numbers'});
cfg = checkconfig(cfg, 'renamedval',     {'zlim',         'absmax',    'maxabs'});
% check for renamed options
cfg = checkconfig(cfg, 'renamed',     {'electrodes',    'marker'});
cfg = checkconfig(cfg, 'renamed',     {'emarker',       'markersymbol'});
cfg = checkconfig(cfg, 'renamed',     {'ecolor',        'markercolor'});
cfg = checkconfig(cfg, 'renamed',     {'emarkersize',   'markersize'});
cfg = checkconfig(cfg, 'renamed',     {'efontsize',     'markerfontsize'});
cfg = checkconfig(cfg, 'renamed',     {'hlmarker',      'highlightsymbol'});
cfg = checkconfig(cfg, 'renamed',     {'hlcolor',       'highlightcolor'});
cfg = checkconfig(cfg, 'renamed',     {'hlmarkersize',  'highlightsize'});
cfg = checkconfig(cfg, 'renamed',     {'maplimits',     'zlim'});
% old checkconfig adapted partially from topoplot.m (backwards backwards compatability)
cfg = checkconfig(cfg, 'renamed',     {'grid_scale',    'gridscale'});
cfg = checkconfig(cfg, 'renamed',     {'interpolate',   'interpolation'});
cfg = checkconfig(cfg, 'renamed',     {'numcontour',    'contournum'});
cfg = checkconfig(cfg, 'renamed',     {'electrod',      'marker'});
cfg = checkconfig(cfg, 'renamed',     {'electcolor',    'markercolor'});
cfg = checkconfig(cfg, 'renamed',     {'emsize',        'markersize'});
cfg = checkconfig(cfg, 'renamed',     {'efsize',        'markerfontsize'});
cfg = checkconfig(cfg, 'renamed',     {'headlimits',    'interplimits'});

% check for forbidden options
cfg = checkconfig(cfg, 'forbidden',  {'hllinewidth'});
cfg = checkconfig(cfg, 'forbidden',  {'headcolor'});
cfg = checkconfig(cfg, 'forbidden',  {'hcolor'});
cfg = checkconfig(cfg, 'forbidden',  {'hlinewidth'});
cfg = checkconfig(cfg, 'forbidden',  {'contcolor'});
cfg = checkconfig(cfg, 'forbidden',  {'outline'});
cfg = checkconfig(cfg, 'forbidden',  {'highlightfacecolor'});
cfg = checkconfig(cfg, 'forbidden',  {'showlabels'});
cfg = checkconfig(cfg, 'forbidden',  {'hllinewidth'});

% Set other config defaults:
if ~isfield(cfg, 'xlim'),                  cfg.xlim = 'maxmin';           end
if ~isfield(cfg, 'ylim'),                  cfg.ylim = 'maxmin';           end
if ~isfield(cfg, 'zlim'),                  cfg.zlim = 'maxmin';           end
if ~isfield(cfg, 'style'),                 cfg.style = 'both';            end
if ~isfield(cfg, 'gridscale'),             cfg.gridscale = 67;            end
if ~isfield(cfg, 'interplimits'),          cfg.interplimits = 'head';     end
if ~isfield(cfg, 'interpolation'),         cfg.interpolation = 'v4';      end
if ~isfield(cfg, 'contournum'),            cfg.contournum = 6;            end
if ~isfield(cfg, 'colorbar'),              cfg.colorbar = 'no';           end
if ~isfield(cfg, 'shading'),               cfg.shading = 'flat';          end
if ~isfield(cfg, 'comment'),               cfg.comment = 'auto';          end
if ~isfield(cfg, 'commentpos'),            cfg.commentpos = 'leftbottom'; end
if ~isfield(cfg, 'fontsize'),              cfg.fontsize = 8;              end
if ~isfield(cfg, 'baseline'),              cfg.baseline = 'no';           end   %to avoid warning in timelock/freqbaseline
if ~isfield(cfg, 'trials'),                cfg.trials = 'all';            end
if ~isfield(cfg, 'interactive'),           cfg.interactive = 'no';        end
if ~isfield(cfg, 'renderer'),              cfg.renderer = [];             end   % matlab sets the default
if ~isfield(cfg, 'marker'),                cfg.marker = 'on';             end
if ~isfield(cfg, 'markersymbol'),          cfg.markersymbol = 'o';        end
if ~isfield(cfg, 'markercolor'),           cfg.markercolor = [0 0 0];     end
if ~isfield(cfg, 'markersize'),            cfg.markersize = 2;            end
if ~isfield(cfg, 'markerfontsize'),        cfg.markerfontsize = 8;        end
if ~isfield(cfg, 'highlight'),             cfg.highlight = 'off';         end
if ~isfield(cfg, 'highlightchannel'),      cfg.highlightchannel = 'all';  end
if ~isfield(cfg, 'highlightsymbol'),       cfg.highlightsymbol = '*';     end
if ~isfield(cfg, 'highlightcolor'),        cfg.highlightcolor = [0 0 0];  end
if ~isfield(cfg, 'highlightsize'),         cfg.highlightsize = 6;         end
if ~isfield(cfg, 'highlightfontsize'),     cfg.highlightfontsize = 8;     end
if ~isfield(cfg, 'labeloffset'),           cfg.labeloffset = 0.005;       end
if ~isfield(cfg, 'maskparameter'),         cfg.maskparameter = [];        end
if ~isfield(cfg, 'component'),             cfg.component = [];            end
if ~isfield(cfg, 'matrixside'),            cfg.matrixside = 'feedforward'; end

% compatability for previous highlighting option
if isnumeric(cfg.highlight)
  cfg.highlightchannel = cfg.highlight;
  cfg.highlight = 'on';
  warning('cfg.highlight is now used for specifing highlighting-mode, use cfg.highlightchannel instead of cfg.highlight for specifiying channels')
elseif iscell(cfg.highlight)
  if ~iscell(cfg.highlightchannel)
    cfg.highlightchannel = cell(1,length(cfg.highlight));
  end
  for icell = 1:length(cfg.highlight)
    if isnumeric(cfg.highlight{icell})
      cfg.highlightchannel{icell} = cfg.highlight{icell};
      cfg.highlight{icell} = 'on';
      warning('cfg.highlight is now used for specifing highlighting-mode, use cfg.highlightchannel instead of cfg.highlight for specifiying channels')
    end
  end
end

% Converting all higlight options to cell-arrays if they're not cell-arrays, to make defaulting and checking for backwards compatability and error
% checking much, much easier
if ~iscell(cfg.highlight),            cfg.highlight         = {cfg.highlight};            end
if ~iscell(cfg.highlightchannel),     cfg.highlightchannel  = {cfg.highlightchannel};     end
if ischar(cfg.highlightchannel{1}),   cfg.highlightchannel  = {cfg.highlightchannel};     end % {'all'} is valid input to channelselection, {1:5} isn't
if ~iscell(cfg.highlightsymbol),      cfg.highlightsymbol   = {cfg.highlightsymbol};      end
if ~iscell(cfg.highlightcolor),       cfg.highlightcolor    = {cfg.highlightcolor};       end
if ~iscell(cfg.highlightsize),        cfg.highlightsize     = {cfg.highlightsize};        end
if ~iscell(cfg.highlightfontsize),    cfg.highlightfontsize = {cfg.highlightfontsize};    end
% then make sure all cell-arrays for options have length ncellhigh and default the last element if not present
ncellhigh = length(cfg.highlight);
if length(cfg.highlightsymbol)    < ncellhigh,   cfg.highlightsymbol{ncellhigh}    = 'o';       end
if length(cfg.highlightcolor)     < ncellhigh,   cfg.highlightcolor{ncellhigh}     = [0 0 0];   end
if length(cfg.highlightsize)      < ncellhigh,   cfg.highlightsize{ncellhigh}      = 6;         end
if length(cfg.highlightfontsize)  < ncellhigh,   cfg.highlightfontsize{ncellhigh}  = 8;         end
% then default all empty cells
for icell = 1:ncellhigh
  if isempty(cfg.highlightsymbol{icell}),    cfg.highlightsymbol{icell} = 'o';     end
  if isempty(cfg.highlightcolor{icell}),     cfg.highlightcolor{icell} = [0 0 0];  end
  if isempty(cfg.highlightsize{icell}),      cfg.highlightsize{icell} = 6;         end
  if isempty(cfg.highlightfontsize{icell}),  cfg.highlightfontsize{icell} = 8;     end
end

% for backwards compatability
if strcmp(cfg.marker,'highlights')
  warning('using cfg.marker option -highlights- is no longer used, please use cfg.highlight')
  cfg.marker = 'off';
end

% check colormap is proper format and set it
if isfield(cfg,'colormap')
  if size(cfg.colormap,2)~=3, error('topoplot(): Colormap must be a n x 3 matrix'); end
  colormap(cfg.colormap);
end;

% Set x/y/zparam defaults according to data.dimord value:
if strcmp(data.dimord, 'chan_time')
  if ~isfield(cfg, 'xparam'),      cfg.xparam='time';         end
  if ~isfield(cfg, 'yparam'),      cfg.yparam='';             end
  if ~isfield(cfg, 'zparam'),      cfg.zparam='avg';          end
elseif strcmp(data.dimord, 'chan_freq')
  if ~isfield(cfg, 'xparam'),      cfg.xparam='freq';         end
  if ~isfield(cfg, 'yparam'),      cfg.yparam='';             end
  if ~isfield(cfg, 'zparam'),      cfg.zparam='powspctrm';    end
elseif strcmp(data.dimord, 'subj_chan_time') || strcmp(data.dimord, 'rpt_chan_time')
  tmpcfg = [];
  tmpcfg.trials = cfg.trials;
  data = ft_timelockanalysis(tmpcfg, data);
  if ~isfield(cfg, 'xparam'),      cfg.xparam='time';         end
  if ~isfield(cfg, 'yparam'),      cfg.yparam='';             end
  if ~isfield(cfg, 'zparam'),      cfg.zparam='avg';          end
elseif strcmp(data.dimord, 'subj_chan_freq') || strcmp(data.dimord, 'rpt_chan_freq')
  if isfield(data, 'crsspctrm'), data = rmfield(data, 'crsspctrm'); end % on the fly computation of coherence spectrum is not supported
  tmpcfg = [];
  tmpcfg.trials = cfg.trials;
  tmpcfg.jackknife = 'no';
  if isfield(cfg, 'zparam') && strcmp(cfg.zparam,'cohspctrm')
    % on the fly computation of coherence spectrum is not supported
  elseif isfield(cfg, 'zparam') && ~strcmp(cfg.zparam,'powspctrm')
    % freqdesctiptives will only work on the powspctrm field, hence a temporary copy of the data is needed
    tempdata.dimord    = data.dimord;
    tempdata.freq      = data.freq;
    tempdata.label     = data.label;
    tempdata.powspctrm = data.(cfg.zparam);
    tempdata.cfg       = data.cfg;
    tempdata           = ft_freqdescriptives(tmpcfg, tempdata);
    data.(cfg.zparam)  = tempdata.powspctrm;
    clear tempdata
  else
    data = ft_freqdescriptives(tmpcfg, data);
  end
  if ~isfield(cfg, 'xparam'),      cfg.xparam='freq';         end
  if ~isfield(cfg, 'yparam'),      cfg.yparam='';             end
  if ~isfield(cfg, 'zparam'),      cfg.zparam='powspctrm';    end
elseif strcmp(data.dimord, 'chan_freq_time')
  if ~isfield(cfg, 'xparam'),      cfg.xparam='time';         end
  if ~isfield(cfg, 'yparam'),      cfg.yparam='freq';         end
  if ~isfield(cfg, 'zparam'),      cfg.zparam='powspctrm';    end
elseif strcmp(data.dimord, 'subj_chan_freq_time') || strcmp(data.dimord, 'rpt_chan_freq_time')
  if isfield(data, 'crsspctrm'), data = rmfield(data, 'crsspctrm'); end % on the fly computation of coherence spectrum is not supported
  tmpcfg = [];
  tmpcfg.trials = cfg.trials;
  tmpcfg.jackknife = 'no';
  if isfield(cfg, 'zparam') && strcmp(cfg.zparam,'cohspctrm')
    % on the fly computation of coherence spectrum is not supported
  elseif isfield(cfg, 'zparam') && ~strcmp(cfg.zparam,'powspctrm')
    % freqdesctiptives will only work on the powspctrm field, hence a temporary copy of the data is needed
    tempdata.dimord    = data.dimord;
    tempdata.freq      = data.freq;
    tempdata.time      = data.time;
    tempdata.label     = data.label;
    tempdata.powspctrm = data.(cfg.zparam);
    tempdata.cfg       = data.cfg;
    tempdata           = ft_freqdescriptives(tmpcfg, tempdata);
    data.(cfg.zparam)  = tempdata.powspctrm;
    clear tempdata
  else
    data = ft_freqdescriptives(tmpcfg, data);
  end
  if ~isfield(cfg, 'xparam'),      cfg.xparam='time';         end
  if ~isfield(cfg, 'yparam'),      cfg.yparam='freq';         end
  if ~isfield(cfg, 'zparam'),      cfg.zparam='powspctrm';    end
elseif strcmp(data.dimord, 'chan_comp')
  % Add a pseudo-axis with the component numbers:
  data.comp = 1:size(data.topo,2);
  % Specify the components
  if ~isempty(cfg.component)
    data.comp = cfg.component;
    data.topo = data.topo(:,cfg.component);
  end
  % Rename the field with topographic label information:
  data.label = data.topolabel;
  if ~isfield(cfg, 'xparam'),      cfg.xparam='comp';         end
  if ~isfield(cfg, 'yparam'),      cfg.yparam='';             end
  if ~isfield(cfg, 'zparam'),      cfg.zparam='topo';         end
else
  if isfield(cfg, 'xparam') && isfield(cfg, 'zparam') && ~isfield(cfg, 'yparam')
    % user specified own fields, but no yparam (which is not asked in help)
    cfg.yparam = '';
  end
end

% Read or create the layout that will be used for plotting:
lay = ft_prepare_layout(cfg, data);
cfg.layout = lay;

% Create time-series of small topoplots:
if ~ischar(cfg.xlim) && length(cfg.xlim)>2
  % Switch off interactive mode:
  cfg.interactive = 'no';
  xlims = cfg.xlim;
  % Iteratively call topoplotER with different xlim values:
  for i=1:length(xlims)-1
    subplot(ceil(sqrt(length(xlims)-1)), ceil(sqrt(length(xlims)-1)), i);
    cfg.xlim = xlims(i:i+1);
    ft_topoplotER(cfg, data);
  end
  return
end

% Check for unconverted coherence spectrum data or any other bivariate metric:
dimtok  = tokenize(data.dimord, '_');
selchan = strmatch('chan', dimtok);
isfull  = length(selchan)>1;
if (strcmp(cfg.zparam,'cohspctrm') && isfield(data, 'labelcmb')) || ...
    (isfull && isfield(data, cfg.zparam)),
  
  % A reference channel is required:
  if ~isfield(cfg,'cohrefchannel'),
    error('no reference channel specified');
  end
  
  if strcmp(cfg.cohrefchannel, 'gui')
    % Open a single figure with the channel layout, the user can click on a reference channel
    h = clf;
    ft_plot_lay(lay, 'box', false);
    title('Select the reference channel by dragging a selection window, more than 1 channel can be selected...');
    % add the channel information to the figure
    info       = guidata(gcf);
    info.x     = lay.pos(:,1);
    info.y     = lay.pos(:,2);
    info.label = lay.label;
    guidata(h, info);
    %set(gcf, 'WindowButtonUpFcn', {@ft_select_channel, 'callback', {@select_topoplotER, cfg, data}});
    set(gcf, 'WindowButtonUpFcn',     {@ft_select_channel, 'multiple', true, 'callback', {@select_topoplotER, cfg, data}, 'event', 'WindowButtonUpFcn'});
    set(gcf, 'WindowButtonDownFcn',   {@ft_select_channel, 'multiple', true, 'callback', {@select_topoplotER, cfg, data}, 'event', 'WindowButtonDownFcn'});
    set(gcf, 'WindowButtonMotionFcn', {@ft_select_channel, 'multiple', true, 'callback', {@select_topoplotER, cfg, data}, 'event', 'WindowButtonMotionFcn'});
    return
  end
  
  if ~isfull,
    % only works explicitly with coherence FIXME
    % Convert 2-dimensional channel matrix to a single dimension:
    sel1           = strmatch(cfg.cohrefchannel, data.labelcmb(:,2));
    sel2           = strmatch(cfg.cohrefchannel, data.labelcmb(:,1));
    fprintf('selected %d channels for coherence\n', length(sel1)+length(sel2));
    data.cohspctrm = data.cohspctrm([sel1;sel2],:,:);
    data.label     = [data.labelcmb(sel1,1);data.labelcmb(sel2,2)];
    data.labelcmb  = data.labelcmb([sel1;sel2],:);
    data           = rmfield(data, 'labelcmb');
  else
    % general solution
    
    sel               = match_str(data.label, cfg.cohrefchannel);
    siz               = [size(data.(cfg.zparam)) 1];
    if strcmp(cfg.matrixside, 'feedback')
      data.(cfg.zparam) = reshape(mean(data.(cfg.zparam)(:,sel,:),2),[siz(1) 1 siz(3:end)]);
    elseif strcmp(cfg.matrixside, 'feedforward')
      data.(cfg.zparam) = reshape(mean(data.(cfg.zparam)(sel,:,:),1),[siz(1) 1 siz(3:end)]);
    elseif strcmp(cfg.matrixside, 'ff-fd')
      data.(cfg.zparam) = reshape(mean(data.(cfg.zparam)(sel,:,:),1),[siz(1) 1 siz(3:end)]) - reshape(mean(data.(cfg.zparam)(:,sel,:),2),[siz(1) 1 siz(3:end)]);
    elseif strcmp(cfg.matrixside, 'fd-ff')
      data.(cfg.zparam) = reshape(mean(data.(cfg.zparam)(:,sel,:),2),[siz(1) 1 siz(3:end)]) - reshape(mean(data.(cfg.zparam)(sel,:,:),1),[siz(1) 1 siz(3:end)]);
    end
  end
end

% Apply baseline correction:
if ~strcmp(cfg.baseline, 'no')
  if strcmp(cfg.xparam, 'freq') || strcmp(cfg.yparam, 'freq')
    data = ft_freqbaseline(cfg, data);
  else
    data = ft_timelockbaseline(cfg, data);
  end
end

% Get physical min/max range of x:
if strcmp(cfg.xlim,'maxmin')
  xmin = min(getsubfield(data, cfg.xparam));
  xmax = max(getsubfield(data, cfg.xparam));
else
  xmin = cfg.xlim(1);
  xmax = cfg.xlim(2);
end

% Replace value with the index of the nearest bin
xmin = nearest(getsubfield(data, cfg.xparam), xmin);
xmax = nearest(getsubfield(data, cfg.xparam), xmax);

% Get physical min/max range of y:
if ~isempty(cfg.yparam)
  if strcmp(cfg.ylim,'maxmin')
    ymin = min(getsubfield(data, cfg.yparam));
    ymax = max(getsubfield(data, cfg.yparam));
  else
    ymin = cfg.ylim(1);
    ymax = cfg.ylim(2);
  end
  
  % Replace value with the index of the nearest bin:
  ymin = nearest(getsubfield(data, cfg.yparam), ymin);
  ymax = nearest(getsubfield(data, cfg.yparam), ymax);
end

% make dat structure with one value for each channel
dat = getsubfield(data, cfg.zparam);
if ~isempty(cfg.yparam),
  dat = dat(:, ymin:ymax, xmin:xmax);
  dat = nanmean(nanmean(dat, 2), 3);
  % if a component is specified, do nothing
elseif ~isempty(cfg.component),
else
  dat = dat(:, xmin:xmax);
  dat = nanmean(dat, 2);
end
dat = dat(:);

% Select the channels in the data that match with the layout:
[seldat, sellay] = match_str(data.label, cfg.layout.label);
if isempty(seldat)
  error('labels in data and labels in layout do not match');
end

datavector = dat(seldat);
% Select x and y coordinates and labels of the channels in the data
chanX = cfg.layout.pos(sellay,1);
chanY = cfg.layout.pos(sellay,2);
chanLabels = cfg.layout.label(sellay);

% make datmask structure with one value for each channel
if ~isempty(cfg.maskparameter)
  datmask = getsubfield(data, cfg.maskparameter);
  if min(size(datmask)) ~= 1 || max(size(datmask)) ~= length(data.label)
    error('data in cfg.maskparameter should be vector with one value per channel')
  end
  datmask = datmask(:);
  % Select the channels in the maskdata that match with the layout:
  maskdatavector = datmask(seldat);
else
  maskdatavector = [];
end

% Get physical min/max range of z:
if strcmp(cfg.zlim,'maxmin')
  zmin = min(datavector);
  zmax = max(datavector);
elseif strcmp(cfg.zlim,'maxabs')
  zmin = -max(max(abs(datavector)));
  zmax = max(max(abs(datavector)));
else
  zmin = cfg.zlim(1);
  zmax = cfg.zlim(2);
end

% make comment
if strcmp(cfg.comment, 'auto')
  comment = date;
  if ~isempty(cfg.xparam)
    if strcmp(cfg.xlim,'maxmin')
      comment = sprintf('%0s\n%0s=[%.3g %.3g]', comment, cfg.xparam, data.(cfg.xparam)(xmin), data.(cfg.xparam)(xmax));
    else
      comment = sprintf('%0s\n%0s=[%.3g %.3g]', comment, cfg.xparam, cfg.xlim(1), cfg.xlim(2));
    end
  end
  if ~isempty(cfg.yparam)
    if strcmp(cfg.ylim,'maxmin')
      comment = sprintf('%0s\n%0s=[%.3g %.3g]', comment, cfg.yparam, data.(cfg.yparam)(ymin), data.(cfg.yparam)(ymax));
    else
      comment = sprintf('%0s\n%0s=[%.3g %.3g]', comment, cfg.yparam, cfg.ylim(1), cfg.ylim(2));
    end
  end
  if ~isempty(cfg.zparam)
    comment = sprintf('%0s\n%0s=[%.3g %.3g]', comment, cfg.zparam, zmin, zmax);
  end
  cfg.comment = comment;
elseif strcmp(cfg.comment, 'xlim')
  if strcmp(cfg.xlim,'maxmin')
    comment = sprintf('%0s=[%.3g %.3g]', cfg.xparam, data.(cfg.xparam)(xmin), data.(cfg.xparam)(xmax));
  else
    comment = sprintf('%0s=[%.3g %.3g]', cfg.xparam, cfg.xlim(1), cfg.xlim(2));
  end
  cfg.comment = comment;
elseif ~ischar(cfg.comment)
  error('cfg.comment must be string');
end
if isfield(cfg,'cohrefchannel')
  if iscell(cfg.cohrefchannel)
    cfg.comment = sprintf('%s\nreference=%s %s', comment, cfg.cohrefchannel{:});
  else
    cfg.comment = sprintf('%s\nreference=%s %s', comment, cfg.cohrefchannel);
  end
end

% Specify the x and y coordinates of the comment
if strcmp(cfg.commentpos,'layout')
  ind_comment = strmatch('COMNT', cfg.layout.label);
  x_comment = cfg.layout.pos(ind_comment,1);
  y_comment = cfg.layout.pos(ind_comment,2);
elseif strcmp(cfg.commentpos,'lefttop')
  x_comment = -0.7;
  y_comment =  0.6;
  HorAlign = 'left';
  VerAlign = 'top';
elseif strcmp(cfg.commentpos,'leftbottom')
  x_comment = -0.6;
  y_comment = -0.6;
  HorAlign = 'left';
  VerAlign = 'bottom';
elseif strcmp(cfg.commentpos,'middletop')
  x_comment =  0;
  y_comment =  0.75;
  HorAlign = 'center';
  VerAlign = 'top';
elseif strcmp(cfg.commentpos,'middlebottom')
  x_comment =  0;
  y_comment = -0.7;
  HorAlign = 'center';
  VerAlign = 'bottom';
elseif strcmp(cfg.commentpos,'righttop')
  x_comment =  0.65;
  y_comment =  0.6;
  HorAlign = 'right';
  VerAlign = 'top';
elseif strcmp(cfg.commentpos,'rightbottom')
  x_comment =  0.6;
  y_comment = -0.6;
  HorAlign = 'right';
  VerAlign = 'bottom';
elseif isnumeric(cfg.commentpos)
  x_comment = cfg.commentpos(1);
  y_comment = cfg.commentpos(2);
  HorAlign = 'left';
  VerAlign = 'middle';
  x_comment = 0.9*((x_comment-min(x))/(max(x)-min(x))-0.5);
  y_comment = 0.9*((y_comment-min(y))/(max(y)-min(y))-0.5);
end

% Draw topoplot
hold on
% Set ft_plot_topo specific options
if strcmp(cfg.interplimits,'head'),  interplimits = 'mask';
else interplimits = cfg.interplimits; end
if strcmp(cfg.style,'both');        style = 'surfiso';     end
if strcmp(cfg.style,'straight');    style = 'surf';         end
if strcmp(cfg.style,'contour');     style = 'iso';         end
if strcmp(cfg.style,'fill');        style = 'isofill';     end

% Draw plot
if ~strcmp(cfg.style,'blank')
  ft_plot_topo(chanX,chanY,datavector,'interpmethod',cfg.interpolation,...
    'interplim',interplimits,...
    'gridscale',cfg.gridscale,...
    'outline',lay.outline,...
    'shading',cfg.shading,...
    'isolines',cfg.contournum,...
    'mask',cfg.layout.mask,...
    'style',style,...
    'datmask', maskdatavector);
elseif ~strcmp(cfg.style,'blank')
  ft_plot_lay(lay,'box','no','label','no','point','no')
end

% Plotting markers for channels and/or highlighting a selection of channels
highlightchansel = []; % used for remembering selection of channels
templay.outline = lay.outline;
templay.mask    = lay.mask;
% For Highlight (channel-selection)
for icell = 1:length(cfg.highlight)
  if ~strcmp(cfg.highlight{icell},'off')
    [dum labelindex]   = match_str(ft_channelselection(cfg.highlightchannel{icell}, data.label), lay.label);
    highlightchansel   = [highlightchansel; match_str(data.label,ft_channelselection(cfg.highlightchannel{icell}, data.label))];
    templay.pos        = lay.pos(labelindex,:);
    templay.width      = lay.width(labelindex);
    templay.height     = lay.height(labelindex);
    templay.label      = lay.label(labelindex);
    if strcmp(cfg.highlight{icell}, 'labels') || strcmp(cfg.highlight{icell}, 'numbers')
      labelflg = 1;
    else
      labelflg = 0;
    end
    if strcmp(cfg.highlight{icell}, 'numbers')
      for ichan = 1:length(labelindex)
        templay.label{ichan} = num2str(match_str(data.label,templay.label{ichan}));
      end
    end
    ft_plot_lay(templay,'box','no','label',labelflg,'point','yes',...
      'pointsymbol',cfg.highlightsymbol{icell},...
      'pointcolor',cfg.highlightcolor{icell},...
      'pointsize',cfg.highlightsize{icell},...
      'labelsize',cfg.highlightfontsize{icell},...
      'labeloffset',cfg.labeloffset)
  end
end % for icell
% For Markers (all channels)
if ~strcmp(cfg.marker,'off')
  [dum labelindex] = match_str(ft_channelselection(setdiff(1:length(data.label),highlightchansel), data.label),lay.label);
  templay.pos      = lay.pos(labelindex,:);
  templay.width    = lay.width(labelindex);
  templay.height   = lay.height(labelindex);
  templay.label    = lay.label(labelindex);
  if strcmp(cfg.marker, 'labels') || strcmp(cfg.marker, 'numbers')
    labelflg = 1;
  else
    labelflg = 0;
  end
  if strcmp(cfg.marker, 'numbers')
    for ichan = 1:length(labelindex)
      templay.label{ichan} = num2str(match_str(data.label,templay.label{ichan}));
    end
  end
  ft_plot_lay(templay,'box','no','label',labelflg,'point','yes',...
    'pointsymbol',cfg.markersymbol,...
    'pointcolor',cfg.markercolor,...
    'pointsize',cfg.markersize,...
    'labelsize',cfg.markerfontsize,...
    'labeloffset',cfg.labeloffset)
end

% Set colour axis
caxis([zmin zmax]);

% Write comment
if ~strcmp(cfg.comment,'no')
  if strcmp(cfg.commentpos, 'title')
    title(cfg.comment, 'Fontsize', cfg.fontsize);
  else
    ft_plot_text(x_comment,y_comment, cfg.comment, 'Fontsize', cfg.fontsize, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');
  end
end

% plot colorbar:
if isfield(cfg, 'colorbar')
  if strcmp(cfg.colorbar, 'yes')
    colorbar;
  elseif ~strcmp(cfg.colorbar, 'no')
    colorbar('location',cfg.colorbar);
  end
end

% Set renderer if specified
if ~isempty(cfg.renderer)
  set(gcf, 'renderer', cfg.renderer)
end

% The remainder of the code is meant to make the figure interactive
hold on;

% Make the figure interactive
if strcmp(cfg.interactive, 'yes')
  % add the channel information to the figure
  info       = guidata(gcf);
  info.x     = lay.pos(:,1);
  info.y     = lay.pos(:,2);
  info.label = lay.label;
  guidata(gcf, info);
  
  if any(strcmp(data.dimord, {'chan_time', 'chan_freq', 'subj_chan_time', 'rpt_chan_time', 'chan_chan_freq'}))
    set(gcf, 'WindowButtonUpFcn',     {@ft_select_channel, 'multiple', true, 'callback', {@select_singleplotER, cfg, varargin{:}}, 'event', 'WindowButtonUpFcn'});
    set(gcf, 'WindowButtonDownFcn',   {@ft_select_channel, 'multiple', true, 'callback', {@select_singleplotER, cfg, varargin{:}}, 'event', 'WindowButtonDownFcn'});
    set(gcf, 'WindowButtonMotionFcn', {@ft_select_channel, 'multiple', true, 'callback', {@select_singleplotER, cfg, varargin{:}}, 'event', 'WindowButtonMotionFcn'});
  elseif any(strcmp(data.dimord, {'chan_freq_time', 'subj_chan_freq_time', 'rpt_chan_freq_time', 'rpttap_chan_freq_time'}))
    set(gcf, 'WindowButtonUpFcn',     {@ft_select_channel, 'multiple', true, 'callback', {@select_singleplotTFR, cfg, varargin{:}}, 'event', 'WindowButtonUpFcn'});
    set(gcf, 'WindowButtonDownFcn',   {@ft_select_channel, 'multiple', true, 'callback', {@select_singleplotTFR, cfg, varargin{:}}, 'event', 'WindowButtonDownFcn'});
    set(gcf, 'WindowButtonMotionFcn', {@ft_select_channel, 'multiple', true, 'callback', {@select_singleplotTFR, cfg, varargin{:}}, 'event', 'WindowButtonMotionFcn'});
  else
    error('unsupported dimord "%" for interactive plotting', data.dimord);
  end
end

axis off;
hold off;
axis equal;

% get the output cfg
cfg = checkconfig(cfg, 'trackconfig', 'off', 'checksize', 'yes');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION which is called after selecting channels in case of cfg.cohrefchannel='gui'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function select_topoplotER(label, cfg, varargin)

cfg.cohrefchannel = label;
fprintf('selected cfg.cohrefchannel = ''%s''\n', cfg.cohrefchannel{:});
p = get(gcf, 'Position');
f = figure;
set(f, 'Position', p);
cfg.highlight = 'on';
cfg.highlightsymbol  = '.';
cfg.highlightcolor   = 'r';
cfg.highlightsize = 20;
cfg.highlightchannel =  cfg.cohrefchannel;
ft_topoplotER(cfg, varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION which is called after selecting channels in case of cfg.interactive='yes'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function select_singleplotER(label, cfg, varargin)
if ~isempty(label)
  cfg.xlim = 'maxmin';
  cfg.channel = label;
  fprintf('selected cfg.channel = {');
  for i=1:(length(cfg.channel)-1)
    fprintf('''%s'', ', cfg.channel{i});
  end
  fprintf('''%s''}\n', cfg.channel{end});
  p = get(gcf, 'Position');
  f = figure;
  set(f, 'Position', p);
  ft_singleplotER(cfg, varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION which is called after selecting channels in case of cfg.interactive='yes'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function select_singleplotTFR(label, cfg, varargin)
if ~isempty(label)
  cfg.xlim = 'maxmin';
  cfg.ylim = 'maxmin';
  cfg.channel = label;
  fprintf('selected cfg.channel = {');
  for i=1:(length(cfg.channel)-1)
    fprintf('''%s'', ', cfg.channel{i});
  end
  fprintf('''%s''}\n', cfg.channel{end});
  p = get(gcf, 'Position');
  f = figure;
  set(f, 'Position', p);
  ft_singleplotTFR(cfg, varargin{:});
end
