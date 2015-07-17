function sess = FL_TrimRun(sess, SubjectNumber, RunNumber, opt)
%   TrimmedRun = FL_TrimRun(sess, opt)
%
%   REQUIRED INPUT
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
%           useCompCor      - scalar, if equals 1, then CompCor is used in the model
%           compCor(*).
%               val         - vector, lists one component for CompCor
%               name        - string, CompCor name
%
%
%   opt.       
%       VolumeSpecifier     - matrix(2, M)
%                             row1 = start volume for run
%                             row2 = end volume for run
%       TR                  - repetition time for experiment
%
%   C = Number of conditions
%   P = number of parametric values
%   Z = number of regressor files
%   I = number of timepoint, subject and run specific
%
%   This function limits the timpoints to include only the range as specified by VolumeSpecifier.
%   The function assumes VolumeSpecifier is not empty for index k.
%   The function assumes VolumeSpecifier(1, :) < VolumeSpecifier(2, :)
%   The function assumes sess.images is not empty.
%   The function assumes the regressors are the same size as sess.images
%
    Subject = opt.SubjDir{SubjectNumber, 1};
    Run = opt.RunDir{RunNumber};

    BeginVolume = opt.VolumeSpecifier(1, k);
    BeginTime = opt.TR * BeginVolume - opt.TR;
    EndVolume = opt.VolumeSpecifier(2, k);
    EndTime = opt.TR * EndVolume - opt.TR;

    % handle a very simple case
    if BeginVolume == 1 && EndVolume >= size(sess.images, 1)
        msg = sprintf(['SUBJECT %s RUN %s', ...
                       ' VolumeSpecifier parameters do no trimming\n\n'], Subject, Run);
        mc_Logger('log', msg, 3);
        return;
    end

    % trim images
    sess.images = sess.images{BeginVolume:EndVolume};

    % trim conditions
    NumCond = size(sess.cond, 2);
    for i = 1:NumCond

        if sess.cond(i).use == 1

            UnderTimeOnsets = sess.cond(i).onset < BeginTime;
            OverTimeOnsets = sess.cond(i).onset > EndTime;
            AllTrimmedOnsets = UnderTimeEvents | OverTimeEvent

            if any(AllTrimmedOnsets) == 1

                sess.cond(i).onset(AllTrimmedOnsets) = [];
                sess.cond(i).duration(AllTrimmedOnsets) = [];

                if usePMod == 1

                    NumPara = size(sess.cond(i).pmod, 2);
                    for k = 1:NumPara

                        sess.cond(i).pmod(k).param(AllTrimmedOnsets) = [];

                    end

                end

                msg = sprintf(['SUBJECT %s RUN %s :\n' ...
                               ' Removed %d onsets for condition %s using VolumeSpecifier parameters %d and %d.\n\n'], ...
                                Subject, Run, sum(AllTrimmedOnsets), sess.cond(i).name, BeginVolume, EndVolume);
                mc_Logger('log', msg, 3);

                if isempty(sess.cond(i).onset) == 1

                    msg = sprintf(['SUBJECT %s RUN %s :\n' ...
                                   ' VolumeSpecifier %d and %d parameters remove all occurrences of condition %s.\n\n'], ...
                                   Subject, Run, BeginVolume, EndVolume, sess.cond(i).name);
                    fprintf(1, msg);
                    mc_Logger('log', msg, 2);
                    sess.cond(i).use = 0;

                end

            end

        % end of testing one condition if being used
        end

    % end of testing one condition
    end

    % handle trimming regressors (compcor included)
    if sess.useRegress == 1

        NumRegressors = size(sess.regress, 2);
        for i = 1:NumRegressors
            sess.regress(i).val = sess.regress(i).val(BeginVolume:EndVolume);
        end

    end
end
