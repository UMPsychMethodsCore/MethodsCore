function BC=betweenness_bin(G)
%BETWEENNESS_BIN    Node betweenness centrality
%
%   BC = betweenness_bin(A);
%
%   Node betweenness centrality is the fraction of all shortest paths in 
%   the network that contain a given node. Nodes with high values of 
%   betweenness centrality participate in a large number of shortest paths.
%
%   Input:      A,      binary (directed/undirected) connection matrix.
%
%   Output:     BC,     node betweenness centrality vector.
%
%   Note: Betweenness centrality may be normalised to the range [0,1] as
%   BC/[(N-1)(N-2)], where N is the number of nodes in the network.
%   
%
%   Reference: Kintali (2008) arXiv:0809.1906v2 [cs.DS]
%              (generalization to directed and disconnected graphs)
%
%
%   Mika Rubinov, UNSW/U Cambridge, 2007-2012

%%% @Yu:set the diagonal of G to 0
G(eye(size(G))~=0)=0;

% tic
n=length(G);                %number of nodes
I=eye(n)~=0;                %logical identity matrix
d=1;                     	%path length
NPd=G;                      %number of paths of length |d|
NSPd=NPd;                  	%number of shortest paths of length |d|
NSP=NSPd; NSP(I)=1;        	%number of shortest paths of any length
L=NSPd; L(I)=1;           	%length of shortest paths, @Yu: initial is direct connected nodes, their length of shortest paths would just be 1.
% toc  % ~30s

%@Yu calculate NSP and L $3.1.1
while find(NSPd,1);
%     tic
    d=d+1;
%     toc   % ~0.001s

%     tic
    NPd=NPd*G;   %@Yu (NPd: Z in the paper, A^d: the number of paths from i to j of length=|d|, allow repeating nodes along the path)
%     toc   % 761s  !!!!!!!!!!! main time-consuming part 1
    
%     tic
    NSPd=NPd.*(L==0);  %@Yu exclude nodes connected with shorter paths to get number of shortest paths of length |d|
%     toc  % 10s
    
%     tic
    NSP=NSP+NSPd;  %@Yu number of shortest paths of any length
%     toc  % 0.73s
    
%     tic
    L=L+d.*(NSPd~=0);    %@Yu NSPd~=0 means the pair is connected shortest with length|d|, times d gives you the length
%     toc  % 12.72s
end

%@Yu Up till now we have: L - length of shortest paths; NSP(big lambda in paper): number of shortest paths of any length
%@Yu O(n^omega*diam), where omega<e=2.376

% tic
L(~L)=inf; L(I)=0;          %L for disconnected vertices is inf, @Yu exclude diagnoal
NSP(~NSP)=1;                %NSP for disconnected vertices is 1
% toc  %30s

% tic
Gt=G.';                     %@Yu:Gt will be the same as G for undirected graphs
DP=zeros(n);            	%vertex on vertex dependency
diam=d-1;                  	%graph diameter (@Yu the longest shortest path)
% toc  %17s

%@Yu calculate DP, completely follows 'ComputeDependency' in $3.1.2
for d=diam:-1:2  %@Yu no need to calculate the situation when d=1
%     tic
    DPd1=(((L==d).*(1+DP)./NSP)*Gt).*((L==(d-1)).*NSP);  %@Yu DPd1 is delta(l-1) in paper
    DP=DP + DPd1;           %DPd1: dependencies on vertices |d-1| from source
%     toc  % 757s!!!!!!!!!  main time-consuming part 2
end

% tic
BC=sum(DP,1);               %compute betweenness
% toc  % 0.3s

% @Yu: add BC normalization
% BC = BC./[(n-1)*(n-2)];