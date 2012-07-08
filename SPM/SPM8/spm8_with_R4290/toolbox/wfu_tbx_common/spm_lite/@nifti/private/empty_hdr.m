function hdr = empty_hdr
% Create an empty NIFTI-1 header
% FORMAT hdr = empty_hdr
% _______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

%
% $Id: empty_hdr.m,v 1.2 2010/08/30 18:44:29 bwagner Exp $


org = niftistruc;
for i=1:length(org),
    hdr.(org(i).label) = org(i).def;
end;

