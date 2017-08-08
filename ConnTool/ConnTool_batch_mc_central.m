%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% General calculations that apply to both Preprocessing and First Level
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize what we need.

warning off all

global defaults
global SOM

spm('defaults','fmri');
SOM_LOG('STATUS : * * * * * * * * * * * * * * * * * * * *');
SOM_LOG('STATUS : Starting up the ConnTool Box');
SOM_LOG('STATUS : Authored by Robert Welsh 2008-2013');
SOM_LOG('STATUS : Some parts authored by Methods Core');
SOM_LOG('STATUS : Ann Arbor, MI');
SOM_LOG('STATUS : rcwelsh (at) med (dot) umich (dot) edu');

SOM_SetDefaults
SOM_LOG('STATUS : * * * * * * * * * * * * * * * * * * * *');

% Did they specify a smaller group of subjects to process?

if exist('SubjectDirBatch') && ~isempty(SubjectDirBatch)
    if max(SubjectDirBatch) > size(SubjDir,1) || min(SubjectDirBatch) < 1
        fprintf('\nError - the batch of subjects you are requesting will not exist\n\n');
        FATALERROR=1;
    else
        SubjDirTmp = {};
        nSubjectBatch = 0;
        for iSubjectBatch = 1:length(SubjectDirBatch)
            nSubjectBatch = nSubjectBatch + 1;
            for iSubjectBatchCol = 1:2
                SubjDirTmp{nSubjectBatch,iSubjectBatchCol} = SubjDir{SubjectDirBatch(iSubjectBatch),iSubjectBatchCol};
            end
        end
        SubjDir = SubjDirTmp;
    end
end

RunMode = [0 0];
if (strcmpi(Mode,'full'))
    RunMode = [1 1];
else                                % Added 2016-11-18 - RCWelsh
  if (strcmpi(Mode,'preprocsave'))   % Run preprocessing, but skip the correlations and save the D0 4D image.
    RunMode = [1 2];
  else
    RunMode(1) = strcmpi(Mode,'parameters');
    RunMode(2) = strcmpi(Mode,'presave');    % Changed on 2016-11-18, 'som' was not option in 'central' script.
  end
end

[spmver spmsubver] = spm('Ver');
if (strcmp(spmver,'SPM8')==1)
    spm_get_defaults('cmdline',true);
end

