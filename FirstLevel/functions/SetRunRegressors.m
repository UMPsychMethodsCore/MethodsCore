function Regressors = SetRunRegressors(SubjectNumber, RunNumber, opt)
%   Regressors = SetRunRegressors(SubjectNumber, RunNumber, opt)
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
%           RegFilesTemplate    - cell(M, 2)
%                                 column1 = run specific regressor file template
%                                 column2 = number of regressors to inclucde from file
%                                           a value of inf includes all regressors
%                                 column3 = number of derivatives to calculate for regressor
%                                           a value equal to or less than 0 does not calculate
%                                           any derivatives for the regressor
%                                 Templates : Exp Subject Run
%  
%   OUTPUT
%
%       Regressors(Z).
%           val         - vector, lists one regressors
%           names       - string, regressor name
%                         placeholders in the form of R### are inserted
%
%   N = number of subjects
%   R = number of runs
%   M = number of regressor files
%   I = number of volumes in a single sess
%   C = number of regressors used in a single sess
%
%   This function appropriately creates the regressor structure on a per session basis.
%

    Exp = opt.Exp;
    Subject = opt.SubjDir{SubjectNumber, 1};
    Run = opt.RunDir{ RunNumber };
    Regressors = [];

    % handle a very simple case :)
    if isempty(opt.RegFilesTemplate) == 1
        return;
    end

    % now if regressors are present
    tmpRegressors = [];
    for iRegFile = 1:size(opt.RegFilesTemplate, 1)

        % get files
        RegFile = opt.RegFilesTemplate{iRegFile, 1};
        RegMatrix = readRegFile(Exp, Subject, Run, RegFile);
        if isempty(RegMatrix) == 1
            continue;
        end

        % trim regressors
        ColumnsToKeep = opt.RegFilesTemplate{iRegFile, 2};
        RegMatrix = trimRegressor(Subject, Run, RegFile, ColumnsToKeep, RegMatrix);
        if isempty(RegMatrix) == 1
            continue;
        end
            
        % remove constant regressors
        RegMatrix = removeConstantColumns(Subject, Run, RegFile, RegMatrix);
        if isempty(RegMatrix) == 1
            continue;
        end

        % calculate and add derivatives if need be
        Order = opt.RegFilesTemplate{iRegFile, 3};
        RegMatrix = addDerivatives(Subject, Run, RegFile, Order, RegMatrix);

        try
            tmpRegressors = [tmpRegressors RegMatrix];
        catch err
            error(['SUBJECT %s RUN %s :\n' ...
                   ' RegFile %s does not have the same number of rows as the other regressors.'], Subject, Run, RegFile);
        end

    end
            
    % now we need to save to as structure
    if isempty(tmpRegressors) == 0

        for iRegMatrix = 1:size(tmpRegressors, 2)

            RegName = sprintf('R%03d', iRegMatrix);
            Regressors(iRegMatrix).val = tmpRegressors(:, iRegMatrix);
            Regressors(iRegMatrix).name = RegName;

        end
        
    else

        msg = sprintf(['SUBJECT %s RUN %s :\n'...
                       ' All regressor files were trimmed to nothing.'], Subjec, Run);
        fprintf(msg);
        mc_Logger('log', msg, 2);

    end
end


function RegMatrix = readRegFile(Exp, Subject, Run, RegFile)

    RegFileCheck.Template = RegFile;
    RegFileCheck.mode = 'check';
    RegFile = mc_GenPath(RegFileCheck);
    RegMatrix = load(RegFile); % have to improve mc_CsvRead before switching to it
    
    if isempty(RegMatrix) == 1
        msg = sprintf(['SUBJECT %s RUN %s :\n' ...
                       ' Regessor file %s has no regressors\n\n'], Subject, Run, RegFile);
        fprintf(1, msg);
        mc_Logger('log', msg, 2);
    end

end

