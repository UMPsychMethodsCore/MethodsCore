%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%        Graph Theory Measurements of connectivity matrix              %
%                         Template Script                              %
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

% RunDir = { 
%   'ERT_cPPI_norm/';
%          };


     
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
% BRow: In cppi_grid data, row of interest which contains beta (unstandardized or standardized)
% Column: In cppi_grid data, columns of interst which contain conditions we want to include
%
% 
% 
% If TemplateType is set as 'averaged':
% The template variable should be NetworkTemplate{num}: num is from 1 to TemplateAverageRun
%
% If TemplateType is set as 'single':
% The template variable should be NetworkTemplate
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TemplateType = 'single';
TemplateAverageRun = 2;
BRow = 4;
Column = [3,4,8,9]; 
% Column = [7,8];  % goERT

NetworkTemplate  = '[Exp]/FirstLevel/[Subject]/[Run]/12mmGrid_19_nogm/12mmGrid_19_nogm_corr.mat';
% NetworkTemplate  = '[Exp]/FirstLevel/[Subject]/[Run]/MSIT/HRF/FixDur/Congruency_NORT_new_cppi_norm/Congruency_NORT_new_cppi_norm_cppi_grid.mat';
% NetworkTemplate  = '[Exp]/FirstLevel/[Subject]/[Run]/ERT_cPPI_norm_cppi_grid.mat';
% NetworkTemplate{1}  = '[Exp]/FirstLevel/[Subject]/[Run]/MSIT/HRF/FixDur/Congruency_NORT_new_cppi_norm/Congruency_NORT_new_cppi_norm_correctedtscore_run05.mat';
% NetworkTemplate{2}  = '[Exp]/FirstLevel/[Subject]/[Run]/MSIT/HRF/FixDur/Congruency_NORT_new_cppi_norm/Congruency_NORT_new_cppi_norm_correctedtscore_run06.mat';


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





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Path where the mni coordinates of each node are located
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NetworkParameter = '[Exp]/FirstLevel/5001/Tx1/12mmGrid_19_nogm/12mmGrid_19_nogm_parameters.mat';
NetworkParameter = '[Exp]/FirstLevel/5001/Tx1/MSIT/HRF/FixDur/Congruency_NORT_new_cppi_norm/Congruency_NORT_new_cppi_norm_parameters.mat';
% NetworkParameter = '[Exp]/FirstLevel/024/ERT_cPPI_norm/ERT_cPPI_norm_parameters.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Nodes of interest (Please input the coordinates that are contained in the
% parameters file)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NodeList = [
    -18 0 72;
     6 12 72;
    -6 12 72;
    ];  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Name and path for your output file, 1 is for global measures, 2 is for
% local measures (leave off the .csv)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OutputPathTemplate1 = '[Exp]/GraphTheory/12mmGrid_19_nogm_weighted_global';
% OutputPathTemplate2 = '[Exp]/GraphTheory/12mmGrid_19_nogm_weighted_local';

OutputPathTemplate1 = '[Exp]/GraphTheory/Congruency_NORT_new_cppi_norm_corrected_averagedT_global';
OutputPathTemplate2 = '[Exp]/GraphTheory/Congruency_NORT_new_cppi_norm_corrected_averagedT_local';
% OutputPathTemplate1 = '[Exp]/GraphTheory/Congruency_NORT_new_cppi_norm_weighted_global_low';
% OutputPathTemplate2 = '[Exp]/GraphTheory/Congruency_NORT_new_cppi_norm_weighted_local_low';

% OutputPathTemplate1 = '[Exp]/GraphTheory/go_ERT_cPPI_norm_Reappraise_weighted_averagedT_global';
% OutputPathTemplate2 = '[Exp]/GraphTheory/go_ERT_cPPI_norm_Reappraise_weighted_averagedT_local';
% OutputPathTemplate1 = '[Exp]/GraphTheory/go_ERT_cPPI_norm_Maintain_global_low';
% OutputPathTemplate2 = '[Exp]/GraphTheory/go_ERT_cPPI_norm_Maintain_local_low';
% OutputPathTemplate1 = '[Exp]/GraphTheory/go_ERT_cPPI_norm_Reappraise_global_low';
% OutputPathTemplate2 = '[Exp]/GraphTheory/go_ERT_cPPI_norm_Reappraise_local_low';
% OutputPathTemplate1 = '[Exp]/GraphTheory/go_ERT_cPPI_norm_Reappraise_global_up';
% OutputPathTemplate2 = '[Exp]/GraphTheory/go_ERT_cPPI_norm_Reappraise_local_up';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Sparsity threshold for the P-value / t-score correlation matrix (to create 
%%% binary adjacency matrix)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.sparsity = 0.2;




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

% SubjDir = {
%     
% '024',1,[1]
% '046',1,[1]
% '066',1,[1]
% '074',1,[1]
% '081',1,[1]
% '084',1,[1]
% '095',1,[1]
% '103',1,[1]
% '107',1,[1]
% '110',1,[1]
% '111',1,[1]
% '124',1,[1]
% '133',1,[1]
% '137',1,[1]
% '138',1,[1]
% '142',1,[1]
% '143',1,[1]
% '148',1,[1]
% '153',1,[1]
% '157',1,[1]
% '158',1,[1]
% '160',1,[1]
% '162',1,[1]
% '167',1,[1]
% '174',1,[1]
% '176',1,[1]
% '191',1,[1]
% '200',1,[1]
% '202',1,[1]
% '203',1,[1]
% '206',1,[1]
% '207',1,[1]
% '218',1,[1]
% '219',1,[1]
% '221',1,[1]
% '227',1,[1]
% '229',1,[1]
% '233',1,[1]
% '235',1,[1]
% '237',1,[1]
% '245',1,[1]
% '251',1,[1]
% '256',1,[1]
% '268',1,[1]
% '269',1,[1]
% '293',1,[1]
% '331',1,[1]
% '332',1,[1]
% '344',1,[1]
% 
% };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The measurements you want to select
%%% ( Detailed explanation of the measurements is in mc_graphtheory_measures.m)
%%% 
%%%         A = assortativity
%%%         B = betweenness
%%%         C = clustering coefficient
%%%         D = density
%%%         E = degree
%%%         F = motif
%%%         G = global efficiency
%%%         L = local efficiency
%%%         M = modularity
%%%         P = characteristic path length
%%%         S = small-worldness
%%%         T = transitivity
%%%
%%%         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.measures = 'ACDEGMPT';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%%%  Save the measurement results into a mat file  
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.save = 'CombinedOutput.mat';

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
%%%         D = density
%%%         E = degree
%%%         G = global efficiency
%%%       
%%%         M = modularity
%%%         P = characteristic path length
%%%         S = small-worldness
%%%         T = transitivity
%%%
%%% If you don't want to do this for any metric, set network.AUC to ''.        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.AUC = 'GP';

network.aucSave = 'AUC.mat';

AUCTemplate = '[Exp]/GraphTheory/0412/MeanValue';



%%%%%%%%%%%%%%%%%%%
% set the path
%%%%%%%%%%%%%%%%%%%
mcRoot = '~/users/yfang/MethodsCore/';
addpath(fullfile(mcRoot,'svmbatch','Brain_Connectivity_Toolbox/'));
addpath(fullfile(mcRoot,'matlabScripts')) % if report error, add 'genpath' before fullfile
addpath(genpath(fullfile(mcRoot,'svmbatch')))
addpath(fullfile(mcRoot,'spm8Batch'))
addpath(fullfile(mcRoot,'SPM','SPM8','spm8Legacy'))

mc_graphtheory_central









