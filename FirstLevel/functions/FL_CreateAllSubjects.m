function AllSubjects = FL_CreateAllSubjects(opt, SubjectMasterData)
% AllSubjectInfo = FL_CreateAllSubjects(opt)
%
%   REQUIRED INPUT
%   
%       opt.
%           Exp                 - string
%           SubjDir             - cell(N, 2)
%                                 column1 = subject name
%                                 column2 = vector of runs to include
%           RunDir              - cell(M, 1)
%
%
%           ImagePathTemplate   - string template to run images
%           BaseFileSpmFilter   - spm_filter used to acquire images
%
%
%           MasterDataFilePath  - string, path to master data file
%                                 templates permitted : [Exp]
%           SubjColumn          - vector
%           RunColumn           - vector
%           CondColumn          - vector
%           TimeColumn          - vector
%           DurationColumn      - vector
%           ConditionName       - cell(C, 1) list of conditions as strings
%           ConditionModifier   - scalar, remove these last conditions from the model
%           ConditionThreshold  - scalar, removes conditions that do not exceed this threshold
%           IdenticalModels     - scalar, if equals 1, all subjects have the same model specs
%           TotalTrials         - scalar, indicates total number of trials if IdenticalModels is
%                                 used
%           ParametricList      - cell(P, 4)
%                                 column1 = paramatric name
%                                 column2 = column in master data file
%                                 column3 = condition number as listed in ConditionName
%                                 column4 = order
%
%
%           RegFilesTemplate    - cell(Z, 4)
%                                 column1 = run specific regressor file template
%                                 column2 = number of regressors to inclucde from file
%                                           a value of inf includes all regressors
%                                 column3 = number of derivatives to calculate for regressor
%                                           a value equal to or less than 0 does not calculate
%                                           any derivatives for the regressor
%                                 column4 = polynomial term to include for regressor
%                                           affects both the regressor and its derivatives
%                                           1 = regressor alone
%                                           2 = include quadratic
%                                           3 = cubic .... and so on
%                                 Templates : Exp Subject Run
%           CompCorTemplate     - cell(A, 4)
%                                 column1 = string, run specific comp cor prefix file template
%                                 column2 = scalar flag [1 2 3], regressors used 
%                                 column3 = scalar flag [1 2], component inclusion method
%                                 column4 = scalar, # of components  OR  minimal fractional 
%                                           variance explained
%                                 Templates : Exp Subject Run
%
%
%           ContrastList        - cell(L, C+2)
%                                 column1 = string, contrast name
%                                 columns 2 thru (C+1), vectors
%                                   first column in vector codes for conditon single run contrast
%                                   weight.  Second column codes for single run contrast weights
%                                   for the parametric regressors associated with the condition.
%                                 column(C+2) is a vector that codes for single contrasts weights
%                                   for the regressors.
%           ContrastRunWeights  - cell(L, 1)
%                                 each row codes for a run specific contrast
%
%
%           VolumeSpecifier     - matrix(2, M)
%                                 row1 = start volume for run
%                                 row2 = end volume for run
%   OUTPUT
%
%       AllSubjectInfo(N).
%           name                - string, subject name
%           outputDir           - string, directory to output first level results
%           sess(M).
%               name            - string, run name
%               images          - cell(I, 1), list of images
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
%               useRegress      - scalar, if equals 1, then regressors should be used in model
%               regress(Z).
%                   val         - vector, lists one regressors
%                   name        - string, regressor name
%               useCompCor      - scalar, if equal 1, then CompCor is used in model
%               varExplained    - vector, variance explained for each CompCor file
%               compCor(*).
%                   val         - vector, lists one component for CompCor
%                   name        - string, CompCor name
%               contrasts       - matrix, L x Q
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

    % Let's assume for now we have done some appropriate checks on the input variables
    NumSubjects = size(opt.SubjDir, 1);
    AllSubjects(NumSubjects) = struct();
    Exp = opt.Exp;

    for i = 1:NumSubjects

        Subject = opt.SubjDir{i, 1};
        AllSubjects(i).name = Subject;
        AllSubjects(i).outputDir = mc_GenPath(opt.OutputDir);
        NumRuns = length( opt.SubjDir{i, 2} );

        % be verbose about build subject
        fprintf(1, 'Building subject %s\n', Subject);

        for k = 1:NumRuns

            RunNumber = opt.SubjDir{i, 2}(k);
            Run = opt.RunDir{ RunNumber };
            AllSubjects(i).sess(k).name = Run;

            % be verbose about building run
            fprintf(1, '\tWorking on %s\n', Run);

            % get subject images for run
            AllSubjects(i).sess(k).images = FL_SetRunImages(i, RunNumber, opt);

            % handle condtions for run
            AllSubjects(i).sess(k).cond = FL_SetRunConditions(i, RunNumber, ...
                                            SubjectMasterData(i).sess(k).RunData, opt);
            AllSubjects(i).sess(k) = FL_CheckRunConditions(Subject, Run, ...
                                        AllSubjects(i).sess(k), opt);
          
            % handle regressors for run
            AllSubjects(i).sess(k).regress = FL_SetRunRegressors(i, RunNumber, opt);
            if isempty(AllSubjects(i).sess(k).regress) == 1
                AllSubjects(i).sess(k).useRegress = 0;
            else
                AllSubjects(i).sess(k).useRegress = 1;
            end

            % handle timepoint trimming
            if ~isempty(opt.VolumeSpecifier) == 1 && size(opt.VolumeSpecifier, 2) <= k
                AllSubjects(i).sess(k) = FL_TrimRun(AllSubjects(i).sess(k), i, RunNumber, opt);
            end

        end

        % create contrast for whole subject
        if opt.VarianceWeighting == 0
            AllSubjects(i).contrasts = FL_SetSubjectContrasts(i, opt, AllSubjects(i));
        else
            AllSubjects(i).contrasts = FL_QuickVarianceWeight(i, opt, AllSubjects(i));
        end

        % assign explicit mask
        if ~isempty(opt.ExplicitMask)
            mcgp.Template = opt.ExplicitMask;
            mcgp.mode = 'check';
            AllSubjects(i).mask = mc_GenPath(mcgp);
        else
            AllSubjects(i).mask = '';
        end
    end
end
