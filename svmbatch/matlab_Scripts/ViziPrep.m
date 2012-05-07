%% Reconstruct into square matrix


NodeImplication=zeros(1139,1139);

NodeImplication(logical(cleanconMat))=pruneIntersect;


%% Build index matrix

NodeImplication=zeros(1139,1139);

% features=1:size(pruneIntersect,2);

NodeImplication(:)=1:1139^2;

NodeImplication_flat=connectivity_grid_flatten(NodeImplication,'',1,ones(1139,1139),2);

% NodeImplication_flat_sparse=NodeImplication_flat(NodeImplication_flat~=0);

pruneIntersect_square=zeros(1139,1139);

pruneIntersect_square(NodeImplication_flat)=pruneIntersect;

ROIs=sum(pruneIntersect_square);

ROIs(ROIs~=0)=1;


%% Write out your ROIs

parameters=load('/net/data4/MAS/FirstLevel/5001/Tx1/MSIT/HRF/FixDur/TBTGrid/TBTGrid_parameters.mat');
ROIlist=parameters.parameters.rois.mni.coordinates;

ROIlist(:,4)=ROIs';
ROIlist(:,5)=ROIs';



goodROIs=ROIlist(logical(ROIs)',:);


%% Write the tab-delimited files

dlmwrite('nodes.node',ROIlist,'\t')
dlmwrite('edges.edge',pruneIntersect_square,'\t')
cell2mat


%% Invert the flattening

roimat = zeros(1,(1139^2-1139)/2);

cleanconMat_flat=connectivity_grid_flatten(cleanconMat,'',1,ones(1139,1139),2);

size(roimat(logical(cleanconMat_flat)))

roimat(find(cleanconMat_flat)

%% A different