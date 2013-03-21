
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

    fprintf('\n\n\nPerforming check registration for subject: %s\n\n\n', Subject);
    
    for jRun = 1:length(SubjDir{iSubject,3})
    
        Run=RunDir{jRun};

        fprintf('\n\n\nPerforming check registration for run: %s\n\n\n', Run);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ImagePathCheck = struct('Template',ImageTemplate,...
                                'mode','check');
        ImagePath = mc_GenPath(ImagePathCheck);

        fileName = fullfile( ImagePath, strcat(FilePrefix,'*.nii') );
        ImagePathFile=dir(fileName);
        ImagePathName=ImagePathFile(1).name;

        WarpTemplateCheck = struct('Template',WarpTemplate,...
                                   'mode','check');
        WarpTemplate = mc_GenPath(WarpTemplateCheck);
        data = {
                [WarpTemplate];
                fullfile(ImagePath, [ImagePathName ',1']);
                fullfile(ImagePath, [ImagePathName ',2']);
                fullfile(ImagePath, [ImagePathName ',3']);
               };

        CheckRegJob.jobs{1}.util{1}.checkreg.data=data;

        spm_jobman('run',CheckRegJob.jobs);

        fprintf(1, 'Press any key to continue\n');
        pause;
    end
 
end % Loop over subjects
close all
fprintf(1, 'All done!\n');   

