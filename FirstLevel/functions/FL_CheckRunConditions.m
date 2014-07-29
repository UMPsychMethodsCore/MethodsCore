function RunConditions = FL_CheckRunConditions(Subject, Run, RunConditions, opt)
%   RunConditions = FL_CheckRunConditions(Subjects, Run, RunConditions, opt)
%
%   REQUIRED INPUT
%
%       opt.
%           ConditionName       - cell(M, 1) list of conditions as strings
%           ConditionThreshold  - scalar, removes conditions that do not exceed this threshold
%                                 used
%       RunCoditions(Z).
%           use         - scalar, this value should always = 1
%           usePMod     - scalar, counts the number of parametric regressors used for condition
%           name        - string, condition name
%           onset       - vector, list of condition onsets
%           duration    - vector, duration of onsets
%           pmod(P).
%               name    - string, parametric regressor name
%               param   - vector, values
%               poly    - scalar, polynomial order to use
%
%   OUTPUT
%       
%       RunConditions(Z).
%           use         - modified
%           usePMod      
%           name         
%           onset        
%           duration     
%           pmod(P).
%               name     
%               param   - modified
%               poly    
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

    for i = 1:size(RunConditions, 2)
        CondName = RunConditions(i).name;
        CondNum = find(strcmp(CondName, opt.ConditionName));
        % check if condition is useable for the run
        if length( RunConditions(i).onset ) <= opt.ConditionThreshold || ...
           isempty( RunConditions(i).onset ) == 1

            RunConditions(i).use = 0;

            % Log this information
            msg = sprintf(['SUBJECT %s RUN %s :\n' ...
                           ' Omitting condition %s number %d\n' ...
                           ' Condition was either not present in the master date file or' ...
                           ' did not exceed the ConditionThreshold of %d.\n\n'], ...
                           Subject, Run, CondName, CondNum, opt.ConditionThreshold);
            fprintf(1, msg);
            mc_Logger('log', msg, 2);
        end

        % check parametric regressors
        if RunConditions(i).usePMod > 0
            for k = 1:size(RunConditions(i).pmod, 2)
                ParamName = RunConditions(i).pmod(k).name;
                % check if corresponding condition is actually being used
                if RunConditions(i).use == 0
                    msg = sprintf(['SUBJECT %s RUN %s :\n' ...
                                   ' Omitting parametric regressor for %s for condition %s number %d.\n' ...
                                   ' The condition is not in this run.\n\n'], ...
                                   Subject, Run, ParamName, CondName, CondNum);

                    fprintf(1, msg);
                    mc_Logger('log', msg, 2);
                    RunConditions(CondForPar).pmod(ParIndex).param = [];
                    continue;
                end

                % check if all values are equal
                if all( RunConditions(i).pmod(k).param == RunConditions(i).pmod(k).param(1) )

                    msg = sprintf(['SUBJECT %s RUN %s :\n' ...
                                   ' All values for parametric regressor %s are equal.\n' ...
                                   ' The parametric regressor will not be used with condition number %d.\n\n'], ...
                                   Subject, Run, ParamName, CondNum);
                    fprintf(1, msg);
                    mc_Logger('log', msg, 2);
                    RunConditions(i).pmod(k).param = [];
                end
            end
        end
    end
end
