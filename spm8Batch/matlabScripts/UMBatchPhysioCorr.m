% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Robert C. Welsh
% Ann Arbor Michigan, USA
%
% October 2011
% Copyright.
%
% UMBatchPhysioCorr
%
% A drivable routine for physio correcting time series images using the 
% batch options of spm8
%
%  Call as :
%
   %  function results = UMBatchPhysioCorr(UMBatchMaster,UMSubjectDir,UMSubject,UMFuncDir,UMRunList,UMVolumeWILD,UMOutName,UMPhysioTable,UMrate,UMdown,UMqualitycheck)
%
%  To Make this work you need to provide the following input:
%
%     UMBatchMaster  = master directory of the experiment
%      
%
%  Output
%  
%     results        = -1 if failure
%                       # of seconds to execute.
%
%
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

function results = UMBatchPhysioCorr(UMBatchMaster,UMSubjectDir,UMSubject,UMFuncDir,UMRunList,UMVolumeWILD,UMOutName,UMPhysioTable,UMrate,UMdown,UMdisdaq,UMfMRITR,TestFlag,UMqualitycheck);

global defaults

PHILIPS='philips';

%
% Set the return status to -1, that is error by default.
%

results = -1;

fprintf('Entering UMBatchPhysioCorr V1.0\n');

tic;

if TestFlag~=0
    fprintf('\nTesting only, no work to be done\n\n');
    return
end 

cd(UMBatchMaster);
cd(UMSubjectDir);
cd(UMSubject);
if (~strcmp(UMFuncDir,''))
    cd(UMFuncDir);
end

functionalDIR = pwd;

[physioDIR physioFILE physioEXT] = fileparts(fullfile(functionalDIR,UMPhysioTable));

% Get rid of any "../.." in the path, just to clean it up.

cd(physioDIR)
physioDIR=pwd;

%Parse the runlist

if (strcmp(UMRunList,'ALLRUNS'))
    targetruns{1}=-1; %set targetruns to -1 as a flag to do all runs
else
    targetruns=regexp(UMRunList,'[0-9]+','match'); %parse the UMRunList object
    % Force all run number strings to be 2-digit number as a string
    % - RCWelsh 2012-02-09
    for i=1:length(targetruns)
      targetruns{i} = sprintf('%02d',str2num(targetruns{i}));
    end
      %if(length(targetruns{i})==1) %add leading 0's to single digit targetrun objects
      %      targetruns{i}=['0' targetruns{i}];
      %  end
end


cd(functionalDIR);

if exist(fullfile(physioDIR,[physioFILE physioEXT])) == 0
  fprintf('\n');
  fprintf('* * * * FATAL ERROR * * * * \n');
  fprintf('Can''t find file : %s\n',fullfile(physioDIR,[physioFILE physioEXT]));
  fprintf('\n');
  fprintf('ABORTING\n\n');
  results = -1
  return
end

physiolog = textread(fullfile(physioDIR,[physioFILE physioEXT]),'%s');

physioInfo = {};
nRUNS = -1;
runINFO = [];

for iLOG = 1:length(physiolog)
  yRUN = 0;
  if length(physiolog{iLOG}) == 6
    if strcmp(physiolog{iLOG}(1:4),'run_') 
      nRUNS = nRUNS + 1;
      yRUN = 1;
    end
  end
  if yRUN == 1
    if length(runINFO) > 0
      physioInfo{nRUNS} = runINFO;
    end
    runINFO = physiolog{iLOG};
  else
    runINFO = strvcat(runINFO,physiolog{iLOG});
  end
end

if yRUN == 0
    nRUNS = nRUNS + 1;
    physioInfo{nRUNS} = runINFO;
end

