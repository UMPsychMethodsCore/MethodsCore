
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Experiment Directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Exp='/net/data4/MAS/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  JobList; InputDirectory and OutputDir are templates.
%%           OutputDir template can create nonexistant directories
%%
%%  Variables you can use in your template are:
%%       Exp = path to your experiment directory
%%  Example:
%%  InputDirectory = '[Exp]/ROIS/'
%%  OutputDir      = '[Exp]/ROIS/'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


JobList = {...


%%%%%Input Directory  %%%%%         %%%%%%%%% OutputDir%%%%%%%%%%     %%%%%%%%%%%%Name of ROI to be converted (with .img)'%%%%%%%  

%      '[Exp]/ROIS/',                       '[Exp]/ROIS/',                             'aal_Occipital_Inf_L.img'; ... 
      '[Exp]/ROIS/',                       '[Exp]/ROIS/',                             'AnteriorCingulate_from_DFW.img'; ... 
%     '[Exp]/ROIS/MaskForXtract/',         '[Exp]/ROIS/MaskForXtract/',              'MedialFrontalGyrus_from_spmT_0001.img'; ...
%     '[Exp]/ROIS/',                       '[Exp]/ROIS/',                            'OFC_conjunction.img'; ...
       
       } ;

   

%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..','..')
%DEVSTOP

%[DEVmcRootAssign]

addpath(fullfile(mcRoot,'matlabScripts'))
addpath(fullfile(mcRoot,'ExtractionScripts','BuildROI'))
addpath(fullfile(mcRoot,'SPM','SPM8','spm8Legacy'))


Img2Mat_central   
     