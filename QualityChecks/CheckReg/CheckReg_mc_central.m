
spmver = spm('Ver');
if (strcmp(spmver,'SPM8')==1)
    spm_jobman('initcfg');
	spm_get_defaults('cmdline',true);
end

global defaults;
global UFp;

fprintf(1,'****************************************************************\n');
fprintf(1,'Starting Check Coregistration to examine registration of Overlay, HiRes, and first five functional.\n');
fprintf(1,'****************************************************************\n');


ImageTemplate = fullfile(ImageTemplate, strcat(FilePrefix, '*nii'));
for iSubject = 1:size(SubjDir,1)

    Subject = SubjDir{iSubject, 1};

    numRuns = size(SubjDir{iSubject, 3}, 2);
    if numRuns > 3
        numRuns = 3;
    end
    
    runStr = '';
    ImagePaths = cell(numRuns, 1);
    for i = 1:numRuns
        Run = RunDir{SubjDir{iSubject, 3}(i)};
        ImagePathCheck = struct('Template', ImageTemplate, 'mode', 'check');
        ImagePaths{i} = strcat(mc_GenPath(ImagePathCheck), ',1');
        runStr = strcat(runStr, ' ', Run);
    end
    
    OverlayPathCheck = struct('Template', OverlayTemplate, 'mode', 'chekck');
    OverlayPathFile = mc_GenPath(OverlayPathCheck);
    
    HiResPathCheck = struct('Template', HiResTemplate, 'mode', 'check');
    HiResPathFile = mc_GenPath(HiResPathCheck);

    data = { [OverlayPathFile] [HiResPathFile] ImagePaths{:} };

    CheckRegJob.jobs{1}.util{1}.checkreg.data=data;
    
    fprintf(1, '\n\n\n');
    fprintf(1, 'Performing check registration for subject : %s\n', Subject);
    fprintf(1, 'Displaying runs                           : %s\n\n\n', runStr);
    
    spm_jobman('run',CheckRegJob.jobs);

    fprintf('Press any key to continue:\n');
    pause;
end % Loop over subjects
close all
fprintf('All done!\n');

