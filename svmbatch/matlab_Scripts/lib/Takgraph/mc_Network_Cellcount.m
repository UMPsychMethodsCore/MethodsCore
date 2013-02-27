function [ a ] = mc_Network_Cellcount( a )
% MC_NETWORK_CELLCOUNT 
%
% Based on the matrix that already sorted by network labels, count the
% basic numbers that is useful in the next step.
% 
% Input:
% 
%               a.mediator                      -       See output of mc_network_FeatRestruct
%                       a.mediator.square       -       Transform a.pruneColor.values from a 1 x nFeat matrix to a sorted upper triangular matrix. 
%                       a.mediator.sorted       -       1 x nROI matrix of sorted network labels.
% 
% Output(New subfield of a)
% 
%               a.cellcount                     -       A set of cell count results
%                       a.cellcount.cellsize    -       A nNet x nNet matrix that counts of number of edges in each cell.
%                       a.cellcount.celltot     -       A nNet x nNet matrix that counts how many edges were "on" in each cell.
%                       a.cellcount.cellpos     -       A nNet x nNet matrix that counts how many edges were "on" and "positive" in each cell.
%                       a.cellcount.cellpos     -       A nNet x nNet matrix that counts how many edges were "on" and "negative" in each cell.


% Variable Initialization
square = a.mediator.square;
sorted = a.mediator.sorted;


% Make sure square doesn't have any element with value other than 1, 2 or 3
if (sum(sum(square==0))+sum(sum(square==1))+sum(sum(square==2))+sum(sum(square==3))<numel(square))
    error('Unexpected elements in square: we only want 0, 1, 2 and 3')
end

% Find out how many networks do we have
Net_label = unique(sorted);
Net_num   = numel(Net_label);

% Initialize result matrices
cellsize = zeros(Net_num);
cellpos  = zeros(Net_num);
cellneg  = zeros(Net_num);

% Calculate cell sizes
cell_length = zeros(Net_num,1);
for iNet = 1:Net_num
    cell_length(iNet) = sum(sorted==Net_label(iNet)); 
end

for i = 1:Net_num
    for j = i:Net_num
        if i == j
            cellsize(i,j) = cell_length(i)*(cell_length(i)-1)/2;
        else
            cellsize(i,j) = cell_length(i)*cell_length(j);
        end                    
    end
end

sorted_new = sorted';
jumps=diff(sorted_new);
starts=[1 ;find(jumps)];
stops=[find(jumps) - 1; size(sorted_new,1)];

% Count positive and negative points
for i = 1:Net_num
    for j = i:Net_num        
        submat = zeros(cell_length(i),cell_length(j));        
        subi = starts(i):stops(i);
        subj = starts(j):stops(j);
        if i == j
            submat = triu(square(subi,subj),1);
        else
            submat = square(subi,subj);
        end        
        cellpos(i,j) = sum(sum(submat == 2));
        cellneg(i,j) = sum(sum(submat == 3));
        
    end
end

% Save the results to a.cellcount
a.cellcount.cellsize = cellsize;
a.cellcount.cellpos  = cellpos;
a.cellcount.cellneg  = cellneg;
a.cellcount.celltot  = cellpos + cellneg;
