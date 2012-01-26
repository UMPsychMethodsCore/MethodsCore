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

