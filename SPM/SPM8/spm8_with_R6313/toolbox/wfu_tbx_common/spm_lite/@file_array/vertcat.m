function o = vertcat(varargin)
% Vertical concatenation of file_array objects.
% _______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

%
% $Id: vertcat.m,v 1.2 2010/08/30 18:44:27 bwagner Exp $


o = cat(1,varargin{:});
return;