function RegMatrix = trimRegressor(Subject, Run, RegFile, ColumnsToKeep, RegMatrix)

    if ~isinf(ColumnsToKeep) == 1
    
        % check if number to keep is bigger then present
        if ColumnsToKeep > size(RegMatrix, 2)
            msg = sprintf(['SUBJECT %s RUN %s :\n' ...
                           ' Regressor file %s\n has %d regressors which is less than %d regressors to keep.\n'...
                           ' Keeping all regressors present.\n\n'], ...
                           Subject, Run, RegFile, size(RegMatrix, 2), ColumnsToKeep);
            fprintf(1, msg);
            mc_Logger('log', msg, 2);
        else
            RegMatrix = RegMatrix(:, 1:RegNumCol);
        end
    
        % handle if all regressors are removed
        if isempty(RegMatrix) == 1
            msg = sprintf(['SUBJECT %s RUN %s :\n' ...
                           ' Regressor file %s lost all regresors after user trimming.\n\n'], Subject, Ru, RegFile);
            fprintf(1, msg);
            mc_Logger('log', msg, 2);
        end
    end

end

function RegMatrix = removeConstantColumns(Subject, Run, RegFile, RegMatrix)

    NumReg = size(RegMatrix, 2);
    RegColToRemove = [];
    for iRegMatrix = 1:NumReg
        if all( RegMatrix(:, iRegMatrix) == RegMatrix(1, iRegMatrix) )
            RegColToRemove(end+1) = iRegMatrix;
        end
    end
    
    if ~isempty(RegColToRemove) == 1
    
        RegMatrix(:, RegColToRemove) = [];
    
        if isempty(RegMatrix)
            msg = sprintf(['SUBJECT %s RUN %s :\n' ...
                           ' Regressor file %s had all constant regressors.  No Regressors will be used.\n\n'], ...
                           RegFile, Subject, Run);
            fprintf(1, msg);
            mc_Logger('log', msg, 2);
        else
            msg = sprintf(['SUBJECT %s RUN %s :\n' ...
                           ' For regressor file %s found %d regressors and removed %d constant regressors.\n\n'], ...
                           Subject, Run, RegFile, NumReg, length(RegColToRemove));
            fprintf(1, msg);
            mc_Logger('log', msg, 3);
        end
    end

end

function RegMatrix = addDerivatives(Subject, Run, RegFile, Order, RegMatrix)

    if Order > size(RegMatrix, 1) 
        error(['ERROR: SUBJECT %s RUN %s\n' ...
               ' Invalid derivative order using regressor file %s\n'], Subject, Run, RegFile);
    end
    
    if Order > 0
    
        NumVolumes = size(RegMatrix, 1);
    
        tmpRegMatrix = RegMatrix;
        DerivativesIncluded = 0;
        LastDerivEndCol = size(RegMatrix, 2);
    
        for iDeriv = 1:Order
    
            for iRegMatrix = 1:size(tmpRegMatrix, 2)
    
                tmpDeriv = diff( tmpRegMatrix(:, iRegMatrix) );
                tmpDeriv = resample(tmpDeriv, NumVolumes, length(tmpDeriv));
    
                % check to make sure derivative is not a constant now
                if all( tmpDeriv(1) == tmpDeriv ) == 0
                    
                    RegMatrix(:, end+1) = tmpDeriv;
                    DerivativesIncluded = DerivativesIncluded + 1;
    
                else
    
                    msg = sprintf(['SUBJECT %s RUN %s :\n' ...
                                   ' RegFile %s had a constant derivative for %dth derivative.\n' ...
                                   ' Not including it or any higher derivatives for regressor number %d\n\n'], ...
                                    Subject, Run, RegFile, iDeriv, iRegMatrix);
                    fprintf(1, msg);
                    mc_Logger('log', msg, 2);
    
                end
    
            end
    
            if DerivativesIncluded == 0
    
                msg = sprintf(['SUBJECT %s RUN %s :\n' ...
                               ' Regfile %s had all constant derivatives for order %d\n' ...
                               ' Only including derivatives up to the %dth order\n\n'], ...
                               Subject, Run, RegFile, iDeriv, iDeriv - 1);
                fprintf(1, msg);
                mc_Logger('log', msg, 2);
                break;
    
            else
    
                % now update variables
                tmpRegMatrix = RegMatrix(:, LastDerivEndCol+1:end);
                DerivativesIncluded = 0;
                LastDerivEndCol = size(RegMatrix, 2);
    
            end
        end
    end
end
