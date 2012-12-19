function [ out ] = mc_TakGraph_lowlevel ( a )
%MC_TAKGRAPH_LOWLEVEL Low-level graphing function to make a TakGraph
% If you're working from the "standard" SVM stream, you probably want to run
% mc_TakGraph instead, which is a higher level function which will call this one.
%
%       INPUTS
%               REQUIRED
%                       a.prune                 -       1 x nFeat logical matrix of features to plot
%                       a.NetworkLabels         -       1 x nFeat matrix of network labels. This will be used literally.
%
%               OPTIONAL
%                       a.DotDilateMat          -       Matrix of offsets to expand dots on the Takgraph by. This should be nOffset x 2.
%                       a.pruneColor.values     -       1 x nFeat matrix of color values that will index into a.pruneColor.map
%                       a.pruneColor.map        -       A colormap object that will be directly indexed by pruneColor.values. 

%% Deal with coloration, if enabled
if(isfield(a,'pruneColor'))
    a.pruneColor.values(~logical(a.prune)) = 1; % Set colors outside of prune to 1, so they will use first colormap color
else % If no a.pruneColor passed, set it up as if the colormap goes white, black, and the values are 1s and 2s
    a.pruneColor.values = zeros(size(a.prune))
    a.pruneColor.values(logical(a.prune)) = 2;
    a.pruneColor.values(~logical(a.prune)) = 1;
    a.pruneColor.map = [1 1 1; 0 0 0]; % Define a colormap where 1 = white, 2 = black
end

%% Make your square matrix
square = mc_unflatten_upper_triangle(a.pruneColor.values);
square_prune = mc_unflatten_upper_triangle(a.prune);

%% Sort the square by networks
[sorted, sortIDX] = sort(a.NetworkLabels);

square = square(sortIDX,sortIDX);
square_prune = square_prune(sortIDX,sortIDX);

square = triu(square + square'); %get it all back on the upper triangle
square_prune = triu(square_prune + square_prune');

%% Counting size,number of positive points and number of negative points of each cell
[CellSize, NumPos, NumNeg] = Initial_Count(square,sorted);

%% Enlarge the dots, if enabled

if(isfield(a,'DotDilateMat'))
    square = enlarge_dots(square,square_prune,a.DotDilateMat);
end

%% Plot the TakGraph
image(square);colormap(a.pruneColor.map)

%% Add the network overlay
network_overlay(sorted);

%% All Done with main body

%% Helper Functions Go Down Here

function out=enlarge_dots(enlarge,logical,mat)
%Enlarge the dots in your heatmat. You will need to supply three things
% enlarge - a square matrix whose values will be enlarged
% logical - another square matrix. This is a logical that indicates which points need to be enlarged
% mat - This is your dilation matrix
%your original square matrix (typically prune_square)
%
% mat will be a n*2 matrix of offsets that you wish to expand
% For example, to enlarge the dots by adding dots 
% above, below, and to either side, use:
% mat = [1 0; -1 0; 0 1; 0 -1];
%
% UNFORTUNATELY, this will overwrite its neighbors in probably a column-major way

out = enlarge;

[hotx hoty] = find(logical);

[maxx maxy] = size(enlarge);

for ihot = 1:size(hotx,1) % Loop over values to enlarge
    curVal = enlarge(hotx(ihot),hoty(ihot)); % Grab the value of the current thing to expand
    
    for ioff = 1:size(mat,1) % Loop over enlargements
        newx = hotx(ihot) + mat(ioff,1); %new x coordinate
        newy = hoty(ihot) + mat(ioff,2); %new y coordinate
        logicx = newx <= maxx & newx >=1; % check if new x coordinate is in bounds
        logicy = newy <= maxy & newy >=1; % check if new y coordinate is in bounds
        logicall = logicx & logicy ;  % check that both x and y coordinate are in bounds
        
        if logicall % if it's good, let's enlarge
            out(newx,newy) = curVal;
        end
    end
end


function network_overlay(sorted)
hold on

% figure out jump points in labels

sorted = sorted';

jumps=diff(sorted);

jumps=[jumps];

starts=[1 ;find(jumps)];
stops=[find(jumps) - 1; size(sorted,1)];


for iBox=1:size(starts)
    mc_draw_box(starts(iBox),starts(iBox),stops(iBox),stops(iBox));
end

hold off

function [CellSize, NumPos, NumNeg] = Initial_Count(square,sorted)
% Based on the matrix that already sorted by network labels, count the
% basic numbers that is useful in the next step.
% Input:
% square - This is your matrix that is already sorted based on the network
% label, the elements of this matrix is supposed only to contain: 1, 2 and
% 3. 1 is backgroun, 2 is positive points, and 3 is negative points.
% sorted - Matrix of network labels that marks the cell distribution.

% Find out how many networks do we have
Net_num = max(sorted) - min(sorted) +1;

% Initialize result matrices
CellSize = zeros(Net_num);
NumPos = zeros(Net_num);
NumNeg = zeros(Net_num);


% Calculate cell sizes
Cell_length = zeros(Net_num,1);
Net_label = unique(sorted);
for iNet = 1:numel(Net_label);
    Cell_length(iNet)=sum(sorted==Net_label(iNet));    
end
for i = 1:Net_num
    for j = i:Net_num
        if i == j
            CellSize(i,j) = Cell_length(i)*(Cell_length(i)-1)/2;
        else
            CellSize(i,j) = Cell_length(i)*Cell_length(j);
        end
            
    end
end

% Count positive and negative points
for i = 1:Net_num
    for j = i:Net_num
        
        submat = zeros(Cell_length(i),Cell_length(j));
        
        if i ==1
            subi = 1:Cell_length(1);
        else
            subi = sum(Cell_length(1:i-1))+1:sum(Cell_length(1:i));
        end
        
        if j ==1
            subj = 1:Cell_length(1);
        else
            subj = sum(Cell_length(1:j-1))+1:sum(Cell_length(1:j));
        end
        
        if i == j
            submat = triu(square(subi,subj),1);
        else
            submat = square(subi,subj);
        end
        
        NumPos(i,j) = sum(sum(submat == 2));
        NumNeg(i,j) = sum(sum(submat == 3));
    end
end



