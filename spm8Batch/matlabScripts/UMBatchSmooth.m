% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Robert C. Welsh
% Ann Arbor Michigan, USA
%
% March 2005-2011
% Copyright.
%
% UMBatchSmooth
%
% A drivable routine for smoothing some images using the 
% batch options of spm8
%
%  Call as :
%
%  function results = UMBatchSmooth(Images2Smooth,sKernel,TestFlag);
%
%  To Make this work you need to provide the following input:
%
%     Images2Smooth   = Full Path and Name to the Target Image.
%     sKernel         = Smoothing Kernel (1 or 3 #'s); [mm]
%     TestFlag        = Flag to test file existance but do nothing.
%
%  Output
%  
%     results        = -1 if failure
%                       # of seconds to execute.
%
%
% Hint:
% 
%   To get the list of files to smooth try something like
%
%      P = spm_get('files',theDir,theImgWildCard)
%
%   where "theDir" is a pointer to the directory of interest,
%   and "theImgWildCard" is something like "theImgWildCard = 'ravol*.img'"
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

function results = UMBatchSmooth(Images2Smooth,sKernel,OutputName,TestFlag);

global defaults
global UMBatch

%
% Set the return status to -1, that is error by default.
%

results = -1;

% Make the call to prepare the system for batch processing.

UMBatchPrep;

if UMBatch == 0
  fprintf('UMBatchPrep failed.')
  results = -70;
  UMCheckFailure(results);
  return
end

% Only proceed if successful.

fprintf('Entering UMBatchSmooth V1.1\n');

if TestFlag~=0
    fprintf('\nTesting only, no work to be done\n\n');
end 

% 
% Make sure that the images exist that have been passed.
%

tic;

if isempty(Images2Smooth) 
    fprintf('You must specify some images to smooth.\n');
    fprintf('  * * * A B O R T I N G * * *\n\n');
    results = -65;
    UMCheckFailure(results);
    return
end

errorFlag = 0;

for iFiles = 1:size(Images2Smooth,1)
  tmpFile=Images2Smooth(iFiles,:);
  commaIDX = findstr(',',tmpFile);
  if ~isempty(commaIDX)
    tmpFile = tmpFile(1:commaIDX(1)-1);
  end
  if exist(tmpFile) ~= 2
    errorFlag = 1;
  end
end

if errorFlag ~= 0
  fprintf('One of the images does not exist.\n');
  fprintf('  * * * A B O R T I N G * * *\n\n');
  results = -65;
  UMCheckFailure(results);
  return
end

% Make sure they specified a smoothing size.

if isempty(sKernel)
    fprintf('You have not specified a smoothing kernel.\n');
    fprintf('  * * * A B O R T I N G * * *\n\n');
    results = -64;
    UMCheckFailure(results);
    return
end

if length(sKernel) ~= 1 & length(sKernel) ~= 3
    fprintf('You have specified a weird # of smoothing sizes: %d\n',length(sKernel));
    fprintf('  * * * A B O R T I N G * * *\n\n');
    results = -64;
    UMCheckFailure(results);
    return
end

if length(sKernel) == 1
    sKernel = [sKernel sKernel sKernel];
end

% All seems ok.

if TestFlag 
    fprintf('Testing, all files exist.\n');
    results = toc;
    return
end

matlabbatch{1}.spm.spatial.smooth.data   = {};

for iP = 1:size(Images2Smooth,1)
  matlabbatch{1}.spm.spatial.smooth.data{iP,1} = strtrim(Images2Smooth(iP,:));
end

matlabbatch{1}.spm.spatial.smooth.fwhm   = sKernel;
matlabbatch{1}.spm.spatial.smooth.dtype  = 0;
matlabbatch{1}.spm.spatial.smooth.im     = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = OutputName;

spm_jobman('run_nogui',matlabbatch);

% Log the smoothing to the local target directory.

SmoothingDirectory = fileparts(Images2Smooth(1,:));

UMBatchLogProcess(SmoothingDirectory,sprintf('UMBatchSmooth : Smoothed images (%04d) : %s -> %s',size(Images2Smooth,1),Images2Smooth(1,:),OutputName));

if size(Images2Smooth,1) > 1
  UMBatchLogProcess(SmoothingDirectory,sprintf('UMBatchSmooth : through image          : %s',Images2Smooth(end,:)));
end

% All finished

results = toc;
fprintf('Smoothing done in %f seconds.\n\n\n',results);

return

%
% All done
%
