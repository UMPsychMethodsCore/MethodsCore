% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Robert C. Welsh
% Ann Arbor Michigan, USA
%
% March 2012
% Copyright.
%
% UMBatchRecon
%
%  This provides an interface to sprec1 (D. Noll). At the moment a standard set of parameters 
%  used
%    
%     1) The field map is reconstructed using : pfile, 'm', 'l', 'fy', 'n', ['64']
%     2) Times series is reconstructed using  : pfile, 'h', 'l', 'fy', 'n', ['64'], 'N'
%
%  Input
% 
%     UMBatchMaster      - Master directory
%     UMSubjDir          - Subject directory that contains the subjects.
%     UMBatchSubject     - Current subject to process.
%     UMfmriPATH         - functional task directory.
%     UMPfile            - pfile name to use (all pfiles matching will be used sequentially)
%     UMReconRunNo       - run number to start assigning runs.
%     UMMatrixSize       - reconstruction matrix size.
%     UMTestFlag         - 0 means to proceed
%                          1 means to no proceeed.
%  Output
%  
%     results        < -1 if failure
%                    >  0  then # of seconds to execute.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

function results = UMBatchRecon(UMBatchMaster,UMSubjDir,UMBatchSubject,UMfmriPATH,UMPfile,UMReconRunNo,UMMatrixSize,UMTestFlag)

%

global UMBatch

%
% Set the return status to -1, that is error by default.
%

results = -1;

% Make the call to prepare the system for batch processing.

UMBatchPrep

if UMBatch == 0
  fprintf('UMBatchPrep failed.')
  results = -70;
  UMCheckFailure(results);
  return
end

% Only proceed if successful.

fprintf('Entering UMBatchRecon v 1.0\n');

if UMTestFlag~=0
    fprintf('\nTesting only, no work to be done\n\n');
end 

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% 
% Make sure that the images exist that have been passed.
%

% Set the CPU timer.

cpuStart = cputime;

% Now get into the subject

CURSUBJDIR=fullfile(UMBatchMaster,UMSubjDir,UMBatchSubject,UMfmriPATH);

try
  cd(CURSUBJDIR);
catch
  fprintf('Major abort, can''t get into the directory:%s\n    %s\n',CURSUBJDIR);
  results = -65;
  UMCheckFailure(results);
  return
end

% Okay, it seems as though the subject is still there.

try
  PFILELIST = dir(UMPfile);
catch
  fprintf('Major abort, something happend while look for pfiles (%s) in directory:%s\n    %s\n',UMPfile,CURSUBJDIR);
  results = -65;
  UMCheckFailure(results);
  return
end
 
% Okay we now hava list of files.

fprintf('Working on subject/task : %s\n\n',CURSUBJDIR);

for iPfile = 1:length(PFILELIST)
  currentRunNumber = (iPfile-1)+UMReconRunNo;
  % We need to make the directory where this will head
  RUNDIRNAME=sprintf('run_%02d',currentRunNumber);
  [MKSUCCESS MSMSG] = mkdir(RUNDIRNAME);
  if MKSUCCESS == 0
    fprintf('Major abort, can''t create %s\n    %s\n',RUNDIRNAME);
    results = -74;
    UMCheckFailure(results);
    return
  end
  cd(RUNDIRNAME)
  % Now do the first part of the recon
  % 
  % gspmat01.csh $pfile m l  fy n $reconsize 
  %
  if UMTestFlag == 0    
    fprintf('    Reconstructing field map for run %d using %s\n',currentRunNumber,PFILELIST(iPfile).name);
    try
      sprec1(fullfile(CURSUBJDIR,PFILELIST(iPfile).name),'m','l','fy','n',sprintf('%d',UMMatrixSize));
    catch
      fprintf('Field map reconstruction failed! Aborting!\n');
      results = -70;
      UMCheckFailure(results);
      return
    end
    
    % Now do the second part of the recon
    % 
    % gspmat01.csh $pfile h l  fy n $reconsize N
    %
    fprintf('   Reconstructing image data for run %d using %s\n',currentRunNumber,PFILELIST(iPfile).name);
    try
      sprecFileName=sprec1(fullfile(CURSUBJDIR,PFILELIST(iPfile).name),'h','l','fy','n',sprintf('%d',UMMatrixSize),'N');
    catch
      fprintf('Time-series reconstruction failed! Aborting!\n');
      results = -70;
      UMCheckFailure(results);
      return
    end
    %
    % So far all is okay.
    % so we need to rename the file.
    %
    sprecFileName=[sprecFileName '.nii'];
    niftiRunFileName=sprintf('run_%02d.nii',currentRunNumber);
    [MVSUCCESS] = movefile(sprecFileName,niftiRunFileName,'f');
    if MVSUCCESS==0
      fprintf('ABORT -- CAN''T change the name of %s to %s\n',sprecFileName,niftiRunFileName);
      results = -74;
      UMCheckFailure(results);
      return
    else
      fprintf('   run file is : %s\n',niftiRunFileName);
    end
    % all done.
  else
    fprintf('Skipping reconstruction due to testing of code.\n');
  end
  cd(CURSUBJDIR)
end

%
% Set the flag to success. We return the total time of processing.
%

results = cputime;

fprintf('Recon done in %f seconds\n',results-cpuStart);

return

%
% All done.
%
