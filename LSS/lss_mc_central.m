% Least Squares Specific Trial x Trial Beta Method
% Ref: Mumford et al. Deconvolving BOLD activation in event-related designs
% for multivoxel pattern classification analyses. NeuroImage (2012) vol. 59
% (3) pp. 2636-2643
%

% loop over trials in task and build design matrix including first trial as
% one condition and all other trials as a second condition.  Build design 
% matrix and estimate SPM model, then save only the first beta image.
% Iterate over trials, each time including the next trial as one condition
% and all other trials as a seperate condition and saving the appropriate
% beta.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Code to create logfile name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LogDirectory = mc_GenPath(struct('Template',LogTemplate,'mode','makedir'));
result = mc_Logger('setup',LogDirectory);
if (~result)
    %error with setting up logging
    mc_Error('There was an error creating your logfiles.\nDo you have permission to write to %s?',LogDirectory);
end

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

NanVar = NaN;

if (~exist('RegOp'))
    RegOp = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%      Paths and Filenames           %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MasterFileCheck = struct('Template',MasterTemplate,'mode','check');
MasterFile = mc_GenPath(MasterFileCheck);

if (RegOp == 1)
    RegFileCheck = struct('Template',RegTemplate,'mode','check');
    RegFile = mc_GenPath(RegFileCheck);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Calculated parameters %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

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
end

NumReg = size(RegList,1);

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
if RegOp ==1;
    if strcmp(RegFile(end-3:end),'.csv')
        RegMasterData = csvread ([RegFile],RegDataSkipRows,RegDataSkipCols);     
    else
        RegMasterData = csvread ([RegFile, '.csv'],RegDataSkipRows,RegDataSkipCols);
    end
end

