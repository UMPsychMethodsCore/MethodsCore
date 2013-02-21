function [ a ] = mc_Network_Cellstats( a )
%MC_NETWORK_CELLSTATS 
% This function will implement do the statistics to decide whether a given cell was selected as having more edges "on" than expected by chance, and the direction 
% of the significant cells. This function also calculates the Log10 of p-values of each cell.
% 
%       INPUTS
%               a.prune                         -       1 x nFeat logical matrix of features
%               a.NetworkLabels                 -       1 x nROI matrix of network labels. This will be used literally.
% 
%               a.cellcount                     -       A set of cell count values: cell size, number of positive points, negative points in each cell
%                       a.cellcount.cellsize    -       A nNet x nNet matrix that counts of number of edges in each cell.
%                       a.cellcount.celltot     -       A nNet x nNet matrix that counts how many edges were "on" in each cell.
%                       a.cellcount.cellpos     -       A nNet x nNet matrix that counts how many edges were "on" and "positive" in each cell.
%                       a.cellcount.cellpos     -       A nNet x nNet matrix that counts how many edges were "on" and "negative" in each cell.
%
%               a.stats                         -       A set of statistic analysis options
%                       a.stats.StatMode        -       0, 1 or 2 to indicate how what the null hypothesis for each cell is, defaults to 0 if unset.
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
%                       a.stats.ePDF          -         A 3D array. First two dimensions will index networks (and together index cells), third dimension will index repetitions.
%                                                      The value in each of the elements is the observed number of suprathreshold edges. Be careful that your CellAlpha matches
%                                                      the conditions of your simulation.
%                       a.stats.NullRate      -         Only matters if a.stats.StatMode is set to 1
%                                                      The expected probability in mode 1. Defaults to 0.001 if not set.
%                       a.stats.CellAlpha     -         The alpha level used to threshold the cell-level test for more edges than chance. If you want to correct
%                                                      for multiple comparisons, reflect it in this setting. Defaults to .05/# of unique cells if unset.        
%                       a.stats.SignAlpha     -         The alpha level used for the binomial sign test. Defaults to 0.05 if unset.
%              
%
%                             
%       OUTPUTS(New subfields of a.stats)
% 
%               a.stats                         -       A set of statistic analysis options plus a set of statistic analysis results
%                       a.stats.cellsign        -       A nNet x nNet matrix: whether a given cell was selected as having more edges "on" than expected by chance. Coding is...
%                                                               1 - Not significant
%                                                               2 - Positive signicant
%                                                               3 - Negative significant
%                                                               4 - Undirectional Significant                    
%                       a.stats.cellsig         -       Log10 of p-value for cell     


% Default settings
if ~isfiled(a,'stats') || ~isfield(a.stats,'StatMode')
    a.stats.StatMode = 2;
end

switch a.stats.StatMode
    case 0
        con = nnz(a.prune); % the consensus (only "on" edges)
        total = numel(a.prune); % total number of edges ("on" and "off")
        a.stats.NullRate = con/total; % The NullRate in mode 0 (consensus ratio mode)
    case 1
        if (~isfield(a.stats,'NullRate'))
            a.stats.NullRate = .001; % The NullRate in mode 1 (alpha mode)
        end
    case 2
    otherwise
        warning('Unexpected alien coming! Check your StatMode!')
end

if (~isfield(a.stats,'CellAlpha'))
    p = size(unique(a.NetworkLabels),2);
    a.stats.CellAlpha = 0.05/(p*(p+1)/2); % The alpha level used to threshold the cell-level test for more edges than chance.
end

if (~isfield(a.stats,'SignAlpha'))
    a.stats.SignAlpha = 0.05; % The alpha level used for the binomial sign test.
end

% Variable initialization
CellSize  = a.cellcount.cellsize;
StatMode  = a.stats.StatMode;
ePDF      = a.stats.ePDF;
NullRate  = a.stats.NullRate;
CellAlpha = a.stats.CellAlpha;
SignAlpha = a.stats.SignAlpha;
NumPos    = a.cellcount.cellpos;
NumNeg    = a.cellcount.cellneg;


% Computation Initialization
row = size(CellSize,1);
column = size(CellSize,2);
stats_result = ones(row,column); 
e = zeros(row,column); % expectation
o = zeros(row,column); % observed positive and negative points


% To mark if one cell passes the proportion test, if yes, flag is 1, if no, flag is 0.
flag = zeros(row,column); 


% Cell level test

for i = 1:row
    for j = i:column
        if StatMode~=2 % old functionality uses a binomial test
            e(i,j) = NullRate*CellSize(i,j);
            o(i,j) = NumPos(i,j) + NumNeg(i,j);
            bi_val = 1 - binocdf(NumPos(i,j)+NumNeg(i,j),CellSize(i,j),NullRate);
            effect_size(i,j) = bi_val;
            h = (bi_val < CellAlpha) & (o(i,j) > e(i,j));
        elseif StatMode==2 %The new empirical PDF approach
            o(i,j) = NumPos(i,j) + NumNeg(i,j);
            pval = (sum(o(i,j)<= squeeze(ePDF(i,j,:))))/size(ePDF,3);
            h = pval < CellAlpha;
            effect_size(i,j) = pval;
            
        end
        if (h == 1)
            flag(i,j) = 1;
        end
    end
end

% Sign test
for i = 1:row
    for j = i:column
        if flag(i,j) == 1
            bi_pos = 1 - binocdf(NumPos(i,j),NumPos(i,j)+NumNeg(i,j),0.5);
            bi_neg = 1 - binocdf(NumNeg(i,j),NumPos(i,j)+NumNeg(i,j),0.5);
            if bi_pos < SignAlpha
                stats_result(i,j) = 2;
            else
                if bi_neg < stat.SignAlpha
                    stats_result(i,j) = 3;
                else
                    stats_result(i,j) = 4;
                end
            end
                        
        end      
    end
end

effect_size(flag==0) = 1; % set to 1 (no sig) all results that did not pass

effect_size(flag==1 & effect_size==0) = eps;

effect_size = log10(effect_size); % take the log so that these are somewhat usable

effect_size(isinf(effect_size)) = min(effect_size(~isinf(effect_size))); % some will be -Inf, so let's set them to min

effect_size = -1 * effect_size; % we want bigger numbers to be bigger effects

% Save the results to subfileds of a.stats
a.stats.cellsign = stats_result;
a.stats.cellsig  = effict_size;


end

