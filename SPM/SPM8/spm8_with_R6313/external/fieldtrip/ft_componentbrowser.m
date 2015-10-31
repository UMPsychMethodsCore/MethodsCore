function [varargout] = ft_componentbrowser(cfg, comp)

% FT_COMPONENTBROWSER plots topography and activations of ICA components
%
% Use as
%   ft_componentbrowser(cfg, comp)
% where comp is a FieldTrip structure obtained from FT_COMPONENTANALYSIS.
%
% The configuration has the following parameters:
% cfg.comp   = a vector with the components to plot (ex. 1:10) (optional)
% cfg.trial  = choose which trial to plot first (optional, only one trial)
% cfg.layout = because the output of componentanalysis does not contain
%   information on the layout, you need to specify in a variety of ways:
%  - you can provide a pre-computed layout structure (see prepare_layout)
%  - you can give the name of an ascii layout file with extension *.lay
%  - you can give the name of an electrode file
%  - you can give an electrode definition, i.e. "elec" structure
%  - you can give a gradiometer definition, i.e. "grad" structure
%
% See also FT_COMPONENTANALYSIS

% Copyright (C) 2009, Giovanni Piantoni
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
% $Id: ft_componentbrowser.m 2675 2011-01-26 16:03:16Z jorhor $

ft_defaults

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check that the data comes from componentanalysis
comp = ft_checkdata(comp, 'datatype', 'comp');

% set the defaults:
if ~isfield(cfg, 'comp'),   cfg.comp  = 1:10; end
if ~isfield(cfg, 'trial'),  cfg.trial = 1;    end

if numel(cfg.trial) > 1,
  warning('componentbrowser:cfg_onetrial', 'only one trial can be plotted at the time');
  cfg.trial = cfg.trial(1);
end

% Read or create the layout that will be used for plotting:
[cfg.layout] = ft_prepare_layout(cfg, comp);

% Identify the channels to plot
[labels, cfg.chanidx.lay, cfg.chanidx.comp] = intersect(cfg.layout.label, comp.topolabel); % in case channels are missing
if isempty(cfg.chanidx.lay)
  error('componentbrowser:labelmismatch', 'The channel labels in the data do not match the labels of the layout');
end

% fixed variables
cfg.shift   = 1.2;   % distance between topoplots

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create figure and assign userdata
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% create figure and axes
cfg.h    = figure('uni','pix', 'name', 'componentbrowser', 'vis', 'off', 'numbertitle', 'off');
cfg.axis = axes;
hold on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Buttons and Callbacks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% scroll components
uicontrol(cfg.h,'uni','pix','pos',[105 5 25 18],'str','-',...
  'call',{@plottopography, comp});

cfg.ncomp = uicontrol(cfg.h,'sty','text','uni','pix','pos',[130 5 150 18],...
  'str',['comp n.' num2str(cfg.comp(1)) '-' num2str(cfg.comp(end))]);

uicontrol(cfg.h,'uni','pix','pos',[280 5 25 18],'str','+',...
  'call',{@plottopography, comp});

% scroll trials
uicontrol(cfg.h,'uni','pix','pos',[330 5 25 18],'str','<<',...
  'call',{@plotactivation, comp});

uicontrol(cfg.h,'uni','pix','pos',[355 5 25 18],'str', '<',...
  'call',{@plotactivation, comp});

cfg.ntrl = uicontrol(cfg.h,'sty','text','uni','pix','pos',[380 5 70 18],...
  'str',['trial n.' num2str(cfg.trial)]);

uicontrol(cfg.h,'uni','pix','pos',[450 5 25 18],'str', '>',...
  'call',{@plotactivation, comp});

uicontrol(cfg.h,'uni','pix','pos',[475 5 25 18],'str','>>',...
  'call',{@plotactivation, comp});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First callback and final adjustments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% first call of the two plotting functions
plottopography([], cfg, comp)
plotactivation([], cfg, comp)

% final adjustments
set(cfg.h, 'vis', 'on')
axis equal
axis off
hold off

