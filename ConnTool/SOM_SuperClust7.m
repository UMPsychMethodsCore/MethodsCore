% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh/Scott Peltier
% Copyright 2010
%
% A routine to super cluster the SOM exemplars
%
% function [scmap_new,distmap]=SOM_SuperClust7(exemap,max_clustnum);
%
% max_clustnum is the maximum number of super clusters
% exemap is the examplar map which is on a grid and organized as
% xGrid x yGrid x Time
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function [scmap_new,distmap]=SOM_SuperClust7(exemap,max_clustnum);

xsize=size(exemap,1);
ysize=size(exemap,2);

distmap=zeros(xsize,ysize,8);
scmap=zeros(xsize,ysize);

clustnum=0;

for x=1:xsize
  for y=1:ysize    
    tc=squeeze(exemap(x,y,:));
    if ((x-1)<1)
      distmap(x,y,[1 4 6])=NaN;
    else
      tcleft=squeeze(exemap(x-1,y,:));
      distmap(x,y,4)=sum((tc-tcleft).^2);  
    end;
    if ((y-1)<1)
      distmap(x,y,[1 2 3])=NaN;
    else
      tctop=squeeze(exemap(x,y-1,:));
      distmap(x,y,2)=sum((tc-tctop).^2);
    end;
    if ((x+1)>xsize)
      distmap(x,y,[3 5 8])=NaN;
    else
      tcright=squeeze(exemap(x+1,y,:));
      distmap(x,y,5)=sum((tc-tcright).^2);    
    end;
    if ((y+1)>ysize)
      distmap(x,y,[6 7 8])=NaN;
    else
      tcbott=squeeze(exemap(x,y+1,:));
      distmap(x,y,7)=sum((tc-tcbott).^2);    
    end;
    if (((x-1)>0) & ((y-1)>0))
      tculc=squeeze(exemap(x-1,y-1,:));
      distmap(x,y,1)=sum((tc-tculc).^2);    
    end;
    if ((x<xsize) & ((y-1)>0))
      tcurc=squeeze(exemap(x+1,y-1,:));
      distmap(x,y,3)=sum((tc-tcurc).^2);    
    end;
    if (((x-1)>0) & (y<ysize))
      tcblc=squeeze(exemap(x-1,y+1,:));
      distmap(x,y,6)=sum((tc-tcblc).^2);    
    end;
    if ((x<xsize) & (y<ysize))
      tcbrc=squeeze(exemap(x+1,y+1,:));
      distmap(x,y,8)=sum((tc-tcbrc).^2);    
    end;
    distmap(x,y,find(distmap(x,y,:)==0))=NaN;
  end;
end;

if (clustnum==0), distmap_org=distmap; end;

[srtd_dist,dirs]=sort(distmap,3);

for i=1:2
  
  indx=i;
  cur_map=squeeze(distmap(:,:,indx));
  min_num=length(unique(cur_map(:)));
  
  for t=1:min_num
    [xlist,ylist]=find(srtd_dist(:,:,indx)==min(min(srtd_dist(:,:,indx))));
    mloop=1;
    while (((i<2) | (length(unique(scmap))>max_clustnum)) & (mloop<=length(xlist)))
      orgx=xlist(mloop);
      orgy=ylist(mloop);
      nbnum=dirs(orgx,orgy,indx);
      if (any(nbnum==[1 2 3]))
	nbry=orgy-1;
      elseif (any(nbnum==[6 7 8]))
	nbry=orgy+1;
      else
	nbry=orgy;
      end;
      if (any(nbnum==[1 4 6]))
	nbrx=orgx-1;
      elseif (any(nbnum==[3 5 8]))
	nbrx=orgx+1;
      else
	nbrx=orgx;
      end;
      if ((scmap(orgx,orgy)==0) & (scmap(nbrx,nbry)==0))
	clustnum=clustnum+1;
	scmap(orgx,orgy)=clustnum;
	scmap(nbrx,nbry)=clustnum;
      elseif ((scmap(orgx,orgy)==0))
	scmap(orgx,orgy)=scmap(nbrx,nbry);
      elseif ((scmap(nbrx,nbry)==0))
	scmap(nbrx,nbry)=scmap(orgx,orgy);
      else
	[gx,gy]=find(scmap==scmap(nbrx,nbry));
	for g=1:length(gx)
	  scmap(gx(g),gy(g))=scmap(orgx,orgy);
	end;
      end;
      srtd_dist(orgx,orgy,indx)=NaN;   
      mloop=mloop+1;
    end;
    
  end;  %min_num
end;	%i 

ulst=unique(scmap);
scmap_new=zeros(size(scmap));

for n=1:length(ulst)
  [x,y]=find(scmap==ulst(n));
  for g=1:length(x)
    scmap_new(x(g),y(g))=n;
  end;
end;

%
% All done
%