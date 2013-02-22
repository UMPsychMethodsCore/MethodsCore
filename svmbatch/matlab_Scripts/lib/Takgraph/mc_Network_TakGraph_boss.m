function [ h,a ] = mc_Network_TakGraph_boss( a )
% MC_NETWORK_TAKGRAPH_BOSS
%
% The boss function combines the whole flow of TakGraph generation, including cell counts,
% cell statistics, graph plot, enlarging dots, and add shading
% 
% INPUTS
%               REQUIRED
%                       a.prune                 -       1 x nFeat logical matrix of features to plot
%                       a.NetworkLabels         -       1 x nROI matrix of network labels. This will be used literally.
%               OPTIONAL
%                       a.DotDilateMat          -       Matrix of offsets to expand dots on the Takgraph by. This should be nOffset x 2.
%                       a.pruneColor.values     -       1 x nFeat matrix of color values that will index into a.pruneColor.map
%                       a.pruneColor.map        -       A colormap object that will be directly indexed by pruneColor.values. 
%                       a.stats.StatMode        -       0, 1 or 2 to indicate how what the null hypothesis for each cell is, defaults to 2 if unset.
%                                                       0 - use consensus size portion(total edge number / total cell size) to be the expected probability.
%                                                       This is appropriate when analyzing a feature set arrived at by consensus. This will use 
%                                                       size(consensus)/size(all edges) as the null rate. In those mode it is not necessary to set a.stats.NullRate
%                                                       1 - use NullRate to be the null rate. 
%                                                       This is appropriate when your features were selected in a mass univariate stream. You should
%                                                       then set a.stats.NullRate to the alpha that was used as the threshold in mass univariate stats.
%                                                       That way, it will test the null hypothesis that the number of implicated edges in a given network
%                                                       intersection is less than or equal to the number expected by chance (e.g. alpha is .05, 
%                                                       so the null is that <= 5% of the edges in each network intersection will have been identified).
%                                                       2 - Rather than using a binomial test, threshold based on an empirical probability density function, most likely 
%                                                       coming from permutation simulations. If you specify this, you will also need to supply a.stats.ePDF. We still
%                                                       use a.stats.CellAlpha as the criterion, but it will be calculated by finding the proportion of cell counts
%                                                       in ePDF that are greater than or equal to the observed count. 
%                       a.stats.ePDF(NEED EDIT no default value yet)       -         A 3D array. First two dimensions will index networks (and together index cells), third dimension will index repetitions.
%                                                       The value in each of the elements is the observed number of suprathreshold edges. Be careful that your CellAlpha matches
%                                                       the conditions of your simulation.
%                       a.stats.NullRate      -         Only matters if a.stats.StatMode is set to 1
%                                                       The expected probability in mode 1. Defaults to 0.001 if not set.
%                       a.stats.CellAlpha     -         The alpha level used to threshold the cell-level test for more edges than chance. If you want to correct
%                                                       for multiple comparisons, reflect it in this setting. Defaults to .05/# of unique cells if unset.        
%                       a.stats.SignAlpha     -         The alpha level used for the binomial sign test. Defaults to 0.05 if unset.
%                       a.shading.transmode   -         Shading mode, defaults to 0 if unset.
%                                                       1  - Scaled transparency  
%                                                       0  - Single transparency
%                       a.shading.trans0      -         Single transparency value if shading mode is set to 0. Defaults to 0.5 if unset
%                       a.shading.trans1(NEED EDIT no default value yet)       -         A set of options including range, scale, etc. when shading mode is set to 1.
%
% OUTPUTS (only list the useful results here)
% 
%                       a.cellcount.cellsize  -       A nNet x nNet matrix that counts of number of edges in each cell.
%                       a.cellcount.celltot   -       A nNet x nNet matrix that counts how many edges were "on" in each cell.
%                       a.cellcount.cellpos   -       A nNet x nNet matrix that counts how many edges were "on" and "positive" in each cell.
%                       a.cellcount.cellpos   -       A nNet x nNet matrix that counts how many edges were "on" and "negative" in each cell.
%                       a.stats.cellsign      -       A nNet x nNet matrix: whether a given cell was selected as having more edges "on" than expected by chance. Coding is...
%                                                               1 - Not significant
%                                                               2 - Positive signicant
%                                                               3 - Negative significant
%                                                               4 - Undirectional Significant                    
%                       a.stats.cellsig       -       Log10 of p-value for each cell   
%                       h                     -       Handle to the graphics object of TakGraph



a = mc_Network_mediator(a);

a = mc_Network_Cellcount(a);

a = mc_Network_Cellstats(a);

if isfield(a,'DotDilateMat')
    a = mc_TakGraph_enlarge(a);
end

[h,a] = mc_TakGraph_plot(a);

if isfield(a,'shading') && isfield(a.shading,'enable') && a.shading.enable==1
    
    a = mc_TakGraph_shadingtrans(a);
    
    mc_TakGraph_addshading(a);
    
end




end

