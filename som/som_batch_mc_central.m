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


RunMode = [0 0];
if (strcmpi(Mode,'full'))
    RunMode = [1 1];
else
    RunMode(1) = strcmpi(Mode,'parameters');
    RunMode(2) = strcmpi(Mode,'som');
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

        for iRun = 1:ImageNumRun
            Run = RunDir{iRun};

            ImagePath = mc_GenPath(ImageTemplate);
            ImageFiles = spm_select('FPList',ImagePath, ['^' basefile '.*.' imagetype]);
            RealignmentParametersFile = mc_GenPath(RealignmentParametersTemplate);

            parameters.data.run(iRun).P = ImageFiles;

            RealignmentParameters = load(RealignmentParametersFile);
            RealignmentParametersDeriv = diff(RealignmentParameters);
            RealignmentParametersDerivR = resample(RealignmentParametersDeriv,size(RealignmentParameters,1),size(RealignmentParametersDeriv,1));

            parameters.data.run(iRun).MotionParameters = [RealignmentParameters RealignmentParametersDerivR];
            parameters.data.run(iRun).nTIME = NumScan(iRun);
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
                ROIGridMask = mc_Genpath(ROIGridMaskTemplate);
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
        ParameterFilename = [OutputName '_parameters'];
        ParameterPath = mc_GenPath(fullfile(OutputPath,ParameterFilename));
        save(ParameterPath,'parameters');
        
    end
end

if (RunMode(2))
    for iSubject = 1:size(SubjDir,1)
        clear D0 parameters results;
        Subject=SubjDir{iSubject,1};
        %load existing parameter file
        OutputPath = mc_GenPath(OutputTemplate);
        load(fullfile(OutputPath,ParameterFilename));
        clear global SOM;
        global SOM;
        SOM.silent = 1;
        SOM_LOG('STATUS : 01');

        [D0 parameters] = SOM_PreProcessData(parameters);
        if D0 == -1
            SOM_LOG('FATAL ERROR : No data returned');
            mc_Error('There is something wrong with your template or your data.\nNo data was returned from SOM_PreProcessData\n');
        else
            results = SOM_CalculateCorrelations(D0,parameters);
            if isnumeric(results)
                SOM_LOG('FATAL ERROR : ');
                mc_Error('There is something wrong with your template or your data.\nNo results were returned from SOM_CalculateCorrelations\n');
            end
        end        
    end
end




