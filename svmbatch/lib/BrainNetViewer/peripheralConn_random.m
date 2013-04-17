function peripheralConn_random(roimat)
%function [edgemat]= peripheralConn_random(roimat,edgemat)
 
%rois=find(roimat(:,1)==-6);
% load /home/slab/users/kesslerd/repos/scratch_analysis_scripts/GO/GO_ERT_cPPI_3DBlocks.mat
% roi_i=find(roimat(:,2)==-108);
% roimat(roi_i,2)=-105;
% findroi([18,72,0]) % repeat for z=12,24
x=roimat(:,1);
y=roimat(:,2);

for i=min(x):12:max(x)
    for j=min(y):12:max(y)
        %for k=min(z):12:max(z)
        coord=[i,j];
            if findroi(coord, roimat)
               iROIs= findroi(coord, roimat);
               coord= [coord min(roimat(iROIs,3))];
               connectneighbour(findroi(coord, roimat), roimat)
               coord(3)= max(roimat(iROIs,3));
               connectneighbour(findroi(coord, roimat), roimat)
            end
    end
end

 
% for i=1:length(rois)
%     connectneighbour(rois(i), roimat)
% end 

% for i=1:length(roi_ind)
%     %iROI1=roi_ind
%     for j=1:length(roi_ind-1)
%     % iROI2=[roi_ind(i+1:end)]
%     roimat(iROI,4)
%      edgemat(roi_ind(i),roi_ind(j))=1;
%     count=count+1;
%     end
% end

%find ROIs matching one coordinate


%Find an ROI given its co-ordinates
function ind = findroi(coord, roimat)
ind=find(ismember(roimat(:,1:numel(coord)),coord,'rows'));

%Find co-ordinates given an ROI
function ind = findcoord(roi, roimat)
ind=roimat(roi,1:3);

%Connects two ROIs and forms an edge
function connectroi(roi1,roi2)
global edgemat1
edgemat1(roi1,roi2)=1;

%Finds all neighbouring ROIs for a given ROI and creates an edge provided
%the ROIs lie withing the 3D brain
function connectneighbour(roi, roimat)
for i1=(-1:1)*12
    for j1=(-1:1)*12
        for k1=(-1:1)*12
            coord=findcoord(roi, roimat)+[i1,j1,k1];
            roi2=findroi(coord, roimat);
            if ~isempty(findroi(coord, roimat));
                connectroi(roi,roi2);
            end
        end
    end
end

function findeucdist(roi1,roi2)i
%load /home/slab/users/kesslerd/repos/scratch_analysis_scripts/GO/GO_ERT_cPPI_3DBlocks.mat
for roi1=1:size(roimat,1)
    coord1=roimat(roi1,1:3);
    for roi2=roi1:size(roimat,1)
        coord2=roimat(roi2,1:3);
        %if edgemat(roi1,roi2)~=0 | edgemat(roi2,roi1)~=0
        eucdist(roi1,roi2)=sqrt(sum((coord1-coord2).^2));
%         if eucdist(roi1,roi2)>17
%             edgemat(roi1,roi2)=0;
%         end
     %   end
    end
end
net1=[1:7];
net2=[1:7];

rescaled = eucdist - 17; % zero out the adjacent ones
rescaled(rescaled <0) = 0;

rescaled = eucdist / max(eucdist(:)); %rescale it to max at 1

rescaled = rescaled .^ ( 1/200);

test = rand(size(eucdist));

edgemat = triu(test >= rescaled);
nnz(edgemat)

Network_Viz(edgemat,roimat,net1,net2,'roi_connectivitymap');

%{


temp=roimat(851,:);
roimat(851,:)=roimat(494,:);
roimat(494,:)=temp;

temp=roimat(850,:);
roimat(850,:)=roimat(635,:);
roimat(635,:)=temp;

roi=randi(1080,1,400);
edgemat(roi,:)=0;

shiftcoord=find(ismember(roimat(:,2),-108,'rows'));
roimat(shiftcoord,2)=-105;

create roi

%}

