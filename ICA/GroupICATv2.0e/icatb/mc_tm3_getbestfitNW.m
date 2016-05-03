function mc_tm3_getbestfitNW(outpath,networkPath)
clear templateFiles; clear dispParameters;

% Specify ICA parameter file
param_file = dir([outpath,'/*ica_parameter_info.mat']);
param_file = fullfile(outpath,param_file.name);

% Options for selectedStr are:
% 1.'Same set of spatial templates for all data-sets'
% 2. 'Different set of spatial templates for sessions'
% 3. 'Different set of spatial templates for subjects and sessions'
selectedStr = 'Same set of spatial templates for all data-sets';

% Count is the current data-set number
% Enter template files for subject 1 sessions followed by subject 2
% sessions, etc.

%%%% Note: Number of spatial templates must be the same between data-sets

%% find all network templates in NWTemplatePath, load templates:
% networks: the struc of all the networks, each struct contains name, data,
% time, etc
% network: the read-in image (the volumn) of all the network templates
hdrpath = [networkPath '/*hdr*'];
niipath = [networkPath '/*nii*'];
networks = [dir(hdrpath); dir(niipath)];

nNW = length(networks);

network = cell(nNW);
for iNW = 1:nNW
    networkName{iNW} = fullfile (networkPath, networks(iNW).name);
end

%% do template matching for each template
for i = 1:nNW
    
templateFiles(1).name = str2mat(networkName{i});                        
                   

                        
%%%%%%% Specify Display parameters %%%%%%%%%

% Options for image values are
% 1 means positive and negative
% 2 means positive
% 3 means Absolute
% 4 means Negative
dispParameters.imagevalues = 2; 

% Anatomical plane options are axial, sagital, coronal
dispParameters.anatomicalplane = 'axial'; 

% slices in mm (vector of real numbers)
dispParameters.slicerange = [0:4:72]; 

% Number of images per figure
% Options are 1, 4, 9, 16, 25
dispParameters.imagesperfigure = 4;

% Convert to z scores:
% 1 means convert, 0 means don't convert to z-scores
dispParameters.convertToZ = 1;     

% Z Threshold: 
dispParameters.thresholdvalue = 1; 

% Anatomical file for overlaying component images:
% Image used from icatb/icatb_templates
dispParameters.structFile = which('nsingle_subj_T1_2_2_5.nii'); 

%%%%%%%% End for specifying display parameters %%%%%%%%%%

% Call spatial sorting function
icatb_spatialSorting(param_file, selectedStr, templateFiles, dispParameters);
end