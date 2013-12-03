function [ a ] = mc_TakGraph_CalcShadeColor ( a, flag )
% MC_TAKGRAPH_CalcShadeColor
%
%       INPUTS
%               a.cellcount.celltot     -       nNet x nNet matrix of how many edges in each cell were sig (pos or neg)
%               a.cellcount.cellpos     -       nNet x nNet matrix of how many edges in each cell were sig & positive
%               a.cellcount.cellmean    -       nNet x nNet matrix of cellwise mean of beta values
%               flag                    -       A flag that indicating which parameter decides shading color
%                                               1: cell count
%                                               2: cell mean
%                                               Defaults to 1. 
%
%       OUTPUTS
%               a.shading.color         -       nNet x nNet x 3 matrix of colors for shading. If you look along third
%                                               dimension you have RGB triples. If cell's sig edges are all positive,
%                                               it will be [1 0 0], if all negative, [0 0 1], if 50/50, [.5 0 .5], etc

if ~exist('flag','var')
    flag = 1;
end

if flag~=1 && flag~=2
    warning('Could not recognize flag, default to 1: cellcount')
    flag = 1;
end

switch flag
    
    case 1
        a.shading.color=zeros([size(a.cellcount.celltot),3]); % initialize colors
        
        cellpropPos = a.cellcount.cellpos ./ a.cellcount.celltot;
        cellpropNeg = 1 - cellpropPos;
        
        cellpropPos(isinf(cellpropPos)) = 0; % zero out any Inf that might come from divide by 0
        cellpropNeg(isinf(cellpropNeg)) = 0; % zero out any Inf that might come from divide by 0
        
        a.shading.color(:,:,1) = cellpropPos;
        a.shading.color(:,:,3) = cellpropNeg;
        
    case 2
        cellmean = a.cellcount.cellmean;
        a.shading.color=zeros([size(cellmean),3]); % initialize colors
        % convert beta values to make it at the similar scale as cellpropPos
        % beta = 0 --> 0.5
        % max(abs(beta)) defines the boundary to 1 (or -1)
        m = 2*max(max(abs(cellmean)));
        cellmeanPos = cellmean./m+0.5;
        a.shading.color(:,:,1) = triu(cellmeanPos);
        a.shading.color(:,:,3) = triu(1 - cellmeanPos);       
        
end

