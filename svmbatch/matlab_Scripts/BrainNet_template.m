%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Where do all of the edge and node files live? %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Exp=['/net/data4/Schiz_COBRE/UnivariateConnectomics/CensorZ_FDpoint5_0f0bExclude_50good/'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% What network intersections are you interested in drawing?         %
% Provide a 2D matrix for this, where rows index "cells",           %
% and column 1 is the first network, column 2 is the second network %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Nets = [
    1 12
    12 12
    7 12
    6 12
    4 12
    3 12
    1 12
    6 7
    7 7
    5 7
    4 7
    1 7
    6 6
    4 6
    3 6
    1 6
    3 5
    4 5
    1 5
    4 4
    3 4
    2 4
    1 4
    3 3
    ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify labels and colormap to be used for the it                                       %
% Column 1 is the label and Columns 2, 3 and 4 are the values of R,G & B respectively     %
% The labels have to be positive integers                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ind.CM=[2, 1, 0, 1;
    3, 0, 1, 1];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Which Brain Surface should BNV use? If you give an empty string, it will use %
% BrainMesh_Ch2withCerebellum by default.                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BrainVol='';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do you have a BNV config file you'd like to use? If so, point to it here.                %
% If you supply an empty string, it will use a default configuration included in the repo. %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CfgFile='';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sometimes, nodes end up appearing outside of the brain. You can "nudge" them %
% back inside the surface using the following options. In all cases, you will  %
% specify the "out of brain" coordinates by view. You will provide a set of    %
% the original "bad" coordinates, and then a corresponding list of where they  %
% should be "nudged".                                                          %
%                                                                              %
% Since each view is parallel to one of the axes, that axis doesn't matter     %
% (e.g. for the superior view, you only have to specify x and y, since you are %
% looking along z.                                                             %
%                                                                              %
% Here is the mapping of columns to dimensions                                 %
%                                                                              %
% Superior - X, Y                                                              %
% Lateral  - Y, Z                                                              %
% Anterior - X, Z                                                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Superior Original
ind.orig.sup=[-66, 24;
     66,  24;
     -66, -60;
     66, -60;
     6, -108;
     -42, -96;];

% Superior Corrected
ind.edit.sup=[-64, 24;
     64,  24;
     -64, -60;
     64, -60;
     8, -105;
     -42, -93;];
 
% Lateral View Original
ind.orig.lat=[24,  72;
    -12,  84;
    -96, -24;
    -96,  36;
    -108,  0;
    -108, 12;];

% Lateral View Corrected
ind.edit.lat=[24,  69;
    -12,  81;
    -96, -21;
    -94,  36;
    -105,  0;
    -105, 12;];
 
% Anterior View Original
ind.orig.ant=[-66, 48;
     66,  48;];

% Anterior View Corrected
ind.edit.ant=[-63, 48;
     63,  48;];
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO NOT EDIT BELOW THIS LINE %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..','..');
%DEVSTOP

%[DEVmcRootAssign]

addpath(genpath(fullfile(mcRoot,'matlabScripts')))
addpath(genpath(fullfile(mcRoot,'svmbatch')))


if strcmp(BrainVol,'')
    BrainVol = fullfile(mcRoot,'svmbatch','lib','BrainNetViewer','Data','SurfTemplate','BrainMesh_Ch2withCerebellum.nv');
end

if strcmp(CfgFile,'')
    CfgFile = fullfile(mcRoot,'svmbatch','lib','BrainNetViewer','Data','Brain_AAL_Nodes_Edges_edited.mat');
end

for iC = 1:size(Nets,1)
    ind.label1 = Nets(iC,1);
    ind.label2 = Nets(iC,2);
    
    NodeFile=sprintf('%s%d-%d.node',Exp,ind.label1,ind.label2);
    EdgeFile=sprintf('%s%d-%d.edge',Exp,ind.label1,ind.label2);
    OutputPath=sprintf('%s%d-%d.bmp',Exp,ind.label1,ind.label2); 

    BrainNet_MapCfg(BrainVol,NodeFile,EdgeFile,CfgFile,OutputPath,ind);
end
