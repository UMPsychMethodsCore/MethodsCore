addpath /net/dysthymia/spm8

 spmver = spm('Ver');
    if (strcmp(spmver,'SPM8')==1)
	    spm_jobman('initcfg');
	    spm_get_defaults('cmdline',true);
    end

global defaults;
global UFp;

%addpath /net/dysthymia/matlabScripts/  %%%% this is for generate_path_CSS
addpath /net/dysthymia/slab/users/sripada/repos/matlabScripts %%%% this is for generate_path_CSS
display('*****************************************************************');
display('Starting Check Coregistration to examine registration of Overlay, SPGR, and first five functional.');
display('*****************************************************************');
   for iSubject = 1:size(SubjDir,1)

Subject=SubjDir{iSubject};
fprintf('\n\n\nPerforming check registration for subject: %s\n\n\n', Subject);


Run=RunDir{1};



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pathcallcmd=generate_PathCommand(ImageTemplate);
ImagePath=eval(pathcallcmd);



pathcallcmd=generate_PathCommand(OverlayTemplate);
OverlayPathFile=eval(pathcallcmd);

pathcallcmd=generate_PathCommand(SPGRTemplate);
SPGRPathFile=eval(pathcallcmd);

 


    ImagePathFile=dir([ImagePath  FilePrefix '*.nii']);
    ImagePathName=ImagePathFile(1).name;


data = {
    [OverlayPathFile];
    [SPGRPathFile];
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

