%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% You shouldn't need to edit this script
%%% Instead make a copy of PPI_mc_template.m 
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

%%%set up variables for sandboxing
%%%sandboxing likely not added for PPI
%%%would need to copy FirstLevel folder, as well as images, and update
%%%FirstLevel SPM.mat to point to the new image location in order to get
%%%any speedup, not worth the hassle.
UseSandbox = 0;
if (UseSandbox)
    username = getenv('USER');
    pid = num2str(feature('GetPID'));
    if (exist('SandboxDir','var') && ~isempty(SandboxDir))
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
%%% General Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

spmver = spm('Ver');
if (strcmp(spmver,'SPM8')==1)
	spm_jobman('initcfg');
	spm_get_defaults('cmdline',true);
    if (exist('spmdefaults','var'))
        mc_SetSPMDefaults(spmdefaults);
    end
end

RunNamesTotal = RunDir;
if (~exist('NumScan','var'))
    NumScan = [];
end
NumScanTotal = NumScan;

spm('defaults','fmri');
global defaults;
warning off all

clear jobs

TotalNumCond = size(ConditionName,1);

for iSubject = 1:size(SubjDir,1)
    Subject = SubjDir{iSubject,1};
    SPMmat = mc_GenPath(ModelTemplate);
    SPM = load(SPMmat);
    SPM = SPM.SPM;
    
    RunList = SubjDir{iSubject,3};
    NumRun = size(RunList,2);
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
    
    if (NumRun ~= size(SPM.Sess,2))
        mc_Error(sprintf('You have specified %d runs, but the SPM ModelTemplate %s has %d',NumRun,SPMmat,size(SPM.Sess,2)));
    end    

    [SubjFolder f e] = fileparts(SPMmat);
    
    for iROI = 1:size(ROIs,1)
        %check that all data is there and accessible

        %setup general variables
        outputname = ROIs{iROI,1};
        ROI = ROIs{iROI,2};
        radius = ROIs{iROI,3};
        fullweights = ROIs{iROI,4};
        if (isempty(fullweights))
            fullweights = ones(1,TotalNumCond);
        end
        threshold.p = ContrastThresh;
        threshold.extent = ContrastExtent;
        threshold.correction = ContrastCorrection;
        
        %VOI extract batch
        try     
            mc_VOI_Extract(SPMmat,ROI,outputname,radius,ContrastNum,threshold,EOIAdjust);
        catch err
            mc_Error('There was a problem during VOI extraction.\n%s',err.message);
        end
            
        for iRun = 1:NumRun
            clear regressors;
            clear mb;
            clear job;
            Run = RunDir{iRun};
            NumCond = size(SPM.Sess(iRun).U,2);
            %loop over SPM.Sess(iRun).U(:).name and match to ConditionName to
            %build run-specific weights vector based on included conditions.
            weights = [];
            CondPresent = zeros(1,TotalNumCond);
            for iCond = 1:NumCond
                for iCondTotal = 1:TotalNumCond
                    match = strfind(SPM.Sess(iRun).U(iCond).name{1},ConditionName{iCondTotal}); %need to adjust for parametric PPI
                    if (~isempty(match))
                        %weights(iCond) = fullweights(iCondTotal);
                        if (fullweights(iCondTotal)~=0)
                            CondPresent(iCondTotal) = iCond;
                        else
                            CondPresent(iCondTotal) = -iCond;
                        end
                        weights(iCond,:) = [iCond 1 fullweights(iCondTotal)];
                    end
                end
            end
            
            CondPresent(find(fullweights==0)) = -1;
            CondPresent(find(CondPresent<0)) = [];
            
            job.spm.stats.ppi.spmmat = {SPMmat};
            job.spm.stats.ppi.type.ppi.voi = {['VOI_' outputname '_' int2str(iRun) '.mat']};
            job.spm.stats.ppi.disp = 0;
            regressors = [];
            switch (lower(PPIType))
                case 'standard'
                    %setup PPI extract batch for standard mode
                    pos = sum(weights(:,3)>0);
                    neg = sum(weights(:,3)<0);
                    if (pos == 0)
                        mc_Error(sprintf('A standard PPI cannot be calculated with only negative conditions in a run.\nPlease check run %d for subject %s.',iRun,Subject));
                    elseif (neg == 0)
                        mc_Error(spritnf('A standard PPI cannot be calculated with only positive conditions in a run.\nPlease check run %d for subject %s.',iRun,Subject));
                    end
                    job.spm.stats.ppi.type.ppi.u = weights;
                    job.spm.stats.ppi.name = [outputname '_' int2str(iRun)];
                    mb{1} = job;
                    spm_jobman('run',mb);
                    %load in PPI file and write out to CSV
                    ppi = load(fullfile(SubjFolder,['PPI_' outputname '_' int2str(iRun) '.mat']));
                    regressors(:,1) = ppi.PPI.Y;
                    regressors(:,2) = ppi.PPI.P;
                    regressors(:,3) = ppi.PPI.ppi;
                    csvoutput = mc_GenPath(fullfile(ImageTemplate,[outputname '.csv']));
                    csvwrite(csvoutput,regressors);
                case 'gppi'
                    Include = find(weights(:,3));
                    for iInclude = 1:NumCond
                    %for iiInclude = 1:size(Include,1)
                        %iInclude = Include(iiInclude);
                        weights(:,3) = zeros(size(weights,1),1);
                        weights(iInclude,3) = 1;
                        job.spm.stats.ppi.type.ppi.u = weights;
                        job.spm.stats.ppi.name = [outputname '_' int2str(iRun) '_' int2str(iInclude)];
                        clear mb;
                        mb{1} = job;
                        spm_jobman('run',mb);
                        %load in PPI file and add to regressors
                        ppi = load(fullfile(SubjFolder,['PPI_' outputname '_' int2str(iRun) '_' int2str(iInclude) '.mat']));
                        %if (iInclude == Include(1))
                        if (iInclude == 1)
                            %add PPI.Y
                            regressors(:,1) = ppi.PPI.Y;
                        end
                        regressors(:,end+1) = ppi.PPI.P;
                        regressors(:,end+1) = ppi.PPI.ppi;
                    end
                    
                    %fullregressors = zeros(size(regressors,1),size(CondPresent,2)*2 + 1);
                    fullregressors = zeros(size(regressors,1),numel(find(CondPresent>=0))*2+1);
                    fullregressors(:,1) = regressors(:,1);
                    for iCond = 1:size(CondPresent,2)
                       if (CondPresent(iCond) > 0)
                          fullidx = iCond * 2;
                          presentidx = CondPresent(iCond)*2;
                          fullregressors(:,fullidx) = regressors(:,presentidx);
                          fullregressors(:,fullidx+1) = regressors(:,presentidx+1);
                       end
                    end
                    %write out regressors to CSV
                    csvoutput = mc_GenPath(fullfile(ImageTemplate,[outputname '.csv']));
                    csvwrite(csvoutput,fullregressors);
            end
        end
    end
end
