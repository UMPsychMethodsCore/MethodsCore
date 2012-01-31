

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Experiment Directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Exp = '/net/data4/CCMB08/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% List all your run directories
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RunDir = { 
    
  'Rest_run1/';
   
         };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Path where the motion correction parameter files are located
%%
%%  Variables you can use in your template are:
%%   Exp = path to your experiment directory
%%   iSubject = index for subject
%%   Subject = name of subject from SubjDir (using iSubject as index of row)
%%   iRun = index of run (listed in Column 3 of SubjDir)
%%   Run = name of run from RunDir (using iRun as index of row)
%%   
%% Examples:
%% MotionPathTemplate = '[*Exp]/Subjects/[*Subject]/func/[*Run]/realign.dat';
%% MotionPathTemplate = '[*Exp]/Subjects/[*Subject]/TASK/func/run_0[*iRun]/rp_arun_[*iRun].txt'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



MotionPathTemplate = '[*Exp]/Subjects/[*Subject]/func/[*Run]/realign.dat';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Name and path for your output file (leave off the .csv)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OutputName = 'RestingState_b';
OutputPathTemplate = '[*Exp]/Output/Motion/[*OutputName]';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Lever arm (typically between 50-100mm)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LeverArm = 75;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% The list of subjects 
%%% col 1 = subject id as string, col 2 = subject id as number, col 3 = runs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SubjDir = {

% '5001/Tx2',50012,[1];
% '5002/Tx2',50022,[1];
% '5003/Tx1',50031,[1];

'CC01',1,[1];
'CC04',2,[1];
'CC06',3,[1];
'CC12',4,[1];
'CC13',5,[1];
'CC17',6,[1]; 
'CC18',7,[1];
'CC19',8,[1];
'CC21',9,[1];
'CC22',10,[1];
'CC23',11,[1];
'CC24',12,[1];
'CC25',13,[1]; 
'CC26',14,[1]; 
'HC03',15,[1];
'HC04',16,[1];
'HC05',17,[1];
'HC06',18,[1];
'HC07',19,[1];
'HC08',20,[1];
'HC12',21,[1];
'HC13',22,[1];
'HC14',23,[1];
'HC15',24,[1];
'HC16',25,[1];
'HC23',26,[1];
'HC25',27,[1]; 
'HC26',28,[1];
'PT01',29,[1];
'PT02',30,[1];
'PT05',31,[1];
'PT06',32,[1];
'PT07',33,[1];
'PT08',34,[1];
'PT09',35,[1];
'PT10',36,[1];
'PT12',37,[1]; 
'PT15',38,[1];
'PT16',39,[1];
'PT19',40,[1];
'PT23',41,[1];
'PT24',42,[1]; 
'PT26',43,[1];
'PT27',44,[1];


   };
   

addpath /net/dysthymia/slab/users/sripada/repos/matlabScripts/MethodsCore/MotionSummary/
MotionSummary_central