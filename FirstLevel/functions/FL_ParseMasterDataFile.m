function [SubjectMasterData opt] = FL_ParseMasterDataFile(opt)
%   SubjectMasterData = FL_ParserMasterDataFile(opt)
%
%   REQUIRED INPUT
%
%       opt.
%           Exp                 - string
%           SubjDir             - cell(N, 2)
%                                 column1 = subject name
%                                 column2 = vector of runs to include
%           RunDir              - cell(R, 1), list of run folders
%           MasterDataFilePath  - string, path to master data file
%                                 templates permitted : [Exp]
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

    % Read in data and do checks on it
    [AllData Subjects opt] = FL_MasterDataFileRead(opt);

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
            if opt.TotalTrials > size(AllData, 1)
                msg = sprintf(['ERROR: TotalTrials is greater than the number of rows present after excluding comments.\n'...
                               'Expected TotalTrials <= %d\n'], size(AllData, 1));
                error(msg);
            end
            SubjectData = AllData(1:opt.TotalTrials, :);
        else
            SubjectIndex = strcmp(opt.SubjDir{i, 1}, Subjects);
            SubjectData = AllData(SubjectIndex, :);
            if isempty(SubjectData) == 1
                msg = sprintf(['SUBJECT %s : No data present in master data file.\n'...
                              'Either remove or comment the subject from the SubjDir list.\n'],...
                              opt.SubjDir{i, 1});
                error(msg);
            end
        end

        NumRuns = length( opt.SubjDir{i, 2} );

        for k = 1:NumRuns

            RunIndex = SubjectData(:, opt.RunColumn) == opt.SubjDir{i, 2}(k);
            if isempty(SubjectData(RunIndex, :))
                TmpRun = opt.RunDir{ opt.SubjDir{i, 2}(k) };
                msg = sprintf(['\nSUBJECT %s RUN %s\n'...
                               'No data present in master data file.\n'...
                               '* * * CANNOT PROCEED * * *\n'],...
                               opt.SubjDir{i, 1}, TmpRun);
                error(msg);
            end
            SubjectMasterData(i).sess(k).RunData = SubjectData(RunIndex, :);

        end

    end

end
