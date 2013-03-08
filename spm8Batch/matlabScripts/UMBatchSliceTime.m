% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Robert C. Welsh
% Ann Arbor Michigan, USA
%
% March 2005-2011
% Copyright.
%
% UMBatchSliceTime
%
% A drivable routine for slice time corretion images using the 
% batch options of spm8
%
%
%  Call as :
%
%  function results = UMBatchSliceTime(Images2SliceTime,fMRI,TestFlag)
%
%  Input
% 
%     Images2SliceTime -- P x c array of file frames from NIFTI or IMG.
%                      
%     fMRI             -- structure with timing information
%
%  REQUIRED
%
%         .TR          -- repetition time       
%
%  THESE AND BELOW HAVE DEFAULTS
%
%        ( .TA          -- acqui time                  (TR-TR/nSlice) CALCUATED )
%         .SliceOrder  -- order of slice acquisition  'ascending','descending',[custom file name],[array]
%         .RefSlice    -- reference slice             'middle','first','last',[number]
%         .Prefix      -- prefix to add to the name   'a_spm8_'
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
%      P = spm_select('ExtFPList',theDir,theNIIWildCard,[inf])
%
%   where "theDir" is a pointer to the directory of interest,
%   and "theNIIildCard" is something like "theNIIWildCard = '^run*.nii'"
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

function results = UMBatchSliceTime(Images2SliceTime,fMRI,TestFlag)

global defaults
global UMBatch

% Default return

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

fprintf('Entering UMBatchWarp V2.0 SPM8 Compatible\n');

if exist('TestFlag') == 0
    TestFlag = 0;
end

if TestFlag~=0
    fprintf('\nTesting only, no work to be done\n\n');
end 

clear matlabbatch

% Start the timer.

tic;

% Setup the job.

% Grab the header information to get the number of slices.

tmpHDR = spm_vol(strtrim(Images2SliceTime(1,:)));

matlabbatch{1}.spm.temporal.st.nslices   = tmpHDR.dim(3);

matlabbatch{1}.spm.temporal.st.tr       = fMRI.TR;

% We will calculate TA for them.
% This is usually okay, if a user wants something else
% they will have to let me know - RCWelsh 2013-03-04

% if isfield(fMRI,'TA') == 0
%   fMRI.TA = fMRI.TR-fMRI.TR/matlabbatch{1}.spm.temporal.st.nslices;
% end

fMRI.TA = fMRI.TR-fMRI.TR/matlabbatch{1}.spm.temporal.st.nslices;

matlabbatch{1}.spm.temporal.st.ta       = fMRI.TA;

% Default the slice order if not specified.

if isfield(fMRI,'SliceOrder') == 0
  fMRI.SliceOrder = 'ascending';
  fprintf('Using a default of ascending acquisition\n');
end

% The option is to pass in an order, or ascending or descending or the name of a file.
% Pretty cool to allow all those otions, hopefully won't break. Will need the use 
% of double quotes on the bash command line

if isnumeric(fMRI.SliceOrder) == 0
  fMRI.SliceOrder=strtrim(fMRI.SliceOrder);
  switch lower(fMRI.SliceOrder(1))
   case 'a'
    fMRI.SliceOrder = 1:matlabbatch{1}.spm.temporal.st.nslices;
   case 'd'
    fMRI.SliceOrder = matlabbatch{1}.spm.temporal.st.nslices:-1:1;
   otherwise
    fMRI.SliceOrder = load(fMRI.SliceOrder);
  end
end

matlabbatch{1}.spm.temporal.st.so       = fMRI.SliceOrder;

% The reference slice can be "first", "last" or "middle" (default). You can also supply 
% a number, though bounded between 1 and nslice.

if isfield(fMRI,'RefSlice') == 0
  fMRI.RefSlice = 'middle';
  fprintf('Using a default of the middle slice for the reference slice.\n');
end

if isnumeric(fMRI.RefSlice) == 0
  fMRI.RefSlice = strtrim(fMRI.RefSlice);
  switch lower(fMRI.RefSlice(1))
   case 'l'   % The last.
    fMRI.RefSlice = matlabbatch{1}.spm.temporal.st.nslices;
   case 'f'   % The first.
    fMRI.RefSlice = 1;
   otherwise  % The middle
    fMRI.RefSlice = round(matlabbatch{1}.spm.temporal.st.nslices/2);
  end
else
  if fMRI.RefSlice < 1 || fMRI.RefSlice > matlabbatch{1}.spm.temporal.st.nslices
    fprintf('Invalid reference slice\n');
    return
  end
end

matlabbatch{1}.spm.temporal.st.refslice = fMRI.RefSlice;

% Default the prefix if not specified

if isfield(fMRI,'Prefix')  == 0
  fMRI.Prefix = 'a_spm8_';
end

matlabbatch{1}.spm.temporal.st.prefix   = fMRI.Prefix;

% Now make the list of images to slice time correct.

for iP = 1:size(Images2SliceTime,1)
  pScans{iP,1} = strtrim(Images2SliceTime(iP,:));
end

matlabbatch{1}.spm.temporal.st.scans{1} = pScans;

% All seems ok
if TestFlag == 1
    fprintf('Testing succesful.\n');
    results = toc;
    return
end

% Run the job.

spm_jobman('run_nogui',matlabbatch);

% Get the location where the files are located for logging.

sliceTimeDirectory = fileparts(Images2SliceTime(1,:));

% Log what we did.

UMBatchLogProcess(sliceTimeDirectory,sprintf('UMBatchSliceTime : Slice time corrected (%d) frames : %s -> %s',Images2SliceTime(1,:),fMRI.Prefix));

if size(Images2SliceTime,1) > 1
  UMBatchLogProcess(sliceTimeDirectory,sprintf('UMBatchSliceTime : though                           : %s',Images2SliceTime(end,:)));
end

% Log how we did this:

if abs(sum(diff(fMRI.SliceOrder))) == matlabbatch{1}.spm.temporal.st.nslices - 1
  if sum(diff(fMRI.SliceOrder)) < 0
    fMRI.order = 'descending';
  else
    fMRI.order = 'ascending';
  end
else
  fMRI.order = 'custom';
end

UMBatchLogProcess(sliceTimeDirectory,sprintf('UMBatchSliceTime : Using TR=%2.2f, TA=%2.2f, Ref=%d, Order:%s',fMRI.TR,fMRI.TA,fMRI.RefSlice,fMRI.order));

results = toc;

fprintf('Slice timing correctin done in %f seconds.\n\n\n',results);

return

%
% all done
%


