function SubjectContrasts = FL_QuickVarianceWeight(SubjectNumber, opt, OneSubj)
%   SubjectContrasts = FL_SetSubjectContrasts(SubjectNumber, opt, SubjectSession)
%
%   REQUIRED INPUT
%
%       opt.
%           SubjDir             - cell(N, 3)
%                                 column1 = subject name
%                                 column2 = subject number in master data file
%                                 column3 = vector of runs to include
%           RunDir              - cell(M, 1)
%           ConditionName       - cell(C, 1) list of conditions as strings
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
%           Basis               - string, either 'hrf' or 'fir'
%           HrfDerivative       - scalar, either [0 1 2], indcates if derivatives are being used 
%                                 for canonical hrf function
%           FirBins             - scalar, number of fir basis functions
%           
%
%       OneSubj.
%           name                - string, subject name
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
%                   names       - string, regressor name
%               useCompCor      - scalar, if equal 1, then CompCor is used in model
%               varExplained    - vector, variance explained for each CompCor file
%               compCor(*).
%                   val         - vector, lists one component for CompCor
%                   name        - string, CompCor name
%
%   OUTPUT
%
%       SubjectContrasts        - matrix, contains contrast vectors as created by 
%                                 opt.ContrastList and opt.ContrastRunWeights

    Subject = opt.SubjDir{SubjectNumber, 1};
    NumCond = size(opt.ConditionName, 1);
    NumRuns = size(OneSubj.sess, 2);

    % find out number of bases used
    if strcmp(opt.Basis, 'hrf')
        if opt.HrfDerivative == 0
            NumBases = 1;
        elseif opt.HrfDerivative == 1
            NumBases = 2;
        else
            NumBases = 3;
        end
    else
        NumBases = opt.FirBins;
    end
    
    % create contrast matrix for each run for this subject
    tmpSess(NumRuns) = struct('Contrasts', []);
    for i = 1:NumRuns
        tmpSess(i).Contrasts = QuickSetRunContrasts(OneSubj.name, opt.ContrastList{i}, OneSubj.sess(i), NumCond);
    end

    % concatanate runs together to create the contrast matrix
    SubjectContrasts = [];
    for i = 1:NumRuns
        SubjectContrasts = [SubjectContrasts tmpSess(i).Contrasts];
    end

    % finally zero pad contrast matrix for the constant regressors
    NumContrasts = size(SubjectContrasts, 1);
    SubjectContrasts = [SubjectContrasts zeros(NumContrasts, NumRuns)];
end

function RunContrasts = QuickSetRunContrasts(Subject, ContrastList, Sess, NumCond)

    NumContrasts = size(ContrastList, 1);

    % count number of columns by using first contrast
    tmp = [ ContrastList{1, [2:(NumCond+1)]} ];
    ContrastColumns = length(tmp);

    % create RunContrasts now and fill it in
    RunContrasts = zeros(NumContrasts, ContrastColumns);
    for i = 1:NumContrasts
        RunContrasts(i, :) = [ ContrastList{i, [2:(NumCond+1)]} ];
    end

    % now create regressor contrasts
    if Sess.useRegress == 1

        NumRegressors = size(Sess.regress, 2);
        RegressorContrasts = zeros(NumContrasts, NumRegressors);
        
        for i = 1:NumContrasts

            UserRegContrast = ContrastList{i, end};
            UserRegConLength = length(UserRegContrast);

            if UserRegConLength > NumRegressors

                msg = sprintf(['SUBJECT %s RUN %s' ...
                               ' The regressor contrast vector is greater than the number of regressors found contrast number %d.\n' ...
                               ' The number of regressors found are %d.  The length of the input regressor contrast vector is %d.\n' ...
                               ' Trimming the regressor contrast vector to the number of regressors found.  Contrast may not be valid.\n\n'], ...
                               Subject, Run, i, NumRegressors, UserRegConLength);
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
        AllUserRegressors = [ ContrastList{:, end} ];
        if ~isempty(AllUserRegressors) == 1

            msg = sprintf(['SUBJECT %s RUN %s :\n' ...
                           ' No regressors were found.  User has specified contrasts for regressors.  No contrasts for regressors will be created.\n\n'], Subject, Run);
            mc_Logger('log', msg, 2);

        end

        RegressorContrasts = [];

    end

    RunContrasts = [RunContrasts RegressorContrasts];
end