if ~isempty(GreyFile)
    GreyMatterTemplate  = [AnatomyMaskPath '/' GreyFile];
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
        
    for iSubject = 1:size(SubjDir,1)
        clear parameters;
        SOM.LOG = [];
        
        parameters.RegressFLAGS.prinComp = PrincipalComponents;
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
            [GreyPath EC]  = mc_GenPath(GreyMatterTemplate);
            if ~isempty(EC)
                SOM_LOG('FATAL : You specified a gray matter volume but it is not there.');
                SOM_LOG(EC);
                return
            end
        end
        if ~isempty(WhiteFile)
            [WhitePath EC] = mc_GenPath(WhiteMatterTemplate);
            if ~isempty(EC)
                SOM_LOG('FATAL : You specified a white matter volume but it is not there.');
                SOM_LOG(EC);
                return
            end
        end
        if ~isempty(CSFFile)
            [CSFPath EC]  = mc_GenPath(CSFTemplate);
            if ~isempty(EC)
                SOM_LOG('FATAL : You specified a CSF volume but it is not there.');
                SOM_LOG(EC);
                return
            end
        end
        [BrainPath EC] = mc_GenPath(EPIBrainMaskTemplate);
        if ~isempty(EC)
            SOM_LOG('FATAL : The specified BrainMask is not there.');
            SOM_LOG(EC);
            return
        end
        
        if ~isempty(GreyFile)
            parameters.masks.grey.File          = GreyPath;
            if ~isempty(GreyThreshold)
                parameters.masks.grey.ImgThreshold  = GreyThreshold;
            else
                parameters.masks.grey.ImgThreshold  = SOM.defaults.MaskImgThreshold;
            end
            
        end
        
        if ~isempty(WhiteFile)
            parameters.masks.white.File         = WhitePath;
        end
        if ~isempty(CSFFile)
            parameters.masks.csf.File           = CSFPath;
        end
        
        parameters.masks.epi.File               = BrainPath;
        
        % Save an example of a time course for plotting.
        
        for iRun = 1:ImageNumRun
            Run = RunDir{iRun};
            
            [ImagePath EC]   = mc_GenPath(ImageTemplate);
            if ~isempty(EC)
                SOM_LOG('FATAL : The generation of the path to the data failed.');
                SOM_LOG(EC);
                return
            end
            
            ImageFiles  = spm_select('FPList',ImagePath, ['^' connectFile '.*.' imagetype]);
            parameters.data.run(iRun).P        = ImageFiles;
            parameters.data.run(iRun).voxelIDX = voxelIDX;
            parameters.data.run(iRun).sampleTC = [];
            
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
            % We don't care about orthogonalizing these as they are just absorbing variance
	    % and we are not concerned which absorbs variance as it's thrown away.

            if ~isempty(strfind(parameters.RegressFLAGS.order,'M'))
                [RealignmentParametersFile EC]  = mc_GenPath(RealignmentParametersTemplate);
                if ~isempty(EC)
                    SOM_LOG('FATAL : The specified path to the realignment file failed.');
                    SOM_LOG(EC);
                    return
                end
                RealignmentParameters       = load(RealignmentParametersFile);
		RealignmentParametersDerivR = 0*RealignmentParameters;         % Pre-allocate.
		%
		% Change from doing diff to using gradient which does better estimation of the derivative. - RCWelsh 2016-11-21
		% (Gradient has be be explicitly called with single vector else it'll calculate the 2d gradient)
		%
		for iReg = 1:size(RealignmentParameters,2)
		  RealignmentParametersDerivR(:,iReg) = gradient(RealignmentParameters(:,iReg));
		end
		% Now to square things.
                if (MotionDeriv)
                    RealignmentParametersQuad = [RealignmentParameters RealignmentParametersDerivR].^2;
                else
                    RealignmentParametersQuad = RealignmentParameters.^2;
                end
		%
                parameters.data.run(iRun).MotionParameters = [RealignmentParameters];
                % Derivatives included?
                if (MotionDeriv)
                    parameters.data.run(iRun).MotionParameters = [parameters.data.run(iRun).MotionParameters RealignmentParametersDerivR];
                end
		% Squared included?
                if (MotionQuad)
                    parameters.data.run(iRun).MotionParameters = [parameters.data.run(iRun).MotionParameters RealignmentParametersQuad];
                end
            else
                parameters.data.run(iRun).MotionParameters = [];
            end
            
            % This neesd some logic, such that if NumScan is missing then
            % the code will assume all time points.
            
            try
                parameters.data.run(iRun).nTIME            = NumScan(iRun);
            catch
                parameters.data.run(iRun).nTIME            = 99999;
            end
            
            parameters.data.run(iRun).despikeVector    = [];
            parameters.data.run(iRun).censorVector     = [];
            
            %%%added code to handle DeSpike Vectors
            %
            %
            parameters.data.run(iRun).despikeVector = [];
            if (exist('DespikeParametersTemplate','var') && ~isempty(DespikeParametersTemplate))
                [DeSpikeFile EC] = mc_GenPath(struct('Template',DespikeParametersTemplate,'mode','check'));
                if isempty(EC)
                    [p f e] = fileparts(DeSpikeFile);
                    if (strcmp(e,'.mat'))
                        %read variable and use the found element
                        tempcv = load(DeSpikeFile);
                        tmpArrayField = fieldnames(tempcv);
                        if length(tmpArrayField) ~= 1
                            SOM_LOG(sprintf('FATAL ERROR : Ambiguous Spike information in file %s',DeSpikeFile));
                            return
                        end
                        try
                            cv = getfield(tempcv,tmpArrayField{1});
                        catch
                            SOM_LOG(sprintf('FATAL ERROR : Error in Spike information in file %s',DeSpikeFile));
                            return
                        end
                    else %assume text file
                        cv = load(DeSpikeFile);
                    end
                    if (size(cv,1)>NumScan(iRun))
                        cv = cv(1:NumScan(iRun));
                    end
                    parameters.data.run(iRun).despikeVector = cv;
                    % Now the parameters for despiking
                    
                    DESPIKEOPTIONS = {'moving','lowess','loess','sgolay','rlowess','rloess'};
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
                                    SOM_LOG(sprintf('WARNING : Despiking span is unreadable : %s. Using default',DespikeNumberOption));
                                    DespikeNumberOption = SOM.defaults.DespikeNumberOption;
                                end
                            end
                        end
                    else
                        SOM_LOG('WARNING : No "DespikeReplacementOption" specified, using default');
                    end
                    
                    DESPIKEINTERP1 = {'nearest','linear','spline','pchip'};
                    
                    if exist('DespikeReplacementInterp','var') && ~isempty(DespikeReplacementInterp)
                        if isempty(cell2mat(strfind(DESPIKEINTERP1,DespikeReplacementInterp)))
                            SOM_LOG('WARNING : No "DespikeReplacementInterp" specified, using default');
                            DespikeReplacementInterp = SOM.defaults.DespikeReplacementInterp;
                        end
                        
                        parameters.RegressFLAGS.despikeParameters.span         = DespikeNumberOption;
                        parameters.RegressFLAGS.despikeParameters.method       = DespikeOption;
                        parameters.RegressFLAGS.despikeParameters.interpMethod = DespikeReplacementInterp;
                        
                    end
                    SOM_LOG(sprintf('STATUS : Despiking file found for run %d',iRun));
                else
                    SOM_LOG(sprintf('STATUS : No despiking file found for run %d',iRun));
                end
            end
            
            %%%added code to handle censorVectors
            %
            % ROBERT DOES NOT RECOMMEND THE CURRENT IMPLEMENTATION OF
            % CENSORING IF DONE AFTER FILTERING.
            %
            % USE AT YOUR OWN STATISTICAL RISK
            %
            parameters.data.run(iRun).censorVector = [];
            if (exist('CensorParametersTemplate','var') && ~isempty(CensorParametersTemplate))
                [CensorFile EC] = mc_GenPath(struct('Template',CensorParametersTemplate,'mode','check'));
                if isempty(EC)
                    [p f e] = fileparts(CensorFile);
                    if (strcmp(e,'.mat'))
                        %read variable and use the found element
                        tempcv = load(CensorFile);
                        tmpArrayField = fieldnames(tempcv);
                        if length(tmpArrayField) ~= 1
                            SOM_LOG(sprintf('FATAL ERROR : Ambiguous Censor information in file %s',CensorFile));
                            return
                        end
                        try
                            cv = getfield(tempcv,tmpArrayField{1});
                        catch
                            SOM_LOG(sprintf('FATAL ERROR : Error in Censor information in file %s',CensorFile));
                            return
                        end
                    else %assume text file
                        cv = load(CensorFile);
                    end
                    
                    if (size(cv,1)>NumScan(iRun))
                        cv = cv(1:NumScan(iRun));
                    end
                    
                    parameters.data.run(iRun).censorVector = cv;
                    SOM_LOG(sprintf('STATUS : Censor vector found for this run : %d',iRun));
                else
                    SOM_LOG(sprintf('STATUS : No censor vector found for this run : %d',iRun));
                end
            end
            
            %%%
            
            %parameters.data.MaskFLAG = MaskBrain;
            
            parameters.TIME.run(iRun).TR            = TR;
            parameters.TIME.run(iRun).DetrendOrder  = DetrendOrder;
            parameters.TIME.run(iRun).LowF          = LowFrequency;
            parameters.TIME.run(iRun).HiF           = HighFrequency;
            if exist('LowFreqBand1','var')
                parameters.TIME.run(iRun).FreqBand1(1)   = LowFreqBand1;
            end
            if exist('LowFreqBand2','var')
                parameters.TIME.run(iRun).FreqBand2(1)   = LowFreqBand2;
            end
            if exist('HighFreqBand1','var')
                parameters.TIME.run(iRun).FreqBand1(2)   = HighFreqBand1;
            end
            if exist('HighFreqBand2','var')
                parameters.TIME.run(iRun).FreqBand2(2)   = HighFreqBand2;
            end
            % 
            % Sanity check on the inputs, Nyquist if trying
            % to run ALFF or fALFF
            %
            if strcmpi(OutputType(1),'f') || strcmpi(OutputType(1),'a') % fALFF / ALFF checks
                if ~isempty(regexpi(RegressOrder,'e')) % if running in "EDIT" mode
                    SOM_LOG('FATAL: You are running in fALFF / ALFF mode, but you have specified option E in RegressOrder. This breaks spectral assumptions and is not allowed.');
                    return
                end
            end
            if strcmpi(OutputType(1),'f') % fALFF checks
                if ~isfield(parameters.TIME.run(iRun),'FreqBand1') || ~isfield(parameters.TIME.run(iRun),'FreqBand2')
                    SOM_LOG('FATAL: You are running in fALFF Mode, but have not set both frequency bands');
                    return
                end
                if numel(parameters.TIME.run(iRun).FreqBand1) ~= 2 || numel(parameters.TIME.run(iRun).FreqBand2) ~= 2
                    SOM_LOG('FATAL: Your two frequency bands must have one lower and one upper bound');
                    return
                end
                if parameters.TIME.run(iRun).FreqBand1(2) > parameters.TIME.run(iRun).FreqBand2(2)
                    SOM_LOG('FATAL : Your high frequencies are not workable (FreqBand1 extends above FreqBand2');
                    return
                end
                if parameters.TIME.run(iRun).FreqBand1(1) < parameters.TIME.run(iRun).FreqBand2(1)
                    SOM_LOG('FATAL : Your low frequencies are not workable (FreqBand1 extends below FreqBand2)');
                    return
                end

                if parameters.TIME.run(iRun).FreqBand1(2) > (1/2/TR-.002) || parameters.TIME.run(iRun).FreqBand2(2) > (1/2/TR-.002)
                    SOM_LOG('FATAL : Your high frequencies violate Nyquist');
                    return
                end
                if parameters.TIME.run(iRun).FreqBand1(1) >= parameters.TIME.run(iRun).FreqBand1(2) || parameters.TIME.run(iRun).FreqBand2(1) >= parameters.TIME.run(iRun).FreqBand2(2);
                    SOM_LOG('FATAL: Your low frequencies are not lower than your high frequencies');
                    return
                end
            end
            if strcmpi(OutputType(1),'a') % ALFF checks
                if ~isfield(parameters.TIME.run(iRun),'FreqBand1')
                    SOM_LOG('FATAL: You are running in ALFF Mode, but have not set the frequency band');
                    return
                end
                if numel(parameters.TIME.run(iRun).FreqBand1) ~= 2
                    SOM_LOG('FATAL: Your frequency band must have one lower and one upper bound');
                    return
                end
                if parameters.TIME.run(iRun).FreqBand1(2) > (1/2/TR-.002)
                    SOM_LOG('FATAL : Your high frequencies violate Nyquist');
                    return
                end
                if parameters.TIME.run(iRun).FreqBand1(1) >= parameters.TIME.run(iRun).FreqBand1(2)
                    SOM_LOG('FATAL: Your low frequency is not lower than your high frequency');
                    return
                end
            end

            parameters.TIME.run(iRun).gentle        = Gentle;
            parameters.TIME.run(iRun).padding       = Padding;
            parameters.TIME.run(iRun).whichFilter   = BandpassFilter;
            parameters.TIME.run(iRun).fraction      = Fraction;
        end
        
        Run = RunDir{1};
        [ImagePath EC] = mc_GenPath(ImageTemplate);
        if ~isempty(EC)
            SOM_LOG('FATAL : Failure to generate path to save som_mask.img.');
            SOM_LOG(EC);
            return
        end
        [SOM_Mask EC] = mc_GenPath(fullfile(ImagePath,'som_mask.img'));
        if ~isempty(EC)
            SOM_LOG('FATAL : Failure to generate name to save som_mask.img.');
            SOM_LOG(EC);
            return
        end
        
        if (isempty(EPIBrainMaskTemplate))
            parameters.rois.mask.File = SOM_Mask;
        else
            parameters.rois.mask.File = BrainPath;
        end
        output.Template = OutputTemplate;
        output.type     = 1;
        output.mode     = 'makedir';
        if (RunMode(1))
            [OutputPath EC] = mc_GenPath(output);
        else
            [OutputPath EC] = mc_GenPath(OutputTemplate);
        end
        if ~isempty(EC)
            SOM_LOG('FATAL : Failure to generate path to save output.');
            SOM_LOG(EC);
            return
        end
        
        switch (ROIInput)
            case 'files'
                [ROIFolder EC] = mc_GenPath(ROITemplate);
                if ~isempty(EC)
                    SOM_LOG('FATAL : Failure to find the ROI directory');
                    SOM_LOG(EC);
                    return
                end
                for iROIs = 1:size(ROIImages,1)
                    ROI{iROIs} = fullfile(ROIFolder,ROIImages{iROIs});
                end
                parameters.rois.files = char(ROI);
            case 'directory'
                [ROIFolder EC] = mc_GenPath(ROITemplate);
                if ~isempty(EC)
                    SOM_LOG('FATAL : Failure to find the ROI directory');
                    SOM_LOG(EC);
                    return
                end
                parameters.rois.files = spm_select('FPList',ROIFolder,'.*\.img|.*\.nii');
            case {'coordinates','coordload','grid','gridplus'}
                switch(ROIInput)
                    case 'coordinates'
                        grid_coord = ROICenters;
                    case 'coordload'
                        [ROIFileName EC] = mc_GenPath(ROIFile);
                        if ~isempty(EC)
                            SOM_LOG('FATAL : Failure to find the ROI file');
                            SOM_LOG(EC);
                            return
                        end
                        tmpArray = load(ROIFileName);
                        if isstruct(tmpArray)
                            tmpArrayField = fieldnames(tmpArray);
                            %
                            % Now we only expect one field, else throw an error
                            %
                            if length(tmpArrayField) ~= 1
                                SOM_LOG(sprintf('FATAL ERROR : Ambiguous ROI information in file %s',ROIFileName));
                                return
                            end
                            try
                                grid_coord = getfield(tmpArray,tmpArrayField{1});
                            catch
                                SOM_LOG(sprintf('FATAL ERROR : Error in ROI information in file %s',ROIFileName));
                                return
                            end
                        end
                    case {'grid','gridplus'}
                        [ROIGridMask EC]   = mc_GenPath(ROIGridMaskTemplate);
                        if ~isempty(EC)
                            SOM_LOG('FATAL : Failure to find the ROI grid mask file');
                            SOM_LOG(EC);
                            return
                        end
                        ROIGridMaskHdr  = spm_vol(ROIGridMask);
                        ROIGridBB       = mc_GetBoundingBox(ROIGridMaskHdr);
                        grid_coord_cand = SOM_MakeGrid(ROIGridSpacing,ROIGridBB);
                        inOutIDX        = SOM_roiPointsInMask(ROIGridMask,grid_coord_cand);
                        grid_coord      = grid_coord_cand(inOutIDX,:);
                        if strcmp(ROIInput,'gridplus')
                            grid_coord      = [grid_coord; ROIGridCenters];
                        end
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
        [ParameterPath EC]             = mc_GenPath(fullfile(OutputPath,ParameterFilename));
        if ~isempty(EC)
            SOM_LOG('FATAL : Failure to generate name to save parameters.');
            SOM_LOG(EC);
            return
        end
        % Save some version information into the file.
        parameters                   = SOM_SetParamVersion(parameters);
        parameters.spmVer            = spmver;
        parameters.spmSubVer         = spmsubver;
        parameters.callingScriptName = ConnToolCallingScriptName;
        parameters.centralScriptName = which(mfilename);
        parameters.callingScript     = SOM_DumpScript(parameters.callingScriptName);
        parameters.centralScript     = SOM_DumpScript(parameters.centralScriptName);
	%
	% Log the usage
	%
	mcUsageReturn = mc_Usage([Subject ': SOM parameters set and written'],'ConnTool');
	if ~mcUsageReturn
	  SOM_LOG('WARNING : Can not write mc_Usage token for parameters');
	end		
	%
	% Now save the parameters
	%
        SOM_LOG(sprintf('STATUS : Saving parameters to %s',ParameterPath));
        parameters.LOG = SOM.LOG;
        save(ParameterPath,'parameters');
        %
        % Now clear out the log.
        %
        SOM.LOG = [];
    end
end

if (RunMode(2))
    for iSubject = 1:size(SubjDir,1)
        clear D0 parameters results;
        Subject=SubjDir{iSubject,1};
        %load existing parameter file
        [OutputPath EC] = mc_GenPath(OutputTemplate);
        if ~isempty(EC)
            SOM_LOG('FATAL : Failure to generate name to save results.');
            SOM_LOG(EC);
            return
        end
        try
            load(fullfile(OutputPath,ParameterFilename));
        catch
            SOM_LOG('FATAL : Error trying to read in the file %s',fullfile(OutputPath,ParameterFilename));
            return
        end
        % Restore the log for this person so we can continue.
        SOM.LOG = parameters.LOG;
        SOM_LOG('STATUS : Log restored');
        SOM_LOG(sprintf('STATUS : Working again on subject %s',Subject));
        parameters = SOM_CheckParamVersion(parameters);
        if ~parameters.OK
            SOM_LOG('FATAL ERROR : The version of parameters loaded is incompatible with this release.');
            return
        end
        SOM_LOG('STATUS : Read parameters file in from previous run');
        
        SOM_LOG('STATUS : Preprocessing data');
        [D0 parameters] = SOM_PreProcessData(parameters);
        if D0 == -1
            SOM_LOG('FATAL ERROR : No data returned');
            SOM_LOG('FATAL ERROR : There is something wrong with your template or your data.\nNo data was returned from SOM_PreProcessData\n');
            return
        else
	    if (RunMode(2) == 1)    %Regular correlation calculations.
                SOM_LOG('STATUS : Going to calculate the correlations');
                results = SOM_CalculateCorrelations(D0,parameters);
                if isnumeric(results)
                    SOM_LOG('FATAL ERROR : ');
                    SOM_LOG('FATAL ERROR : There is something wrong with your template or your data.\nNo results were returned from SOM_CalculateCorrelations\n');
                    return
                else
                    for iR = 1:size(results,1)
                        SOM_LOG(['OUTPUT : ',results(iR,:)]);
                    end
	   	    %
		    % Log the usage
	 	    %
		    mcUsageReturn = mc_Usage([Subject ': SOM calculated'],'ConnTool');
		    if ~mcUsageReturn
		      SOM_LOG('WARNING : Can not write mc_Usage token for calculation');
		    end		
                    SOM_LOG('STATUS : * * * * * * * * * * * * * * * * * * * * ');
                    SOM_LOG('STATUS : ');
                    SOM_LOG(sprintf('STATUS : Calculation done for Subject : %s',Subject));
                    SOM_LOG('STATUS : ');
                    SOM_LOG('STATUS : * * * * * * * * * * * * * * * * * * * * ');		
	        end
	    else
	        % RunMode(2) == 2 case.
		% We must be in the mode to save the 4D data to disk.
		%
		SOM_LOG(sprintf('STATUS : Writing 4D data to disk for subject : %s',Subject));
		SOM_LOG(sprintf('STATUS : Save to :%s',fullfile(parameters.Output.directory,[parameters.Output.name '.nii'])));
		data4D2Save = zeros(prod(parameters.maskInfo.size),size(D0,2));
		data4D2Save(parameters.maskInfo.iMask,:) = D0;
		data4D2Save = reshape(data4D2Save,[parameters.maskInfo.size size(D0,2)]);
		SOM_WriteNII(parameters.data.run.P,fullfile(parameters.Output.directory,[parameters.Output.name '.nii']),data4D2Save);
		clear data4D2Save;
		clear D0;
            end
        end
    end
end




