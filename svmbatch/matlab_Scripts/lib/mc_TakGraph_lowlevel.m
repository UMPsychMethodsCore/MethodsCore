function [ out ] = mc_TakGraph_lowlevel ( a )
%MC_TAKGRAPH_LOWLEVEL Low-level graphing function to make a TakGraph
% If you're working from the "standard" SVM stream, you probably want to run
% mc_TakGraph instead, which is a higher level function which will call this one.
%
%       INPUTS
%               REQUIRED
%                       a.prune                 -       1 x nFeat logical matrix of features to plot
%                       a.NetworkLabels         -       1 x nROI matrix of network labels. This will be used literally.
%
%               OPTIONAL
%                       a.DotDilateMat          -       Matrix of offsets to expand dots on the Takgraph by. This should be nOffset x 2.
%                       a.pruneColor.values     -       1 x nFeat matrix of color values that will index into a.pruneColor.map
%                       a.pruneColor.map        -       A colormap object that will be directly indexed by pruneColor.values. 
%                       a.Shading.Enable        -       0 - Disable Shading
%                                                       1 - Enable Shading Mode. Details below
%                                                       For each unique cell (intersection of two networks or network with itself), this function will identify whether there are more
%                                                       edges "on" than would be expected by chance. The option a.Shading.StatMode lets you define what "chance" behavior is.
%                                                       If test statistic will for the cell is below the threshold set by  a.Shading.CellAlpha it will be shaded.
%                                                       For cells that pass this first test, it will then do a sign test to check
%                                                       if, of the "on" edges, significantly more than half are positive, or if significantly more than half are negative.
%                                                       This sign test will use a.Shading.SignAlpha as its threshold. If the positive direction passes the test, it will be shaded
%                                                       red. If the negative direction passes the test, it will be shaded blue. If neither direction passes the test, it will be yellow.
%                                                       It assumes that the following correspondence for values of a.pruneColor.values
%                                                           1 - Edge is not turned on
%                                                           2 - Edge is on average positive
%                                                           3 - Edge is on average negative
%                                                       This function can do stats analysis on cells of TakGraphs (namely
%                                                       intersections of networks) and identify whether the number of edges contained within each cell is
%                                                       greater than expected by chance. If you'd like to turn on this functionality, set a.Shading.Mode to
%                                                       1. Set it to 0 to disable.
%                                                       If you turn on a.Shading.Mode you'll need to be careful to set a number of other
%                                                       options below that control how the stats tests are performed,otherwise default
%                                                       numbers will be used.                                                       
%                       a.Shading.StatMode      -       0 or 1 to indicate how what the null hypothesis for each cell is, defaults to 0 if unset.
%                                                       1 - use NullRate to be the null rate. 
%                                                       This is appropriate when your features were selected in a mass univariate stream. You should
%                                                       then set a.Shading.NullRate to the alpha that was used as the threshold in mass univariate stats.
%                                                       That way, it will test the null hypothesis that the number of implicated edges in a given network
%                                                       intersection is less than or equal to the number expected by chance (e.g. alpha is .05, 
%                                                       so the null is that <= 5% of the edges in each network intersection will have been identified).
%                                                       
%                                                       0 - use consensus size portion(total edge number / total cell size) to be the expected probability.
%                                                       This is appropriate when analyzing a feature set arrived at by consensus. This will use 
%                                                       size(consensus)/size(all edges) as the null rate. In those mode it is not necessary to set a.Shading.NullRate
%                       a.Shading.NullRate      -       Only matters if a.Shading.StatMode is set to 1
%                                                       The expected probability in mode 1. Defaults to 0.001 if not set.
%                       a.Shading.CellAlpha     -       The alpha level used to threshold the cell-level test for more edges than chance. If you want to correct
%                                                       for multiple comparisons, reflect it in this setting. Defaults to .05/# of unique cells if unset.        
%                       a.Shading.SignAlpha     -       The alpha level used for the binomial sign test. Defaults to 0.05 if unset.
%                       a.Shading.Transparency  -       How transparent should shading colors be? Defaults to .5 if unset.
%                       a.Shading.Trans         -       Use this set of fields if you want to rescale transparency relative to effect sizes
%                       a.Shading.Trans.Mode    -       How do you want to rescale your cell-level effect sizes into transparency. Express this with 1 = opaque, 0 = clear.
%                                                       1 - Provide a range. We will linearly rescale your data to this range
%                                                       2 - Provide a scale factor and a constant. The constant will be added, then the data grown away from the mean by scale factor.
%                                                       3 - Provide a scale factor and a center. Your data will be recentered to this and grown away from the center by scale factor
%                       a.Shading.Trans.Range   -       A range for use with mode 1
%                       a.Shading.Trans.Scale   -       Scale factor for use with modes 2 and 3
%                       a.Shading.Trans.Constant-       Constant for use with mode 2
%                       a.Shading.Trans.Center  -       Center for use with mode 3

