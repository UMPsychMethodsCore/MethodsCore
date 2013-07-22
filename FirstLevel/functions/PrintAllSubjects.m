function PrintAllSubjects(Subjects, opt)
%   PrintAllSubjects(Subjects, opt)

    fid = fopen('AllSubjects.txt', 'w');
    if fid == -1
        fprintf(1, 'Cannot print all subjects.\n');
        return;
    end

    NumSubjects = size(Subjects, 2);
    fprintf(fid, 'There are %d subjects in this batch\n\n', NumSubjects);

    for i = 1:NumSubjects

        NumRuns = size(Subjects(i).sess, 2);
        fprintf(fid, 'SUBJECT : %s OUTPUTDIR : %s RUNS : %d\n\n', Subjects(i).name, Subjects(i).outputDir, NumRuns);

        for k = 1:NumRuns
            PrintRun(Subjects(i).sess(k), fid);
        end
        
        % print out contrast matrix
        fprintf(fid, '\tCONTRAST MATRIX :\n\n');
        for k = 1:size(Subjects(i).contrasts, 1)
            fprintf(fid, '\t');
            for l = 1:size(Subjects(i).contrasts, 2)
                fprintf(fid, '%-3.5f ', Subjects(i).contrasts(k, l));
            end
            fprintf(fid, '\n');
        end
        fprintf(fid, '\n\n');
    end
    fclose(fid);
end

function PrintRun(sess, fid)
%   PrintRun(sess, fid)
%   assumes sess is not empty, but still might work if it is

    fprintf(fid, '\tRUN                  : %s\n', sess.name);
    fprintf(fid, '\tTIMEPOINTS           : %d\n', size(sess.images, 1));
    % print out condition information
    NumCond = size(sess.cond, 2);
    fprintf(fid, '\tNUMBER OF CONDITIONS : %d\n\n', NumCond);
    for i = 1:NumCond

        if sess.cond(i).use == 1
            PrintCondition(sess.cond(i), fid)
        else
            fprintf(fid, '\tCONDITION %s IS NOT BEING USED.\n', sess.cond(i).name);
        end

    end
    fprintf(fid, '\n');

    % print out regressor information if being used
    if sess.useRegress == 1
        numRegress = size(sess.regress, 2);
        fprintf(fid, '\tNUMBER REGRESSORS  : %d\n', numRegress);
    else
        fprintf(fid, '\tNO REGRESSORS USED FOR THIS SESSION\n');
    end
    fprintf(fid, '\n');

    % print out CompCor information if being used
    if sess.useCompCor == 1
        numCompCor = size(sess.compCor, 2);
        fprintf(fid, '\tNUMBER COMP COR   : %d\n', numCompCor);
        fprintf(fid, '\tVARIANCE ACCOUNTED: ');
        for i = 1:length(sess.varExplained)
            fprintf(fid, '%0.3f ', sess.varExplained(i));
        end
        fprintf(fid, '\n');
    end
    fprintf(fid, '\n');
        
end

function PrintCondition(cond, fid)
%   PrintCondition(cond, fid)

    % print out general information
    ocurrences = length(cond.onset);
    fprintf(fid, '\tCONDITION             : %s\n', cond.name);
    fprintf(fid, '\tOCURRENCES            : %d\n', ocurrences);
    
    % print out condition onsets
    fprintf(fid, '\t\t ONSETS    : ');
    for k = 1:ocurrences-1
        fprintf(fid, '%-6.2f ', cond.onset(k)); 
    end
    fprintf(fid, '%-6.2f\n', cond.onset(end));
    
    % print out condition durations
    fprintf(fid, '\t\t DURATIONS : ');
    for k = 1:ocurrences-1
        fprintf(fid, '%-6.2f ', cond.duration(k));
    end
    fprintf(fid, '%-6.2f\n\n', cond.duration(end));
    
    % handle parametric regressors
    fprintf(fid, '\tPARAMETRIC REGRESSORS : %d\n', cond.usePMod);
    for i = 1:cond.usePMod
        fprintf(fid, '\t\tP REGRESSOR # %d\n', i);
        fprintf(fid, '\t\tNAME        : %s\n', cond.pmod(i).name);
        fprintf(fid, '\t\tPOLYNOMIAL  : %d\n', cond.pmod(i).poly);

        % print parameter values only if parametric regressor is being used (param is not empty)
        numParam = length(cond.pmod(i).param);
        if numParam == 0
            fprintf(fid, '\t\tPARAMETRIC REGRESSOR IS NOT BEING USED.\n');
        else
            fprintf(fid, '\t\tPARAM     : ');
            for k = 1:numParam-1
                fprintf(fid, '%-4.2f ', cond.pmod(i).param(k));
            end
            fprintf(fid, '%-4.2f\n', cond.pmod(i).param(end));
        end
    end
    fprintf(fid, '\n');
end
         
