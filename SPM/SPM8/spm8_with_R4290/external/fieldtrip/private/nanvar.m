% nanvar() - var, not considering NaN values
%
% Usage: same as var()

% Author: Arnaud Delorme, CNL / Salk Institute, Sept 2003

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2003 Arnaud Delorme, Salk Institute, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% This file is part of FieldTrip, see http://www.ru.nl/neuroimaging/fieldtrip
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id: nanvar.m 2885 2011-02-16 09:41:58Z roboos $

function out = nanvar(in, varargin)
   
if nargin < 1
  help nanvar;
  return;
end
if nargin == 1, flag = 0; end
if nargin <  3,
  if size(in,1) ~= 1
    dim = 1;
  elseif size(in,2) ~= 1 
    dim = 2; 
  else
    dim = 3;
  end
end
if nargin == 2, flag = varargin{1}; end
if nargin == 3,
  flag = varargin{1};
  dim  = varargin{2};
end
if isempty(flag), flag = 0; end

nans = find(isnan(in));
in(nans) = 0;
   
nonnans = ones(size(in));
nonnans(nans) = 0;
nonnans = sum(nonnans, dim);
nononnans = find(nonnans==0);
nonnans(nononnans) = 1;
   
out = (sum(in.^2, dim)-sum(in, dim).^2./nonnans)./(nonnans-abs(flag-1));
out(nononnans) = NaN;
