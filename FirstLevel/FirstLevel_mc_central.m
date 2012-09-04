%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% You shouldn't need to edit this script
%%% Instead make a copy of PreprocessingFirstLevel_template.m 
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
global mcLog;
mcWarnings = 0;

if (Mode == 2)
    UseSandbox = 0;
end

if (UseSandbox)
    username = getenv('USER');
    pid = num2str(feature('GetPID'));
    [ans hostname] = system('hostname -s');
    [fd fn fe] = fileparts(mcLog);
    Sandbox = fullfile([filesep hostname(1:end-1)],'sandbox',[username '_' pid '_' fn]);
    mc_Logger('log',sprintf('Using sandbox %s',Sandbox),3);
else
    Sandbox = '';
    mc_Logger('log','Not using sandbox',3);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% General Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
if (~exist('NumScan','var'))
    NumScan = [];
end
NumScanTotal = NumScan;
if (exist('ContrastRunWeights','var'))
    ContrastRunWeightsTotal = ContrastRunWeights;
else
    ContrastRunWeightsTotal = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% First level begin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%     Don't Edit Below This Line     %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%Set to 1 if using spm2 %%% Caution, full script not compatible yet
spm2 = 0;

%%% if StartOp is set to '1', then need to set the start point below
StartPoint = 2; % manual start point doesn't work with SPM5

NanVar = NaN;

if (~exist('RegOp'))
    RegOp = [0 0];
end

if (size(RegOp,2)==1)
    RegOp(2) = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%      Paths and Filenames           %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MasterFileCheck = struct('Template',MasterTemplate,...
                         'mode','check');
MasterFile = mc_GenPath(MasterFileCheck);

if (RegOp(1) == 1)
    RegFileCheck = struct('Template',RegTemplate,...
                          'mode','check');
    RegFile = mc_GenPath(RegFileCheck);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Calculated parameters %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SubjColumn    = SubjColumn - MasterDataSkipCols;
RunColumn     = RunColumn - MasterDataSkipCols;
RegSubjColumn = RegSubjColumn - RegDataSkipCols;
RegRunColumn  = RegRunColumn - RegDataSkipCols;
CondColumn    = CondColumn - MasterDataSkipCols;
TimColumn     = TimColumn - MasterDataSkipCols;
DurColumn     = DurColumn - MasterDataSkipCols;

if (RegOp(1) == 1)
    for x = 1:size(RegList,1)
        RegList{x,2} = RegList{x,2} - RegDataSkipCols;
    end
end

NumCond = size(ConditionName,1); %number of conditions
NumCondCol = size(CondColumn,2); % number of columns that assign conditions

NumPar = size(ParList,1);
for iPar = 1: NumPar
    ParName{iPar}   = ParList{iPar,1};
    ParColumn{iPar} = ParList{iPar,2};

    if NumCondCol > 1
        ParCondCol{iPar} = ParList{iPar,3};
    end
end % loop through parameters

