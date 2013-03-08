%
% Copyright Robert C. Welsh
% Ann Arbor, Michigan 2005
% 
% This is to be used with the UMBatch System for SPM2.
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
%   TemplateImage  =   image that represents the normalized space.
%                      if [], then no determination made.
%
%   UMImg2Warp     =   A {} array of image names to warp to the 
%                      standard template.
%
%   ParamImage     =   image for determining the normalization.
%
%   ObjectMask     =   image mask for warping - default is [];
%
%   Images2Write   =   image to warp.
%                      if [], then no images to write normalize.
%
% 
%        If you are needing to write alot of images out I suggest you use 
%        a command like this:
%  
%              Images2Write = spm_get('files',ImagesDir,'ravol*.img');
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


