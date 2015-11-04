function [dist] = warp_error(M, input, target, varargin)

% WARP_ERROR computes the mean distance after linear or non-linear warping
% and can be used as the goalfunction in a 3D warping minimalisation
%
% Use as
%   [dist] = warp_error(M, input, target, 'method')
%
% It returns the mean Euclidian distance (residu) when attempting to
% transform the input towards the target using transformation M
% and using the specified warping method.

% Copyright (C) 2000-2005, Robert Oostenveld
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
% $Id: warp_error.m 7123 2012-12-06 21:21:38Z roboos $

if ~isempty(M)
  % apply the warp to the input positions
  input = warp_apply(M, input, varargin{:});
end

if isstruct(target)
  % project points onto target surface and compute distance between points and surface
  % this is done here in one step, but can also be done in seperate steps (see example code below)
  el = project_elec(input, target.pnt, target.tri);
  dist = mean(el(:,4));
  % the following example code is more elaborate, and can be used for detailled testing
  if 0
    Npnt = size(input,1);
    prj = zeros(Npnt, 3);
    % step 1: project each input point onto the triangulated surface
    el = project_elec(input, target.pnt, target.tri);
    % step 2: compute the projected point on the triangulated surface
    for i=1:Npnt
      v1 = target.pnt(target.tri(el(i,1),1),:); % position of vertex 1
      v2 = target.pnt(target.tri(el(i,1),2),:); % position of vertex 2
      v3 = target.pnt(target.tri(el(i,1),3),:); % position of vertex 3
      prj(i,:) = routlm(v1, v2, v3, el(i,2), el(i,3));
    end
    % step 3: compute the distance
    dif    = input - prj;
    dist   = mean(sqrt(sum(dif' .^2)));
  end
else
  % compute distance between input points and target points
  dif    = input - target;
  dist   = mean(sqrt(sum(dif' .^2)));
end

