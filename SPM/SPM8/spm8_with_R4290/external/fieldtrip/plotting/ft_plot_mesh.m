function [hs] = ft_plot_mesh(bnd, varargin)

% FT_PLOT_MESH visualizes the information of a mesh contained in the first
% argument bnd. The boundary argument (bnd) contains typically 2 fields
% called .pnt and .tri referring to vertices and triangulation of a mesh.
%
% Use as
%   ft_plot_mesh(bnd, ...)
%
% FT_PLOT_MESH also allows to plot only vertices by
%   ft_plot_mesh(pnt)
% where pnt is a list of 3d points cartesian coordinates.
%
% Graphic facilities are available for vertices, edges and faces. A list of
% the arguments is given below with the correspondent admitted choices.
%
%     'facecolor'     [r g b] values or string, for example 'brain', 'cortex', 'skin', 'black', 'red', 'r'
%     'vertexcolor'   [r g b] values or string, for example 'brain', 'cortex', 'skin', 'black', 'red', 'r', or an Nx1 array where N is the number of vertices
%     'edgecolor'     [r g b] values or string, for example 'brain', 'cortex', 'skin', 'black', 'red', 'r'
%     'faceindex'     true or false
%     'vertexindex'   true or false
%     'facealpha'     transparency, between 0 and 1
%
% If you don't want the faces or vertices to be plotted, you should
% specify facecolor or respectively edgecolor as 'none'.
%
% Example
%   [pnt, tri] = icosahedron162;
%   bnd.pnt = pnt;
%   bnd.tri = tri;
%   ft_plot_mesh(bnd, 'facecolor', 'skin', 'edgecolor', 'none')
%   camlight
%
% See also TRIMESH

% Copyright (C) 2009, Cristiano Micheli
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
% $Id: ft_plot_mesh.m 3249 2011-03-30 09:51:22Z johzum $

ws = warning('on', 'MATLAB:divideByZero');

keyvalcheck(varargin, 'forbidden', {'faces', 'edges', 'vertices'});

if ~isstruct(bnd) && isnumeric(bnd) && size(bnd,2)==3
  % the input seems like a list of points, convert into something that resembles a mesh
  warning('off', 'MATLAB:warn_r14_stucture_assignment');
  bnd.pnt = bnd;
end

haspnt = isfield(bnd, 'pnt');
hastri = isfield(bnd, 'tri');

% get the optional input arguments
facecolor   = keyval('facecolor',   varargin); if isempty(facecolor),   facecolor='white';end
vertexcolor = keyval('vertexcolor', varargin); 
edgecolor   = keyval('edgecolor',   varargin); if isempty(edgecolor),   edgecolor='k';end
faceindex   = keyval('faceindex',   varargin); if isempty(faceindex),   faceindex=false;end
vertexindex = keyval('vertexindex', varargin); if isempty(vertexindex), vertexindex=false;end
vertexsize  = keyval('vertexsize',  varargin); if isempty(vertexsize),  vertexsize=10;end
facealpha   = keyval('facealpha',   varargin); if isempty(facealpha),   facealpha=1;end
tag         = keyval('tag',         varargin); if isempty(tag),         tag='';end

if isempty(vertexcolor)
  if haspnt && hastri
    vertexcolor='none';
  else
    vertexcolor='k';
  end
end

% convert string into boolean values
faceindex   = istrue(faceindex);
vertexindex = istrue(vertexindex);

skin   = [255 213 119]/255;
brain  = [202 100 100]/255;
cortex = [255 213 119]/255;
    
% there a various ways of disabling the plotting
if isequal(vertexcolor, 'false') || isequal(vertexcolor, 'no') || isequal(vertexcolor, 'off') || isequal(vertexcolor, false)
  vertexcolor = 'none';
end
if isequal(facecolor, 'false') || isequal(facecolor, 'no') || isequal(facecolor, 'off') || isequal(facecolor, false)
  facecolor = 'none';
end
if isequal(edgecolor, 'false') || isequal(edgecolor, 'no') || isequal(edgecolor, 'off') || isequal(edgecolor, false)
  edgecolor = 'none';
end

% new colors management
if strcmpi(vertexcolor,'skin') || strcmpi(vertexcolor,'brain') || strcmpi(vertexcolor,'cortex')
  vertexcolor = eval(vertexcolor);
end
if strcmpi(facecolor,'skin') || strcmpi(facecolor,'brain') || strcmpi(facecolor,'cortex')
  facecolor = eval(facecolor);
end

% everything is added to the current figure
holdflag = ishold;
hold on

if ~isfield(bnd, 'tri')
  bnd.tri = [];
end

if isfield(bnd, 'pnt')
  % this is normal
  pnt = bnd.pnt;
elseif isfield(bnd, 'pos')
  % this is the case for a cortical sheet source model from ft_prepare_sourcemodel
  pnt = bnd.pos;
end
tri = bnd.tri;

if ~isempty(pnt)
  hs = patch('Vertices', pnt, 'Faces', tri);
  set(hs, 'FaceColor', facecolor);
  set(hs, 'EdgeColor', edgecolor);
  set(hs, 'tag', tag);
end

% if vertexcolor is an array with number of elements equal to the number of vertices
if size(pnt,1)==numel(vertexcolor)
  set(hs, 'FaceVertexCData', vertexcolor, 'FaceColor', 'interp'); 
end

% if facealpha is an array with number of elements equal to the number of vertices
if size(pnt,1)==numel(facealpha)
  set(hs, 'FaceVertexAlphaData', facealpha);
  set(hs, 'FaceAlpha', 'interp');
elseif ~isempty(pnt) && numel(facealpha)==1
  set(hs, 'FaceAlpha', facealpha);
end

if faceindex
  % plot the triangle indices (numbers) at each face
  for face_indx=1:size(tri,1)
    str = sprintf('%d', face_indx);
    tri_x = (pnt(tri(face_indx,1), 1) +  pnt(tri(face_indx,2), 1) +  pnt(tri(face_indx,3), 1))/3;
    tri_y = (pnt(tri(face_indx,1), 2) +  pnt(tri(face_indx,2), 2) +  pnt(tri(face_indx,3), 2))/3;
    tri_z = (pnt(tri(face_indx,1), 3) +  pnt(tri(face_indx,2), 3) +  pnt(tri(face_indx,3), 3))/3;
    h   = text(tri_x, tri_y, tri_z, str, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    hs  = [hs; h];
  end
end

if ~isequal(vertexcolor, 'none') && ~(size(pnt,1)==numel(vertexcolor))
  if size(pnt, 2)==2
    hs = plot(pnt(:,1), pnt(:,2), 'k.');
  else
    hs = plot3(pnt(:,1), pnt(:,2), pnt(:,3), 'k.');
  end
  if ~isempty(vertexcolor)
    try
      set(hs, 'Marker','.','MarkerEdgeColor', vertexcolor,'MarkerSize', vertexsize);
    catch
      error('Unknown color')
    end
  end
  if vertexindex
    % plot the vertex indices (numbers) at each node
    for node_indx=1:size(pnt,1)
      str = sprintf('%d', node_indx);
      if size(pnt, 2)==2
        h   = text(pnt(node_indx, 1), pnt(node_indx, 2), str, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
      else
        h   = text(pnt(node_indx, 1), pnt(node_indx, 2), pnt(node_indx, 3), str, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
      end
      hs  = [hs; h];
    end
  end
end

axis off
axis vis3d
axis equal

if ~nargout
  clear hs
end
if ~holdflag
  hold off
end

warning(ws); %revert to original state
