% condition: net_1 < net_2
ind.label1=[4];  
ind.label2=[7];

Exp=['/net/data4/ADHD/UnivariateConnectomics/Results/1166_CensorZ/'];

BrainVol=['/home/slab/users/krishan/repos/MethodsCore/svmbatch/lib/BrainNetViewer/Data/SurfTemplate/BrainMesh_Ch2withCerebellum.nv'];
CfgFile=['/net/data4/ADHD/UnivariateConnectomics/Results/1166_CensorZ/Brain_AAL_Nodes_Edges_edited.mat'];
NodeFile=sprintf('%s%d-%d.node',Exp,ind.label1,ind.label2);
EdgeFile=sprintf('%s%d-%d.edge',Exp,ind.label1,ind.label2);
OutputPath=sprintf('%s%d-%d.bmp',Exp,ind.label1,ind.label2); 

%superior view
ind.orig.sup=[-66, 24;
     66,  24;
     -66, -60;
     66, -60;
     6, -108;
     -42, -96;];

ind.edit.sup=[-64, 24;
     64,  24;
     -64, -60;
     64, -60;
     8, -105;
     -42, -93;];
 
 %lateral view
 %index of outliers in lateral view
ind.orig.lat=[24,  72;
    -12,  84;
    %     -48, -36; %cerebellum
    %     -60, -36;
    %     -72, -36;
    %     -84, -36;
    -96, -24;
    -96,  36;
    -108,  0;
    -108, 12;];

ind.edit.lat=[24,  69;
    -12,  81;
    %     -48, -36; %cerebellum
    %     -60, -36;
    %     -72, -36;
    %     -84, -36;
    -96, -21;
    -94,  36;
    -105,  0;
    -105, 12;];
 
%anterior view
ind.orig.ant=[-66, 48;
     66,  48;];

ind.edit.ant=[-63, 48;
     63,  48;];
 
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

%Central Script
BrainNet_MapCfg(BrainVol,NodeFile,EdgeFile,CfgFile,OutputPath,ind);