%% Use full path for directories and files wherever needed

%% Output directory to place results 
outputDir = '/na1/batch_results';

%% ICA parameter file 
ica_param_file = '/na1/rest_hcp_ica_parameter_info.mat';

%% Features. Options avaialble are spatial maps, timecourses spectra, fnc correlations
features = {'spatial maps', 'timecourses spectra', 'fnc correlations'};

%% Cell array of dimensions number of covariates by 4. The 4 columns are as follows:
% a. name - Covariate name
% b. type - Covariate type continuous or categorical
% c. value - You could enter the vector by hand or use Ascii file for continuous covariates and text file with new line delimiter for
% categorical covariates.
% d. Transformation function - Enter transformation function to be applied
% on the continuous covariate 
covariates = {'Age', 'continuous', '/na1/demo/age_50.txt', 'log';
             'Gender', 'categorical', '/na1/demo/gender_50.txt', '';
             'motion_avg_trans', 'continuous', '/na1/demo/motion_avg_trans_50.txt', 'log';
             'motion_avg_rot', 'continuous', '/na1/demo/motion_avg_rot_50.txt', 'log';
             'spatialnorm_rho_S', 'continuous', '/na1/demo/spatialnorm_rho_S_50.txt', 'atanh'};             

%% Pairwise interactions list (No. of interactions by 2). Indices are
% relative w.r.t to covariates. If you don't want to include interactions
% leave it as empty or comment the variable
interactions = [1, 2];

%% Cell array of dimensions number of network names by 2. Don't duplicate components in different
% network names
comp_network_names = {'BG', 21;                    % Basal ganglia 21st component
                      'AUD', 17;                   % Auditory 17th component
                      'SM', [7 23 24 29 38 56];    % Sensorimotor comps
                      'VIS', [39 46 48 59 64 67];  % Visual comps
                      'DMN', [25 50 53 68];        % DMN comps
                      'ATTN', [34 52 55 60 71 72]; % ATTN Comps
                      'FRONT', [20 42 47 49]};     % Frontal comps

%% Enter no. of principal components of length equal to no. of features selected which will be used to determine the significant covariates. The dimension reduction will be done in the feature 
% dimension (voxels, spectra, etc). This number should be less than the total no of components of all networks.
numOfPCs = [10, 10, 10];                  
                                           
%% Significance threshold
p_threshold = 0.01;

%% TR of the experiment
TR = 2;
