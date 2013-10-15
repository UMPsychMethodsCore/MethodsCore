%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%                   MassUnivariate Connectomic Analysis                % 
%                           Template Script                            %
%                                                                      %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up your design matrix. You will need to provide a path to a cleansed        %
% Master Data file. It must have a column named 'Subject' for the parsing to      %
% work properly. This will happen in R automatically, then switch back to MATLAB  %
%                                                                                 %
% des.csvpath     -       A full path to your cleansed MasterData File (MDF)      %
% des.IncludeCol  -       String naming col of logicals in MDF for subsetting     %
% des.model       -       A formula expression indicating how to build the design %
%                         matrix. See R or examples for details. Intercept is     %
%                         automatically included in most cases                    %
% des.FxCol       -       Which column of the design matrix will hold the effect  %
%                         of interest? Note that the first column will be an      %
%                         intercept term, so if you have a paired design, set this%
%                         to 1. If you were interested in the first term in       %
%                         des.model, you would set this to 2. If the third term,  %
%                         set it to 3, and so on.                                 %
% des.FlipFx      -       By default, results will be reported in terms of your   %
%                         design matrix. However, sometimes this is the reverse   %
%                         of the way you want to interpret it. R will order its   %
%                         categorical factors alphabetically, so if you have      %
%                         some subjects labeled 'A' for autism and others labeled %
%                         'H' for healthy control, autism will end up being the   %
%                         reference group, and your "effect" will actually be the %
%                         effect of being healthy. If you'd like to flip this, set%
%                         des.FlipFx to 1, and it will multiply the des.FxCol of  %
%                         your design matrix by -1, so that you can interpret     %
%                         results in a more naturaly way.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

des.csvpath = '/net/data4/SomeStudy/MDF.csv';
des.IncludeCol = 'Include.Overall';
des.model = '~ Disease + Motion' ; 
des.FxCol = 2;
des.FxFlip = 0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Does your data follow a paired structure? If so, set paired to 1, and also        %
% be sure to set RunDir. This will get plugged in for '[Run]' in your templates.    %
% You'll also need to set a contrast that will be used to do the delta calculation. %
% This contrast will be the weights of the runs specified in RunDir.                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

paired = 0;

RunDir= {
    'rest_1'
    'rest_2'
    'rest_3'
} ;

pairedContrast = [1 -1 0]; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Provide a path to the .mat files that hold your connectivity or cPPI matrices %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CorrTemplate = '/net/data4/SomeStudy/FirstLevel/MotionScrubbedLinks/[Subject]/censortest_corr.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Is the data that you're loading connectivity or cPPI? In other words, do you %
% care about the upper portion of the connectivity matrix, or the whole thing? %
% If doing connectivity, set matrixtype to 'upper'.                            %
% If doing cPPI, set matrixtype to 'nodiag'.                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

matrixtype = 'nodiag';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If you have resting state data, you may want to Z tranform your data using %
% Fisher's transform. If so, set ZTrans to 1.                                %
% If you have cPPI data, BE SURE TO SET THIS TO 0.                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ZTrans = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify a folder to hold your output. If it does not not already exist, %
% it will be created for you.                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

outputPath = '/net/data4/MyStudy/SweetNewOutput';
GraphTitle = 'SweetNewOutput';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We also need to find just ONE parameter file that has info on where the     %
% ROIs were located, so that we can assign them to networks. We assume that   %
% all subjects had identical ROI grids, so we'll just use the data associated %
% with the first subject (and their first run, if paired)                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ParamTemplate = '/net/data4/FirstLevel/FirstLevel_1080/SiteCatLinks/[SampleSubject]/Grid/Grid_parameters.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do you want to add shading?                                             %
% Yes --- 1; No --- 0;                                                    %
%                                                                         %  
% ShadingEnable is for the entire cell, defaults to 1.                    %
% DotShadingEnable is only for the dots, defaults to 0.                   %
%                                                                         %                  
% The two are mutually exclusive, and ShadingEnable owns higher priority, %
% so if you want to do Dot shading, be sure to set ShadingEnable to 0 in  %
% in advance. Otherwise it will only do cell shading.                     %                                          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ShadingEnable = 1;
DotShadingEnable=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do you want to enlarge the edges in the TakGraph                        %
% Yes --- 1; No --- 0;                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DotEnlarge=1;

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
%                               fall back to just one core.                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nRep     = 10000;
permSave = 'AutismPermutations_5.mat';  
permDone = 0;
permCores = 1;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stats Settings                                                                                                                                         %
%                                                                                                                                                        %
%        NetInclude      -       If you only want to do FDR correction on a subset of your networks, specify them here. You have two options             %
%                                a - Provide a row vector networks to include. These should use the same range of values as in a.NetworkLabels           %
%                                b - Provide a 2D logical square matrix with as many rows & columns as unique values in a.NetworkLabels. This allows you %
%                                maximum flexibility to turn some cells on and others off. Note, the lower triangle will be ignored regardless.          %
%        thresh          -       What is the p-value threshold in the mass univariate model for a single edge to be significant?                         %
%                                Pro tip - pass it a vector. Your analysis will be based on only the first value, but your permutation object            %
%                                will have results from all of them.                                                                                     %
%                                                                                                                                                        %
%                                                                                                                                                        %
%        FDRmode:        -       'pdep'  --- The original Bejnamini & Hochberg FDR procedure is used, which is guaranteed to be accurate if              %
%                                        the individual tests are independent or positively dependent (e.g., Gaussian variables that                     %
%                                        are positively correlated or independent).                                                                      %
%                                'dep'   --- The FDR procedure described in Benjamini & Yekutieli (2001) that is guaranteed to be accurate for           %
%                                        any test dependency structure (e.g., Gaussian variables with any covariance matrix) is used. 'dep'              %
%                                        is always appropriate to use but is less powerful than 'pdep.                                                   %
%                                                                                                                                                        %
%                                        Defaults to 'pdep'.                                                                                             %
%                                                                                                                                                        %
%        FDRRate         -               FDR thresh (The desired false discovery rate). Default 0.05.                                                    %
%                                                                                                                                                        %
%        CalcP           -               [1 or 0]. Defaults to 0. If set to 1, it will actually calculate adjusted p values.                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

thresh = [.001];
NetInclude = [1,2,3,4,5,6,7];
FDRmode = 'pdep';
FDRrate = 0.05;
CalcP = 1;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Network Subset                                                                               %
%                                                                                              %
% If you would like your final TakGraph to include only a subset of networks,                  %
% specify that here. This must be a contiguous range in terms of your actual network labels,   %
% otherwise weird things might happen.                                                         %
% Set TakGraphNetSubsetEnable to 1 to enable this behavior, and set                            %
% TakGraphNetSubset to the range of networks to include                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


TakGraphNetSubsetEnable = 0;

TakGraphNetSubset = 1:7;

  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do Not Edit Below This Line %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..','..','..');
%DEVSTOP

%[DEVmcRootAssign]


addpath(fullfile(mcRoot,'matlabScripts')) % if report error, add 'genpath' before fullfile)
addpath(genpath(fullfile(mcRoot,'svmbatch')))
addpath(fullfile(mcRoot,'spm8Batch'))
addpath(fullfile(mcRoot,'SPM','SPM8','spm8Legacy'))

MassUniConn_mc_central

