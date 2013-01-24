%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% You shouldn't need to edit this script
%%% Instead make a copy of Preprocess_mc_template.m 
%%% and edit that to match your data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Code to create logfile name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LogDirectory = mc_GenPath(struct('Template',LogTemplate,'mode','makedir'));
result = mc_Logger('setup',LogDirectory);
if (~result)
    %error with setting up logging
    mc_Error('There was an error creating your logfiles.\nDo you have permission to write to %s?',LogDirectory);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% General calculations that apply to both Preprocessing and First Level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
newbasefile = basefile;

if (alreadydone(1))
	newbasefile = [stp newbasefile];
end
if (alreadydone(2))
	newbasefile = [rep newbasefile];
end
if (alreadydone(3))
    newbasefile = [cop newbasefile];
end
if (alreadydone(4))
    newbasefile = [chp newbasefile];
end
if (alreadydone(5))
	newbasefile = [nop newbasefile];
end
if (alreadydone(6))
	newbasefile = [smp newbasefile];
end

doslicetiming = StepsToDo(1);
dorealign = StepsToDo(2);
docoregoverlay = StepsToDo(3);
docoreghires = StepsToDo(4);
donormalize = StepsToDo(5);
dosmooth = StepsToDo(6);

stp = SliceTimePrefix;
rep = RealignPrefix;
cop = CoregOverlayPrefix;
chp = CoregHiResPrefix;
nop = NormalizePrefix;
smp = SmoothPrefix;

if (~exist('doslicetiming') | ~doslicetiming)
	stp = '';
end
if (~exist('dorealign') | ~dorealign)
	rep = '';
end
if (~exist('docoregoverlay') | ~docoregoverlay)
    cop = '';
end
if (~exist('docoreghires') | ~docoreghires)
    chp = '';
end
if (~exist('donormalize') | ~donormalize)
	nop = '';
end
if (~exist('dosmooth') | ~dosmooth)
	smp = '';
end
	
Pa = [stp];
Pra = [rep stp];
Pora = [cop rep stp];
Phora = [chp cop rep stp];
Pwhora = [nop chp cop rep stp];	
Pswhora = [smp nop chp cop rep stp];

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
	
Processing(1) = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Preprocessing Section
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (Processing(1) == 1)

	%suffix = ',1';
	suffix = '';

	st.scans = {};
	st.tr = TR;
	st.nslices = NumSlices;
	st.ta = (TR-(TR/NumSlices));
	st.so = SliceOrder;
    if (~exist('RefSlice','var') | isempty(RefSlice))
        st.refslice = floor(NumSlices/2);
    else
        st.refslice = RefSlice;
    end
	st.prefix = stp;

	realign.estwrite.data = {}; %
    realign.estwrite.eoptions = defaults.realign.estimate;
    realign.estwrite.roptions = defaults.realign.write;
    realign.estwrite.roptions.prefix = rep;
    
    coreg.estimate = defaults.coreg.estimate;
	coreg.estimate.ref = {};
	coreg.estimate.source = {};
	coreg.estimate.other = {''};

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
		util.defs.comp{2}.idbbvox.vox = VoxelSize;
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
		vbm.estwrite.output.extopts.bb = [-78 -112 -50;78 76 85];
		vbm.estwrite.output.extopts.writeaffine = 0;
		vbm.estwrite.output.extopts.print = 1;
	end

	if (strcmp(NormMethod,'seg'))
		normalise.write.subj.matname = {};
		normalise.write.subj.resample = {};
		normalise.write.roptions.preserve = 0;
		normalise.write.roptions.bb = [-78 -112 -50;78 76 85];
		normalise.write.roptions.vox = VoxelSize;
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
		normalise.estwrite.roptions.vox = VoxelSize;
		normalise.estwrite.roptions.interp = 1;
		normalise.estwrite.roptions.wrap = [0 0 0];
		normalise.estwrite.roptions.prefix = nop;
    end

    smooth = defaults.smooth;
	smooth.data = {};
    if (numel(SmoothingKernel)==1)
        smooth.fwhm = [SmoothingKernel SmoothingKernel SmoothingKernel];
    else
        smooth.fwhm = SmoothingKernel;
    end
	smooth.dtype = 0;
	smooth.im = 0;
	smooth.prefix = smp;

    %%%MAYBE NOT NEEDED?
	%%%if (strcmp(spmver,'SPM8'))
	%%%    realign.estwrite.eoptions.weight = {''};
	%%%    normalise.estwrite.subj.wtsrc = '';
	%%%    normalise.estwrite.eoptions.weight = '';
    %%%end
    
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
		    NumScan=horzcat(NumScan,NumScanTotal(1,RunList(1,iRun)));
		end

		NumRun= size(NumScan,2); % number of runs
		ImageNumRun=size(RunDir,1); %number of image folders

	    nj = 0;
	    switch (NormMethod) 
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
            scan{r} = spm_select('ExtList',ImageDir,['^' newbasefile '.*' imagetype],frames);
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
	    switch (NormMethod)
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
                    
                    [HiResPath HiResName]=fileparts(HiresDir);
                    
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
                [HiResPath HiResName]=fileparts(HiresDir);
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