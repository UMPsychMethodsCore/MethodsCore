function checkedFiles = qc_CheckScanOpt(Opt)
%
% Input: 
%   Opt.
%       Exp  -  Experiment top dir
%       List.
%           Subjects {Subjects,IncludedRuns}
%           Runs     - list of run name folders
%       ImageTemplate - template to image
%       FileExp      - Regexp for file names
%       OutlierText  - full path to output text file
%       Thresh       - z-score threshold value
%
% Output:
%   checkedFiles{:,1} - file names
%   checkedFiles{:,2} - subject name
%   checkedFiles{:,3} - run names
%
nsubjects = size(Opt.List.Subjects,1);
tempRuns = numel(size([Opt.List.Subjects]));
checkedFiles = cell(size(Opt.List.Subjects,1)*tempRuns,3);
index = 1;

fid = fopen(Opt.OutlierText,'w');
if fid == -1
    mc_Error(['Cannot write to %s\n'...
              ' * * * A B O R T I N G * * *\n']);
end
fclose(fid);

if Opt.Thresh < 0
    mc_Error(['Invalid threshold %f\n'...
              ' * * * A B O R T I N G * * *\n']);
end

fileExp = ['^' Opt.FileExp '.*nii'];
Exp = Opt.Exp;
check.Template = Opt.ImageTemplate;
check.mode = 'check';
for i = 1:nsubjects
    for k = Opt.List.Subjects{i,2}
        Run = Opt.List.Runs{k};
        Subject = Opt.List.Subjects{i,1};
        runDir = mc_GenPath(check);
        
        if exist(runDir,'dir') ~= 7
            mc_Error(['FATAL ERROR: Directory does not exist %s\n'...
                      ' * * * A B O R T I N G * * *\n']);
        end

        funcFile = spm_select('FPList',runDir,fileExp);
        if isempty(funcFile)
            mc_Error(['FATAL ERROR: No funciton file in directory: %s\n'...
                     'Please check Opt.FileExp filter.\n'...
                     ' * * * A B O R T I N G * * *\n']);
        end

        if size(funcFile,1) > 1
            mc_Error(['FATAL ERROR: Expected only one 4D functional image in directory: %s\n'...
                      'Please check Opt.FileExp filter\n'...
                      ' * * * A B O R T I N G * * *\n']);
        end

        checkedFiles{index,1} = funcFile;
        checkedFiles{index,2} = Opt.List.Subjects{i,1};
        checkedFiles{index,3} = Opt.List.Runs{k};
        index = index + 1;
    end
end

