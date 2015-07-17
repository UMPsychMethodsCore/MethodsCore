function AllSubjects = FL_CreateSimpleSubjects(opt, SubjectMasterData)
% AllSubjectInfo = FL_CreateSimpleSubjects(opt, SubjectMasterData)
%
%   REQUIRED INPUT
%   
%       opt.
%           Exp                 - string
%           SubjDir             - cell(N, 2)
%                                 column1 = subject name
%                                 column2 = vector of runs to include
%           RunDir              - cell(M, 1)
%           MasterDataFilePath  - string, path to master data file
%                                 templates permitted : [Exp]
%           SubjColumn          - vector
%           RunColumn           - vector
%           CondColumn          - vector
%           TimeColumn          - vector
%           DurationColumn      - vector
%           ConditionName       - cell(C, 1) list of conditions as strings
%           ConditionThreshold  - scalar, removes conditions that do not exceed this threshold
%           IdenticalModels     - scalar, if equals 1, all subjects have the same model specs
%           TotalTrials         - scalar, indicates total number of trials if IdenticalModels is
%                                 used
%           ParametricList      - cell(P, 4)
%                                 column1 = paramatric name
%                                 column2 = column in master data file
%                                 column3 = condition number as listed in ConditionName
%                                 column4 = order
%   OUTPUT
%
%       AllSubjectInfo(N).
%           name                - string, subject name
%           sess(M).
%               name            - string, run name
%               cond(C).
%                   use         - scalar, a value of 1 indicates to use this
%                   usePMod     - scalar, a value of 1 indicates this condition has parametric
%                                 regressors
%                   name        - string, condition name
%                   onset       - vector, list of condition onsets
%                   duration    - vector, duration of onsets
%                   pmod(P).
%                       name    - string, parametric regressor name
%                       param   - vector, values
%                       poly    - scalar, polynomial order to use
%
%   M = Number of Run directories
%   N = Number of subjects
%   C = Number of conditions
%   P = number of parametric values
%   Z = number of regressor files
%   L = number of contrasts
%   I = number of timepoint, subject and run specific
%   Q = number of columns in design matrix per run per subjects
%   A = number of comp cor files
%
%   This function is used for creating simple subject structures. They are simple in the fact that no regressor checking
%   is done, so that all regressors read are included in the subject structures.
%
    % Let's assume for now we have done some appropriate checks on the input variables
    NumSubjects = size(opt.SubjDir, 1);
    AllSubjects(NumSubjects) = struct();
    Exp = opt.Exp;

    for i = 1:NumSubjects

        Subject = opt.SubjDir{i, 1};
        AllSubjects(i).name = Subject;
        NumRuns = length( opt.SubjDir{i, 2} );

        % be verbose about build subject
        fprintf(1, 'Building subject %s\n', Subject);

        for k = 1:NumRuns

            RunNumber = opt.SubjDir{i, 2}(k);
            Run = opt.RunDir{ RunNumber };
            AllSubjects(i).sess(k).name = Run;

            % be verbose about building run
            fprintf(1, '\tWorking on %s\n', Run);

            % handle condtions for run
            AllSubjects(i).sess(k).cond = FL_SetRunConditions(i, RunNumber, SubjectMasterData(i).sess(k).RunData, opt);
          
        end
    end
end

