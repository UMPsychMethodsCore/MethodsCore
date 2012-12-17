%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% General calculations that apply to both Preprocessing and First Level
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

global mcLog;
tempLog = mcLog;

if (~exist('ROIOutput','var'))
    ROIOutput = 'maps';
end
if (~exist('Mode','var'))
    Mode = 'full';
end

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


RunMode = [0 0];
if (strcmpi(Mode,'full'))
    RunMode = [1 1];
else
    RunMode(1) = strcmpi(Mode,'parameters');
    RunMode(2) = strcmpi(Mode,'cppi');
end

spm('defaults','fmri');
global defaults
warning off all

spmver = spm('Ver');
if (strcmp(spmver,'SPM8')==1)
    spm_jobman('initcfg');
    spm_get_defaults('cmdline',true);
end

if (RunMode(1) | sum(RunMode) == 0)
    RunNamesTotal = RunDir;
    NumScanTotal = NumScan;

    MaskBrain = 1;

    RegressGlobal = any(strfind(upper(RegressOrder),'G'));
    RegressWhite = any(strfind(upper(RegressOrder),'W'));
    RegressCSF = any(strfind(upper(RegressOrder),'C'));
    DoBandpassFilter = any(strfind(upper(RegressOrder),'B'));
    RegressMotion = any(strfind(upper(RegressOrder),'M'));
    DoLinearDetrend = any(strfind(upper(RegressOrder),'D'));

    for iSubject = 1:size(SubjDir,1)
        clear parameters;
        clear global SOM;
        
        parameters.RegressFLAGS.prinComp = PrincipalComponents;
        parameters.RegressFLAGS.global = RegressGlobal;
        parameters.RegressFLAGS.csf = RegressCSF;
        parameters.RegressFLAGS.white = RegressWhite;
        parameters.RegressFLAGS.motion = RegressMotion;
        parameters.RegressFLAGS.order = RegressOrder;  
    
        Subject=SubjDir{iSubject,1};
        RunList=SubjDir{iSubject,3};

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

        GreyPath = mc_GenPath(GreyMatterTemplate);
        WhitePath = mc_GenPath(WhiteMatterTemplate);
        CSFPath = mc_GenPath(CSFTemplate);
        BrainPath = mc_GenPath(BrainMaskTemplate);

        parameters.grey.File = GreyPath;
        parameters.grey.ImgThreshold = GreyThreshold;
        parameters.masks.white.File = WhitePath;
        parameters.masks.csf.File = CSFPath;
        parameters.masks.epi.File = BrainPath;
        parameters.rois.mask.MaskFLAG = MaskBrain;

        for iRun = 1:NumRun
            Run = RunDir{iRun};

            ImagePath = mc_GenPath(ImageTemplate);
            ImageFiles = spm_select('FPList',ImagePath, ['^' basefile '.*.' imagetype]);
            RealignmentParametersFile = mc_GenPath(RealignmentParametersTemplate);

            parameters.data.run(iRun).P = ImageFiles;
            if (SubjDir{iSubject,4}(1) ~= 0)
                parameters.data.run(iRun).nTIME = SubjDir{iSubject,4}(iRun);
            else
                parameters.data.run(iRun).nTIME = NumScan(iRun);
            end
            RealignmentParameters = load(RealignmentParametersFile);
            RealignmentParametersDeriv = diff(RealignmentParameters);
            %RealignmentParametersDerivR = resample(RealignmentParametersDeriv,size(RealignmentParameters,1),size(RealignmentParametersDeriv,1));

            %parameters.data.run(iRun).MotionParameters = [RealignmentParameters RealignmentParametersDerivR];
            parameters.data.run(iRun).MotionParameters = RealignmentParameters(1:parameters.data.run(iRun).nTIME,:);

            parameters.data.MaskFLAG = MaskBrain;

            parameters.TIME.run(iRun).TR = TR;
            parameters.TIME.run(iRun).BandFLAG = DoBandpassFilter;
            parameters.TIME.run(iRun).TrendFLAG = DoLinearDetrend;
            parameters.TIME.run(iRun).LowF = LowFrequency;
            parameters.TIME.run(iRun).HiF = HighFrequency;
            parameters.TIME.run(iRun).gentle = Gentle;
            parameters.TIME.run(iRun).padding = Padding;
            parameters.TIME.run(iRun).whichFilter = BandpassFilter;
            parameters.TIME.run(iRun).fraction = Fraction;
        end

        Run = RunDir{1};
        ImagePath = mc_GenPath(ImageTemplate);
        SOM_Mask = mc_GenPath(fullfile(ImagePath,'som_mask.img'));

        if (isempty(BrainMaskTemplate))
            parameters.rois.mask.File = SOM_Mask;
        else
            parameters.rois.mask.File = BrainPath;
        end
        output.Template = OutputTemplate;
        output.type = 1;
        output.mode = 'makedir';
        if (RunMode(1))
            OutputPath = mc_GenPath(output);
        else
            OutputPath = mc_GenPath(OutputTemplate);
        end
        
        switch (ROIInput)
            case 'files'
                ROIFolder = mc_GenPath(ROITemplate);
                for iROIs = 1:size(ROIImages,1)
                    ROI{iROIs} = fullfile(ROIFolder,ROIImages{iROIs});
                end
                parameters.rois.files = char(ROI);
            case 'directory'
                ROIFolder = mc_GenPath(ROITemplate);
                parameters.rois.files = spm_select('FPList',ROIFolder,'.*\.img|.*\.nii');
            
            case 'coordinates'
                parameters.rois.mni.coordinates = ROICenters;
                if (iscell(ROISize))
                    parameters.rois.mni.size = ROISize{1};
                else
                    XYZ = SOM_MakeSphereROI(ROISize);
                    parameters.rois.mni.size.XROI = XYZ(1,:);
                    parameters.rois.mni.size.YROI = XYZ(2,:);
                    parameters.rois.mni.size.ZROI = XYZ(3,:);
                end
            case 'grid'
                ROIGridMask = mc_GenPath(ROIGridMaskTemplate);
                ROIGridMaskHdr = spm_vol(ROIGridMask);
                ROIGridBB = mc_GetBoundingBox(ROIGridMaskHdr);
                grid_coord_cand = SOM_MakeGrid(ROIGridSpacing,ROIGridBB);
                inOutIDX = SOM_roiPointsInMask(ROIGridMask,grid_coord_cand);
                grid_coord = grid_coord_cand(inOutIDX,:);
                parameters.rois.mni.coordinates = grid_coord;
                if (iscell(ROIGridSize))
                    parameters.rois.mni.size = ROIGridSize{1};
                else
                    XYZ = SOM_MakeSphereROI(ROIGridSize);
                    parameters.rois.mni.size.XROI = XYZ(1,:);
                    parameters.rois.mni.size.YROI = XYZ(2,:);
                    parameters.rois.mni.size.ZROI = XYZ(2,:);
                end
        end

        parameters.Output.correlation = ROIOutput;
        %parameters.Output.description = 'description of output';
        parameters.Output.directory = OutputPath;
        parameters.Output.name = OutputName;
        
        parameters.cppi.SPM = mc_GenPath(fullfile(SPMTemplate,'SPM.mat'));
        parameters.cppi.UseSandbox = UseSandbox;
        parameters.cppi.NumScan = NumScan;
        if (~exist('StandardizeBetas','var') | isempty(StandardizeBetas))
            StandardizeBetas = 1;
        end
        parameters.cppi.StandardizeBetas = StandardizeBetas;
        
        if (UseSandbox)
            [status hostname] = system('hostname -s');
            parameters.cppi.sandbox = fullfile([filesep hostname(1:end-1)],'sandbox','cppi',parameters.Output.directory);
        else
            parameters.cppi.sandbox = fullfile(parameters.Output.directory,'temp');
        end
        parameters.cppi.domotion = IncludeMotion;
        
        ParameterFilename = [OutputName '_parameters'];
        ParameterPath = mc_GenPath(fullfile(OutputPath,ParameterFilename));
        save(ParameterPath,'parameters');
        
    end
