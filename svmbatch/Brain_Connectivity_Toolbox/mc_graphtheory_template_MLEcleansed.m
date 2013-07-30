%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%        Graph Theory Measurements of connectivity matrix              %
%                         Template Script                              %
%                                                                      %
% Yu Fang 2013/01                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Experiment Directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Exp = '/net/data4/ADHD/';

Pxe = '/freewill/data/ADHD/UnivariateConnectomics/VoxelWise_CensorZ_ConnectomeCleaning/';
% Pxe = '/net/data4/ADHD/UnivariateConnectomics/Results/Cleansing_MLE_1166_Censor_Z/';
% Pxe = '/net/data4/ADHD/UnivariateConnectomics/Results/1166_CensorZ_ConnectomeCleaning_Age/';

SubjWiseTemp = '[Pxe]/SubjectWise/[Subject].mat';

SubjWiseField = 'CorrectedR';

SubjNameLength = 7; % To avoid the akward caused by subject

nFlat = 500434066;

% ConCatTemp = '[Pxe]/Results_Cleansed_Part[m].mat';
% ConCatField = 'Cleansed_Part[m]';
ConCatTemp = '[Pxe]/NoAgeModel/CorrectedR.mat';
ConCatField = 'Corrected_R';   % the subfield name in the file that saves the corr 


PartNum = 1;  % Results_Cleansed_Part1 ~ Results_Cleansed_Part(PartNum)

% ResultTemp = '[Pxe]/Results.mat';
ResultTemp = '[Pxe]/FixedFX.mat';
% ResultTemp = '[Exp]/UnivariateConnectomics/Results/Cleansing_MLE_1166_Censor_Z/Results.mat';

SubFolder = '0729_voxel_eigenvector';



     
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Path where the mni coordinates of each node are located
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NetworkParameter = '[Exp]/FirstLevel/SiteCatLinks/1018959/1166rois_Censor/1166rois_Censor_parameters.mat';
NetworkParameter = '/freewill/data/ADHD/FirstLevel/SiteLinks/1018959/4mmVoxel_Censor/4mmVoxel_Censor_parameters.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subject type order
% 0 -- alphabetically, control group name in the front, like 'H' and 'O'
% 1 -- alphabetically, disease group name in the front, like 'A' and 'H'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
covtype = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Do you want to use partial correlation instead of correlation?
%%%   1 --- yes, 0 --- no
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.partial = 0;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Required Network Options:
%%% network.directed:    0 - undirected matrix; 1 - directed matrix
%%% network.weighted:    0 - unweighted matrix; 1 - weighted matrix
%%% network.datatype: 
%%%                     'r' - thresholding r-value matrix to binary/weighted matrix by p-value (e.g. results from SOM)
%%%                     'b' - threshloding beta-value matrix to binary/weighted matrix by t-score (e.g. results from cPPI)
%%% network.ztransform:  If network.datatype is set to 'r', we have the option to do an r to z transform
%%%                      0  - Don't do z transform    1 - Do z transform
%%% network.ztransdone:  Although you want to do z transform, have you already done this?
%%%                      0  - No                      1 - Yes
%%% network.loc(only for cPPI):  0  - Average over upper and lower triangulars; 1 - upper triangular; 2 - lower triangular  
%%% network.positive(when using weighted network):       0 - Absolute value;   1 - Only positive value
%%% 
%%% network.local:  1 - Include local measurement; 0 - Do not include local measurement
%%%
%%% network.iter: rewiring parameter when generating random graph (each
%%%               edge is rewired approximatel network.iter times)
%%% network.netinclude:  Any network number in the array will be treated separately and 
%%%                      for now the number is in the range of 0 to 12. We are usually interested
%%%                      in network 1:7. If set to -1, than treat the whole brain(include all 13 networks).
%%% network.rthresh: The single r threshold to create the adjacency matrix when single r threhsold method is used. 
%%% network.zthresh: The single z threshold corresponding to the r threshold
%%%
%%% network.perm:  1 -- To do permutation test; 0 -- not to do permutation test;
%%% network.ttest: 1 -- To do 2 sample t-test;  0 -- not to do 2 sample t-test;
%%%
%%% network.subjwise:    1 -- The input data would be subject wise files;
%%%                      0 -- The input data would be concatenated file/s;
%%% network.cleansed:    1 -- The input data would be cleansed;
%%%                      0 -- The input data would be non cleansed;
%%% network.uptri:       1 -- The loaded corr would be 1 x n*(n-1)/2 upper triangular vector;
%%%                      0 -- The loaded corr would be n x n matrix
%%% network.int
%%% network.amplify:     1 -- The input data value is interger (amplified by network.amplify) which need to be convert back to (-1,1)
%%%                      0 -- The input data value is original (-1,1) values.
%%% network.voxel:       1 -- Use matfile to partially load files if file is very big
%%%                      0 -- Not use matfile
%%% network.voxelzscore: 1 -- Convert voxelwise measure values to normalized zscore for each subject: (value-mean())/std()
%%%                      0 -- Use original voxelwise measure values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.directed   = 0;
network.weighted   = 0;

network.ztransform = 1;
network.ztransdone = 0; 

network.loc        = 0;
network.positive   = 1;

network.local = 0;
network.voxel = 0;

network.iter       = 5;
network.netinclude = -1; 

network.rthresh  = 0.25;
network.zthresh  = 0.5.*log((1+network.rthresh)./(1-network.rthresh));

network.perm     = 1;
network.ttest    = 1;

network.subjwise = 1;
network.cleansed = 1;
network.uptri    = 1;

network.int      = 1;
network.amplify  = 10000;