% the (optional) output is the handle
if nargout == 1;
  varargout{1} = cfg.h;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTTOPOGRAPHY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plottopography(h, cfg, comp)
% now plottopography is not associated with a callback, but it might in
% the future

if isempty(h) % when called in isolation
  set(cfg.h, 'user', cfg)
else
  cfg = get(get(h, 'par'), 'user');

  % which button has been pressed
  if intersect(h, findobj(cfg.h, 'str', '+'))

    cfg.comp = cfg.comp + numel(cfg.comp);
    if cfg.comp(end) > size(comp.label,1)
      cfg.comp = cfg.comp - (cfg.comp(end) - size(comp.label,1));
    end

  elseif intersect(h, findobj(cfg.h, 'str', '-'))

    cfg.comp = cfg.comp - numel(cfg.comp);
    if cfg.comp(1) < 1
      cfg.comp = cfg.comp - cfg.comp(1) + 1;
    end

  end
end

set(cfg.ncomp, 'str', ['comp n.' num2str(cfg.comp(1)) '-' num2str(cfg.comp(end))])
drawnow
delete(findobj(cfg.h, 'tag', 'comptopo'))

cnt = 0;
for k = cfg.comp
  cnt = cnt + 1;

  % write number of the component on the left
  h_text(cnt) = ft_plot_text(-2.5, -cnt*cfg.shift, ['n. ' num2str(cfg.comp(cnt))]);

  % plot only topography (*and* layout)
    ft_plot_topo(cfg.layout.pos(cfg.chanidx.lay,1), cfg.layout.pos(cfg.chanidx.lay,2), ...
    comp.topo(cfg.chanidx.comp, k)./max(abs(comp.topo(cfg.chanidx.comp, k))), ... % for proper scaling
    'hpos', -1, 'vpos', -cnt*cfg.shift, 'mask', cfg.layout.mask, ...
    'interplim','mask', 'outline',cfg.layout.outline);
end

h_topo = findobj(cfg.h, 'type', 'surface');

set(h_text, 'tag', 'comptopo')
set(h_topo, 'tag', 'comptopo')

% in the colorbar, green should be zero
set(cfg.axis, 'clim', [-1 1])

plotactivation([], cfg, comp)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOTACTIVATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotactivation(h, cfg, comp)
% plotactivation can be called in isolation or by buttondownfcn
% cfg is stored in 'user' of the main figure

if isempty(h) % when called in isolation
  set(cfg.h, 'user', cfg)
else
  cfg = get(get(h, 'par'), 'user');

  % which button has been pressed
  if     intersect(h, findobj(cfg.h, 'str', '>>'))

    cfg.trial = cfg.trial + 10;
    if cfg.trial > size(comp.trial,2)
      cfg.trial = size(comp.trial,2);
    end

  elseif intersect(h, findobj(cfg.h, 'str', '>'))

    cfg.trial = cfg.trial + 1;
    if cfg.trial > size(comp.trial,2)
      cfg.trial = size(comp.trial,2);
    end
    
  elseif intersect(h, findobj(cfg.h, 'str', '<'))

    cfg.trial = cfg.trial - 1;
    if cfg.trial < 1
      cfg.trial = 1;
    end

  elseif intersect(h, findobj(cfg.h, 'str', '<<'))

    cfg.trial = cfg.trial - 10;
    if cfg.trial < 1
      cfg.trial = 1;
    end

  end
end

set(cfg.ntrl,'str',['trial n. ' num2str(cfg.trial)])
drawnow
delete(findobj(cfg.h,'tag', 'activations'));

hold on
cnt = 0;
for k = cfg.comp
  cnt = cnt + 1;

  % plot the activations
  h_act(cnt) = ft_plot_vector(comp.trial{cfg.trial}(k,:), 'hpos', 6 , 'vpos', -cnt*cfg.shift, 'width', 12, 'height', 1, 'box', true);
end

h_inv = plot(6+12+1, -cnt*cfg.shift, '.'); %
set(h_inv, 'vis', 'off')

set(h_act, 'tag', 'activations')
set(cfg.h, 'user', cfg)
hold off
