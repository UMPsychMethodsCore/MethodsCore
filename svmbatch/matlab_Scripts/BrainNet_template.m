%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Where do all of the edge and node files live? %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Exp=['/net/data4/Schiz_COBRE/UnivariateConnectomics/CensorZ_FDpoint5_0f0bExclude_50good/'];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Which node/edge files do you want to draw? Provide a cell %
% array of strings which will serve as the base file names  %
% (this program will automatically append .edge and .node   %
% for you)                                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Files = {

    };
    
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


BrainNet_central;
