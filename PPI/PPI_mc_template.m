%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%~~~~~~~~~~~~~~~~~~~~~~~~~~   Basic   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your subject folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/net/data4/MAS/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path where your logfiles will be stored
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LogTemplate = '[Exp]/Logs';

ModelTemplate = '[Exp]/FirstLevel/[Subject]/[Model]/SPM.mat';
Model = 'HARIRI';

OutputTemplate = '[Exp]/PPI/[Model]/[ROI].csv';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects to process
%%% The format is 'subjectfolder',subject number in masterfile,[runs to include]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjDir = {
      '5001/Tx1',50011,[1 2];
      '5028/Tx1',50281,[2];
      '5029/Tx1',50291,[1 2];
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ContrastNum is the index of the contrast you're using to identify
%%% your active voxels.  If you're planning on extracting from all voxels
%%% in your ROI (unthresholded), then this number can be any valid contrast
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ContrastNum = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ContrastThesh is the p-value threshold to use on ContrastNum to 
%%% identify super-threshold voxels for the extraction.  If you'd like to 
%%% include all voxels in your ROI (unthresholded) this should be set to 1
%%% Similarly, ContrastExtent is a minimum cluster size extent threshold.
%%% When extracting unthresholded data, this should be 0.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ContrastThresh = 1;
ContrastExtent = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PPIType is the type of the analysis to perform. Valid settings are:
%%%	'standard'	this is a standard SPM PPI (contrast of conditions)
%%%	'gPPI'		this is a generalized PPI (each condition seperate)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PPIType = 'standard';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% ROIs is a list of different ROIs that you would like to extract from
%%% and create PPI regressors.  Each one will be saved in a different 
%%% CSV file in OutputTemplate based on the first field below. The second
%%% field is either the path to an ROI image file (for images) or coordinates
%%% of the center of your ROI (for sphere or cluster). The next field is
%%% blank for images or clusters, but should be the radius of your ROI for
%%% spheres. The final field defines the contrast of conditions for your
%%% PPI (in standard mode) or should be blank for generalized mode.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ROIs = {
	'ROI1',['/path/to/ROI.img'],[],[0 1 -1];
	'ROI2',[-2 20 8],[5],[0 1 -1];
}


%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~ Advanced ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EOIAdjust is an F-contrast index in your model that you would like to
%%% use to adjust the extracted data.  What this means is that contributions
%%% to your signal from effects that are NOT included in the chosen F-contrast
%%% will be removed from your signal.  Set to 0 to skip adjustment.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EOIAdjust = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SPM Default Values for First Level analysis
%%% this is set up as a cell array where each row corresponds to a default
%%% value in SPM.  The first element is a string with the name of the
%%% default field (without defaults. at the beginning).  You can view
%%% spm_defaults.m for a list of possible fields to set.  The second
%%% element is the value you want to set for that default.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The main default that impacts first level analysis is the implicit 
%%% masking threshold. The default is 0.8 which means that voxels that have
%%% a value of less than 80% of the grand mean will be masked out of the
%%% analysis.  This default value can be problematic in some susceptibility
%%% prone areas like OFC.  A more liberal value like 0.5 can help to keep
%%% these regions in the analysis.  If you set this value very low, you'll
%%% want to use an explicit mask to exclude non-brain regions from
%%% analysis.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
spmdefaults = {
    'mask.thresh'   0.8;
};

global mcRoot;

%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..');
%DEVSTOP

addpath(fullfile(mcRoot,'matlabScripts'))
addpath(fullfile(mcRoot,'PPI'))
addpath(fullfile(mcRoot,'SPM','SPM8','spm8_with_R4667'))

PPI_mc_central