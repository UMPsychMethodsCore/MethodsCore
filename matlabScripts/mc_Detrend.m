function result = mc_Detrend(Images,Order)
% A utility function to apply a detrending to an input image (or series of
% images)
%
% FORMAT result = mc_Detrend(Images,[Order])
%
% Images                 A string containing the fully qualified filename
%                        of the image to detrend OR a cell array of strings
%                        containing the fully qualified filenames of each
%                        timepoint.
%
% Order                  An optional argument to specify the order of the
%                        polynomial to remove. The default if not provided 
%                        is 1.
%
% result                 1 if successful, 0 if there was an error.
%

result = 1;

if (~exist('Order','var') | isempty(Order))
    Order = 1;
end

if (~iscell(Images))
    % check if Images is a string
    
    % check if Images exists
    
    % load Images into data matrix
else
    % check if Images elements exist
    
    % load Images into data matrix
end

y = spm_detrend(x,Order);

%write out detrended images
if (~iscell(Images))
    %write out a single 4D Nifti image
    
else
    %write out a series of img/hdr pairs
    
end

return;

