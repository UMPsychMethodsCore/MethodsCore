%%Dan's Comments
% Objects
%   permD - permissibility matrix of driving inputs
%   permC - permissibility matrix of fixed connectivity
%   permM - permissibility matrix of modulatory connectivity
%   allD  - cell array of length nD x 1 where nD = # of possible driving
%   input configurations
%   allC  - cell array of length nC x 1 where nC = # of poss connectivities
%   allM  - cell array of length nC x 1. Each cell will contain another cell
%   array, size c* x 1 where c* is the number of possible modulatory
%   connectivity configurations for a given fixed connectivity matrix
%   (indexed by nC)
%   allDCM - cell array length 3 x (nD * sum(c* over nC))


%%
clear all
clc

t=cputime;

%define nodes
nnodes=5;       %# of nodes

%--------------------------------------------------------
%----                      DRIVING                 ------
%--------------------------------------------------------
%define driving vector
permD=[2,1,0,0,1]';

%---------    define driving permutation vector   -------
%---------           defined as 'allD'         -----
%implement permutation(get every possible permutation)
allD=permutation(permD);
[nDrow, nDcol, nD]=size(allD);


%--------------------------------------------------------
%----                   CONNECTION                 ------
%--------------------------------------------------------
%connection matrix: 5*5 diagnal matrix w/ diagnol of 2
permC=2*diag(ones(nnodes,1));  
%user define
permC=[2,2,0,2,2;1,2,2,0,0;0,2,2,2,0;0,0,1,2,1;1,0,0,1,2];


% %determine whether diagnals are set to 2
% ConnCompMat=(permC>1);
% ConnTemplate=diag(ones(nnodes,1));
% if isequal(ConnTemplate & ConnCompMat, ConnTemplate)==0
%     disp(sprintf('The diagnol must all be set to 2'));
% end

%---------    define connection permutation matrix -------
%---------           defined as 'allC'         -----
allC=permutation (permC);
[nCrow,nCcol,nC]=size(allC);


%--------------------------------------------------------
%----                   MODULATORY                 ------
%--------------------------------------------------------
%-----------       define modulatory matrix    --------
permM=[0,2,0,1,0;1,0,0,0,0;0,1,0,0,0;0,0,2,0,1;0,0,0,1,0];

%------define modulatory matrices for each connectivity matrices
%------store all modu mats for the ith conn mat in allM{i}
ModuCell=cell (1,nC);
for i = 1 : nC
    ModuClean=permM.*squeeze(allC(:,:,i));
    allM{i}=permutation(ModuClean);
end
%%

% %--------------------------------------------------------
% %----                  COMBINE DCM                 ------
% %--------------------------------------------------------
%nM stores each 
totalnM=0;
for i=1:nC
    [nMrow, nMcol, nM(i)]=size(allM{i});
    totalnM=totalnM+nM(i);
end
            
allDCM= cell(3,totalnM);
for i=1:nD
    for j=1:nC
        for k=1:nM(j)
            allDCM{1,sum(nM(1:j-1))+k}=allD(:,:,i);
            allDCM{2,sum(nM(1:j-1))+k}=allC(:,:,j);
            %
            %M=cell(1,nM(j));
            M=allM{1,j};
            allDCM{3,sum(nM(1:j-1))+k}=M(:,:,k);
        end
    end
end


 t=cputime-t