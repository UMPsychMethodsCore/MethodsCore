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
global mcLog

%%%set up variables for sandboxing
if (UseSandbox)
    username = getenv('USER');
    pid = num2str(feature('GetPID'));
    if (exist('SandboxDir','var') & ~isempty(SandboxDir))
        hostname = SandboxDir;
    else
        [ans hostname] = system('hostname -s');
        hostname = [filesep hostname(1:end-1) filesep 'sandbox'];
    end
    [fd fn fe] = fileparts(mcLog);
    Sandbox = fullfile(hostname,[username '_' pid '_' fn]);
    mc_Logger('log',sprintf('Using sandbox %s',Sandbox),3);
else
    Sandbox = '';
    mc_Logger('log','Not using sandbox',3);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% General calculations that apply to both Preprocessing and First Level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
newbasefile = basefile;

stp = SliceTimePrefix;
rep = RealignPrefix;
cop = CoregOverlayPrefix;
chp = CoregHiResPrefix;
nop = NormalizePrefix;
smp = SmoothPrefix;

if (AlreadyDone(1))
	newbasefile = [stp newbasefile];
end
if (AlreadyDone(2))
	newbasefile = [rep newbasefile];
end
if (AlreadyDone(3))
    newbasefile = [cop newbasefile];
end
if (AlreadyDone(4))
    newbasefile = [chp newbasefile];
end
if (AlreadyDone(5))
	newbasefile = [nop newbasefile];
end
if (AlreadyDone(6))
	newbasefile = [smp newbasefile];
end

doslicetiming = StepsToDo(1);
dorealign = StepsToDo(2);
docoregoverlay = StepsToDo(3);
docoreghires = StepsToDo(4);
donormalize = StepsToDo(5);
dosmooth = StepsToDo(6);

if (~exist('doslicetiming','var') || ~doslicetiming)
	stp = '';
end
if (~exist('dorealign','var') || ~dorealign)
	rep = '';
end
if (~exist('docoregoverlay','var') || ~docoregoverlay)
    cop = '';
end
if (~exist('docoreghires','var') || ~docoreghires)
    chp = '';
end
if (~exist('donormalize','var') || ~donormalize)
	nop = '';
end
if (~exist('dosmooth','var') || ~dosmooth)
	smp = '';
end
	
Pa = stp;
Pra = [rep stp];
Pwra = [nop rep stp];	
Pswra = [smp nop rep stp];



spmver = spm('Ver');
if (strcmp(spmver,'SPM8')==1)
	spm_jobman('initcfg');
	spm_get_defaults('cmdline',true);
    if (exist('spmdefaults','var'))
        mc_SetSPMDefaults(spmdefaults);
    end
end

spm('defaults','fmri');
global defaults
global vbm8
warning off all

RunNamesTotal = RunDir;
if (~exist('NumScan','var'))
    NumScan = [];
end
NumScanTotal = NumScan;
	
