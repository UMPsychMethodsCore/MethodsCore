function [AllData CommLoc Subjects] = MasterDataFileRead(opt)
% function AllLines = MasterDataFileRead(opt)
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
%
% 
    Exp = opt.Exp;
    MasterDataFileCheck.Template = opt.MasterDataFilePath;
    MasterDataFileCheck.Mode = 'check';
    MasterDataFile = mc_GenPath(MasterDataFileCheck);
    fprintf(1, 'Reading data file : %s\n', MasterDataFile);

    fid = fopen(MasterDataFile, 'r');
    AllLines = textscan(fid, '%s', 'Delimiter', '\n');
    AllLines = AllLines{1};

    % let's find all comments - do this instead of using MasterDataSkipRows
    CommentLines = cell2mat( regexp(AllLines, '^#') );
    AllLines(CommentLines) = [];

    % let's find all pointer files
    PointerLines = cell2mat( regexp(AllLines, '^@') );
    PointerFiles = AllLines(PointerLines);
    AllLines(PointerLines) = [];

    CommLoc = cell2mat( regexp(AllLines, ',') );

    % Parse out data
    NumRows = size(AllLines, 1);
    Subjects = cell(NumRows, 1);
    NumCols = 2 + length(opt.CondColumn) + length(opt.TimeColumn) + length(opt.DurationColumn);
    AllData = zeros(NumRows, NumCols);
    NumFields = size(CommLoc, 2);
    for i = 1:NumRows

        % Parse out subjects
        if opt.SubjColumn == 1
            BIndex = 1;
        else
            BIndex = CommLoc(i, opt.SubjColumn) + 1;
        end

        if opt.SubjColumn ~= NumFields
            EIndex = CommLoc(i, opt.SubjColumn + 1) - 1;
            Subjects{i} = AllLines{i}(BIndex:EIndex);
        else
            Subjects{i} = AllLines{i}(BIndex:end);
        end

        DataIndex = 1;

        % Parse out runs
        if opt.RunColumn == 1
            BIndex = 1;
        else
            BIndex = CommLoc(i, opt.RunColumn) + 1;
        end

        if opt.RunColumn ~= NumFields
            EIndex = CommLoc(i, opt.RunColumn + 1) - 1;
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
                BIndex = CommLoc(i, opt.CondColumn(k)) + 1;
            end

            if opt.CondColumn(k) ~= NumFields
                EIndex = CommLoc(i, opt.CondColumn(k) + 1) - 1;
                AllData(i, DataIndex) = str2double( AllLines{i}(BIndex:EIndex) );
            else
                AllData(i, DataIndex) = str2double( AllLines{i}(BIndex:end) );
            end
            DataIndex = DataIndex + 1;
        end

        % Parse out onsets
        for k = 1:length(opt.TimeColumn)
            
            BIndex = CommLoc(i, opt.TimeColumn(k)) + 1;
            if opt.TimeColumn(k) ~= NumFields
                EIndex = CommLoc(i, opt.TimeColumn(k) + 1) - 1;
                AllData(i, DataIndex) = str2double( AllLines{i}(BIndex:EIndex) );
            else
                AllData(i, DataIndex) = str2double( AllLines{i}(BIndex:end) );
            end
            DataIndex = DataIndex + 1;
        end

        % Parse out durations
        for k = 1:length(opt.DurationColumn)
            BIndex = CommLoc(i, opt.DurationColumn(k)) + 1;
            if opt.DurationColumn(k) ~= NumFields
                EIndex = CommLoc(i, opt.DurationColumn(k) + 1) - 1;
                AllData(i, DataIndex) = str2double( AllLines{i}(BIndex:EIndex) );
            else
                AllData(i, DataIndex) = str2double( AllLines{i}(BIndex:end) );
            end
            DataIndex = DataIndex + 1;
        end
    end
end
        
