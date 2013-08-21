clear
%%%
opt.LogTemplate = fullfile(pwd, 'Logs');

opt.Exp = '/zubdata/oracle1/Eureka';

opt.ImagePathTemplate = '[Exp]/[Subject]/dm_func/[Run]/';

opt.BaseFileSpmFilter = '^sw3mmVBM8_rarun.*nii';

opt.RunDir = {
	'run_01';
    'run_02';
    'run_03';
    'run_04';
    'run_05';
	'run_06';
};

opt.SubjDir = {

     'PM103_EUR/Active',1301,[1 2 3 4 5 6];
     'PM103_EUR/Inactive',1032,[1 2 3 4 5];
     'PF104_EUR/Active',1041,[1 2 3 4 5 6];
     % 'PF105_EUR/Active',1051,[1 2 3 4 5];
     % 'PF105_EUR/Inactive',1052,[1 2 3 4 5 6];
     % 'PF106_EUR/Active',1061,[1 2 3 4 5 6];
     % 'PF106_EUR/Inactive',1062,[1 2 3 4 5 6];
     % 'PM107_EUR/Active',1071,[1 2 3 4 5 6];
     % 'PM107_EUR/Inactive',1072,[1 2 3 4 5 6];
     % 'PM108_EUR/Active',1081,[1 2 3 4 5 6];
     % 'PM108_EUR/Inactive',1082,[1 2 3 4 5];
     % 'PF109_EUR/Active',1091,[1 2 3 4 5 6];
     % 'PF109_EUR/Inactive',1092,[1 2 3 4 5 6];
     % 'PF111_EUR/Active',1111,[1 2 3 4 5 6];
     % 'PF111_EUR/Inactive',1112,[1 2 3 4 5 6];
     % 'PF115_EUR/Active',1151,[1 2 3 4 5 6];
     % 'PF115_EUR/Inactive',1152,[1 2 3 4 5];
     % 'PM116_EUR/Active',1161,[1 2 3 4 5 6];
     % 'PM116_EUR/Inactive',1162,[1 2 3 4 5];
     % 'PF117_EUR/Active',1171,[1 2 3 4 5 6];
     % 'PF117_EUR/Inactive',1172,[1 2 3 4 5 6];
     % 'PM118_EUR/Active',1181,[1 2 3 4 5 6];
     % 'PM118_EUR/Inactive',1182,[1 2 3 4 5 6];
     % 'PF119_EUR/Active',1191,[1 2 3 4 5 6];
     % 'PF119_EUR/Inactive',1192,[1 2 3 4 5 6];
     % 'PM120_EUR/Active',1201,[1 2 3 4 5 6];
     % 'PM120_EUR/Inactive',1202,[1 2 3 4 5 6];
     % 'PF121_EUR/Active',1211,[1 2 3 4 5 6];
     % 'PF121_EUR/Inactive',1212,[1 2 3 4 5 6];
     % 'PF122_EUR/Active',1221,[1 2 3 4 5 6];
     % 'PF122_EUR/Inactive',1222,[1 2 3 4 5 6];
     % 'PF123_EUR/Active',1231,[1 2 3 4 5 6];
     % 'PF123_EUR/Inactive',1232,[1 2 3 4 5 6];
     % 'PF125_EUR/Active',1251,[1 2 3 4 5];
     % 'PF125_EUR/Inactive',1252,[1 2 3 4 5 6];
     % 'PM128_EUR/Active',1281,[1 2 3 4 5 6];
     % 'PM128_EUR/Inactive',1282,[1 2 3 4 5 6];
     % 'PF129_EUR/Active',1291,[1 2 3 4 5 6];
     % 'PF129_EUR/Inactive',1292,[1 2 3 4 5 6];
     % 'PF130_EUR/Active',1301,[1 2 3 4 5 6];
     % 'PF130_EUR/Inactive',1302,[1 2 3 4 5 6];
     % 'PM131_EUR/Active',1311,[1 2 3 4 5 6];
     % 'PM131_EUR/Inactive',1312,[1 2 3 4 5 6];
     % 'PF132_EUR/Active',1321,[1 2 3 4 5 6];
     % 'PF132_EUR/Inactive',1322,[1 2 3 4 5 6];
};


opt.MasterDataFilePath = fullfile(pwd, 'MasterDataFiles/EurekaDM_Master.csv');

opt.MasterDataSkipRows = 2;
opt.MasterDataSkipCols = 0;

opt.SubjColumn = 1;
opt.RunColumn = 2;
opt.CondColumn = 5;
opt.TimeColumn = 11;
opt.DurationColumn = 10;


opt.ConditionName = {
    'Draws1234_UncertDecks';
    'Draws1234_Cont';
    'Pick_UncertDecks';
    'Pick_Cont';
    'Feedback_All';
};

opt.ConditionModifier = 0;
opt.ConditionThreshold = 0;
opt.IdenticalModels = 0;
opt.TotalTrials = -1;

% name column condition order
opt.ParametricList = {
    'Cov_PostProb_JNeuroModel1',12,1,2;
};


opt.RegFilesTemplate = {
'[Exp]/[Subject]/dm_func/[Run]/mcflirt*.dat', Inf, 0;
};

opt.ContrastList = {
'UncertDraw_PostProb_Pos' [0 1 0] 0 0 0 0 [0 0 0 0 0 0];
'UncertDraw_PostProb_Neg' [0 -1 0] 0 0 0 0 [0 0 0 0 0 0];
};

opt.ContrastRunWeights = {
[];
[];
};

opt.TR = 2;
opt.VolumeSpecifier = [];
opt.Basis = 'hrf';
opt.HrfDerivative = 0;

opt.fMRI_T0 = 8;
opt.ScaleOp = 'none';
opt.ExplicitMask = '';
opt.usear1 = 1;
opt.Mode = 1;
opt.UseSandbox = 0;

opt.OutputDir = '/oracle7/Researchers/heffjos/MethodsCore/FirstLevel/testCases/FirstLevelTests/OneParametric/[Subject]';

%%%
addpath('/oracle7/Researchers/heffjos/MethodsCore/matlabScripts');
addpath('/oracle7/Researchers/heffjos/MethodsCore/FirstLevel/functions');
%%%

global mcRoot;
mcRoot = '/oracle7/Researchers/heffjos/MethodsCore';



FirstLevelMain(opt);
