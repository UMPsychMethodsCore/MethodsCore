
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

for iSubject = 1:size(SubjDir,1)

    Subject=SubjDir{iSubject};

    fprintf('\n\n\nPerforming check registration for subject: %s', Subject);
    
    Run = RunDir{SubjDir{iSubject,3}(1)};
    
    fprintf('Using run: %s\n\n\n', Run);
    
    ImagePathCheck = struct('Template', ImageTemplate, 'mode', 'check');
    ImagePath = mc_GenPath(ImagePathCheck);
    
    spmFilt = ['^' FilePrefix '.*nii'];
    displayImage = spm_select('ExtFPList', ImagePath, spmFilt, 1);
    if isempty(displayImage) || size(displayImage, 1) > 2
        fprintf(1, 'Invaild file prefix for subject %s\n', Subject);
        fprintf(1, ' * * * S K I P P I N G * * *\n');
        continue;
    end
    
    WarpTemplateCheck = struct('Template', WarpTemplate, 'mopde', 'check');
    WarpTemplate = mc_GenPath(WarpTemplateCheck);
    data = {WarpTemplate displayImage};
    
    CheckRegJob.jobs{1}.util{1}.checkreg.data = data;
    
    spm_jobman('run', CheckRegJob.jobs);
    
    fprintf(1, 'Press any key to continue\n');
    pause;
end % Loop over subjects
close all
fprintf(1, 'All done!\n');   

