%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Experiment Directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Exp='/net/data4/MAS/';  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% List the spherical ROIs that you want to build
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

JobList = {...


%%%%%'Name of ROI to be created',  %%%% [x ,  y ,  z ] %%%,   radius,  %%%%%   'OutputDir/' ;

       'test_15_17_1' ,                  [15, 17 , 1] ,          5,            '[*Exp]/ROIS/'; ... 
       'test_99_99_99' ,                 [5, 5 , 5] ,            5,            '[*Exp]/ROIS/'; ...        
       
      
       } ;

   
   
   
   
   
   
   
   
   
   
   
addpath /net/dysthymia/slab/users/sripada/repos/matlabScripts/MethodsCore/ExtractionScripts/BuildROI/
BuildSphere_central
