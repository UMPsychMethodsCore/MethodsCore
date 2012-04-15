%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% You shouldn't need to edit this script
%%% Instead make a copy of PreprocessingFirstLevel_template.m 
%%% and edit that to match your data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% General calculations that apply to both Preprocessing and First Level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (alreadydone(1))
	basefile = [stp basefile];
end
if (alreadydone(2))
	basefile = [rep basefile];
end
if (alreadydone(3))
	basefile = [nop basefile];
end
if (alreadydone(4))
	basefile = [smp basefile];
end

if (~exist('doslicetiming') | ~doslicetiming)
	stp = '';
end
if (~exist('dorealign') | ~dorealign)
	rep = '';
end
if (~exist('donormalize') | ~donormalize)
	nop = '';
end
if (~exist('dosmooth') | ~dosmooth)
	smp = '';
end
	
Pa = [stp];
Pra = [rep stp];
Pwra = [nop rep stp];	
Pswra = [smp nop rep stp];

addpath(spmpath);
addpath(pwd);
spm('defaults','fmri');
global defaults
warning off all

spmver = spm('Ver');
if (strcmp(spmver,'SPM8')==1)
	spm_jobman('initcfg');
	spm_get_defaults('cmdline',true);
end

RunNamesTotal = RunDir;
NumScanTotal = NumScan;
	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Preprocessing Section
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (Processing(1) == 1)
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%% You shouldn't need to edit below this line
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	addpath(spmpath);
	addpath(pwd)
	spm('defaults','fmri');
	global defaults;

	%suffix = ',1';
	suffix = '';

	spmver = spm('Ver');

	st.scans = {};
	st.tr = TR;
	st.nslices = num_slices;
	st.ta = (TR-(TR/num_slices));
	%st.so = [1:1:num_slices];
	st.so = slice_order;
	st.refslice = ceil(num_slices/2);
	st.prefix = stp;

	realign.estwrite.data = {}; %
	realign.estwrite.eoptions.quality = 0.9000;
	realign.estwrite.eoptions.sep = 4;
	realign.estwrite.eoptions.fwhm = 5;
	realign.estwrite.eoptions.rtm = 1;
	realign.estwrite.eoptions.interp = 2;
	realign.estwrite.eoptions.wrap = [0 0 0];
	realign.estwrite.eoptions.weight = {};
	realign.estwrite.roptions.which = [2 1]; %[0 1] writes only mean image [2 1] writes all + mean [1 0] writes 2..n
	realign.estwrite.roptions.interp = 4;
	realign.estwrite.roptions.wrap = [0 0 0];
	realign.estwrite.roptions.mask = 1;
	realign.estwrite.roptions.prefix = rep;

	coreg.estimate.ref = {};
	coreg.estimate.source = {};
	coreg.estimate.other = {''};
	coreg.estimate.eoptions.cost_fun = 'nmi';
	coreg.estimate.eoptions.sep = [4 2];
	coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
	coreg.estimate.eoptions.fwhm = [7 7];

	if (strcmp(spmver,'SPM8'))
		vbm.estwrite.data = {};
		vbm.estwrite.opts.tpm = {[spmpath '/toolbox/Seg/TPM.nii']};
		vbm.estwrite.opts.ngaus = [2 2 2 3 4 2];
		vbm.estwrite.opts.biasreg = 0.0001;
		vbm.estwrite.opts.biasfwhm = 60;
		vbm.estwrite.opts.affreg = 'mni';
		vbm.estwrite.opts.warpreg = 4;
		vbm.estwrite.opts.samp = 3;
		vbm.estwrite.extopts.dartelwarp = 1;
		vbm.estwrite.extopts.sanlm = 1;
		vbm.estwrite.extopts.mrf = 0.1500;
		vbm.estwrite.extopts.cleanup = 1;
		vbm.estwrite.extopts.print = 1;
		vbm.estwrite.extopts.GM.native = 0;
		vbm.estwrite.extopts.GM.warped = 0;
		vbm.estwrite.extopts.GM.modulated = 2;
		vbm.estwrite.extopts.GM.dartel = 0;
		vbm.estwrite.extopts.WM.native = 0;
		vbm.estwrite.extopts.WM.warped = 0;
		vbm.estwrite.extopts.WM.modulated = 2;
		vbm.estwrite.extopts.WM.dartel = 0;
		vbm.estwrite.extopts.CSF.native = 0;
		vbm.estwrite.extopts.CSF.warped = 0;
		vbm.estwrite.extopts.CSF.modulated = 2;
		vbm.estwrite.extopts.CSF.dartel = 0;
		vbm.estwrite.extopts.bias.native = 0;
		vbm.estwrite.extopts.bias.warped = 1;
		vbm.estwrite.extopts.bias.affine = 0;
		vbm.estwrite.extopts.label.native = 0;
		vbm.estwrite.extopts.label.warped = 0;
		vbm.estwrite.extopts.label.dartel = 0;
		vbm.estwrite.extopts.jacobian.warped = 0;
		vbm.estwrite.extopts.warps = [1 1];

		vbm.estwrite.output.GM.native = 0;
		vbm.estwrite.output.GM.warped = 0;
		vbm.estwrite.output.GM.modulated = 2;
		vbm.estwrite.output.GM.dartel = 0;
		vbm.estwrite.output.WM.native = 0;
		vbm.estwrite.output.WM.warped = 0;
		vbm.estwrite.output.WM.modulated = 2;
		vbm.estwrite.output.WM.dartel = 0;
		vbm.estwrite.output.CSF.native = 0;
		vbm.estwrite.output.CSF.warped = 0;
		vbm.estwrite.output.CSF.modulated = 2;
		vbm.estwrite.output.CSF.dartel = 0;
		vbm.estwrite.output.bias.native = 0;
		vbm.estwrite.output.bias.warped = 1;
		vbm.estwrite.output.bias.affine = 0;
		vbm.estwrite.output.label.native = 0;
		vbm.estwrite.output.label.warped = 1;
		vbm.estwrite.output.label.affine = 0;
		vbm.estwrite.output.jacobian.warped = 0;
		vbm.estwrite.output.warps = [1 1];
		%vbmtools.tools.defs.field = {};
		%vbmtools.tools.defs.fnames = {};
		%vbmtools.tools.defs.interp = 5;
		%vbmtools.tools.defs.modulate = 0;
		
		util.defs.comp{1}.def = {};
		util.defs.comp{2}.idbbvox.vox = vox_size;
		util.defs.comp{2}.idbbvox.bb = [-78 -112 -50;78 76 85];
		util.defs.ofname = '';
		util.defs.fnames = {};
		util.defs.savedir.savesrc = 1;
		util.defs.interp = 1;
	else 
		vbm.estwrite.data = {};
		vbm.estwrite.opts.tpm = {[spmpath '/tpm/grey.nii'];[spmpath '/tpm/white.nii'];[spmpath '/tpm/csf.nii']};
		vbm.estwrite.opts.ngaus = [2 2 2 4];
		vbm.estwrite.opts.regtype = 'mni';
		vbm.estwrite.opts.warpreg = 1;
		vbm.estwrite.opts.warpco = 25;
		vbm.estwrite.opts.biasreg = 0.0001;
		vbm.estwrite.opts.biasfwhm = 70;
		vbm.estwrite.opts.samp = 3;
		vbm.estwrite.opts.msk = {};
		vbm.estwrite.opts.usecom = 0;
		vbm.estwrite.output.GM.native = 0;
		vbm.estwrite.output.GM.warped = 0;
		vbm.estwrite.output.GM.modulated = 2;
		vbm.estwrite.output.WM.native = 0;
		vbm.estwrite.output.WM.warped = 0;
		vbm.estwrite.output.WM.modulated = 2;
		vbm.estwrite.output.CSF.native = 0;
		vbm.estwrite.output.CSF.warped = 0;
		vbm.estwrite.output.CSF.modulated = 2;
		vbm.estwrite.output.BIAS.native = 0;
		vbm.estwrite.output.BIAS.warped = 1;
		vbm.estwrite.output.BIAS.descalp = 0;
		vbm.estwrite.output.extopts.usepriors = 1;
		vbm.estwrite.output.extopts.mrf = 1;
		vbm.estwrite.output.extopts.cleanup = 1;
		vbm.estwrite.output.extopts.vox = [1 1 1];
		vbm.estwrite.output.extopts.bb = [-78 -112 -70;78 76 85];
		vbm.estwrite.output.extopts.writeaffine = 0;
		vbm.estwrite.output.extopts.print = 1;
	end

	if (strcmp(normmethod,'seg'))
		normalise.write.subj.matname = {};
		normalise.write.subj.resample = {};
		normalise.write.roptions.preserve = 0;
		normalise.write.roptions.bb = [-78 -112 -50;78 76 85];
		normalise.write.roptions.vox = vox_size;
		normalise.write.roptions.interp = 1;
		normalise.write.roptions.wrap = [0 0 0];
		normalise.write.roptions.prefix = nop;
	else
		normalise.estwrite.subj.source = {}; %
		normalise.estwrite.subj.wtsrc = {};
		normalise.estwrite.subj.resample = {}; %
		normalise.estwrite.eoptions.template = {[WarpTemplate suffix]};
		normalise.estwrite.eoptions.weight = {};
		normalise.estwrite.eoptions.smosrc = 8;
		normalise.estwrite.eoptions.smoref = 0;
		normalise.estwrite.eoptions.regtype = 'mni';
		normalise.estwrite.eoptions.cutoff = 25;
		normalise.estwrite.eoptions.nits = 16;
		normalise.estwrite.eoptions.reg = 1;
		normalise.estwrite.roptions.preserve = 0;
		normalise.estwrite.roptions.bb = [-78 -112 -50;78 76 85];
		normalise.estwrite.roptions.vox = vox_size;
		normalise.estwrite.roptions.interp = 1;
		normalise.estwrite.roptions.wrap = [0 0 0];
		normalise.estwrite.roptions.prefix = nop;
	end

	smooth.data = {}; %
	smooth.fwhm = [kernel kernel kernel];
	smooth.dtype = 0;
	smooth.im = 0;
	smooth.prefix = smp;

	if (strcmp(spmver,'SPM8'))
	    spm_jobman('initcfg');
	    spm_get_defaults('cmdline',true);
	    realign.estwrite.eoptions.weight = {''};
	    normalise.estwrite.subj.wtsrc = '';
	    normalise.estwrite.eoptions.weight = '';
	end

	clear jobs
	
	for x = 1:size(SubjDir,1)
	    clear job
        Subject=SubjDir{x,1};
		RunList=SubjDir{x,3};

		NumRun = size(RunList,2);

		TotalNumRun = size(NumScanTotal,2);  %%% number of image runs if every run were present

		%%%%% This code cuts RunDir and NumScan based which Image Runs are present  
		NumScan=[];
		clear RunDir;
		for iRun=1:NumRun
		    RunDir{iRun,1}=RunNamesTotal{RunList(1,iRun)};
		    NumScan=horzcat(NumScan,NumScanTotal(1,iRun));
		end

		NumRun= size(NumScan,2); % number of runs
		ImageNumRun=size(RunDir,1); %number of image folders

	    nj = 0;
	    switch (normmethod) 
		case 'func'
		    if (strcmp(spmver,'SPM8'))
			    job{1}.spm.temporal.st = st;
			    job{2}.spm.spatial.realign = realign;
			    job{3}.spm.spatial.normalise = normalise;
			    job{4}.spm.spatial.smooth = smooth;    
		    else
			    job{1}.temporal{1}.st = st;
			    job{2}.spatial{1}.realign{1} = realign;
			    job{3}.spatial{1}.normalise{1} = normalise;
			    job{4}.spatial{1}.smooth = smooth;
		    end
		    nj = 4;
		case 'anat'
		    if (strcmp(spmver,'SPM8'))
			    job{1}.spm.temporal.st = st;
			    job{2}.spm.spatial.realign = realign;
			    job{3}.spm.spatial.coreg = coreg;
			    job{4}.spm.spatial.coreg = coreg;
			    job{5}.spm.spatial.normalise = normalise;
			    job{6}.spm.spatial.smooth = smooth;    
		    else
			    job{1}.temporal{1}.st = st;
			    job{2}.spatial{1}.realign{1} = realign;
			    job{3}.spatial{1}.coreg{1} = coreg;
			    job{4}.spatial{1}.coreg{1} = coreg;
			    job{5}.spatial{1}.normalise{1} = normalise;
			    job{6}.spatial{1}.smooth = smooth;
		    end
		    nj = 6;
		case 'seg'
		    if (strcmp(spmver,'SPM8'))
			    job{1}.spm.temporal.st = st;
			    job{2}.spm.spatial.realign = realign;
			    job{3}.spm.spatial.coreg = coreg;
			    job{4}.spm.spatial.coreg = coreg;
			    job{5}.spm.tools.vbm8 = vbm;
		    	    %job{6}.spm.tools.vbm8 = vbmtools;
		    	    job{6}.spm.util = util;
			    job{7}.spm.spatial.smooth = smooth;     
		    else
			    job{1}.temporal{1}.st = st;
			    job{2}.spatial{1}.realign{1} = realign;
			    job{3}.spatial{1}.coreg{1} = coreg;
			    job{4}.spatial{1}.coreg{1} = coreg;
			    job{5}.tools{1}.vbm{1} = vbm;
			    job{6}.spatial{1}.normalise{1} = normalise;
			    job{7}.spatial{1}.smooth = smooth;
		    end
		    nj = 7;
	    end

	    offset = (x-1)*nj;

	    %subjdir = fullfile(Exp,ImageLevel1,SubjDir{x,1});
	    clear scancell
	    ascan = {};
	    rscan = {};
	    wscan = {};
	    sscan = {};
	    scancell = {};

        for r = 1:size(RunDir,1)
	    	frames = [1];
            if strcmp(imagetype,'nii')
	    		frames = [1:NumScan(r)];
            end
            
            Run=RunDir{r};
            iRun=num2str(r);
            ImageDirCheck = struct('Template',ImageTemplate,...
                                   'type',1,...
                                   'mode','check');
            ImageDir=mc_GenPath(ImageDirCheck);
            scan{r} = spm_select('ExtList',ImageDir,['^' basefile '.*' imagetype],frames);
            %subjpath = fullfile(subjdir,ImageLevel2,RunDir{r},ImageLevel3);
            subjpath = ImageDir;
            
            for s = 1:size(scan{r},1)
                scancell{end+1} = strtrim([subjpath scan{r}(s,:) suffix]);
                ascan{r}{s} = strtrim([subjpath scan{r}(s,:) suffix]);
                rscan{r}{s} = strtrim([subjpath Pa scan{r}(s,:) suffix]);
                wscan{end+1} = strtrim([subjpath Pra scan{r}(s,:) suffix]);
                sscan{end+1} = strtrim([subjpath Pwra scan{r}(s,:) suffix]);
            end
        end
        
	    for r = 1:size(RunDir,1)
            ascan{r} = ascan{r}';
            rscan{r} = rscan{r}';
	    end

	    wscan = wscan';
	    sscan = sscan';

        Run = RunDir{1};
	    switch (normmethod)
		case 'func'
		    if (strcmp(spmver,'SPM8'))
			    job{1}.spm.temporal.st.scans = ascan;
			    job{2}.spm.spatial.realign.estwrite.data = rscan;
			    [a b c d] = fileparts(rscan{1}{1});
			    normsource = ['mean' b c];
                ImageDirCheck = struct('Template',ImageTemplate,...
                                       'mode','check');
                ImageDir=mc_GenPath(ImageDirCheck);
			    job{3}.spm.spatial.normalise.estwrite.subj.source = {fullfile(ImageDir,normsource)};
			    job{3}.spm.spatial.normalise.estwrite.subj.resample = wscan;
			    job{3}.spm.spatial.normalise.estwrite.subj.resample{end+1} = fullfile(ImageDir,normsource);
			    job{4}.spm.spatial.smooth.data = sscan;
			    if (~doslicetiming)
				job{1} = [];
			    end
			    if (~dorealign)
				job{2} = [];
			    end
			    if (~donormalize)
				job{3} = [];
			    end
			    if (~dosmooth)
				job{4} = [];
			    end
			    job(cellfun(@isempty,job)) = [];
			    jobs{x} = job;
		    else
			    job{1}.temporal{1}.st.scans = ascan;
			    job{2}.spatial{1}.realign{1}.estwrite.data = rscan;
			    [a b c d] = fileparts(rscan{1}{1});
			    normsource = ['mean' b c];
                ImageDirCheck = struct('Template',ImageTemplate,...
                                       'mode','check');
                ImageDir=mc_GenPath(ImageDirCheck);
			    job{3}.spatial{1}.normalise{1}.estwrite.subj.source = {fullfile(ImageDir,normsource)};
			    job{3}.spatial{1}.normalise{1}.estwrite.subj.resample = wscan;
			    job{3}.spatial{1}.normalise{1}.estwrite.subj.resample{end+1} = fullfile(ImageDir,normsource);
			    job{4}.spatial{1}.smooth.data = sscan;
			    if (~doslicetiming)
				job{1}.temporal = [];
			    end
			    if (~dorealign)
				job{2}.spatial = [];
			    end
			    if (~donormalize)
				job{3}.spatial = [];
			    end
			    if (~dosmooth)
				job{4}.spatial = [];
			    end
			    for j = 1:nj
				jobs{offset+j} = job{j};
			    end
		    end    		
		case 'anat'
		    if (strcmp(spmver,'SPM8'))
			    job{1}.spm.temporal.st.scans = ascan;
			    job{2}.spm.spatial.realign.estwrite.data = rscan;

			    [a b c d] = fileparts(rscan{1}{1});
			    if (strcmp(b(1),'r') & alreadydone(2))
			    	b = b(2:end);
			    end
			    normsource = ['mean' b c];
                
                ImageDirCheck = struct('Template',ImageTemplate,...
                                       'mode','check');
                ImageDir=mc_GenPath(ImageDirCheck);
                
                OverlayDirCheck = struct('Template',OverlayTemplate,...
                                         'mode','check');
                OverlayDir=mc_GenPath(OverlayDirCheck);
                
                HiresDirCheck = struct('Template',HiresTemplate,...
                                       'mode','check');
                HiresDir=mc_GenPath(HiresDirCheck);
                
			    job{3}.spm.spatial.coreg.estimate.ref = {fullfile(ImageDir,normsource)};
			    job{3}.spm.spatial.coreg.estimate.source = {OverlayDir};
			    job{4}.spm.spatial.coreg.estimate.ref = {OverlayDir};
			    job{4}.spm.spatial.coreg.estimate.source = {HiresDir};

			    job{5}.spm.spatial.normalise.estwrite.subj.source = {HiresDir};
			    job{5}.spm.spatial.normalise.estwrite.subj.resample = wscan;
			    job{5}.spm.spatial.normalise.estwrite.subj.resample{end+1} = HiresDir;
			    
			    job{6}.spm.spatial.smooth.data = sscan;
			    if (~doslicetiming)
				job{1} = [];
			    end
			    if (~dorealign)
				job{2} = [];
			    end
			    if (~docoreg)
				job{3} = [];
				job{4} = [];
			    end
			    if (~donormalize)
				job{5} = [];
			    end
			    if (~dosmooth)
				job{6} = [];
			    end
			    job(cellfun(@isempty,job)) = [];
			    jobs{x} = job;
		    else
			    job{1}.temporal{1}.st.scans = ascan;
			    job{2}.spatial{1}.realign{1}.estwrite.data = rscan;

			    [a b c d] = fileparts(rscan{1}{1});
			    if (strcmp(b(1),'r') & alreadydone(2))
			    	b = b(2:end);
			    end
			    normsource = ['mean' b c];
                
                ImageDirCheck = struct('Template',ImageTemplate,...
                                       'mode','check');
                ImageDir=mc_GenPath(ImageDirCheck);
                
                OverlayDirCheck = struct('Template',OverlayTemplate,...
                                         'mode','check');
                OverlayDir=mc_GenPath(OverlayDirCheck);
                
                HiresDirCheck = struct('Template',HiresTemplate,...
                                       'mode','check');
                HiresDir=mc_GenPath(HiresDirCheck);
                
			    job{3}.spatial{1}.coreg{1}.estimate.ref = {fullfile(ImageDir,normsource)};
			    job{3}.spatial{1}.coreg{1}.estimate.source = {OverlayDir};
			    job{4}.spatial{1}.coreg{1}.estimate.ref = {OverlayDir};
			    job{4}.spatial{1}.coreg{1}.estimate.source = {HiresDir};

			    job{5}.spatial{1}.normalise{1}.estwrite.subj.source = {HiresDir};
			    job{5}.spatial{1}.normalise{1}.estwrite.subj.resample = wscan;
			    job{5}.spatial{1}.normalise{1}.estwrite.subj.resample{end+1} = HiresDir;
			    
			    job{6}.spatial{1}.smooth.data = sscan;
			    if (~doslicetiming)
				job{1}.temporal = [];
			    end
			    if (~dorealign)
				job{2}.spatial = [];
			    end
			    if (~docoreg)
				job{3}.spatial = [];
				job{4}.spatial = [];
			    end
			    if (~donormalize)
				job{5}.spatial = [];
			    end
			    if (~dosmooth)
				job{6}.spatial = [];
			    end
			    for j = 1:nj
				jobs{offset+j} = job{j};
			    end
		    end
		case 'seg'
		    if (strcmp(spmver,'SPM8'))
			    job{1}.spm.temporal.st.scans = ascan;
			    job{2}.spm.spatial.realign.estwrite.data = rscan;

			    [a b c d] = fileparts(rscan{1}{1});
			    if (strcmp(b(1),'r') & alreadydone(2))
			    	b = b(2:end);
			    end
			    normsource = ['mean' b c];
                
                ImageDirCheck = struct('Template',ImageTemplate,...
                                       'mode','check');
			    ImageDir=mc_GenPath(ImageDirCheck);
                
                OverlayDirCheck = struct('Template',OverlayTemplate,...
                                         'mode','check');
                OverlayDir=mc_GenPath(OverlayDirCheck);
                
                HiresDirCheck = struct('Template',HiresTemplate,...
                                       'mode','check');
                HiresDir=mc_GenPath(HiresDirCheck);
                
			    job{3}.spm.spatial.coreg.estimate.ref = {fullfile(ImageDir,normsource)};
			    job{3}.spm.spatial.coreg.estimate.source = {OverlayDir};
			    job{4}.spm.spatial.coreg.estimate.ref = {OverlayDir};
			    job{4}.spm.spatial.coreg.estimate.source = {HiresDir};

			    job{5}.spm.tools.vbm8.estwrite.data = {HiresDir};
            		    
            		    %job{6}.spm.tools.vbm8.tools.defs.field = {fullfile(subjdir,anatdir,['y_r' hires '.nii'])};
            		    %job{6}.spm.tools.vbm8.tools.defs.fnames = wscan;
		    	    
		    	    %job{6}.spm.util.defs.comp{1}.def = {fullfile(subjdir,anatdir,['y_r' hires '.' imagetype])};
                    
                    [HiResPath HiResName]=fileparts(HiResTemplate);
                    
		    	    job{6}.spm.util.defs.comp{1}.def = {fullfile(HiResPath,['y_r' HiResName '.nii'])}; %%%Mike needs to check this
		    	    job{6}.spm.util.defs.fnames = wscan;
		    	    	    	    
		    	    %job{6}.spm.spatial.normalise.write.subj.matname = {fullfile(subjdir,anatdir,[hires '_seg8.mat'])};
		            %job{6}.spm.spatial.normalise.write.subj.resample = wscan;
			    %job{6}.spm.spatial.normalise.write.subj.matname = {fullfile(subjdir,anatdir,[hires '_seg_sn.mat'])};
			    %job{6}.spm.spatial.normalise.write.subj.resample = wscan;
			    
			    job{7}.spm.spatial.smooth.data = sscan;
			    if (~doslicetiming)
				job{1} = [];
			    end
			    if (~dorealign)
				job{2} = [];
			    end
			    if (~docoreg)
				job{3} = [];
				job{4} = [];
			    end
			    if (~donormalize)
				job{5} = [];
                		job{6} = [];
			    end
			    if (~dosmooth)
				job{7} = [];
			    end
			    job(cellfun(@isempty,job)) = [];
			    jobs{x} = job;
		    else
			    job{1}.temporal{1}.st.scans = ascan;
			    job{2}.spatial{1}.realign{1}.estwrite.data = rscan;

			    [a b c d] = fileparts(rscan{1}{1});
			    if (strcmp(b(1),'r') & alreadydone(2))
			    	b = b(2:end);
			    end
			    normsource = ['mean' b c];
                
                ImageDirCheck = struct('Template',ImageTemplate,...
                                       'mode','check');
                ImageDir=mc_GenPath(ImageDirCheck);
                
                OverlayDirCheck = struct('Template',OverlayTemplate,...
                                         'mode','check');
                OverlayDir=mc_GenPath(OverlayDirCheck);
                
                HiresDirCheck = struct('Template',HiresTemplate,...
                                       'mode','check');
                HiresDir=mc_GenPath(HiresDirCheck);
                
			    job{3}.spatial{1}.coreg{1}.estimate.ref = {fullfile(ImageDir,normsource)};
			    job{3}.spatial{1}.coreg{1}.estimate.source = {OverlayDir};
			    job{4}.spatial{1}.coreg{1}.estimate.ref = {OverlayDir};
			    job{4}.spatial{1}.coreg{1}.estimate.source = {HiresDir};

			    job{5}.tools{1}.vbm{1}.estwrite.data = {HiresDir};
                [HiResPath HiResName]=fileparts(HiResTemplate);
			    job{6}.spatial{1}.normalise{1}.write.subj.matname = {fullfile(HiResPath,[HiResName '_seg_sn.mat'])}; %Mike needs to check this
			    job{6}.spatial{1}.normalise{1}.write.subj.resample = wscan;
			    
			    job{7}.spatial{1}.smooth.data = sscan;
			    if (~doslicetiming)
				job{1}.temporal = [];
			    end
			    if (~dorealign)
				job{2}.spatial = [];
			    end
			    if (~docoreg)
				job{3}.spatial = [];
				job{4}.spatial = [];
			    end
			    if (~donormalize)
				job{5}.tools = [];
				job{6}.spatial = [];
			    end
			    if (~dosmooth)
				job{7}.spatial = [];
			    end
			    for j = 1:nj
				jobs{offset+j} = job{j};
			    end
		    end
	     end


	end

	spm_jobman('run',jobs);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% First Level section
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (Processing(2) == 1)

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%     Don't Edit Below This Line     %%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%Set to 1 if using spm2 %%% Caution, full script not compatible yet
	spm2 = 0;

	%%% if StartOp is set to '1', then need to set the start point below
	StartPoint = 2 % manual start point doesn't work with SPM5

	NanVar = NaN;

	if (~exist('RegOp'))
		RegOp = 0;
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%      Paths and Filenames           %%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    MasterFileCheck = struct('Template',MasterTemplate,...
                             'mode','check');
	MasterFile = mc_GenPath(MasterFileCheck);
    %fullfile(Exp,MasterLevel1,MasterLevel2);

    RegFileCheck = struct('Template',RegTemplate,...
                          'mode','check');
	RegFile = mc_GenPath(RegFileCheck);
    %fullfile(Exp,RegLevel1,RegLevel2);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%% Calculated parameters %%%%%%%%%%%%%%%%%%%%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

	%RunNamesTotal = RunDir;
	
	SubjColumn = SubjColumn - MasterDataSkipCols;
	RunColumn = RunColumn - MasterDataSkipCols;
	RegSubjColumn = RegSubjColumn - RegDataSkipCols;
	RegRunColumn = RegRunColumn - RegDataSkipCols;
	CondColumn = CondColumn - MasterDataSkipCols;
	TimColumn = TimColumn - MasterDataSkipCols;
	DurColumn = DurColumn - MasterDataSkipCols;
	if (RegOp == 1)
		for x = 1:size(RegList,1)
			RegList{x,2} = RegList{x,2} - RegDataSkipCols;
		end
	end

	NumCond = size(ConditionName,1); %number of conditions
	NumCondCol = size(CondColumn,2); % number of columns that assign conditions

	NumPar = size(ParList,1);
	for iPar = 1: NumPar
		ParName{iPar}=ParList{iPar,1};
		ParColumn{iPar}=ParList{iPar,2};

		if NumCondCol > 1
		    ParCondCol{iPar}=ParList{iPar,3};
		end
	end % loop through parameters

	NumReg = size(RegList,1);

	NumSubject = size(SubjDir,1);


	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%%      Read Data from Files          %%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	if strcmp(MasterFile(end-3:end),'.csv')
        %CheckPath(MasterFile,'Check your MasterTemplate')
        MasterData = csvread([MasterFile],MasterDataSkipRows,MasterDataSkipCols);
    else
        %CheckPath([MasterFile '.csv'],'Check your MasterTemplate')
        MasterData = csvread([MasterFile, '.csv'],MasterDataSkipRows,MasterDataSkipCols);
	end

	% regressor line
	if RegOp ==1;
            if strcmp(RegFile(end-3:end),'.csv')
                %CheckPath(RegFile,'Check your RegTemplate')
                RegMasterData = csvread ([RegFile],RegDataSkipRows,RegDataSkipCols);     
            else
                %CheckPath([RegFile '.csv'],'Check your RegTemplate')
                RegMasterData = csvread ([RegFile, '.csv'],RegDataSkipRows,RegDataSkipCols);
            end
	end

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%% Begin looping over subjects %%%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	for iSubject = 1:NumSubject %First level fixed effect, subject by subject
        clear SPM;
        Subject=SubjDir{iSubject,1};
		SubjRow=SubjDir{iSubject,2};  
		RunList=SubjDir{iSubject,3};

		NumRun = size(RunList,2);

		TotalNumRun = size(NumScanTotal,2);  %%% number of image runs if every run were present

		%%%%% This code cuts RunDir and NumScan based which Image Runs are present  
		NumScan=[];
		clear RunDir;
		for iRun=1:NumRun
		    RunDir{iRun,1}=RunNamesTotal{RunList(1,iRun)};
		    NumScan=horzcat(NumScan,NumScanTotal(1,iRun));
		end

		NumRun= size(NumScan,2); % number of runs
		ImageNumRun=size(RunDir,1); %number of image folders

		%TrialsPerRun = TotalTrials / TotalNumRun; % Assumes same number of trials in each run!!!

		% Clear the variables
		    clear SPM
		    P=[];
		    clear CondLength


		    fprintf('Building Fixed Effects Analysis of %s\n', SubjDir{iSubject,1});



		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%      Parse Data Columns into input variables  %%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%% The following routine reads the Masterdata file for onsets, durations and parameters (if there are any) for every event in every trial in the whole experiment



		%%%%% assign values to main variables
		if (IdenticalModels)
			Data=MasterData(1:TotalTrials,:);
		else
			%Data=MasterData(((SubjRow-1)*TotalTrials)+1:(((SubjRow-1)*TotalTrials)+TotalTrials),:);
			Data=MasterData(find(MasterData(:,SubjColumn)==SubjRow),:);
		end

		%%%% Shorten data according to runs present in RunList
		NewData=[];
		TrialsPerRun = [];
		for iRun=1:TotalNumRun
			%DataRun=Data(((iRun-1)*TrialsPerRun)+1:(((iRun-1)*TrialsPerRun)+TrialsPerRun),:);
			DataRun = Data(find(Data(:,RunColumn)==iRun),:);
			if ismember(iRun,RunList)
				NewData=vertcat(NewData,DataRun);
				TrialsPerRun = [TrialsPerRun size(DataRun,1)];
			end
		end
		Data=NewData;

                if (isempty(ConditionName)) 
                    TrialsPerRun = zeros(size(TrialsPerRun));
                end
                
		for iCondCol = 1: NumCondCol
		NumCondPerCondCol(iCondCol) = size(unique(MasterData(:,CondColumn(iCondCol))),1);
		CondValues{iCondCol} = Data(1:size(Data,1), CondColumn(iCondCol));
		TimValues{iCondCol} = Data(1:size(Data,1), TimColumn(iCondCol));
		DurValues{iCondCol} = Data(1:size(Data,1), DurColumn(iCondCol));

		for iPar = 1 : NumPar
		ParValues{iPar,iCondCol} = Data(1:size(Data,1), ParColumn{iPar});
		end
		end % loop through Condition Columns
		%%%%%%%%%%%%%%%%%


		%%%% clear variables that are maintained accross all runs
		clear Timing 
		clear Duration
		clear Parameter

		offset = 0;
		%%%% clear variables reused for each run  
		for iRun=1:NumRun
		clear RunTiming
		RunTiming=cell(1,NumCond);


		clear RunDur
		RunDur=cell(1,NumCond);


		clear RunPar
		for iPar = 1 : NumPar
		RunPar{iPar}=cell(1,NumCond);
		end


		%%%%%%%%%%%%%% Begin main parsing routine
		for iCondCol = 1: NumCondCol    

		%%%%%%%%%%%%%% 
		% calculate an adjustment factor that represents any conditions already assigned by previous Condition Columns
		    if iCondCol > 1
		CondColAdjustment = CondColAdjustment + NumCondPerCondCol(iCondCol-1);
		else 
		    CondColAdjustment= 0;
		    end
		%%%%%%%%%%%%%%


		for iTrial = 1 : TrialsPerRun(iRun)

			%jTrial = ((iRun-1)*TrialsPerRun)+iTrial;
			jTrial = offset + iTrial;
			
			iCondValue=CondValues{iCondCol}(jTrial,1);
			iTimValue=TimValues{iCondCol}(jTrial,1);
			iDurValue=DurValues{iCondCol}(jTrial,1);

		for iPar = 1 : NumPar      
		    iParValue{iPar}=ParValues{iPar,iCondCol}(jTrial,1);
		end

		%%% Handle case where condition, onset or duration is set to NaN
		if (isnan(iCondValue) | isnan(iTimValue) | isnan (iDurValue))
		    iCondValue=NaN;
		    iTimValue=NaN;
		    iDurValue=NaN;
		    for iPar = 1 : NumPar      
		    iParValue{iPar}=NaN;
		    end
		%%%        
		else




		    RunTiming{iCondValue+CondColAdjustment}= vertcat(RunTiming{iCondValue+CondColAdjustment},iTimValue);
		     RunDur{iCondValue+CondColAdjustment}= vertcat(RunDur{iCondValue+CondColAdjustment},iDurValue);

		for iPar = 1 : NumPar   

		     if (NumCondCol==1 | (NumCondCol>1 & ParCondCol{iPar}==iCondCol))  % if the curent condition column is one that the parameter is supposed to modulate
		  %    RunPar{iPar}{iCondValue+CondColAdjustment}= vertcat(RunPar{iPar}{iCondValue+CondColAdjustment}, NanVar);  
		  %  else
		     RunPar{iPar}{iCondValue+CondColAdjustment}= vertcat(RunPar{iPar}{iCondValue+CondColAdjustment},iParValue{iPar}); 
		     end
		end % loop through parameters

		end % else statement
		end % loop through trials

		    Timing{iRun}=RunTiming;
		     Duration{iRun}=RunDur;
		for iPar = 1 : NumPar   
		      Parameter{iPar,iRun}=RunPar{iPar};  
		end    

		   end % loop through Condition Columns 

			offset = offset + TrialsPerRun(iRun);
		end % loop through runs
		%%%%%%%%%%%%%% End main parsing routine   

        
        %%% Count length of each condition in each run

		for iRun = 1 : NumRun 


		    for iCond=1:NumCond

		%         if sum(isnan(Timing{iRun}{1,iCond}),1) == size(Timing{iRun}{1,iCond},1)
		%             CondLength(iRun,iCond)= 0;
		%         else

			CondLength(iRun,iCond)=  size(Timing{iRun}{1,iCond},1);
		%        end
		    end   % Loop through conditions
		end % loop through runs
        
        
        
        
        %%%%%%%%%%%%%% Produce formatted screen output %%%%%%%%%%%

            display(sprintf('\n\n\n'));
