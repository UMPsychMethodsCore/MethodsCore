

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Experiment Directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Exp = '/net/data4/MAS/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% List all your run directories
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RunDir = { 
    
  'run_01/';
  'run_02/';
  'run_03/';
  'run_04/';
  'run_05/';
  'run_06/';
         };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Path where the motion correction parameter files are located
%%
%%  Variables you can use in your template are:
%%       Exp = path to your experiment directory
%%       iSubject = index for subject
%%       Subject = name of subject from SubjDir (using iSubject as index of row)
%%       iRun = index of run (listed in Column 3 of SubjDir)
%%       Run = name of run from RunDir (using iRun as index of row)
%%        * = wildcard (can only be placed in final part of template)
%% Examples:
%% MotionPathTemplate = '[Exp]/Subjects/[Subject]/func/run_0[iRun]/realign.dat';
%% MotionPathTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/rp_arun_*.txt'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MotionPathTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/rp_arun_*.txt';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Name and path for your output file (leave off the .csv)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputName = 'RestingState_c';
OutputPathTemplate = '[Exp]/Output/Motion/[OutputName]';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Lever arm (typically between 50-100mm)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LeverArm = 75;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects 
%%% col 1 = subject id as string, col 2 = subject id as number, col 3 = runs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


SubjDir = {

 '5001/Tx1',50011,[1],[215 235], 0; 
 '5002/Tx1',50021,[1],[225 240], 0;
'5003/Tx1',50031,[1], [225 240], 0;
'5004/Tx1',50041,[1], 0, 0;
'5005/Tx1',50051,[1 ], 0, 0;
%%%%%%'5008/Tx1',50081,[1 2], 0, 0;
'5010/Tx1',50101,[1], 0, 0;
'5011/Tx1',50111,[1], 0, 0;
'5012/Tx1',50121,[1], 0, 0; 
%%%%%%%%%%'5013/Tx2',50132,[1 2], 0, 0;
'5014/Tx1',50141,[1], 0, 0; 
'5015/Tx1',50151,[1], 0, 0;
'5016/Tx1',50161,[1], 0, 0;
'5017/Tx1',50171,[1], 0, 0;
'5018/Tx1',50181,[1], 0, 0;
'5019/Tx1',50191,[1], 0, 0;
'5020/Tx1',50201,[1], 0, 0;
'5021/Tx1',50211,[1], 0, 0;
'5023/Tx1',50231,[1], 0, 0;
'5024/Tx1',50241,[1], 0, 0;
'5025/Tx1',50251,[1], 0, 0;
'5026/Tx1',50261,[1], 0, 0;
'5028/Tx1',50281,[1], 0, 0;
'5029/Tx1',50291,[1], 0, 0;
'5031/Tx1',50311,[1], 0, 0;
'5032/Tx1',50321,[1], 0, 0;
%'5034/Tx1',50232,[1], 0, 0; not preprocessed
'5035/Tx1',50241,[1], 0, 0;
'5036/Tx1',50252,[1], 0, 0;
'5037/Tx1',50262,[1], 0, 0;
'5038/Tx1',50281,[1], 0, 0;
'5040/Tx1',50291,[1], 0, 0;
'5041/Tx1',50311,[1], 0, 0;
'5042/Tx1',50321,[1], 0, 0;


'5001/Tx2',50012,[1],[215 235], 0; 
 '5002/Tx2',50022,[1],[225 240], 0;
'5003/Tx2',50032,[1], [225 240], 0;
'5004/Tx2',50042,[1], 0, 0;
'5005/Tx2',50052,[1], 0, 0;
%%%%%%'5008/Tx1',50081,[1], 0, 0;
'5010/Tx2',50102,[1], 0, 0;
'5011/Tx2',50112,[1], 0, 0;
'5012/Tx2',50122,[1], 0, 0; 
%%%%%%%%%%'5013/Tx2',50132,[1], 0, 0;
'5014/Tx2',50142,[1], 0, 0;
'5015/Tx2',50152,[1], 0, 0;
'5016/Tx2',50162,[1], 0, 0;
'5017/Tx2',50172,[1], 0, 0;
'5018/Tx2',50182,[1], 0, 0;
'5019/Tx2',50192,[1], 0, 0;
'5020/Tx2',50202,[1], 0, 0;
'5021/Tx2',50212,[1], 0, 0;
'5023/Tx2',50232,[1], 0, 0;
'5024/Tx2',50242,[1], 0, 0;
'5025/Tx2',50252,[1], 0, 0;
'5026/Tx2',50262,[1], 0, 0;
'5028/Tx2',50282,[1], 0, 0;
'5029/Tx2',50292,[1], 0, 0;
'5031/Tx2',50312,[1], 0, 0;
'5032/Tx2',50322,[1], 0, 0;
%'5034/Tx2',50232,[1], 0, 0; not preprocessed
'5035/Tx2',50241,[1], 0, 0;
'5036/Tx2',50252,[1], 0, 0;
 '5037/Tx2',50262,[1], 0, 0;
 '5038/Tx2',50281,[1], 0, 0;
'5040/Tx2',50291,[1], 0, 0;
'5041/Tx2',50311,[1], 0, 0;
'5042/Tx2',50321,[1], 0, 0; 
   }
%DEVSTART
mcRoot = fullfile(fileparts(mfilename('fullpath')),'..')
%DEVSTOP

%[DEVmcRootAssign]

addpath(fullfile(mcRoot,'matlabScripts'))
addpath(fullfile(mcRoot,'MotionSummary'))
addpath(fullfile(mcRoot,'spm8'))
   
MotionSummary_central