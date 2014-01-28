function tmap=tile(maps);

xsize=size(maps,1);
ysize=size(maps,2);
zsize=size(maps,3);

sqsize=ceil(sqrt(zsize));

repnum=floor(zsize/sqsize);

extranum=zsize-repnum*sqsize;

temp=zeros(sqsize*xsize,sqsize*ysize);

for rownum=1:repnum
%size(temp(((1:xsize)+(rownum-1)*xsize),:))
%size(maps(:,:,((1:sqsize)+((rownum-1)*sqsize))))

temp(((1:xsize)+(rownum-1)*xsize),:)=reshape(maps(:,:,((1:sqsize)+((rownum-1)*sqsize))),[xsize ysize*sqsize]);
end;
%disp('hi')
for xnum=1:extranum
%disp('hi')
temp(((1:xsize)+repnum*xsize),((1:ysize)+((xnum-1)*ysize)))=maps(:,:,((repnum*sqsize)+xnum));
end;

tmap=temp;


