function subjectInfo = getSubjectImages(opt)
% subjectInfo = getSubjectImages(opt)
%   
%   REQUIRED INPUT
%   
%       opt.
%           Exp                 - string
%           ImagePathTemplate   - string template to run images
%           BaseFileSpmFilter   - spm_filter used to acquire images
%           RunDir              - cell(M, 1)
%           SubjDir             - cell(N, 3)
%                                 column1 = subject name
%                                 column2 = subject number in master data file
%                                 column3 = vector of runs to include
%
%   OPTIONAL INPUT
%   
%           VolumeSpecifier     - matrix(2, M)
%                                 row1 = start volume for run
%                                 row2 = end volume for run
%           
%
%   OUTPUT
%
%       subjectInfo(1, N).
%           name                - string, subject name
%           sess(1,MM).
%               name            - string, run name
%               images          - cell(I, 1), list of images
%
%   N = number of subjects
%   M = number of all available runs
%   MM = number of runs for a given subject
%   I = number of images for a subject in a given run
%
%   If not using optional input, input value as an empty matrix.
%

    if isfield(opt, 'VolumeSpecifier') == 0
        opt.VolumeSpecifier = [];
    end            

    % handle VolumeSpecifier
    if ~isempty(opt.VolumeSpecifier) == 1
    
        [r c] = size(opt.VolumeSpecifier);
        NumRuns = size(opt.RunDir, 1);

        % make sure has correct number of runs (columns)
        if c ~= NumRuns
            error('VolumeSpecifier has %d columns.  Expected %d columns (equal to number of runs in RunDir)\n', c, NumRuns);
        end

        % make sure has 2 rows
        if r ~= 2
            error('VolumeSpecifier has %d rows.  Expected 2 rows\n', r);
        end

        % make sure both are postive and startIndex < endIndex
        for i = 1:c
            if opt.VolumeSpecifier(1, i) <= 0  || opt.VolumeSpecifier(2, i) <= 0
                error('VolumeSpecifier can only have positive values');
            end
            
            if opt.VolumeSpecifier(1, i) >= opt.VolumeSpecifier(2, i)
                error('The start index in the VolumeSpecifier matrix must be strictly less than the end index.');
            end
        end
    end
        
    Exp = opt.Exp;
    NumSubjects = size(opt.SubjDir, 1);
    subjectInfo(NumSubjects) = struct();
    % collect all images for all runs for all subject
    for i = 1:NumSubjects

        Subject = opt.SubjDir{i, 1};
        subjectInfo(i).name = Subject;
        RunVector = opt.SubjDir{i, 3};

        for k = 1:length(RunVector)

            Run = opt.RunDir{RunVector(k), 1};
            subjectInfor(i).sess(k).name = Run;
            RunDirCheck.Template = opt.ImagePathTemplate;
            RunDirCheck.type = 1;
            RunDirCheck.mode = 'check';
            RunDir = mc_GenPath(RunDirCheck); % useable : Exp Subject Run

            runImages = spm_select('ExtFPList', RunDir, opt.BaseFileSpmFilter, Inf);

            if isempty(runImages) == 1
                error(['No images found in directory : %s\n'...
                       'Check your BaseFileSpmFilter : %s'], RunDir, opt.BaseFileSpmFilter);
            end

            if ~isempty(opt.VolumeSpecifier) == 1
                NumImages = size(runImages, 1);
                vsRun = opt.VolumeSpecifier(:, RunVector(k));
                if NumImages < vsRun(2)
                    error('End index in VolumeSpecifier is greater than the number of images found for subject %s in run %s\n', subjectInfo(1, i).name, Run);
                end

                runImages = runImages(vsRun(1):vsRun(2), :);
            end

            % trim white space and insert into cell array
            subjectInfo(1, i).sess(1, k).images = cell( size(runImages, 1), 1 );
            for iRunImage = 1:size(runImages, 1)
                subjectInfo(1, i).sess(1, k).images{iRunImage} = strtrim(runImages(iRunImage, :));
            end
        end
    end
end

            

