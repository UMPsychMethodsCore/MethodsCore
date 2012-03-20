
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Experiment Directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Exp='/net/data4/MAS/';  





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% List the ROIs that you want to be converted
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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
addpath(fullfile(mcRoot,'spm8'))


Img2Mat_central   
     