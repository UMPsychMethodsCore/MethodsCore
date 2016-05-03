function o = horzcat(varargin)
% Horizontal concatenation of file_array objects
% _______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

%
% $Id: horzcat.m,v 1.2 2010/08/30 18:44:27 bwagner Exp $

o    = cat(2,varargin{:});
return;

