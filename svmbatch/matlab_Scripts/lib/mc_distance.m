function [ distance ] = mc_distance( x,y )
%MC_DISTANCE Calculate euclidian distance between two vectors, or a set of
%vectors and a reference point
% 
% x     -   n*v matrix, where n is the number of vectors, and v is the
%           order of each vector
% y     -   1*v matrix


bigy = repmat(y,size(x,1),1);

diffs = x - bigy;

sqdiffs = diffs.^2;

distance = sqrt(sum(sqdiffs,2));


    
    


end