Processing(1) = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Preprocessing Section
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (Processing(1) == 1)

	%suffix = ',1';
	suffix = '';

    st = defaults.slicetiming;
	st.scans = {};
	st.tr = TR;
	st.nslices = NumSlices;
	st.ta = (TR-(TR/NumSlices));
	st.so = SliceOrder;
    if (~exist('RefSlice','var') || isempty(RefSlice))
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
        vbm.estwrite.opts = vbm8.opts;
        %vbm.estwrite.extopts = vbm8.extopts;
        vbm.estwrite.output = rmfield(vbm8.output,'surf');
        vbm.estwrite.output.bias.native = 1;
        vbm.estwrite.output.bias.warped = 1;
        vbm.estwrite.output.GM.native = 1;
        vbm.estwrite.output.GM.modulated = 2;
        vbm.estwrite.output.WM.native = 1;
        vbm.estwrite.output.WM.modulated = 2;
        vbm.estwrite.output.CSF.native = 1;
        vbm.estwrite.output.CSF.modulated = 2;
        vbm.estwrite.output.label.native = 1;
        vbm.estwrite.output.label.warped = 1;
        vbm.estwrite.output.warps = [1 1];

        vbm.estwrite.extopts.dartelwarp.normhigh.darteltpm = vbm8.extopts.darteltpm;
        vbm.estwrite.extopts.sanlm = vbm8.extopts.sanlm;
        vbm.estwrite.extopts.mrf = vbm8.extopts.mrf;
        vbm.estwrite.extopts.cleanup = vbm8.extopts.cleanup;
        vbm.estwrite.extopts.print = vbm8.extopts.print;
        
        util.defs.comp{1}.def = {};
        util.defs.comp{2}.idbbvox.vox = VoxelSize;
        util.defs.comp{2}.idbbvox.bb = defaults.normalise.write.bb;
        util.defs.ofname = '';
        util.defs.fnames = {};
        util.defs.savedir.savesrc = 1;
        util.defs.interp = 1;
    else
        mc_Error('You are using an unsupported version of SPM.  This script is compatible with SPM8');
    end
    
    if (strcmp(NormMethod,'seg'))
        normalise.write = defaults.normalise.write;
        normalise.write.subj.matname = {};
        normalise.write.subj.resample = {};
        normalise.write.roptions.vox = VoxelSize;
        normalise.write.roptions.prefix = nop;
    else
        normalise.estwrite.eoptions = defaults.normalise.estimate;
        normalise.estwrite.roptions = defaults.normalise.write;
        normalise.estwrite.subj.source = {};
        normalise.estwrite.subj.wtsrc = {};
        normalise.estwrite.subj.resample = {};
        WarpImage = mc_GenPath(WarpTemplate);
        normalise.estwrite.eoptions.template = {[WarpImage suffix]};
        normalise.estwrite.roptions.vox = VoxelSize;
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
    
	for x = 1:size(SubjDir,1)
        
            SandboxFolders = {};
        SandboxFiles = {};
        
	    clear job
        Subject=SubjDir{x,1};
		RunList=SubjDir{x,3};

        mc_Logger('log',sprintf('Working on subject %s',Subject),3);

		NumRun = size(RunList,2);

		TotalNumRun = size(NumScanTotal,2);  %%% number of image runs if every run were present

		%%%%% This code cuts RunDir and NumScan based which Image Runs are present  
		NumScan=[];
		clear RunDir;
		for iRun=1:NumRun
		    RunDir{iRun,1}=RunNamesTotal{RunList(1,iRun)};
            if (~isempty(NumScanTotal))
                NumScan=horzcat(NumScan,NumScanTotal(1,RunList(1,iRun)));
            end
		end

		NumRun= size(RunList,2); % number of runs
    
        if (NumRun < TotalNumRun)
            mc_Logger('log',sprintf('Only analyzing %d runs out of %d total.',NumRun,TotalNumRun),3);
        end
        
        %%%Check if NumScan exists and is filled in.  If not, we need to build
        %%%NumScan based on number of frames in .nii file (or number of analyze
        %%%images)
        nsflag = 0;
        if (isempty(NumScan))
            nsflag = 1;
        end
        for iRun = 1:NumRun
            frames = 1;
            Run = RunDir{iRun};
            ImageDirCheck = struct('Template',ImageTemplate,'mode','check');
            ImageDir = mc_GenPath(ImageDirCheck);
            tmpP = [];
            if (strcmp(imagetype,'nii'))
                %%%load NIFTI image and check frames
                tmpP = spm_select('ExtFPList',ImageDir,['^' basefile '.*.' imagetype],[1:10000]);
            else
                tmpP = spm_select('ExtFPList',ImageDir,['^' basefile '.*.' imagetype],frames);
            end

            if (nsflag)
                NumScan(iRun) = size(tmpP,1);
            end

            if (size(tmpP,1) ~= NumScan(iRun))
                if (size(tmpP,1) < NumScan(iRun))
                    mc_Error(sprintf('Number of TRs requested (%d) for run %s of subject %s is greater than the number of TRs in the file.',NumScan(iRun),RunDir{iRun},Subject));
                end
                mc_Logger('log',sprintf('Number of TRs requested (%d) for run %s of subject %s does not match total number of frames in the file. Only %d TRs will be analyzed.',NumScan(iRun),RunDir{iRun},Subject,NumScan(iRun)),2);
                mcWarnings = mcWarnings + 1;
            end
        end
        
	    nj = 0;
	    switch (NormMethod) 
		case 'func'
            job{1}.spm.temporal.st = st;
            job{2}.spm.spatial.realign = realign;
            job{3}.spm.spatial.normalise = normalise;
            job{4}.spm.spatial.smooth = smooth;    
            
		    nj = 4;
		case 'anat'
            job{1}.spm.temporal.st = st;
            job{2}.spm.spatial.realign = realign;
            job{3}.spm.spatial.coreg = coreg;
            job{4}.spm.spatial.coreg = coreg;
            job{5}.spm.spatial.normalise = normalise;
            job{6}.spm.spatial.smooth = smooth;    

		    nj = 6;
		case 'seg'
            job{1}.spm.temporal.st = st;
            job{2}.spm.spatial.realign = realign;
            job{3}.spm.spatial.coreg = coreg;
            job{4}.spm.spatial.coreg = coreg;
            job{5}.spm.tools.vbm8 = vbm;
            job{6}.spm.util = util;
            job{7}.spm.util = util;
            job{8}.spm.spatial.smooth = smooth; 
            
		    nj = 8;
        end

	    clear scancell
	    ascan = {};
	    rscan = {};
	    wscan = {};
	    sscan = {};
	    scancell = {};
        imagecell = {};
        wimagefile = {};
        w2imagefile = {};
        wimagecell = {};
        w2imagecell = {};
        wmatfile = {};
        w2matfile = {};
        for r = 1:size(RunDir,1)
	    	frames = 1;
            if strcmp(imagetype,'nii')
	    		frames = 1:NumScan(r);
            end
            
            Run=RunDir{r};
            iRun=num2str(r);
            ImageDirCheck = struct('Template',ImageTemplate,'type',1,'mode','check');
            ImageDir=mc_GenPath(ImageDirCheck);
            scan{r} = spm_select('ExtList',ImageDir,['^' newbasefile '.*' imagetype],frames);
            imagefile{r} = spm_select('List',ImageDir,['^' newbasefile '.*\..*']);
            
            %%%%%%%%% Copy Images to Sandbox directory if necessary
            if (UseSandbox)
                SandboxFolders{end+1,1} = ImageDir;
                SandboxFolders{end,2} = fullfile(Sandbox,ImageDir);
                %SandboxFiles{end+1,1} = ImageDir;
                %SandboxFiles{end,2} = fullfile(Sandbox,ImageDir);
            end
        
            subjpath = fullfile(Sandbox,ImageDir);
            
            for s = 1:size(scan{r},1)
                scancell{end+1} = strtrim([subjpath scan{r}(s,:) suffix]);
                ascan{r}{s} = strtrim([subjpath scan{r}(s,:) suffix]);
                rscan{r}{s} = strtrim([subjpath Pa scan{r}(s,:) suffix]);
                wscan{end+1} = strtrim([subjpath Pra scan{r}(s,:) suffix]);
                sscan{end+1} = strtrim([subjpath Pwra scan{r}(s,:) suffix]);
            end
            for s = 1:size(imagefile{r},1)
                SandboxFiles{end+1,1} = fullfile(ImageDir, imagefile{r}(s,:));
                SandboxFiles{end,2} = fullfile(Sandbox,ImageDir,imagefile{r}(s,:));
                wimagefile{r}(s,:) = fullfile(subjpath,['w' Pra imagefile{r}(s,:)]);
                w2imagefile{r}(s,:) = fullfile(subjpath,[Pwra imagefile{r}(s,:)]);
                [p f e] = fileparts(imagefile{r}(s,:));
                wmatfile{r}(s,:) = fullfile(subjpath,['w' Pra f '.mat']);
                w2matfile{r}(s,:) = fullfile(subjpath,[Pwra f '.mat']);
                %imagecell{end+1} = strtrim([subjpath imagefile{r}(s,:)]);
                %wimagecell{end+1} = strtrim([subjpath 'w' Pra imagefile{r}(s,:)]);
                %w2imagecell{end+1} = strtrim([subjpath Pwra imagefile{r}(s,:)]);
            end
        end
        
        if (exist('RefImage','var') && ~isempty(RefImage))
            refimage = rscan{1}{RefImage};
        else
            refimage = rscan{1}{1};
        end
        
        rscan{1} = {refimage rscan{1}{:}};
        
