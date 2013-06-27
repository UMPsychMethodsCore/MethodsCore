function FirstLevelMain(opt)
%   FirstLevelMain(opt)

    fprintf(1, '~~~Checking options~~~\n\n');
    opt = CheckOpt(opt);
    fprintf(1, '~~~Done with options~~~\n\n');

    fprintf(1, '~~~Parsing master data file~~~\n\n');
    SubjectMasterData = ParseMasterDataFile(opt);
    fprintf(1, '~~~Done paring master data file~~~\n\n');

    fprintf(1, '~~~Creating all subjects~~~\n\n');
    Subjects = CreateAllSubjects(opt, SubjectMasterData);
    fprintf(1, '~~~Done creating all subjects~~~\n\n');

    if opt.Mode == 1
        fprintf(1, '~~~Running first level for all subjects~~~\n\n');
        RunFirstLevel(Subjects, opt);
        fprintf(1, '~~~Done running first levels~~~\n');
    elseif opt.Mode == 2
        fprintf(1, '~~~Runing in contrast add-on mode~~~\n\n');
        RunContrastAddOn(Subjects, opt);
        fprintf(1, '~~~Done adding on contrasts~~~\n');
    else
        fprintf(1, '~~~Printing subjects to log file~~~\n');
        PrintAllSubjects(Subjects, opt);
        fprintf(1, '~~~All subjects printed to log file~~~\n');
    end 
    
    fprintf(1, 'Make sure you check your log files!!!\n');
end

