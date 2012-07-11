function l = length(x)
% Overloaded length function for file_array objects
% _______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

%
% $Id: length.m,v 1.2 2010/08/30 18:44:27 bwagner Exp $


l = max(size(x));

