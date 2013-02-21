function mc_TakGraph_addshading( a )
%MC_TAKGRAPH_ADDSHADING 
% Based on the result of stats analysis, add shading over the TakGraph at
% the stats significant area
%       INPUTS
%                       a.stats.cellsign        -       A nNet x nNet matrix: whether a given cell was selected as having more edges "on" than expected by chance. Coding is...
%                                                               1 - Not significant
%                                                               2 - Positive signicant
%                                                               3 - Negative significant
%                                                               4 - Undirectional Significant 
%                       a.mediator.sorted       -       1 x nROI matrix of sorted network labels, which will help with finding the start and end point of each cell.
%                       a.shading.transparency  -       Transparency of the shading blocks
%


hold on;

stats_result = a.stats.cellsign;
transp       = a.shading.transparency;
sorted       = a.mediator.sorted;

% if only one transparency is given, replicate it for use everywhere
if numel(transp)==1     
    transp=repmat(transp,size(stats_result));
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



hold off;


end

