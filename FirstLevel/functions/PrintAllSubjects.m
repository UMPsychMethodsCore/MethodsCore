function PrintAllSubjects(Subjects, opt)
%   PrintAllSubjects(Subjects, opt)

    Exp = opt.Exp;
    textPath = mc_GenPath(opt.LogTemplate);
    textFile = sprintf('SubjectSummary_%s.txt', datestr(now, 'yyyy_mm_dd_HHMMSSFFF'));
    outputFile = fullfile(textPath, textFile);
    fid = fopen(outputFile, 'w');
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
            PrintRun(Subjects(i).sess(k), Subjects(i).name, fid);
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

function PrintRun(sess, subjectName, fid)
%   PrintRun(sess, subjectName, fid)
%   assumes sess is not empty, but still might work if it is

    lineHeader = sprintf('\tSUBJECT : %-20s RUN : %-10s', subjectName, sess.name);

    fprintf(fid, '%s TIMEPOINTS : %d\n', lineHeader, size(sess.images, 1));
    % print out condition information
    NumCond = size(sess.cond, 2);
    fprintf(fid, '%s NUMBER OF CONDITIONS : %d\n\n', lineHeader, NumCond);
    for i = 1:NumCond

        if sess.cond(i).use == 1
            PrintCondition(sess.cond(i), subjectName, sess.name, fid)
        else
            fprintf(fid, '%s CONDITION %s IS NOT BEING USED.\n', lineHeader, sess.cond(i).name);
        end

    end

    % print out regressor information if being used
    if sess.useRegress == 1
        numRegress = size(sess.regress, 2);
        fprintf(fid, '%s REGRESSORS  : %d\n', lineHeader, numRegress);
    else
        fprintf(fid, '%s REGRESSORS  : 0\n', lineHeader);
    end
    fprintf(fid, '\n');
end

function PrintCondition(cond, subjectName, runName, fid)
%   PrintCondition(cond, fid)

    lineHeader = sprintf('\tSUBJECT : %-20s RUN : %-10s CONDITION : %-15s', subjectName, runName, cond.name);

    % print out general information
    ocurrences = length(cond.onset);
    fprintf(fid, '%s OCURRENCES : %d\n', lineHeader, ocurrences);
    
    % print out condition onsets
    fprintf(fid, '%s ONSETS : ', lineHeader);
    for k = 1:ocurrences-1
        fprintf(fid, '%-6.2f ', cond.onset(k)); 
    end
    fprintf(fid, '%-6.2f\n', cond.onset(end));
    
    % print out condition durations
    fprintf(fid, '%s DURATIONS : ', lineHeader);
    for k = 1:ocurrences-1
        fprintf(fid, '%-6.2f ', cond.duration(k));
    end
    fprintf(fid, '%-6.2f\n', cond.duration(end));
    
    % handle parametric regressors
    fprintf(fid, '%s PARAMETRIC REGRESSORS : %d\n', lineHeader, cond.usePMod);
    for i = 1:cond.usePMod
        fprintf(fid, '%s P REGRESSOR # %d\n', lineHeader, i);
        fprintf(fid, '%s NAME        : %s\n', lineHeader, cond.pmod(i).name);
        fprintf(fid, '%s POLYNOMIAL  : %d\n', lineHeader, cond.pmod(i).poly);

        % print parameter values only if parametric regressor is being used (param is not empty)
        numParam = length(cond.pmod(i).param);
        if numParam == 0
            fprintf(fid, '%s PARAMETRIC REGRESSOR %s IS NOT BEING USED.\n', lineHeader, cond.pmod(i).name);
        else
            fprintf(fid, '%s PNAME %s PARAM     : ', lineHeader, cond.pmod(i).name);
            for k = 1:numParam-1
                fprintf(fid, '%-4.2f ', cond.pmod(i).param(k));
            end
            fprintf(fid, '%-4.2f\n', cond.pmod(i).param(end));
        end
    end
    fprintf(fid, '\n');
end
         
