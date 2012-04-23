function [pnt, ori, lab] = channelposition(sens, varargin)

% CHANNELPOSITION
%
% Use either as
%   [pos]           = channelposition(sens, ...)
%   [pos, lab]      = channelposition(sens, ...)
%   [pos, ori, lab] = channelposition(sens, ...)

% Copyright (C) 2009, Robert Oostenveld & Vladimir Litvak
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
% $Id: channelposition.m 3791 2011-07-07 09:02:58Z jansch $

% remove the balancing from the sensor definition, e.g. 3rd order gradients, PCA-cleaned data or ICA projections
sens = undobalancing(sens);

switch ft_senstype(sens)
  case {'ctf151', 'ctf275' 'bti148', 'bti248', 'itab153', 'yokogawa160', 'yokogawa64'}
    % the following code is for all axial gradiometer systems
    
    % remove the non-MEG channels altogether
    sel = ft_chantype(sens, 'meg');
    sens.label = sens.label(sel);
    sens.tra   = sens.tra(sel,:);

    % subsequently remove the unused coils
    used = any(abs(sens.tra)<0.5, 1);  % allow a little bit of rounding-off error
    sens.pnt = sens.pnt(used,:);
    sens.ori = sens.ori(used,:);
    sens.tra = sens.tra(:,used);

    % compute distances from the center of the helmet
    center = mean(sens.pnt(sel,:));
    dist   = sqrt(sum((sens.pnt - repmat(center, size(sens.pnt, 1), 1)).^2, 2));

    % put the corresponding distances instead of non-zero tra entries    
    maxval = repmat(max(abs(sens.tra),[],2), [1 size(sens.tra,2)]);
    maxval = min(maxval, ones(size(maxval))); %a value > 1 sometimes leads to problems; this is an empirical fix
    dist = (abs(sens.tra)>0.9.*maxval).*repmat(dist', size(sens.tra, 1), 1);
    
    % put nans instead of the zero entries
    dist(~dist) = inf;

    % use the matrix to find coils with minimal distance to the center, i.e. the bottom coil
    [junk, ind] = min(dist, [], 2);

    lab = sens.label;
    pnt = sens.pnt(ind, :);
    ori = sens.ori(ind, :);

  case {'ctf151_planar', 'ctf275_planar', 'bti148_planar', 'bti248_planar', 'itab153_planar', 'yokogawa160_planar', 'yokogawa64_planar'}
    % create a list with planar channel names
    chan = {};
    for i=1:length(sens.label)
      if ~isempty(findstr(sens.label{i}, '_dH')) || ~isempty(findstr(sens.label{i}, '_dV'))
        chan{i} = sens.label{i}(1:(end-3));
      end
    end
    chan = unique(chan);
    % find the matching channel-duplets
    ind = [];
    lab = {};
    for i=1:length(chan)
      ch1 =  [chan{i} '_dH'];
      ch2 =  [chan{i} '_dV'];
      sel = match_str(sens.label, {ch1, ch2});
      if length(sel)==2
        ind = [ind; i];
        lab(i,:) = {ch1, ch2};
        meanpnt1 = mean(sens.pnt(abs(sens.tra(sel(1),:))>0.5, :), 1);
        meanpnt2 = mean(sens.pnt(abs(sens.tra(sel(2),:))>0.5, :), 1);
        pnt(i,:) = mean([meanpnt1; meanpnt2], 1);
      end
    end
    lab = lab(ind,:);
    pnt = pnt(ind,:);

  case 'neuromag122'
    % find the matching channel-duplets
    ind = [];
    lab = {};
    for i=1:2:140
      % first try MEG channel labels with a space
      ch1 = sprintf('MEG %03d', i);
      ch2 = sprintf('MEG %03d', i+1);
      sel = match_str(sens.label, {ch1, ch2});
      % then try MEG channel labels without a space
      if (length(sel)~=2)
        ch1 = sprintf('MEG%03d', i);
        ch2 = sprintf('MEG%03d', i+1);
        sel = match_str(sens.label, {ch1, ch2});
      end
      % then try to determine the channel locations
      if (length(sel)==2)
        ind = [ind; i];
        lab(i,:) = {ch1, ch2};
        meanpnt1 = mean(sens.pnt(abs(sens.tra(sel(1),:))>0.5,:), 1);
        meanpnt2 = mean(sens.pnt(abs(sens.tra(sel(2),:))>0.5,:), 1);
        pnt(i,:) = mean([meanpnt1; meanpnt2], 1);
      end
    end
    lab = lab(ind,:);
    pnt = pnt(ind,:);

  case 'neuromag306'
    % find the matching channel-triplets
    ind = [];
    lab = {};
    for i=1:300
      % first try MEG channel labels with a space
      ch1 = sprintf('MEG %03d1', i);
      ch2 = sprintf('MEG %03d2', i);
      ch3 = sprintf('MEG %03d3', i);
      [sel1, sel2] = match_str(sens.label, {ch1, ch2, ch3});
      % the try MEG channels without a space
      if isempty(sel1)
        ch1 = sprintf('MEG%03d1', i);
        ch2 = sprintf('MEG%03d2', i);
        ch3 = sprintf('MEG%03d3', i);
        [sel1, sel2] = match_str(sens.label, {ch1, ch2, ch3});
      end
      % then try to determine the channel locations
      if (~isempty(sel1) && length(sel1)<=3)
        ind = [ind; i];
        lab(i,sel2) = sens.label(sel1)';
        meanpnt  = [];
        for j = 1:length(sel1)
           meanpnt  = [meanpnt; mean(sens.pnt(abs(sens.tra(sel1(j),:))>0.5,:), 1)];
        end
        pnt(i,:) = mean(meanpnt, 1);
      end
    end
    lab = lab(ind,:);
    pnt = pnt(ind,:);


  otherwise
    % compute the position for each electrode

    if isfield(sens, 'tra')
      % each channel depends on multiple sensors (electrodes or coils)
      % compute a weighted position for the channel
      [nchan, ncoil] = size(sens.tra);
      pnt = zeros(nchan,3);
      ori = zeros(nchan,3); % FIXME not sure whether this will work
      for i=1:nchan
        weight = abs(sens.tra(i,:));
        weight = weight ./ norm(weight);
        pnt(i,:) = weight * sens.pnt;
        ori(i,:) = weight * sens.ori;
      end
      lab = sens.label;

    else
      % there is one sensor per channel, which means that the channel position
      % is identical to the sensor position
      pnt = sens.pnt;
      lab = sens.label;
    end

end % switch senstype

n   = size(lab,2);
% this is to fix the planar layouts, which cannot be plotted anyway
if n>1 && size(lab, 1)>1 %this is to prevent confusion when lab happens to be a row array
  pnt = repmat(pnt, n, 1);
end

% ensure that it is a row vector
lab = lab(:);

% the function can be called with a different number of output arguments
if nargout==1
  pnt = pnt;
  ori = [];
  lab = [];
elseif nargout==2
  pnt = pnt;
  ori = lab;  % second output argument
  lab = [];   % third output argument
elseif nargout==3
  pnt = pnt;
  ori = ori;  % second output argument
  lab = lab;  % third output argument
end
