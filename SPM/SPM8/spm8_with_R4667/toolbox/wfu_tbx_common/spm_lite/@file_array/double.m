function out = double(fa)
% Convert to double precision
% FORMAT double(fa)
% fa - a file_array
% _______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

%
% $Id: double.m,v 1.2 2010/08/30 18:44:26 bwagner Exp $

out = double(numeric(fa));

