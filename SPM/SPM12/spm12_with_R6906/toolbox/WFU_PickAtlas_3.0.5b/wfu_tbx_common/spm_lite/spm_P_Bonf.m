function P = spm_P_Bonf(Z,df,STAT,S,n)
% Returns the corrected P value using Bonferroni
% FORMAT P = spm_P_Bonf(Z,df,STAT,S,n)
%
% Z     - height {minium over n values}
% df    - [df{interest} df{error}]
% STAT  - Statistical field
%       'Z' - Gaussian field
%       'T' - T - field
%       'X' - Chi squared field
%       'F' - F - field
% n     - number of conjoint SPMs
% S     - Voxel count
%
% P     - corrected   P value  - P(STAT > Z)
%
%___________________________________________________________________________
%
% spm_P_Bonf returns the p-value of Z corrected by the Bonferroni
% inequality. 
%
% If n > 1 a conjunction probility over the n values of the statistic
% is returned
%
%___________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging

% Thomas Nichols
% $Id: spm_P_Bonf.m,v 1.2 2010/08/30 18:44:18 bwagner Exp $


if      STAT == 'Z'
  P = 1 - spm_Ncdf(Z);
elseif  STAT == 'T'
  P = 1 - spm_Tcdf(Z,df(2));
elseif  STAT == 'X'
  P = 1 - spm_Xcdf(Z,df(2));
elseif  STAT == 'F'
  P = 1 - spm_Fcdf(Z,df);
end

P = S*P.^n;
P = min(P,1);
