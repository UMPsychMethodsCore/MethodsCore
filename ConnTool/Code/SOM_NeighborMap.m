% NEIGHBS = KOHNEIGHBS(GRIDSIZE,NEIGHBSIZE,LRATE)
%
%	GRIDSIZE = [M,N] is the size of the grid.
%	NEIGHBSIZE is a scale factor for the neighborhood function.
%	LRATE is the learning rate.
%
%	NEIGHBS is an M x N cell array whose elements are M x N matrices
%	which define the degree of updating for each of the neighbors 
%	of that unit.

function results = SOM_NeighborMap(GridSize,NeighSize)

M = GridSize(1); 
N = GridSize(2);

mcoords = (1:M)' * ones(1,N);
ncoords = ones(M,1) * (1:N);
nvalues = exp(-(0:((M-1)^2+(N-1)^2))/(NeighSize^2));

for i = 1:M
    for j = 1:N
        distsqmat = (i-mcoords).^2 + (j-ncoords).^2 + 1;
        results{i,j} = nvalues(distsqmat);
    end
end
