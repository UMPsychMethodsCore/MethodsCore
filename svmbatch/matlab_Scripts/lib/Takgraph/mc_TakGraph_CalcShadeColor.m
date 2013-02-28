function [ a ] = mc_TakGraph_CalcShadeColor ( a )
% MC_TAKGRAPH_CalcShadeTransparency
%
%       INPUTS
%               a.cellcount.celltot     -       nNet x nNet matrix of how many edges in each cell were sig (pos or neg)
%               a.cellcount.cellpos     -       nNet x nNet matrix of how many edges in each cell were sig & positive
%
%       OUTPUTS
%               a.shading.color         -       nNet x nNet x 3 matrix of colors for shading. If you look along third
%                                               dimension you have RGB triples. If cell's sig edges are all positive,
%                                               it will be [1 0 0], if all negative, [0 0 1], if 50/50, [.5 0 .5], etc

a.shading.color=zeros([size(a.cellcount.celltot],3)); % initialize colors

cellpropPos = a.cellcount.cellpos ./ a.cellcount.celltot;
cellpropNeg = 1 - cellproppos;

cellpropPos(isnan(cellpropPos)) = 0; % zero out any NaN that might come from divide by 0
cellpropNeg(isnan(cellpropNeg)) = 0; % zero out any NaN that might come from divide by 0

a.shading.color(:,:,1) = cellpropPos;
a.shading.color(:,:,3) = cellpropNeg;
