function [Components VarAccounted]= SetRunCompCor(SubjectIndex, RunNumber, opt)
%   Components = SetCompCorReg(SubjectIndex, RunNumber, opt)
%
%   REQUIRED INPUT
%
%       opt.
%           Exp                 - string
%           SubjDir             - cell(N, 3)
%                                 column1 = subject name
%                                 column2 = subject number in master data file
%                                 column3 = vector of runs to include
%           RunDir              - cell(R, 1), list of run folders
%           CompCorTemplate     - cell(A, 2)
%                                 column1 = run specific compcor file template
%                                 column2 = minimum fraction variance explained
%                                 Templates : Exp Subject Run
%
%   OUPTUT
%
%       Components(*).
%           val                 - vector, lists one component
%           name                - string, component name
%                                 placeholders in the form of CC### are inserted
%       VarAccounted            - vector, contains the variance accounted for each log/csv pair
%
%   N = number of subjects
%   R = number of runs
%   A = number of comp cor files
%

    Exp = opt.Exp;
    Subject = opt.SubjDir{SubjectIndex, 1};
    Run = opt.RunDir{ RunNumber };
    Components = [];
    VarAccounted = [];

    % handle a very simple case :)
    if isempty(opt.CompCorTemplate) == 1
        return;
    end

    % now if comp cor is being used
    tmpComponents = [];
    numFiles = size(opt.CompCorTemplate, 1);
    VarAccounted = zeros(numFiles, 1);
    for iCompFile = 1:numFiles

        % check log and csv files
        prefix = opt.CompCorTemplate{iCompFile, 1};
        ccLogCheck.Template = strcat(prefix, '*log');
        ccLogCheck.mode = 'check';
        ccLog = mc_GenPath(ccLogCheck);

        ccCsvCheck.Template = strcat(prefix, '*csv');
        ccCsvCheck.mode = 'check';
        ccCsv = mc_GenPath(ccCsvCheck);

        % read log file to determine number of components to use
        logFid = fopen(ccLog, 'r');

        % currently the log file has a header that consists of 13 lines
        for iHeader = 1:13
            line = fgetl(logFid);
            if isnumeric(line) && line == -1
                error(['SUBJECT %s RUN %s :\n' ...
                       ' CompCor log file %s is incomplete\n\n'], Subject, Run, ccLog);
            end
        end
        % variance is stored in the third column
        pcaInfo = textscan(logFid, '%f%f%f\n');
        fclose(logFid);
        
        % now find out the number of components used using the minimum variance explained
        minVarExplained = opt.CompCorTemplate{iCompFile, 2};
        pcaIndex = 1;
        while pcaIndex < size(pcaInfo{1, 3}, 1) && pcaInfo{1, 3}(pcaIndex) < minVarExplained
            pcaIndex = pcaIndex + 1;
        end
        
        % check to make sure enough components were present; otherwise error out
        if pcaInfo{1, 3}(pcaIndex) < minVarExplained
            error(['SUBJECT %s RUN %s :\n' ...
                   ' Not enough components present to for minimum variance %0.2f.  Only explained %0.2f variance\n\n'], Subject, Run, minVarExplained, pcaInfo{1, 3}(pcaIndex));
        end

        % read in components
        allRunComponents = csvread(ccCsv);
        try
            tmpComponents = [tmpComponents allRunComponents(:, 1:pcaIndex)];
        catch
            error(['SUBJECT %s RUN %s : \n' ...
                   ' Failed to add components from file %s.'], Subject, Run, ccCsv);
        end

        % save variance explained
        VarAccounted(iCompFile) = pcaInfo{1, 3}(pcaIndex);
    end

    % create final Components structure
    % NOTE: checking for constant regressors and calculating derivatives may be added in future
    for iCompCor = 1:size(tmpComponents, 2)
        CompCorName = sprintf('CC%03d', iCompCor);
        Components(iCompCor).val = tmpComponents(:, iCompCor);
        Components(iCompCor).name = CompCorName;
    end
end        

