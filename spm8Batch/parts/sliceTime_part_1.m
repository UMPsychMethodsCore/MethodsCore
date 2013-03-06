% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Copyright Robert C. Welsh
% Ann Arbor, Michigan 2013
% 
% This is to be used with the UMBatch System for SPM8.
%
% This is to Slice Time Correct Images
%
% You must point to the batch processing code
%
%  spm8
%  spm2Batch
%
%
% You need to fill the following variables:
%
%   UMBatchMaster  =   point to the directory of the experiment.
%
%   UMBatchSubjs   =   list of subjects within experiment. Space
%                      pad if need be.
%
%   UMfMRI         =   structure with slice timing parameters
%                      see UMBatchSliceTime.m
%
%
%   UMImgDIRS      =   directory to which to find images.
%                      (full path name)
%
%   UMVolmeWild    =   wild card name for images
%                      (e.g. "ravol_*.img')
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% Make sure the UM Batch system is installed.

if exist('UMBatchPrep') ~= 2 | exist('UMBatchSliceTime') ~= 2
    fprintf('You need to have the UM Batch system\n');
    resuts = -69;
    UMCheckFailure(results);
    exit(abs(results))
end

% 
% Prepare the batch processes
%

results = UMBatchPrep;

if UMCheckFailure(results)
  exit(abs(results))
end

% --------------- END OF PART I ----------------------
