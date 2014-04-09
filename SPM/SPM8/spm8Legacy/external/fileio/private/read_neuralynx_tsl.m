function [dat] = read_neuralynx_tsh(filename, begsample, endsample);

% READ_NEURALYNX_TTL reads the TimeStampHi values from a *.tsh file
%
% Use as
%   [dat] = read_neuralynx_tsh(filename, begsample, endsample);
%
% The *.tsh file is not a formal Neuralynx file format, but at the
% F.C. Donders Centre we use it in conjunction with Neuralynx and
% SPIKEDOWNSAMPLE.

% Copyright (C) 2006, Robert Oostenveld
%
% $Log: read_neuralynx_tsl.m,v $
% Revision 1.3  2006/12/12 11:32:22  roboos
% read the data as uint32 instead of signed integers
%

fid = fopen(filename, 'rb', 'ieee-le');

if begsample<1
  begsample = 1;
end

if isinf(endsample)
  fseek(fid, 0, 'eof');
  endsample = (ftell(fid)-8)/4;
  fseek(fid, 0, 'bof');
end

fseek(fid,  8, 'cof');             % skip the 8-byte header with the filetype identifier
fseek(fid,  begsample-1, 'cof');   % skip to the beginning of the interesting data
dat = fread(fid, endsample-begsample+1, 'uint32=>uint32')';
if length(dat)<(endsample-begsample+1)
  error('could not read the requested data');
end

fclose(fid);

