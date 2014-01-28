function results = SOM_CostFunctionMI(theData, theSOM)

nVoxels = size(theData,1);
nTime = size(theData,2);
nSOM = size(theSOM,2);

minx = min(theData,[],2);
miny = min(theSOM,[],1);
minx_rep = repmat(minx,1,nTime);
miny_rep = repmat(miny,nTime,1);
maxx = max(theData,[],2);
maxy = max(theSOM,[],1);

nx = floor(nTime^(1/3)+.5);
deltax = (maxx-minx)/(nx-1);
deltay = (maxy-miny)/(nx-1);
deltax_rep = repmat(deltax,1,nTime);
deltay_rep = repmat(deltay,nTime,1);

iX = floor((theData-minx_rep)./deltax_rep+1.5);
iY = floor((theSOM-miny_rep)./deltay_rep+1.5);

histIncr = 1/nTime;

HX = zeros(nVoxels,nx);
HY = zeros(nSOM,nx);
for ii=1:nx
  HX(:,ii) = sum(iX==ii,2)*histIncr;
  HY(:,ii) = sum(iY==ii,1)*histIncr;
end
clear deltax
clear deltax_rep
clear maxx
clear minx
clear minx_rep
%keyboard;
%tic
for ii=1:nx
    eval(sprintf('HY_rep%d = log(repmat(HY(:,%d)'',nVoxels,1));',ii,ii));
end
%HY_rep = log(repmat(HY(:,1)',nVoxels,1));
results = zeros(nVoxels,nSOM);
for ii=1:nx
    HX_rep = repmat(HX(:,ii),1,nSOM);
    HX_rep = log(HX_rep);
    for jj=1:nx
        JH = single(iX==ii)*histIncr*(iY==jj);
        eval(sprintf('results = results + JH.*(log((JH+1e-10))-HX_rep-HY_rep%d);',jj));
    end
    ii
end
%toc

%keyboard;