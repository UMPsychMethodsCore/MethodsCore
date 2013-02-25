
spmver = spm('Ver');
if (strcmp(spmver,'SPM8')==1)
    spm_jobman('initcfg');
    spm_get_defaults('cmdline',true);
end

global defaults;
global UFp;

display('*****************************************************************');
display('Starting Check Warp to examine registration of canonical template and first five functional.');
display('*****************************************************************');

for iSubject = 1:size(SubjDir,1)

    Subject=SubjDir{iSubject};

    fprintf('\n\n\nPerforming check registration for subject: %s\n\n\n', Subject);

    Run=RunDir{1};

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
            [ImagePath ImagePathName ',1'];
            [ImagePath ImagePathName ',2'];
            [ImagePath ImagePathName ',3'];
            [ImagePath ImagePathName ',4'];
            [ImagePath ImagePathName ',5'];
           };

    CheckRegJob.jobs{1}.util{1}.checkreg.data=data;

    spm_jobman('run',CheckRegJob.jobs);

    pause = input('Press [Return] to continue:\n');        
 
end % Loop over subjects
   
display('All Done')
display('************************************')
   
