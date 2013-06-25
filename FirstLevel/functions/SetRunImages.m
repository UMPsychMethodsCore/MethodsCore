function RunImages = SetRunImages(SubjectNumber, RunNumber, opt)
% RunImages = SetRunImages(SubjectNumber, RunNumber, opt)
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
%
%   OUTPUT
%
%       RunImages               - cell(I, 1), list of images
%
%   N = number of subjects
%   M = number of all available runs
%   MM = number of runs for a given subject
%   I = number of images for a subject in a given run
%
%

    Exp = opt.Exp;
    Subject = opt.SubjDir{SubjectNumber, 1};
    Run = opt.RunDir{RunNumber};

    RunDirCheck.Template = opt.ImagePathTemplate;
    RunDirCheck.type = 1;
    RunDirCheck.mode = 'check';
    RunDir = mc_GenPath(RunDirCheck); % useable : Exp Subject Run

    runImages = spm_select('ExtFPList', RunDir, opt.BaseFileSpmFilter, Inf);

    if isempty(runImages) == 1
        error(['SUBJECT %s RUN %s :\n'...
               'No images found in directory : %s\n'...
               'Check your BaseFileSpmFilter : %s'], Subject, Run, RunDir, opt.BaseFileSpmFilter);
    end
            
    RunImages = cell( size(runImages, 1), 1 );
    for iRunImage = 1:size(runImages, 1)
        RunImages{iRunImage} = strtrim(runImages(iRunImage, :));
    end

end