display('***********************************************')
display(sprintf('I am working on Subject: %s', SubjDir{iSubject,1}));
display(sprintf('The number of runs is: %s', num2str(NumRun)));
display(sprintf('For each run, here are the onsets, durations, and parameters: '));
        
        for iRun=1:NumRun
            
            fprintf('\nRun: %g',iRun)
            for iCond=1:NumCond
                fprintf('\nCondition %g: ',iCond)  %%%% (Onset, Duration, Parameter Vals)
          
                for iVal = 1: CondLength(iRun,iCond)
                    
                    fprintf('(%g, ',Timing{iRun}{1,iCond}(iVal))
                    fprintf('%g',Duration{iRun}{1,iCond}(iVal))
                    for iPar = 1: NumPar
                        fprintf(', %g',Parameter{iPar,iRun}{1,iCond}(iVal))
                    end;
                    
                fprintf(') ');     
                
                end  % loop through iVals
            end  % loop through conditions
        end % loop through runs
        
        
        
        
		%%% remove NaN's from variables

		for iRun = 1 : NumRun 

		    iRun;
		    for iCond=1:NumCond

              iCond;
			  Timing{iRun}{1,iCond}= Timing{iRun}{1,iCond}(isnan(Timing{iRun}{1,iCond})==0);
			  Duration{iRun}{1,iCond}= Duration{iRun}{1,iCond}(isnan(Duration{iRun}{1,iCond})==0);

			  Timing{iRun}{1,iCond};
			  Duration{iRun}{1,iCond};

			  for iPar = 1: NumPar
                  
                Parameter{iPar,iRun}{1,iCond} = Parameter{iPar,iRun}{1,iCond}(isnan(Parameter{iPar,iRun}{1,iCond})==0);

                Parameter{iPar,iRun}{1,iCond};

			  end % loop through parameters
		    end  % loop through conditions       

		end % loop through runs


		







		OutputDir = mc_GenPath(OutputTemplate);
        display(sprintf('\n\nI am going to save the output here: %s', OutputDir));
        %fullfile(Exp,OutputLevel1,SubjDir{iSubject,1},OutputLevel2,OutputLevel3);

		if (Mode == 1 | Mode ==2) 
		    %eval(sprintf('!mkdir -p %s', OutputDir))
            mc_GenPath( struct('Template',OutputDir,...
                               'mode','makeparentdir') );
		    cd(OutputDir)
		end

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%% Assign onsets, durations and parameters to SPM variables  %%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

			for iRun = 1:NumRun
			    if NumCond == 0  % case wehere the run lacks any conditions

				 SPM.Sess(iRun).U = [];
			    else

				iCond=1;

				for jCond = 1:NumCond-CondModifier

				    if CondLength(iRun,jCond)>CondThreshold % case where condition has more than CondThreshold members

				    SPM.Sess(iRun).U(iCond).name  = {[RunDir{iRun}, ConditionName{jCond}]};
				    SPM.Sess(iRun).U(iCond).ons   = Timing{iRun}{1,jCond};

		   %                 if filedur==1
				    SPM.Sess(iRun).U(iCond).dur   = Duration{iRun}{1,jCond};

		%                     else
		%                         SPM.Sess(iRun).U(iCond).dur   = TrialDur;
		%                     end

				     SPM.Sess(iRun).U(iCond).P(1).name = 'none';
				    if NumPar == 0
				     %SPM.Sess(iRun).U(iCond).P(1).name = 'none';
				    else


				       iPar=1;  % iPar is the counter for the output (SPM) variable
				     for jPar = 1:NumPar % jPar is the counter for the input variable


					 if size(Parameter{jPar,iRun}{1,jCond},1) > CondThreshold % case where parameter has more than CondThreshold members
				     SPM.Sess(iRun).U(iCond).P(iPar).name = [RunDir{iRun}, ParList{jPar,1}];
				     SPM.Sess(iRun).U(iCond).P(iPar).P = Parameter{jPar,iRun}{1,jCond};
				     SPM.Sess(iRun).U(iCond).P(iPar).h = 1; % order of polynomial expansion

				     iPar=iPar+1;
					 end


				     end % loop through parameters

				    end % end parameter else statement


				     iCond=iCond+1;
				   end    % end if regarding whether length of condition is zero

				end % loop through conditions



			    end % end else statement
			end % loop through runs

		 % design (user specified covariates) -  %---------------------------------------------------------------------------


		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%% Scan-by-Scan Regressors     %%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		 %%% case where there are no regressors
		    for iSess = 1:NumRun
			SPM.Sess(iSess).C.C    = [];          
			SPM.Sess(iSess).C.name = {}; 
		    end

		 %%% case where there are regressors
		 if NumReg > 0

		 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
		     if RegOp == 2 % case where you preset regressors

			 %set preset regressor values below
			 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			 reg{1} = [ones(1,200) zeros(1,600)];
			 reg{2} = [zeros(1,200) ones(1,200) zeros(1,400)];
			 reg{3} = [zeros(1,400) ones(1,200) zeros(1,200)];
			 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

			 %% assign regressor name
			  for iRun=1:NumRun  
			      clear RegNameHor;
			  for iReg = 1:NumReg    
			      SPM.Sess(iRun).C.C(:,iReg) = reg{iReg};



			      RegNameHor {1,iReg} = RegList{iReg,1};
			  end
			  SPM.Sess(iRun).C.name = RegNameHor;
			  end

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
		 else % case where you get your regressors from file

		     RegData=[];
		     RegDataCol=[];

		     TotalScan = sum(NumScanTotal);
		     %Data=MasterData(find(MasterData(:,SubjColumn)==SubjRow),:);
		     RegData=RegMasterData(find(RegMasterData(:,RegSubjColumn)==SubjRow),:);
		     
		     %RegData=RegMasterData(((SubjRow-1)*TotalScan)+1:(((SubjRow-1)*TotalScan)+TotalScan),:);

		%%%% Shorten data according to runs present in RunList
		NewRegData=[];
		for iRun=1:TotalNumRun
			NewDataRun = RegData(find(RegData(:,RegRunColumn)==iRun),:);
			if ismember(iRun,RunList)
				NewRegData=vertcat(NewRegData,NewDataRun);
			end
		end
		RegData=NewRegData;
		
		%%%% Shorten data according to runs present in RunList
		%NewRegData=[];
		%for iRun=1:TotalNumRun
		%	NewDataRun=RegData(((iRun-1)*NumScanTotal(iRun))+1:(((iRun-1)*NumScanTotal(iRun))+NumScanTotal(iRun)),:);
		%	if ismember(iRun,RunList)
		%		NewRegData=vertcat(NewRegData,NewDataRun);
		%	end
		%end
		RegData=NewRegData;
			   iScan=1;

			   for iRun=1:NumRun



			  for iReg = 1:NumReg

		      RegDataCol = RegData(iScan:iScan+(NumScan(1,iRun)-1),RegList{iReg,2}); % RegDataCol now contains the column of regressors for regressor#iReg for run#iRun
		      SPM.Sess(iRun).C.C(:,iReg) = RegDataCol; % assign this RegDataCol to appropriate column in the SPM variable

			  end % loop through regressors

			 %% assign regressor name
			  clear RegNameHor;
			  for iReg = 1:NumReg
			      RegNameHor {1,iReg} = RegList{iReg,1};
			  end
			  SPM.Sess(iRun).C.name = RegNameHor;
			  iScan = iScan + NumScan (1,iRun);

			  end % loop through run


		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
		     end %% end conditional on RegOp

		 end    % end regressor routine



		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%% Get images from Image Directory    %%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		%%%%%%%%%%%%%%%%%%     
		%%%% for SPM2 %%%%
		%%%%%%%%%%%%%%%%%%
		    for iRun = 1:ImageNumRun
                frames = [1];
                if (strcmp(imagetype,'nii'))
                    frames = [1:NumScanTotal(RunList(iRun))];
                end
                % directory of images in a subject
            
                Run=RunDir{iRun};
                ImageDirCheck = struct('Template',ImageTemplate,...
                                       'mode','check');
                ImageDir = mc_GenPath(ImageDirCheck);
                %fullfile(Exp,ImageLevel1,SubjDir{iSubject,1},ImageLevel2,RunDir{iRun},ImageLevel3); 
                %CheckPath(ImageDir,'Check your ImageTemplate');


                % for SPM2
                if (spm2)
                    tmpP = spm_get('files',ImageDir,[Pwra basefile '*.img']); 
                else
                    tmpP = spm_select('ExtFPList',ImageDir,['^' basefile '.*.' imagetype],frames);
                end
                P = strvcat(P,tmpP);

                if isempty(P)
                    display(sprintf('Sorry friend. I was looking for your functional images here: %s. I could not find any images there.', ImageDir));
                    error('');
                end
		    end
		%%%%%%%%%%%%%%%%%%

		    SPM.xY.P = P; %Put all the images session-wise

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%% SPM Design Parameters     %%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


		    SPM.nscan = NumScan;

		 % basis functions and timing parameters
		 %---------------------------------------------------------------------------
		 % OPTIONS:'hrf'
		 %         'hrf (with time derivative)'
		 %         'hrf (with time and dispersion derivatives)'
		 %         'Fourier set'
		 %         'Fourier set (Hanning)'
		 %         'Gamma functions'
		 %         'Finite Impulse Response'
		 %---------------------------------------------------------------------------
		 %AP Model/'
		    SPM.xBF.name       	= 'hrf';
		    SPM.xBF.length     	= 32;   % length in seconds; not used in HRF because HRF computes this
		    SPM.xBF.order      	= 1;    % order of basis set; not used for HRF because HRF computes this
		    SPM.xBF.T          	= 16;   % number of time bins per scan; 16 is default 
		    SPM.xBF.T0         	= fMRI_T0;    % first time bin (see slice timing) WHEN DATA SLICE TIME CORRECTED, 
						%TAKE SAME REF-SLICE AS REF_SLICE IN SLICE TIMING. 
		    SPM.xBF.UNITS      	= 'secs';         % OPTIONS: 'scans'|'secs' for timing
		    SPM.xBF.Volterra   	= 1;              % OPTIONS: 1 No|2 Yes = order of convolution

		 % global normalization: OPTINS:'Scaling'|'None'
		 %---------------------------------------------------------------------------
		    SPM.xGX.iGXcalc    = ScaleOp;

		 % low frequency confound: high-pass cutoff (secs) [Inf = no filtering]
		 %---------------------------------------------------------------------------
		    SPM.xX.K.HParam  = 128; 
		 %Supposed to be lower in frequency than the min frequency of among conditions

		 % intrinsic autocorrelations: OPTIONS: 'none'|'AR(1) + w'
		 %-----------------------------------------------------------------------
		  %  SPM.xVi.form       = 'AR(1) + w'; %Used in SPM2

		  if (usear1)
			if (spm2)
				SPM.xVi.form = 'AR(1) + w';
			else
				SPM.xVi.form = 'AR(0.2)'; %Used in SPM5
			end
		  else
			SPM.xVi.form = 'none';
		  end

		 % specify data:  TR
		     SPM.xY.RT = TR; % TR in seconds

		 %===========================================================================


		 SPM.xM.VM = [];
		 if (~isempty(explicitmask))
		 	SPM.xM.VM = spm_vol(explicitmask);
		 end
		 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		 %%%%%%%%%% Configure design matrix %%%%%%%%%%%%%%
		 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		 if Mode == 1
		 SPM = spm_fmri_spm_ui(SPM);
		 end

		 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		 %%%%%%%%%% Estimation %%%%%%%%%%%%%%%%%%%%%%%%%%%
		 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		    fprintf('Start Model Estimation for %s\n', SubjDir{iSubject,1});
		  if Mode == 1
		    SPM = spm_spm(SPM);
		  elseif Mode == 2
		      clear SPM;
		      load('SPM.mat');
		  end

		    fprintf('Model Estimation Done for %s\n', SubjDir{iSubject,1});


		 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		 %%%%%%%%%% Contrasts %%%%%%%%%%%%%%%%%%%%%%%%%%%%
		 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		    fprintf('Start Contrast Building for %s\n', SubjDir{iSubject,1});


		clear ContrastContent

		%%%% Figure out which conditions are present and set up scaling vector %%%%%%%%
		CondPresent = ones(NumRun,NumCond);
		for iRun = 1: NumRun
		    for iCond = 1: NumCond-CondModifier
			if CondLength(iRun,iCond)<=CondThreshold
			    CondPresent(iRun,iCond)=0;
			end

		    end
		end

		Scaling = sum(CondPresent,1);
		Scaling = NumRun./Scaling  % This needs attention


		%%%%% Set up "dynamic" contrasts %%%%%
		NumContrast=size(ContrastList,1);


		for iContrast = 1: NumContrast


		    ContrastName{iContrast} = ContrastList{iContrast,1};
		    ContrastBase=[];

		     for iRun=1:NumRun

			for iCond=1:NumCond-CondModifier

			    CondContrast = ContrastList{iContrast, iCond+1};



			    if CondLength(iRun, iCond)  > CondThreshold

			  CondContrast = CondContrast * Scaling(1,iCond);  % apply scaling factor
			  ContrastBase= horzcat(ContrastBase,CondContrast);


			    end

			end % loop through conditions
		  if NumReg > 0
		      ContrastBase = horzcat(ContrastBase, ContrastList{iContrast, NumCond+2});
		  end        
		     end % loop through runs




		 ContrastContent{iContrast} = 1/NumRun*ContrastBase;  % Normalize the values of the contrast vector based on the number of runs
		 ContrastContent{iContrast} = horzcat(ContrastContent{iContrast},zeros(1,NumRun));  % Right pad the contrast vector with zeros for each SMP automatic run regressor
		 end % loop through contrasts
		%     
		%     


		if ((Mode == 1 | Mode ==2) & StartOp ~=1) % case where you want do *not* want to set your own start (and thus want to simply append to previous contrasts)
		    StartPoint=length(SPM.xCon)+1;
		end


		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%% Assign Contrasts to SPM variables %%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%% For SPM2 %%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		% loop through the contrast tests
		%if (Mode == 1 | Mode ==2)
		%  for iContrast = 1:size(ContrastContent,2)
		%       SPM.xCon((StartPoint-1)+iContrast) = spm_FcUtil('Set',ContrastName{iContrast},'T','c',ContrastContent{iContrast}(:),SPM.xX.xKXs); 
		%   end
		% end
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%% For SPM5 %%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


		% 
		% 
		if (Mode == 1 | Mode == 2)
		    clear jobs
		    jobs{1}.stats{1}.con.spmmat = {fullfile(OutputDir,'SPM.mat')};
		    if (StartOp == 2)
			jobs{1}.stats{1}.con.delete = 0;
		    else
			jobs{1}.stats{1}.con.delete = 1;    
		    end
		    for iContrast = 1:size(ContrastContent,2)
			%    
			if (sum(abs(ContrastContent{iContrast})) == 0)
				ContrastContent{iContrast}(1) = 1;
				fprintf(1,'\n**************************\nEvent not represented for contrast %d, %s\n**************************\n', iContrast,ContrastName{iContrast});
				ContrastName{iContrast} = 'DUMMYEVENTNOTREPRESENTEDDUMMY';
			end  
			jobs{1}.stats{1}.con.consess{iContrast}.tcon.name = ContrastName{iContrast};
			jobs{1}.stats{1}.con.consess{iContrast}.tcon.convec = ContrastContent{iContrast};
			jobs{1}.stats{1}.con.consess{iContrast}.tcon.sessrep='none';
		    end
		    if (strcmp(spmver,'SPM8')==1)
			temp{1} = jobs;
			matlabbatch = spm_jobman('spm5tospm8',temp)
			spm_jobman('run_nogui',matlabbatch);
		    else
			spm_jobman('run_nogui',jobs);
		    end  
		end

		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%% Evaluate Contrasts %%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%  ---------------------------------------------------------------------------
		if (Mode == 1 | Mode ==2)
		%spm_contrasts(SPM); 
		end
			fprintf('Contrast Test Done for %s\n', SubjDir{iSubject,1});
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		%%%%%%%%%%    Done with subject   %%%%%%%%%%%%%%%%
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	end % loop through subjects
	fprintf('All Done\n');
display('***********************************************\n\n\n')
end


