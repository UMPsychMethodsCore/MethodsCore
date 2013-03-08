% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Robert C. Welsh
% Ann Arbor Michigan, USA
%
% March 2005
% Copyright.
%
% UMBatchSegment
%
% A drivable routine for warping some images using the 
% batch options of spm8.
%
% Version 2.0
%
% 
%  Call as :
%
%  function results = UMBatchSegment(Image2Segment);
%
%  To Make this work you need to provide the following input:
%
%  Input
%
%    Image2Segment - name of the image to segment.
%
%  Output
%  
%     results        = -1 if failure
%                       # of seconds to execute.
%
%  If you wish to use any normalization parameters other than the default
%  you must set them yourself!
%
%  You should make call to UMBatchPrep first.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

function results = UMBatchSegment(Image2Segment,TestFlag,NormedAlready);

global defaults
global UMBatch

results = -1;

% Start the timer.

tic;

% Make the call to prepare the system for batch processing.

UMBatchPrep

if UMBatch == 0
  fprintf('UMBatchPrep failed.')
  return
end

% Only proceed if successful.

fprintf('Entering UMBatchSegment V0.1\n');

if TestFlag~=0
  fprintf('\nTesting only, no work to be done\n\n');    
  fprintf('\Would be segmenting the image %s\n',Image2Segment);
else
  if exist('NormedAlready') == 0
    NormedAlready = 0;
  end
  
  if NormedAlready ~=0 | NormedAlready ~= 1
    NormedAlready = 1;
  end
  
  %
  % Set the return status to -1, that is error by default.
  %
    
  warning off
    
  matlabbatch{1}.spm.spatial.preproc.data{1} = [deblank(Image2Segment) ',1'];
  
  matlabbatch{1}.spm.spatial.preproc.output.GM  = [0 0 1];
  matlabbatch{1}.spm.spatial.preproc.output.WM  = [0 0 1];
  matlabbatch{1}.spm.spatial.preproc.output.CSF = [0 0 1];
  
  matlabbatch{1}.spm.spatial.preproc.output.biascor = 1;
  matlabbatch{1}.spm.spatial.preproc.output.cleanup = 0;
  
  matlabbatch{1}.spm.spatial.preproc.opts = defaults.preproc;
  
  spm_jobman('run_nogui',matlabbatch);
      
  results = toc;

  fprintf('Segmenting finished in %f seconds\n',results);

end

return

%
% All done.
%
