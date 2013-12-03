function [ a ] = mc_Network_CellCount( a )
% MC_NETWORK_CELLCOUNT 
%
% Based on the matrix that already sorted by network labels, count the
% basic numbers that is useful in the next step.
% 
% Input:
% 
%               a.mediator                      -       See output of mc_network_FeatRestruct
%                       a.mediator.tsquare      -       Transform a.tvalues from a 1 x nFeat matrix to a sorted upper triangular matrix. 
%                       a.mediator.bsquare      -       Transform a.bvalues from a 1 x nFeat matrix to a sorted upper triangular matrix.
%                       a.mediator.sorted       -       1 x nROI matrix of sorted network labels.
%                       a.dotenable            -       0 - No dot shading, do regular cell counting
%                                                       1 - Do dot shading, regular cell counting is not quite useful
%
% 
% Output(New subfield of a)
% 
%               a.cellcount                     -       A set of cell count results, among these celltot, cellpos and cellneg are based on t vals, and cell mean is based on betas
%                       a.cellcount.cellsize    -       A nNet x nNet matrix that counts of number of edges in each cell.
%                       a.cellcount.celltot     -       A nNet x nNet matrix that counts how many edges were "on" in each cell.
%                       a.cellcount.cellpos     -       A nNet x nNet matrix that counts how many edges were "on" and "positive" in each cell.
%                       a.cellcount.cellneg     -       A nNet x nNet matrix that counts how many edges were "on" and "negative" in each cell.
%                       a.cellcount.cellmean    -       A nNet x nNet matrix that calculates the cellwise mean of betas


% Variable Initialization
tsquare = a.mediator.tsquare;
bsquare = a.mediator.bsquare;
sorted = a.mediator.sorted;


% Make sure square doesn't have any element with value other than 1, 2 or 3
if (a.dotenable == 0 && numel(setdiff(mc_flatten_upper_triangle(tsquare),[1 2 3]))>0);
    error('Unexpected elements in square: we only want  1, 2 and 3')
end

% Find out how many networks do we have
Net_label = unique(sorted);
Net_num   = numel(Net_label);

% Initialize result matrices
cellsize = zeros(Net_num);
cellpos  = zeros(Net_num);
cellneg  = zeros(Net_num);
cellmean = zeros(Net_num);

% Calculate cell sizes
cell_length = zeros(Net_num,1);
for iNet = 1:Net_num
    cell_length(iNet) = sum(sorted==Net_label(iNet)); 
end

sorted_new = sorted';
jumps=diff(sorted_new);
starts=[1 ;find(jumps) + 1];
stops=[find(jumps) ; size(sorted_new,1)];

% Count positive and negative points
for i = 1:Net_num
    for j = i:Net_num        
        subtmat = zeros(cell_length(i),cell_length(j));  
        subbmat = zeros(cell_length(i),cell_length(j));
        subi = starts(i):stops(i);
        subj = starts(j):stops(j);
        if i == j
            cellsize(i,j) = cell_length(i)*(cell_length(i)-1)/2;
            subtmat = triu(tsquare(subi,subj),1);
            subbmat = triu(bsquare(subi,subj),1);
        else
            cellsize(i,j) = cell_length(i)*cell_length(j);
            subtmat = tsquare(subi,subj);
            subbmat = bsquare(subi,subj);
        end        
        cellpos(i,j) = sum(sum(subtmat == 2));
        cellneg(i,j) = sum(sum(subtmat == 3));
        cellmean(i,j) = mean(mean(subbmat));        
    end
end

% Save the results to a.cellcount
a.cellcount.cellsize = cellsize;
a.cellcount.cellpos  = cellpos;
a.cellcount.cellneg  = cellneg;
a.cellcount.celltot  = cellpos + cellneg;
a.cellcount.cellmean = cellmean;
