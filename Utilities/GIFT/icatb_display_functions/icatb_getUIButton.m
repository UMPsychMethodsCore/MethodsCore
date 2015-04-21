function [buttonHandle] = icatb_getUIButton(varargin)
% function used to plot button user control on figure
% Inputs: must be in pairs
% Output: handle of the control

% defaults
visible = 'on';
enable = 'on';
Tag = 'button';
label = '';
controlCallback = '';
fontWeight = 'normal';
userData = [];

% loop over number of arguments
for ii = 1:2:nargin
    if strcmp(lower(varargin{ii}), 'handles')
        Handle = varargin{ii + 1};
    elseif strcmp(lower(varargin{ii}), 'visible')
        visible = varargin{ii + 1};
    elseif strcmp(lower(varargin{ii}), 'enable')
        enable = varargin{ii + 1};
    elseif strcmp(lower(varargin{ii}), 'units')
        units = varargin{ii + 1};
    elseif strcmp(lower(varargin{ii}), 'position')
        pos = varargin{ii + 1};
    elseif strcmp(lower(varargin{ii}), 'tag')
        Tag = varargin{ii + 1};
    elseif strcmp(lower(varargin{ii}), 'label')
        label = varargin{ii + 1};
    elseif strcmp(lower(varargin{ii}), 'callback')
        controlCallback = varargin{ii + 1};
    elseif strcmp(lower(varargin{ii}), 'fontweight')
        fontWeight = varargin{ii + 1};
    elseif strcmp(lower(varargin{ii}), 'userdata')
        userData = varargin{ii + 1};
    end
end

if ~exist('units', 'var')
    error('Units are not specfied for text control');
end

if ~exist('pos', 'var')
    error('Position is not specfied for text control');
end

% Load defaults
icatb_defaults;
% Colors
global BUTTON_COLOR;
global BUTTON_FONT_COLOR;
% Fonts
global UI_FONTNAME;
global UI_FONTUNITS;
global UI_FS;

% Plot the button control on the handle specified
buttonHandle = uicontrol('parent', Handle, 'tag', Tag, 'string', label, 'units', units, ...
    'position', pos, 'fontunits', UI_FONTUNITS, 'fontname', UI_FONTNAME, 'FontSize', UI_FS, ...
    'style', 'text', 'ForegroundColor', BUTTON_FONT_COLOR, 'BackgroundColor', BUTTON_COLOR, 'Visible', visible, ...
    'enable', enable, 'callback', controlCallback, 'fontweight', fontWeight, 'userdata', userData);