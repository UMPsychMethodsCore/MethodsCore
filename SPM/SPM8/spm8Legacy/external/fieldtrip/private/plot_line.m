function plot_line(X, Y, varargin)

% PLOT_LINE

% Copyrights (C) 2009, Robert Oostenveld
%
% $Log: plot_line.m,v $
% Revision 1.5  2009/07/14 16:13:14  roboos
% speed up the plotting if no rescaling needs to be done
%
% Revision 1.4  2009/04/14 19:48:28  roboos
% added keyvalcheck
%
% Revision 1.3  2009/04/14 14:31:08  roboos
% many small changes to make it fully functional
%

% get the optional input arguments
keyvalcheck(varargin, 'optional', {'hpos', 'vpos', 'width', 'height', 'hlim', 'vlim', 'color', 'linestyle'});
hpos        = keyval('hpos',      varargin);
vpos        = keyval('vpos',      varargin);
width       = keyval('width',     varargin);
height      = keyval('height',    varargin);
hlim        = keyval('hlim',      varargin);
vlim        = keyval('vlim',      varargin);
color       = keyval('color',     varargin); if isempty(color), color = 'k'; end
linestyle   = keyval('linestyle', varargin); if isempty(linestyle), linestyle = '-'; end

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

h = line(X, Y);
set(h, 'Color', color);
set(h, 'LineStyle', linestyle);


