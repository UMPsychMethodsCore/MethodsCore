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


Pxe = '/net/data4/ADHD/UnivariateConnectomics/Results/Cleansing_MLE_1166_Censor_Z/';

CleansedTemp = '[Pxe]/Results_Cleansed_Part[m].mat';

ResultTemp = '[Pxe]/Results.mat';
     
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Path where the mni coordinates of each node are located
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NetworkParameter = '[Exp]/FirstLevel/SiteCatLinks/1018959/1166rois_Censor/1166rois_Censor_parameters.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subject type order
% 0 -- alphabetically, control group name in the front
% 1 -- alphabetically, disease group name in the front
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.directed   = 0;
network.weighted   = 0;
network.datatype   = 'r';
network.ztransform = 1;
network.loc        = 0;
network.positive   = 1;

network.local = 0;

network.iter       = 5;
network.netinclude = [1:7]; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Nodes of interest (Please input the coordinates that are contained in the
% parameters file)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NodeList = [
    -18 0 72;
     6 12 72;
    -6 12 72;
    ];  

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
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nRep     = 10;
PermOutput = '[Exp]/GraphTheory/0619/';
permSave = 'ADHD_GT.mat';  
permDone = 0;
permCores = 2;

%% Statistics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  siglevel  ---        significant level of  t-test                        
%  permlevel ---        significant level of permutation test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
siglevel  = 0.05;
permlevel = 0.05;

%%%%%%%%%%%%%%%%%%%%%%
% Average over sparsities
% 1 -- Do; 2 -- Don't
%%%%%%%%%%%%%%%%%%%%%%
SparAve=1;


%% Output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name and path for your output file, 1 is for global measures, 2 is for
% local measures (leave off the .csv)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

OutputPathTemplate1 = '[Exp]/GraphTheory/0619/MotionScrubbed/Measure_global';
OutputPathTemplate2 = '[Exp]/GraphTheory/0619/MotionScrubbed/Measure_local';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  Save the measurement results into a mat file (For safe)  
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.save = '[Exp]/GraphTheory/0619/MotionScrubbed/CombinedOutput.mat';

%% Sparsity, Measures, Stream, AUC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Sparsity threshold for the P-value / t-score correlation matrix (to create 
%%% binary adjacency matrix)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.sparsity = [0.1,0.15,0.2,0.25,0.3,0.35];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The measurements you want to select
%%% ( Detailed explanation of the measurements is in mc_graphtheory_measures.m)
%%% 
%%%         A = assortativity
%%%         B = betweenness
%%%         C = clustering coefficient
%%%         D = density
%%%         E = degree
%%%         G = global efficiency
%%%         L = local efficiency
%%%         M = modularity
%%%         P = characteristic path length
%%%         S = small-worldness
%%%         T = transitivity
%%%
%%%         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.measures = 'ACGMPT';

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
mc_graphtheory_central_MLEcleansed








