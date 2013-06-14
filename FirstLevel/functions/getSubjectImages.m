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
%       NONE :)           
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

            % trim white space and insert into cell array
            subjectInfo(1, i).sess(1, k).images = cell( size(runImages, 1), 1 );
            for iRunImage = 1:size(runImages, 1)
                subjectInfo(1, i).sess(1, k).images{iRunImage} = strtrim(runImages(iRunImage, :));
            end
        end
    end
end

            

