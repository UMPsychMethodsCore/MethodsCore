function volume = ft_datatype_volume(volume, varargin)

% FT_DATATYPE_VOLUME describes the FieldTrip MATLAB structure for volumetric data.
%
% The volume data structure represents data on a regular volumetric
% 3-D grid, like an anatomical MRI, a functional MRI, etc. It can
% also represent a source reconstructed estimate of the activity
% measured with MEG. In this case the source reconstruction is estimated
% or interpolated on the regular 3-D dipole grid (like a box).
%
% An example volume structure is
%           dim: [181 217 181]         the dimensionality of the 3D volume
%     transform: [4x4 double]          affine transformation matrix for mapping the voxel coordinates to the head coordinate system
%       anatomy: [181x217x181 double]  the numeric data, in this case anatomical information
%
% Required fields:
%   - transform, dim
%
% Optional fields:
%   - anatomy, prob, stat, grey, white, csf, or any other field with
%     dimensions that are consistent with dim
%
% Deprecated fields:
%   - dimord
%
% Obsoleted fields:
%   - none
%
% Revision history:
%
% (2011) The dimord field was deprecated and we agreed that volume
% data should be 3-dimensional and not N-dimensional with arbitary
% dimensions. In case time-frequency recolved data has to be represented
% on a 3-d grid, the source representation should be used.
%
% (2010) The dimord field was added by some functions, but not by all
%
% (2003) The initial version was defined
%
% See also FT_DATATYPE, FT_DATATYPE_COMP, FT_DATATYPE_DIP, FT_DATATYPE_FREQ,
% FT_DATATYPE_MVAR, FT_DATATYPE_RAW, FT_DATATYPE_SOURCE, FT_DATATYPE_SPIKE,
% FT_DATATYPE_TIMELOCK, FT_DATATYPE_VOLUME

% Copyright (C) 2011, Robert Oostenveld
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
% $Id: ft_datatype_volume.m 3423 2011-05-03 09:08:12Z roboos $

% get the optional input arguments, which should be specified as key-value pairs
version = keyval('version', varargin); if isempty(version), version = 'latest'; end

if strcmp(version, 'latest')
  version = '2011';
end

% it should  never have contained these, but they might be present due to an unclear
% distinction between the volume and the source representation
if isfield(volume, 'xgrid'),     volume = rmfield(volume, 'xgrid');     end
if isfield(volume, 'ygrid'),     volume = rmfield(volume, 'ygrid');     end
if isfield(volume, 'zgrid'),     volume = rmfield(volume, 'zgrid');     end
if isfield(volume, 'freq'),      volume = rmfield(volume, 'freq');      end
if isfield(volume, 'frequency'), volume = rmfield(volume, 'frequency'); end
if isfield(volume, 'time'),      volume = rmfield(volume, 'time');      end
if isfield(volume, 'latency'),   volume = rmfield(volume, 'latency');   end

switch version
  case '2011'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isfield(volume, 'dimord')
      volume = rmfield(volume, 'dimord');
    end

  case '2010'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % this might have been N-dimensional and contained a dimord, but in general cannot
    % be reconstructed on the fly

  case '2003'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isfield(volume, 'dimord')
      volume = rmfield(volume, 'dimord');
    end

  otherwise
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    error('unsupported version "%s" for freq datatype', version);
end

