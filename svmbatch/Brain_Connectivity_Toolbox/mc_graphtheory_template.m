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
% - Experiment Directory -
% Your main analysis folder
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Exp = '/net/data4/slab_OCD/';
Exp = '/net/data4/MAS/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Input File -
% This script expects subject-wise input files. 
% Each subject-wise file is a struct, and should have 1 or 2 
% subfields, each of them containing an nROIxnROI matrix. One subfield serves 
% as thresholding matrix. For each edge, only when the value in ThreshField
% is above the threshold value in graph.thresh will the edge be included.
% The other subfield serves as a edge matrix, which provides 
% the actual value of the connections (can be either binary or weighted). 
% ThreshField and EdgeField can be the same or different fields. 
% For example, for Pearson's r correlations, we suggest using the r matrix or 
% p matrix as the threshold matrix and the r matrix as theedge matrix; 
% for cPPI, we suggest using the t-score matrix as thresholding matrix and 
% the beta matrix as edge matrix.
%
% SubjWiseTemp - Subject-wise input file template
% ThreshField  - Subfield with thresholding matrix
% EdgeField    - Subfield with edge matrix
% 
% The matrices in both ThreshField and EdgeField should be nROI x nROI
% matrix with symmetric or asymmetric values on upper and lower triangle.
% Values only being in one triangle is not acceptable. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% SubjWiseTemp = '[Exp]/FirstLevel/[Subject]/4mmVoxel_Censor/gm_gp_corr.mat';

SubjWiseTemp = '[Exp]/FirstLevel/[Subject]/Tx1/RestingGrid1166/RestingGrid1166_corr.mat';

ThreshField = 'rMatrix';
EdgeField   = 'rMatrix';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - MasterData File -
% By loading the referenced MDF, the script will extract subject name and type
% lists. The users should create a MDF in advance with at least the
% following columns: Subject, Type, Include_Overall
%
% MDF.path - Path of MasterDataFile, which provides subject and type lists
% NamePre  - Prefix of Subject Names, defaults to ''  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MDF.path    = '[Exp]/Scripts/MDF/MDF_OCD.csv'; 
MDF.path    = '[Exp]/Scripts/slab/MDF/MDF_Rest_tx1.csv'; 
NamePre = '';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - MasterData File column names -
%
% MDF.Subject - Column header of Subject names
% MDF.Type    - Column header of Subject types (one letter each)
% MDF.include - Column header of logicals in MDF for subsetting
%               ('TRUE' or 'FALSE')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MDF.Subject = 'Subject';
MDF.Type    = 'Type';
MDF.include = 'Include_Overall'; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Network Parameter File -
% The file provides mni coordinates which are used to separate sub brain
% networks
%
% NetworkParameter - Path of Network Parameter File. 
%
% Usually one file from any one of the subjects in the list would be
% enough.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NetworkParameter = '[Exp]/FirstLevel/080315jp/4mmVoxel_Censor/gm_gp_parameters.mat';
NetworkParameter = '[Exp]/FirstLevel/5001/Tx1/RestingGrid1166/RestingGrid1166_parameters.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Network Selection -
% To decide which brain network/s to include
% 
% graph.netinclude:                             -1 - Whole Brain;
%                   Array of integers from 1 to 13 - SubNetworks based on 
%                                                    parcellation of Yeo
%                   Defaults to -1 if not assigned.   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

graph.netinclude = -1; 
% graph.netinclude = 1:7; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Subject type order -
% A flag that helps the script to distinguish group types in second level
% analysis
%
% graph.covtype:  0 - experiment group name is in the back alphabetically, 
%                     like 'H' and 'O';
%                 1 - experiment group name is in the front alphabetically, 
%                     like 'A' and 'H'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

graph.covtype = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Graph Type -
%
% graph.directed: 1 - directed matrix; 
%                 0 - undirected matrix; 
%                 Defaults to 0 if not assigned.
% graph.weighted: 1 - weighted matrix; 
%                 0 - unweighted matrix; 
%                 Defaults to 0 if not assigned.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

