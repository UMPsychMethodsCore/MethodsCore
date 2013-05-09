%
% Copyright Robert C. Welsh
% Ann Arbor, Michigan 2005
% 
% This is to be used with the UMBatch System for SPM2.
%
% To CoRegister Image together using batch use the following code.
%

% You must point to the batch processing code
%
%  addpath /net/dysthymia/spm8
%  addpath /net/dysthymia/spm8Batch
%

% You need to fill the following variables:
%
%   UMBatchMaster  =   point to the directory of the experiment.
%
%   UMImgPairs     =   {}{} array subject x image pairs.
%                       first images is Object, second is target.
%
%   UMBatchSubjs   =   list of subjects within experiment. Space
%                      pad if need be.
%
%   UMReSlice      =   0 -> don't reslice the image.
%                      1 -> reslice the image.
%                      2 -> reslice w/o coreg NOT IMPLEMENTED YET!

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% Make sure the UM Batch system is installed.

if exist('UMBatchPrep') ~= 2 | exist('UMBatchCoReg') ~= 2
    fprintf('You need to have the UM Batch system\n');
    results = -69;
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

% - - - - - - - - - - END OF PART I - - - - - - - - - - - - -
