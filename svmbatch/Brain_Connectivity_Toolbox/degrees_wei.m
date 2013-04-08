function [ deg,glodeg,strength,glostr ] = degrees_wei( CIJ )
%DEGREE_WEI Summary of this function goes here
%   

%%% @Yu:set the diagonal of CIJ to 0
%%% from the 2009 review paper: 
%%% 'The degree of a node is the number of connections that linke it to the
%%% REST OF THE NETWORK'
CIJ(eye(size(CIJ))~=0)=0;


strength = sum(CIJ); % Exclude self connection

CIJ = double(CIJ~=0); % convert to binary matrix

deg = sum(CIJ);

%%% @Yu: Add a part of computing global degree
n = size(CIJ,1);
glodeg = sum(deg)/n;
glostr = sum(strength)/n;

end