graph.directed   = 0;
graph.weighted   = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Pre Calculation -
%
% graph.amplify: Integers > 1  - Indicating the input correlations were 
%                                amplified by graph.amplify and need to 
%                                be converted back to (-1,1);
%                           1  - The input data value is already in the 
%                                right range
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% graph.amplify     = 10000;
graph.amplify     = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Calculation Options -
%
% graph.partial:       1 - use partial correlation; 
%                      0 - use normal correlation;  
%                      Defaults to 0 if not assigned.
% graph.ztransform:    1 - Do z transform;   
%                      0 - Don't do z transform. 
%                      Defaults to 1 if not assigned.
% graph.ztransdone:    1 - Z transform already done; 
%                      0 - Z transform not done yet.
%                      Defaults to 0 if not assigned.
% graph.value:         -1 - Only use negative value;
%                      0  - Use original value.
%                      1  - Only use positive value;
%                      2  - Use absolute value;   
%                      Defaults to 1 if not assigned.
%
% Partial and Z-transform aims at the case that input matrix is pearson's 
% r correlation matrix. In other cases, set them to 0.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

graph.partial     = 0;
graph.ztransform  = 1;
graph.ztransdone  = 0; 
graph.value    = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Thresholding -
% 
% graph.threshmode: 'value'      - thresholding based on edge value, in 
%                                  this case, the number/s in graph.thresh
%                                  indicates the value threshold;
%                   'percent'    - in this case, the number/s listed in
%                                  graph.thresh indicates how many
%                                  percentage edges you want to keep, e.g.
%                                  10 means you want to keep top 10%
%                                  edges; all numbers bigger than 100 will
%                                  be treated as 100, smaller than 0 will
%                                  be treated as 0.
%                   Defaults to 'value'.
%
% graph.thresh - A number representing the threshold/s that decides which 
%                edges to keep in the graph;
%                
% If do not want the graph to be thresholded, you can either: set
% threshomode to 'value' and set thresh to '-Inf'; or : set threshmode to
% 'percentage' and set thresh to '100'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

graph.threshmode = 'value';

graph.thresh = [0.25];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Nodewise Measure - 
% 
% graph.node:  1 - Do node-wise measurement analysis;
%              0 - Don't do node-wise measurement analysis;
%              Defaults to 0 if not assigned.
%
% 3D template and mask (Need to be defined only when graph.node is assigned
% with 1)
% TDtemplate - Template for building 3D map for node-wise graph theory
%              measure results or second level (t-test/permutation test) 
%              results. Usually use one of the preprocessed functional
%              image.
% TDmask     - Mask for building 3D map for node-wise graph theory
%              measure results or second level (t-test/permutation test) 
%              results.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

graph.node        = 1;

TDtemplate = '[Exp]/Subjects/5001/Tx1/TASK/func/run_01/swrarestrun_01.nii';
TDmask     = '[Exp]/ROIS/rEPI_MASK_NOEYES.img';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - t-test -
%
% graph.ttest:     1 - Do t-test for global measures;  
%                  0 - Don't do t-test for global measures.
%                  Defaults to 0 if not assigned.%
% graph.nodettest: 1 - Do t-test for node-wise measures;
%                  0 - Don't do t-test for global measures.
%                  Defaults to 0 if not assigned.
% ttype:           'paired' - paired t-test
%                  '2-sample' - 2 sample t-test
% siglevel:        alpha threshold for T-test
%
% ttype needs to be defined only when graph.ttest and/or graph.nodettest 
% are set to 1 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

graph.ttest    = 1;
graph.nodettest = 1;
   
