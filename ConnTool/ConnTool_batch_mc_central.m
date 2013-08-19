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
global SOM

warning off all

SOM_SetDefaults

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
    
    %RegressGlobal    = any(strfind(upper(RegressOrder),'G'));
    %RegressWhite     = any(strfind(upper(RegressOrder),'W'));
    %RegressCSF       = any(strfind(upper(RegressOrder),'C'));
    %DoBandpassFilter = any(strfind(upper(RegressOrder),'B'));
    %RegressMotion    = any(strfind(upper(RegressOrder),'M'));
    %DoLinearDetrend  = any(strfind(upper(RegressOrder),'D'));
    
    for iSubject = 1:size(SubjDir,1)
        clear parameters;
        clear global SOM;
        
        parameters.RegressFLAGS.prinComp = PrincipalComponents;
        %parameters.RegressFLAGS.global   = RegressGlobal;
        %parameters.RegressFLAGS.csf      = RegressCSF;
        %parameters.RegressFLAGS.white    = RegressWhite;
        %parameters.RegressFLAGS.motion   = RegressMotion;
        parameters.RegressFLAGS.order    = RegressOrder;
        
        Subject=SubjDir{iSubject,1};
        
        % This SubjDir{:,2} previous was useless, so discard to remove confusion.
        
        RunList=SubjDir{iSubject,2};
        
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
            
            % Only get the motion parameters if the person asked for motion
            % regression.
            
            if ~isempty(strfind(parameters.RegressFLAGS.order,'M'))
                RealignmentParametersFile   = mc_GenPath(RealignmentParametersTemplate);
                RealignmentParameters       = load(RealignmentParametersFile);
                RealignmentParametersDeriv  = diff(RealignmentParameters);
                RealignmentParametersDerivR = resample(RealignmentParametersDeriv,size(RealignmentParameters,1),size(RealignmentParametersDeriv,1));
                
                parameters.data.run(iRun).MotionParameters = [RealignmentParameters RealignmentParametersDerivR];
            else
                parameters.data.run(iRun).MotionParameters = [];
            end
            
            % This neesd some logic, such that if NumScan is missing then
            % the code will assume all time points.
            
            try
                parameters.data.run(iRun).nTIME            = NumScan(iRun);
            catch
                parameters.data.run(iRun).nTIME            = 9999;
            end
            
            parameters.data.run(iRun).despikeVector    = [];
            parameters.data.run(iRun).censorVector     = [];
            
            %%%added code to handle DeSpike Vectors
            %
            %
            if (exist('DespikeParametersTemplate','var') && ~isempty(DespikeParametersTemplate))
                DeSpikeFile = mc_GenPath(struct('Template',DespikeParametersTemplate,'mode','check'));
                [p f e] = fileparts(DeSpikeFile);
                if (strcmp(e,'.mat'))
                    %read variable and use cv element
                    tempcv = load(DeSpikeFile);
                    cv = tempcv.cv;
                else %assume text file
                    cv = load(DeSpikeFile);
                end
                if (size(cv,1) ~= NumScan(iRun))
                    SOM_LOG(sprintf('STATUS : Your despiking vector is %g elements, but you have %g scans in run %g of %s',size(cv,1),NumScan(iRun),iRun,SubjDir(iSubject)));
                end
                parameters.data.run(iRun).despikeVector = cv;
                % Now the parameters for despiking
                
                DESPIKEOPTIONS = {'moving','lowess','loess','sgolay','rlowess','rloess'};
                SOM.defaults.DespikeNumberOption
                DespikeOption       = SOM.defaults.DespikeOption;
                DespikeNumberOption = SOM.defaults.DespikeNumberOption;
                if exist('DespikeReplacementOption','var') && ~isempty(DespikeReplacementOption)
                    for iOpt = 1:length(DESPIKEOPTIONS)
                        if strcmp(DESPIKEOPTIONS{iOpt}(1:3),DespikeReplacementOption(1:3))
                            DespikeOption = DESPIKEOPTIONS{iOpt};
                            DespikeNumberOption = DespikeReplacementOption(length(DESPIKEOPTIONS{iOpt})+1:end);
                            try
                                DespikeNumberOption = str2double(DespikeNumberOption);
                            catch
                                SOM_LOG(sprintf('WARNING : Despiking span is unreadable : %s. Using default',DespikeNumberOption))
                                DespikeNumberOption = SOM.defaults.DespikeNumberOption;
                            end
                        end
                    end
                else
                    SOM_LOG('WARNING : No "DespikeReplacementOption" specified, using default');
                end
                
                DESPIKEINTERP1 = {'nearest','linear','spline','pchip'};
                
                if exist('DespikeReplacementInterp','var') && ~isempty(DespikeReplacementInterp)
                    if isempty(cell2mat(DESPIKEINTERP1,DespikeReplacementInterp))
                        SOM_LOG('WARNING : No "DespikeReplacementInterp" specified, using default');
                        DespikeReplacementInterp = SOM.defaults.DespikeReplacementInterp;
                    end
                    
                    parameters.RegressFLAGS.despikeParameters.span         = DespikeNumberOption;
                    parameters.RegressFLAGS.despikeParameters.method       = DespikeOption;
                    parameters.RegressFLAGS.despikeParameters.interpMethod = DespikeReplacementInterp;
                    
                end
            end
            
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
                    SOM_LOG(sprintf('STATUS : Your censor vector is %g elements, but you have %g scans in run %g of %s',size(cv,1),NumScan(iRun),iRun,SubjDir(iSubject)));
                end
                parameters.data.run(iRun).censorVector = cv;
            end
            %%%
            
            parameters.data.MaskFLAG = MaskBrain;
            
            parameters.TIME.run(iRun).TR            = TR;
            %parameters.TIME.run(iRun).BandFLAG      = DoBandpassFilter;
            parameters.TIME.run(iRun).DetrendOrder  = DetrendOrder;
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
            case {'coordinates','coordload','grid','gridplus'}
                switch(ROIInput)
                    case 'coordinates'
                        grid_coord = ROICenters;
                    case 'coordload'
                        tmpArray = load(mc_GenPath(ROIFile));
                        if isstruct(tmpArray)
                            tmpArrayField = fieldnames(tmpArray);
                            %
                            % Now we only expect one field, else throw an error
                            %
                            if length(tmpArrayField) ~= 1
                                SOM_LOG(sprintf('FATAL ERROR : Ambiguous ROI information in file %s',mc_GenPath(ROIFile)));
                                return
                            end
                            try
                                grid_coord = getfield(tmpArray,tmpArrayFields{1});
                            catch
                                SOM_LOG(sprintf('FATAL ERROR : Ambiguous ROI information in file %s',mc_GenPath(ROIFile)));
                                return
                            end
                        end
                    case 'grid'
                        ROIGridMask     = mc_GenPath(ROIGridMaskTemplate);
                        ROIGridMaskHdr  = spm_vol(ROIGridMask);
                        ROIGridBB       = mc_GetBoundingBox(ROIGridMaskHdr);
                        grid_coord_cand = SOM_MakeGrid(ROIGridSpacing,ROIGridBB);
                        inOutIDX        = SOM_roiPointsInMask(ROIGridMask,grid_coord_cand);
                        grid_coord      = grid_coord_cand(inOutIDX,:);
                    case 'gridplus'
                        ROIGridMask     = mc_GenPath(ROIGridMaskTemplate);
                        ROIGridMaskHdr  = spm_vol(ROIGridMask);
                        ROIGridBB       = mc_GetBoundingBox(ROIGridMaskHdr);
                        grid_coord_cand = SOM_MakeGrid(ROIGridSpacing,ROIGridBB);
                        inOutIDX        = SOM_roiPointsInMask(ROIGridMask,grid_coord_cand);
                        grid_coord      = grid_coord_cand(inOutIDX,:);
                        grid_coord      = [grid_coord; ROIGridCenters];
                end
                
                parameters.rois.mni.coordinates = grid_coord;
                
                if (iscell(ROIGridSize))
                    parameters.rois.mni.size = ROIGridSize{1};
                else
                    % The radius is measured in VOXELS and not mm.
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
        parameters = SOM_CheckParamVersion(parameters);
        if ~parameters.OK
            SOM_LOG('FATAL ERROR : The version of parameters loaded is incompatible with this release.');
            return
        end
        clear global SOM;
        global SOM;
        SOM.silent = 1;
        SOM_LOG('STATUS : Read parameters file in from previous run');
        
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
                    SOM_LOG(results(iR,:));
                end
                SOM_LOG(sprintf('STATUS : Calculation done for Subject : %s',Subject));
            end
        end
    end
end