network.voxelzscore=1;

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Subject List
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~network.cleansed
    
    SubjDir = {      
    
%     '1018959'
    '0015006'
    '0015007'
    '0015013'
    '0015018'
    '0015026'
    '0015027'
    '0015028'
    '0015031'
    '0015032'
    '0015033'
    '0015036'
    '0015039'
    '0015041'
    '0015043'
    '0015045'
    '0015048'
    '0015050'
    '0015052'
    '0015053'
    '0015054'
    '0015057'
    '0015058'
    '0015061'
    '0015062'
    
    };
 
end

%% Permutation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Permutation Settings (Will only be effective if ShadingEnable == 1)                                                                      %
%                                                                                             %
%       nRep            -       Number of permutations to perform.                            %
%       permSave        -       Where should we save the permutation results?                 %
%       permDone        -       If you have previously run this script and have permutations, %
%                               set this to 1, and it will load up your previous result based %
%                               value in permSave                                             %
%       permCores       -       How many CPU cores to use for permutations. We will try,      %
%                               but it often fails with big data, in which case we will       %
%                               fall back to just one core. 
%       permlevel       -       significant level of permutation test
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if network.perm
    nRep     = 10000;
    PermOutput = '[Exp]/GraphTheory/[SubFolder]/permutation/[ThreshValue]/';
    permSave = 'ADHD_10000perm.mat';
    permDone = 0;
    permCores = 1;
    permlevel = 0.005;
end
%% t statistics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  siglevel  ---        significant level of  t-test                        
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if network.ttest
    siglevel  = 0.005;
end


%%%%%%%%%%%%%%%%%%%%%%
% Average over sparsities
% 1 -- Do; 2 -- Don't
%%%%%%%%%%%%%%%%%%%%%%
% SparAve=1;


%% Output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name and path for your output file, 1 is for global measures, 2 is for
% local measures (leave off the .csv)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

OutputPathTemplate1 = '[Exp]/GraphTheory/[SubFolder]/MotionScrubbed/Measure_global';
OutputPathTemplate2 = '[Exp]/GraphTheory/[SubFolder]/MotionScrubbed/Measure_local';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  Save the measurement results into a mat file (For safe)  
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.save = '[Exp]/GraphTheory/[SubFolder]/MotionScrubbed/CombinedOutput.mat';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  Save the first level voxel-wise measurement results
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
network.flsave = '[Exp]/GraphTheory/[SubFolder]/FirstLevel/[Netname]/[Metricname]_[Subjectfl].mat';
network.typesave = '[Exp]/GraphTheory/[SubFolder]/FirstLevel/type.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  Plot options
%%%    network.plot         1  -- To do the plot; 0 -- not to do the plot
%%%    network.plotNet      -1 -- Whole brain; any combination of 1:13 -- sub networks
%%%    network.plotMetric   any combination from:
%%%       Metrics   = {'Clustering','CharPathLength','Transitivity',
%%%                    'GlobEfficiency','Modularity','Assortativity',
%%%                    'Betweenness','Entropy','GlobalDegree','Density'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
network.plot = 1;
network.plotNet = [3,4,6,7];
network.plotMetric = {'CharPathLength','Betweenness','Entropy','GlobalDegree'};


%% Sparsity, Measures, Stream, AUC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Sparsity threshold for the P-value / t-score correlation matrix (to create 
%%% binary adjacency matrix)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% network.sparsity = [0.1,0.15,0.2,0.25,0.3,0.35];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The measurements you want to select
%%% ( Detailed explanation of the measurements is in mc_graphtheory_measures.m)
%%% 
%%%         A = assortativity
%%%         B = betweenness [global/local]
%%%         C = clustering coefficient [global/local]
%%%         D = density
%%%         E = degree [global/local]
%%%         F = efficiency [global/local]
%%%         M = modularity
%%%         N = eccentricity
%%%         P = characteristic path length
%%%         S = small-worldness
%%%         T = transitivity
%%%         V = eigenvector centrality
%%%         Y = entropy
%%%
%%%         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% network.measures = 'ABCDEFMPTY';
network.measures = 'V';
% network.measures = 'BCEF';

% network.measures = 'CDEPS';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The stream you are at
%%%          m   =   measurement
%%%          t   =   threshold selection
%%%
%%%         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.stream = 'm';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The metrics you want to draw and calculate the AUC
%%%
%%%         A = assortativity
%%%       
%%%         C = clustering coefficient
%%%         
%%%         E = degree
%%%         G = global efficiency
%%%       
%%%         M = modularity
%%%         P = characteristic path length
%%%         S = small-worldness
%%%         T = transitivity
%%%
%%% If you don't want to do this for any metric, set network.AUC to ''.
%%%
%%% network.aucSave: mat files that you save auc results to (for safe)
%%%
%%% AUCTemplate: csv files that you save auc results to
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.AUC = '';

%% 
%%%%%%%%%%%%%%%%%%%
% set the path
%%%%%%%%%%%%%%%%%%%
mcRoot = '~/users/yfang/MethodsCore/';
addpath(fullfile(mcRoot,'svmbatch','Brain_Connectivity_Toolbox/'));
addpath(fullfile(mcRoot,'matlabScripts')) % if report error, add 'genpath' before fullfile
addpath(genpath(fullfile(mcRoot,'svmbatch')))
addpath(genpath(fullfile(mcRoot,'svmbatch','matlab_Scripts')))
addpath(fullfile(mcRoot,'spm8Batch'))
addpath(fullfile(mcRoot,'SPM','SPM8','spm8Legacy'))

%%
% mc_graphtheory_central_MLEcleansed








