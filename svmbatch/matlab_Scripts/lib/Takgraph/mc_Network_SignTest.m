function [ a ] = mc_Network_SignTest( a )
%MC_NETWORK_SignTest 
% After the cell level test, this function will further decide the direction of the cell
% 
%       INPUTS
%               a.cellcount                     -       A set of cell count values: cell size, number of positive points, negative points in each cell
%                       a.cellcount.cellpos     -       A nNet x nNet matrix that counts how many edges were "on" in each cell.
%                       a.cellcount.cellneg     -       A nNet x nNet matrix that counts how many edges were "negative" in each cell.
%                       a.stats.rebuild         -       A binary matrix of the same size as the a.stat.adjp. If the (i,j) element of a.stats.rebuild is 1, then the test that produced the 
%                                                       p-value of the (i,j)th cell is significant (i.e., the null hypothesis of the test is rejected).
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


if (~isfield(a.stats,'rebuild'))
    error('Please run the cell level test first to get a.stats.rebuild')
end

if (~isfield(a.stats,'SignAlpha'))
    a.stats.SignAlpha = 0.05; % The alpha level used for the binomial sign test.
end

% Variable initialization
flag      = a.stats.rebuild;
SignAlpha = a.stats.SignAlpha;
NumPos    = a.cellcount.cellpos;
NumNeg    = a.cellcount.cellneg;

% Computation Initialization
row = size(flag,1);
column = size(flag,2);
stats_result = ones(row,column); 
effect_size  = zeros(row,column);

% Sign test
for i = 1:row
    for j = i:column
        if flag(i,j) == 1
            bi_pos = 1 - binocdf(NumPos(i,j),NumPos(i,j)+NumNeg(i,j),0.5);
            bi_neg = 1 - binocdf(NumNeg(i,j),NumPos(i,j)+NumNeg(i,j),0.5);
            if bi_pos < SignAlpha
                stats_result(i,j) = 2;
            else
                if bi_neg < SignAlpha
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
a.stats.cellsig  = effect_size;


end

