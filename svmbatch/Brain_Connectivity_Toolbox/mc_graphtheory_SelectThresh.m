%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%        Graph Theory Measurements of connectivity matrix              %
%                      Select Threshold Script                         %
%                                                                      %
% Yu Fang 2013/01                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Experiment Directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Exp = '/net/data4/MAS/';
% Exp = '/home/slab/mnt/psyche/net/data4/GO2010/PROJECTS/ERT';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% List all your run directories
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RunDir = { 
  'Tx1/';
  'Tx2/';
         };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Path where the correlation matrix are located
% 
% TemplateType: Type of correlation matrix template 
%                           'single'   -    Single network template, usually it's cppi_grid
%                           'averaged' -    Template files from multiple runs 
%                                           which need to be averaged (corrected) 
%                                           in the downstream, usually it's corrected t score
% 
% TemplateAverageRun: If TemplateType is 'averaged', then set the number of runs here
% 
% TRow: In cppi_grid data, row of interest which contains t-score
% BRow: In cppi_grid data, row of interest which contains beta (unstandardized or standardized)
% Column: In cppi_grid data, columns of interst which contain conditions we want to include
%
% 
% If TemplateType is set as 'averaged':
% The template variable should be NetworkTemplate{num}: num is from 1 to TemplateAverageRun
%
% If TemplateType is set as 'single':
% The template variable should be NetworkTemplate
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TemplateType = 'averaged';
TemplateAverageRun = 2;
TRow = 3;
BRow = 4;
Column = [3,4,8,9]; 

NetworkTemplate{1}  = '[Exp]/FirstLevel/[Subject]/[Run]/MSIT/HRF/FixDur/Congruency_NORT_new_cppi_norm/Congruency_NORT_new_cppi_norm_correctedtscore_run05.mat';
NetworkTemplate{2}  = '[Exp]/FirstLevel/[Subject]/[Run]/MSIT/HRF/FixDur/Congruency_NORT_new_cppi_norm/Congruency_NORT_new_cppi_norm_correctedtscore_run06.mat';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Required Network Options:
%%% network.directed:    0 - undirected matrix; 1 - directed matrix
%%% network.weighted:    0 - unweighted matrix; 1 - weighted matrix
%%% network.datatype: 
%%%                     'p' - thresholding p-value matrix to binary matrix by p-value (e.g. results from SOM)
%%%                     't' - thresholding t-score matrix to binary matrix by t-score (e.g. results from cPPI)
%%%                     'r' - thresholding r-value matrix to weighted matrix by p-value (e.g. results from SOM)
%%%                     'b' - threshloding beta-value matrix to weighted matrix by t-score (e.g. results from cPPI)
%%% network.ztransform:  If network.datatype is set to 'r', we have the option to do an r to z transform
%%%                      0  - Don't do z transform    1 - Do z transform
%%% network.loc:         0  - Average over upper and lower triangulars; 1 - upper triangular; 2 - lower triangular  
%%% network.value(when using weighted network):       0 - Absolute value;   1 - Only positive value
%%% network.iter: rewiring parameter when generating random graph (each
%%% edge is rewired approximatel network.iter times)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.directed = 0;
network.weighted = 0;
network.datatype = 't';
network.ztransform = 1;
network.loc      = 0;
network.value    = 0;
network.iter     = 5;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Path where the mni coordinates of each node are located
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NetworkParameter = '[Exp]/FirstLevel/5001/Tx1/12mmGrid_19_nogm/12mmGrid_19_nogm_parameters.mat';
NetworkParameter = '[Exp]/FirstLevel/5001/Tx1/MSIT/HRF/FixDur/Congruency_NORT_new_cppi_norm/Congruency_NORT_new_cppi_norm_parameters.mat';
% NetworkParameter = '[Exp]/FirstLevel/024/ERT_cPPI_norm/ERT_cPPI_norm_parameters.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name and path for your output file(leave off the .csv) 
% <For different threshold values, output to a same file>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

OutputPathTemplate = '[Exp]/GraphTheory/Congruency_NORT_new_cppi_norm_corrected_averagedT_global';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Threshold for the P-value / t-score correlation matrix (to create binary
%%% or weighted adjacency matrix)
%%% <An array of threshold value you want to test>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
network.adjacency = [2,2.1,2.2,2.3,2.4,2.5,2.6];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects 
%%% col 1 = subject id as string, col 2 = subject id as number, col 3 = runs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SubjDir = {
    '5001',1,[1 2]
    '5002',1,[1 2]
    '5003',1,[1 2]
    '5004',1,[1 2]
    '5005',1,[1 2]
    '5010',1,[1 2]
    '5012',1,[1 2]
    '5014',1,[1 2]
    '5015',1,[1 2]
    '5016',1,[1 2]
    '5017',1,[1 2]
    '5018',1,[1 2]
    '5019',1,[1 2]
    '5020',1,[1 2]
    '5021',1,[1 2]
    '5023',1,[1 2]
    '5024',1,[1 2]
    '5025',1,[1 2]
    '5026',1,[1 2]
    '5028',1,[1 2]
    '5029',1,[1 2]
    '5031',1,[1 2]
    '5032',1,[1 2]
    '5034',1,[1 2]
    '5035',1,[1 2]
    '5036',1,[1 2]
    '5037',1,[1 2]
    '5038',1,[1 2]
    '5039',1,[1 2]
    '5040',1,[1 2]
    '5041',1,[1 2]
    '5042',1,[1 2]
    };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The measurements you need to do
%%% ( Detailed explanation of the measurements is in mc_graphtheory_measures.m)
%%% 
%%%         E = degree
%%%         S = small-worldness
%%%                  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
network.measures = 'ES';

mcRoot = '~/users/yfang/MethodsCore';
addpath(fullfile(mcRoot,'Brain_Connectivity_Toolbox/');
addpath(fullfile(mcRoot,'matlabScripts')) % if report error, add 'genpath' before fullfile
addpath(genpath(fullfile(mcRoot,'svmbatch')))
addpath(fullfile(mcRoot,'spm8Batch'))
addpath(fullfile(mcRoot,'SPM','SPM8','spm8Legacy'))

mc_graphtheory_central
