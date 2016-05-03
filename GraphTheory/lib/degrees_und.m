function [deg,glodeg] = degrees_und(CIJ)
%DEGREES_UND        Degree
%
%   deg = degrees_und(CIJ);
%
%   Node degree is the number of links connected to the node.
%
%   Input:      CIJ,    undirected (binary/weighted) connection matrix
%
%   Output:     deg,    node degree
%               glodeg, global degree
%
%   Note: Weight information is discarded.
%
%
%   Olaf Sporns, Indiana University, 2002/2006/2008



%%% @Yu:set the diagonal of CIJ to 0
%%% from the 2009 review paper: 
%%% 'The degree of a node is the number of connections that linke it to the
%%% REST OF THE NETWORK'
CIJ(eye(size(CIJ))~=0)=0;

% ensure CIJ is binary...
CIJ = double(CIJ~=0);

deg = sum(CIJ);

%%% @Yu: Add a part of computing global degree
n = size(CIJ,1);
glodeg = sum(deg)/n;

