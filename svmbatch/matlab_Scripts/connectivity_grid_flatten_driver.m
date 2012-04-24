%% Template part

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% GENERAL OPTIONS
%%%	These options are the same between Preprocessing and First level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The folder that contains your subject folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/net/data4/MAS/';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Path where your images are located
%
%  Variables you can use in your template are:
%       Exp = path to your experiment directory
%       iSubject = index for subject
%       Subject = name of subject from SubjDir (using iSubject as index of row)
%       iRun = index of run (listed in Column 3 of SubjDir)
%       Run = name of run from RunDir (using iRun as index of row)
%        * = wildcard (can only be placed in final part of template)
% Examples:
% ImageTemplate = '[Exp]/Subjects/[Subject]/func/run_0[iRun]/';
% ImageTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ConnTemplate = '[Exp]/FirstLevel/[Subject]/12mmGrid_19/12mmGrid_19_corr.mat';

OutputTemplate = '[Exp]/SVM/Connectivity/12mmGrid_19/Train.dat';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% A list of run folders where the script can find the images to use
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RunDir = {
	'run_01/';

};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects to process
%%% The format is 'subjectfolder',subject number in masterfile,[runs to include]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjDir = {

% '5001/Tx1',+1;
% '5001/Tx2',-1;
% '5002/Tx1',+1;
% '5002/Tx2',-1;
% '5003/Tx1',+1;
% '5003/Tx2',-1;
% '5004/Tx1',+1;
% '5004/Tx2',-1;
% '5005/Tx1',+1;
% '5005/Tx2',-1;
% '5010/Tx1',+1;
% '5010/Tx2',-1;
% '5012/Tx1',+1;
% '5012/Tx2',-1;
% '5014/Tx1',+1;
% '5014/Tx2',-1;
% '5015/Tx1',+1;
'5015/Tx2',-1;
% '5016/Tx1',+1;
% '5016/Tx2',-1;
% '5017/Tx1',+1;
% '5017/Tx2',-1;
% '5018/Tx1',+1;
% '5018/Tx2',-1;
% '5019/Tx1',+1;
% '5019/Tx2',-1;
% '5020/Tx1',+1;
% '5020/Tx2',-1;
% '5021/Tx1',+1;
% '5021/Tx2',-1;
% '5023/Tx1',+1;
% '5023/Tx2',-1;
% '5024/Tx1',+1;
% '5024/Tx2',-1;
% '5025/Tx1',+1;
% '5025/Tx2',-1;
% '5026/Tx1',+1;
% '5026/Tx2',-1;
% '5028/Tx1',+1;
% '5028/Tx2',-1;
% '5029/Tx1',+1;
% '5029/Tx2',-1;
% '5031/Tx1',+1;
% '5031/Tx2',-1;
% '5032/Tx1',+1;
% '5032/Tx2',-1;
% '5034/Tx1',+1;
% '5034/Tx2',-1;
% '5035/Tx1',+1;
% '5035/Tx2',-1;
% '5036/Tx1',+1;
% '5036/Tx2',-1;
% '5037/Tx1',+1;
% '5037/Tx2',-1;
% '5038/Tx1',+1;
% '5038/Tx2',-1;
% '5039/Tx1',+1;
% '5039/Tx2',-1;
% '5040/Tx1',+1;
% '5040/Tx2',-1;
% '5041/Tx1',+1;
% '5041/Tx2',-1;
% '5042/Tx1',+1;
% '5042/Tx2',-1;

 

       };

%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..','..');
%DEVSTOP

%[DEVmcRootAssign]

addpath(fullfile(mcRoot,'matlabScripts'))
addpath(fullfile(mcRoot,'FirstLevel'))
addpath(fullfile(mcRoot,'spm8'))



%% Central Part

conPathTemplate.Template = ConnTemplate;
conPathTemplate.mode='check';

outPathTemplate.Template=OutputTemplate;
outPathTemplate.mode='makeparentdir';
outPath=mc_GenPath(outPathTemplate);

for iSub=1:size(SubjDir,1)
    Subject = SubjDir{iSub,1};
    Example=SubjDir{iSub,2};
    conPath=mc_GenPath(conPathTemplate);
    conmat=load(conPath);
    rmat=conmat.rMatrix;
    connectivity_grid_flatten(rmat,outPath,Example)
    
end


tick
% system(['svm_learn ' outPath ' ~/model -x 1'])
