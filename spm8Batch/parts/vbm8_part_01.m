%
% Copyright Robert C. Welsh
% Ann Arbor, Michigan 2005
% 
% This is to be used with the UMBatch System for SPM8.
%
% To Warp image  using batch use the following code.
%

% You must point to the batch processing code
%
%  addpath /net/dysthymia/spm8Batch
%

% You need to fill the following variables:
%
%   UMBatchMaster  =   point to the directory of the experiment.
%
%   ParamImage     =   image for determining the normalization.
%
%   UMBatchSubjs   =   list of subjects within experiment. Space
%                      pad if need be.
%


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% Make sure the UM Batch system is installed.

if exist('UMBatchPrep') ~= 2 | exist('UMBatchVBM8') ~= 2
    fprintf('You need to have the UM Batch system\n');
    return
end

% 
% Prepare the batch processes
%

UMBatchPrep

% - - - - - - - END OF PART I - - - - - - - - - - - - - - - - -


