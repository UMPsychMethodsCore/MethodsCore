% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Robert C. Welsh
% Ann Arbor Michigan, USA
%
% March 2005-2011
% Copyright.
%
% This should be included in ALL batch processing.
%
% Is is an inline piece of code.
%

% Turn off progress bar.

function UMBatchPrep

global UMBatch
global UMBatchInit

% Success code.

UMBatch = 1;

% Is spm in the path?

if exist('spm') ~= 2
  fprintf('\nFATAL ERROR, no SPM in the matlab path!!!\n');
  UMBatch = 0;
  return
end

% Check for SPM8

if strcmp(spm('ver'),'SPM8') == 0
  fprintf('\nFATAL ERROR, these scripts only are SPM8 specific!!!\n');
  UMBatch = 0;
  return
end

% Make sure spm_defaults has been called.

global defaults

if isempty(defaults)
  spm('defaults','fmri')
  global defaults
  %
  % Now see if it worked.
  %
  if isempty(defaults)
      fprintf('\n\n* * * * * \nAre you not running SPM8?\n\n* * * * * \n\n');
      fprintf('        A B O R T I N G\n\n');
      UMBatch = 0;
      return
  end
end

% Initialize the batch processing system.

if isempty(UMBatchInit)
  fprintf('Initializing the job manager in SPM8\n');
  spm_jobman('initcfg');
  UMBatchInit = 1;
end

% Turn off annoying warnings.

warning off

return

%
% That is all.
%
