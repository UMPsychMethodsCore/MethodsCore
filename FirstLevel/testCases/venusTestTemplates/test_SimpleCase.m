clear
%%%

opt.Exp = '/oracle3/Perimenopause/DATA';

opt.ImagePathTemplate = '[Exp]/[Subject]/func/[Run]';

opt.BaseFileSpmFilter = '^sw2mm_ra_spm8_run.*nii';

opt.RunDir = {
'run_05';
'run_06';
'run_07';
};

opt.SubjDir = {
'060828by', 1, [1 2 3];
'060828cg', 2, [1 2 3];
'060830es', 3, [1 2 3];
'060830ss', 4, [1 2 3];
'060920ec', 5, [1 2 3];
'060920la', 6, [1 2 3];
'061012jh', 7, [1 2 3];
'061107ls', 8, [1 2 3];
'061205rr', 9, [1 2 3];
'070220ms', 10, [1 2 3];
'070320lb', 11, [1 2 3];
'070328tg', 12, [1 2 3];
'070418tp', 13, [1 2 3];
'070426mm', 14, [1 2 3];
'070512tb', 15, [1 2 3];
'070522gp', 16, [1 2 3];
'070523pm', 17, [1 2 3];
'070620cp', 18, [1 2 3];
'070625sv', 19, [1 2 3];
'070717rs', 20, [1 2 3];
'070724py', 21, [1 2 3];
'070726mp', 22, [1 2 3];
'070814li', 23, [1 2 3];
'070815mg', 24, [1 2 3];
'070822ah', 25, [1 2 3];
'070911lp', 26, [1 2 3];
'070921je', 27, [1 2 3];
'070924lb', 28, [1 2 3];
'071002ds', 29, [1 2 3];
'071022sc', 30, [1 2 3];
'071113ck', 31, [1 2 3];
'071116lb', 32, [1 2 3];
'071211dh', 33, [1 2 3];
'071221cl', 34, [1 2 3];
'080118dd', 35, [1 2 3];
'080225cc', 36, [1 2 3];
'080321mr', 37, [1 2 3];
'080626ck', 38, [1 2 3];
'080721mk', 39, [1 2 3];
'080808nh', 40, [1 2 3];
'090424tr', 41, [1 2 3];
'090505pg', 42, [1 2 3];
'090608ss', 43, [1 2 3];
'090616lg', 44, [1 2 3];
'090819ad', 45, [1 2 3];
'090821md', 46, [1 2 3];
'090828mi', 47, [1 2 3];
'090917ss', 48, [1 2 3];
'091023bz', 49, [1 2 3];
'091029lf', 50, [1 2 3];
'091113vp', 51, [1 2 3];
'091120dd', 52, [1 2 3];
'091217dd', 53, [1 2 3];
'100118pg', 54, [1 2 3];
'100128eg', 55, [1 2 3];
'100129do', 56, [1 2 3];
'100215sg', 57, [1 2 3];
};


opt.MasterDataFilePath = '/oracle7/Researchers/heffjos/testPeriMen/matlabScripts/MasterDataFiles/DataFile_Perimenopause_Visual.csv';

opt.MasterDataSkipRows = 1;
opt.MasterDataSkipCols = 0;

opt.SubjColumn = 1;
opt.RunColumn = 2;
opt.CondColumn = 3;
opt.TimeColumn = 4;
opt.DurationColumn = 5;


opt.ConditionName = {
    'Match';
    'Delay1';
    'Delay4';
};

opt.ConditionModifier = 0;
opt.ConditionThreshold = 0;
opt.IdenticalModels = 0;
opt.TotalTrials = -1;

opt.ParametricList = {};


opt.RegFilesTemplate = {
'/oracle3/Perimenopause/DATA/[Subject]/func/[Run]/mcflirt_realign_a_spm8_run*.dat', Inf, 0;
};

opt.ContrastList = {
    'D4-M'      -1 0 1 [0 0 0 0 0 0];
    'D4-D1'     0 -1 1 [0 0 0 0 0 0];
    'M'         1 0 0 [0 0 0 0 0 0];
    'D1'        0 1 0 [0 0 0 0 0 0];
    'D4'        0 0 1 [0 0 0 0 0 0];
};

opt.ContrastRunWeights = {
[];
[];
[];
[];
[];
};

opt.TR = 2;
opt.VolumeSpecifier = [];
opt.Basis = 'hrf';
opt.HrfDerivative = 0;

%%%
addpath('/oracle7/Researchers/heffjos/MethodsCore/matlabScripts');
addpath('/oracle7/Researchers/heffjos/MethodsCore/FirstLevel/functions');
%%%

SubjectMasterData = ParseMasterDataFile(opt);

NumSubjects = size(opt.SubjDir, 1);
AllSubjects(NumSubjects) = struct();

for i = 1:NumSubjects

    Subject = opt.SubjDir{i, 1};
    AllSubjects(i).name = Subject;
    NumRuns = length( opt.SubjDir{i, 3} );

    for k = 1:NumRuns

        Run = opt.RunDir{ opt.SubjDir{i, 3}(k) };
        AllSubjects(i).sess(k).name = Run;

        AllSubjects(i).sess(k).images = SetRunImages(i, k, opt);

        AllSubjects(i).sess(k).cond = SetRunConditions(i, k, SubjectMasterData(i).sess(k).RunData, opt);
       
        AllSubjects(i).sess(k).regress = SetRunRegressors(i, k, opt);
        if isempty(AllSubjects(i).sess(k).regress) == 1
            AllSubjects(i).sess(k).useRegress = 0;
        else
            AllSubjects(i).sess(k).useRegress = 1;
        end

        % handle timepoint trimming
        if ~isempty(opt.VolumeSpecifier) == 1 && size(opt.VolumeSpecifier, 2) <= k
            AllSubjects(i).sess(k) = TrimRun(AllSubjects(i).sess(k), i, k, opt);
        end

    end

        % create contrast for whole subject
        AllSubjects(i).contrasts = SetSubjectContrasts(i, opt, AllSubjects(i));
end
