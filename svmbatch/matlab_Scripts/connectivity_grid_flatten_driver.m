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

ConnTemplate = '[Exp]/FirstLevel/[Subject]/12mmGrid/12mmGrid_corr.mat';

OutputTemplate = '[Exp]/SVM/Connectivity/TEST/Train.dat';


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
%  '5001/Tx2',1;
%  '5002/Tx2',50022,[1 2],[225 240], 0;
%  '5003/Tx1',50031,[1 2], [225 240], {'run_04/';'run_05/'};
% 
% '5004/Tx1',50041,[1 2], 0, 0;
% '5005/Tx1',50051,[1 2], 0, 0;
% '5008/Tx1',50081,[1 2], 0, 0;
% '5010/Tx1',50101,[1 2], 0, 0;
% % '5011/Tx1',50111,[1 2], 0, 0; %This subject has too many error trials
% '5012/Tx1',50121,[1 2], 0, 0; 
% '5013/Tx2',50132,[1 2], 0, 0;
% '5014/Tx2',50142,[1 2], 0, 0;
% '5015/Tx2',50152,[1 2], 0, 0;
% '5016/Tx1',50161,[1 2], 0, 0;
% '5017/Tx1',50171,[1 2], 0, 0;
% '5018/Tx2',50182,[1 2], 0, 0;
% '5019/Tx1',50191,[1 2], 0, 0;
% '5020/Tx2',50202,[1 2], 0, 0;
% '5021/Tx1',50211,[1 2], 0, 0;
% '5023/Tx2',50232,[1 2], 0, 0;
% '5024/Tx1',50241,[1 2], 0, 0;
% '5025/Tx2',50252,[1 2], 0, 0;
% '5026/Tx2',50262,[1 2], 0, 0;
'5028/Tx1',1
'5029/Tx1',1
'5031/Tx1',1
'5032/Tx1',1

% '5034/Tx1',50341,[1 2], 0, 0;
'5034/Tx2',-1
% '5035/Tx1',50351,[1 2], 0, 0;
'5035/Tx2',-1
% '5036/Tx1',50361,[1 2], 0, 0;
'5036/Tx2',-1
% '5037/Tx1',50371,[1 2], 0, 0;
'5037/Tx2',-1
% '5038/Tx1',50381,[1 2], 0, 0;
'5038/Tx2',-1
'5039/Tx1',1

'5040/Tx1',1
% '5040/Tx2',50402,[1 2], 0, 0;
% '5041/Tx1',50411,[1 2], 0, 0;
'5041/Tx2',-1
% '5042/Tx1',50421,[1 2], 0, 0;
'5042/Tx2',-1

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



system(['svm_learn ' outPath ' ~/model -x 1'])
