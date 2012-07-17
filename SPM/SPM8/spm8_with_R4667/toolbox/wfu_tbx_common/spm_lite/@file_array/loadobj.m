function b = loadobj(a)
% loadobj for file_array class
% _______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

%
% $Id: loadobj.m,v 1.2 2010/08/30 18:44:27 bwagner Exp $

if isa(a,'file_array')
    b = a;
else
    a = permission(a, 'rw');
    b = file_array(a);
end