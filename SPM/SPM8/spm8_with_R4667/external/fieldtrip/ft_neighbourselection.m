function neighbours = ft_neighbourselection(cfg,data)

% FT_NEIGHBOURSELECTION finds the neighbours of the channels based on three 
% different methods. Using the 'distance'-method, neighbourselection is
% based on a minimum neighbourhood distance (in cfg.neighbourdist). The
% 'triangulation'-method calculates a triangulation based on a
% two-dimenstional projection of the sensor position. The 'template'-method
% loads a default template for the given data type. Neighbourselection
% should be verified using cfg.feedback ='yes' or by calling
% ft_neighbourplot
%
% The positions of the channel are specified in a gradiometer or electrode configuration or
% from a layout.
% This configuration can be passed in three ways:
%  (1) in a configuration field,
%  (2) in a file whose name is passed in a configuration field, and that can be imported using READ_SENS, or
%  (3) in a data field.
%
% Use as
%   neighbours = ft_neighbourselection(cfg, data)
%
% The configuration can contain
%   cfg.method        = 'distance', 'triangulation' or 'template' (default = 'distance')
%   cfg.neighbourdist = number, maximum distance between neighbouring sensors (only for 'distance')
%   cfg.template      = name of the template file, e.g. CTF275_neighb.mat
%   cfg.layout        = filename of the layout, see FT_PREPARE_LAYOUT
%   cfg.elec          = structure with EEG electrode positions
%   cfg.grad          = structure with MEG gradiometer positions
%   cfg.elecfile      = filename containing EEG electrode positions
%   cfg.gradfile      = filename containing MEG gradiometer positions

%   cfg.feedback      = 'yes' or 'no' (default = 'no')
%
% The following data fields may also be used by FT_NEIGHBOURSELECTION:
%   data.elec     = structure with EEG electrode positions
%   data.grad     = structure with MEG gradiometer positions
%
% The output:
%   neighbours     = definition of neighbours for each channel,
%     which is structured like this:
%        neighbours(1).label = 'Fz';
%        neighbours(1).neighblabel = {'Cz', 'F3', 'F3A', 'FzA', 'F4A', 'F4'};
%        neighbours(2).label = 'Cz';
%        neighbours(2).neighblabel = {'Fz', 'F4', 'RT', 'RTP', 'P4', 'Pz', 'P3', 'LTP', 'LT', 'F3'};
%        neighbours(3).label = 'Pz';
%        neighbours(3).neighblabel = {'Cz', 'P4', 'P4P', 'Oz', 'P3P', 'P3'};
%        etc.
%        (Note that a channel is not considered to be a neighbour of itself.)
%
% See also FT_NEIGHBOURPLOT


% Copyright (C) 2006-2011, Eric Maris, J�rn M. Horschig, Robert Oostenveld
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
% $Id: ft_neighbourselection.m 3887 2011-07-20 14:09:43Z jorhor $

ft_defaults

% set the defaults
if ~isfield(cfg, 'feedback'),       cfg.feedback = 'no';         end
cfg = ft_checkconfig(cfg, 'required',    {'method'});

hasdata = nargin>1;
if strcmp(cfg.method, 'template')
    fprintf('Trying to load sensor neighbours from a template\n');
    if ~isfield(cfg, 'template')
        if hasdata
            fprintf('Estimating sensor type of data to determine the layout filename\n');
            senstype = upper(ft_senstype(data));
            fprintf('Data is of sensor type ''%s''\n', senstype);
            if exist([senstype '.lay'], 'file')
                cfg.layout = [senstype '.lay'];
            else
                fprintf('Name of sensor type does not match name of layout- and template-file\n');
            end
        end    
        if ~isfield(cfg, 'layout')
            error('You need to define a template or layout or give data as an input argument when ft_neighbourselection is called with cfg.method=''template''');
        end
        fprintf('Using the 2-D layout filename to determine the template filename\n');
        cfg.template = [strtok(cfg.layout, '.') '_neighb.mat'];
    end
    if ~exist(cfg.template, 'file') 
        error('Template file could not be found - please check spelling or contact jm.horschig(at)donders.ru.nl if you want to create and share your own template! See also http://fieldtrip.fcdonders.nl/faq/how_can_i_define_my_own_neighbourhood_template');
    end
    load(cfg.template);    
    fprintf('Successfully loaded neighbour structure from %s\n', cfg.template);
