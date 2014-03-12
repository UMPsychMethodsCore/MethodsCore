function C=clustering_coef_bu(G)
%CLUSTERING_COEF_BU     Clustering coefficient
%
%   C = clustering_coef_bu(A);
%
%   The clustering coefficient is the fraction of triangles around a node
%   (equiv. the fraction of node�s neighbors that are neighbors of each other).
%
%   %%% @Yu: For example, node 1 has neighbors of 2,3 and itself(1), this function
%   calculates the ratio of (the edges between these neighbors(include the deges 
%   between themselves) and (all of
%   the possible edges between these neighbors (not include the edges
%   between themselves))  <---------- got this based on the code
%   Fix: only calculate the edges between the neighbors, do not include
%   self connection. %%%
%
%   Input:      A,      binary undirected connection matrix
%
%   Output:     C,      clustering coefficient vector
%
%   Reference: Watts and Strogatz (1998) Nature 393:440-442.
%
%
%   Mika Rubinov, UNSW, 2007-2010

n=length(G);
C=zeros(n,1);
G(eye(n)~=0)=0; % @Yu: fix G, no self connection should be considered

for u=1:n
    V=find(G(u,:));
    k=length(V);
    if k>=2;                % @Yu: if k smaller than 2, no triangle will exist around this node 
        S=G(V,V);
        C(u)=sum(S(:))/(k^2-k);
    end
end