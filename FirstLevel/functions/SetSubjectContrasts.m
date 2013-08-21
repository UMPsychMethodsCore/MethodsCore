function SubjectContrasts = SetSubjectContrasts(SubjectNumber, opt, OneSubj)
%   SubjectContrasts = SetSubjectContrasts(SubjectNumber, opt, SubjectSession)
%
%   REQUIRED INPUT
%
%       opt.
%           SubjDir             - cell(N, 3)
%                                 column1 = subject name
%                                 column2 = subject number in master data file
%                                 column3 = vector of runs to include
%           RunDir              - cell(M, 1)
%           ConditionName       - cell(C, 1) list of conditions as strings
%           ContrastList        - cell(L, C+2)
%                                 column1 = string, contrast name
%                                 columns 2 thru (C+1), vectors
%                                   first column in vector codes for conditon single run contrast
%                                   weight.  Second column codes for single run contrast weights
%                                   for the parametric regressors associated with the condition.
%                                 column(C+2) is a vector that codes for single contrasts weights
%                                   for the regressors.
%           ContrastRunWeights  - cell(L, 1)
%                                 each row codes for a run specific contrast
%           Basis               - string, either 'hrf' or 'fir'
%           HrfDerivative       - scalar, either [0 1 2], indcates if derivatives are being used 
%                                 for canonical hrf function
%           FirBins             - scalar, number of fir basis functions
%           
%
%       OneSubj.
%           name                - string, subject name
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
%                   names       - string, regressor name
%               useCompCor      - scalar, if equal 1, then CompCor is used in model
%               varExplained    - vector, variance explained for each CompCor file
%               compCor(*).
%                   val         - vector, lists one component for CompCor
%                   name        - string, CompCor name
%
%   OUTPUT
%
%       SubjectContrasts        - matrix, contains contrast vectors as created by 
%                                 opt.ContrastList and opt.ContrastRunWeights

    Subject = opt.SubjDir{SubjectNumber, 1};
    NumCond = size(opt.ConditionName, 1);
    NumRuns = size(OneSubj.sess, 2);
    NumContrasts = size(opt.ContrastList, 1);
    
    % find out number of bases used
    if strcmp(opt.Basis, 'hrf')
        if opt.HrfDerivative == 0
            NumBases = 1;
        elseif opt.HrfDerivative == 1
            NumBases = 2;
        else
            NumBases = 3;
        end
    else
        NumBases = opt.FirBins;
    end

    % find out the maximum number of regressors from all runs
    MaxNumRegRun = 0;
    for i = 1:NumRuns
        if OneSubj.sess(i).useRegress == 1 && size(OneSubj.sess(i).regress, 2) > MaxNumRegRun
            CurRegNum = size(OneSubj.sess(i).regress, 2);
            if CurRegNum > MaxNumRegRun
                MaxNumRegRun = CurRegNum;
            end
        end
    end

    % create contrast scales
    [CondScaling RegScaling] = CreateContrastScales(OneSubj, NumCond, MaxNumRegRun);

    % scale each contrast row
    for i = 1:NumContrasts
        opt.ContrastList(i, :) = ScaleContrastRow(NumCond, opt.ContrastList(i, :), NumBases, CondScaling, NumRuns, RegScaling);
    end

    % create contrast matrix for each run for this subject
    tmpSess(NumRuns) = struct('Contrasts', []);
    for i = 1:NumRuns
        tmpSess(i).Contrasts = SetRunContrasts(OneSubj.name, NumBases, opt, OneSubj.sess(i));
    end

    % correct contrast runweight lenghts
    for i = 1:NumContrasts

        if isempty(opt.ContrastRunWeights{i}) == 1

            opt.ContrastRunWeights{i} = ones(1, NumRuns);

        elseif length(opt.ContrastRunWeights{i}) > NumRuns

            msg = sprintf(['SUBJECT %s :\n' ...
                           ' Contrast run weight #%d is longer than the number of specified runs %d.\n' ...
                           ' Trimming the contrast run weight to the number of available runs.\n' ...
                           ' If ContrastRunWeight was specified for this contrast numbber, it may be invalid.\n\n'], Subject, i, NumRuns);
            fprintf(1, msg);
            mc_Logger('log', msg, 2);

            try
                RunList = opt.SubjecDir{SubjectNumber, 3};
                opt.ContrastRunWeights{i} = opt.ContrastRunWeights{i}(RunList);
            catch err
                msg = sprintf(['SUBJECT %s :\n' ...
                               ' RunWeight correction failed.  RunList from SubjDir{%d, 3} exceeds ContrastRunWeight #%d length.\n' ...
                               ' Manually trimming ContrastRunWeight as correction.  Contrast #%d may be invalid.\n\n'], Subject, SubjectNumber, i, i);
                fprintf(1, msg);
                mc_Logger('log', msg, 2);
                opt.ContrastRunWeights{i} = opt.ContrastRunWeights{i}(1:NumRuns);
            end
        
        elseif length(opt.ContrastRunWeights{i}) < NumRuns

            msg = sprintf(['SUBJECT %s :\n' ...
                           'ContrastRunWeight number %d is less than the number of runs present (%d).  Weighting extra runs as zero.\n\n'], Subject, i, NumRuns);

            extraWeights = NumRuns - length(opt.ContrastRunWeights{i});
            opt.ContrastRunWeights{i} = [opt.ContrastRunWeights{i} zeros(1, extraWeights)];
 
        end

    end

    % scale run weights appropriately
    for iContrast = 1:NumContrasts
        RunWeighting = opt.ContrastRunWeights{iContrast};

        % Calculate positive and negative weighting and NumRunIncluded
        PosOneIndex = RunWeighting == 1;
        NegOneIndex = RunWeighting == -1;
        PosWeight = sum(PosOneIndex);
        NegWeight = sum(NegOneIndex);
        NumRunIncluded = max(PosWeight, NegWeight);

        % calcualte contrast weight sum accross runs; used for weight correction below
        ContrastBaseSum = 0;
        for i = 1:NumRuns
            ContrastBaseSum = ContrastBaseSum + sum(tmpSess(i).Contrasts(iContrast, :));
        end

        % perform weight correction
        if ContrastBaseSum == 0 && PosWeight > 0 && NegWeight > 0
            NumRunIncluded = NumRunInclude * 2;
        end

        if PosWeight == 0
            PosWeight = 1;
        end

        if NegWeight == 0
            NegWeight = 1;
        end

        if PosWeight == NegWeight
            PosWeight = 1;
            NegWeight = 1;
        end

        % adjust the run weighting
        RunWeighting(RunWeighting > 0) = RunWeighting(RunWeighting > 0) .* NegWeight;
        RunWeighting(RunWeighting < 0) = RunWeighting(RunWeighting < 0) .* PosWeight;

        opt.ContrastRunWeights{iContrast} = RunWeighting * 1 / NumRunIncluded;
    end

    % apply the run weighting now
    for i = 1:NumRuns
        for k = 1:NumContrasts
            tmpSess(i).Contrasts(k, :) = tmpSess(i).Contrasts(k, :) .* opt.ContrastRunWeights{k}(i);
        end
    end

    % concatanate runs together to create the contrast matrix
    SubjectContrasts = [];
    for i = 1:NumRuns
        SubjectContrasts = [SubjectContrasts tmpSess(i).Contrasts];
    end

    % finally zero pad contrast matrix for the constant regressors
    SubjectContrasts = [SubjectContrasts zeros(NumContrasts, NumRuns)];

    % do some final checking of contrast matrix