else
    % get the the grad or elec if not present in the data
    if hasdata && isfield(data, 'grad')
        fprintf('Using the gradiometer configuration from the dataset.\n');
        sens = data.grad;
        % extract true channelposition
        [sens.pnt, sens.label] = channelposition(sens);
    elseif hasdata && isfield(data, 'elec')
        fprintf('Using the electrode configuration from the dataset.\n');
        sens = data.elec;
    elseif isfield(cfg, 'grad')
        fprintf('Obtaining the gradiometer configuration from the configuration.\n');
        sens = cfg.grad;
        % extract true channelposition
        [sens.pnt,sens.label] = channelposition(sens);
    elseif isfield(cfg, 'elec')
        fprintf('Obtaining the electrode configuration from the configuration.\n');
        sens = cfg.elec;
    elseif isfield(cfg, 'gradfile')
        fprintf('Obtaining the gradiometer configuration from a file.\n');
        sens = ft_read_sens(cfg.gradfile);
        % extract true channelposition
        [sens.pnt, sens.label] = channelposition(sens);
    elseif isfield(cfg, 'elecfile')
        fprintf('Obtaining the electrode configuration from a file.\n');
        sens = ft_read_sens(cfg.elecfile);
    elseif isfield(cfg, 'layout')
        fprintf('Using the 2-D layout to determine the neighbours\n');
        lay = ft_prepare_layout(cfg);
        sens = [];
        sens.label = lay.label;
        sens.pnt = lay.pos;
        sens.pnt(:,3) = 0;
    else
        error('Did not find gradiometer or electrode information or a layout.');
    end;
    
    
    switch lower(cfg.method)
        case 'distance'
            % use a smart default for the distance
            if ~isfield(cfg, 'neighbourdist')
                sens = ft_checkdata(sens, 'hasunits', 'yes');
                if isfield(sens, 'unit') && strcmp(sens.unit, 'm')
                    cfg.neighbourdist = 0.04;
                elseif isfield(sens, 'unit') && strcmp(sens.unit, 'dm')
                    cfg.neighbourdist = 0.4;
                elseif isfield(sens, 'unit') && strcmp(sens.unit, 'cm')
                    cfg.neighbourdist = 4;
                elseif isfield(sens, 'unit') && strcmp(sens.unit, 'mm')
                    cfg.neighbourdist = 40;
                else
                    % don't provide a default in case the dimensions of the sensor array are unknown
                    error('Sensor distance is measured in an unknown unit type');
                end
            end
            
            neighbours = compneighbstructfromgradelec(sens, cfg.neighbourdist);
        case {'triangulation', 'tri'} % the latter for reasons of simplicity
            if size(sens.pnt, 2)==2 || all(sens.pnt(:,3)==0)
                % the sensor positions are already on a 2D plane
                prj = sens.pnt(:,1:2);
            else
                % project sensor on a 2D plane
                prj = elproj(sens.pnt);
            end
            % make a 2d delaunay triangulation of the projected points
            tri = delaunay(prj(:,1), prj(:,2));
            tri_x = delaunay(prj(:,1)./2, prj(:,2));
            tri_y = delaunay(prj(:,1), prj(:,2)./2);
            tri = [tri; tri_x; tri_y];
            neighbours = compneighbstructfromtri(sens, tri);
        otherwise
            error('Method ''%s'' not known', cfg.method);
    end
end

if iscell(neighbours)
    warning('Neighbourstructure is in old format - converting to structure array');
    neighbours = fixneighbours(neighbours);
end

k = 0;
for i=1:length(neighbours)
    k = k + length(neighbours(i).neighblabel);
end
if k==0, error('No neighbours were found!'); end;
fprintf('there are on average %.1f neighbours per channel\n', k/length(neighbours));



if strcmp(cfg.feedback, 'yes')
    % give some graphical feedback
    cfg.neighbours = neighbours;
    if exist('data', 'var')
        ft_neighbourplot(cfg, data);
    else
        ft_neighbourplot(cfg);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION that compute the neighbourhood geometry from the
% gradiometer/electrode positions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [neighbours]=compneighbstructfromgradelec(sens,neighbourdist)

nsensors = length(sens.label);

% compute the distance between all sensors
dist = zeros(nsensors,nsensors);
for i=1:nsensors
    dist(i,:) = sqrt(sum((sens.pnt(1:nsensors,:) - repmat(sens.pnt(i,:), nsensors, 1)).^2,2))';
end;

% find the neighbouring electrodes based on distance
% later we have to restrict the neighbouring electrodes to those actually selected in the dataset
channeighbstructmat = (dist<neighbourdist);

% electrode istelf is not a neighbour
channeighbstructmat = (channeighbstructmat .* ~eye(nsensors));

% construct a structured cell array with all neighbours
neighbours=struct;
for i=1:nsensors
    neighbours(i).label       = sens.label{i};
    neighbours(i).neighblabel = sens.label(find(channeighbstructmat(i,:)));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION that computes the neighbourhood geometry from the
% triangulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [neighbours]=compneighbstructfromtri(sens,tri)

nsensors = length(sens.label);

channeighbstructmat = zeros(nsensors,nsensors);
% mark neighbours according to triangulation
for i=1:size(tri, 1)
    channeighbstructmat(tri(i, 1), tri(i, 2)) = 1;
    channeighbstructmat(tri(i, 1), tri(i, 3)) = 1;
    channeighbstructmat(tri(i, 2), tri(i, 1)) = 1;
    channeighbstructmat(tri(i, 3), tri(i, 1)) = 1;
    channeighbstructmat(tri(i, 2), tri(i, 3)) = 1;
    channeighbstructmat(tri(i, 3), tri(i, 2)) = 1;
end

% construct a structured cell array with all neighbours
neighbours=struct;
alldist = [];
noneighb = 0;
for i=1:nsensors
    neighbours(i).label       = sens.label{i};
    neighbidx                 = find(channeighbstructmat(i,:));
    neighbours(i).dist        = sqrt(sum((repmat(sens.pnt(i, :), numel(neighbidx), 1) - sens.pnt(neighbidx, :)).^2, 2));
    alldist                   = [alldist; neighbours(i).dist];
    neighbours(i).neighblabel = sens.label(neighbidx);
    neighbours(i).neighbidx   = neighbidx;
end

neighbdist = mean(alldist)+3*std(alldist);

dismissedneighb = 0;
alldist = [];
for i=1:nsensors
    idx                     = neighbours(i).dist > neighbdist;
    dismissedneighb = dismissedneighb + sum(idx);
    neighbours(i).dist(idx) = [];
    neighbours(i).neighblabel(idx) = [];
    alldist                   = [alldist; neighbours(i).dist];
end
neighbours = rmfield(neighbours, 'dist');
neighbours = rmfield(neighbours, 'neighbidx');