for iSubject = 1:NumSubject
    betas = [];
    allQ = [];
    Subject=SubjDir{iSubject,1};
    SubjRow=SubjDir{iSubject,2};
    RunList=SubjDir{iSubject,3};

    NumRun = size(RunList,2);
    TotalNumRun = size(NumScanTotal,2);

    %%%%% This code cuts RunDir and NumScan based which Image Runs are present
    NumScan=[];
    clear RunDir;
    for iRun=1:NumRun
        RunDir{iRun,1}=RunNamesTotal{RunList(1,iRun)};
        NumScan=horzcat(NumScan,NumScanTotal(1,RunList(1,iRun)));
    end

    NumRun= size(NumScan,2);
    ImageNumRun=size(RunDir,1);

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

    for iCondCol = 1:NumCondCol
        NumCondPerCondCol(iCondCol) = size(find(~isnan(unique(MasterData(:,CondColumn(iCondCol))))),1);
        CondValues{iCondCol} = Data(1:size(Data,1), CondColumn(iCondCol));
        TimValues{iCondCol} = Data(1:size(Data,1), TimColumn(iCondCol));
        DurValues{iCondCol} = Data(1:size(Data,1), DurColumn(iCondCol));
        for iPar = 1 : NumPar
            ParValues{iPar,iCondCol} = Data(1:size(Data,1), ParColumn{iPar});
        end
    end

    for jRun = 1:NumRun
        for iTrial = 1:size(CondValues{jRun},1)
            clear SPM CondLength;
            P = [];
            for iRun = 1:NumRun
                CondValues{iRun}(:) = 2;
            end
            CondValues{jRun}(iTrial) = 1;
            NumCond = 2;
            ConditionName = {'trial','others'};

            clear Timing
            clear Duration
            clear Parameter
            offset = 0;
            for iRun = 1:NumRun
                clear RunTiming RunDur RunPar;
                RunTiming=cell(1,NumCond);
                RunDur=cell(1,NumCond);
                for iPar = 1 : NumPar
                    RunPar{iPar}=cell(1,NumCond);
                end

                for iCondCol = 1: NumCondCol
                    if iCondCol > 1
                        CondColAdjustment = CondColAdjustment + NumCondPerCondCol(iCondCol-1);
                    else
                        CondColAdjustment= 0;
                    end

                    for iTrial = 1 : TrialsPerRun(iRun)
                        jTrial = offset + iTrial;

                        iCondValue=CondValues{iCondCol}(jTrial,1);
                        iTimValue=TimValues{iCondCol}(jTrial,1);
                        iDurValue=DurValues{iCondCol}(jTrial,1);

                        for iPar = 1 : NumPar
                            iParValue{iPar}=ParValues{iPar,iCondCol}(jTrial,1);
                        end

                        %%% Handle case where condition, onset or duration is set to NaN
                        if (isnan(iCondValue) || isnan(iTimValue) || isnan(iDurValue))
                            iCondValue=NaN;
                            iTimValue=NaN;
                            iDurValue=NaN;
                            for iPar = 1 : NumPar
                                iParValue{iPar}=NaN;
                            end
                        else
                            RunTiming{iCondValue+CondColAdjustment}= vertcat(RunTiming{iCondValue+CondColAdjustment},iTimValue);
                            RunDur{iCondValue+CondColAdjustment}= vertcat(RunDur{iCondValue+CondColAdjustment},iDurValue);

                            for iPar = 1 : NumPar

                                if (NumCondCol==1 || (NumCondCol>1 && ParCondCol{iPar}==iCondCol))  % if the curent condition column is one that the parameter is supposed to modulate
                                    RunPar{iPar}{iCondValue+CondColAdjustment}= vertcat(RunPar{iPar}{iCondValue+CondColAdjustment},iParValue{iPar});
                                end
                            end

                        end
                    end
                    Timing{iRun}=RunTiming;
                    Duration{iRun}=RunDur;
                    for iPar = 1 : NumPar
                        Parameter{iPar,iRun}=RunPar{iPar};
                    end
                end
                offset = offset + TrialsPerRun(iRun);
            end

            %%% Count length of each condition in each run
            for iRun = 1 : NumRun
                for iCond=1:NumCond
                    CondLength(iRun,iCond)=  size(Timing{iRun}{1,iCond},1);
                end
            end

            %%% remove NaN's from variables
            for iRun = 1 : NumRun
                for iCond=1:NumCond
                    Timing{iRun}{1,iCond}= Timing{iRun}{1,iCond}(isnan(Timing{iRun}{1,iCond})==0);
                    Duration{iRun}{1,iCond}= Duration{iRun}{1,iCond}(isnan(Duration{iRun}{1,iCond})==0);

                    for iPar = 1: NumPar
                        Parameter{iPar,iRun}{1,iCond} = Parameter{iPar,iRun}{1,iCond}(isnan(Parameter{iPar,iRun}{1,iCond})==0);
                        Parameter{iPar,iRun}{1,iCond};
                    end
                end
            end

            OutputDir = mc_GenPath(OutputTemplate);
            mc_GenPath( struct('Template',OutputDir,'mode','makedir') );
            cd(OutputDir)

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%% Assign onsets, durations and parameters to SPM variables  %%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            for iRun = 1:NumRun
                if NumCond == 0
                    SPM.Sess(iRun).U = [];
                else
                    iCond=1;
                    for jCond = 1:NumCond-CondModifier
                        if CondLength(iRun,jCond)>CondThreshold
                            SPM.Sess(iRun).U(iCond).name  = {[RunDir{iRun}, ConditionName{jCond}]};
                            SPM.Sess(iRun).U(iCond).ons   = Timing{iRun}{1,jCond};

                            SPM.Sess(iRun).U(iCond).dur   = Duration{iRun}{1,jCond};

                            SPM.Sess(iRun).U(iCond).P(1).name = 'none';
                            if NumPar >0
                                iPar=1;
                                for jPar = 1:NumPar
                                    if size(Parameter{jPar,iRun}{1,jCond},1) > CondThreshold % case where parameter has more than CondThreshold members
                                        SPM.Sess(iRun).U(iCond).P(iPar).name = [RunDir{iRun}, ParList{jPar,1}];
                                        SPM.Sess(iRun).U(iCond).P(iPar).P = Parameter{jPar,iRun}{1,jCond};
                                        SPM.Sess(iRun).U(iCond).P(iPar).h = 1; % order of polynomial expansion
                                        iPar=iPar+1;
                                    end
                                end
                            end
                            iCond=iCond+1;
                        end
                    end
                end
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%% Scan-by-Scan Regressors     %%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            for iSess = 1:NumRun
                SPM.Sess(iSess).C.C    = [];
                SPM.Sess(iSess).C.name = {};
            end
            %% Store Motion regressors for all runs in 1 subject
            if ( exist('MotRegTemplate','var') == 1 && ~isempty(MotRegTemplate) )
                for iRun=1:NumRun
                    Run           = RunDir{iRun};
                    MotRegName    = mc_GenPath( struct('Template',MotRegTemplate,'mode','check') );

                    if ( exist('MotRegList','var') ~= 1 || isempty(MotRegList) )
                        SPM.Sess(iRun).C.C    = load( MotRegName );
                        SPM.Sess(iRun).C.name = {'x', 'y', 'z', 'p', 'y', 'r'};
                    else
                        MotReg = load( MotRegName );
                        for iMot=1:size(MotRegList,1)
                            SPM.Sess(iRun).C.C = [ SPM.Sess(iRun).C.C MotReg(:,MotRegList{iMot,2}) ];
                            SPM.Sess(iRun).C.name{1,iMot} = MotRegList{iMot,1};
                        end
                    end
                end
            end

            if NumReg > 0
                RegData=[];
                RegDataCol=[];

                TotalScan = sum(NumScanTotal);
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
                RegData=NewRegData;
                iScan=1;

                for iRun=1:NumRun
                    for iReg = 1:NumReg
                        RegDataCol = RegData(iScan:iScan+(NumScan(1,iRun)-1),RegList{iReg,2});
                        SPM.Sess(iRun).C.C = [SPM.Sess(iRun).C.C RegDataCol]; %needs offset (not done?)
                    end
                    SPM.Sess(iRun).C.name = [SPM.Sess(iRun).C.name RegList(:,1)'];
                    iScan = iScan + NumScan(1,iRun);
                end
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%% Get images from Image Directory    %%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            for iRun = 1:ImageNumRun
                frames = [1];
                if (strcmp(imagetype,'nii'))
                    frames = [1:NumScanTotal(RunList(iRun))];
                end
                Run=RunDir{iRun};
                ImageDirCheck = struct('Template',ImageTemplate,'mode','check');
                ImageDir = mc_GenPath(ImageDirCheck);

                tmpP = spm_select('ExtFPList',ImageDir,['^' basefile '.*.' imagetype],frames);

                P = strvcat(P,tmpP);

                if isempty(P)
                    mc_Error('Functional images not found in %s',ImageDir);
                end
            end
            SPM.xY.P = P;
            SPM.xY.VY = spm_vol(P);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%% SPM Design Parameters     %%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            SPM.nscan = NumScan;
            SPM.xBF.name       	= 'hrf';
            SPM.xBF.T          	= 16;
            SPM.xBF.T0         	= fMRI_T0;
            SPM.xBF.UNITS      	= 'secs';
            SPM.xBF.Volterra   	= 1;

            SPM.xGX.iGXcalc    = ScaleOp;

            SPM.xX.K.HParam  = 128;

            if (usear1)
                SPM.xVi.form = 'AR(0.2)'; %Used in SPM5
            else
                SPM.xVi.form = 'none';
            end

            SPM.xY.RT = TR;

            SPM.xM.VM = [];
            if (~isempty(explicitmask))
                SPM.xM.VM = spm_vol(explicitmask);
            end

            %now run SPM model for jRun and iTrial and save beta_1+jRun-1
            [SPM currentbeta Q] = lss_runSPM(SPM,jRun,iTrial);
            betas = [betas;currentbeta];
            allQ = [allQ;Q];
            clear Q;
            clear currentbeta;
        end
    end
end

%-Initialise beta image files
%----------------------------------------------------------------------
nBeta = size(betas,1);

DIM      = SPM.xY.VY(1).dim(1:3)';
M        = SPM.xY.VY(1).mat;
Vbeta(1:nBeta) = deal(struct(...
    'fname',    [],...
    'dim',      DIM',...
    'dt',       [spm_type('float32') spm_platform('bigend')],...
    'mat',      M,...
    'pinfo',    [1 0 0]',...
    'descrip',  ''));

for i = 1:nBeta
    Vbeta(i).fname   = sprintf('beta_%04d.img',i);
    Vbeta(i).descrip = sprintf('spm_spm:beta (%04d)',i);
end
Vbeta = spm_create_vol(Vbeta);

for i = 1:nBeta
    jj = NaN(SPM.xY.VY(1).dim);
    if ~isempty(allQ(i,:)), jj(allQ(i,:)) = betas(i,:); end
    Vbeta(i) = spm_write_plane(Vbeta(i), jj, [1:SPM.xY.VY(1).dim(3)]);
end


