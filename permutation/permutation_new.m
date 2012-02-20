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

function [PermuMat]=permutation (InputMat)
    
%implement permutation(get every possible permutation)
%define # of rows and # of cols
dim=size(InputMat);
dimensioncol=repmat(':,',1,size(dim,2));  %':,:,:,...' 

%!!!!!!!extract must be's
InputMatPermuDef=(InputMat==2);    

%list all situation for could be's 
InputMatPos=(InputMat==1);    %extract could be's
nposs=nnz(InputMatPos);  %# of 1s
InputPermuMask=str2vec(dec2bin(0:2^nposs-1)); %get all possible permu mask
%permutes every possible indices:InputPermu
ind=repmat(find(InputMatPos)',2^nposs,1);
InputPermuMask=InputPermuMask.*ind;


a=zeros([dim]);
InputMatPermuPos=zeros([[dim] 2^nposs]);
dimensioncol=repmat(':,',1,size(dim,2));
eval(['InputMatPermuPos(' dimensioncol '1)=a;']);
if nposs>1
    for i=2:2^nposs
        a=zeros([dim]);
        pos=InputPermuMask(i,:);
        a(pos(pos>0))=1;

        eval(['InputMatPermuPos(' dimensioncol 'i)=a;']);
    end
end


%define whole Inputection permutation matrix, 2^nposs in total
PermuMat=zeros([[dim] 2^nposs]);
for i=1:2^nposs
    %dimensioncol=repmat(':,',1,size(dim,2));
    eval(['InputMatPermuPos(' dimensioncol 'i)=squeeze(InputMatPermuPos(' dimensioncol 'i))+InputMatPermuDef;']);

   % PermuMat(:,:,i)=squeeze(InputMatPermuPos(:,:,i))+InputMatPermuDef;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%END HERE%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
