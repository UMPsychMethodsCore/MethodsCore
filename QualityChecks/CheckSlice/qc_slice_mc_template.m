%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% If you have any questions read the pdf documentation or contact
%%% MethodsCore at methodscore@umich.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your subject folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Opt.Exp  = '/zubdata/oracle7/Researchers/heffjos/SignalChange/ChronicPain/testData';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects to process
%%% The format is {'subjectfolder',[runs to include]}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Opt.List.Subjects = {
                     'CM1286CHR',1,[1 2];
                     'CM1329CHR',1,[1 2];
                    };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% A list of run folders where the script can find the images to use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Opt.List.Runs = {
                  'run_01';
                  'run_02';
                  'run_03';
                  'run_04';
                  'run_05';
                  'run_06';
                  'run_07';
                };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Path where your images are located
%%%
%%%  Variables you can use in your template are:
%%%       Exp      = path to your experiment directory
%%%       Subject  = name of subject from SubjDir (using iSubject as index of row)
%%%       Run      = name of run from RunDir (using iRun as index of row)
%%% Examples:
%%% ImageTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Opt.ImageTemplate = '[Exp]/[Subject]/func/[Run]/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Prefix of scan images to use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Opt.FileExp = 'run';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Text file to output detected slice outliers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Opt.OutlierText = '[Exp]/TestDir/outlier.txt';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Z score threshold; slices with absolute z scores greater than this 
%%% value will be considered as outliers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Opt.Thresh = 4;

global mcRoot;
%DEVSTART
mcRoot = '/zubdata/oracle7/Researchers/heffjos/MethodsCore';
%DEVSTOP

%[DEVmcRootAssign]
addpath(fullfile(mcRoot,'matlabScripts'));
addpath(fullfile(mcRoot,'QualityChecks','CheckSlice'));
% addpath(fullfile(mcRoot,'SPM','SPM8','spm8_with_R4667'));

qc_slice_mc_central(Opt);
