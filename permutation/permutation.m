%This function requires an input matrix ('InputMat') which needs to be permuted
%This input matrix can be any size, but with element values of 0/1/2 which
%represent possibilities of each element.
%0 means not allowed; 1 means could be; 2 means must be
%

function [PermuMat]=permutation (InputMat)
    
%implement permutation(get every possible permutation)
%define # of rows and # of cols
%[nrow, ncol,nslice]=size(InputMat);
dim=size(InputMat);
%if the matrix is 2D, use 2D permutation
if length(dim)==2
    PermuMat=permutation2D(InputMat);
%if it's more than 2D, first flatten it then do 2D permutation then
%change it back
else
%flatten to 2D
nrow=dim(1);
ncol=prod(dim(2:end));

FlatMat=reshape(InputMat,[nrow,ncol]);
PermuMat2D=permutation2D(FlatMat);

%change it back to its original size
dimP=size(PermuMat2D);
nperm=dimP(3);
PermuMat=reshape(PermuMat2D,[dim,nperm]);
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%END HERE%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
