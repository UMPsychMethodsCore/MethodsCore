function en = end(a,k,n)
% Overloaded end function for file_array objects.
% _______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

%
% $Id: end.m,v 1.2 2010/08/30 18:44:26 bwagner Exp $

dim = size(a);
if k>length(dim)
    en = 1;
else
    if n<length(dim),
    dim = [dim(1:(n-1)) prod(dim(n:end))];
    end;
    en = dim(k);
end;
