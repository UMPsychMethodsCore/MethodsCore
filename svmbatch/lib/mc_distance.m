function [ distance ] = mc_distance( x,y )
%MC_DISTANCE Calculate euclidian distance between two vectors, or a set of
%vectors and a reference point, or pairwise distances between two sets of vectors
% 
% x     -   n*v matrix, where n is the number of vectors, and v is the
%           order of each vector
% y     -   1*v matrix or n*v matrix

if size(y,1) ~= 1
    bigy = y;
else
    bigy = repmat(y,size(x,1),1);
end

diffs = x - bigy;

sqdiffs = diffs.^2;

distance = sqrt(sum(sqdiffs,2));


    
    


end

