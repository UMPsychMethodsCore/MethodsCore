function RunContrasts = SetRunContrasts(Subject, NumBases, opt, sess)
%   RunContrasts = SetRunContrasts(Subject, NumBases, opt, sess)
%
%   REQUIRED INPUT
%       Subject                 - string, subject name
%
%       NumBases                - scalar, number of bases function used in model
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
    Run = sess.name;

    NumContrasts = size(opt.ContrastList, 1);
    NumConditions = size(opt.ConditionName, 1);
    
    % trim contrast list based on wheter conditions and parametric regressors are being used
    for i = 1:NumConditions

        if sess.cond(i).use == 0

            msg = sprintf(['SUBJCT %s RUN %s :\n' ...
                           ' Condition %s and any parametric regressors will be omitted from the model.\n\n'], Subject, Run, sess.cond(i).name);
            fprintf(1, msg);
            mc_Logger('log', msg, 2);

            % remove condition from each contrast vector
            for k = 1:NumContrasts
                opt.ContrastList{k, i + 1} = [];
            end

        % check for parametric regressors
        elseif sess.cond(i).usePMod > 0

            NumPara = size(sess.cond(i).pmod, 2);

            for k = 1:NumPara

                if isempty(sess.cond(i).pmod(k).param) == 1
                    msg = sprintf(['SUBJECT %s RUN %s :\n' ...
                                   ' Condition %s, the parametric regressor %s will be omitted from the model.\n\n'], ...
                                   Subject, Run, sess.cond(i).name, sess.cond(i).pmod(NumPara).name);
                    fprintf(1, msg);
                    mc_Logger('log', msg, 2);

                    % assume the condition contrast vector is the same length for all contrast
                    % vectors; otherwise this breaks, but assumption should be valid
                    tmpConVec = opt.ContrastList{1, i + 1};
                    ColumnsRemoved = sess.cond(i).pmod(k).poly * NumBases;
                    tmpConVec(NumBases+1:ColumnsRemoved-1) = [];

                    for iCon = 1:NumContrasts
                        opt.ContrastList{iCon, i + 1} = tmpConVec;
                    end

                end
            end
        end
    end

    % count number of columns by using first contrast
    tmp = [ opt.ContrastList{1, [2:(NumConditions+1)]} ];
    ContrastColumns = length(tmp);
    RunContrasts = [];
    
    % give feedback if no conditions are being modeld this run
    if isempty(tmp) == 1

        msg = sprintf(['SUBJECT %s RUN %s :\n' ...
                       ' No conditions are being modeled.\n\n'], Subject, Run);
        fprintf(1, msg);
        mc_Logger('log', msg, 2);

    else       

        % create RunContrasts now and fill it in
        RunContrasts = zeros(NumContrasts, ContrastColumns);
        for i = 1:NumContrasts
            RunContrasts(i, :) = [ opt.ContrastList{i, [2:(NumConditions+1)]} ];
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

                msg = sprintf(['SUBJECT %s RUN %S' ...
                               ' The regressor contrast vector is greater than the number of regressors found contrast number %d.\n' ...
                               ' The number of regressors found are %d.  The length of the input regressor contrast vector is %d.\n' ...
                               ' Trimming the regressor contrast vector to the number of regressors found.  Contrast may not be valid.\n\n'], ...
                               Subject, Run, i, NumRegressors, UserRegConLegnth);
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

            msg = sprintf(['SUBJECT %s RUN %s :\n' ...
                          ' No regressors were found.  User has specified contrasts for regressors.  No contrasts for regressors will be created.\n\n'], Subject, Run);
            mc_Logger('log', msg, 2);

        end

        RegressorContrasts = [];

    end

    RunContrasts = [RunContrasts RegressorContrasts];

end