%% Deal with coloration, if enabled
if(isfield(a,'pruneColor'))
    a.pruneColor.values(~logical(a.prune)) = 1; % Set colors outside of prune to 1, so they will use first colormap color
else % If no a.pruneColor passed, set it up as if the colormap goes white, black, and the values are 1s and 2s
    a.pruneColor.values = zeros(size(a.prune));
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

square = triu(square + square',1); %get it all back on the upper triangle
square_prune = triu(square_prune + square_prune');

%% Counting size,number of positive points and number of negative points of each cell
[CellSize, NumPos, NumNeg] = initial_count(square,sorted);

%% Stats analysis setup
if isfield(a,'Shading') && isfield(a.Shading,'Enable') && a.Shading.Enable==1
    a = shading_initialize(a);
    stats_result = stats_analysis(CellSize,NumPos,NumNeg,a.Shading);
end

%% Enlarge the dots, if enabled

if(isfield(a,'DotDilateMat'))
    square = enlarge_dots(square,square_prune,a.DotDilateMat);
end

%% Plot the TakGraph
figure;image(square);colormap(a.pruneColor.map);
axis off;

%% Add the shading on TakGraph
if isfield(a,'Shading') && isfield(a.Shading,'Enable') && a.Shading.Enable==1
    hold on;
    % Transparency of the shading block
    add_shading(stats_result, a.Shading.Transparency, sorted);
    hold off;
end

%% Add the network overlay
network_overlay(sorted);

out = 1; %indicate success

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

[hotx, hoty] = find(logical);

[maxx, maxy] = size(enlarge);

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

starts=[1 ;find(jumps)];
stops=[find(jumps) - 1; size(sorted,1)];

starts = starts-0.5;
stops = stops + 0.5;

% Draw the diagonal line
n = size(starts,1);
plot([starts(1) stops(n)],[starts(1) stops(n)],'Color',[0.5 0.5 0.5]);

% Manully set this from 0.5 to 1 just in order to keep the top line when
% saving to tiff file
starts(1) = 1;
stops(n) = stops(n)-0.5;


% Draw the Cell boudaries
for iBox=1:size(starts)    
    plot([starts(iBox) stops(n)],[starts(iBox) starts(iBox)],'Color',[0.5 0.5 0.5])
    plot([stops(iBox) stops(iBox)],[starts(1) stops(iBox)],'Color',[0.5 0.5 0.5])
end

hold off

function [CellSize, NumPos, NumNeg] = initial_count(square,sorted)
% Based on the matrix that already sorted by network labels, count the
% basic numbers that is useful in the next step.
% Input:
% square - This is your matrix that is already sorted based on the network
% label, the elements of this matrix is supposed only to contain: 1, 2 and
% 3. 1 is background, 2 is positive points, and 3 is negative points.
% sorted - Matrix of network labels that marks the cell distribution.
% Output:
% CellSize - a matrix that contains the size of each cell
% NumPos - a matrix that contains the number of positive points in each
% cell
% NumNeg - a matrix that contains the number of negative points in each
% cell
% Cell_length - a vector that contains the length(1D) of each cell, which
% will be used in the shading function

% Find out how many networks do we have
Net_label = unique(sorted);
Net_num = size(Net_label,2);

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

sorted_new = sorted';
jumps=diff(sorted_new);
starts=[1 ;find(jumps)];
stops=[find(jumps) - 1; size(sorted_new,1)];

% Count positive and negative points
for i = 1:Net_num
    for j = i:Net_num        
        submat = zeros(Cell_length(i),Cell_length(j));        
        subi = starts(i):stops(i);
        subj = starts(j):stops(j);
        if i == j
            submat = triu(square(subi,subj),1);
        else
            submat = square(subi,subj);
        end        
        NumPos(i,j) = sum(sum(submat == 2));
        NumNeg(i,j) = sum(sum(submat == 3));
        
    end
end


function [stats_result effect_size] = stats_analysis(CellSize,NumPos,NumNeg,stat)
% Apply the stats analysis to each cell
% Input:
% CellSize - a matrix that contains the size of each cell
% NumPos - a matrix that contains the number of positive points in each cell
% NumNeg - a matrix that contains the number of negative points in each cell
% stat - a struct that contains stats initialization parameters 
% Output:
% stats_result - a matrix that contains flag for each cell, 1 indicates not
% significant, 2 indicates positive significant, 3 indicates negative significant
% effect_size - quantifies effect size as observed proportion minus expected proportion

% Initialization
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
        e(i,j) = stat.NullRate*CellSize(i,j);
        o(i,j) = NumPos(i,j) + NumNeg(i,j);
        bi_val = 1 - binocdf(NumPos(i,j)+NumNeg(i,j),CellSize(i,j),stat.NullRate);
        h = (bi_val < stat.CellAlpha) & (o(i,j) > e(i,j));
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
            if bi_pos < stat.SignAlpha
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

effect_size = (o ./ CellSize) - (e ./ CellSize)



function add_shading(stats_result, transp, sorted)
% Based on the result of stats analysis, add shading over the TakGraph at
% the stats significant area
% Input:
% stats_result - a matrix that contains the stats analysis result of each
% cell of TakGraph
% transp - transparency of the shading blocks
% sorted - the vector that contains the sorted network label, which will
% help with finding the start and end point of each cell.
% 
% The flag of result is:
% 1 - background
% 2 - positive (red shading)
% 3 - negative (blue shading)
% 4 - neutral (yellow shading)
% transparency can now also be a matrix of transparencies to use

if numel(transp)==1 % if only one transparency is given, replicate it for use everywhere
    transp=repmat(transp,size(stats_result);
end

sorted_new = sorted';
jumps=diff(sorted_new);
starts=[1 ;find(jumps)];
stops=[find(jumps) - 1; size(sorted_new,1)];
starts = starts - 0.5;
stops = stops + 0.5;

for i = 1:size(stats_result,1)
    for j = i:size(stats_result,2)
        if (i == j)  % half shading on the diagonal cells
            switch stats_result(i,j)
            case 1
                continue
            case 2  
                shade_x = [starts(j),stops(j),stops(j)];
                shade_y = [starts(i),starts(i),stops(i)];                          
                fill(shade_x,shade_y,'r','FaceAlpha',transp(i,j));
            case 3 
                shade_x = [starts(j),stops(j),stops(j)];
                shade_y = [starts(i),starts(i),stops(i)]; 
                fill(shade_x,shade_y,'b','FaceAlpha',transp(i,j));
            case 4
                shade_x = [starts(j),stops(j),stops(j)];
                shade_y = [starts(i),starts(i),stops(i)]; 
                fill(shade_x,shade_y,'y','FaceAlpha',transp(i,j));
            otherwise 
                warning('Unexpected value in the results, please check!')
                continue
            end
        else
            switch stats_result(i,j)
            case 1
                continue
            case 2  
                shade_x = [starts(j),stops(j),stops(j),starts(j)];
                shade_y = [starts(i),starts(i),stops(i),stops(i)];                          
                fill(shade_x,shade_y,'r','FaceAlpha',transp(i,j));
            case 3 
                shade_x = [starts(j),stops(j),stops(j),starts(j)];
                shade_y = [starts(i),starts(i),stops(i),stops(i)];
                fill(shade_x,shade_y,'b','FaceAlpha',transp(i,j));
            case 4
                shade_x = [starts(j),stops(j),stops(j),starts(j)];
                shade_y = [starts(i),starts(i),stops(i),stops(i)];
                fill(shade_x,shade_y,'y','FaceAlpha',transp(i,j));
            otherwise 
                warning('Unexpected value in the results, please check!')
                continue
            end
        end          
        
    end
end


function a = shading_initialize(a)
% Mode of binomial test of cell significance
if ~isfield(a.Shading,'StatMode')
    a.Shading.StatMode = 0;
end

switch a.Shading.StatMode
    case 1        
        % The NullRate in mode 1 (alpha mode)
        if (~isfield(a.Shading,'NullRate'))
            a.Shading.NullRate = .001;
        end
    case 0        
        % The NullRate in mode 0 (consensus ratio mode) 
        con = nnz(a.prune); % the consensus
        total = numel(a.prune); % total number of edges
        a.Shading.NullRate = con/total;
    otherwise
        warning('Unexpected alien coming! Check your StatMode!')
end

% The alpha level used to threshold the cell-level test for more edges than chance.
if (~isfield(a.Shading,'CellAlpha'))
    p = size(unique(a.NetworkLabels),2);
    a.Shading.CellAlpha = 0.05/(p*(p+1)/2);
end

% The alpha level used for the binomial sign test.
if (~isfield(a.Shading,'SignAlpha'))
    a.Shading.SignAlpha = 0.05;
end

if (~isfield(a.Shading,'Transparency'))
    a.Shading.Transparency = 0.5;
end

function out = rescale1(in)
% Linearly rescale in.raw into range specified by in.range
% NOTE - in.raw and in.range MUST BE ROW VECTORS
% This will break if you give it something with no variance or something stupid
if range(in.raw)~=0 && range(in.range)~=0
    in.raw = in.raw - min(in.raw); % get it scaled into (0, max)
    in.raw = in.raw ./ max(in.raw); % scale it to (0,1)
    in.raw = in.raw .* range(in.range); % scale it so that ranges match
    in.raw = in.raw + min(in.range); % translate so that left edges match
end
out = in.raw

function out = rescale2(in)
% This will add a constant to a vector, and then grow it by a factor away from the center
% It can also trim the result so that it stays in a reasonable range
% Arguments
% in.raw
% in.constant
% in.scale
% in.lowlimit
% in.uplimit

oldmean = mean(in.raw); % grab the old mean
in.raw = in.raw - oldmean; % center it about 0 before dilation
in.raw = in.raw .* in.scale; % dilate it by scaling factor
in.raw = in.raw + oldmean; % move it back to the old center
in.raw = in.raw + in.constant % add it in the scaling factor
in.raw(in.raw>in.uplimit) = in.uplimit; % trim any of the large values
in.raw(in.raw<in.lowlimit) = in.lowlimit; % trim small values
out = in.raw

function out = rescale3(in)
% This will recenter your data about a variable point and grow it by a scale factor away from center
% ARGS
% in.raw - your original vector
% in.center - the new center
% in.scale - the factor to grow by

in.raw = in.raw - mean(in.raw); % center data about 0 b4 dilation
in.raw = in.raw .* in.scale; % dilate it by scaling factor
in.raw = in.raw + in.center; % move the data to the new center
out = in.raw;
