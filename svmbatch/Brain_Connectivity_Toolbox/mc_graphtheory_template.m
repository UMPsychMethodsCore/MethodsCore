%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%        Graph Theory Measurements of connectivity matrix              %
%                         Template Script                              %
%                                                                      %
% Yu Fang 2013/01                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Experiment Directory: Your main analysis folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Exp = '/net/data4/MAS/';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input File
%
% The script expects subject-wise input files. 
% Each subject-wise file is a struct, and supposed to have 1 or 2 
% subfields, each of them contains an nROIxnROI matrix. One subfield serves 
% as thresholding matrix, for each pair of node, only when % its value in 
% thresholding matrix higher than the threshold will it be considered as a 
% connection. The other subfield serves as a edge matrix, which provides 
% the actual value of the connections, could be either binary or weighted. 
% ThreshField and EdgeField are not necessary to be different. 
% For example, for pearson's r correlation, we suggest to use r matrix as
% both edge and thresholding matrices; for cPPI, we suggest to use t-score 
% matrix as thresholding matrix and beta matrix as edge matrix.
% thresholding
%
% SubjWiseTemp   - Subject-wise input file
% ThreshField    - Subfield with thresholding matrix
% EdgeField      - Subfield with edge matrix
% SubjNameLength - Length of subject name (supposed to be consistent over
%                  all subjects
% MDF.path       - Path of MasterDataFile, which provides subject list and
%                  type list
% MDF.Subject    - String naming column of Subject names
% MDF.Type       - String naming column of Subject types
% MDF.include    - String naming column of logicals in MDF for subsetting
%                  ('TRUE' or 'FALSE')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjWiseTemp = '[Exp]/FirstLevel/[Subject]/TaskGrid_tcb_2run_0f0b_DVARS_mdq_5csfwm_corrected/TaskGrid_tcb_2run_0f0b_DVARS_mdq_5csfwm_corrected_corr.mat';

ThreshField = 'rMatrix';
EdgeField   = 'rMatrix';

MDF.path    = '[Exp]/Scripts/MSIT/MDF/MDF_LSS_GT.csv'; 
MDF.Subject = 'Subject';
MDF.Type    = 'Type';
MDF.include = 'Include.Overall';   
SubjNameLength = 4; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mni coordinates used to separate sub-networks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NetworkParameter = '[Exp]/FirstLevel/5001/Tx1/TaskGrid_tcb_2run_0f0b_DVARS_mdq_5csfwm/TaskGrid_tcb_2run_0f0b_DVARS_mdq_5csfwm_parameters.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subject type order
% 0 -- alphabetically, control group name in the front, like 'H' and 'O'
% 1 -- alphabetically, experiment group name in the front, like 'A' and 'H'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.covtype = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Graph Type
% network.directed:    1 - directed matrix; 0 - undirected matrix; 
% network.weighted:    1 - weighted matrix; 0 - unweighted matrix; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.directed   = 0;
network.weighted   = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculation Options
%
% Partial and Z-transform aims at the case that input matrix is pearson's 
% r correlation matrix. In other cases, set them to 0.
%
% network.amplify:     Intergers > 1 - The input data value is amplified by
%                                      network.amplify and need to be
%                                      converted back to (-1,1);
%                      1 - The input data value is already in the range of
%                          (-1,1).                   
% network.partial:     1 - use partial correlation; 
%                      0 - use normal correlation.
% network.ztransform:  1 - Do z transform;   
%                      0 - Don't do z transform.   
% network.ztransdone:  1 - Z transform already done; 
%                      0 - Z transform not done yet.
% network.positive:    1 - Only use positive value; 
%                      2 - Only use negative value;
%                      0 - Use absolute value. 
% network.voxelzscore: 1 - Convert voxelwise measure values to normalized 
%                          zscore for each subject: (value-mean())/std();
%                      0 - Use original voxelwise measure values.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.amplify  = 1;

network.partial    = 0;

network.ztransform = 1;
network.ztransdone = 0; 

network.positive   = 1;

network.voxelzscore=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Thresholding
% 
% network.thresh: The threshold/s to create adjacency matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.thresh  = 0.25;
if (network.ztransform==1)
network.thresh  = 0.5.*log((1+network.thresh)./(1-network.thresh));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Network Selection
% 
% network.netinclude: -1 - Whole Brain;
%                     Array of intergers ranging from 1 to 13 - SubNetworks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.netinclude = -1; 
% network.netinclude = 1:7; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% t-test settings
%
% network.ttest: 1 - To do t-test for global measures;  
%                0 - Not to do t-test for global measures.
% siglevel:      Significant level of  t-test                        
% ttype:         'paired' - paired t-test
%                '2-sample' - 2 sample t-test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
network.ttest    = 1;
if network.ttest
    siglevel  = 0.005;
    ttype     = 'paired';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Permutation Settings 
%
% network.perm:  1 - To do permutation test; 
%                0 - Not to do permutation test.                                                                                        %
% nRep:          Number of permutations to perform.                            
% permSave:      Where should we save the permutation results?                 
% permDone:      1 - Permutation already done;
%                0 - Permutation not done.                          
% permCores:     How many CPU cores to use for permutations. We will try,      
%                but it often fails with big data, in which case we will       
%                fall back to just one core. 
% permlevel:     significant level of permutation test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
network.perm     = 1;

if network.perm
    nRep     = 10;
    PermOutput = '[Exp]/GraphTheory/[SubFolder]/permutation/[ThreshValue]/';
    permSave = 'MAS_tcb_10perm.mat';
    permDone = 0;
    permCores = 1;
    permlevel = 0.005;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output Settings
% 
% SubFolder:   The major folder that contains all of the outputs
% 
% Name and path for output csv files, 1 is for global measures, 2 is for
% local measures (leave off the .csv), and t-test p values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubFolder = 'Grid_tcb_WholeBrain';
network.save = '[Exp]/GraphTheory/[SubFolder]/MotionScrubbed/CombinedOutput.mat';

OutputPathTemplate = '[Exp]/GraphTheory/[SubFolder]/MotionScrubbed/Measure_global';


OutpvaluePathTemplate = '[Exp]/GraphTheory/[SubFolder]/ttest/pvalue';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  Save the first level voxel-wise measurement results
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
network.flsave = '[Exp]/GraphTheory/[SubFolder]/FirstLevel/[Netname]/[Metricname]/[Metricname]_[Subjectfl].mat';
network.flconcat = '[Exp]/GraphTheory/[SubFolder]/FirstLevel/[Netname]/[Metricname]/[Metricname].mat';
network.typesave = '[Exp]/GraphTheory/[SubFolder]/FirstLevel/type.mat';
network.tsave = '[Exp]/GraphTheory/[SubFolder]/ttest/result.mat';

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


%% Measures, Stream
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

% network.measures = 'V';
network.measures = 'ABCDEFMNPTVY';

network.voxelmeasures={'degree','betweenness','efficiency','clustering','eigenvector','eccentricity'};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The stream you are at
%%%          m   =   measurement
%%%          t   =   threshold selection
%%%
%%%         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.stream = 'm';

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
addpath(fullfile(mcRoot,'SPM','SPM8','spm8_with_R4667'))

%%
mc_graphtheory_central







