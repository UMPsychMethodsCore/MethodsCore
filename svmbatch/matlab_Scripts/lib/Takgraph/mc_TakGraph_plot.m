function [ a ] = mc_TakGraph_plot( a )
% MC_TAKGRAPH_PLOT
% This function will draw the basic structure of TakGraph:
%     The "on" edges, boundaries of cells, diagonal line. No Shading yet.
% Need to run mc_Network_mediator.m first to get the upper triangular matrix that we want to plot.
% If enlarged dots are desired, need to run mc_TakGraph_enlarge first to update the a.mediator.square
%
%       INPUTS
%               a.colormap                      -       A colormap object that will be directly indexed by a.values.
%                                                       Defaults to 1 - white, 2 - red, 3 - blue
%               a.mediator                      -       A set of variables that are useful for the following functions, and these variables contain:
%                       a.mediator.tsquare      -       Transform a.tvalues from a 1 x nFeat matrix to a sorted upper triangular matrix.
%                       a.mediator.sorted       -       1 x nROI matrix of sorted network labels.
%                       a.mediator.NetSubset    -       OPTIONAL - Contiguous vector of network labels to plot
%                       a.mediator.pad          -       OPTIONAL - Number of blank rows and columns to draw around the figure for better graphics.
%                                                       If unspecified, this will default to 10
%               a.dotenable                    -        0 - No dot shading, plot dots with binary colors
%                                                       1 - Do dot shading, plot dots with gradual changing colors
%                                                       If enabled to 1, a.colormap will be disregared, instead the colormap will be calculated based on dot values.
%              
%
%       OUTPUTS
%               a.h                             -       Handle to the graphics object

% Variable initialization

if ~isfield(a.mediator,'pad')
    a.mediator.pad = 10;
end

tsquare = a.mediator.tsquare;

if ~isfield(a,'colormap')
    a.colormap=[1 1 1; 1 0 0; 0 0 1];
end

if ~isfield(a,'dotenable')
    a.dotenable=0;
end

sorted = a.mediator.sorted;
graphtitle=a.title;

if isfield(a.mediator,'NetSubset')
    NetLogic = ismember(sorted,a.mediator.NetSubset);
    tsquare = tsquare(NetLogic,NetLogic);
    sorted = sorted(NetLogic);
end

a.h = figure;
if a.dotenable==1
    % add the padding to square and sorted
    square_pad = zeros(size(tsquare) + a.mediator.pad*2);
    square_pad((a.mediator.pad+1):(end - a.mediator.pad),(a.mediator.pad+1):(end - a.mediator.pad) ) = tsquare;
    sorted_pad=zeros(1,numel(sorted) + a.mediator.pad*2);
    % Plot the edges
    imshow(square_pad);
    a.colormap=b2r(min(tsquare(:)),max(tsquare(:)));
    colormap(a.colormap);
    colorbar;
else
    square_pad = ones(size(tsquare) + a.mediator.pad*2);
    square_pad((a.mediator.pad+1):(end - a.mediator.pad),(a.mediator.pad+1):(end - a.mediator.pad) ) = tsquare;
    sorted_pad=ones(1,numel(sorted) + a.mediator.pad*2);
    image(square_pad);
    colormap(a.colormap);    
end

sorted_pad(1:a.mediator.pad) = -Inf;
sorted_pad((end - a.mediator.pad + 1) : end) = Inf;
sorted_pad((a.mediator.pad+1):(end - a.mediator.pad)) = sorted;
title(graphtitle,'Interpreter','none'); % Ignore any possible underscore
axis off;

hold on

% figure out jump points in labels
sorted_new = sorted_pad';
jumps=diff(sorted_new);
jumps(isnan(jumps)) = 0; % ignore all the Nan Jmps
breaks=[find(jumps)] + 0.5;
starts = breaks(1:(end-1));
stops = breaks(2:end);
% Draw the diagonal line
n = size(starts,1);
plot([starts(1) stops(n)],[starts(1) stops(n)],'Color',[0.5 0.5 0.5]);


% Draw the Cell boudaries
for iBox=1:size(starts)
    plot([starts(iBox) stops(n)],[starts(iBox) starts(iBox)],'Color',[0.5 0.5 0.5])
    plot([stops(iBox) stops(iBox)],[starts(1) stops(iBox)],'Color',[0.5 0.5 0.5])
end

hold off
set(a.h,'Visible','on')

end

