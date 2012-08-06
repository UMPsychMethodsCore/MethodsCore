function [varargout] = ft_plot_box(position, varargin);

% FT_PLOT_BOX plots the outline of a box that is specified by its lower
% left and upper right corner
%
% Use as
%    plot_box(position, ...)
% where the position of the box is specified as is [x1, x2, y1, y2].
% Optional arguments should come in key-value pairs and can include
%   'facealpha'   = transparency value between 0 and 1
%   'facecolor'   = color specification as [r g b] values or a string, for example 'brain', 'cortex', 'skin', 'red', 'r'
%   'edgecolor'   = color specification as [r g b] values or a string, for example 'brain', 'cortex', 'skin', 'red', 'r'
%   'hpos'        =
%   'vpos'        =
%   'width'       =
%   'height'      =
%   'hlim'        =
%   'vlim'        =
%
% Example
%   ft_plot_box([-1 1 2 3], 'facecolor', 'b')
%   axis([-4 4 -4 4])

% Copyrights (C) 2009, Robert Oostenveld
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
% $Id: ft_plot_box.m 1802 2010-09-29 12:17:39Z crimic $

warning('on', 'MATLAB:divideByZero');

% get the optional input arguments
keyvalcheck(varargin, 'optional', {'hpos', 'vpos', 'width', 'height', 'hlim', 'vlim', 'facealpha', 'facecolor', 'edgecolor'});
hpos        = keyval('hpos',      varargin);
vpos        = keyval('vpos',      varargin);
width       = keyval('width',     varargin);
height      = keyval('height',    varargin);
hlim        = keyval('hlim',      varargin);
vlim        = keyval('vlim',      varargin);
facealpha   = keyval('facealpha', varargin); if isempty(facealpha), facealpha = 1; end
facecolor   = keyval('facecolor', varargin); if isempty(facecolor), facecolor = 'none'; end
edgecolor   = keyval('edgecolor', varargin); if isempty(edgecolor), edgecolor = 'k'; end

% convert the two cornerpoints into something that the patch function understands
% the box position is represented just like the argument to the AXIS function
x1 = position(1);
x2 = position(2);
y1 = position(3);
y2 = position(4);
X = [x1 x2 x2 x1 x1];
Y = [y1 y1 y2 y2 y1];

if isempty(hlim) && isempty(vlim) && isempty(hpos) && isempty(vpos) && isempty(height) && isempty(width)
  % no scaling is needed, the input X and Y are already fine
  % use a shortcut to speed up the plotting

else
  % use the full implementation
  abc = axis;

  if isempty(hlim)
    hlim = abc([1 2]);
  end

  if isempty(vlim)
    vlim = abc([3 4]);
  end

  if isempty(hpos);
    hpos = (hlim(1)+hlim(2))/2;
  end

  if isempty(vpos);
    vpos = (vlim(1)+vlim(2))/2;
  end

  if isempty(width),
    width = hlim(2)-hlim(1);
  end

  if isempty(height),
    height = vlim(2)-vlim(1);
  end

  % first shift the horizontal axis to zero
  X = X - (hlim(1)+hlim(2))/2;
  % then scale to length 1
  X = X ./ (hlim(2)-hlim(1));
  % then scale to the new width
  X = X .* width;
  % then shift to the new horizontal position
  X = X + hpos;

  % first shift the vertical axis to zero
  Y = Y - (vlim(1)+vlim(2))/2;
  % then scale to length 1
  Y = Y ./ (vlim(2)-vlim(1));
  % then scale to the new width
  Y = Y .* height;
  % then shift to the new vertical position
  Y = Y + vpos;

end % shortcut

% use an arbitrary color, which will be replaced by the correct color a few lines down
C = 0;

h = patch(X, Y, C);
set(h, 'FaceAlpha', facealpha)
set(h, 'FaceColor', facecolor)
set(h, 'EdgeColor', edgecolor)

% the (optional) output is the handle
if nargout == 1
  varargout{1} = h;
end
