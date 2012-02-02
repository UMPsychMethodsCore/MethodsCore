

 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Experiment Directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      

Exp='/net/data4/OXT/';  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Name and path for your output file (leave off the .csv)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

OuputPathTemplate='[Exp]/Output/Level2_Extractions/OXT_mpfc_test';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Set up the extraction jobs you would like done
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ExtractionJobs = {...

%%%%% Go to this folder to get the level 2 SPM.mat %%%%%%      %%%%%%%% and extract using this ROI %%%%%%%%%%%%%%                         
    '[Exp]/RANFX_spm8/GRNoFilter/Ramy/PBO_HC/',                '[Exp]/ROIS/mPFC_n10_42_24_roi.mat' ; ...
    '[Exp]/RANFX_spm8/GRNoFilter/Ramy/OXT_HC/',                '[Exp]/ROIS/mPFC_n10_42_24_roi.mat' ; ...
    '[Exp]/RANFX_spm8/GRNoFilter/Lamy/PBO_HC/',                '[Exp]/ROIS/mPFC_n10_42_24_roi.mat' ; ...
    '[Exp]/RANFX_spm8/GRNoFilter/Lamy/OXT_HC/',                '[Exp]/ROIS/mPFC_n10_42_24_roi.mat' ; ...
    

 } ;
    
    
    
    
addpath /net/dysthymia/slab/users/sripada/repos/matlabScripts/MethodsCore/ExtractionScripts/ExtractROI/
ExtractROI_central