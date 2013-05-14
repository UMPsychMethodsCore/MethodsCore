%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% General calculations that apply to both Preprocessing and First Level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    spm_get_defaults('cmdline',true);
end

if ~isempty(GreyFile)
    GreyMatterTemplate  = [AnatomyMaskPath '/' GreyFile]
end

if ~isempty(WhiteFile)
    WhiteMatterTemplate = [AnatomyMaskPath '/' WhiteFile];
end

if ~isempty(CSFFile)
    CSFTemplate         = [AnatomyMaskPath '/' CSFFile];
end

if (RunMode(1) | sum(RunMode) == 0)
    RunNamesTotal = RunDir;
    NumScanTotal  = NumScan;
    
    MaskBrain = 1;
    
    RegressGlobal    = any(strfind(upper(RegressOrder),'G'));
    RegressWhite     = any(strfind(upper(RegressOrder),'W'));
    RegressCSF       = any(strfind(upper(RegressOrder),'C'));
    DoBandpassFilter = any(strfind(upper(RegressOrder),'B'));
    RegressMotion    = any(strfind(upper(RegressOrder),'M'));
    DoLinearDetrend  = any(strfind(upper(RegressOrder),'D'));
    
    for iSubject = 1:size(SubjDir,1)
        clear parameters;
        clear global SOM;
        
        parameters.RegressFLAGS.prinComp = PrincipalComponents;
        parameters.RegressFLAGS.global   = RegressGlobal;
        parameters.RegressFLAGS.csf      = RegressCSF;
        parameters.RegressFLAGS.white    = RegressWhite;
        parameters.RegressFLAGS.motion   = RegressMotion;
        parameters.RegressFLAGS.order    = RegressOrder;
        
        Subject=SubjDir{iSubject,1};
	
	% This suggests that SubjDir{:,2} is useless information.
	
        RunList=SubjDir{iSubject,3};
        
        SOM_LOG(sprintf('STATUS : Working on Subject : %s',Subject));
        NumRun = size(RunList,2);
        
        TotalNumRun = size(NumScanTotal,2);  %%% number of image runs if every run were present
        
        %%%%% This code cuts RunDir and NumScan based which Image Runs are present
        NumScan=[];
        clear RunDir;
        for iRun=1:NumRun
            RunDir{iRun,1} = RunNamesTotal{RunList(1,iRun)};
            NumScan        = horzcat(NumScan,NumScanTotal(1,RunList(1,iRun)));
        end
        
        NumRun= size(NumScan,2); % number of runs
        ImageNumRun=size(RunDir,1); %number of image folders
        
        if ~isempty(GreyFile)
            GreyPath  = mc_GenPath(GreyMatterTemplate);
        end
        if ~isempty(WhiteFile)
            WhitePath = mc_GenPath(WhiteMatterTemplate);
        end
        if ~isempty(CSFFile)
            CSFPath   = mc_GenPath(CSFTemplate);
        end
        BrainPath = mc_GenPath(BrainMaskTemplate);
        
        if ~isempty(GreyFile)
            parameters.masks.grey.File          = GreyPath;
            parameters.masks.grey.ImgThreshold  = GreyThreshold;
        end
        
        if ~isempty(WhiteFile)
            parameters.masks.white.File   = WhitePath;
        end
        if ~isempty(CSFFile)
            parameters.masks.csf.File     = CSFPath;
        end
        parameters.masks.epi.File     = BrainPath;
        parameters.rois.mask.MaskFLAG = MaskBrain;
        
        for iRun = 1:ImageNumRun
            Run = RunDir{iRun};
            
            ImagePath   = mc_GenPath(ImageTemplate);
            ImageFiles  = spm_select('FPList',ImagePath, ['^' connectFile '.*.' imagetype]);
            parameters.data.run(iRun).P     = ImageFiles;
            if isempty(ImageFiles)
                SOM_LOG(sprintf('FATAL ERROR : P spm_select returned nothing for %s/^%s.*.%s',ImagePath,connectFile,imagetype));
                return
            end
            if ~isempty(confoundFile)
                cImageFiles = spm_select('FPList',ImagePath, ['^' confoundFile '.*.' imagetype]);
                if isempty(cImageFiles)
                    SOM_LOG(sprintf('FATAL ERROR : cP spm_select returned nothing for %s/^%s.*.%s',ImagePath,confoundFile,imagetype));
                    return
                end
                parameters.data.run(iRun).cP  = cImageFiles;
            end
            
            RealignmentParametersFile = mc_GenPath(RealignmentParametersTemplate);
            
            parameters.data.run(iRun).P = ImageFiles;
            
            RealignmentParameters       = load(RealignmentParametersFile);
            RealignmentParametersDeriv  = diff(RealignmentParameters);
            RealignmentParametersDerivR = resample(RealignmentParametersDeriv,size(RealignmentParameters,1),size(RealignmentParametersDeriv,1));
            
            parameters.data.run(iRun).MotionParameters = [RealignmentParameters RealignmentParametersDerivR];
            parameters.data.run(iRun).nTIME            = NumScan(iRun);
            
            %%%added code to handle censorVectors
            %
            % ROBERT DOES NOT RECOMMEND THE CURRENT IMPLEMENTATION OF CENSORING.
            % USE AT YOUR OWN STATISTICAL RISK
            %
            if (exist('CensorTemplate','var') && ~isempty(CensorTemplate))
                CensorFile = mc_GenPath(struct('Template',CensorTemplate,'mode','check'));
                [p f e] = fileparts(CensorFile);
                if (strcmp(e,'.mat'))
                    %read variable and use cv element
                    tempcv = load(CensorFile);
                    cv = tempcv.cv;
                else %assume text file
                    cv = load(CensorFile);
                end
                if (size(cv,1) ~= NumScan(iRun))
                    SOM_LOG(sprintf('Your censor vector is %g elements, but you have %g scans in run %g of %s',size(cv,1),NumScan(iRun),iRun,SubjDir(iSubject)));
                end
                parameters.data.run(iRun).censorVector = ~cv;
            end
            %%%
            
            parameters.data.MaskFLAG = MaskBrain;
            
            parameters.TIME.run(iRun).TR            = TR;
            parameters.TIME.run(iRun).BandFLAG      = DoBandpassFilter;
            parameters.TIME.run(iRun).TrendFLAG     = DoLinearDetrend;
            parameters.TIME.run(iRun).LowF          = LowFrequency;
            parameters.TIME.run(iRun).HiF           = HighFrequency;
            parameters.TIME.run(iRun).gentle        = Gentle;
            parameters.TIME.run(iRun).padding       = Padding;
            parameters.TIME.run(iRun).whichFilter   = BandpassFilter;
            parameters.TIME.run(iRun).fraction      = Fraction;
        end
        
        Run = RunDir{1};
        ImagePath = mc_GenPath(ImageTemplate);
        SOM_Mask  = mc_GenPath(fullfile(ImagePath,'som_mask.img'));
        
        if (isempty(BrainMaskTemplate))
            parameters.rois.mask.File = SOM_Mask;
        else
            parameters.rois.mask.File = BrainPath;
        end
        output.Template = OutputTemplate;
        output.type     = 1;
        output.mode     = 'makedir';
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
            case 'coordload'
                tmpArray = load(mc_GenPath(ROIFile));
                if isstruct(tmpArray)
                    tmpArrayFields = fieldnames(tmpArray);
                    %
                    % Now we only expect one field, else throw an error
                    %
                    if length(tmpArrayField) ~= 1
                        SOM_LOG(sprintf('FATAL ERROR : Ambiguous ROI information in file %s',mc_GenPath(ROIFile)));
                        return
                    end
                    try
                        parameters.rois.mni.coordinates = getfield(tmpArray,tmpArrayFields{1});
                    catch
                        SOM_LOG(sprintf('FATAL ERROR : Ambiguous ROI information in file %s',mc_GenPath(ROIFile)));
			return
                    end
                    if (iscell(ROISize))
                        parameters.rois.mni.size = ROISize{1};
                    else
                        XYZ = SOM_MakeSphereROI(ROISize);
                        parameters.rois.mni.size.XROI = XYZ(1,:);
                        parameters.rois.mni.size.YROI = XYZ(2,:);
                        parameters.rois.mni.size.ZROI = XYZ(3,:);
                    end
                end
            case 'grid'
                ROIGridMask     = mc_GenPath(ROIGridMaskTemplate);
                ROIGridMaskHdr  = spm_vol(ROIGridMask);
                ROIGridBB       = mc_GetBoundingBox(ROIGridMaskHdr);
                grid_coord_cand = SOM_MakeGrid(ROIGridSpacing,ROIGridBB);
                inOutIDX        = SOM_roiPointsInMask(ROIGridMask,grid_coord_cand);
                grid_coord      = grid_coord_cand(inOutIDX,:);
                parameters.rois.mni.coordinates = grid_coord;
                if (iscell(ROIGridSize))
                    parameters.rois.mni.size = ROIGridSize{1};
                else
                    XYZ = SOM_MakeSphereROI(ROIGridSize);
                    parameters.rois.mni.size.XROI = XYZ(1,:);
                    parameters.rois.mni.size.YROI = XYZ(2,:);
                    parameters.rois.mni.size.ZROI = XYZ(2,:);
                end
            case 'gridplus'
                ROIGridMask     = mc_GenPath(ROIGridMaskTemplate);
                ROIGridMaskHdr  = spm_vol(ROIGridMask);
                ROIGridBB       = mc_GetBoundingBox(ROIGridMaskHdr);
                grid_coord_cand = SOM_MakeGrid(ROIGridSpacing,ROIGridBB);
                inOutIDX        = SOM_roiPointsInMask(ROIGridMask,grid_coord_cand);
                grid_coord      = grid_coord_cand(inOutIDX,:);
                
                grid_coord      = [grid_coord; ROIGridCenters];
                
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
        
        parameters.Output.correlation  = OutputType;
        parameters.Output.power        = OutputPower;
        parameters.Output.saveroiTC    = saveroiTC;
        parameters.Output.directory    = OutputPath;
        parameters.Output.name         = OutputName;
        ParameterFilename              = [OutputName '_parameters'];
        ParameterPath                  = mc_GenPath(fullfile(OutputPath,ParameterFilename));
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
            SOM_LOG('FATAL ERROR : There is something wrong with your template or your data.\nNo data was returned from SOM_PreProcessData\n');
	    return
        else
            results = SOM_CalculateCorrelations(D0,parameters);
            if isnumeric(results)
                SOM_LOG('FATAL ERROR : ');
                SOM_LOG('FATAL ERROR : There is something wrong with your template or your data.\nNo results were returned from SOM_CalculateCorrelations\n');
		return
            else
                for iR = 1:size(results,1)
                    SOM_LOG(results(iR,:))
                end
                SOM_LOG(sprintf('STATUS : Calculation done for Subject : %s',Subject));
            end
        end
    end
end




