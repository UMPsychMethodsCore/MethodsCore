function [ a ] = mc_Network_TakGraph_boss( a )
% MC_NETWORK_TAKGRAPH_BOSS
%
% The boss function combines the whole flow of TakGraph generation, including cell counts,
% cell statistics, graph plot, enlarging dots, and add shading
% 
% INPUTS
%               REQUIRED
%                       a.values                -       1 x nFeat matrix of feature values
%                                                       For downstream functions to work, only allowed values are...
%                                                               1 - Edge Not Significant
%                                                               2 - Edge Significant & Positive
%                                                               3 - Edge Significant & Negative    
%                       a.NetworkLabels         -       1 x nROI matrix of network labels. This will be used as is (no network expansion)
%                       a.perms                 -       Cell Counts resulting from permutation testing. We expect this to be a 3D array
%                                                       First two dimensions index cell structure (Net x Net). Third dimension indexes repetitions    
%               OPTIONAL
%                       a.stats.FDR.Enable      -       Set to 1 to enable FDR Correction. You then need to set options below. Defaults to 1 for TakGraph flow.
%                       a.stats.FDR.NetIn       -       If you only want to do FDR correction on a subset of your networks, specify them here. You have two options
%                                                           a - Provide a row vector networks to include. These should use the same range of values as in a.NetworkLabels
%                                                           b - Provide a 2D logical square matrix with as many rows & columns as unique values in a.NetworkLabels. 
%                                                           This allows you maximum flexibility to turn some cells on and others off. Note, the lower triangle will be ignored regardless.        
%                       a.stats.FDR.rate        -       The desired false discovery rate. {default: 0.05}
%                       a.stats.FDR.mode        -       'pdep'  --- the original Bejnamini & Hochberg FDR procedure is used, which is guaranteed to be accurate if
%                                                       the individual tests are independent or positively dependent (e.g., Gaussian variables that are positively correlated or
%                                                       independent).
%                                                       'dep'   --- the FDR procedure described in Benjamini & Yekutieli (2001) that is guaranteed
%                                                       to be accurate for any test dependency structure (e.g.,Gaussian variables with any covariance matrix) is used. 'dep'
%                                                       is always appropriate to use but is less powerful than 'pdep.
%                                                       Default 'pdep'.
%                       a.stats.FDR.CalcP       -       0 or 1. If set to 1, it will actually calculate adjusted p values. Defaults to 1.
%                       a.DotDilateMat          -       Your dilation matrix. Your original square matrix mat will be a nOffset*2 matrix of offsets that you wish to expand
%                                                       For example, to enlarge the dots by adding dots above, below, and to either side, use:
%                                                       a.DotDilateMat = [1 0; -1 0; 0 1; 0 -1];
%                       a.colormap              -       A colormap object that will be directly indexed by a.values.
%                                                       Defaults to 1 - white, 2 - red, 3 - blue.
%                       a.shading.enable        -       0 - turn off shading
%                                                       1 - turn on shading
%                                                       Defaults to 1.
%                       a.shading.transparency  -       nNet x nNet matrix of opacity values for shading. 0 is transparent, 1 opaque.
%                                                       Alternatively, provide a scalar, and all cells will have identical shading.
%                                                       Defaults to .3    
%                       a.shading.shademask     -       nNet x nNet logical matrix of which cells to shade. 
%                                                       Allows you to override behavior of FDR correction result (a.stats.FDR.hypo).    
%
% OUTPUTS (only list the useful results here)
% 
%                       a.cellcount.cellsize  -       A nNet x nNet matrix that counts of number of edges in each cell.
%                       a.cellcount.celltot   -       A nNet x nNet matrix that counts how many edges were "on" in each cell.
%                       a.cellcount.cellpos   -       A nNet x nNet matrix that counts how many edges were "on" and "positive" in each cell.
%                       a.cellcount.cellpos   -       A nNet x nNet matrix that counts how many edges were "on" and "negative" in each cell.
%                       a.stats.rawp          -       Raw one-sided p-values arrived at by comparing each cell's total to the empirical distribution from the permutation
%
%                 FDR CORRECTION ONLY
%                       a.stats.FDR.hypo      -       Matrix of same size as a.stats.rawp. 
%                                                        0 - Indicates non significant FDR result
%                                                        1 - Indicates significant FDR result
%                                                        2 - Indicates this cell not included in FDR correction (based on NetIn)        
%                                                      p-value of the (i,j)th cell is significant (i.e., the null hypothesis of the test is rejected).
%                       a.stats.FDR.adjp     -         Adjusted p values of each included cell.% This will be zero for any there were masked out by NetIn

%                       a.h                   -       Handle to the graphics object of TakGraph


%% Restructure Your Features

a = mc_Network_FeatRestruct(a);

%% Count your cells

a = mc_Network_CellCount(a);

%% Calculate CellLevel Statistics

if ~isfield(a,'stats')
    a.stats=struct();
end
if ~isfield(a.stats,'FDR')
    a.stats.FDR=struct();
    a.stats.FDR.Enable = 1;
end

a = mc_Network_CellLevelStats(a);


%% Enlarge dots

if isfield(a,'DotDilateMat')
    a = mc_TakGraph_enlarge(a);
end

%% Plot Edges and Cell Boundaries

a = mc_TakGraph_plot(a);

%% Calculate Shading Color

if ~isfield(a,'shading')
    a.shading = struct();
end
if ~isfield(a.shading,'enable')
    a.shading.enable = 1;
end

if isfield(a,'shading') && isfield(a.shading,'enable') && a.shading.enable==1
    
    a = mc_TakGraph_CalcShadeColor(a);
    
    a = mc_TakGraph_addshading(a);
    
end


end

