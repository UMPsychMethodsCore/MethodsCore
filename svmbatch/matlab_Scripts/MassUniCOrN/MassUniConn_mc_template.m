%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                      %
%                   MassUnivariate Connectomme Analysis                % 
%                           Template Script                            %
%                                                                      %
%                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects to process
%%% The format is 'subjectfolder',
%%%
%%% For unpaired SVM, next is an example label, should be +1 or -1
%%%
%%% For paired SVM, next is a mapping of conditions to runs. Include a
%%% 0 if a given condition is not present. E.g. [3 1 0] would indicate that
%%% condition one is present in Run 3, condition two is present in run 1,
%%% and condition three is missing. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjDir = {

'081119mk',[2 1 3];
'090602pr',[1 2 3];
'090612sb',[2 3 1];
'090701op',[3 2 1];
'090814ad',[2 1 3];
'090908lm',[0 2 1];
'091109ed',[2 1 3];
'100317bc',[1 2 3];
'100408tg',[2 1 3];
'100414ss',[2 3 1];
'100504kc',[3 1 2];
'100505ma',[3 2 1];
'100506kh',[3 2 1];

       };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Do you have multiple runs (or something run-like to iterave over?) If
%%%% so, specify it here.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RunDir= {
    'rest_1'
    'rest_2'
    'rest_3'
} ;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Main Path
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Exp1 = '~/users/kesslerd/repos/scratch_analysis_scripts/Autism/';
Exp2 = '/net/data4/Autism';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% The path of design matrix
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DesMtrxTemplate = '[Exp1]/[DesMtrxName].mat';
DesMtrxName     = 'FixedFX_5';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% The path of correlation file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

CorrTemplate = '[Exp2]/FirstLevel/MotionScrubbedLinks/[Subject]/censortest_corr.mat';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% The path of parameter file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ParamTemplate = '[Exp2]/FirstLevel/FirstLevel_1080/SiteCatLinks/[SampleSubject]/Grid/Grid_parameters.mat';
SampleSubject = '0051459';



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
%               NetInclude: The networks we want to include (The whole network set is from 0 to 13)
% 
%               thresh:     1   ---
%                           2   ---
%                           3   ---  
%
%               nRep:       Number of permutation repitition
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