%         temp = cell2mat(scan');
%         temp2 = mat2cell(temp,ones(1,size(temp,1)),size(temp,2));
%         [p f e] = cellfun(@fileparts,temp2,'UniformOutput',false);
%         rf = strrep(f,basefile,[Pa basefile]);
%         wf = strrep(f,basefile,[Pra basefile]);
%         sf = strrep(f,basefile,[Pwra basefile]);
%         rtemp = strtrim(fullfile(p,mat2cell([cell2mat(rf) cell2mat(e)],ones(1,size(rf,1)),size(rf{1},2)+size(e{1},2))));
%         wtemp = strtrim(fullfile(p,mat2cell([cell2mat(wf) cell2mat(e)],ones(1,size(wf,1)),size(wf{1},2)+size(e{1},2))));
%         stemp = strtrim(fullfile(p,mat2cell([cell2mat(sf) cell2mat(e)],ones(1,size(sf,1)),size(sf{1},2)+size(e{1},2))));
        
	    for r = 1:size(RunDir,1)
            ascan{r} = ascan{r}';
            rscan{r} = rscan{r}';
	    end

	    wscan = wscan';
	    sscan = sscan';
        NewOverlayTemplate = '';
        NewHiResTemplate = '';
        if (docoregoverlay && ~strcmp(NormMethod,'func'))
            %copy overlay file to new location
            [p f e] = fileparts(OverlayTemplate);
            NewOverlayTemplate = fullfile(AnatTemplate,[CoregOverlayPrefix f e]);
            mc_Copy(OverlayTemplate,NewOverlayTemplate);
            if (UseSandbox)
                NewOverlayTemplate = fullfile(Sandbox,NewOverlayTemplate);
            end
        end
        if (docoreghires && ~strcmp(NormMethod,'func'))
            %copy hires file to new location
            [p f e] = fileparts(HiResTemplate);
            NewHiResTemplate = fullfile(AnatTemplate,[CoregHiResPrefix f e]);
            mc_Copy(HiResTemplate,NewHiResTemplate);
            if (UseSandbox)
                NewHiResTemplate = fullfile(Sandbox,NewHiResTemplate);
            end
        end
        
        if ((docoregoverlay || docoreghires) && ~strcmp(NormMethod,'func'))
            SandboxFiles{end+1,1} = mc_GenPath(AnatTemplate);
            SandboxFiles{end,2} = mc_GenPath(fullfile(Sandbox,AnatTemplate));
            SandboxFolders{end+1,1} = mc_GenPath(AnatTemplate);
            SandboxFolders{end,2} = mc_GenPath(fullfile(Sandbox,AnatTemplate));
        end
                
        if (UseSandbox)
            mc_Logger('log','Copying files to sandbox',3);
            for iS = 1:size(SandboxFiles,1)
                %copy 1st element to 2nd
                mc_Copy(SandboxFiles{iS,1},SandboxFiles{iS,2});
            end
        end
        
        Run = RunDir{1};
	    switch (NormMethod)
		case 'func'
            job{1}.spm.temporal.st.scans = ascan;
            job{2}.spm.spatial.realign.estwrite.data = rscan;
            [p f e] = fileparts(rscan{1}{1});
            normsource = fullfile(p,['mean' f e]);
            
            job{3}.spm.spatial.normalise.estwrite.subj.source = {normsource};
            job{3}.spm.spatial.normalise.estwrite.subj.resample = wscan;
            job{3}.spm.spatial.normalise.estwrite.subj.resample{end+1} = normsource;
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
            %jobs{x} = job;
  		
		case 'anat'
            job{1}.spm.temporal.st.scans = ascan;
            job{2}.spm.spatial.realign.estwrite.data = rscan;

            [p f e] = fileparts(rscan{1}{1});
            if (strcmp(f(1),'r') & AlreadyDone(2))
                f = f(2:end);
            end
            normsource = fullfile(p,['mean' f e]);

            if (docoregoverlay)
                OverlayDirCheck = struct('Template',NewOverlayTemplate,'mode','check');
                OverlayDir=mc_GenPath(OverlayDirCheck);
            end

            HiResDirCheck = struct('Template',NewHiResTemplate,'mode','check');
            HiResDir=mc_GenPath(HiResDirCheck);

            job{3}.spm.spatial.coreg.estimate.ref = {normsource};
            job{3}.spm.spatial.coreg.estimate.source = {OverlayDir};
            
            if (docoreghires && docoregoverlay)
                job{4}.spm.spatial.coreg.estimate.ref = {OverlayDir};
                job{4}.spm.spatial.coreg.estimate.source = {HiResDir};
            elseif (docoreghires && ~docoregoverlay)
                job{4}.spm.spatial.coreg.estimate.ref = {normsource};
                job{4}.spm.spatial.coreg.estimate.source = {HiResDir};
            end
            
            job{5}.spm.spatial.normalise.estwrite.subj.source = {HiResDir};
            job{5}.spm.spatial.normalise.estwrite.subj.resample = wscan;
            job{5}.spm.spatial.normalise.estwrite.subj.resample{end+1} = HiResDir;

            job{6}.spm.spatial.smooth.data = sscan;
            if (~doslicetiming)
            job{1} = [];
            end
            if (~dorealign)
            job{2} = [];
            end
            if (~docoregoverlay)
            job{3} = [];
            end
            if(~docoreghires)
            job{4} = [];
            end
            if (~donormalize)
            job{5} = [];
            end
            if (~dosmooth)
            job{6} = [];
            end
            job(cellfun(@isempty,job)) = [];
            %jobs{x} = job;

		case 'seg'
            job{1}.spm.temporal.st.scans = ascan;
            job{2}.spm.spatial.realign.estwrite.data = rscan;

            [p f e] = fileparts(rscan{1}{1});
            if (strcmp(f(1),'r') && AlreadyDone(2))
                f = f(2:end);
            end
            normsource = fullfile(p,['mean' f e]);

            OverlayDir = '';
            if (docoregoverlay)
                OverlayDirCheck = struct('Template',NewOverlayTemplate,'mode','check');
                OverlayDir=mc_GenPath(OverlayDirCheck);
            end
            
            HiResDirCheck = struct('Template',NewHiResTemplate,'mode','check');
            HiResDir=mc_GenPath(HiResDirCheck);

            job{3}.spm.spatial.coreg.estimate.ref = {normsource};
            job{3}.spm.spatial.coreg.estimate.source = {OverlayDir};
            
            if (docoreghires && docoregoverlay)
                job{4}.spm.spatial.coreg.estimate.ref = {OverlayDir};
                job{4}.spm.spatial.coreg.estimate.source = {HiResDir};
            elseif (docoreghires && ~docoregoverlay)
                job{4}.spm.spatial.coreg.estimate.ref = {normsource};
                job{4}.spm.spatial.coreg.estimate.source = {HiResDir};
            end           

            job{5}.spm.tools.vbm8.estwrite.data = {HiResDir};

            [HiResPath HiResName]=fileparts(HiResDir);

            job{6}.spm.util.defs.comp{1}.def = {fullfile(HiResPath,['y_r' HiResName '.nii'])}; 
            job{6}.spm.util.defs.fnames = wscan;
            
            job{7}.spm.util.defs.comp{1}.def = {fullfile(HiResPath,['y_r' HiResName '.nii'])};
            
            %V = spm_vol(HiResDir);
            %vox = spm_imatrix(V.mat);
            %vox = vox(7:9);
            %vox = abs(vox);
            %job{7}.spm.util.defs.comp{2}.idbbvox.vox = vox;
            job{7}.spm.util.defs.fnames = {HiResDir};

            job{8}.spm.spatial.smooth.data = sscan;
            if (~doslicetiming)
                job{1} = [];
            end
            if (~dorealign)
                job{2} = [];
            end
            if (~docoregoverlay)
                job{3} = [];
            end
            if (~docoreghires)
                job{4} = [];
            end
            if (~donormalize)
                job{5} = [];
                job{6} = [];
                job{7} = [];
            end
            if (~dosmooth)
                job{8} = [];
            end
            job(cellfun(@isempty,job)) = [];
            %jobs{x} = job;

        end

        if (dosmooth)
            job2{1} = job{end};
            job{end} = [];
        end
        job(cellfun(@isempty,job)) = [];
        %spm_jobman('run',job);
        if (strcmp(NormMethod,'seg'))
            %rename normalized images
%             for iS = 1:size(imagecell,2)
%                 [p f e] = fileparts(wimagecell{iS});
%                 wimagecell{end+1} = fullfile(p,[f '.mat']);
%                 [p f e] = fileparts(w2imagecell{iS});
%                 w2imagecell{end+1} = fullfile(p,[f '.mat']);
%             end
% can use matlabbatch jobs to move files, but it would need
% to be done on a per-run basis because the job only allows a
% single destination folder.
            for iRun = 1:size(wimagefile,2)
                temp = vertcat(wimagefile{iRun},wmatfile{iRun});
                temp2 = mat2cell(temp,ones(1,size(temp,1)),size(temp,2));
                cfg_basicio.file_move.files = temp2;
                [p f e] = fileparts(temp2{1});
                cfg_basicio.file_move.action.moveren.moveto = {p};
                cfg_basicio.file_move.action.moveren.patrep.pattern = '^w';
                cfg_basicio.file_move.action.moveren.patrep.repl = nop;
                cfg_basicio.file_move.action.moveren.unique = 0;
                job{end+1}.cfg_basicio = cfg_basicio;
            end
%             result = cellfun(@mc_Move,wimagecell,w2imagecell);
        end

        if (dosmooth)
            job{end+1} = job2{1};
        end
        mc_Logger('log','Running preprocessing job',3);
        spm_jobman('run',job);
        %spm_jobman('run',job2);
        
        %need to strip off the 1st line of the first run's realignment
        %parameters because of refimage being included.
        [p f e] = fileparts(rscan{1}{1});
        ImageDirCheck = struct('Template',ImageTemplate,'mode','check');
        ImageDir = mc_GenPath(ImageDirCheck);
        r1rd = load(fullfile(Sandbox,ImageDir,['rp_' f '.txt']));
        r1rd = r1rd(2:end,:);
        save(fullfile(Sandbox,ImageDir,['rp_' f '.txt']),'r1rd','-ascii');
        
        if (UseSandbox)
            mc_Logger('log','Copying files from sandbox to original location',3);
            for iS = 1:size(SandboxFolders,1)
                %copy 2nd element to 1st
                %mc_Copy(SandboxFiles{iS,2},SandboxFiles{iS,1});
                files = dir(SandboxFolders{iS,2});
                for iFile = 1:size(files,1)
                    if (~strcmp(files(iFile).name,'.') && ~ strcmp(files(iFile).name,'..'))
                        if (~strncmp(files(iFile).name,basefile,length(basefile))) %don't copy  original basefile back
                            mc_Copy(fullfile(SandboxFolders{iS,2},files(iFile).name),SandboxFolders{iS,1});
                        end
                    end
                end
            end
        end
        mc_Logger('log',sprintf('Done with subject %s',Subject),3);
    end

    if (UseSandbox)
        [status, ans, ans] = rmdir(Sandbox, 's');
        if (status ~= 0)
            mc_Logger('log','Unable to remove sandbox directory',2);
        end
    end
end