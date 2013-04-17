% condition: net_1 < net_2
net.label1=[1];  
net.label2=[7];

Exp=['/net/data4/ADHD/UnivariateConnectomics/Results/1166_CensorZ/'];

BrainVol=['/home/slab/users/krishan/repos/MethodsCore/svmbatch/lib/BrainNetViewer/Data/SurfTemplate/BrainMesh_Ch2withCerebellum.nv'];
CfgFile=['/net/data4/ADHD/UnivariateConnectomics/Results/1166_CensorZ/Brain_AAL_Nodes_Edges_edited.mat'];
NodeFile=sprintf('%s%d-%d.node',Exp,net.label1,net.label2);
EdgeFile=sprintf('%s%d-%d.edge',Exp,net.label1,net.label2);
OutputPath=sprintf('%s%d-%d.bmp',Exp,net.label1,net.label2); 

BrainNet_MapCfg(BrainVol,NodeFile,EdgeFile,CfgFile,OutputPath,net);


% for i=1:length(ind_lat)
% rois=[find(surf.sphere(:,2)==ind_lat(i,1)&surf.sphere(:,3)==ind_lat(i,2)); rois];
% end
% outlier_rois=rois(find(surf.sphere(rois,4)==net_1|surf.sphere(rois,4)==net_2))
% outlier_coord=unique(surf.sphere(outlier_rois,2:3),'rows')

% Displays the co-ordinates of outliers and expects input co-ordinates for nudging nodes
% if ~isempty(outlier_coord)
%     printmat(outliers,'Outliers detected - lateral view',num2str([1:length(outliers)]),'Y Z');
%     data=input('Select the co-ordinates that require nudging : \n')
%     if ~isempty(data)
%         for i=1:size(data,1)
%             surf.sphere(outlier_rois(data(i,1)),2:3)=data(i,2:3)
%         end
%     end
% end