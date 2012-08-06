function flip = spm_flip_analyze_images
% Do Analyze format images need to be left-right flipped? The default
% behaviour is to have the indices of the voxels stored as left-handed and
% interpret the mm coordinates within a right-handed coordinate system.
%
% Note: the behaviour used to be set in spm_defaults.m, but this has now
% been changed.
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% John Ashburner
% $Id: spm_flip_analyze_images.m,v 1.2 2010/08/30 18:44:21 bwagner Exp $

flip = 1;

