


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
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Number of Functional scans per run
%%% (if you have more than 1 run, there should be more than 1 value here)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
NumScan = [70 70]; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path where the motion correction parameter files are located
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

MotionPathTemplate = '[Exp]/Subjects/[Subject]/TASK/func/[Run]/rp_arun_*';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Name and path for your output file (leave off the .csv)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputName = 'MAS_motionregressors';
OutputPathTemplate = '[Exp]/MasterData/[OutputName]';



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects to process
%%% col 1 = subject id as string, col 2 = subject id as number, col 3 = runs that are present (this lets you omit missing runs for a subject)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjDir = {

'5001/Tx1',50011,[1];
 '5002/Tx1',50021,[1];
'5003/Tx1',50031,[1];
'5004/Tx1',50041,[1];
'5005/Tx1',50051,[1 ];
%%%%%%%'5008/Tx1',50081,[1 2];
'5010/Tx1',50101,[1];
'5011/Tx1',50111,[1];
'5012/Tx1',50121,[1];
%%%%%%%%%%%'5013/Tx2',50132,[1 2];
'5014/Tx1',50141,[1];
'5015/Tx1',50151,[1];
'5016/Tx1',50161,[1];
'5017/Tx1',50171,[1];
'5018/Tx1',50181,[1];
'5019/Tx1',50191,[1];
'5020/Tx1',50201,[1];
'5021/Tx1',50211,[1];
'5023/Tx1',50231,[1];
'5024/Tx1',50241,[1];
'5025/Tx1',50251,[1];
'5026/Tx1',50261,[1];
'5028/Tx1',50281,[1];
'5029/Tx1',50291,[1];
'5031/Tx1',50311,[1];
'5032/Tx1',50321,[1];

   };
   








addpath /net/dysthymia/slab/users/sripada/repos/matlabScripts/MethodsCore/MotionRegressors/
MVMT_collapse_central