ttype     = '2-sample';
siglevel = 0.05;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Permutation test -
%
% graph.perm:     1 - Do permutation test for global measures; 
%                 0 - Don't do permutation test for global measures.  
%                 Defaults to 0 if not assigned.
% nRep          - Number of permutations to perform. 
% permDone:       1 - Permutation already done;
%                 0 - Permutation not done.                          
% permCores     - How many CPU cores to use for permutations. We will try,      
%                 but it often fails with big data, in which case we will       
%                 fall back to just one core. 
% permLevel     - alpha value for permutation test
%
% graph.nodeperm: 1 - Do permutation test for nodewise measures; 
%                 0 - Don't do permutation test for nodewise measures.
%                 Defaults to 0 if not assigned.
% nodenRep      - Number of permutations to perform.                
% nodepermCores - How many CPU cores to use for permutations. We will try,      
%                 but it often fails with big data, in which case we will       
%                 fall back to just one core. 
%
% nRep, permDone and permCores need to be defined only when graph.perm is 
% set to 1; nodenRep and nodepermCores need to be defined only when
% graph.nodeperm is set to 1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

graph.perm     = 1;        

nRep     = 10000;
permDone = 0;
permCores = 1;

permlevel = 0.05;

graph.nodeperm = 1;   

nodenRep = 10000;
nodepermCores = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - FDR correction - 
%
% This is for nodewise measurements.
% 
% graph.FDR: 1 - Enable FDR Correction
%            0 - Disable FDR Correction
%            Defaults to 0.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

graph.FDR = 0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Metric Selection -
%
% graph.measures - The metrics you want to select
% 
%         A = assortativity
%         B = betweenness [global/node-wise] (Note: Time-consuming)
%         C = clustering coefficient [global/node-wise]
%         D = density
%         E = degree [global/node-wise]
%         F = efficiency [global/node-wise]
%             (Note: global efficiency is inversely related to
%             characteristic path length; local efficiency is related to
%             clustering coefficient. Therefore the users don't have to 
%             select all of these measures.)
%         M = modularity
%         N = eccentricity
%         P = characteristic path length
%         S = small-worldness (Note: Time-consuming, need to select 'C' and 'P')
%         T = transitivity
%             (Note: transitivity is an alternative to the clustering
%             coefficient. Therefore the users don't have to select both
%             of these measures.)
%         V = eigenvector centrality
%         Y = entropy
%
% graph.voxelmeasures  -  The node-wise metrics you want to analyze 
% 
%         B = betweenness  (need to include 'B' in graph.measures)
%         C = clustering   (need to include 'C' in graph.measures)
%         E = degree       (need to include 'E' in graph.measures)
%         F = efficiency   (need to include 'F' in graph.measures)
%         G = strength     (need to include 'E' in graph.measures and only apply to weighted measure)
%         N = eccentricity (need to include 'P' in graph.measures)
%         V = eigenvector  (need to include 'V' in graph.measures)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

graph.measures = 'BEM';

graph.voxelmeasures = 'BE';   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Output -
%
% OutputFolder: The folder that contains all of the outputs, located under
%               [Exp]/GraphTheory/
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

