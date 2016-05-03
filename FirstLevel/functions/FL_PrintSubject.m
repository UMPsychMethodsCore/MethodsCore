function FL_PrintSubject(Subject, fid)
% function FL_PrintSubjectToConsole(Subject, fid)
%
%   INPUT
%       Subject.
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
%       fid - file identifier (use 1 for standard output) 
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
    % calculate total trials across all runs to print in header
    TotalTrials = 0;
    for i = 1:size(Subject.sess, 2)
        for k = 1:size(Subject.sess(i).cond, 2)
            if Subject.sess(i).cond(k).use == 1
                TotalTrials = TotalTrials + length(Subject.sess(i).cond(k).onset);
            end
        end
    end

    % print header
    fprintf(fid, '\n\n\n');
    fprintf(fid, '***********************************************\n');
    fprintf(fid, 'subject:        %s\n', Subject.name);
    fprintf(fid, '# of runs:      %d\n', size(Subject.sess, 2));
    fprintf(fid, '# of trials:    %d\n', TotalTrials);
    fprintf(fid, 'For each run here are the onsets, durations, and parameters: \n');

    for i = 1:size(Subject.sess, 2)
        fprintf(fid, 'Run: %s\n', Subject.sess(i).name);
        for k = 1:size(Subject.sess(i).cond, 2)
            if Subject.sess(i).cond(k).use == 1
                PrintOnsetsDurationsParameters(Subject.sess(i).cond(k), fid);
            else
                fprintf(fid, 'Condition %s: EXCLUDED\n', Subject.sess(i).cond(k).name);
            end
        end
    end
end

function PrintOnsetsDurationsParameters(cond, fid)
% function PrintOnsetsDurationsParameters(cond, fid)

    fprintf(fid, 'Condition %s: ', cond.name);
    if cond.usePMod > 0
        fprintf(fid, 'Parametric Regressors: (');
        for i = 1:size(cond.pmod, 2)
            if i ~= size(cond.pmod, 2)
                fprintf(fid, '%s, ', cond.pmod(i).name);
            else
                fprintf(fid, '%s)', cond.pmod(i).name);
            end
        end
    end

    for i = 1:length(cond.onset)
        fprintf(fid, ' (%0.3f, %0.3f', cond.onset(i), cond.duration(i));
        if cond.usePMod > 0
            for k = 1:size(cond.pmod, 2)
                fprintf(fid, ', %0.3f', cond.pmod(k).param(i));
            end
        end
        fprintf(fid, ') ');
    end

    fprintf(fid, '\n');
end
            

    