end

function [CondScaling RegScaling] = CreateContrastScales(Subject, NumCond, MaxNumRegRun)
% [CondScaling RegScaling] = CreateContrastScales(Suhbject, NumRuns, NumCond, MaxNumRegRun)
%
%   INPUT
%
%       Subject      - subject object
%       NumComd      - number of conditions used in experiment
%       MaxNumRegRun - maximum number of regressors used in a run
%
%   OUTPUT
%
%       CondScaling(C).
%         weight     - the weight value for the condition contrast vector.  It is determined
%                      by the number of runs the condition is present
%         pmod(P).   - field is only present and not empty if parametric regressors are being 
%                      used with the condition
%             weight - The weight value for the parametric condition.  It is determined by the 
%                      number of runs the parametric regressor is present.
%             order  - the order for the parametric regressor
%
%       RegScaling   - vector, holds the regressor scaling factors

    CondScaling = struct('weight', 0);
    CondScaling = repmat(CondScaling, 1, NumCond);
    RegScaling = zeros(1, MaxNumRegRun);
    NumRuns = size(Subject.sess, 2);

    % fill in scaling structure
    for i = 1:NumRuns

        for k = 1:NumCond

            % take care of condition scaling
            if Subject.sess(i).cond(k).use == 1
                CondScaling(k).weight = CondScaling(k).weight + 1;
            end

            % take care of associated parametric regressor scaling for condition
            if Subject.sess(i).cond(k).usePMod > 0

                NumParaForCond = size(Subject.sess(i).cond(k).pmod, 2);
                CondScaling(k).pmod(NumParaForCond) = struct('weight', 0, 'order', []);

                for iPar = 1:NumParaForCond

                    if ~isempty(Subject.sess(i).cond(k).pmod(iPar).param) == 1
                        CondScaling(k).pmod(iPar).weight = CondScaling(k).pmod(iPar).weight + 1;
                    end
                    CondScaling(k).pmod(iPar).order = Subject.sess(i).cond(k).pmod(iPar).poly;
                end
            end
        end

        % take care of regressor scaling if regressors are present
        if Subject.sess(i).useRegress == 1
            NumRegThisRun = size(Subject.sess(i).regress, 2);
            for k = 1:MaxNumRegRun

                if k > NumRegThisRun
                    break;
                else
                    RegScaling(k) = RegScaling(k) + 1;
                end
            end
        end
    end