OutputFolder = 'test011514';




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% Advanced Calculation Settings %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% (Usually don't change) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Nodewise Measure -
%
% graph.nodezscore: 1 - Convert nodewise measure values to normalized 
%                          zscore for each subject: (value-mean())/std();
%                   0 - Use original voxelwise measure values;
%                   Defaults to 1 if not assigned.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

graph.nodezscore = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Measure parameters -
% 
% smallworlditer:  The iteration time when calculating smallworldness, need
%                  to be defined only when smallworldness is selected.
%                  Defaults to 100.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

smallworlditer = 100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - FDR correction - 
% 
% FDR.rate:  The desired false discovery rate. 
% FDR.mode:  'pdep' - the original Bejnamini & Hochberg FDR procedure is used, 
%                     which is guaranteed to be accurate if the individual 
%                     tests are independent or positively dependent (e.g., 
%                     Gaussian variables that are positively correlated or
%                     independent).
%            'dep'  - the FDR procedure described in Benjamini & Yekutieli (2001) 
%                     that is guaranteed to be accurate for any test dependency 
%                     structure (e.g.,Gaussian variables with any covariance 
%                     matrix) is used. 'dep' is always appropriate to use 
%                     but is less powerful than 'pdep.
%             Default 'dep'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FDR.rate  = 0.05;
FDR.mode  = 'dep';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% Advanced Output Settings %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% (Usually don't change) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Initial results -
% 
% OutputMat - The mat file that contains all the initial measurement 
%             results with three subfields
%             'CombinedOutput' - including both global and nodewise
%                                results.
%             'SubUse'         - a vector indicating which subjects are 
%                                used or excluded(e.g. all NaNs in the 
%                                correlation matrix).
%             'nROI'           - Number of ROIs in the graph.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
OutputMat = '[Exp]/GraphTheory/[OutputFolder]/AllMeasures.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Global First Level -
% 
% OutputPathTemplate - The csv file containing first level graph theory 
%                      results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

OutputPathTemplate = '[Exp]/GraphTheory/[OutputFolder]/FirstLevel/global/Measure.csv';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Global Second Level -
%
% ttestOutMat          - The mat file saving the t-test results;
% ttestOutPathTemplate - The csv file containing t-test results;
%
% permSave             - The mat files saving permutation intermediate 
%                        results, nThresh files, size nNet x nMetric x nRep;
% permOutMat           - The mat file saving the permutation stats results;
% permOutPathTemplate  - The csv file containing permutation results.
%
% ttestOutMat and ttestOutPathTemplate need to be defined only when 
% graph.ttest is set to 1;
% permSave, permOutMat and permOutPathTemplates need to be defined only
% when graph.perm is set to 1;
% In case the user want to do change in this part, be careful not to
% touch 'iThresh' in the bracket, as 'ThreValue' is a variable in the central
% script.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ttestOutMat = '[Exp]/GraphTheory/[OutputFolder]/SecondLevel/global/ttest.mat';
ttestOutPathTemplate = '[Exp]/GraphTheory/[OutputFolder]/SecondLevel/global/ttest.csv';

permSave   = '[Exp]/GraphTheory/[OutputFolder]/SecondLevel/global/[ThreValue]_perms.mat';
permOutMat = '[Exp]/GraphTheory/[OutputFolder]/SecondLevel/global/permtest.mat';
permOutPathTemplate = '[Exp]/GraphTheory/[OutputFolder]/SecondLevel/global/permtest.csv';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Node-wise Second Level (3D maps) -
%  
% TDgptemp   - Necessary when intending to do second-level with SPM
% TDttemp    - Necessary when intending to do second-level t-test within
%              script
% TDpermtemp - Necessary when intending to do second-level permutation test
%              within script
% graph.expand: 0 - no expansion in the 3d maps
%               1 - expand voxel to cross in the 3d maps
%               Defaults to 0.
%
% TDgptemp need to be defined only when graph.node is set to 1;
% TDttemp need to be defined only when graph.node and graph.nodettest are 
% set to 1;
% TDpermtemp need to be defined only when graph.node and graph.nodeperm are 
% set to 1;
% In case the user want to do change in this part, be careful not to
% touch 'group', 'ThreValue','Netname' and 'Metricname' in the brackets, as 
% they are variables in the central script.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TDgptemp = '[Exp]/GraphTheory/[OutputFolder]/FirstLevel/nodewise/[ThreValue]/[Netname]/[Metricname]/[group]_[Subjname].nii';

TDttemp    = '[Exp]/GraphTheory/[OutputFolder]/SecondLevel/nodewise/[ThreValue]_[Netname]_[Metricname]_ttest.nii';
TDpermtemp = '[Exp]/GraphTheory/[OutputFolder]/SecondLevel/nodewise/[ThreValue]_[Netname]_[Metricname]_permtest.nii';

graph.expand = 1;






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do not edit below this line.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - set the path -
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mcRoot = '~/users/yfang/MethodsCore/';
addpath(fullfile(mcRoot,'svmbatch','Brain_Connectivity_Toolbox/'));
addpath(fullfile(mcRoot,'matlabScripts'))
addpath(genpath(fullfile(mcRoot,'svmbatch')))
addpath(genpath(fullfile(mcRoot,'svmbatch','matlab_Scripts')))
addpath(fullfile(mcRoot,'spm8Batch'))
addpath(fullfile(mcRoot,'SPM','SPM8','spm8_with_R4667'))


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - Run central script -
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mc_graphtheory_central







