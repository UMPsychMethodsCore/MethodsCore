function [ a ] =  mc_TakGraph_AddColorbar( a )
%MC_TAKGRAPH_ADDCOLORBAR
% Simple function that adds a colorbar for easier interpretation of shading
%       INPUTS
%                       a.h                     -       Handle to TakGraph graphics object
%               OPTIONAL
%                       a.colorbar.startpt      -       1 x 2 coordinate of where to start colorbar
%                       a.colorbar.colors       -       nStep x 3 matrix of color steps
%                       a.colorbar.xsize        -       how big each color square should be in x (left/right)
%                       a.colorbar.ysize        -       how big each color square should be in y (down/up)
%               CURRENTLY DISABLED
%                       a.colorbar.text         -       nStep x 1 cell array of strings to label each step

% This function will add a series of labeled transparencies
% to your graph to provide it a key.
% INPUTS
% value - row vector of effect sizes
% transp - row vector of corresponding transparencies
% startpt - 1x2 vector of X, Y to be top left corner of first square
% xsize - how big each transparency square should be in x (left/right)
% ysize - how big each transparency square should be in y (down/up)
% Value labels will get written at the y start pt, mid way in X
% NOTE - top left corner of graph is (1,1)

set(0,'currentfigure',a.h)
hold on;


%% Set some defaults

if ~isfield(a,'colorbar')
a.colorbar = struct();
end


if ~isfield(a.colorbar,'startpt')
    a.colorbar.startpt = [20 600];
end

if ~isfield(a.colorbar,'colors')
    a.colorbar.colors = zeros(11,3);
    a.colorbar.colors(:,1) = 0:.1:1;
    a.colorbar.colors(:,3) = 1:-.1:0;
end

if ~isfield(a.colorbar,'text');
    range = 0:.1:1;
    for i = 1:size(a.colorbar.colors,1)
        a.colorbar.text{i} = num2str(range(i));
    end
end


if ~isfield(a.colorbar,'xsize')
    a.colorbar.xsize = 20;
end

if ~isfield(a.colorbar,'ysize')
    a.colorbar.ysize = 40;
end

if ~isfield(a.shading,'transparency')
    transp = .3;
end
    
%% add the colorbar    
colors = a.colorbar.colors;

curx = a.colorbar.startpt(1);
cury = a.colorbar.startpt(2);

xsize = a.colorbar.xsize;
ysize = a.colorbar.ysize;

for i = 1:size(a.colorbar.colors,1)
    % Setup the offsets
    rx = curx;
    bx = curx+xsize;
    yx = curx+xsize*2;

    % Draw the boxes
    fill(...
    [rx, rx+xsize, rx+xsize,rx],...
    [cury, cury, cury+ysize, cury+ysize],...
    squeeze(colors(i,:)), 'FaceAlpha',transp, 'EdgeColor','none');


    % Add the textlabel
    curstring =  a.colorbar.text{i};

%    text(curx,cury - 20,curstring);

    curx = curx + xsize; % increment x left to right


end


hold off;
