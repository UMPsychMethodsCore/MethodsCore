function disp(obj)
% Disp a NIFTI-1 object
% _______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

%
% $Id: disp.m,v 1.2 2010/08/30 18:44:28 bwagner Exp $


sz = size(obj);
fprintf('NIFTI object: ');
if length(sz)>4,
    fprintf('%d-D\n',length(sz));
else
    for i=1:(length(sz)-1),
        fprintf('%d-by-',sz(i));
    end;
    fprintf('%d\n',sz(end));
end;
if prod(sz)==1,
    display(structn(obj))
end;
return;
