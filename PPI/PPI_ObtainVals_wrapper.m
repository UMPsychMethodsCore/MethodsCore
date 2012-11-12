%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Stable paramters %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%contrastNum = the number of the contrast you're using to identify
%your active voxels
%NOTE: If you use 1 as threshold below, this number is irrelevant
contrastNum = 1;

%Main Experiment Folder
Exp = '/data/BIEL/ACNP2010/';

%Input path for First Level models
%Path will be /Exp/InputLevel1/subjDir/InputLevel2/InputLevel3/
InputLevel1 = 'FirstLevel/'; 
InputLevel2 = 'hariri_mvmt/';
InputLevel3 = '';

%Output path for CSV file with P/Y/PPI vectors
%Path will be /Exp/OutputLevel1/OutputLevel2/OutputLevel3/PPIJob_PPI.csv
OutputLevel1 = 'PPI/';
OutputLevel2 = 'HARIRI/';
OutputLevel3 = '';

%Number of runs in the first level model
Num_run = 1;

%P-value threshold to use for identifying active voxels to include
%Use 1 for unthresholded results (i.e. it will include the same
%voxels for all subjects
threshold = 1;

%Cluster extent minimum (used in conjunction with threshold to
%identify active voxels
%Set to 0 if using unthresholded data
extent = 0;

%Type of VOI to use
%This can be either 'sphere' or 'image'
typeVOI = 'image';

%This depends on what your typeVOI is
%'image': leave spec blank (just empty brackets [])
%'sphere': set spec to the radius of the sphere to use
spec = [];

%If you have an Effects of Interest F contrast in your model that
%you want to adjust for (i.e. exclude contributions to your signal
%from effects that are NOT in your modelled F-contrast) set this to
%the number of the contrast
%If you don't want to adjust the data or don't have an F-contrast,
%set it to 0
adjust =0;

%PPIJobs are the different extractions that you will be doing
% If you're using 'sphere'
%%% {VOI file name, [x, y, z], conditions, weights}
% if you're using 'image'
%%% {VOI file name, ['/path/to/mask.img'], conditions, weights}
PPIJobs = {
    'ACNP_FvH_Left',['/path/to/mask.img'],[1 1 1],[0 1 -1];  
    'ACNP_FvH_Right',['/path/to/mask.img'],[1 1 1],[0 1 -1];
          };

%List of subject directories
subjDir = {
'H_080502tf/';
'H_080506jw/';
'H_080516sp/';
'H_080519pb/';
'P_080613sm/';
'H_080618rb/';   
          };  

%Set to 1 to extract standard PPI regressors 
%Set to 0 to extract separate Psych and Interaction regressors
%for each condition in your first level model (PMP)
PPItype = 1


addpath /net/dysthymia/matlabScripts
PPI_ObtainVals_central