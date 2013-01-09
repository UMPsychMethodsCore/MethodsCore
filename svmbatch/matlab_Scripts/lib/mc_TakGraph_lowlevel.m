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
%                       a.Shading.Mode          -       Indicate if you
%                       want it to do shading with ...
%                       a.chioption             -       0 or 1 to indicate
%                       the mode of chi square test

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

square = triu(square + square',1); %get it all back on the upper triangle
square_prune = triu(square_prune + square_prune');

% put upper/lower triangle matrix together (for future optional use)
square_full = square + tril(square',-1);

%% Counting size,number of positive points and number of negative points of each cell
[CellSize, NumPos, NumNeg] = initial_count(square,sorted);

%% Stats analysis
% The mode of chi square test,
% 1 is to use alpha to calculate expectation
% 0 is to use size portion to calculate expectation 
% Predefined in the subfield of a
chi_option = a.chioption;
% the alpha that helps calculating expectation in option 1
exp_alpha = .001;
% the alpha used in chi square test
chi_alpha = 0.05/72;
% the alpha used in binomial test for sign (predominantely negative vs positive)
bi_alpha = 0.05;

stats_result = stats_analysis(CellSize,NumPos,NumNeg,chi_option,exp_alpha,chi_alpha,bi_alpha);

%% Enlarge the dots, if enabled

if(isfield(a,'DotDilateMat'))
    square = enlarge_dots(square,square_prune,a.DotDilateMat);
end

%% Plot the TakGraph
figure;image(square);colormap(a.pruneColor.map);
axis off;

%% Add the shading on TakGraph
hold on;
% Transparency of the shading block
transp = 0.5;
add_shading(stats_result, transp, sorted);
hold off;

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

starts = starts-0.5;
stops = stops + 0.5;


for iBox=1:size(starts)
    mc_draw_box(starts(iBox),starts(iBox),stops(iBox),stops(iBox));
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
jumps=[jumps];
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


function stats_result = stats_analysis(CellSize,NumPos,NumNeg,chi_option,exp_alpha,chi_alpha,bi_alpha)
% Apply the stats analysis to each cell
% Input:
% CellSize - a matrix that contains the size of each cell
% NumPos - a matrix that contains the number of positive points in each
% cell
% NumNeg - a matrix that contains the number of negative points in each
% cell
% alpha - 
% Output:
% stats_result - a matrix that contains flag for each cell, 1 indicates not
% significant, 2 indicates positive significant, 3 indicates negative
% significant

% Initialization
row = size(CellSize,1);
column = size(CellSize,2);
stats_result = ones(row,column); 
e = zeros(row,column); % expectation
o = zeros(row,column); % observed positive and negative points
con = sum(sum(NumPos)) + sum(sum(NumNeg)); % the con...
total = sum(sum(CellSize));% Total size
con_alpha = con/total;

% To mark if one cell passes the proportion test, if yes, flag is 1, if no, flag is 0.
flag = zeros(row,column); 

% Proportion test
% To avoid df = 0, use observed points in this cell, rest of the  points as
% the observed vector, use expected points in this cell and the expected 
% rest of the points as the expected vector.
switch chi_option
    case 1
        for i = 1:row
            for j = i:column
                e(i,j) = exp_alpha*CellSize(i,j);
                o(i,j) = NumPos(i,j) + NumNeg(i,j);                
                obs = [o(i,j) CellSize(i,j)-o(i,j)];  
                ept = [e(i,j) (1-exp_alpha)*(CellSize(i,j))];
                bi_val = 1 - binocdf(NumPos(i,j)+NumNeg(i,j),CellSize(i,j),exp_alpha);
                h = (bi_val < chi_alpha) & (o(i,j) > e(i,j));
%                 [h,p,stats]=chi2gof([1 2],'freq',obs,'expected',ept,'alpha',chi_alpha);
                if (h == 1) 
                    flag(i,j) = 1;
                end
            end
        end
    case 0
        for i = 1:row
            for j = i:column
                e(i,j) = con_alpha*CellSize(i,j);
                o(i,j) = NumPos(i,j) + NumNeg(i,j);
                obs = [o(i,j) con-o(i,j)];   
                ept = [e(i,j) con*(1-CellSize(i,j)/total)];
                bi_val = 1 - binocdf(NumPos(i,j)+NumNeg(i,j),CellSize(i,j),con_alpha);
%                 [h,p,stats]=chi2gof([1 2],'freq',obs,'expected',ept,'alpha',chi_alpha);
                h = (bi_val < chi_alpha) & (o(i,j) > e(i,j));
                if (h == 1) 
                    flag(i,j) = 1;
                end
            end
        end
    otherwise
        warning('Unexpected alien coming! Check your input of chi_option!')
end

% Sign test
for i = 1:row
    for j = i:column
        if flag(i,j) == 1
            bi_pos = 1 - binocdf(NumPos(i,j),NumPos(i,j)+NumNeg(i,j),0.5);
            bi_neg = 1 - binocdf(NumNeg(i,j),NumPos(i,j)+NumNeg(i,j),0.5);
            if bi_pos < bi_alpha
                stats_result(i,j) = 2;
            else
                if bi_neg < bi_alpha
                    stats_result(i,j) = 3;
                else
                    stats_result(i,j) = 4;
                end
            end
                        
        end      
    end
end



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

sorted_new = sorted';
jumps=diff(sorted_new);
jumps=[jumps];
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
                fill(shade_x,shade_y,'r','FaceAlpha',transp);
            case 3 
                shade_x = [starts(j),stops(j),stops(j)];
                shade_y = [starts(i),starts(i),stops(i)]; 
                fill(shade_x,shade_y,'b','FaceAlpha',transp);
            case 4
                shade_x = [starts(j),stops(j),stops(j)];
                shade_y = [starts(i),starts(i),stops(i)]; 
                fill(shade_x,shade_y,'y','FaceAlpha',transp);
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
                fill(shade_x,shade_y,'r','FaceAlpha',transp);
            case 3 
                shade_x = [starts(j),stops(j),stops(j),starts(j)];
                shade_y = [starts(i),starts(i),stops(i),stops(i)];
                fill(shade_x,shade_y,'b','FaceAlpha',transp);
            case 4
                shade_x = [starts(j),stops(j),stops(j),starts(j)];
                shade_y = [starts(i),starts(i),stops(i),stops(i)];
                fill(shade_x,shade_y,'y','FaceAlpha',transp);
            otherwise 
                warning('Unexpected value in the results, please check!')
                continue
            end
        end          
        
    end
end































