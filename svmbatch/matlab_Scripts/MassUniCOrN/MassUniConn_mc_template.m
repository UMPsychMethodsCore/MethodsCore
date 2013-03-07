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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

des.csvpath = '/net/data4/SomeStudy/MDF.csv';
des.IncludeCol = 'Include.Overall';
des.model = '~ Disease + Motion' ; 

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify a folder to hold your output. If it does not not already exist, %
% it will be created for you.                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

outputPath = '/net/data4/MyStudy/SweetNewOutput'


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We also need to find just ONE parameter file that has info on where the     %
% ROIs were located, so that we can assign them to networks. We assume that   %
% all subjects had identical ROI grids, so we'll just use the data associated %
% with the first subject (and their first run, if paired)                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ParamTemplate = '/net/data4/FirstLevel/FirstLevel_1080/SiteCatLinks/[SampleSubject]/Grid/Grid_parameters.mat';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Permutation Settings
%                      
%       nRep            -       Number of permutations to perform.
%       permcol         -       Which column of your design matrix should we permute?
%       permSave        -       Where should we save the permutation results?
%       permDone        -       If you have previously run this script and have permutations,
%                               set this to 1, and it will load up your previous result based
%                               value in permSave
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nRep     = 10000;
permcol  = 2;
permSave = 'AutismPermutations_5.mat';  
permsDone = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Stats Settings
% 
%               NetInclude: The networks we want to include (The whole network set is typically from 0 to 13)
% 
%               thresh:     1   ---
%                           2   ---
%                           3   ---  
%
%               nRep:       Number of permutation repetition
%
%               FDRmode:    'pdep'  --- The original Bejnamini & Hochberg FDR procedure is used, which is guaranteed to be accurate if
%                                       the individual tests are independent or positively dependent (e.g., Gaussian variables that 
%                                       are positively correlated or independent).
%                           'dep'   --- The FDR procedure described in Benjamini & Yekutieli (2001) that is guaranteed to be accurate for 
%                                       any test dependency structure (e.g., Gaussian variables with any covariance matrix) is used. 'dep'
%                                       is always appropriate to use but is less powerful than 'pdep. 
%                            Defaults to 'pdep'.
% 
%               FDRrate:     FDR thresh (The desired false discovery rate). Default 0.05.
%
%               SignAlpha:   The alpha level used for the binomial sign test. Defaults to 0.05 if unset.
% 
%               CalcP:       [1 or 0]. Defaults to 0. If set to 1, it will actually calculate adjusted p values. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

thresh = [.001, .01, .05];
NetInclude = [1,2,3,4,5,6,7];
FDRmode = 'pdep';
FDRrate = 0.05;
SignAlpha = 0.05;
CalcP = 1;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Shading Options
% 
%              enable     1    ---     turn on shading
%                         0    ---     turn off shading
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
enable = 1;
transmode = 0;
SingleTrans = 0.5;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Networks Selection
%                      
%                   net1, net2  ---   Define networks for contingency analyis
%                      netName  ---   Assign a network name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

net1=[2]; %enter network [range: 0-13]
net2=[2];
netName= 'defFront';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Do Not Edit Below This Line %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Add path 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mcRoot = '~/users/yfang/MethodsCore';

addpath(fullfile(mcRoot,'matlabScripts')) % if report error, add 'genpath' before fullfile)
addpath(fullfile(mcRoot,'svmbatch'))
addpath(fullfile(mcRoot,'spm8Batch'))
addpath(fullfile(mcRoot,'SPM','SPM8','spm8Legacy'))

MassUniConn_mc_central

