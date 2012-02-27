%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Experiment Directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Exp = '/net/data4/MAS/';  



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% List the run directories that you want to process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RunDir = { 
    
  'run_01/';
  'run_02/'
  'run_03/'
  'run_04/'
  'run_05/'
  'run_06/'
         };
     
     
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Set the needed paths
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

OverlayTemplate = '[Exp]/Subjects/[Subject]/anatomy/OVERLAY.nii';

HiResTemplate =    '[Exp]/Subjects/[Subject]/anatomy/HIRESSAG.nii';

ImageTemplate=    '[Exp]/Subjects/[Subject]/TASK/func/[Run]/';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set the file prefix for the file that you want displayed. In most cases this
%% will be 'ra' for file that has gone through realignment.
%%
%% The program will display the first five scans in the .nii file with this
%% file prefix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
FilePrefix = 'ra';




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



   SubjDir = {

% '5001/Tx2',50012,[1 2];
% '5002/Tx2',50022,[1 2];
% '5003/Tx1',50031,[1 2];
% '5004/Tx1',50041,[1 2];
% '5005/Tx1',50051,[1 2];
% %%%%%%%'5008/Tx1',50081,[1 2];
% '5010/Tx1',50101,[1 2];
% '5011/Tx1',50111,[1 2];
% '5012/Tx1',50121,[1 2];
% %%%%%%%%%%%'5013/Tx2',50132,[1 2];
% '5014/Tx2',50142,[1 2];
% '5015/Tx2',50152,[1 2];
% '5016/Tx1',50161,[1 2];
% '5017/Tx1',50171,[1 2];
% '5018/Tx2',50182,[1 2];
% '5019/Tx1',50191,[1 2];
% '5020/Tx2',50202,[1 2];
% '5021/Tx1',50211,[1 2];
% '5023/Tx2',50232,[1 2];
% '5024/Tx1',50241,[1 2];
% '5025/Tx2',50252,[1 2];
% '5026/Tx2',50262,[1 2];
% '5028/Tx1',50281,[1 2];
% '5029/Tx1',50291,[1 2];
% '5031/Tx1',50311,[1 2];
 '5032/Tx1',50321,[1 2];
'5034/Tx2',50232,[1 2];
'5035/Tx2',50241,[1 2];
'5036/Tx2',50252,[1 2];
'5037/Tx2',50262,[1 2];
'5038/Tx2',50281,[1 2];
'5040/Tx1',50291,[1 2];
'5041/Tx2',50311,[1 2];
'5042/Tx2',50321,[1 2];   
   };
   
   addpath /net/dysthymia/slab/users/sripada/repos/matlabScripts/MethodsCore/QualityChecks/CheckReg
   CheckReg_central
