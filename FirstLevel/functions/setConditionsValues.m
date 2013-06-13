function subjectInfo = setConditionsValues(opt, subjectInfo)
%   subjectInfo = setConditionValues(opt, subjectInfo)
%
%   REQUIRED INPUT
%
%       opt.
%           Exp                 - string
%           SubjDir             - cell(N, 3)
%                                 column1 = subject name
%                                 column2 = subject number in master data file
%                                 column3 = vector of runs to include
%           RunDir              - cell(R, 1), list of run folders
%           MasterDataFilePath  - string, path to master data file
%                                 templates permitted : [Exp]
%           MasterDataSkipRows  - number of rows to skip in master data file
%           MasterDataSkipCols  - number of columns to skip in master data file
%           SubjColumn          - vector
%           RunColumn           - vector
%           CondColumn          - vector
%           TimeColumn          - vector
%           DurationColumn      - vector
%           ConditionName       - cell(M, 1) list of conditions as strings
%           ParametricList      - cell(P, 4)
%                                 column1 = paramatric name
%                                 column2 = column in master data file
%                                 column3 = condition number as listed in ConditionName
%                                 column4 = order
%
%   OPTIONAL INPUT
%
%           ConditionModifier   - scalar, remove these last conditions from the model
%           ConditionThreshold  - scalar, removes conditions that do not exceed this threshold
%           IdenticalModels     - scalar, if equals 1, all subjects have the same model specs
%           TotalTrials         - scalar, indicates total number of trials if IdenticalModels is
%                                 used
%
%   OUTPUT
%
%       subjectInfo(1, N)
%           sess(1, Y).
%               cond(1, Z).
%                   use         - scalar, a value of 1 indicates to use this
%                   usePMod     - scalar, a value of 1 indicates this condition has parametric
%                                 regressors
%                   name        - string, condition name
%                   onset       - vector, list of condition onsets
%                   duration    - vector, duration of onsets
%                   pmod(1, P).
%                       name    - string, parametric regressor name
%                       param   - vector, values
%                       poly    - scalar, polynomial order to use
%
%   N = number of subjects
%   Y = number of sessions
%   M = number of conditions
%   P = number of parametric regressors
%   Z = number of conditions
%
%   If not using optional input, input value as an empty matrix or don't ....
%

    % check existence of optional inputs
    if ~isfield(opt, 'ConditionModifier') == 1
        opt.ConditionModifier = 0;
    end

    if ~isfield(opt, 'ConditionThreshold') == 1
        opt.ConditionThreshold = 0;
    end

    if ~isfield(opt, 'IdenticalModels') == 1
        opt.IdenticalModels = 0;
    else
        if ~isfield(opt, 'TotalTrials') == 1 || opt.TotalTrials <= 0
            error('ERROR: When using IdenticalModels, TotalTrials variable must be specified and greater than zero');
        end
    end

    % let's do some simple checks first and variable update
    if length(opt.CondColumn) ~= length(opt.TimeColumn) || length(opt.TimeColumn) ~= length(opt.DurationColumn)
        error('Variables CondColumn TimeColumn DurationColumn must all have equal lengths');
    end

    % handle master data file
    Exp = opt.Exp;
    MasterDataFileCheck.Template = opt.MasterDataFilePath;
    MasterDataFileCheck.Mode = 'check';
    MasterDataFile = mc_GenPath(MasterDataFileCheck);

    try
        AllData = csvread(MasterDataFile, opt.MasterDataSkipRows, opt.MasterDataSkipCols);
    catch
        error(['ERROR: Unable to read master data file successfully.\n' ...
               '       Check variables MasterDataSkipRows MasterDataSkipColumns%s'],'');
    end

    % correct for headers and ensure corrrection was good
    opt.SubjColumn = opt.SubjColumn - opt.MasterDataSkipCols;
    opt.RunColumn = opt.RunColumn - opt.MasterDataSkipCols;
    opt.CondColumn = opt.CondColumn - opt.MasterDataSkipCols;
    opt.TimeColumn = opt.TimeColumn - opt.MasterDataSkipCols;
    opt.DurationColumn = opt.DurationColumn - opt.MasterDataSkipCols;
    if ~isempty(opt.ParametricList) == 1
        for i = 1:size(opt.ParametricList, 1)
            opt.ParamtericList{i, 2}  = opt.ParamtericList{i, 2} - opt.MasterDataSkipCols;
            if opt.ParametricList{i, 2} <= 0
                error(['ERROR: The parametric column for parametric regressor %s is less than zero.\n' ...
                       '       Check this value and the MasterDataSkipCols variable.\n'], opt.ParametricList{i, 1});
            end
        end
    end

    if any([opt.SubjColumn opt.RunColumn opt.CondColumn opt.TimeColumn opt.DurationColumn] <= 0)
        error('ERROR: SubjColumn RunColumn CondColumn TimeColumn or DurationColumn is less than zero.  Check these variables and MasterDataSkipCols variable.');
    end

    if any([opt.SubjColumn opt.RunColumn opt.CondColumn opt.TimeColumn opt.DurationColumn] > size(AllData, 2))
        error(['ERROR: SubjColumn RunColumn CondColumn TimeColumn DurationColumn values must be less than' ...
               'the number of columns in the MasterDataFile after removing SkipRows and SkipColumns']);
    end

    % do a simple check to make sure times and durations are not in milliseconds
    for i = 1:length(opt.TimeColumn)
    
        if any( AllData(:, opt.TimeColumn(i)) ) > 5000
            error(['ERROR: Detected TimeColumn %d has a value greater than 5000.\n' ...
                          'Expected timing to be in seconds.'], i);
        end

        if any( AllData(:, opt.DurationColumn(i)) ) > 5000
            error(['ERROR: Detected DurationColumn %d has a value greater than 5000.\n' ...
                          'Expected timing to be in seconds.'], i);
        end

    end

    % handle ConditionModifier
    if opt.ConditionModifier > 0
        
        if opt.ConditionModifier > size(ConditionName, 1)
            error('ERROR: ConditionModifier should be less than the number of conditions present.');
        end

        opt.ConditionName = opt.ConditionName(1:opt.ConditionModifier);

    end

        
    % now let's start building the conditions into subjectInfo
    numSubjects = size(opt.SubjDir, 1);
    for i = 1:numSubjects

        if opt.IdenticalModels == 1
            SubjectData = AllData(1:opt.TotalTrials, :);
        else
            SubjectIndex = AllData(:, opt.SubjColumn) == opt.SubjDir{i, 2};
            SubjectData = AllData(SubjectIndex, :);
        end

        NumRuns = length( opt.SubjDir{i, 2} );

        for k = 1:NumRuns

            RunIndex = SubjectData(:, opt.RunColumn) == opt.SubjDir{i, 3}(k);
            RunData = SubjectData(RunIndex, :); 

            % manage condtions
            for l = 1:size(opt.ConditionName, 1)

                subjectInfo(i).sess(k).cond(l).name = opt.ConditionName{l};
                subjectInfo(i).sess(k).cond(l).onset = [];
                subjectInfo(i).sess(k).cond(l).duration = [];
                subjectInfo(i).sess(k).cond(l).use = 1;
                subjectInfo(i).sess(k).cond(l).usePMod = 0;

                for m = 1:length(opt.CondColumn)

                    CondIndex = RunData(:, opt.CondColumn(m)) == l;
                    CondOnsets = RunData(CondIndex, opt.TimeColumn(m));
                    subjectInfo(i).sess(k).cond(l).onset(end+1:end+length(CondOnsets)) = CondOnsets;
                    CondDurations = RunData(CondIndex, opt.DurationColumn);
                    subjectInfo(i).sess(k).cond(l).duration(end+1:end+length(CondDurations)) = CondDurations;
                end

                % check if condition is useable for the run
                if length( subjectInfo(i).sess(k).cond(l).onset ) < opt.ConditionThreshold || ...
                   isempty( subjectInfo(i).sess(k).cond(l).onset ) == 1

                    subjectInfo(i).sess(k).cond(l).use = 0;

                    % Log this information
                    msg = sprintf(['Omitting condition %s for subject %s run %s.\n' ...
                                   'Condition was either not present in the master date file or' ...
                                   'did not exceed the ConditionThreshold.\n\n'], ...
                                   opt.ConditionName{l}, opt.SubjDir{i, 1}, ...
                                   opt.RunDir{ opt.SubjDir{i, 2}(k) });

                    fprintf(1, msg);
                    mc_Logger('log', msg, 2);
                end
                %end of managing conditions
            end

            % manage parametric regressors
            if ~isempty(opt.ParametricList) == 1

                for iPar = 1:size(opt.ParametricList, 1)

                    CondForPar = opt.ParametricList{iPar, 3};

                    % check if corresponding condition is actually being used
                    if subjectInfo(i).sess(k).cond(CondForPar).use == 0

                        msg = sprintf(['Omitting parametric regressor %s for condition %s for' ...
                                       'subject %s run %s.\n  The corresponding condition is' ...
                                       'not in this run.\n\n']);

                        fprintf(1, msg);
                        mc_Logger('log', msg, 2);
                        continue;
                    end

                    subjectInfo(i).sess(k).cond(CondForPar).usePMod = 1;
                    subjectInfo(i).sess(k).cond(condForPar).name = opt.ParametricList{iPar, 1};
                    subjectInfo(i).sess(k).cond(condForPar).poly = opt.ParametricList{iPar, 4};

                    % now assign parametric values based on the number of CondColumns present.
                    % If CondColumn > 1, use the parametric regressors in the column assigned
                    % to it at each column where it equals the corresponding condition number.
                    if length(opt.CondColumn) == 1
                       
                        % easy case :) 
                        CondIndex = RunData(:, opt.CondColumn) == CondForPar;
                        subjectInfo(i).sess(k).cond(condForPar).param = RunData(CondIndex, opt.ParametricList{iPar, 2});
                    else

                        % now we have to cycle through each condition and log usage
                        CondIndex = false(size(RunIndex, 1), 1);

                        msg = sprintf(['Parametric regressor %s is being used with condition' ...
                                       '%d from columns '], opt.ParametricList{iPar, 1}, CondForPar);

                        for iCondCol = 1:legnth(opt.CondColumn)
                            tmpIndex = RunData(:, opt.CondColumn(iCondCol)) == CondForPar;
                            CondIndex = CondIndex | tmpIndex;
                            msg = strcat(msg, sprintf('%d ', opt.CondColumn(iCondCol)));
                        end

                        msg = strcat(msg, sprintf('in the Master Data File'\n'));
                        fprintf(1, msg);
                        mc_Logger('log', msg, 3);

                        subjectInfo(i).sess(k).cond(condForPar).param = RunData(CondIndex, opt.ParametricList{iPar, 2});

                    end
                    % end of managing parametric list
                end
            end
            
            % end for run
        end

        % end for subject
    end
end