%Prune the objects in physio.log to correspond with indicated runs, if
%targeting certain runs
newphysioInfo=[];
if(targetruns{1}~=-1)
    for i=1:length(physioInfo) %Loop over physioInfo, only retain those that are in targetruns
        if(sum(cell2mat(regexp(physioInfo{i}(1,:),targetruns)))>0)
            newphysioInfo{end+1}=physioInfo{i};
        end
    end
    physioInfo=newphysioInfo;
    nRUNS=length(physioInfo); %update nRUNS based on the pruned list
    if(length(physioInfo)==0)
      fprintf('* * * * FATAL ERROR * * * * \n');
      fprintf(['No runs available for preprocessing for this subject'])
      fprintf('ABORTING\n\n');
      return
    end
end

%Check to ensure that the same run is not specified twice. More of a safeguard against typos

pRUNFOUND = zeros(nRUNS,1) ;

for iRUN = 1:nRUNS
    for jRUN = 1:nRUNS
        if strcmp(strtrim(physioInfo{iRUN}(1,:)),strtrim(physioInfo{jRUN}(1,:)))
            pRUNFOUND(iRUN) = pRUNFOUND(iRUN) + 1 ;
        end
    end
end

if sum(pRUNFOUND) ~= nRUNS
    fprintf('Some runs may be specified more than once in the physio log file. Are you sure you haven''t made a typo?\n')
    fprintf('ABORTING\n\n');  
    return
end


NPHYSPERRUN = [];

fprintf('\nPhysio correction files by run:\n');

for iRUN = 1:nRUNS
  for iLINE = 1:size(physioInfo{iRUN},1)
    fprintf('%s ',strtrim(physioInfo{iRUN}(iLINE,:)));
  end
  NPHYSPERRUN = [NPHYSPERRUN size(physioInfo{iRUN},1)];
  fprintf('\n');
end

fprintf('\n');

% make sure that the number of physio files per run is the same as we won't
% know what to do if different.

if any(NPHYSPERRUN - NPHYSPERRUN(1))
  fprintf('* * * * FATAL ERROR * * * * \n');
  fprintf('Different phys log files per run, not programmed for that!\n');
  fprintf('ABORTING\n\n');
  return
end

% If two phys files per then we have to assume that one is the cardiac and
% the other is the respiration, else we assume that it's a philips physio
% log file.

if NPHYSPERRUN(1) == 2
    physioTYPE=PHILIPS;
else
    physioTYPE='ge';
end

% Now make sure these files exist!

for iRUN = 1:nRUNS
  for iLINE = 2:size(physioInfo{iRUN},1)
    if exist(fullfile(physioDIR,strtrim(physioInfo{iRUN}(iLINE,:)))) == 0
      fprintf('* * * * FATAL ERROR * * * * \n');
      fprintf('Can''t find physio file %s in %s\n',strtrim(physioInfo{iRUN}(iLINE,:)),physioDIR);
      fprintf('ABORTING\n\n');  
      return
    end
  end
end

% Now go back to the functional directory

cd (functionalDIR);

RUNDIRS = dir('run_*');



% Now see if the names match up? and that run_* is a directory.

RUNFOUND = zeros(nRUNS,1);

for iRUN = 1:nRUNS
  for jRUN = 1:length(RUNDIRS)
    if strcmp(strtrim(physioInfo{iRUN}(1,:)),strtrim(RUNDIRS(jRUN).name)) & RUNDIRS(jRUN).isdir
      RUNFOUND(iRUN) = 1;
    end
  end
end

if sum(RUNFOUND) ~= nRUNS
  fprintf('I can''t match the runs found in the physio log %s and those found in the directory %s\n',physioFILE,UMFuncDir)
  fprintf('ABORTING\n\n');  
  return
end
   
%
% Ok, so far so good. Now we make sure there is a run in each targeted run directory.
% 

