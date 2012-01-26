%%
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
%%%%%%%%%%%%%%%%%%%%%%FROM HERE BASICLY THE SAME%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%CAN BE IMPLEMENTED AS A FUNCTION%%%%%%%%%%%
%!!!!!!!etract must be's
DrivVecPermuDef=(DrivVec==2);    

%list all situation for could be's 
DrivVecPos=(DrivVec==1);    %extract could be's
nposs=nnz(DrivVecPos);  %# of 1s
DrivPermuMask=str2vec(dec2bin(0:2^nposs-1)); %get all possible permu mask
%permutes every possible indices:ConnPermu
ind=repmat(find(DrivVecPos)',2^nposs,1);
DrivPermuMask=DrivPermuMask.*ind;


a=zeros(nnodes,1);
%%%%%%%%%%%%%%%%THIS LINE IS DIFF  %%%%%%%%%%%%%%%%%%%%%
DrivVecPermuPos=zeros(nnodes,1,2^nposs);
DrivVecPermuPos(:,:,1)=a;
for i=2:2^nposs
    a=zeros(nnodes,1);
    pos=DrivPermuMask(i,:);
    a(pos(pos>0))=1;
    DrivVecPermuPos(:,:,i)=a;
end

%define whole connection permutation matrix, 2^nposs in total
%%%%%%%%%%%%%%%%%THIS LINE IS DIFF   %%%%%%%%%%%%%%%%%%%%
DrivPermu=zeros(nnodes,1,2^nposs);
for i=1:2^nposs
    DrivPermu(:,:,i)=squeeze(DrivVecPermuPos(:,:,i))+DrivVecPermuDef;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%END HERE%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



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

%implement permutation(get every possible permutation)
%!!!!!!!etract must be's
ConnMatPermuDef=(ConnMat==2);    

%list all situation for could be's 
ConnMatPos=(ConnMat==1);    %extract could be's
nposs=nnz(ConnMatPos);  %# of 1s
ConnPermuMask=str2vec(dec2bin(0:2^nposs-1)); %get all possible permu mask
%permutes every possible indices:ConnPermu
ind=repmat(find(ConnMatPos)',2^nposs,1);
ConnPermuMask=ConnPermuMask.*ind;


a=zeros(nnodes);
ConnMatPermuPos=zeros(nnodes,nnodes,2^nposs);
ConnMatPermuPos(:,:,1)=a;
for i=2:2^nposs
    a=zeros(nnodes);
    pos=ConnPermuMask(i,:);
    a(pos(pos>0))=1;
    ConnMatPermuPos(:,:,i)=a;
end

%define whole connection permutation matrix, 2^nposs in total
ConnPermu=zeros(nnodes,nnodes,2^nposs);
for i=1:2^nposs
    ConnPermu(:,:,i)=squeeze(ConnMatPermuPos(:,:,i))+ConnMatPermuDef;
end




%-----------       define modulatory matrix    --------
%Modu 

