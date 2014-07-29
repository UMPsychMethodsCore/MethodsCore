function RunConditions = FL_SetRunConditions(SubjectNumber, RunNumber, RunData, opt)
%   RunConditions = FL_SetRunConditions(SubjectNumber, RunNumber, SubjectMasterData, opt)
%
%   REQUIRED INPUT
%
%       opt.
%           Exp                 - string
%           SubjDir             - cell(N, 2)
%                                 column1 = subject name
%                                 column2 = vector of runs to include
%           RunDir              - cell(R, 1), list of run folders
%           MasterDataFilePath  - string, path to master data file
%                                 templates permitted : [Exp]
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
%   OUTPUT
%       
%       cond(Z).
%           use         - scalar, a value of 1 indicates to use this
%           usePMod     - scalar, counts the number of parametric regressors used for condition
%           name        - string, condition name
%           onset       - vector, list of condition onsets
%           duration    - vector, duration of onsets
%           pmod(P).
%               name    - string, parametric regressor name
%               param   - vector, values
%               poly    - scalar, polynomial order to use
%
%   N = number of subjects
%   Y = number of sessions
%   M = number of conditions
%   P = number of parametric regressors
%   Z = number of conditions
%
% This function assigns the conditions for a subject's single run.
% NOTE: CondColumn, TimeColumn, and DurationColumn can be vectors.  If they are vectors, each are
% associated to each other by the column index.  For instance, the conditions in CondColumn(1)
% have onsets at TimeColumn(1) and duration DurationColumn(1), CondColumn(2) have onsets at 
% TimeColumn(2) and durations DurationColumn(2), etc.  If parametric regressors are present,
% then the condition number assigned to the parametric regressor is searched in each CondColumn 
% and is used for each column where the condition number is present.
% 

    NumCond = size(opt.ConditionName, 1);
    
    % include a check for zero conditions -- this is for PPI
    if NumCond == 0
        RunConditions = [];
        return;
    end

    RunConditions(NumCond) = struct();
    Subject = opt.SubjDir{SubjectNumber, 1};
    Run = opt.RunDir{RunNumber};
 
    % manage condtions
    for l = 1:size(opt.ConditionName, 1)

        RunConditions(l).name = opt.ConditionName{l};
        RunConditions(l).onset = [];
        RunConditions(l).duration = [];
        RunConditions(l).use = 1;
        RunConditions(l).usePMod = 0;

        for m = 1:length(opt.CondColumn)

            CondIndex = RunData(:, opt.CondColumn(m)) == l;
            CondOnsets = RunData(CondIndex, opt.TimeColumn(m));
            RunConditions(l).onset(end+1:end+length(CondOnsets)) = CondOnsets;
            CondDurations = RunData(CondIndex, opt.DurationColumn(m));
            RunConditions(l).duration(end+1:end+length(CondDurations)) = CondDurations;

        end
    end

    % manage parametric regressors
    if ~isempty(opt.ParametricList) == 1

        for iPar = 1:size(opt.ParametricList, 1)

            for iCondForPar = 1:length(opt.ParametricList{iPar, 3})
                CondForPar = opt.ParametricList{iPar, 3}(iCondForPar);
                RunConditions(CondForPar).usePMod = RunConditions(CondForPar).usePMod + 1;
                ParIndex = RunConditions(CondForPar).usePMod;
                RunConditions(CondForPar).pmod(ParIndex).name = opt.ParametricList{iPar, 1};
                RunConditions(CondForPar).pmod(ParIndex).poly = opt.ParametricList{iPar, 4};

                % now assign parametric values based on the number of CondColumns present.
                % If CondColumn > 1, use the parametric regressors in the column assigned
                % to it at each column where it equals the corresponding condition number.
                if length(opt.CondColumn) == 1
                   
                    % easy case :)
                    CondIndex = RunData(:, opt.CondColumn) == CondForPar;
                    RunConditions(CondForPar).pmod(ParIndex).param = RunData(CondIndex, opt.ParametricList{iPar, 2});

                else

                    % now we have to cycle through each condition and log usage
                    CondIndex = false(size(RunData, 1), 1);

                    msg = sprintf(['SUBJECT %s RUN %s :\n' ...
                                   ' Parametric regressor %s is being used with condition number' ...
                                   '%d from columns '], Subject, Run, opt.ParametricList{iPar, 1}, CondForPar);

                    for iCondCol = 1:length(opt.CondColumn)
                        tmpIndex = RunData(:, opt.CondColumn(iCondCol)) == CondForPar;
                        CondIndex = CondIndex | tmpIndex;
                        msg = strcat(msg, sprintf('%d ', opt.CondColumn(iCondCol)));
                    end

                    msg = strcat(msg, sprintf('in the Master Data File\n\n'));
                    fprintf(1, msg);
                    mc_Logger('log', msg, 3);

                    RunConditions(CondForPar).pmod(ParIndex).param = RunData(CondIndex, opt.ParametricList{iPar, 2});

                end
            end
        end
    % end of managing parametric list
    end

end
