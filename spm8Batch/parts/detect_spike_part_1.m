% 
% This is to be used with SPM8.
%
% To detect spikes in a run using batch use the following code.
%

% You must point to the batch processing code
%
%  addpath /net/dysthymia/spm8Batch
%

% You need to fill the following variables:
%
%   UMBatchMaster  =   point to the directory of the experiment.
%
%   Images         =   char array of images in a run
%
%   OutputFile     =   results of spike detection is writeen here
%
%   Subject        =   subject name
%
%   Run            =   run name
%
% 
%        If you are needing to write alot of images out I suggest you use 
%        a command like this:
%  
%              Images = spm_select('files',ImagesDir,'ravol*.img');
%
%        where "ImagesDir" is the directory where the images live. You can of 
%        course put a loop around to write normalize each run seperately etc.
%
%   UMBatchSubjs   =   list of subjects within experiment. Space
%                      pad if need be.
%


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% Make sure the UM Batch system is installed.

if exist('UMBatchPrep') ~= 2 | exist('UMBatchWarp') ~= 2
    fprintf('You need to have the UM Batch system\n');
    return
end

% 
% Prepare the batch processes
%

UMBatchPrep

% - - - - - - - END OF PART I - - - - - - - - - - - - - - - - -


