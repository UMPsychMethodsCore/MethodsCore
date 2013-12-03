function [ a ] = mc_Network_CellLevelStats( a )
% MC_NETWORK_CellLevelstats 
% This function does cell level statistics on selected networks based on permutation results
% INPUT
%   REQUIRED
%         a.perms              -     Cell Counts resulting from permutation testing. We expect this to be a 3D array
%                                    First two dimensions index cell structure (Net x Net). Third dimension indexes repetitions
%         a.meanbperms         -     Cellwise beta mean resulting from permutation testing. We expect this to be a 3D array
%                                    First two dimensions index cell structure (Net x Net). Third dimension indexes repetitions%
%         a.cellcount.celltot  -     A nNet x nNet matrix that counts how many edges were "on" in each cell.
%         a.cellcount.cellmean -     A nNet x nNet matrix that calculates the cellwise mean of betas
%                                    As a result, this function should run after mc_NetworkCellcount.m
%         a.NetworkLabels      -     1 x nROI matrix of network labels. This will be used as is (no network expansion)
%    
%   OPTIONAL
%         a.stats.FDR.Enable   -     Set to 1 to enable FDR Correction. You then need to set options below. Defaults to 0
%         a.stats.FDR.NetIn    -     If you only want to do FDR correction on a subset of your networks, specify them here. You have two options
%                                       a - Provide a row vector networks to include. These should use the same range of values as in a.NetworkLabels
%                                       b - Provide a 2D logical square matrix with as many rows & columns as unique values in a.NetworkLabels. This allows you
%                                           maximum flexibility to turn some cells on and others off. Note, the lower triangle will be ignored regardless.        
%         a.stats.FDR.rate     -     The desired false discovery rate. {default: 0.05}
%         a.stats.FDR.mode     -     'pdep'  --- the original Bejnamini & Hochberg FDR procedure is used, which is guaranteed to be accurate if
%                                    the individual tests are independent or positively dependent (e.g., Gaussian variables that are positively correlated or
%                                    independent).
%                                    'dep'   --- the FDR procedure described in Benjamini & Yekutieli (2001) that is guaranteed
%                                    to be accurate for any test dependency structure (e.g.,Gaussian variables with any covariance matrix) is used. 'dep'
%                                    is always appropriate to use but is less powerful than 'pdep.
%                                    Default 'pdep'.
%         a.stats.FDR.CalcP    -     0 or 1. If set to 1, it will actually calculate adjusted p values. Defaults to 1.
%         a.stats.FDR.UseRawp  -     If you are supplying values in a.stats.rawp that you just want FDR corrected, set this field to 1
% OUTPUT
%         a.stats.rawp         -     Raw one-sided p-values arrived at by comparing each cell's total to the empirical distribution from the permutation
%         a.stats.brawp        -     Raw one-sided p-values arrived at by comparing each cell's total to the empirical distribution from the permutation
%   FDR ONLY
%         a.stats.FDR.hypo     -     Cell structure, 1st from cellcount stats, 2nd from cellmean stats.
%                                    Each subcell is a matrix of same size as a.stats.rawp. 
%                                       0 - Indicates non significant FDR result
%                                       1 - Indicates significant FDR result
%                                       2 - Indicates this cell not included in FDR correction (based on NetIn)        
%                                    p-value of the (i,j)th cell is significant (i.e., the null hypothesis of the test is rejected).
%         a.stats.FDR.adjp     -     Cell structure, 1st from cellcount stats, 2nd from cellmean stats.
%                                    Each subcell contains adjusted p values of each included cell.% This will be zero for any there were masked out by NetIn
% 2013/02 
if ~isfield(a,'stats')
    a.stats=struct();
end
if ~isfield(a.stats,'FDR')
    a.stats.FDR=struct();
    a.stats.FDR.Enable = 0;
end
if ~isfield(a.stats.FDR,'rate')
    a.stats.FDR.rate = 0.05;
end
if ~isfield(a.stats.FDR,'mode')
    a.stats.FDR.mode = 'pdep';
end
if ~isfield(a.stats.FDR,'CalcP')
    a.stats.FDR.CalcP = 1;
end

        
% Variable Initialization

permstot   = a.perms;
permsmeanb = a.meanbperms;
celltot    = a.cellcount.celltot;
cellmean   = a.cellcount.cellmean;
thresh     = a.stats.FDR.rate;
FDRmode    = a.stats.FDR.mode;
CalcP      = a.stats.FDR.CalcP;

if isfield(a,'stats') && isfield(a.stats,'FDR') && isfield(a.stats.FDR,'UseRawp') && a.stats.FDR.UseRawp==1 && isfield(a.stats,'rawp')
    epval.full = a.stats.rawp;
else
    for i = 1:size(celltot,1)
        for j = i:size(celltot,2)
            epval.full(i,j) = sum(celltot(i,j) <= squeeze(permstot(i,j,:)))/size(permstot,3);
        end
    end

    a.stats.rawp = epval.full;
end

if isfield(a,'stats') && isfield(a.stats,'FDR') && isfield(a.stats.FDR,'UseRawp') && a.stats.FDR.UseRawp==1 && isfield(a.stats,'brawp')
    epval.bfull = a.stats.brawp;
else
    for i = 1:size(celltot,1)
        for j = i:size(celltot,2)
            epval.bfull(i,j) = sum(abs(cellmean(i,j)) <= abs(squeeze(permsmeanb(i,j,:))))/size(permsmeanb,3); % Look at the absolute value of betas
        end
    end

    a.stats.brawp = epval.bfull;
end

if a.stats.FDR.Enable == 1 % only if asked to do FDR Correction

% Subset (Select the networks we want) 
    nets = sort(unique(a.NetworkLabels));
    NetSelect = zeros(numel(unique(a.NetworkLabels))); % initialize Netselect
    if ~isfield(a.stats.FDR,'NetIn')
        NetSelect(:) = 1; % select all nets
    elseif size(a.stats.FDR.NetIn,1) == 1 % row vector, mode a
        NetIncludeLogic = ismember(nets,a.stats.FDR.NetIn); % figure out which of networks we want to keep
        NetSelect(NetIncludeLogic,NetIncludeLogic) = 1; % grab all cells for implicated networks
    elseif (size(a.stats.FDR.NetIn,1) == size(a.stats.FDR.NetIn,2)) && numel(size(a.stats.FDR.NetIn)) == 2 % square matrix
        NetSelect = a.stats.FDR.NetIn; % use NetIn as is
    else
        error('Something seems wrong with a.stats.FDR.NetIn. Check the help');
    end
    NetSelect = logical(triu(NetSelect)); % discard lower triangle
    NetSelectIdx = find(NetSelect); % how to index directly into NetSelect
    
    epval.mini.flat{1} = epval.full(NetSelectIdx); % grab only the p values we care about
    epval.mini.flat{2} = epval.bfull(NetSelectIdx); % 1 is cellcount, 2 is cellmean
    
    for i = 1:2  % calculate adjusted p-values for both cellcount(i=1) and cellmean(i=2)
        % FDR (get the adjusted p-Values)
        [h, ~, adjp] = fdr_bh(epval.mini.flat{i},thresh,FDRmode,[],CalcP);
        
        a.stats.FDR.hypo{i} = ones(size(NetSelect)).*2; % initialize hypothesis tests and set all to 2 initially to indicate test was not run
        a.stats.FDR.hypo{i}(NetSelectIdx) = h;
        
        a.stats.FDR.adjp{i} = zeros(size(NetSelect)); % initialize adjusted p values
        a.stats.FDR.adjp{i}(NetSelectIdx) = adjp;
    end
end

