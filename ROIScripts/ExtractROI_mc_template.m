%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%~~~~~~~~~~~~~~~~~~~~~~~~~~   Basic   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Experiment Directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp='/net/data4/OXT/';  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path where your logfiles will be stored
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LogTemplate = '[Exp]/Logs';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Output file for analysis (leave off the .csv)
%%%
%%%  Variables you can use in your template are:
%%%       Exp = path to your experiment directory
%%%  Example:
%%%  OutputPathTemplate = '[Exp]/Output/Level2_Extractions/OXT_mpfc_test';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputPathTemplate='[Exp]/Output/Level2_Extractions/OXT_mpfc_test';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Folder where SPM.mat is located and location for ROI file
%%%  Format depends on if you are extracting a sphere or image:
%%%  'Path with SPM.mat to extract from'   [x,y,z,radius];
%%%  'Path with SPM.mat to extract from'   'Path and filename of ROI image';
%%%
%%%  Variables you can use in your path templates are:
%%%       Exp = path to your experiment directory
%%% Examples:
%%%  ExtracttionJobs =
%%%     {'[Exp]/RANFX/PBO_HC/','[Exp]/ROIS/aal_Amygdala_R.img'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ExtractionJobs = {...
     '[Exp]/RANFX_spm8/GRNoFilter/Ramy/OXT_HC/',                 [-10, 42, 24, 5] ;
     '[Exp]/RANFX_spm8/GRNoFilter/Ramy/OXT_HC/',                '[Exp]/ROIS/aal_Cingulum_Ant_L.img' ;
     '[Exp]/RANFX_spm8/GRNoFilter/Ramy/OXT_SP/',                 [-10, 42, 24, 5] ;
     '[Exp]/RANFX_spm8/GRNoFilter/Ramy/OXT_SP/',                '[Exp]/ROIS/aal_Cingulum_Ant_L.img' ;
 } ;


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~ Advanced ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% choose the type of summary function
%%% Options are:
%%% 'mean'   - takes the average activation of the voxels in the ROI
%%% 'eigen1' - takes the first principle component of the activation within the ROI. This is the method used in SPM8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SummaryFunction = 'eigen1';

global mcRoot
%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..');
%DEVSTOP

%[DEVmcRootAssign]
addpath(fullfile(mcRoot,'Utilities','marsbar','marsbar-0.43'));
addpath(fullfile(mcRoot,'matlabScripts'));
addpath(fullfile(mcRoot,'SPM','SPM8','spm8_with_R4667'));
    
    
ExtractROI_mc_central