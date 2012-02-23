function anewnum=str2vec (amat)

anewnum=[];

[nrow,ncol]=size(amat);
for n=1:nrow

a=amat(n,:);
i=1;
anew=[];
while i<=length(a)
    anew = [anew,' ', a(i)];
    i=i+1;
end

anew=anew(2:length(anew));
anewnum(n,:)=str2num(anew);

end