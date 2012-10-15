function checkedFiles = qc_checkopt(Opt)
%
% Input: 
%   Opt.
%       Exp  -  Experiment top dir
%       List.
%           Subjects {Subjects,IncludedRuns}
%           Runs     - list of run name folders
%       Postpend.
%           Exp      - what goes after Exp
%           Subjects - what goes after .List.Subjects{:,1}
%           Runs     - what goes after Runs
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
    fprintf(1,'Cannot write to %s\n',Opt.Detected);
    fprintf(1,' * * * A B O R T I N G * * *\n');
    return;
end
fclose(fid);

if Opt.Thresh < 0
    fprintf(1,'Invalid threshold %f\n',Opt.Thresh);
    fprintf(1,' * * * A B O R T I N G * * * \n');
    return;
end

fileExp = ['^' Opt.FileExp '.*nii'];

for i = 1:nsubjects
    subjDir = fullfile(Opt.Exp,Opt.Postpend.Exp,Opt.List.Subjects{i,1},Opt.Postpend.Subjects);
    for k = Opt.List.Subjects{i,2}
        runDir = fullfile(subjDir,Opt.List.Runs{k},Opt.Postpend.Runs);
        if exist(runDir,'dir') ~= 7
            fprintf(1,'FATAL ERROR: Directory does not exist %s\n',runDir);
            fprintf(1,' * * * A B O R T I N G * * *\n');
            checkedFiles = [];
            return;
        end
            
        funcFile = spm_select('FPList',runDir,fileExp);
        if isempty(funcFile)
            fprintf(1,'FATAL ERROR: No function file in directory: %s\n',funcDir);
            fprintf(1,' * * * A B O R T I N G * * *\n');
            checkedFiles = [];
            return;
        end
        
        if size(funcFile,1) > 1
            fprintf(1,'FATAL ERROR: Expected only one 4D functional image in directory: %s\n',funcDir);
            fprintf(1,'Please check Opt.File.Func filter\n');
            fprintf(1,' * * * A B O R T I N G * * *\n');
            checkedFiles = [];
            return;
        end
        
        checkedFiles{index,1} = funcFile;
        checkedFiles{index,2} = Opt.List.Subjects{i,1};
        checkedFiles{index,3} = Opt.List.Runs{k};
        index = index + 1;
    end
end