for iRUN = 1:length(physioInfo)
    try
        cd (strtrim(physioInfo{iRUN}(1,:)))
        RUNFILE=dir([UMVolumeWILD '*.nii']);
        if length(RUNFILE) ~= 1
            fprintf('Too many or too few run files (%d) found in %s\n',length(RUNFILE),RUNDIRS(iRUN).name);
            fprintf('ABORTING\n\n');
            return
        end
        cd (functionalDIR)
    catch
        fprintf('Name issue with %s, not a directory.\n',physioInfo{iRUN}(1,:));
        fprintf('ABORTING\n\n');
        return
    end
end

%
% All in line now.
%

for iRUN = 1:nRUNS
  fprintf('Working on run directory : %s\n',strtrim(physioInfo{iRUN}(1,:)));
  physOk = -1;
  physioDatFILE = fullfile(physioDIR,[strtrim(physioInfo{iRUN}(1,:)) '_physio.dat']);
  %
  % Now do we have philips or GE data, based on the number of
  % physio files per run. 1 means philips, 2 is GE.
  %
  if strcmp(physioTYPE,PHILIPS)
    [physData physOk philipsData] = convertPhilipsPhysio(fullfile(physioDIR,strtrim(physioInfo{iRUN}(2,:))),UMrate,UMdown);
    if physOk ~= 1
      fprintf('Error converting %s\n',fullfile(physioDIR,strtrim(physioInfo{iRUN}(2,:))));
      fprintf('ABORTING\n\n');
      return
    end
  else
    [physData physOk] = convertGEPhysio(fullfile(physioDIR,strtrim(physioInfo{iRUN}(2,:))),fullfile(physioDIR,strtrim(physioInfo{iRUN}(3,:))),UMrate);
    if physOk ~= 1
      fprintf('Error converting %s\n',fullfile(physioDIR,strtrim(physioInfo{iRUN}(2,:))));
      fprintf('ABORTING\n\n');
      return
    end
  end
  % Save to ascii file.
  save(physioDatFILE,'physData','-ascii');
  % Now make the physio for the regression removal.
  physioMATFILE = fullfile(physioDIR,[strtrim(physioInfo{iRUN}(1,:)) '_physio.mat']);
  cd(functionalDIR)
  cd(strtrim(physioInfo{iRUN}(1,:)))
  % We need to get the number of slices.
  NIFTIRUNFILE = dir([UMVolumeWILD '*.nii']);
  NIFTIDATA    = nifti(NIFTIRUNFILE.name);
  nSLICE       = NIFTIDATA.dat.dim(3);
  fprintf('Correcting run file : %s\n', NIFTIRUNFILE.name);
  fprintf('           found in : %s\n',[functionalDIR '/' strtrim(physioInfo{iRUN}(1,:))]);
  fprintf('               with : %s\n',physioInfo{iRUN}(2,:));
  if size(physioInfo{iRUN},1) == 3
    fprintf('                    : %s\n',physioInfo{iRUN}(3,:));
  end
  % Now make the physio regressors.
  if strcmp(physioTYPE,PHILIPS)      
    PhysioMat = mkPhysioMatPhilips(physioDatFILE, UMrate*UMdown, UMdisdaq, nSLICE, UMfMRITR, physioMATFILE);
  else
    PhysioMat = mkPhysioMatGE(physioDatFILE, UMrate, UMdisdaq, nSLICE, UMfMRITR, physioMATFILE);
  end     
  if ~exist('UMqualitycheck','var') || UMqualitycheck==0
  results = rmReg_nii(NIFTIRUNFILE.name, [UMOutName NIFTIRUNFILE.name], PhysioMat);
  % Now log it.
  PhysioCorrectionDirectory=fileparts(NIFTIRUNFILE.name);
  UMBatchLogProcess(PhysioCorrectionDirectory,sprintf('UMBatchPhysioCorr : Corrected file : %s',NIFTIRUNFILE.name))
  else
  results = 0; % if you've made it this far, and didn't make pruns, you're good
  end
end

% All finished

results = toc;

fprintf('\nPhysio correction done in %f seconds.\n\n\n',results);

%
% All done

