function [ a ] =  mc_TakGraph_AddShading( a )
%MC_TAKGRAPH_ADDSHADING 
% Based on the result of stats analysis, add shading over the TakGraph at
% the stats significant area
%       INPUTS
%                       a.shading.color         -       nNet x nNet x 3 matrix of colors to shade. Third dimension is an RGB triple.
%                                                       Alternatively, a RGB row vector to to be used as color for all cells    
%                       a.mediator.sorted       -       1 x nROI matrix of sorted network labels, which will help with finding the start and end point of each cell.
%                       a.stats.FDR.hypo        -       We will only shade cells where this value is 1    
%               OPTIONAL
%                       a.shading.transparency  -       nNet x nNet matrix of opacity values for shading. 0 is transparent, 1 opaque.
%                                                       Alternatively, provide a scalar, and all cells will have identical shading.
%                                                       Defaults to .3    
%                       a.shading.shademask     -       Allows you to override behavior of FDR correction result(a.stats.FDR.hypo). 
%                                                       nNet x nNet logical matrix of which cells to shade.
%                       a.mediator.pad          -       OPTIONAL - Number of blank rows and columns to draw around the figure for better graphics.

set(0,'currentfigure',a.h)
hold on;

if isfield(a.shading,'shademask') % if a shademask is given, use that
    shademask = a.shading.shademask;
else
    shademask = a.stats.FDR.hypo == 1;
end

if numel(size(a.shading.color)) < 3; % if only one color, replicate it
    shadecolor(1,1,:) = a.shading.color;
    shadecolor = repmat(shadecolor,[size(shademask), 1]);
else
    shadecolor = a.shading.color; % if it's an arrray, use it as is
end

% figure out transparency setting
if ~isfield(a.shading,'transparency') % if unset, default
    transp = .3;
elseif numel(a.shading.transparency) == 1 % if just one, replicate it
    transp = repmat(a.shading.transparency,size(shademask));
else % if a matrix, use as is
    transp = a.shading.transparency;
end
    
sorted       = a.mediator.sorted;

% if only one transparency is given, replicate it for use everywhere
if numel(transp)==1     
    transp=repmat(transp,size(shademask));
end

% do network subsetting, if enabled (see mc_TakGraph_plot for more details)
if isfield(a.mediator,'NetSubset')
    nets = sort(unique(sorted));
    % figure out logic for edges, and for cells
    NetLogic = ismember(sorted,a.mediator.NetSubset);
    CellLogic = ismember(nets,a.mediator.NetSubset);
    % apply filter
    sorted = sorted(NetLogic);
    transp = transp(CellLogic,CellLogic);
    shademask = shademask(CellLogic,CellLogic);
    shadecolor = shadecolor(CellLogic,CellLogic,:);
end

sorted_pad=ones(1,numel(sorted) + a.mediator.pad*2);
sorted_pad(1:a.mediator.pad) = -Inf;
sorted_pad((end - a.mediator.pad + 1) : end) = Inf;
sorted_pad((a.mediator.pad+1):(end - a.mediator.pad)) = sorted;


sorted_new = sorted_pad';
jumps=diff(sorted_new);
jumps(isnan(jumps)) = 0; % ignore all the Nan Jmps
breaks=[find(jumps)] + 0.5;
starts = breaks(1:(end-1));
stops = breaks(2:end);

for i = 1:size(shademask,1)
    for j = i:size(shademask,2)
        if shademask(i,j)
            if (i == j)  % half shading on the diagonal cells
                shade_x = [starts(j),stops(j),stops(j)];
                shade_y = [starts(i),starts(i),stops(i)];                          
                fill(shade_x,shade_y,squeeze(shadecolor(i,j,:))','FaceAlpha',transp(i,j));
            else
                shade_x = [starts(j),stops(j),stops(j),starts(j)];
                shade_y = [starts(i),starts(i),stops(i),stops(i)];                          
                fill(shade_x,shade_y,squeeze(shadecolor(i,j,:))','FaceAlpha',transp(i,j));
            end
        end          
    end
end



hold off;
end

