function out = ndims(fa)
% Number of dimensions
%_______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

%
% $Id: ndims.m,v 1.2 2010/08/30 18:44:27 bwagner Exp $


out = size(fa);
out = length(out);

