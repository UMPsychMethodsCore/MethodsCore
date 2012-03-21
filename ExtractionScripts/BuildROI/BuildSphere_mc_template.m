%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Experiment Directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Exp='/net/data4/MAS/';  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  JobList; OutputDir is a template and can create nonexistant directories
%%
%%  Variables you can use in your template are:
%%       Exp = path to your experiment directory
%%  Example:
%%  OutputDir = '[Exp]/ROIS/'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

JobList = {...


%%%%%'Name of ROI to be created',  %%%% [x ,  y ,  z ] %%%,   radius,  %%%%%   'OutputDir/' ;

%      'test_15_17_1' ,                  [15, 17 , 1] ,          5,            '[Exp]/ROIS/'; ... 
%      'SMA_3_17_52' ,                   [3, 17 , 52] ,          5,            '[Exp]/ROIS/'; ...        
%      'LCaudate_n9_5_10' ,              [-9, 5 , 10] ,          5,            '[Exp]/ROIS/'; ...          
%      'IPL_n36_n49_49'                  [-36, -49 , 49] ,       5,            '[Exp]/ROIS/'; ... 
%      'Lingual_24_n85_n11' ,            [24, -85 , -11] ,       5,            '[Exp]/ROIS/'; ... 
%      'PCC_0_n46_28' ,                  [0, -46 , 28] ,         5,            '[Exp]/ROIS/'; ... 
%      'SMA_n6_2_58' ,                   [-6, 2 , 58] ,          5,            '[Exp]/ROIS/'; ... 
%      'SMA_n6_32_25' ,                  [-6, 32 , 25] ,         5,            '[Exp]/ROIS/'; ...      
       'SMA_n6_5_46' ,                   [-6, 5 , 46] ,         5,            '[Exp]/ROIS/'; ...  
       } ;

   
   
   
   
   
   
   
   
   
%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..','..');
%DEVSTOP

%[DEVmcRootAssign]

addpath(fullfile(mcRoot,'matlabScripts'))
addpath(fullfile(mcRoot,'ExtractionScripts','BuildROI'))
addpath(fullfile(mcRoot,'spm8'))
   
   

BuildSphere_central
