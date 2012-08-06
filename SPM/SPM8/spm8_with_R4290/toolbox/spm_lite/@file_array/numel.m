function t = numel(obj)
% Number of simple file arrays involved.
% _______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

%
% $Id: numel.m,v 1.2 2010/08/30 18:44:27 bwagner Exp $


% Should be this, but it causes problems when accessing
% obj as a structure.
%t = prod(size(obj));

t  = numel(struct(obj));