end

if (RunMode(2))
    %partition SubjDir into parameters.cppi.NumProcesses equal parts
    NumSubj = size(SubjDir,1);
    if (NumProcesses > 12)
        NumProcesses = 12;
    end
    SubjPerChunk = floor(NumSubj / NumProcesses);
    SubjRemain = mod(NumSubj,NumProcesses);
    
    for iChunk = 1:NumProcesses
        %save each piece of SubjDir into a chunkN.mat file in temp location
        offset = (iChunk - 1) * SubjPerChunk;
        tempSubjDir = [];
%        if (iChunk < NumProcesses)
            for iSubject = 1+offset:SubjPerChunk+offset
                tempSubjDir{end+1,1} = SubjDir{iSubject,1};
                tempSubjDir{end,2} = SubjDir{iSubject,2};
                tempSubjDir{end,3} = SubjDir{iSubject,3};
                tempSubjDir{end,4} = SubjDir{iSubject,4};
            end
%         else
%             for iSubject = 1+offset:size(SubjDir,1)
%                 tempSubjDir{end+1,1} = SubjDir{iSubject,1};
%                 tempSubjDir{end,2} = SubjDir{iSubject,2};
%                 tempSubjDir{end,3} = SubjDir{iSubject,3};
%                 tempSubjDir{end,4} = SubjDir{iSubject,4};
%             end
%        end
        if (SubjRemain > 0)
            iSubject = NumSubj+1-SubjRemain;
            tempSubjDir{end+1,1} = SubjDir{iSubject,1};
            tempSubjDir{end,2} = SubjDir{iSubject,2};
            tempSubjDir{end,3} = SubjDir{iSubject,3};
            tempSubjDir{end,4} = SubjDir{iSubject,4};
            SubjRemain = SubjRemain - 1;
        end
            
        [fd fn fe] = fileparts(mcLog);
        mcLog = fullfile(fd,[fn '_chunk' num2str(iChunk) fe]);
        chunkFile = fullfile(mc_GenPath(Exp),['chunk_' num2str(iChunk) '.mat']);
        save(chunkFile,'tempSubjDir','OutputTemplate','Exp','OutputName','ParameterFilename','NumScan','mcLog');
        mcLog = tempLog;
    end
        %send a system call to start matlab, load a chunk file, and call
        %cppi_batch_chunk with the loaded variables
        
        %spawn NumProcesses-1 other matlab processes
        for iChunk = 1:NumProcesses-1
            chunkFile = fullfile(mc_GenPath(Exp),['chunk_' num2str(iChunk) '.mat']);
            systemcall = sprintf('matlab -nosplash -nodesktop -r "addpath(fullfile(''%s'',''matlabScripts''));,addpath(fullfile(''%s'',''cPPI''));,addpath(fullfile(''%s'',''som''));,addpath(fullfile(''%s'',''SPM/SPM8/spm8_with_R4667''));,cppi_batch_chunk(''%s'');,quit;" &',mcRoot,mcRoot,mcRoot,mcRoot,chunkFile);
            [status result] = system(systemcall);
        end
        %now the last one in this matlab.  This one will always be equal to
        %or greater in number of subjects to the previous ones.
        iChunk = NumProcesses;
        chunkFile = fullfile(mc_GenPath(Exp),['chunk_' num2str(iChunk) '.mat']);
        cppi_batch_chunk(chunkFile);
    
    
    
end