end    
    
                        
function ContrastRow = ScaleContrastRow(NumCond, ContrastRow, NumBases, CondScaling, NumRuns, RegScaling)
% ContrastRow = ScalContrastRow(NumCond, ContrastRow, NumBases, CondScaling)

    for k = 1:NumCond
    
        if CondScaling(k).weight == 0
            % add 1 to account for contrast name
            ContrastRow{k + 1} = ContrastRow{k + 1} .* 0;
        else
            TmpConVec = ContrastRow{k + 1};
            TmpConVec(1:NumBases) = TmpConVec(1:NumBases) * (NumRuns / CondScaling(k).weight);
    
            % scale parametric regressors if present for condition
            if isfield(CondScaling(k), 'pmod') == 1 && ~isempty(CondScaling(k).pmod) == 1
    
                NumPara = size(CondScaling(k).pmod, 2);
                StartIndex = NumBases + 1;
    
                for iPar = 1:NumPara
    
                    EndIndex = StartIndex + CondScaling(k).pmod(iPar).order - 1;
                    ParaWeight = NumRuns / CondScaling(k).pmod(iPar).weight;
                    TmpConVec(StartIndex:EndIndex) = TmpConVec(StartIndex:EndIndex) .* ParaWeight;
                    StartIndex = EndIndex + 1;
                end
            end
    
            ContrastRow{k + 1} = TmpConVec;
        end
    end
    
    %scale regressors if present
    if ~isempty(ContrastRow{NumCond + 2}) == 1
        RegConVec = ContrastRow{NumCond + 2};
        for k = 1:length(RegConVec)
            RegConVec(k) = RegConVec(k) * NumRuns / RegScaling(k);
        end
        ContrastRow{NumCond + 2} = RegConVec;
    end

end

