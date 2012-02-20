%This function requires an input matrix ('InputMat') which needs to be permuted
%This input matrix can be any size, but with element values of 0/1/2 which
%represent possibilities of each element.
%0 means not allowed; 1 means could be; 2 means must be
%For example, with a driving matrix for 5 nodes, the matrix can be like
%follows (each element means can this driving feature affect the node or not):
%                      | 2 |
%                      | 1 |
%                      | 0 |
%                      | 0 |
%                      | 1 |
%This will be the input of the matrix
%The output matrix will be a 5*1*4 matrix, which means there are 4
%possibilities (two 1's, possibility # is 2^2), each can be pulled out from
%PermuMat(:,:,i) (i means the ith possibility)

function [PermuMat]=permutation3D (InputMat)
    
%implement permutation(get every possible permutation)
%define # of rows and # of cols
[nrow, ncol,nslice]=size(InputMat);

FlatMat=squeeze(reshape(InputMat,[nrow,ncol*nslice,1]));
PermuMat2D=permutation(FlatMat);

[dim]=size(PermuMat2D);
PermuMat=reshape(PermuMat2D,[nrow,ncol,nslice,dim(3)]);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%END HERE%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
