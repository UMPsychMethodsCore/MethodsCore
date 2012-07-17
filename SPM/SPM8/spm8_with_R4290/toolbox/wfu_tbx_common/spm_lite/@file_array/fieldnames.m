function t = fieldnames(obj)
% Fieldnames of a file-array object
% _______________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

%
% $Id: fieldnames.m,v 1.2 2010/08/30 18:44:27 bwagner Exp $

t = {...
    'fname'
    'dim'
    'dtype'
    'offset'
    'scl_slope'
    'scl_inter'
};
