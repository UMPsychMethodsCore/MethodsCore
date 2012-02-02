
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Experiment Directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Exp='/net/data4/MAS/';  





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% List the ROIs that you want to be converted
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


JobList = {...


%%%%%Input Directory  %%%%%         %%%%%%%%% OutputDir%%%%%%%%%%     %%%%%%%%%%%%Name of ROI to be converted (with .img)'%%%%%%%  

      '[Exp]/ROIS/',                       '[Exp]/ROIS/',                             'PCC.img'; ... 
%     '[Exp]/ROIS/MaskForXtract/',         '[Exp]/ROIS/MaskForXtract/',              'MedialFrontalGyrus_from_spmT_0001.img'; ...
%     '[Exp]/ROIS/',                       '[Exp]/ROIS/',                            'OFC_conjunction.img'; ...
       
       } ;

   
   
   
   
   
   
   
   
   
   
   
   
addpath /net/dysthymia/slab/users/sripada/repos/matlabScripts/MethodsCore/ExtractionScripts/BuildROI/

Img2Mat_central   
     