NumReg     = size(RegList,1);
NumSubject = size(SubjDir,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%      Read Data from Files          %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(MasterFile(end-3:end),'.csv')
    MasterData = csvread([MasterFile],MasterDataSkipRows,MasterDataSkipCols);
else
    MasterData = csvread([MasterFile, '.csv'],MasterDataSkipRows,MasterDataSkipCols);
end

% regressor line
if RegOp(1) ==1;
    if strcmp(RegFile(end-3:end),'.csv')
        RegMasterData = csvread ([RegFile],RegDataSkipRows,RegDataSkipCols);     
    else
        RegMasterData = csvread ([RegFile, '.csv'],RegDataSkipRows,RegDataSkipCols);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Begin looping over subjects %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for iSubject = 1:NumSubject %First level fixed effect, subject by subject
    clear SPM;
    
    Subject = SubjDir{iSubject,1};
    SubjRow = SubjDir{iSubject,2};  
    RunList = SubjDir{iSubject,3};

    mc_Logger('log',sprintf('Now working on subject %s',Subject),3);
    
    NumRun      = size(RunList,2);
    TotalNumRun = size(RunNamesTotal,1);  %%% number of image runs if every run were present
    ContrastRunWeights = ContrastRunWeightsTotal;

    if (size(RunList,2) ~= TotalNumRun && ~isempty(ContrastRunWeights))
        mcWarnings = mcWarnings + 1;
        mc_Logger('log',sprintf('You have specified run-specific contrasts but are excluding runs for %s. Contrast results may be invalid.',Subject),2);
    end
    
    %%% This code cuts ContrastRunWeights down based on included runs
    for iRun = 1:NumRun
        for iContrast = 1:size(ContrastRunWeights,1)
            if (size(ContrastRunWeights{iContrast},2)>0)
                ContrastRunWeights{iContrast} = ContrastRunWeights{iContrast}(RunList);
            end
        end
    end
    
    %%%%% This code cuts RunDir and NumScan based which Image Runs are present  
    clear RunDir;
    NumScan = [];
    for iRun=1:NumRun
        RunDir{iRun,1}=RunNamesTotal{RunList(1,iRun)};
        if (~isempty(NumScanTotal))
            NumScan(1,iRun) = NumScanTotal(1,RunList(1,iRun));
        end
    end

    NumRun = size(RunDir,1); % number of runs
    
    %%%Check if NumScan exists and is filled in.  If not, we need to build
    %%%NumScan based on number of frames in .nii file (or number of analyze
    %%%images)
    nsflag = 0;
    if (isempty(NumScan))
        nsflag = 1;
    end
    for iRun = 1:NumRun
        frames = [1];
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
      
    % Clear the variables
    clear SPM
    P=[];
    clear CondLength
    if (Mode == 1 || Mode == 3)
        fprintf('Building Fixed Effects Analysis of %s\n', SubjDir{iSubject,1});
        mc_Logger('log',sprintf('Building Fixed Effects Analysis of %s',Subject),3);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%      Parse Data Columns into input variables  %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% The following routine reads the Masterdata file for onsets, durations and parameters (if there are any) for every event in every trial in the whole experiment

    %%%%% assign values to main variables
    if (IdenticalModels)
        Data=MasterData(1:TotalTrials,:);
    else
        Data=MasterData(find(MasterData(:,SubjColumn)==SubjRow),:);
    end

    %%%% Shorten data according to runs present in RunList
    NewData=[];
    TrialsPerRun = [];
    for iRun=1:TotalNumRun
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
        NumCondPerCondCol(iCondCol) = size(find(~isnan(unique(MasterData(:,CondColumn(iCondCol))))),1); %%% need to look at this line
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
    for iRun = 1:NumRun
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
                            RunPar{iPar}{iCondValue+CondColAdjustment}= vertcat(RunPar{iPar}{iCondValue+CondColAdjustment},iParValue{iPar}); 
                        end
                    end % loop through parameters
                end % else statement
            end % loop through trials

            Timing{iRun}   = RunTiming;
            Duration{iRun} = RunDur;
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
            CondLength(iRun,iCond)=  size(Timing{iRun}{1,iCond},1);
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
    if (exist(OutputDir,'dir')) %if outputdir already exists, remove it for new results
        result = rmdir(OutputDir,'s');
        if (result == 0)
            mc_Error('Output directory %s\nalready exists and cannot be removed. Please check you permissions.',OutputDir);
        end
    end
    SandboxOutputDir = mc_GenPath(fullfile(Sandbox,OutputTemplate));
    display(sprintf('\n\nI am going to save the output here: %s', OutputDir));

    if (Mode == 1 | Mode ==2) 
        if (strcmp(OutputDir(end),filesep))
            OutputDir = OutputDir(1:end-1);
        end
        mc_GenPath( struct('Template',OutputDir,'mode','makeparentdir') );
        mc_GenPath(struct('Template',SandboxOutputDir,'mode','makedir'));
        cd(SandboxOutputDir)
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%% Assign onsets, durations and parameters to SPM variables  %%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for iRun = 1:NumRun
        if NumCond == 0  % case wehere the run lacks any conditions
            SPM.Sess(iRun).U = [];
        else
            iCond = 1;
            for jCond = 1:NumCond-CondModifier

                if CondLength(iRun,jCond)>CondThreshold % case where condition has more than CondThreshold members
                    
                    SPM.Sess(iRun).U(iCond).name  = {[RunDir{iRun}, ConditionName{jCond}]};
                    SPM.Sess(iRun).U(iCond).ons   = Timing{iRun}{1,jCond};
                    SPM.Sess(iRun).U(iCond).dur   = Duration{iRun}{1,jCond};
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
                    iCond = iCond+1;
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

    %% Store Motion regressors for all runs in 1 subject  
    if (RegOp(2) == 1)
    if ( exist('MotRegTemplate','var') == 1 && ~isempty(MotRegTemplate) )
        for iRun=1:NumRun
            Run           = RunDir{iRun};
            MotRegName2    = mc_GenPath( struct('Template',MotRegTemplate,'mode','check') );
            MotRegressors = load(MotRegName2);
            mc_Logger('log',sprintf('Found %d motion regressors',size(MotRegressors,2)),3);
            fprintf('Found %d motion regressors\n',size(MotRegressors,2));
            if ( exist('MotRegList','var') ~= 1 || isempty(MotRegList) )
                SPM.Sess(iRun).C.C    = MotRegressors(1:NumScan(iRun),:);
                SPM.Sess(iRun).C.name = {'x', 'y', 'z', 'p', 'y', 'r'};
            else
                MotReg = MotRegressors(1:NumScan(iRun),:);
                for iMot=1:size(MotRegList,1)
                    SPM.Sess(iRun).C.C = [ SPM.Sess(iRun).C.C MotReg(:,MotRegList{iMot,2}) ];
                    SPM.Sess(iRun).C.name{1,iMot} = MotRegList{iMot,1};
                end
            end                  
        end
    end
    end
    

    %% case where there are regressors
    if (NumReg > 0 && RegOp(1) == 1)
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        if RegOp(1) == 1 % case where you preset regressors

            RegData    = [];
            RegDataCol = [];

            RegData=RegMasterData(find(RegMasterData(:,RegSubjColumn)==SubjRow),:);

            %%%% Shorten data according to runs present in RunList
            NewRegData=[];
            for iRun=1:TotalNumRun
                NewDataRun = RegData(find(RegData(:,RegRunColumn)==iRun),:);
                if ismember(iRun,RunList)
                    NewRegData=vertcat(NewRegData,NewDataRun);
                end
            end
            RegData=NewRegData;
            mc_Logger('log',sprintf('Loaded %d regressors from %s',NumReg,RegFile),3);
            fprintf('Loaded %d regressors from %s\n',NumReg,RegFile);
            for iRun=1:NumRun
                for iReg = 1:NumReg
                    TempRegData = RegData(find(RegData(:,RegRunColumn)==RunList(iRun)),:);
                    RegDataCol = TempRegData(1:NumScan(iRun),RegList{iReg,2}); % RegDataCol now contains the column of regressors for regressor#iReg for run#iRun
                    SPM.Sess(iRun).C.C = [SPM.Sess(iRun).C.C RegDataCol]; % assign this RegDataCol to appropriate column in the SPM variable %%Joe, needs offset
                end % loop through regressors

                %% assign regressor name
                SPM.Sess(iRun).C.name = [SPM.Sess(iRun).C.name RegList(:,1)'];

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
    for iRun = 1:NumRun
        frames = [1];
        if (strcmp(imagetype,'nii'))
            frames = [1:NumScan(iRun)];
        end
        % directory of images in a subject

        Run=RunDir{iRun};
        ImageDirCheck = struct('Template',ImageTemplate,...
                               'mode','check');
        ImageDir = mc_GenPath(ImageDirCheck);
        %fullfile(Exp,ImageLevel1,SubjDir{iSubject,1},ImageLevel2,RunDir{iRun},ImageLevel3); 
        %CheckPath(ImageDir,'Check your ImageTemplate');

        %%%%%%%%% Copy Images to Sandbox directory if necessary
        if (UseSandbox)
            mc_GenPath(struct('Template',fullfile(Sandbox,ImageTemplate),'mode','makeparentdir'));
            shellcommand = sprintf('cp -af %s %s',fullfile(ImageDir,'*'),fullfile(Sandbox,ImageDir));
            [status result] = system(shellcommand);
            if (status ~= 0)
                mc_Error('Image folder %s could not be copied to sandbox.\nPlease check your paths and permissions.',ImageDir);
            end
        end
        
        % for SPM2
        if (spm2)
            mc_Error(strcat('FATAL ERROR: %s is not supported.\n',...
                            '* * * A B O R T I N G * * *\n'),'SPM2');
        else
            tmpP = spm_select('ExtFPList',fullfile(Sandbox,ImageDir),['^' basefile '.*.' imagetype],frames);
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

    if (Mode==1 || Mode==3)
        fprintf('Start Model Estimation for %s\n', SubjDir{iSubject,1});
        mc_Logger('log',sprintf('Start Model Estimation for %s',Subject),3);
    end
    
    if Mode == 1
        SPM = spm_spm(SPM);
    elseif Mode == 2
        clear SPM;
        load('SPM.mat');
    end
    
    if (Mode==1 || Mode==3)
        fprintf('Model Estimation Done for %s\n', SubjDir{iSubject,1});
        mc_Logger('log',sprintf('Model Estimation Done for %s',Subject),3);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%% Contrasts %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    fprintf('Start Contrast Building for %s\n', SubjDir{iSubject,1});
    mc_Logger('log',sprintf('Start Contrast Building for %s',Subject),3);

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
    Scaling = NumRun./Scaling;  % This needs attention

    CondPresentInf = CondPresent;
    CondPresentInf(find(CondPresentInf==0))=Inf;
    %CondPresentInf = [CondPresentInf ones(size(CondPresentInf,1),size(RegList,1))];
    CondPresentInf = [CondPresentInf ones(size(CondPresentInf,1),size(SPM.Sess(1).C.C,2))];
    
    %%%%% Set up "dynamic" contrasts %%%%%
    NumContrast=size(ContrastList,1);
    
    if (~exist('ContrastRunWeights','var'))
        ContrastRunWeights = {};
        for iContrast = 1:NumContrast
            ContrastRunWeights{iContrast} = [];
        end
    end
    
    for iContrast = 1: NumContrast
        if (size(ContrastRunWeights,1)<iContrast || isempty(ContrastRunWeights{iContrast}))
            ContrastRunWeights{iContrast} = ones(1,NumRun);
        end
        RunWeighting = repmat(ContrastRunWeights{iContrast}',1,size(CondPresentInf,2)).*CondPresentInf;
        RunWeighting = reshape(RunWeighting',1,prod(size(RunWeighting)));
        RunWeighting = RunWeighting(find(~isnan(RunWeighting)));
        RunWeighting = RunWeighting(find(~isinf(RunWeighting)));
        
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
            % do motion regressors from file if any
            if (RegOp(2) == 1)
            if exist('MotRegTemplate','var') == 1 && ~isempty(MotRegTemplate)
                Run          = RunDir{iRun};
                MotRegName2   = mc_GenPath( struct('Template',MotRegTemplate,'mode','check') );
                MotReg       = load( MotRegName2 );
                zeroPad      = zeros( 1, size(MotReg,2) );
                ContrastBase = [ContrastBase zeroPad];
            end
            end
            % do user specified regressors
            if (NumReg > 0 && RegOp(1) == 1)
                ContrastBase = horzcat(ContrastBase, ContrastList{iContrast, NumCond+2});
            end
        end % loop through runs
        NumRunIncluded = sum(abs(ContrastRunWeights{iContrast}));

        PosWeighting = sum(abs(ContrastRunWeights{iContrast}(find(ContrastRunWeights{iContrast}==1))));
        NegWeighting = sum(abs(ContrastRunWeights{iContrast}(find(ContrastRunWeights{iContrast}==-1))));
        NumRunIncluded = max(PosWeighting,NegWeighting);
        if (sum(ContrastBase)==0 && PosWeighting>0 && NegWeighting>0)
            NumRunIncluded = NumRunIncluded * 2;
        end
        if (PosWeighting == 0)
            PosWeighting = 1;
        end
        if (NegWeighting == 0)
            NegWeighting = 1;
        end
        if (PosWeighting==NegWeighting)
            PosWeighting = 1;
            NegWeighting = 1;
        end
        
        RunWeighting(find(RunWeighting>0)) = RunWeighting(find(RunWeighting>0)).*NegWeighting;
        RunWeighting(find(RunWeighting<0)) = RunWeighting(find(RunWeighting<0)).*PosWeighting;
        
        ContrastContent{iContrast} = 1/NumRunIncluded*ContrastBase;  % Normalize the values of the contrast vector based on the number of runs
        
        ContrastContent{iContrast} = RunWeighting.*ContrastContent{iContrast};
        ContrastContent{iContrast} = horzcat(ContrastContent{iContrast},zeros(1,NumRun));  % Right pad the contrast vector with zeros for each SMP automatic run regressor
        ContrastContent{iContrast}(isnan(ContrastContent{iContrast})) = 0;
        if (sum(abs(ContrastContent{iContrast})) == 0)
            mcWarnings = mcWarnings + 1;
            mc_Logger('log',sprintf('Due to non-present conditions or run-specific contrasts, contrast %s was all 0s for %s and has been replaced by a dummy contrast.',ContrastName{iContrast},Subject),2);    
        end
    end % loop through contrasts

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
        jobs{1}.stats{1}.con.spmmat = {fullfile(SandboxOutputDir,'SPM.mat')};
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
    mc_Logger('log',sprintf('Contrast Test Done for %s\n',Subject),3);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%% Move results back to OutputDir %%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if (UseSandbox)
        shellcommand = sprintf('cp -af %s %s',SandboxOutputDir,OutputDir);
        [status result] = system(shellcommand);
        if (status ~= 0)
            mc_Error('Unable to copy sandbox directory (%s) back to output directory (%s).\nPlease check paths and permissions.',SandboxOutputDir,OutputDir);
        end
        
        mc_FixSPM(OutputDir,Sandbox,'');
        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%    Done with subject   %%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % loop through subjects


shellcommand = sprintf('rm -rf %s',Sandbox);
[status result] = system(shellcommand);
if (status ~= 0)
    mcWarnings = mcWarnings + 1;
    mc_Logger('log','Unable to remove sandbox directory',2);
end
        
fprintf('All Done\n');
fprintf('***********************************************\n')

if (mcWarnings > 0)
    fprintf('You had %d warnings.  Please check the logfile located at %s.\n',mcWarnings,mcLog);
end
