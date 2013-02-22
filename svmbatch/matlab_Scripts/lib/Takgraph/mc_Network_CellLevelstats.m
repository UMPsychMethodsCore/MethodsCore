function [ a ] = mc_Network_CellLevelstats( a )
% MC_NETWORK_CellLevelstats 
% This function does cell level statistics on selected networks based on the permutation results
% INPUT
%         a.perms              -     A 5D object, the permutation results 
%         a.NetworkInclude     -     A 1-D vector, the included network (elements in the range of 0 - 14)
%         a.cellcount.celltot  -     A nNet x nNet matrix that counts how many edges were "on" in each cell.
%                                    As a result, this function should run after mc_NetworkCellcount.m
%         a.stats.FDRrate      -     The desired false discovery rate. {default: 0.05}
%         a.stats.FDRmode      -     'pdep'  --- the original Bejnamini & Hochberg FDR procedure is used, which is guaranteed to be accurate if
%                                    the individual tests are independent or positively dependent (e.g., Gaussian variables that are positively correlated or
%                                    independent).
%                                    'dep'   --- the FDR procedure described in Benjamini & Yekutieli (2001) that is guaranteed
%                                    to be accurate for any test dependency structure (e.g.,Gaussian variables with any covariance matrix) is used. 'dep'
%                                    is always appropriate to use but is less powerful than 'pdep.
%                                    Default 'pdep'.
%         a.stats.CalcP        -     0 or 1. If set to 1, it will actually calculate adjusted p values. Defaults to 1.
% Output
%         a.stats.adjp         -     Adjusted p values of each included cell.
%         a.stats.rebuild      -     A binary matrix of the same size as the a.stat.adjp. If the (i,j) element of a.stats.rebuild is 1, then the test that produced the 
%                                    p-value of the (i,j)th cell is significant (i.e., the null hypothesis of the test is rejected).
% 
% 2013/02 

if ~isfield(a.stats,'FDRrate')
    a.stats.FDRrate = 0.05;
end

if ~isfield(a.stats,'FDRmode')
    a.stats.FDRmode = 'pdep';
end

if ~isfield(a.stats,'CalcP')
    a.stats.CalcP = 1;
end



% Variable Initialization

permstot   = a.perms;
NetInclude = a.NetworkInclude;
celltot    = a.cellcount.celltot;
thresh     = a.stats.FDRrate;
FDRmode    = a.stats.FDRmode;
CalcP      = a.stats.CalcP;

for i = 1:size(celltot,1)
    for j = i:size(celltot,2)
        epval.full(i,j) = sum(celltot(i,j) <= squeeze(permstot(i,j,1,1,:)))/size(permstot,5);
    end
end

% Subset (Select the networks we want) 
NetIncludeMat = NetInclude + 1; % shift 1 from network label to matrix label
epval.mini.sq = epval.full(NetIncludeMat,NetIncludeMat);  % only network 1 - 7 (remember network starts from 0)

% Unroll(matrix -> vector, only use diagonal and upper triangle)
ctr = 1;
for i=1:size(epval.mini.sq,1)
    for j = i:size(epval.mini.sq,2)
        epval.mini.flat(ctr) = epval.mini.sq(i,j);
        ctr = ctr+1;
    end
end

% FDR (get the adjusted p-Values)
[h, ~, adjp] = fdr_bh(epval.mini.flat,thresh,FDRmode,[],CalcP);

% Reroll (vector -> matrix)
ctr = 1;
for i=1:size(epval.mini.sq,1)
    for j = i:size(epval.mini.sq,2)
        epval.mini.rebuild(i,j) = h(ctr);
        epval.mini.adjp(i,j) = adjp(ctr);
        ctr = ctr+1;
    end
end

a.stats.rebuild = epval.mini.rebuild;
a.stats.adjp = epval.mini.adjp;      


end

