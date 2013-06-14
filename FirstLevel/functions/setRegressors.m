function subjectInfo = setRegressors(opt, subjectInfo)
%   subjectInfo = setRegressors(opt, subjectInfo)
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
%   OPTIONAL INPUT
%
%       NONE ;)
%  
%   OUTPUT
%
%       subjectInfo(N).
%           sess(Y).
%               useRegress      - scalar, if equals 1, then regressors should be used in model
%               regress(Z).
%                   val         - vector, lists one regressors
%                   names       - cell(C, 1), list of regressor names
%                                 placeholders in the form of R### are inserted
%
%   N = number of subjects
%   R = number of runs
%   M = number of regressor files
%   I = number of volumes in a single sess
%   C = number of regressors used in a single sess
%

    % handle a very simple case :)
    if isempty(opt.RegFilesTemplate) == 1
        
        msg = sprintf('No regressor files are being used for any subject model\n');
        fprintf(1, msg);
        mc_Logger('log', msg, 3);

        for i = 1:size(SubjDir, 1);
            for k = 1:length( opt.SubjDir{i, 2} )
                subjectInfo(i).sess(k).useRegress = 0;
            end
        end

        return;
    end

    % now if regressors are present
    Exp = opt.Exp;
    NumSubjects = size(opt.SubjDir, 1);
    for i = 1:NumSubjects

        Subject = opt.SubjDir{i, 1};
        NumRuns = length( opt.SubjDir{i, 2} );

        for k = 1:NumRuns

            Run = opt.RunDir{ opt.SubjDir{i, 3}(k), 1 };

            for iRegFile = 1:size(opt.RegFilesTemplate)

                % RegMatrix = readRegFile(Exp, Subject, Run, RegFile)
                RegFileCheck.Template = opt.RegFilesTemplate{iRegFile, 1};
                RegFileCheck.mode = 'check';
                RegFile = mc_GenPath(RegFileCheck);
                RegMatrix = load(RegFile);

                if isempty(RegMatrix) == 1
                    msg = sprintf(['Regessor file %s\n' ...
                                   ' has no regressors for subject %s run %s\n\n'], ...
                                   RegFile, Subject, Run);
                    fprintf(1, msg);
                    mc_Logger('log', msg, 2);
                    subjectInfo(i).sess(k).useRegress = false;
                    continue;
                end

                % trim regressors if needed
                % RegMatrix = trimRegMatrix(RegMatrix, RegNumCol) ~ continue
                RegNumCol = opt.RegFilesTemplate{iRegFile, 2};
                if ~isinf(RegNumCol) == 1

                    % check if number to keep is bigger then present
                    if RegNumCol > size(RegMatrix, 2)
                        msg = sprintf(['Regressor file %s\n' ...
                                       ' has %d regressors is less than %d regressors to keep.'...
                                       '  Keeping all regressors present.\n\n'], ...
                                       RegFile, size(RegMatrix, 2), RegNumCol);
                        fprintf(1, msg);
                        mc_Logger('log', msg, 2);
                    else
                        RegMatrix = RegMatrix(:, 1:RegNumCol);
                    end

                    % handle if all regressors are removed
                    if isempty(RegMatrix) == 1
                        msg = sprintf(['Regressor file %s\n' ...
                                       ' lost all regresors after trimming for subject %s' ...
                                       ' run %s\n\n'], RegFile, Subject, Run);
                        fprintf(1, msg);
                        mc_Logger('log', msg, 2);
                        subjectInfo(i).sess(k).useRegress = false;
                        continue;
                    end
                end

                % remove constant regressors
                % RegMatrix = removeConstRegressors(RegMatrix)
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
                        msg = sprintf(['Regressor file %s\n' ...
                                       ' had all constant regressors.  Subject %s run %s' ...
                                       ' will not be using any regressors.\n\n'], ...
                                       RegFile, Subject, Run);
                        fprintf(1, msg);
                        mc_Logger('log', msg, 2);
                        subjectInfo(i).sess(k).useRegress = false;
                        continue;
                    else
                        msg = sprintf(['%s\n' ...
                                       '   Found %d regressors and removed %d constant' ...
                                       ' regressors for subject %s in run %s\n'], ...
                                       NumReg, length(RegColToRemove), Subject, Run);
                        fprintf(1, mgs);
                        mc_Logger('log', msg, 3);
                    end
                end
                        
                % calculate and add derivatives if need be
                % RegMatrix = addDerivatives(RegMatrix, Order, ConstantColumsRemoved)
                doDerivativeFlag = true;
                RegDerivOrder = opt.RegFilesTemplate{iRegFile, 3};
                if RegDerivOrder > size(RegMatrix, 1) 
                    if length(RegColToRemove) ~= NumReg
                        error(['ERROR: Invalid derivative order for subject %s run %s.\n' ...
                               '       Using regressor file %s\n'], Subject, Run, RegFile);
                    else
                        msg = sprintf(['Cannot add derivatives for regressor file %s\n' ...
                                       'All regressors were constant and thus removed.\n'], ...
                                       RegFile);
                        fprintf(1, msg);
                        mc_Logger('log', msg, 3);
                        doDerivativeFlag = false;
                    end
                end

                % finally add derivates if good to go
                if RegDerivOrder > 0 && doDerivativeFlag

                    NumVolumes = size(RegMatrix, 1);

                    tmpRegMatrix = RegMatrix;
                    DerivativesIncluded = 0;
                    LastDerivEndCol = size(RegMatrix, 2);

                    for iDeriv = 1:RegDerivOrder

                        for iRegMatrix = 1:size(tmpRegMatrix, 2)

                            tmpDeriv = diff( tmpRegMatrix(:, iRegMatrix) );
                            tmpDeriv = resample(tmpDeriv, NumVolumes, length(tmpDeriv));

                            % check to make sure derivative is not a constant now
                            if ~all( tmpDeriv(1) == tmpDeriv )
                                
                                RegMatrix(:, end+1) = tmpDeriv;
                                DerivativesIncluded = DerivativesIncluded + 1;

                            else

                                msg = sprintf(['RegFile %s\n' ...
                                               ' had a constant derivative for %dth' ...
                                               ' derivative. Not including it or any' ...
                                               ' higher derivatives for regressor number %d\n\n'], ...
                                                RegFile, iDeriv, iRegMatrix);
                                fprintf(1, msg);
                                mc_Logger('log', msg, 2);

                            end

                        end

                        if DerivativesIncluded == 0

                            msg = sprintf(['Regfile %s\n' ...
                                           ' had all constant derivatives for order %d' ...
                                           ' Only including derivatives up to the %dth order'], ...
                                           RegFile, iDeriv, iDeriv - 1);
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

            % end of RegFileTemplate loop
            end
            
            % now we need to save to subjectInfo
            for iRegMatrix = 1:size(RegMatrix, 2)

                RegName = sprintf('R%03d', iRegMatrix);
                subjectInfo(i).sess(k).regress(iRegMatrix).val = RegMatrix(:, iRegMatrix);
                subjectInfo(i).sess(k).regress(iRegMatrix).name = RegName;

            end
            
%            subject

            % end of run loop
        end

        % end of subject loop
    end

end


function RegMatrix = readRegFile(Exp, Subject, Run, RegFile)

    RegFileCheck.Template = opt.RegFilesTemplate{iRegFile, 1};
    RegFileCheck.mode = 'check';
    RegFile = mc_GenPath(RegFileCheck);
    RegMatrix = load(RegFile);
    
    if isempty(RegMatrix) == 1
        msg = sprintf(['Regessor file %s\n' ...
                       ' has no regressors for subject %s run %s\n\n'], ...
                       RegFile, Subject, Run);
        fprintf(1, msg);
        mc_Logger('log', msg, 2);
        subjectInfo(i).sess(k).useRegress = false;
        continue;
    end
end
