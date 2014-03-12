% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Copyright Robert C. Welsh
% Ann Arbor, Michigan 2013
% 
% This is to be used with the UMBatch System for SPM8.
%
%
%
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% Make sure the UM Batch system is installed.

if exist('UMBatchPrep') ~= 2 | exist('UMBatchPrinComp') ~= 2 | exist('UMBatchPCA') ~= 2
    fprintf('You need to have the UM Batch system\n');
    return
end

% 
% Prepare the batch processes
%

results = UMBatchPrep;

if UMCheckFailure(results)
  exit(abs(results));
end


% - - - - - - - END OF PART I - - - - - - - - - - - - - - - - -