function opt = CheckOpt(opt)
% this function does some simple checks and some simple variable updates
    global mcLog

    Exp = opt.Exp;

    % setup log directory
    LogCheck.Template = opt.LogTemplate;
    LogCheck.mode = 'makedir';
    LogDirectory = mc_GenPath(LogCheck);
    mc_Logger('setup', LogDirectory);

    % MasterDataFile checks
    if length(opt.CondColumn) ~= length(opt.TimeColumn) || length(opt.TimeColumn) ~= length(opt.DurationColumn)
        error('Variables CondColumn TimeColumn DurationColumn must all have equal lengths');
    end

    % correct for master data file headers
    opt.SubjColumn = opt.SubjColumn - opt.MasterDataSkipCols;
    opt.RunColumn = opt.RunColumn - opt.MasterDataSkipCols;
    opt.CondColumn = opt.CondColumn - opt.MasterDataSkipCols;
    opt.TimeColumn = opt.TimeColumn - opt.MasterDataSkipCols;
    opt.DurationColumn = opt.DurationColumn - opt.MasterDataSkipCols;

    if any([opt.SubjColumn opt.RunColumn opt.CondColumn opt.TimeColumn opt.DurationColumn] <= 0) == 1
        error('SubjColumn RunColumn CondColumn TimeColumn or DurationColumn are less than zero after correcting for MasterDataSkipCols');
    end

    % do the same for ParametricList if it is being used
    if ~isempty(opt.ParametricList) == 1
    
        NumCond = size(opt.ConditionName, 1);

        for i = 1:size(opt.ParametricList, 1)
    
            opt.ParametricList{i, 2}  = opt.ParametricList{i, 2} - opt.MasterDataSkipCols;
           
            % check valid column number 
            if opt.ParametricList{i, 2} <= 0
                error(['ERROR: The parametric column for parametric regressor %s is less than zero.\nCheck this value and the MasterDataSkipCols variable.\n'], opt.ParametricList{i, 1});
            end

            % check valid polynomial order for the parametric regressor
            if any( opt.ParametricList{i, 4} == [1 2 3 4 5 6] ) == 0
                error(['ERROR: The parametric regressor %s has an invalid polynomial order of %d.  Valid values are 1 2 3 4 5 or 6.'], opt.ParametricList{i, 1}, opt.ParametricList{i, 4});
            end

            % check valid condition number
            if opt.ParametricList{i, 3} <= 0 || opt.ParametricList{i, 3} > NumCond
                error('ERROR: Invalid condition number for parametric regressor %d name %s.  The conditon number must be strictly greater than zero and less than or equal to the number of conditions (%d)', i, opt.ParametricList{i, 1}, NumCond);
            end
            
        end
    end

    % check that specified columns are valid in the master data file
    MasterCheck.Template = opt.MasterDataFilePath;
    MasterCheck.mode = 'check';
    MasterDataFile = mc_GenPath(MasterCheck);

    try
        Data = csvread(MasterDataFile, opt.MasterDataSkipRows, opt.MasterDataSkipCols);
    catch
        error('ERROR: Unable to read the master data file %s.  Check the headers are skipped using MasterDataSkipRows and MasterDataSkipCols.\n  Current values MasterDataSkipRows : %d MasterDataSkipCols %d', MasterDataFile, opt.MasterDataSkipRows, opt.MasterDataSkipCols);
    end

    % check single vector column specifications
    MasterDataCols = size(Data, 2);
    MasterDataRows = size(Data, 1);
    if any(opt.SubjColumn > MasterDataCols) == 1
        error('ERROR: Corrected SubjColumn exceeds columns in master data file.  Columns in master data file: %d', MasterDataCols);
    elseif any(opt.RunColumn > MasterDataCols) == 1
        error('ERROR: Correctued RunColumn exceeds columns in master data file.  Columns in master data file: %d', MasterDataCols');
    elseif any(opt.CondColumn > MasterDataCols) == 1
        error('ERROR: Corrected CondColumn exceeds columns in master data file.  Columns in master data file: %d', MasterDataCols');
    elseif any(opt.TimeColumn > MasterDataCols) == 1
        error('ERROR: Corrected TimeColumn exceeds columns in master data file.  Columns in master data file: %d', MasterDataCols');
    elseif any(opt.DurationColumn > MasterDataCols) == 1
        error('ERROR: Corrected DurationColumn exceeds columns in master data file.  Columns in master data file: %d', MasterDataCols');
    end

    % check parametric columns if any are used
    if ~isempty(opt.ParametricList) == 1
        for i = 1:size(opt.ParametricList, 1)
            if opt.ParametricList{i, 2} > MasterDataCols
                error('ERROR: Parametric regressor #%d name %s user specifiec column in master data file is greater than the number of columns present in the master data file. Columnes in master data file: %d', i, opt.ParametricList{i, 1}, MasterDataCols);
            end
        end
    end

    % handle ConditionModifier
    if opt.ConditionModifier > 0
        
        if opt.ConditionModifier >= size(ConditionName, 1)
            error('ERROR: ConditionModifier should strictly be less than the number of conditions present.');
        end

        opt.ConditionName = opt.ConditionName(1:opt.ConditionModifier);

    end

    % simple check for IdenticalModels and TotalTrials
    if opt.IdenticalModels == 1 && (opt.TotalTrials <= 0 || opt.TotalTrials > MasterDataRows)
        error('When using IdenticalModels, TotalTrials must be a positive value and less than or equal to the number of columns in the mastetr data file %d.', MasterDataCols);
    end

    % handle different bases functions
    if any(strcmp(opt.Basis, {'hrf', 'fir'})) ~= 1
        msg = sprintf(['ERROR: Only valid values for ''Basis'' are ''hrf'' or ''fir''\n']);
        error('%s', msg);
    end
        
    if strcmp(opt.Basis, 'hrf') == 1
        if any(opt.HrfDerivative == [0 1 2]) == 0
            msg = sprintf(['ERROR: When using the canonical basis set, the valid values for ''Base'' are the following:\n\n'...
                   '       0 : CANONICAL ONLY\n' ...
                   '       1 : CANONICAL AND DERIVATIVE\n' ...
                   '       2 : CANONICAL, DERIVATIVE, AND DISPERSION\n' ...
                   ' Your input: %d\n'], opt.HrfDerivative);

            error('%s', msg);
        end
    end

    % handle contrasts
    if (size(opt.ConditionName, 1) + 2) ~= size(opt.ContrastList, 2)
        NumCond = size(opt.ConditionName, 1);
        NumContrastCols = size(opt.ContrastList, 2);
        msg = sprintf(['ERROR: Invalid ContrastList variable.  Expected %d columns but found %d'], NumCond + 2, NumContrastCols);
        error('%s', msg);
    end

    % check contrast vectors are correct
    BasesPerCondition = zeros( size(opt.ConditionName, 1), 1 );
    if strcmp(opt.Basis, 'hrf') == 1
        if opt.HrfDerivative == 0
            opt.NumBases = 1;
        elseif opt.HrfDerivative == 1
            opt.NumBases = 2;
        elseif opt.HrfDerivative == 2
            opt.NumBases = 3;
        else
            error(['Invalid HrfDerivative value.  This should never happen.']);
        end
    elseif strcmp(opt.Basis, 'fir') == 1
        opt.NumBases = opt.FirBins;
    else
        error(['Invalid Basis value.  This should never happen.']);
    end

    BasesPerCondition = BasesPerCondition + opt.NumBases;
    
    for i = 1:size(opt.ParametricList)
        CondNum = opt.ParametricList{i, 3};
        
        BasesPerCondition(CondNum) = BasesPerCondition(CondNum) + opt.NumBases * opt.ParametricList{i, 4};
    end

    for i = 1:size(opt.ContrastList, 1)
        
        for k = 1:length(BasesPerCondition)

            userConditionLength = length(opt.ContrastList{i, k+1});

            if userConditionLength ~= BasesPerCondition(k)
                error(['ERROR: In ContrastList, row %d for condition number %d for condition name %s.\n' ...
                       '       The vector for this condition is invalid.  Expected %d weights but found %d.\n'], ...
                       i, k, opt.ContrastList{k}, BasesPerCondition(k), userConditionLength);
            end

        end
    
    end 

    % handle VolumeSpecifier
    if ~isempty(opt.VolumeSpecifier) == 1
    
        [r c] = size(opt.VolumeSpecifier);
        NumRuns = size(opt.RunDir, 1);

        % make sure has correct number of runs (columns)
        if c ~= NumRuns
            error('VolumeSpecifier has %d columns.  Expected %d columns (equal to number of runs in RunDir)\n', c, NumRuns);
        end

        % make sure has 2 rows
        if r ~= 2
            error('VolumeSpecifier has %d rows.  Expected 2 rows\n', r);
        end

        % make sure both are postive and startIndex < endIndex
        for i = 1:c
            if opt.VolumeSpecifier(1, i) <= 0  || opt.VolumeSpecifier(2, i) <= 0
                error('VolumeSpecifier can only have positive values');
            end
            
            if opt.VolumeSpecifier(1, i) >= opt.VolumeSpecifier(2, i)
                error('The start index in the VolumeSpecifier matrix must be strictly less than the end index.');
            end
        end
    end

    % check contrast run weights if present
    if ~isempty(opt.ContrastRunWeights) == 1

        for i = 1:size(opt.ContrastRunWeights)

            tmp = opt.ContrastRunWeights{i};

            % check to make sure at least one weight equals 1 or -1
            if ~isempty(tmp) && all( tmp(tmp ~= 0) ~= -1 & tmp(tmp ~= 0) ~= 1)
                error('ERROR: Contrast run weight for contrast number %d is invalid.  There must be at least one run coeeficient with weight equal to 1 or -1.', i);
            end

            % give warning if any weight does not equal -1, 0, 1
            if ~isempty(tmp) && any( tmp ~= -1 & tmp ~= 0 & tmp ~= 1 )
                msg = sprintf('Contrast run weight number %d has a weight that is not equal to -1, 0, or 1.  Contrast run weights are intended to work with these coefficients.  Contast number %d may be invalid for all subjects\n\n', i, i);
                fprintf(1, msg);
                mc_Logger('log', msg, 2);
            end

        end

    end

    % fill in contrast run weights if none are present also give warning if too many run weights
    NumMissing = size(opt.ContrastList, 1) - size(opt.ContrastRunWeights, 1);
    if NumMissing > 0
        for i = 1:NumMissing
            opt.ContrastRunWeights{end+1} = [];
        end
    elseif NumMissing < 0
        msg = sprintf('ContrastRunWeights list is longer than ContrastList.  Only the first %d contrast run weights will be used for all subjects.\n\n', size(opt.ContrastList, 1));
        fprintf(1, msg);
        mc_Logger('log', 2, msg);
    end

    % check if explicit mask exists
    if ~isempty(opt.ExplicitMask) == 1 && exist(opt.ExplicitMask, 'file') ~= 2
        error('ExplicitMask %s does not exist.\n', opt.ExplicitMask);
    end

    % check mode
    if opt.Mode == 2
        opt.UseSandbox = 0;
    end

    % handle sandbox
    if (opt.UseSandbox)
        username = getenv('USER');
        pid = num2str(feature('GetPID'));
        [ans hostname] = system('hostname -s');
        [fd fn fe] = fileparts(mcLog);
        opt.Sandbox = fullfile([filesep hostname(1:end-1)],'sandbox',[username '_' pid '_' fn]);
        mc_Logger('log',sprintf('Using sandbox %s',opt.Sandbox),3);
    else
        opt.Sandbox = '';
        mc_Logger('log','Not using sandbox',3);
    end
end
