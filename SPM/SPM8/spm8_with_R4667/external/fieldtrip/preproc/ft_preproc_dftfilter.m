function [filt] = ft_preproc_dftfilter(dat, Fs, Fl)

% FT_PREPROC_DFTFILTER applies a notch filter to the data to remove the 50Hz
% or 60Hz line noise components. This is done by fitting a sine and cosine
% at the specified frequency to the data and subsequently subtracting the
% estimated components. The longer the data is, the sharper the spectral
% notch will be that is removed from the data.
%
% Use as
%   [filt] = ft_preproc_dftfilter(dat, Fsample, Fline)
% where
%   dat        data matrix (Nchans X Ntime)
%   Fsample    sampling frequency in Hz
%   Fline      line noise frequency
%
% The line frequency should be specified as a single number. 
% If omitted, a European default of 50Hz will be assumed.
%
% Preferaby the data should have a length that is a multiple of the 
% oscillation period of the line noise (i.e. 20ms for 50Hz noise). If the
% data is of different lenght, then only the first N complete periods are
% used to estimate the line noise. The estimate is subtracted from the
% complete data.
%
% See also PREPROC

% Copyright (C) 2003, Pascal Fries
% Copyright (C) 2003-2008, Robert Oostenveld
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
% $Id: ft_preproc_dftfilter.m 1722 2010-09-20 15:19:23Z sashae $

% determine the size of the data
[Nchans, Nsamples] = size(dat);

% set the default filter frequency
if nargin<3 || isempty(Fl)
  Fl = 50;
end

% determine the largest integer number of line-noise cycles that fits in the data
sel = 1:round(floor(Nsamples * Fl/Fs) * Fs/Fl);

% temporarily remove mean to avoid leakage
mdat = mean(dat(:,sel),2);
dat  = dat - mdat(:,ones(1,Nsamples));

% fit a sin and cos to the signal and subtract them
time  = (0:Nsamples-1)/Fs;
tmp  = exp(j*2*pi*Fl*time);                    % complex sin and cos
% ampl = 2*dat*tmp'/Nsamples;                  % estimated amplitude of complex sin and cos
ampl = 2*dat(:,sel)*tmp(sel)'/length(sel);     % estimated amplitude of complex sin and cos on integer number of cycles
est  = ampl*tmp;                               % estimated signal at this frequency
%filt = dat - est;                              % subtract estimated signal
filt = dat - est + mdat(:,ones(1,Nsamples));
filt = real(filt);

