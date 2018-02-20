function checkedFiles = qc_CheckFrameOpt(Opt)
%
% Input: 
%   Opt.
%       Exp  -  Experiment top dir
%       List.
%           Subjects {Subjects,SubjectNumber,IncludedRuns}
%           Runs     - list of run name folders
%       ImageTemplate - template to image
%       FileExp      - Regexp for file names
%       OutlierText  - full path to output text file
%       Thresh       - z-score threshold value
%       LogTemplate  - directory path to log files
%
% Output:
%   checkedFiles{:,1} - file names
%   checkedFiles{:,2} - subject name
%   checkedFiles{:,3} - run names
%
Exp = Opt.Exp; % do this first, since LogDirectory assignment calls GenPath, and requires that Exp be defined in workspace
nsubjects = size(Opt.List.Subjects,1);
[~,endcol] = size(Opt.List.Subjects);
tempRuns = numel([Opt.List.Subjects{:,endcol}]);
checkedFiles = cell(tempRuns,3);
index = 1;

% handle logging
LogDirectory = mc_GenPath(struct('Template',Opt.LogTemplate,'mode','makedir'));
result = mc_Logger('setup', LogDirectory);
if (~result)
    mc_Error('There was an error creating your logfiles.\nDo you have permission to write to %s?',LogDirectory);
end
global mcLog

if Opt.Thresh < 0
    mc_Error(['Invalid threshold %f\n'...
              ' * * * A B O R T I N G * * *\n'],Opt.Thresh);
end

fileExp = ['^' Opt.FileExp '.*nii'];
check.Template = Opt.ImageTemplate;
check.mode = 'check';
for i = 1:nsubjects
    for k = Opt.List.Subjects{i,endcol}
        Run = Opt.List.Runs{k};
        Subject = Opt.List.Subjects{i,1};
        runDir = mc_GenPath(check);
        
        if exist(runDir,'dir') ~= 7
            mc_Error(['FATAL ERROR: Directory does not exist %s\n'...
                      ' * * * A B O R T I N G * * *\n'],runDir);
        end

        funcFile = spm_select('FPList',runDir,fileExp);
        if isempty(funcFile)
            mc_Error(['FATAL ERROR: No funciton file in directory: %s\n'...
                     'Please check Opt.FileExp filter.\n'...
                     ' * * * A B O R T I N G * * *\n'],runDir);
        end

        if size(funcFile,1) > 1
            mc_Error(['FATAL ERROR: Expected only one 4D functional image in directory: %s\n'...
                      'Please check Opt.FileExp filter\n'...
                      ' * * * A B O R T I N G * * *\n'],runDir);
        end

        checkedFiles{index,1} = funcFile;
        checkedFiles{index,2} = Opt.List.Subjects{i,1};
        checkedFiles{index,3} = Opt.List.Runs{k};
        index = index + 1;
    end
end

OutlierText.Template = Opt.OutlierText;
OutlierText = mc_GenPath(OutlierText);
fid = fopen(OutlierText,'w');
if fid == -1
    mc_Error(['Cannot write to %s\n'...
              ' * * * A B O R T I N G * * *\n'],Opt.OutlierText);
end
fclose(fid);
