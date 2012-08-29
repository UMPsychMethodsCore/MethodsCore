%
% Copyright Robert C. Welsh
% Ann Arbor, Michigan 2005
% 
% This is to be used with the UMBatch System for SPM2.
%
% This is to SMOOTH IMAGES.

% You must point to the batch processing code
%
%  addpath /net/dysthymia/spm2
%  addpath /net/dysthymia/spm2Batch
%

% You need to fill the following variables:
%
%   UMBatchMaster  =   point to the directory of the experiment.
%
%   UMBatchSubjs   =   list of subjects within experiment. Space
%                      pad if need be.
%
%   UMKernel       =   smoothing kernel, either a scalar or a
%                      3-vector (e.g. 5 or [5 6 6])
%
%   UMImgDIRS      =   directory to which to find images.
%                      (full path name)
%
%   UMImgWildCard  =   wild card name for images
%                      (e.g. "ravol_*.img')

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% Make sure the UM Batch system is installed.

if exist('UMBatchPrep') ~= 2 | exist('UMBatchCoReg') ~= 2
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
