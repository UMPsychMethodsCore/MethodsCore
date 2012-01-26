%%Dan's Comments
% Objects
%   permD - permissibility matrix of driving inputs
%   permC - permissibility matrix of fixed connectivity
%   permM - permissibility matrix of modulatory connectivity
%   allD  - cell array of length a x 1 where a = # of possible driving
%   input configurations
%   allC  - cell array of length b x 1 where b = # of poss connectivities
%   allM  - cell array of length b x 1. Each cell will contain another cell
%   array, size c* x 1 where c* is the number of possible modulatory
%   connectivity configurations for a given fixed connectivity matrix
%   (indexed by b)
%   allDCM - cell array length 3 x (a * sum(c* over b))


%%
t=cputime;

%define nodes
nnodes=5;       %# of nodes

%--------------------------------------------------------
%----                      DRIVING                 ------
%--------------------------------------------------------
%define driving vector
DrivVec=[2,1,0,0,1]';

%---------    define driving permutation vector   -------
%---------           defined as 'DrivPermu'         -----
%implement permutation(get every possible permutation)
DrivPermu=permutation(DrivVec);



%--------------------------------------------------------
%----                   CONNECTION                 ------
%--------------------------------------------------------
%connection matrix: 5*5 diagnal matrix w/ diagnol of 2
ConnMat=2*diag(ones(nnodes,1));  
%user define
ConnMat=[2,2,0,2,2;1,2,2,0,0;0,2,2,2,0;0,0,1,2,1;1,0,0,1,2];

%---------    define connection permutation matrix -------
%---------           defined as 'ConnPermu'         -----
%determine whether diagnals are set to 2
ConnCompMat=(ConnMat>1);
ConnTemplate=diag(ones(nnodes,1));
if isequal(ConnTemplate & ConnCompMat, ConnTemplate)==0
    disp(sprintf('The diagnol must all be set to 2'));
end

ConnPermu=permutation (ConnMat);
%t=cputime-t;
%--------------------------------------------------------
%----                   MODULATION                 ------
%--------------------------------------------------------
%-----------       define modulatory matrix    --------
%Modu

