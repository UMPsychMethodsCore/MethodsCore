function checkedFiles = qc_CheckSliceOpt(Opt)
%
% Input: 
%   Opt.
%       Exp  -  Experiment top dir
%       List.
%           Subjects {Subjects,IncludedRuns}
%           Runs      - list of run name folders
%       ImageTemplate - template to image
%       FileExp       - Prefix for file names
%       OutlierText   - full path to output text file
%       Thresh        - z-score threshold value
%
% Output:
%   checkedFiles{:,1} - file names
%   checkedFiles{:,2} - subject name
%   checkedFiles{:,3} - run names
%
nsubjects = size(Opt.List.Subjects,1);
tempRuns = numel([Opt.List.Subjects{:,2}]);
checkedFiles = cell(tempRuns,3);
index = 1;

if Opt.Thresh < 0
    mc_Error(['Invalid threshold %3.2f\n'...
              ' * * * A B O R T I N G * * *\n'], Opt.Thresh);
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
        
        funcFile = spm_select('FPList',runDir,fileExp);
        if isempty(funcFile)
            mc_Error(['FATAL ERROR: No function file in directory: %s\n'...
                      'Please check Opt.FileExp filter.\n'...
                      ' * * * A B O R T I N G * * * \n'],runDir);
        end
        
        if size(funcFile,1) > 1
            mc_Error(['FATAL ERROR: Expected only one 4D function image in directory: %s\n'...
                      'Please check Opt.FileExp filter\n'...
                      ' * * * A B O R T I N G * * *\n'], rundDir);
        end
        
        checkedFiles{index,1} = funcFile;
        checkedFiles{index,2} = Opt.List.Subjects{i,1};
        checkedFiles{index,3} = Opt.List.Runs{k};
        index = index + 1;
    end
end

outlierTextFile = mc_GenPath(Opt.OutlierText);
fid = fopen(outlierTextFile,'w');
if fid == -1
    mc_Error(['Cannot write to %s\n'...
              ' * * * A B O R T I N G * * *\n'], Opt.OutlierText);
end
fclose(fid);

