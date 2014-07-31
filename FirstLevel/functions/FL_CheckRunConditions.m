function Sess = FL_CheckRunConditions(Subject, Run, Sess, opt)
%   Sess = FL_CheckRunConditions(Subjects, Run, Sess, opt)
%
%   REQUIRED INPUT
%
%       opt.
%           ConditionName       - cell(M, 1) list of conditions as strings
%           ConditionThreshold  - scalar, removes conditions that do not exceed this threshold
%                                 used
%       Sess.
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
%
%   OUTPUT
%       
%       Sess.
%           name            
%           images          
%           cond(Z).
%               use         - modified
%               usePMod      
%               name         
%               onset        
%               duration     
%               pmod(P).
%                   name     
%                   param   - modified
%                   poly    
%
%   N = number of subjects
%   Y = number of sessions
%   M = number of conditions
%   P = number of parametric regressors
%   Z = number of conditions
%
% This function checks whether the condition and its parametric regressors are useable.
% Appropriate variables are updated in RunCoditions to indicate useability.
% 

    FinalTime = size(Sess.images, 1) * opt.TR;
    for i = 1:size(Sess.cond, 2)
        CondName = Sess.cond(i).name;
        CondNum = find(strcmp(CondName, opt.ConditionName));
        % check if condition is useable for the run
        if length( Sess.cond(i).onset ) <= opt.ConditionThreshold || ...
           isempty( Sess.cond(i).onset ) == 1

            Sess.cond(i).use = 0;

            % Log this information
            msg = sprintf(['SUBJECT %s RUN %s :\n' ...
                           ' Omitting condition %s number %d\n' ...
                           ' Condition was either not present in the master date file or' ...
                           ' did not exceed the ConditionThreshold of %d.\n\n'], ...
                           Subject, Run, CondName, CondNum, opt.ConditionThreshold);
            fprintf(1, msg);
            mc_Logger('log', msg, 2);
        end

        % check to make sure times make sense for condition
        if Sess.cond(i).use == 1 && ...
           (all(Sess.cond(i).onset > FinalTime) || all(Sess.cond(i).onset < 0))

            Sess.cond(i).use = 0;
            % Log this information
            msg = sprintf(['SUBJECT %s RUN %s :\n' ...
                           ' Omitting condition %s number %d\n' ...
                           ' Condition onset times are all greater than the expected final' ...
                           ' time of %0.2f or below 0\n\n'], ...
                           Subject, Run, CondName, CondNum, FinalTime);
            fprintf(1, msg);
            mc_Logger('log', msg, 2);
        end


        % check parametric regressors
        if Sess.cond(i).usePMod > 0
            for k = 1:size(Sess.cond(i).pmod, 2)
                ParamName = Sess.cond(i).pmod(k).name;
                % check if corresponding condition is actually being used
                if Sess.cond(i).use == 0
                    msg = sprintf(['SUBJECT %s RUN %s :\n' ...
                                   ' Omitting parametric regressor for %s for condition %s number %d.\n' ...
                                   ' The condition is not in this run.\n\n'], ...
                                   Subject, Run, ParamName, CondName, CondNum);

                    fprintf(1, msg);
                    mc_Logger('log', msg, 2);
                    Sess.cond(CondForPar).pmod(ParIndex).param = [];
                    continue;
                end

                % check if all values are equal
                if all( Sess.cond(i).pmod(k).param == Sess.cond(i).pmod(k).param(1) )

                    msg = sprintf(['SUBJECT %s RUN %s :\n' ...
                                   ' All values for parametric regressor %s are equal.\n' ...
                                   ' The parametric regressor will not be used with condition number %d.\n\n'], ...
                                   Subject, Run, ParamName, CondNum);
                    fprintf(1, msg);
                    mc_Logger('log', msg, 2);
                    Sess.cond(i).pmod(k).param = [];
                end
            end
        end
    end
end
