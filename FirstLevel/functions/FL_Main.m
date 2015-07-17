function FL_Main(opt)
%   FL_Main(opt)

    fprintf(1, '~~~Checking options~~~\n\n');
    opt = CheckOpt(opt);
    fprintf(1, '~~~Done with options~~~\n\n');

    fprintf(1, '~~~Parsing master data file~~~\n\n');
    [SubjectMasterData opt] = FL_ParseMasterDataFile(opt);
    fprintf(1, '~~~Done paring master data file~~~\n\n');

    fprintf(1, '~~~Creating all subjects~~~\n\n');
    Subjects = FL_CreateAllSubjects(opt, SubjectMasterData);
    fprintf(1, '~~~Done creating all subjects~~~\n\n');

    if opt.Mode == 1
        fprintf(1, '~~~Running first level for all subjects~~~\n\n');
        FL_Run(Subjects, opt);
        FL_PrintAllSubjects(Subjects, opt);
        fprintf(1, '~~~Done running first levels~~~\n');
    elseif opt.Mode == 2
        fprintf(1, '~~~Runing in contrast add-on mode~~~\n\n');
        FL_RunContrastAddOn(Subjects, opt);
        fprintf(1, '~~~Done adding on contrasts~~~\n');
    else
        fprintf(1, '~~~Printing subjects to log file~~~\n');
        FL_PrintAllSubjects(Subjects, opt);
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

    % check run numbers are valid for each subject
    NumRuns = size(opt.RunDir, 1);
    for i = 1:size(opt.SubjDir, 1)
        SubjectRuns = opt.SubjDir{i, 2};
        if any(SubjectRuns > NumRuns)
            error('Subject %s : Runs to include exceed the number of possible runs.', opt.SubjDir{i, 1});
        end
    end

    % MasterDataFile checks
    if length(opt.CondColumn) ~= length(opt.TimeColumn) || length(opt.TimeColumn) ~= length(opt.DurationColumn)
        error('Variables CondColumn TimeColumn DurationColumn must all have equal lengths');
    end

    % ParametricList checks
    if ~isempty(opt.ParametricList) == 1
    
        NumCond = size(opt.ConditionName, 1);

        for i = 1:size(opt.ParametricList, 1)
    
            % check valid polynomial order for the parametric regressor
            if any( opt.ParametricList{i, 4} == [1 2 3 4 5 6] ) == 0
                error(['ERROR: The parametric regressor %s has an invalid polynomial order of %d.  Valid values are 1 2 3 4 5 or 6.'], opt.ParametricList{i, 1}, opt.ParametricList{i, 4});
            end

            % check valid condition number
            if any(opt.ParametricList{i, 3} <= 0) || any(opt.ParametricList{i, 3} > NumCond)
                error('ERROR: Invalid condition number for parametric regressor %d name %s.  The conditon number must be strictly greater than zero and less than or equal to the number of conditions (%d)', i, opt.ParametricList{i, 1}, NumCond);
            end
            
        end
    end

    % simple check for IdenticalModels and TotalTrials
    if opt.IdenticalModels == 1 && opt.TotalTrials <= 0
        error('When using IdenticalModels, TotalTrials must be a positive value.');
    end

    % handle RegFilesTemplate
    NumRegFiles = size(opt.RegFilesTemplate, 1);
    for i = 1:NumRegFiles
        if opt.RegFilesTemplate{i, 4} < 1
            msg = sprintf(['ERROR: Invalid polynomial expansion option for RegFile %s.  Expected a value >= 1, but found %d'], opt.RegFilesTemplate{i, 1}, opt.RegFilesTemplate{i, 4});
            error('%s', msg);
        end
    end

    % handle different bases functions
    if any(strcmp(opt.Basis, {'hrf', 'fir'})) ~= 1
        msg = sprintf(['ERROR: Only valid values for ''Basis'' are ''hrf'' or ''fir''']);
        error('%s', msg);
    end
        
    if strcmp(opt.Basis, 'hrf') == 1
        if any(opt.HrfDerivative == [0 1 2]) == 0
            msg = sprintf(['ERROR: When using the canonical basis set, the valid values for ''Basis'' are the following:\n'...
                           '       0 : CANONICAL ONLY\n' ...
                           '       1 : CANONICAL AND DERIVATIVE\n' ...
                           '       2 : CANONICAL, DERIVATIVE, AND DISPERSION\n' ...
                           ' Your input: %d'], opt.HrfDerivative);

            error('%s', msg);
        end
    end

    % handle contrasts
    if opt.VarianceWeighting == 0
        if (size(opt.ConditionName, 1) + 2) ~= size(opt.ContrastList, 2) && (strcmp(opt.Basis, 'fir') == 0 || opt.FirDoContrasts ~= 1)
            NumCond = size(opt.ConditionName, 1);
            NumContrastCols = size(opt.ContrastList, 2);
            msg = sprintf(['ERROR: Invalid ContrastList variable. Expected %d columns but found %d'], NumCond + 2, NumContrastCols);
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
                error(['Invalid HrfDerivative value. This should never happen.']);
            end
        elseif strcmp(opt.Basis, 'fir') == 1
            opt.NumBases = opt.FirBins;
        else
            error(['Invalid Basis value. This should never happen.']);
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
                           '       The vector for this condition is invalid.  Expected %d weights but found %d.'], ...
                           i, k, opt.ContrastList{k}, BasesPerCondition(k), userConditionLength);
                end

            end
        
        end 

        % using BasesPerCondition let's make FIR contrast list if we need to
        if strcmp(opt.Basis, 'fir') == 1 && opt.FirDoContrasts == 1
            DummyRow = cell(1, length(BasesPerCondition) + 1);
            for i = 1:length(BasesPerCondition)
                DummyRow{1, i} = zeros(1, BasesPerCondition(i));
            end

            for i = 1:length(BasesPerCondition)
                for k = 1:opt.FirBins
                    InsertRow = DummyRow;
                    InsertRow{1, i}(k) = 1;
                    TmpCondName = sprintf('%sBin%02d', opt.ConditionName{i}, k);
                    InsertRow = [TmpCondName InsertRow];
                    opt.ContrastList = [opt.ContrastList; InsertRow];
                end
            end
        end
    end

    % handle VolumeSpecifier
    if ~isempty(opt.VolumeSpecifier) == 1
    
        [r c] = size(opt.VolumeSpecifier);
        NumRuns = size(opt.RunDir, 1);

        % make sure has correct number of runs (columns)
        if c ~= NumRuns
            error('VolumeSpecifier has %d columns.  Expected %d columns (equal to number of runs in RunDir)', c, NumRuns);
        end

        % make sure has 2 rows
        if r ~= 2
            error('VolumeSpecifier has %d rows.  Expected 2 rows', r);
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
