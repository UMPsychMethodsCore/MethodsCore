
spmver = spm('Ver');
if (strcmp(spmver,'SPM8')==1)
    spm_jobman('initcfg');
    spm_get_defaults('cmdline',true);
end

global defaults;
global UFp;

fprintf(1, '*****************************************************************');
fprintf(1, 'Starting Check Warp to examine registration of canonical template and first five functional.');
fprintf(1, '*****************************************************************');

if (~exist('FileSuffix','var') | isempty(FileSuffix))
    FileSuffix = '.nii';
end

ImageTemplate = strcat(ImageTemplate, FilePrefix, '*',FileSuffix);
for iSubject = 1:size(SubjDir,1)

    Subject=SubjDir{iSubject};

    [~,endcol] = size(SubjDir);
    numRuns = numel(SubjDir{iSubject, endcol});
    if numRuns > 4
        numRuns = 4;
    end
    
    runStr = '';
    ImagePaths = cell(numRuns, 1);
    for i = 1:numRuns
        Run = RunDir{SubjDir{iSubject, endcol}(i)};
        ImagePathCheck = struct('Template', ImageTemplate, 'mode', 'check');
        ImagePaths{i} = strcat(mc_GenPath(ImagePathCheck), ',1');
        runStr = strcat(runStr, ' ', Run);
    end
    
    WarpTemplateCheck = struct('Template', WarpTemplate, 'mopde', 'check');
    WarpTemplate = mc_GenPath(WarpTemplateCheck);
    WarpAnatPath = mc_GenPath(WarpAnat);
    data = {WarpTemplate WarpAnatPath ImagePaths{:}};
    
    CheckRegJob.jobs{1}.util{1}.checkreg.data = data';
    
    fprintf('\n\n\n');
    fprintf('Performing check registration for subject : %s\n', Subject);
    fprintf('Displaying runs                           : %s\n\n\n', runStr);
    
    spm_jobman('run', CheckRegJob.jobs);
    
    fprintf(1, 'Press any key to continue\n');
    pause;
end % Loop over subjects
close all
fprintf(1, 'All done!\n');   

