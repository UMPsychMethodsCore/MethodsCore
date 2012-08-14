

 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Experiment Directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      

Exp='/net/data4/OXT/';  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Output file for analysis (leave off the .csv)
%%
%%  Variables you can use in your template are:
%%       Exp = path to your experiment directory
%%  Example:
%%  OutputPathTemplate = '[Exp]/Output/Level2_Extractions/OXT_mpfc_test';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

OuputPathTemplate='[Exp]/Output/Level2_Extractions/OXT_mpfc_test';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Folder where SPM.mat is located and location for ROI file
%%
%%  Variables you can use in your template are:
%%       Exp = path to your experiment directory
%%  Examples:
%%  ExtracttionJobs =
%%     {'[Exp]/RANFX_spm8/GRNoFilter/Ramy/PBO_HC/','[Exp]/ROIS/mPFC_n10_42_24_roi.mat'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ExtractionJobs = {...

%%%%% Go to this folder to get the level 2 SPM.mat %%%%%%      %%%%%%%% and extract using this ROI %%%%%%%%%%%%%%                         
    '[Exp]/RANFX_spm8/GRNoFilter/Ramy/PBO_HC/',                '[Exp]/ROIS/mPFC_n10_42_24_roi.mat' ; ...
    '[Exp]/RANFX_spm8/GRNoFilter/Ramy/OXT_HC/',                '[Exp]/ROIS/mPFC_n10_42_24_roi.mat' ; ...
    '[Exp]/RANFX_spm8/GRNoFilter/Lamy/PBO_HC/',                '[Exp]/ROIS/mPFC_n10_42_24_roi.mat' ; ...
    '[Exp]/RANFX_spm8/GRNoFilter/Lamy/OXT_HC/',                '[Exp]/ROIS/mPFC_n10_42_24_roi.mat' ; ...
    

 } ;
    
    
%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..','..');
%DEVSTOP

%[DEVmcRootAssign]

addpath(fullfile(mcRoot,'matlabScripts'))
addpath(fullfile(mcRoot,'ExtractionScripts','ExtractROI'))
addpath(fullfile(mcRoot,'SPM','SPM8','spm8Legacy'))
    
    
ExtractROI_central