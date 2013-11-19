function [Components VarAccounted]= SetRunCompCor(SubjectIndex, RunNumber, opt)
%   Components = SetCompCorReg(SubjectIndex, RunNumber, opt)
%
%   REQUIRED INPUT
%
%       opt.
%           Exp                 - string
%           SubjDir             - cell(N, 2)
%                                 column1 = subject name
%                                 column2 = vector of runs to include
%           RunDir              - cell(R, 1), list of run folders
%           CompCorTemplate     - cell(A, 2)
%                                 column1 = string, run specific comp cor prefix file template
%                                 column2 = scalar flag [1 2 3], regressors used 
%                                 column3 = scalar flag [1 2], component inclusion method
%                                 column4 = scalar, # of components  OR  minimal fractional variance explained
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

    % now if CompCor is being used
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

        % read in csv and log file
        AllRunComponents = csvread(ccCsv);
        AllVarAcc = ParseCompCorLog(ccLog);
        
        % add regressors based on CompUsedFlag value
        CompUsedFlag = opt.CompCorTemplate{iCompFile, 2};

        % global mean only
        if CompUsedFlag == 1

            FileComps = AllRunComponents(:, 1);
            VarAccounted(iCompFile) = 0;

        % components only
        elseif CompUsedFlag == 2

            CompIncMethod = opt.CompCorTemplate{iCompFile, 3};
            
            % add components based on component inclusion method
            % specified number of components
            if CompIncMethod == 1
                NumCompIncluded = opt.CompCorTemplate{iCompFile, 4};

                if NumCompIncluded > size(AllRunComponents, 2)
                    error(['SUBJECT %s RUN %s :\n' ...
                           ' COMPCOR: Number of components to include %d is greater the number of components present %d\n\n'], Subject, Run, NumRegIncluded, size(AllRunComponents, 2));
                end

                FileComps = AllRunComponents(:, 2:(1+NumCompIncluded));
                VarAccounted(iCompFile) = AllVarAcc(NumCompIncluded);

            % minimum fractional variance explained
            elseif CompIncMethod == 2

                MinVar = opt.CompCorTemplate{iCompFile, 4};

                % find out number of components to use
                CompToInclude = 1;
                while CompToInclude < length(AllVarAcc) && AllVarAcc(CompToInclude) < MinVar
                    CompToInclude = CompToInclude + 1;
                end

                % check to make sure enough components were present; otherwise error out
                if AllVarAcc(CompToInclude) < minVarExplained
                    error(['SUBJECT %s RUN %s :\n' ...
                           ' Not enough components present to for minimum variance %0.2f.  Only explained %0.2f variance\n\n'], Subject, Run, MinVar, AllVarAcc(CompToInclude));
                end

                FileComps = AllRunComponents(:, 2:(1+CompToInclude));
                VarAccounted(iCompFile) = AllVarAcc(CompToInclude);

            % invalid option that should never occur
            else
                error(['SUBJECT %s RUN %s :\n'...
                       ' COMPCOR: Invalid component inclusion method.\n'...
                       '          Expected [1 2] but found %d\n\n'], Subject, Run, CompIncMethod);
            end

        % both global mean and components
        elseif CompUsedFlag == 3
        
            CompIncMethod = opt.CompCorTemplate{iCompFile, 3};
            
            % add components based on component inclusion method
            % specified number of components
            if CompIncMethod == 1
                NumCompIncluded = opt.CompCorTemplate{iCompFile, 4};

                if NumCompIncluded > size(AllRunComponents, 2)
                    error(['SUBJECT %s RUN %s :\n' ...
                           ' COMPCOR: Number of components to include %d is greater the number of components present %d\n\n'], Subject, Run, NumRegIncluded, size(AllRunComponents, 2));
                end

                FileComps = AllRunComponents(:, 1:(1+NumCompIncluded));
                VarAccounted(iCompFile) = AllVarAcc(NumCompIncluded);

            % minimum fractional variance explained
            elseif CompIncMethod == 2

                MinVar = opt.CompCorTemplate{iCompFile, 4};

                % find out number of components to use
                CompToInclude = 1;
                while CompToInclude < length(AllVarAcc) && AllVarAcc(CompToInclude) < MinVar
                    CompToInclude = CompToInclude + 1;
                end

                % check to make sure enough components were present; otherwise error out
                if AllVarAcc(CompToInclude) < minVarExplained
                    error(['SUBJECT %s RUN %s :\n' ...
                           ' Not enough components present to for minimum variance %0.2f.  Only explained %0.2f variance\n\n'], Subject, Run, MinVar, AllVarAcc(CompToInclude));
                end

                FileComps = AllRunComponents(:, 1:(1+CompToInclude));
                VarAccounted(iCompFile) = AllVarAcc(CompToInclude);

            % invalid option that should never occur
            else
                error(['SUBJECT %s RUN %s :\n'...
                       ' COMPCOR: Invalid component inclusion method.\n'...
                       '          Expected [1 2] but found %d\n\n'], Subject, Run, CompIncMethod);
            end

        % invalid option that should never occur
        else
            error(['SUBJECT %s RUN %s :\n'...
                   ' COMPCOR: Invalid components used flag.\n'...
                   '          Expected [1 2 3] but found %d\n\n'], Subject, Run, CompUsedFlag);
        end

        % save components
        try
            tmpComponents = [tmpComponents FileComps];
        catch
            error(['SUBJECT %s RUN %s : \n' ...
                   ' COMPCOR: Invalid rows from file %s.'], Subject, Run, ccCsv);
        end
    end

    % create final Components structure
    % NOTE: checking for constant regressors and calculating derivatives may be added in future
    for iCompCor = 1:size(tmpComponents, 2)
        CompCorName = sprintf('CC%03d', iCompCor);
        Components(iCompCor).val = tmpComponents(:, iCompCor);
        Components(iCompCor).name = CompCorName;
    end
end        

function AllVarAcc = ParseCompCorLog(LogFile)
% function AllVarAcc = ParseCompCorLog(LogFile)
%
% This function parses the .log files output from pcafMRI from spm8Batch.
% It outputs the cumulative sum (column 3) of the variance accounted by the components.

    logFid = fopen(LogFile, 'r');
    LinesInHdr = 13;
    
    % currently the log file has a header that consists of 13 lines
    for iHeader = 1:LinesInHdr
        line = fgetl(logFid);
        if isnumeric(line) && line == -1
            error(['SUBJECT %s RUN %s :\n' ...
                   ' CompCor log file %s is incomplete\n\n'], Subject, Run, ccLog);
        end
    end

    % variance is stored in the third column
    pcaInfo = textscan(logFid, '%f%f%f\n');
    fclose(logFid);

    AllVarAcc = pcaInfo{3};

end
