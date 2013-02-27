function [ a ] = mc_TakGraph_plot( a )
% MC_TAKGRAPH_PLOT 
% This function will draw the basic structure of TakGraph:
%     The "on" edges, boundaries of cells, diagonal line. No Shading yet.
% Need to run mc_Network_mediator.m first to get the upper triangular matrix that we want to plot.
% If enlarged dots are desired, need to run mc_TakGraph_enlarge first to update the a.mediator.square
%
%       INPUTS
%                       a.colormap        -       A colormap object that will be directly indexed by pruneColor.values. 
%                                                 Defaults to 1 - white, 2 - red, 3 - blue        
%               a.mediator                      -       A set of variables that are useful for the following functions, and these variables contain:
%                       a.mediator.square       -       Transform a.pruneColor.values from a 1 x nFeat matrix to a sorted upper triangular matrix. 
%                       a.mediator.sorted       -       1 x nROI matrix of sorted network labels.
%
%       OUTPUTS
%               a.h       -       Handle to the graphics object

% Variable initialization
square = a.mediator.square;
if ~isfield(a,'colormap')
    a.colormap=[1 1 1; 1 0 0; 0 0 1];
end
map    = a.colormap;
sorted = a.mediator.sorted;

% Plot the edges
a.h = figure;
image(square);
colormap(map);
axis off;

hold on

% figure out jump points in labels
sorted_new = sorted';
jumps=diff(sorted_new);
starts=[1 ;find(jumps)];
stops=[find(jumps) - 1; size(sorted_new,1)];
starts = starts-0.5;
stops = stops + 0.5;

% Draw the diagonal line
n = size(starts,1);
plot([starts(1) stops(n)],[starts(1) stops(n)],'Color',[0.5 0.5 0.5]);


% Draw the Cell boudaries
for iBox=1:size(starts)    
    plot([starts(iBox) stops(n)],[starts(iBox) starts(iBox)],'Color',[0.5 0.5 0.5])
    plot([stops(iBox) stops(iBox)],[starts(1) stops(iBox)],'Color',[0.5 0.5 0.5])
end

hold off

end

