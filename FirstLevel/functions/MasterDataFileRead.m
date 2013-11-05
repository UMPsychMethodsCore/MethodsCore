function [AllData Subjects opt] = MasterDataFileRead(opt)
% function [AllData Subjects opt] = MasterDataFileRead(opt)
%
%   REQUIRED INPUT
%
%       opt.
%           Exp                 - string
%           SubjDir             - cell(N, 3)
%                                 column1 = subject name
%                                 column2 = vector of runs to include
%           MasterDataFilePath  - string, path to master data file
%                                 templates permitted : [Exp]
%           SubjColumn          - scalar
%           RunColumn           - scalar
%           CondColumn          - vector
%           TimeColumn          - vector
%           DurationColumn      - vector
%           ParametricList      - cell(P, 4)
%                                 column1 = paramatric name
%                                 column2 = column in master data file
%                                 column3 = condition number as listed in ConditionName
%                                 column4 = order
%   OUTPUT
%
%       AllData                 - matrix, contains all parsed data from opt.MasterDataFilePath
%       Subjects                - cell, lists the subjects found in opt.MasterDataFilePath
%       opt                     - Here are the fields updated in opt:
%                                   SubjColumn
%                                   RunColumn
%                                   CondColumn
%                                   TimeColumn
%                                   DurationColumn
%                                   ParametricList{:, 2}
%
    %initialize all data
    AllData = [];
    Subjects = {};

    Exp = opt.Exp;
    MasterDataFileCheck.Template = opt.MasterDataFilePath;
    MasterDataFileCheck.mode = 'check';
    MasterDataFile = mc_GenPath(MasterDataFileCheck);
    fprintf(1, 'Reading data file : %s\n', MasterDataFile);

    fid = fopen(MasterDataFile, 'r');
    AllLines = textscan(fid, '%s', 'Delimiter', '\n');
    AllLines = AllLines{1};

    % let's find all comments - do this instead of using MasterDataSkipRows
    CommentLines = regexp(AllLines, '^#');
    for i = 1:size(CommentLines, 1)
        if isempty(CommentLines{i})
            CommentLines{i} = 0;
        end
    end
    CommentLines = logical(cell2mat(CommentLines));
    AllLines(CommentLines) = [];

    % let's find all pointer files
    PointerLines = regexp(AllLines, '^@');
    for i = 1:size(PointerLines, 1)
        if isempty(PointerLines{i})
            PointerLines{i} = 0;
        end
    end
    PointerLines = logical(cell2mat(PointerLines));
    PointerFiles = AllLines(PointerLines);
    AllLines(PointerLines) = [];

    % now parse any lines that are remaining
    if ~isempty(AllLines)
        CommaLoc = cell2mat( regexp(AllLines, ',') );

        % initialize variables for parsing
        NumRows = size(AllLines, 1);
        Subjects = cell(NumRows, 1);
        NumCols = 1 + length(opt.CondColumn) + length(opt.TimeColumn) + length(opt.DurationColumn) + size(opt.ParametricList, 1);
        AllData = zeros(NumRows, NumCols);
        NumFields = size(CommaLoc, 2) + 1;

        % check to make sure all assigned columns are less then NumFields
        if opt.SubjColumn > NumFields
            error(['ERROR: SubjColumn value exceeds the number of columns present in the master data file.  Expected a value less than or equal to %d'], NumFields);
        end

        if opt.RunColumn > NumFields
            error(['ERROR: RunColumn value exceeds the number of columns present in the master data file.  Expected a value less than or equal to %d'], NumFields);
        end

        if any(opt.TimeColumn > NumFields)
            error(['ERROR: TimeColumn value exceeds the number of columns present in the master data file.  Expected a value less than or equal to %d'], NumFields);
        end

        if any(opt.DurationColumn > NumFields)
            error(['ERROR: DurationColumn value exceeds the number of columns present in the master data file.  Expected a value less than or equal to %d'], NumFields);
        end

        for i = 1:size(opt.ParametricList, 1)
            if opt.ParametricList{i, 2} > NumFields
                error('ERROR: Master data file column specified for parametric regressor %s exceeds the number of column in the master data file.  Expected a value less than or equal to %d.', opt.ParametricList{i, 1}, NumFields);
            end
        end

        % now start parsing
        for i = 1:NumRows

            % Parse out subjects
            if opt.SubjColumn == 1
                BIndex = 1;
            else
                BIndex = CommaLoc(i, opt.SubjColumn - 1) + 1;
            end

            if opt.SubjColumn ~= NumFields
                EIndex = CommaLoc(i, opt.SubjColumn) - 1;
                Subjects{i} = AllLines{i}(BIndex:EIndex);
            else
                Subjects{i} = AllLines{i}(BIndex:end);
            end

            DataIndex = 1;

            % Parse out runs
            if opt.RunColumn == 1
                BIndex = 1;
            else
                BIndex = CommaLoc(i, opt.RunColumn - 1) + 1;
            end

            if opt.RunColumn ~= NumFields
                EIndex = CommaLoc(i, opt.RunColumn) - 1;
                AllData(i, DataIndex) = str2double( AllLines{i}(BIndex:EIndex) );
            else
                AllData(i, DataIndex) = str2double( AllLines{i}(BIndex:end) );
            end
            DataIndex = DataIndex + 1;

            % Parse out conditions
            for k = 1:length(opt.CondColumn)
                if opt.CondColumn(k) == 1
                    BIndex = 1;
                else
                    BIndex = CommaLoc(i, opt.CondColumn(k) - 1) + 1;
                end

                if opt.CondColumn(k) ~= NumFields
                    EIndex = CommaLoc(i, opt.CondColumn(k)) - 1;
                    AllData(i, DataIndex) = str2double( AllLines{i}(BIndex:EIndex) );
                else
                    AllData(i, DataIndex) = str2double( AllLines{i}(BIndex:end) );
                end
                DataIndex = DataIndex + 1;
            end

            % Parse out onsets
            for k = 1:length(opt.TimeColumn)
                
                BIndex = CommaLoc(i, opt.TimeColumn(k) - 1) + 1;
                if opt.TimeColumn(k) ~= NumFields
                    EIndex = CommaLoc(i, opt.TimeColumn(k)) - 1;
                    AllData(i, DataIndex) = str2double( AllLines{i}(BIndex:EIndex) );
                else
                    AllData(i, DataIndex) = str2double( AllLines{i}(BIndex:end) );
                end
                DataIndex = DataIndex + 1;
            end

            % Parse out durations
            for k = 1:length(opt.DurationColumn)
                BIndex = CommaLoc(i, opt.DurationColumn(k) - 1) + 1;
                if opt.DurationColumn(k) ~= NumFields
                    EIndex = CommaLoc(i, opt.DurationColumn(k)) - 1;
                    AllData(i, DataIndex) = str2double( AllLines{i}(BIndex:EIndex) );
                else
                    AllData(i, DataIndex) = str2double( AllLines{i}(BIndex:end) );
                end
                DataIndex = DataIndex + 1;
            end

            % Parse out parametric regressors
            for k = 1:size(opt.ParametricList, 1)
                BIndex = CommaLoc(i, opt.ParametricList{k, 2} - 1) + 1;
                if opt.ParametricList{k, 2} ~= NumFields
                    EIndex = CommaLoc(i, opt.ParametricList{k, 2}) - 1;
                    AllData(i, DataIndex) = str2double( AllLines{i}(BIndex:EIndex) );
                else
                    AllData(i, DataIndex) = str2double( AllLines{i}(BIndex:end) );
                end
                DataIndex = DataIndex + 1;
            end

            % check all values read are valid
            if any( isnan(AllData(i, :)) ) == 1
                msg = sprintf(['Invalid data file : %s line %d\n'...
                               'Check to make sure all headers begin with ''#''.\n'...
                               'Check if the run, condtion, onsets, duration, and parametric regressors columns were assigned correctly.\n'], MasterDataFile, i);
                error(msg);
            end
        end
    end
    fclose(fid);

    % now parse our pointer files
    TmpOpt = opt;
    for i = 1:size(PointerFiles, 1)
        TmpOpt.MasterDataFilePath = PointerFiles{i}(2:end);
        [TmpAllData TmpAllSubjects] = MasterDataFileRead(TmpOpt);
        AllData = [AllData; TmpAllData];
        Subjects = [Subjects; TmpAllSubjects];
    end

    % now update opt
    opt.RunColumn = 1;
    opt.CondColumn = (1:length(opt.CondColumn)) + 1;
    opt.TimeColumn = (1:length(opt.TimeColumn)) + opt.CondColumn(end);
    opt.DurationColumn = (1:length(opt.DurationColumn)) + opt.TimeColumn(end);
    for i =1:size(opt.ParametricList, 1)
        opt.ParametricList{i, 2} = i + opt.DurationColumn(end);
    end
end
