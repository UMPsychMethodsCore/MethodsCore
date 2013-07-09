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
% Exp = '/net/data4/slab_OCD/';

NonCleansedTemp = '[Exp]/FirstLevel/[Subject]/Grid_Censor/Grid_Censor_corr.mat';


Pxe = '/net/data4/ADHD/UnivariateConnectomics/Results/Cleansing_MLE_1166_Censor_Z/';

CleansedTemp = '[Pxe]/Results_Cleansed_Part[m].mat';

PartNum = 5;  % Results_Cleansed_Part1 ~ Results_Cleansed_Part(PartNum)

ResultTemp = '[Pxe]/Results.mat';

SubFolder = '0627';



     
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Path where the mni coordinates of each node are located
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

NetworkParameter = '[Exp]/FirstLevel/SiteCatLinks/1018959/1166rois_Censor/1166rois_Censor_parameters.mat';
% NetworkParameter = '[Exp]/FirstLevel/080516dw/Grid_Censor/Grid_Censor_parameters.mat';

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
%%% network.MLEcleansed: 1 -- The input data would be MLEcleansed data;
%%%                      0 -- The input data would be regular correlation data;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.directed   = 0;
network.weighted   = 0;
network.datatype   = 'r';
network.ztransform = 1;
network.loc        = 0;
network.positive   = 1;

network.local = 0;
network.voxel = 1;

network.iter       = 5;
network.netinclude = [1:7]; 

network.rthresh  = [0.25:0.01:0.3];
network.zthresh  = 0.5.*log((1+network.rthresh)./(1-network.rthresh));

network.perm     = 1;
network.ttest    = 1;

network.MLEcleansed = 1;

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Subject List
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~network.MLEcleansed
    
    SubjDir = {
        
    '080222rt','H';
% '080223rg','H';
'080315cs','O';
'080315jp','H';
'080412km','H';
'080419lk','O';
'080516dw','H';
'080614bs','H';
'080618ms','O';
'080626bc','O';
'080710kn','H';
'080820at','O';
'080830af','O';
'080917aj','H';
'081003jd','O';
'081011mb','H';
'081220kj','O';
'090110oh','O';
'090124jb','H';
'090210ap','O';
'090210ep','O';
'090228cs1','H';
'090228cs2','H';
'090228sj','O';
'090501dt','H';
'090502es','H';
'090502js','H';
'090603eg','H';
'090613ls','O';
'090626gc','O';
'090711zc','O';
'090714eg','H';
'090717vm','H';
'090730ej','H';
% '090812cz','H';
'090814mb','H';
'090829jj','H';
'090909ac','O';
'091012rb','O';
'091019jj','H';
'091031jk','O';
'091103rt','H';
'091114ek','O';
'091118lp','H';
'091219ak','O';
'091222jb','O';
'100130pe','H';
'100215na','O';
'100217jr','O';
'100220kh','O';
'100313sw','O';
'100315mh','H';
'100331cd','H';
'100407ld','H';
'100412hc','H';
'100417rk','O';
'100518nh','O';
'100611gc','O';
'100729am','O';
'100817ik','O';
'100825aw','O';
'100830nn','O';
'101002jr','O';
'101104ss','H';
'101105kj','O';
'101113kt','O';
'101113rm','O';
'101203ap','O';
'110214cm','H';
'110305je','H';
'110326lm','H';
'110402kt','O';
'110413ci','O';
'110425dt','H';
'110514ag','O';
'110608mm','H';
'110610sm','O';
'110621se','H';
'110720lz','O';
'110723bh','H';
'110723cg','O';
'110827eb','H';
'111114ap','O';
'111118md','O';
'111209hw','H';
'120114aw','H';
'120127ak','O';
'120322tu','O';
'120331ad','O';
'120331ap','H';
'120331jm','H';
'120331js','H';
'120414tg','H';
    
    };
 


end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Nodes of interest (Please input the coordinates that are contained in the
% parameters file)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if network.local
%     NodeList = [
%         -18 0 72;
%         6 12 72;
%         -6 12 72;
%         ];
% end

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
%%%         P = characteristic path length
%%%         S = small-worldness
%%%         T = transitivity
%%%         Y = entropy
%%%
%%%         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

network.measures = 'ABCDEFMPTY';

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
mc_graphtheory_central_MLEcleansed








