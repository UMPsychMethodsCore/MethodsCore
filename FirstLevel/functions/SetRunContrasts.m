function RunContrasts = SetRunContrasts(SubjectNumber, RunNumber, opt, sess)
%   RunContrasts = SetRunContrasts(SubjectNumber, SubjectRun, opt, sess)
%
%   REQUIRED INPUT
%
%       opt.
%           ConditionName       - cell(C, 1) list of conditions as strings
%           ContrastList        - cell(L, C+2)
%                                 column1 = string, contrast name
%                                 columns 2 thru (C+1), vectors
%                                   first column in vector codes for conditon single run contrast
%                                   weight.  Second column codes for single run contrast weights
%                                   for the parametric regressors associated with the condition.
%                                 column(C+2) is a vector that codes for single contrasts weights
%                                   for the regressors.
%           
%           
%       sess.
%           name            - string, run name
%           images          - cell(I, 1), list of images
%           cond(C).
%               use         - scalar, a value of 1 indicates to use this
%               usePMod     - scalar, a value of 1 indicates this condition has parametric
%                             regressors
%               name        - string, condition name
%               onset       - vector, list of condition onsets
%               duration    - vector, duration of onsets
%               pmod(P).
%                   name    - string, parametric regressor name
%                   param   - vector, values
%                   poly    - scalar, polynomial order to use
%           useRegress      - scalar, if equals 1, then regressors should be used in model
%           regress(Z).
%               val         - vector, lists one regressors
%               names       - string, regressor name
%
%   OUTPUT
%
%       RunContrasts        - matrix, L x Q
%
%   C = Number of conditions
%   P = number of parametric values
%   Z = number of regressor files
%   L = number of contrasts
%   I = number of timepoint, subject and run specific
%   Q = number of columns in design matrix per run per subjects
%
%   This function assumes all contrasts have the same vector lengths for a condition.
%
    Subject = opt.SubjDir{SubjectNumber, 1};
    Run = opt.RunDir{RunNumber};

    NumContrasts = size(opt.ContrastList, 1);
    NumConditions = size(opt.ConditionName, 1);
    
    ConditionsModeled = [];
    ContrastColumns = 0;

    % check which conditions are being modeled
    for i = 1:NumConditions
        
        if sess.cond(i).use == 0

            msg = sprintf('For subject %s run %s condtion %s will not be modeled.\n\n', Subject, Run, sess.cond(i).name);
            fprintf(1, msg);
            mc_Logger('log', msg, 2);

        else

            ConditionsModeled(end+1) = i;
            ContrastColumns = ContrastColumns + length(opt.ContrastList{1, 1+i});

        end

    end

    % create contrast matrix whether or not any condtions are being modeled
    if isempty(ConditionsModeled) == 1

        msg = sprintf('For subject %s run %s no conditions are being modeled.\n\n', Subject, Run);
        fprintf(1, msg);
        mc_Logger('log', msg, 2);
        RunContrasts = [];

    else

        RunContrasts = zeros(NumContrasts, ContrastColumns);
        for i = 1:NumContrasts
            RunContrasts(i, :) = [ opt.ContrastList{i, ConditionsModeled + 1} ];
        end

    end

    % now create regressor contrasts
    if sess.useRegress == 1

        NumRegressors = size(sess.regress, 2);
        RegressorContrasts = zeros(NumContrasts, NumRegressors);
        
        for i = 1:NumContrasts

            UserRegContrast = opt.ContrastList{i, end};
            UserRegConLength = length(UserRegContrast);

            if UserRegConLength > NumRegressors

                 msg = sprintf('The regressor contrast vector is greater than the number of regressors found for subject %s for run %s for contrast number %d.\n  The number of regressors found are %d.  The length of the input regressor contrast vector is %d.\n  Trimming the regressor contrast vector to the number of regressors found.  Contrast may not be valid.\n\n');
                fprintf(1, msg);
                mc_Logger('log', msg, 2);
                UserRegContrast = UserRegContrast(1:NumRegressors);
                UserRegConLength = NumRegressors;

            end

            if UserRegConLength ~= 0
                RegressorContrasts(i, 1:UserRegConLength) = UserRegContrast;
            end

        end

    else

        % check if user has any regressor contrasts
        AllUserRegressors = [ opt.ContrastList{:, end} ];
        if ~isempty(AllUserRegressors) == 1

            msg = sprintf('For subject %s run %r no regressors were found.  User has specified contrasts for regressors.  No contrasts for regressors will be created.\n\n', Subject, Run);
            mc_Logger('log', msg, 2);

        end

        RegressorContrasts = [];

    end

    RunContrasts = [RunContrasts RegressorContrasts];

end

