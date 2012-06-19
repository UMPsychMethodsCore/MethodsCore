function [i] = nearest(array, val)

% NEAREST return the index of an array nearest to a scalar
% 
% [indx] = nearest(array, val)

% Copyright (C) 2002, Robert Oostenveld
%
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
% $Id: nearest.m 2865 2011-02-12 19:24:57Z roboos $

mbreal(array);
mbreal(val);

mbvector(array);
mbscalar(val);

% ensure that it is a column vector
array = array(:);

if isnan(val)
  error('incorrect value')
end

if val>max(array)
  % return the last occurence of the nearest number
  [dum, i] = max(flipud(array));
  i = length(array) + 1 - i;
else
  % return the first occurence of the nearest number
  [mindist, i] = min(abs(array(:) - val));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mbreal(a)
if ~isreal(a)
  error('Argument to mbreal must be real');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mbscalar(a)
if ~all(size(a)==1)
  error('Argument to mbscalar must be scalar');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mbvector(a)
if ndims(a) > 2 | (size(a, 1) > 1 & size(a, 2) > 1)
  error('Argument to mbvector must be a vector');
end

