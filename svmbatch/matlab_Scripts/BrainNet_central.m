if strcmp(BrainVol,'')
    BrainVol = fullfile(mcRoot,'svmbatch','lib','BrainNetViewer','Data','SurfTemplate','BrainMesh_Ch2withCerebellum.nv');
end

if strcmp(CfgFile,'')
    CfgFile = fullfile(mcRoot,'svmbatch','lib','BrainNetViewer','Data','Brain_AAL_Nodes_Edges_edited.mat');
end

for iC = 1:size(Files,1)
    
    NodeFile = fullfile(Exp,Files{iC},'.node');
    EdgeFile = fullfile(Exp,Files{iC},'.edge');
    OutputPath = fullfile(Exp,Files{iC},'.bmp');

    BrainNet_MapCfg(BrainVol,NodeFile,EdgeFile,CfgFile,OutputPath,ind);
end
