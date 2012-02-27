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

global UMBatch

UMBatch = 1;

% Is spm in the path?

if exist('spm') ~= 2
  fprintf('\nFATAL ERROR, no SPM in the matlab path!!!\n');
  exit
end

% Check for SPM8

if strcmp(spm('ver'),'SPM8') == 0
  fprintf('\nFATAL ERROR, these scripts only are SPM8 specific!!!\n');
  exit
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
      exit
      return
  end
end

% Initialize the batch processing system.

fprintf('Initializing the job manager in SPM\n');

spm_jobman('initcfg');

% Turn off annoying warnings.

warning off

%
% That is all.
%
