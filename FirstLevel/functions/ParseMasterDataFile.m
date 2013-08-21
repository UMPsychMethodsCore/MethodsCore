function SubjectMasterData = ParseMasterDataFile(opt)
%   SubjectMasterData = ParserMasterDataFile(opt)
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
%           MasterDataFilePath  - string, path to master data file
%                                 templates permitted : [Exp]
%           MasterDataSkipRows  - number of rows to skip in master data file
%           MasterDataSkipCols  - number of columns to skip in master data file
%           SubjColumn          - vector
%           RunColumn           - vector
%           CondColumn          - vector
%           TimeColumn          - vector
%           DurationColumn      - vector
%           ParametricList      - cell(P, 4)
%                                 column1 = paramatric name
%                                 column2 = column in master data file
%                                 column3 = condition number as listed in ConditionName
%                                 column4 = order
%
%   OUTPUT
%
%       SubjectMasterData(N).
%           sess(R).
%               RunData         - matrix, contains all the subject data from the master data file 
%                                 for run y
%
    Exp = opt.Exp;
    MasterDataFileCheck.Template = opt.MasterDataFilePath;
    MasterDataFileCheck.Mode = 'check';
    MasterDataFile = mc_GenPath(MasterDataFileCheck);

    % read in master data file
    try
        AllData = csvread(MasterDataFile, opt.MasterDataSkipRows, opt.MasterDataSkipCols);
    catch err
        error(['ERROR: Failed to read master data file %s.\n' ...
               ' Check that the headers are skipped using MasterDataSkipRows and MasterDataSkipCols.\n' ...
               ' Current values MasterDataSkipRows : %d MasterDataSkipCols %d'], ...
               MasterDataFile, opt.MasterDataSkipRows, opt.MasterDataSkipCols);
    end

    % check none of the columns exceed columns present in master data file
    ColumnsInMasterDataFile = size(AllData, 2);
    if opt.SubjColumn > ColumnsInMasterDataFile
        error(['ERROR: Corrected SubjColumn value exceeds the number of columns present in the master data file.  Expected a value less than or equal to %d'], ColumnsInMasterDataFile);
    end

    if opt.RunColumn > ColumnsInMasterDataFile
        error(['ERROR: Corrected RunColumn value exceeds the number of columns present in the master data file.  Expected a value less than or equal to %d'], ColumnsInMasterDataFile);
    end
        
    if any([opt.CondColumn opt.TimeColumn opt.DurationColumn] > ColumnsInMasterDataFile) == 1
        error('ERROR: CondColumn TimeColumn and DurationColumn must contain values less than or equal to the number of columns in the master data file.  Expected a value less than or equal to %d', ColumnsInMasterDataFile);
    end

    % do the same for parametric regressors
    for i = 1:size(opt.ParametricList)
        if opt.ParametricList{i, 2} > ColumnsInMasterDataFile
            error('ERROR: Master data file column specified for parametric regressor %s exceeds the number of column in the master data file.  Expected a value less than or equal to %d.', ColumnsInMasterDataFile);
        end
    end

    % do a simple check to make sure times and durations are not in milliseconds
    for i = 1:length(opt.TimeColumn)
    
        if any( AllData(:, opt.TimeColumn(i)) ) > 5000
            error(['ERROR: Detected TimeColumn %d has a value greater than 5000.\n' ...
                   '       Expected timing to be in seconds.'], i);
        end

        if any( AllData(:, opt.DurationColumn(i)) ) > 5000
            error(['ERROR: Detected DurationColumn %d has a value greater than 5000.\n' ...
                   '       Expected timing to be in seconds.'], i);
        end

    end

    NumSubjects = size(opt.SubjDir, 1);
    SubjectMasterData(NumSubjects) = struct();
    % now let's start parsing the master data file
    for i = 1:NumSubjects

        if opt.IdenticalModels == 1
            SubjectData = AllData(1:opt.TotalTrials, :);
        else
            SubjectIndex = AllData(:, opt.SubjColumn) == opt.SubjDir{i, 2};
            SubjectData = AllData(SubjectIndex, :);
        end

        NumRuns = length( opt.SubjDir{i, 3} );

        for k = 1:NumRuns

            RunIndex = SubjectData(:, opt.RunColumn) == opt.SubjDir{i, 3}(k);
            SubjectMasterData(i).sess(k).RunData = SubjectData(RunIndex, :);

        end

    end

end
