function [val, status] = findcfg(cfg, var);

% FINDCFG searches for an element in the cfg structure
% or in the nested previous cfgs
%
% Use as
%   [val] = findcfg(cfg, var)
% where the name of the variable should be specified as string.
%
% e.g.
%   trl   = findcfg(cfg, 'trl')
%   event = findcfg(cfg, 'event')

% Copyright (C) 2006, Robert Oostenveld
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
% $Id: findcfg.m 951 2010-04-21 18:24:01Z roboos $

if var(1)~='.'
  var = ['.' var];
end
val   = [];
depth = 0;
status = 0;

while ~status
  depth = depth + 1;
  if issubfield(cfg,  var)
    val = getsubfield(cfg, var);
    status = 1;
  elseif issubfield(cfg, '.previous');
    [val, status] = findcfg(cfg.previous, var);
     if status, break; end;
  elseif iscell(cfg) 
    for i=1:length(cfg)
      [val, status] = findcfg(cfg{i}, var);
      if status, break; end;
    end
  else
    status = -1;
    break
  end
end

