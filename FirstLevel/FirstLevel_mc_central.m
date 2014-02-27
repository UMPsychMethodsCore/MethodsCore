
% check for using older first level template file
if exist('TimColumn', 'var') == 1
    addpath(fullfile(mcRoot, 'FirstLevel/functions/OldFirstLevel'));
    OldFirstLevel_mc_central
else
    try
        % set opt values
        opt.Exp = Exp;
        opt.SubjDir = SubjDir;
        opt.RunDir = RunDir;
    
        opt.ImagePathTemplate = ImagePathTemplate;
        opt.BaseFileSpmFilter = BaseFileSpmFilter;
        
        opt.MasterDataFilePath = MasterDataFilePath;
        opt.SubjColumn = SubjColumn;
        opt.RunColumn = RunColumn;
        opt.CondColumn  = CondColumn;
        opt.TimeColumn = TimeColumn;
        opt.DurationColumn = DurationColumn;
        opt.ConditionName = ConditionName;
        opt.ConditionModifier = ConditionModifier;
        opt.ConditionThreshold = ConditionThreshold;
        opt.IdenticalModels = IdenticalModels;
        opt.TotalTrials = TotalTrials;
        opt.ParametricList = ParametricList;
    
        opt.RegFilesTemplate = RegFilesTemplate;
        
        opt.ContrastList = ContrastList;
        opt.ContrastRunWeights = ContrastRunWeights;
    
        opt.LogTemplate = LogTemplate;
        opt.Mode = Mode;
        opt.UseSandBox = UseSandbox;
    
        opt.OutputDir = OutputDir;
    
        opt.TR = TR;
        opt.fMRI_T0 = fMRI_T0;
        opt.VolumeSpecifier = VolumeSpecifier;
        opt.usear1 = usear1;
        opt.ScaleOp = ScaleOp;
        opt.ExplicitMask = ExplicitMask;
        opt.StartOp = StartOp;
        opt.SpmDefaults = spmdefaults;
    
        opt.Basis = Basis;
        if strcmp(opt.Basis, 'hrf') == 1
            opt.HrfDerivative = HrfDerivative;
        elseif strcmp(opt.Basis, 'fir') == 1
            opt.FirDuration = FirDuration;
            opt.FirBins = FirBins;
            opt.FirDoContrasts = FirDoContrasts;
        end
    
        opt.UseSandbox = UseSandbox;
        opt.CompCorTemplate = CompCorTemplate;
    catch err
        
        msg = sprintf('Not all required variables were assigned in the template file.\n');
        msg2 = sprintf('Make sure you have the most recent copy of the first level template file.\n\n');
        error('%s%s%s', msg, msg2, err.message);
    
    end
        
    FirstLevelMain(opt);
end
