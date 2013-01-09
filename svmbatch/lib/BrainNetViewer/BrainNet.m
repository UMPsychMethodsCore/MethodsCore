function varargout = BrainNet(varargin)
%BrainNet Viewer, a graph-based brain network mapping tool, by Mingrui Xia
%-----------------------------------------------------------
%	Copyright(c) 2012
%	Beijing Normal University
%	Written by Mingrui Xia
%	Mail to Author:  <a href="mingruixia@gmail.com">Mingrui Xia</a>
%   Version 1.21;
%   Date 20110531;
%   Last edited 20120414
%-----------------------------------------------------------
%
% BrainNet MATLAB code for BrainNet.fig
%      BrainNet, by itself, creates a new BrainNet or raises the existing
%      singleton*.
%
%      H = BrainNet returns the handle to a new BrainNet or the handle to
%      the existing singleton*.
%
%      BrainNet('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BrainNet.M with the given input arguments.
%
%      BrainNet('Property','Value',...) creates a new BrainNet or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BrainNet_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BrainNet_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BrainNet

% Last Modified by GUIDE v2.5 13-Apr-2012 10:19:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @BrainNet_OpeningFcn, ...
    'gui_OutputFcn',  @BrainNet_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before BrainNet is made visible.
function BrainNet_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BrainNet (see VARARGIN)

fprintf('Citing Information:\nPlease cite as "... was/were visualized with the BrainNet Viewer (http://www.nitrc.org/projects/bnv/)" \nwhile using the package to make publicized pictures.\n');


% Choose default command line output for BrainNet
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% if exist('BrainNet_Icon.png','file')==2
%     newIcon = javax.swing.ImageIcon('BrainNet_Icon.png');
%     figFrame = get(handles.NV_fig,'JavaFrame');
%     figFrame.setFigureIcon(newIcon);
% end
movegui(handles.NV_fig,'center');
global FLAG
FLAG.Loadfile=0;
FLAG.EC=0;
FLAG.Rotate=0;
FLAG.EC_change=0;
FLAG.axial=0;
FLAG.sagittal=0;
FLAG.coronal=0;
FLAG.LF=0;
FLAG.MAP=0;
global EC
EC=[];
EC.bak.color=[1,1,1];
EC.msh.color=[0.95,0.95,0.95];
EC.msh.alpha=0.2;
EC.nod.draw=1;
EC.nod.draw_threshold_type=1;
EC.nod.draw_threshold=0;
EC.nod.size=2;
EC.nod.size_size=3;
EC.nod.size_value=1;
EC.nod.size_threshold=0;
EC.nod.size_ratio=1;
EC.nod.color=1;
EC.nod.CM=zeros(64,3);
EC.nod.CM(:,1)=1;
EC.nod.color_map=1;
EC.nod.color_threshold=0;
EC.nod.CMm=[1,0,0,0,1,1,0.5,0,0,0,0.5,0.5,1,0.5,0.5,1,1,0.5,0,0.5,0
    0,1,0,1,0,1,0,0.5,0,0.5,0,0.5,0.5,1,0.5,0.5,0,1,0.5,0,0.5
    0,0,1,1,1,0,0,0,0.5,0.5,0.5,0,0.5,0.5,1,0,0.5,0,1,1,1]';
EC.lbl=2;
EC.lbl_threshold=0;
EC.lbl_threshold_type=1;
EC.edg.draw=1;
EC.edg.draw_threshold=0;
EC.edg.draw_abs=1;
EC.edg.size=2;
EC.edg.size_size=0.3;
EC.edg.size_value=1;
EC.edg.size_threshold=0;
EC.edg.size_ratio=1;
EC.edg.size_abs=1;
EC.edg.color=1;
EC.edg.CM=ones(64,3)*0.38;
EC.edg.color_map=1;
EC.edg.color_threshold=0;
EC.edg.color_distance=0;
EC.edg.color_abs=1;

EC.edg.interhemiedges = 0; % Add by Mingrui Xia, 20120109, draw inter hemisphere edges.

EC.img.width=2000;
EC.img.height=1500;
EC.img.dpi=300;
EC.lbl_font.FontName='Arial';
EC.lbl_font.FontWeight='bold';
EC.lbl_font.FontAngle='normal';
EC.lbl_font.FontSize=11;
EC.lbl_font.FontUnits='points';
EC.lot.view=1;
EC.lot.view_direction=1;
EC.vol.display = []; 
EC.vol.pn = [];
EC.vol.px = [];
EC.vol.nn = [];
EC.vol.nx = [];
EC.vol.null=[0.95,0.95,0.95];
EC.vol.CM=ones(1000,3)*0.75;
EC.vol.color_map=15; 

EC.glb.material = 'dull';% Added by Mingrui Xia, 20120316, modify object material, shading, light.
EC.glb.material_ka = '0.5';
EC.glb.material_kd = '0.5';
EC.glb.material_ks = '0.5';
EC.glb.shading = 'interp';
EC.glb.lighting = 'phong';
EC.glb.lightdirection = 'right';
EC.glb.render = 'OpenGL'; % Added by Mingrui Xia, 20120413, selection for rendering methods
EC.glb.detail = 3; % Add by Mingrui Xia, 20120413, adjust graph detail


global a
if ~isempty(a) && mean(ishandle(a))==1
    delete(a);
end
a=[];
global File
File.MF=[];
File.NI=[];
File.NT=[];
File.VF=[];


if exist('BrainNet_Background.jpg','file')==2
    imshow(imread('BrainNet_Background.jpg'));
end

global AAL %%% Added by Mingrui Xia, 20120413, give out aal information for selected vertex.
if exist('BrainNet_AAL_Label.mat','file')==2
    AAL = load('BrainNet_AAL_Label.mat');
else
    AAL = [];
end
dcm_obj = datacursormode(hObject);
set(dcm_obj,'UpdateFcn',@BrainNet_Output_txt)
% set(gcf,'Renderer','OpenGL');
%set(handles.NV_fig,'position',get(0,'screensize'));

% UIWAIT makes BrainNet wait for user response (see UIRESUME)
% uiwait(handles.NV_fig);


% --- Outputs from this function are returned to the command line.
function varargout = BrainNet_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
%set(handles.NV_axes,'Position',get(handles.NV_fig,'Position'))


% --------------------------------------------------------------------
function NV_m_file_Callback(hObject, eventdata, handles)
% hObject    handle to NV_m_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function NV_m_exit_Callback(hObject, eventdata, handles)
% hObject    handle to NV_m_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global a
if ~isempty(a)
    delete(a);
    a=[];
end
close(findobj('Tag','NV_fig'));


% --------------------------------------------------------------------
function NV_m_nm_Callback(hObject, eventdata, handles)
% hObject    handle to NV_m_nm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FLAG

if isfield(FLAG,'IsCalledByREST') && FLAG.IsCalledByREST==1 % YAN Chao-Gan 111023. For calling from outside.
    handles.NV_axes=gca(hObject);
end
axes(handles.NV_axes);
cla
global a
if FLAG.Loadfile==0
    if exist('BrainNet_Background.jpg','file')==2
        imshow(imread('BrainNet_Background.jpg'));
    end
else
    if ~isempty(a) && mean(ishandle(a))==1
        delete(a);
    end
    a=FileView;
end
FLAG.IsCalledByREST = 0;


function NetPrepare
global surf
global EC
switch EC.edg.draw
    case 1
        [surf.ncyl,surf.cylinder2]=Nettrans(surf.net,min(min(surf.net)));
    case 2
        [surf.ncyl,surf.cylinder2]=Nettrans(surf.net,EC.edg.draw_threshold);
end

switch EC.edg.size_abs
    case 0
        surf.cylinder=surf.cylinder2;
    case 1
        surf.cylinder=abs(surf.cylinder2);
end
if EC.edg.color_abs==1
    surf.cylinder3=surf.cylinder2;
    if min(surf.cylinder3(:,3))<0
        surf.cylinder3(:,3)=surf.cylinder3(:,3)-min(surf.cylinder3(:,3));
    end
    if min(surf.cylinder3(:,3))<1;
        surf.cylinder3(:,3)=surf.cylinder3(:,3)+1;
    end
    while max(surf.cylinder3(:,3))/min(surf.cylinder3(:,3))>10
        surf.cylinder3(:,3)=log(surf.cylinder3(:,3));
        if min(surf.cylinder3(:,3))<1;
            surf.cylinder3(:,3)=surf.cylinder3(:,3)+1;
        end
    end
    if max(surf.cylinder3(:,3))~=min(surf.cylinder3(:,3))
        EC.Net.k=0.6/(max(surf.cylinder3(:,3))-min(surf.cylinder3(:,3)));
        EC.Net.b=1-EC.Net.k*max(surf.cylinder3(:,3)); % Edited by Mingrui Xia, 20120413, adjust edge value between 0.4~1
    else
        EC.Net.k=0;
        EC.Net.b=0.7;
    end
    surf.cylinder3(:,3)=surf.cylinder3(:,3)*EC.Net.k+EC.Net.b;
end

if min(surf.cylinder(:,3))<0
    surf.cylinder(:,3)=surf.cylinder(:,3)-min(surf.cylinder(:,3));
end
if min(surf.cylinder(:,3))<1;
    surf.cylinder(:,3)=surf.cylinder(:,3)+1;
end
while max(surf.cylinder(:,3))/min(surf.cylinder(:,3))>10
    surf.cylinder(:,3)=log(surf.cylinder(:,3));
    if min(surf.cylinder(:,3))<1;
        surf.cylinder(:,3)=surf.cylinder(:,3)+1;
    end
end
if max(surf.cylinder(:,3))~=min(surf.cylinder(:,3))
    EC.Net.k=0.6/(max(surf.cylinder(:,3))-min(surf.cylinder(:,3)));
    EC.Net.b=1-EC.Net.k*max(surf.cylinder(:,3)); % Edited by Mingrui Xia, 20120413, adjust edge value between 0.4~1
else
    EC.Net.k=0;
    EC.Net.b=0.7;
end
surf.cylinder(:,3)=surf.cylinder(:,3)*EC.Net.k+EC.Net.b;


function NodePrepare
global surf
global EC
if EC.nod.color==2
    surf.sphere(:,6)=surf.sphere(:,4);
    if min(surf.sphere(:,6))<0
        surf.sphere(:,6)=surf.sphere(:,6)-min(surf.sphere(:,6));
    end
    if min(surf.sphere(:,6))<1
        surf.sphere(:,6)=surf.sphere(:,6)+1;
    end
    while max(surf.sphere(:,6))/min(surf.sphere(:,6))>10
        surf.sphere(:,6)=log(surf.sphere(:,6));
        if min(surf.sphere(:,6))<1
            surf.sphere(:,6)=surf.sphere(:,6)+1;
        end
    end
    if max(surf.sphere(:,6))~=min(surf.sphere(:,6))
        EC.nod.k=63/(max(surf.sphere(:,6))-min(surf.sphere(:,6)));
        EC.nod.b=64-EC.nod.k*max(surf.sphere(:,6));
    else
        EC.nod.k=0;
        EC.nod.b=1;
    end
    surf.sphere(:,6)=surf.sphere(:,6)*EC.nod.k+EC.nod.b;
else
    surf.sphere(:,6)=surf.sphere(:,4);
end
if EC.nod.size==2||EC.nod.size==3
    surf.sphere(:,7)=surf.sphere(:,5);
    if min(surf.sphere(:,7))<0
        surf.sphere(:,7)=surf.sphere(:,7)-min(surf.sphere(:,7));
    end
    if min(surf.sphere(:,7))<1
        surf.sphere(:,7)=surf.sphere(:,7)+1;
    end
    while max(surf.sphere(:,7))/min(surf.sphere(:,7))>10
        surf.sphere(:,7)=log(surf.sphere(:,7));
        if min(surf.sphere(:,7))<1
            surf.sphere(:,7)=surf.sphere(:,7)+1;
        end
    end
    if max(surf.sphere(:,7))~=min(surf.sphere(:,7))
        EC.nod.k=5/(max(surf.sphere(:,7))-min(surf.sphere(:,7)));
        EC.nod.b=7-EC.nod.k*max(surf.sphere(:,7));
    else
        EC.nod.k=0;
        EC.nod.b=4;
    end
    surf.sphere(:,7)=surf.sphere(:,7)*EC.nod.k+EC.nod.b;
else
    surf.sphere(:,7)=surf.sphere(:,5);
end


function [ncyl,cylinder]=Nettrans(net,t)
global EC
global surf
switch EC.edg.draw_abs
    case 0
        temp=net;
    case 1
        temp=abs(net);
end
temp(temp==0)=t-1;
index=find(triu(temp)>t);
ncyl=length(index);
cylinder=zeros(ncyl,3);
[cylinder(:,1),cylinder(:,2)]=ind2sub(size(net),index);
cylinder(:,3)=net(index);


% Add by Mingrui Xia, 20120109, draw inter hemisphere edges.
if EC.edg.interhemiedges == 1
    index = surf.sphere(cylinder(:,1)).*surf.sphere(cylinder(:,2))>0;
    cylinder(index,:) = [];
    ncyl=size(cylinder,1);
end


function [t,tl,tr,vl,vr,h1,w1,cut,cuv]=CutMesh(surf)
t=size(surf.tri,1);
v=size(surf.coord,2);
tmax=max(surf.tri,[],2);
tmin=min(surf.tri,[],2);
if min(tmin(t/2+1:t))-max(tmax(1:t/2))==1
    cut=t/2;
    cuv=v/2;
else
    for i=1:t-1
        tmax(i+1)=max(tmax(i+1),tmax(i));
        tmin(t-i)=min(tmin(t-i),tmin(t-i+1));
    end
    cut=min([find((tmin(2:t)-tmax(1:t-1))==1, 1 ) t]); %%% Edited by Mingrui, 20120320, fix a bug.
    cuv=tmax(cut);
end
tl=1:cut;
tr=(cut+1):t;
vl=1:cuv;
vr=(cuv+1):v;
h=0.39;
r=max(surf.coord,[],2)-min(surf.coord,[],2);
w1=h/r(2)*r(1)*3/4;
h1=h/r(2)*r(1);


function w1=NoMeshPage(surf)
h=0.39;
r=max(surf.sphere,[],1)-min(surf.sphere,[],1)*2;
w1=h/r(2)*r(1)*3/4;


function Viewer=GenerateView8(h1,w1)
Viewer(1,:)=[0.055,0.62,0.2925,0.4,-90,0];
Viewer(2,:)=[0.3,0.58,0.4,0.39,0,90];
Viewer(3,:)=[0.6525,0.62,0.2925,0.4,90,0];
Viewer(4,:)=[0.055,0.29,0.2925,0.4,90,0];
Viewer(5,:)=[0.3,0.18,0.4,0.39,0,-90];
Viewer(6,:)=[0.6525,0.29,0.2925,0.4,-90,0];
Viewer(7,:)=[0.055,0.02,w1,h1,180,0];
Viewer(8,:)=[0.945-w1,0.02,w1,h1,0,0];


function Viewer=GenerateView6(w1)
Viewer(1,:)=[0.055,0.58,0.2925,0.4,-90,0];
Viewer(2,:)=[0.3,0.58,0.4,0.39,0,90];
Viewer(3,:)=[0.6525,0.58,w1,0.4,180,0];
Viewer(4,:)=[0.055,0.15,0.2925,0.4,90,0];
Viewer(5,:)=[0.3,0.15,0.4,0.39,0,-90];
Viewer(6,:)=[0.6525,0.15,w1,0.4,0,0];


function Viewer=GenerateView4
% YAN Chao-Gan 111023 Added. For Medium View (4 views)
Viewer(1,:)=[0.045,0.45,0.4387,0.6,-90,0];
Viewer(2,:)=[0.52,0.45,0.4387,0.6,90,0];
Viewer(3,:)=[0.045,-0.01,0.4387,0.6,90,0];
Viewer(4,:)=[0.52,-0.01,0.4387,0.6,-90,0];


% Viewer(1,:)=[0.055,0.62,0.2925,0.4,-90,0];
% Viewer(2,:)=[0.6525,0.62,0.2925,0.4,90,0];
% Viewer(3,:)=[0.055,0.29,0.2925,0.4,90,0];
% Viewer(4,:)=[0.6525,0.29,0.2925,0.4,-90,0];


function Surfmatrix=GenertateSurfM8(surf,tl,tr,vl,vr,cuv)
Surfmatrix.tri{1}=surf.tri(tl,:);
Surfmatrix.tri{2}=surf.tri;
Surfmatrix.tri{3}=surf.tri(tr,:)-cuv;
Surfmatrix.tri{4}=surf.tri(tl,:);
Surfmatrix.tri{5}=surf.tri;
Surfmatrix.tri{6}=surf.tri(tr,:)-cuv;
Surfmatrix.tri{7}=surf.tri;
Surfmatrix.tri{8}=surf.tri;
Surfmatrix.coord{1}=[surf.coord(1,vl)',surf.coord(2,vl)',surf.coord(3,vl)'];
Surfmatrix.coord{2}=[surf.coord(1,:)',surf.coord(2,:)',surf.coord(3,:)'];
Surfmatrix.coord{3}=[surf.coord(1,vr)',surf.coord(2,vr)',surf.coord(3,vr)'];
Surfmatrix.coord{4}=[surf.coord(1,vl)',surf.coord(2,vl)',surf.coord(3,vl)'];
Surfmatrix.coord{5}=[surf.coord(1,:)',surf.coord(2,:)',surf.coord(3,:)'];
Surfmatrix.coord{6}=[surf.coord(1,vr)',surf.coord(2,vr)',surf.coord(3,vr)'];
Surfmatrix.coord{7}=[surf.coord(1,:)',surf.coord(2,:)',surf.coord(3,:)'];
Surfmatrix.coord{8}=[surf.coord(1,:)',surf.coord(2,:)',surf.coord(3,:)'];
if isfield(surf,'T')
    Surfmatrix.T{1}=surf.T(vl);
    Surfmatrix.T{2}=surf.T;
    Surfmatrix.T{3}=surf.T(vr);
    Surfmatrix.T{4}=surf.T(vl);
    Surfmatrix.T{5}=surf.T;
    Surfmatrix.T{6}=surf.T(vr);
    Surfmatrix.T{7}=surf.T;
    Surfmatrix.T{8}=surf.T;
end


function Surfmatrix=GenertateSurfM4(surf,tl,tr,vl,vr,cuv)
% YAN Chao-Gan 111023 Added. For Medium View (4 views)
Surfmatrix.tri{1}=surf.tri(tl,:);
Surfmatrix.tri{2}=surf.tri(tr,:)-cuv;
Surfmatrix.tri{3}=surf.tri(tl,:);
Surfmatrix.tri{4}=surf.tri(tr,:)-cuv;
Surfmatrix.coord{1}=[surf.coord(1,vl)',surf.coord(2,vl)',surf.coord(3,vl)'];
Surfmatrix.coord{2}=[surf.coord(1,vr)',surf.coord(2,vr)',surf.coord(3,vr)'];
Surfmatrix.coord{3}=[surf.coord(1,vl)',surf.coord(2,vl)',surf.coord(3,vl)'];
Surfmatrix.coord{4}=[surf.coord(1,vr)',surf.coord(2,vr)',surf.coord(3,vr)'];
if isfield(surf,'T')
    Surfmatrix.T{1}=surf.T(vl);
    Surfmatrix.T{2}=surf.T(vr);
    Surfmatrix.T{3}=surf.T(vl);
    Surfmatrix.T{4}=surf.T(vr);
end


function a=PlotMesh4(Viewer,Surfmatrix,alpha)
% Mingrui Xia 111026 Added. For Medium View (4 views)
global EC
global cam
a=zeros(1,4);
for i=1:4
    a(i)=axes('position',Viewer(i,1:4));
    Brain=trisurf(Surfmatrix.tri{i},Surfmatrix.coord{i}(:,1),Surfmatrix.coord{i}(:,2),Surfmatrix.coord{i}(:,3),'EdgeColor','none');
    view(Viewer(i,5:6));
    daspect([1 1 1]);
    whitebg(gcf,EC.bak.color);
    set(gcf,'Color',EC.bak.color,'InvertHardcopy','off');
    eval(['lighting ',EC.glb.lighting,';']); eval(['material ',EC.glb.material,';']);eval(['shading ',EC.glb.shading,';']);axis off
    set(Brain,'FaceColor',EC.msh.color);
    set(Brain,'FaceAlpha',EC.msh.alpha);
    if alpha~=1
        eval(['lighting ',EC.glb.lighting,';']);axis tight; axis vis3d off;
        cam = camlight(EC.glb.lightdirection);
    end
    switch i
        case 1
            text(0,max(Surfmatrix.coord{i}(:,2)),max(Surfmatrix.coord{i}(:,3)),'L','FontSize',20,'FontWeight','Bold','HorizontalAlignment','center');
        case 2
            text(0,max(Surfmatrix.coord{i}(:,2)),max(Surfmatrix.coord{i}(:,3)),'R','FontSize',20,'FontWeight','Bold','HorizontalAlignment','center');
    end
end


function a=PlotMesh8(Viewer,Surfmatrix,alpha)
global EC
global cam
a=zeros(1,8);
for i=1:8
    a(i)=axes('position',Viewer(i,1:4));
    Brain=trisurf(Surfmatrix.tri{i},Surfmatrix.coord{i}(:,1),Surfmatrix.coord{i}(:,2),Surfmatrix.coord{i}(:,3),'EdgeColor','none');
    view(Viewer(i,5:6));
    daspect([1 1 1]);
    whitebg(gcf,EC.bak.color);
    set(gcf,'Color',EC.bak.color,'InvertHardcopy','off');
    eval(['lighting ',EC.glb.lighting,';']); eval(['material ',EC.glb.material,';']); eval(['shading ',EC.glb.shading,';']);axis off
    set(Brain,'FaceColor',EC.msh.color);
    set(Brain,'FaceAlpha',EC.msh.alpha);
    if alpha~=1
        eval(['lighting ',EC.glb.lighting,';']);axis tight; axis vis3d off;
        cam = camlight(EC.glb.lightdirection);
    end
    switch i
        case 1
            text(0,max(Surfmatrix.coord{i}(:,2)),max(Surfmatrix.coord{i}(:,3)),'L','FontSize',20,'FontWeight','Bold','HorizontalAlignment','center');
        case 3
            text(0,max(Surfmatrix.coord{i}(:,2)),max(Surfmatrix.coord{i}(:,3)),'R','FontSize',20,'FontWeight','Bold','HorizontalAlignment','center');
    end
end


function a=PlotMesh6(Viewer,surf,alpha)
global EC
global cam
a=zeros(1,6);
for i=1:6
    a(i)=axes('position',Viewer(i,1:4));
    Brain=trisurf(surf.tri,surf.coord(1,:),surf.coord(2,:),surf.coord(3,:),'EdgeColor','none');
    view(Viewer(i,5:6));
    daspect([1 1 1]);
    whitebg(gcf,EC.bak.color);
    set(gcf,'Color',EC.bak.color,'InvertHardcopy','off');
    eval(['material ',EC.glb.material,';']); eval(['shading ',EC.glb.shading,';']);axis off
    set(Brain,'FaceColor',EC.msh.color);
    set(Brain,'FaceAlpha',EC.msh.alpha);
    if alpha~=1
        axis tight; eval(['lighting ',EC.glb.lighting,';']);axis vis3d off;
        cam = camlight(EC.glb.lightdirection);
    end
end


function a=MapMesh6(Viewer,surf,low,high,alpha)
%%% Edited by Mingrui Xia, 20111116, add translucency show
global EC
global cam
a=zeros(1,6);
for i=1:6
    a(i)=axes('position',Viewer(i,1:4));
    Brain=trisurf(surf.tri,surf.coord(1,:),surf.coord(2,:),surf.coord(3,:),surf.T,'EdgeColor','none');
    set(Brain,'FaceAlpha',EC.msh.alpha);
    view(Viewer(i,5:6));
    daspect([1 1 1]);
    whitebg(gcf,EC.bak.color);
    set(gcf,'Color',EC.bak.color,'InvertHardcopy','off');
    eval(['material ',EC.glb.material,';']); eval(['shading ',EC.glb.shading,';']);axis off
    colormap(EC.vol.CM);
    caxis([low,high]);
    if alpha~=1
        axis tight; eval(['lighting ',EC.glb.lighting,';']); axis vis3d off;
        cam = camlight(EC.glb.lightdirection);
    end
end
cb=colorbar('location','South');
set(cb,'Position',[0.35 0.085 0.3 0.03]);
set(cb,'XAxisLocation','bottom');


function a=PlotMesh1(surf,alpha)
global EC
global cam
a=axes;
Brain=trisurf(surf.tri,surf.coord(1,:),surf.coord(2,:),surf.coord(3,:),'EdgeColor','none');
switch EC.lot.view_direction
    case 1
        view(-90,0);
    case 2
        view(0,90);
    case 3
        view(180,0);
end
daspect([1 1 1]);
whitebg(gcf,EC.bak.color);
set(gcf,'Color',EC.bak.color,'InvertHardcopy','off');
eval(['material ',EC.glb.material,';']); eval(['shading ',EC.glb.shading,';']);axis off
set(Brain,'FaceColor',EC.msh.color);
set(Brain,'FaceAlpha',EC.msh.alpha);
if alpha~=1
    axis tight; eval(['lighting ',EC.glb.lighting,';']); axis vis3d off;
    cam = camlight(EC.glb.lightdirection);
end


function a=MapMesh1(surf,low,high,alpha)
%%% Edited by Mingrui Xia, 20111116, add translucency show
global EC
global cam
a=axes;
Brain=trisurf(surf.tri,surf.coord(1,:),surf.coord(2,:),surf.coord(3,:),surf.T,'EdgeColor','none');
set(Brain,'FaceAlpha',EC.msh.alpha);
colormap(EC.vol.CM);
switch EC.lot.view_direction
    case 1
        view(-90,0);
    case 2
        view(0,90);
    case 3
        view(180,0);
end
daspect([1 1 1]);
whitebg(gcf,EC.bak.color);
set(gcf,'Color',EC.bak.color,'InvertHardcopy','off');
eval(['material ',EC.glb.material,';']); eval(['shading ',EC.glb.shading,';']);axis off
if alpha~=1
    axis tight; eval(['lighting ',EC.glb.lighting,';']); axis vis3d off;
    cam = camlight(EC.glb.lightdirection);
end
caxis([low,high]);
cb=colorbar;
set(cb,'Position',[0.9 0.1 0.03 0.3]);
set(cb,'XAxisLocation','bottom');


function a=MapMesh8(Viewer,Surfmatrix,low,high,alpha)
%%% Edited by Mingrui Xia, 20111116, add translucency show
global EC
global cam
a=zeros(1,8);
for i=1:8
    a(i)=axes('position',Viewer(i,1:4));
    Brain=trisurf(Surfmatrix.tri{i},Surfmatrix.coord{i}(:,1),Surfmatrix.coord{i}(:,2),Surfmatrix.coord{i}(:,3),Surfmatrix.T{i},'EdgeColor','none');
    colormap(EC.vol.CM);
    set(Brain,'FaceAlpha',EC.msh.alpha);
    caxis([low,high])
    view(Viewer(i,5:6));
    daspect([1 1 1]);
    whitebg(gcf,EC.bak.color);
    set(gcf,'Color',EC.bak.color,'InvertHardcopy','off');
    eval(['lighting ',EC.glb.lighting,';']); eval(['material ',EC.glb.material,';']); eval(['shading ',EC.glb.shading,';']);axis off
    if alpha~=1
        eval(['lighting ',EC.glb.lighting,';']);axis tight; axis vis3d off;
        cam = camlight(EC.glb.lightdirection);
    end
    switch i
        case 1
            text(0,max(Surfmatrix.coord{i}(:,2)),max(Surfmatrix.coord{i}(:,3)),'L','FontSize',20,'FontWeight','Bold','HorizontalAlignment','center');
        case 3
            text(0,max(Surfmatrix.coord{i}(:,2)),max(Surfmatrix.coord{i}(:,3)),'R','FontSize',20,'FontWeight','Bold','HorizontalAlignment','center');
    end
end
cb=colorbar('location','South');
set(cb,'Position',[0.35 0.085 0.3 0.03]);
set(cb,'XAxisLocation','bottom');


function a=MapMesh4(Viewer,Surfmatrix,low,high,alpha)
% YAN Chao-Gan 111023 Added. For Medium View (4 views)
%%% Edited by Mingrui Xia, 20111116, add translucency show
global EC
global cam
a=zeros(1,4);
for i=1:4
    a(i)=axes('position',Viewer(i,1:4));
    Brain=trisurf(Surfmatrix.tri{i},Surfmatrix.coord{i}(:,1),Surfmatrix.coord{i}(:,2),Surfmatrix.coord{i}(:,3),Surfmatrix.T{i},'EdgeColor','none');
    set(Brain,'FaceAlpha',EC.msh.alpha);
    colormap(EC.vol.CM);
    caxis([low,high])
    view(Viewer(i,5:6));
    daspect([1 1 1]);
    whitebg(gcf,EC.bak.color);
    set(gcf,'Color',EC.bak.color,'InvertHardcopy','off');
    eval(['lighting ',EC.glb.lighting,';']); eval(['material ',EC.glb.material,';']); eval(['shading ',EC.glb.shading,';']);axis off
    if alpha~=1
        axis tight; eval(['lighting ',EC.glb.lighting,';']); axis vis3d off;
        cam = camlight(EC.glb.lightdirection);
    end
    switch i
        case 1
            text(0,max(Surfmatrix.coord{i}(:,2)),max(Surfmatrix.coord{i}(:,3)),'L','FontSize',20,'FontWeight','Bold','HorizontalAlignment','center');
        case 2
            text(0,max(Surfmatrix.coord{i}(:,2)),max(Surfmatrix.coord{i}(:,3)),'R','FontSize',20,'FontWeight','Bold','HorizontalAlignment','center');
    end
end
cb=colorbar('location','South');
set(cb,'Position',[0.4 0.055 0.2 0.03]);
set(cb,'XAxisLocation','bottom');


function a=PlotNode6(Viewer,surf,a,n,EC)
global cam
if length(a)>1
    for i=1:6
        axes(a(i));
        hold on
        for j=1:surf.nsph
            switch EC.nod.draw
                case 1
                    DrawSphere(surf,j,i,6,EC);
                case 2
                    switch EC.nod.draw_threshold_type
                        case 1
                            if surf.sphere(j,5)>EC.nod.draw_threshold
                                DrawSphere(surf,j,i,6,EC);
                            end
                        case 2
                            if surf.sphere(j,4)>EC.nod.draw_threshold
                                DrawSphere(surf,j,i,6,EC);
                            end
                    end
            end
        end
        
        if n>1
            axis tight; axis vis3d off;eval(['material ',EC.glb.material,';']);eval(['lighting ',EC.glb.lighting,';']);
            cam = camlight(EC.glb.lightdirection);
        end
        hold off
    end
else
    a=zeros(1,6);
    for i=1:6
        a(i)=axes('position',Viewer(i,1:4));
        hold on
        view(Viewer(i,5:6));
        daspect([1 1 1]);
        whitebg(gcf,EC.bak.color);
        set(gcf,'Color',EC.bak.color,'InvertHardcopy','off');
        eval(['lighting ',EC.glb.lighting,';']);
        for j=1:surf.nsph
            switch EC.nod.draw
                case 1
                    DrawSphere(surf,j,i,6,EC);
                case 2
                    switch EC.nod.draw_threshold_type
                        case 1
                            if surf.sphere(j,5)>EC.nod.draw_threshold
                                DrawSphere(surf,j,i,6,EC);
                            end
                        case 2
                            if surf.sphere(j,4)>EC.nod.draw_threshold
                                DrawSphere(surf,j,i,6,EC);
                            end
                    end
            end
        end
        if n>1
            axis tight; axis vis3d off;eval(['material ',EC.glb.material,';']);eval(['lighting ',EC.glb.lighting,';']);
            cam = camlight(EC.glb.lightdirection);
        end
        hold off
    end
end


function a=PlotNode4(surf, a, flag, centerX, n, EC)
% Mingrui Xia 111026 Added. For Medium View (4 views)
global cam
for i=1:4
    axes(a(i));
    hold on
    switch i
        case {1,3}
            if flag==1
                for j=1:surf.nsph
                    if surf.sphere(j,1)<centerX
                        switch EC.nod.draw
                            case 1
                                DrawSphere(surf,j,i,4,EC);
                            case 2
                                switch EC.nod.draw_threshold_type
                                    case 1
                                        if surf.sphere(j,5)>EC.nod.draw_threshold
                                            DrawSphere(surf,j,i,4,EC);
                                        end
                                    case 2
                                        if surf.sphere(j,4)>EC.nod.draw_threshold
                                            DrawSphere(surf,j,i,4,EC);
                                        end
                                end
                        end
                    end
                end
            else
                for j=1:surf.nsph
                    if surf.sphere(j,1)>centerX
                        switch EC.nod.draw
                            case 1
                                DrawSphere(surf,j,i,4,EC);
                            case 2
                                switch EC.nod.draw_threshold_type
                                    case 1
                                        if surf.sphere(j,5)>EC.nod.draw_threshold
                                            DrawSphere(surf,j,i,4,EC);
                                        end
                                    case 2
                                        if surf.sphere(j,4)>EC.nod.draw_threshold
                                            DrawSphere(surf,j,i,4,EC);
                                        end
                                end
                        end
                    end
                end
            end
        case{2,4}
            if flag==2
                for j=1:surf.nsph
                    if surf.sphere(j,1)<centerX
                        switch EC.nod.draw
                            case 1
                                DrawSphere(surf,j,i,4,EC);
                            case 2
                                switch EC.nod.draw_threshold_type
                                    case 1
                                        if surf.sphere(j,5)>EC.nod.draw_threshold
                                            DrawSphere(surf,j,i,4,EC);
                                        end
                                    case 2
                                        if surf.sphere(j,4)>EC.nod.draw_threshold
                                            DrawSphere(surf,j,i,4,EC);
                                        end
                                end
                        end
                    end
                end
            else
                for j=1:surf.nsph
                    if surf.sphere(j,1)>centerX
                        switch EC.nod.draw
                            case 1
                                DrawSphere(surf,j,i,4,EC);
                            case 2
                                switch EC.nod.draw_threshold_type
                                    case 1
                                        if surf.sphere(j,5)>EC.nod.draw_threshold
                                            DrawSphere(surf,j,i,4,EC);
                                        end
                                    case 2
                                        if surf.sphere(j,4)>EC.nod.draw_threshold
                                            DrawSphere(surf,j,i,4,EC);
                                        end
                                end
                        end
                    end
                end
            end
    end
    if n>1
        axis tight; axis vis3d off;eval(['material ',EC.glb.material,';']);eval(['lighting ',EC.glb.lighting,';']);
        cam = camlight(EC.glb.lightdirection);
    end
    hold off
end


function a=PlotNode1(surf,a,n,EC)
global cam
if ~isempty(a)
    axes(a);
    hold on
    for j=1:surf.nsph
        switch EC.nod.draw
            case 1
                DrawSphere(surf,j,2,1,EC);
            case 2
                switch EC.nod.draw_threshold_type
                    case 1
                        if surf.sphere(j,5)>EC.nod.draw_threshold
                            DrawSphere(surf,j,2,1,EC);
                        end
                    case 2
                        if surf.sphere(j,4)>EC.nod.draw_threshold
                            DrawSphere(surf,j,2,1,EC);
                        end
                end
        end
    end
    hold off
    if n>1
        axis tight; axis vis3d off;eval(['material ',EC.glb.material,';']);eval(['lighting ',EC.glb.lighting,';']);
        cam = camlight(EC.glb.lightdirection);
    end
else
    a=axes;
    hold on
    switch EC.lot.view_direction
        case 1
            view(-90,0);
        case 2
            view(0,90);
        case 3
            view(180,0);
    end
    daspect([1 1 1]);
    whitebg(gcf,EC.bak.color);
    set(gcf,'Color',EC.bak.color,'InvertHardcopy','off');
    eval(['lighting ',EC.glb.lighting,';']);
    for j=1:surf.nsph
        switch EC.nod.draw
            case 1
                DrawSphere(surf,j,2,1,EC);
            case 2
                switch EC.nod.draw_threshold_type
                    case 1
                        if surf.sphere(j,5)>EC.nod.draw_threshold
                            DrawSphere(surf,j,2,1,EC);
                        end
                    case 2
                        if surf.sphere(j,4)>EC.nod.draw_threshold
                            DrawSphere(surf,j,2,1,EC);
                        end
                end
        end
    end
    if n>1
        axis tight; axis vis3d off;eval(['material ',EC.glb.material,';']);eval(['lighting ',EC.glb.lighting,';']);
        cam = camlight(EC.glb.lightdirection);
    end
    hold off
end


function PlotNode8(surf,a,flag,centerX,n,EC)
global cam
for i=1:8
    axes(a(i));
    hold on
    switch i
        case {1,4}
            if flag==1
                for j=1:surf.nsph
                    if surf.sphere(j,1)<centerX
                        switch EC.nod.draw
                            case 1
                                DrawSphere(surf,j,i,8,EC);
                            case 2
                                switch EC.nod.draw_threshold_type
                                    case 1
                                        if surf.sphere(j,5)>EC.nod.draw_threshold
                                            DrawSphere(surf,j,i,8,EC);
                                        end
                                    case 2
                                        if surf.sphere(j,4)>EC.nod.draw_threshold
                                            DrawSphere(surf,j,i,8,EC);
                                        end
                                end
                        end
                    end
                end
            else
                for j=1:surf.nsph
                    if surf.sphere(j,1)>centerX
                        switch EC.nod.draw
                            case 1
                                DrawSphere(surf,j,i,8,EC);
                            case 2
                                switch EC.nod.draw_threshold_type
                                    case 1
                                        if surf.sphere(j,5)>EC.nod.draw_threshold
                                            DrawSphere(surf,j,i,8,EC);
                                        end
                                    case 2
                                        if surf.sphere(j,4)>EC.nod.draw_threshold
                                            DrawSphere(surf,j,i,8,EC);
                                        end
                                end
                        end
                    end
                end
            end
        case{3,6}
            if flag==2
                for j=1:surf.nsph
                    if surf.sphere(j,1)<centerX
                        switch EC.nod.draw
                            case 1
                                DrawSphere(surf,j,i,8,EC);
                            case 2
                                switch EC.nod.draw_threshold_type
                                    case 1
                                        if surf.sphere(j,5)>EC.nod.draw_threshold
                                            DrawSphere(surf,j,i,8,EC);
                                        end
                                    case 2
                                        if surf.sphere(j,4)>EC.nod.draw_threshold
                                            DrawSphere(surf,j,i,8,EC);
                                        end
                                end
                        end
                    end
                end
            else
                for j=1:surf.nsph
                    if surf.sphere(j,1)>centerX
                        switch EC.nod.draw
                            case 1
                                DrawSphere(surf,j,i,8,EC);
                            case 2
                                switch EC.nod.draw_threshold_type
                                    case 1
                                        if surf.sphere(j,5)>EC.nod.draw_threshold
                                            DrawSphere(surf,j,i,8,EC);
                                        end
                                    case 2
                                        if surf.sphere(j,4)>EC.nod.draw_threshold
                                            DrawSphere(surf,j,i,8,EC);
                                        end
                                end
                        end
                    end
                end
            end
        case {2,5,7,8}
            for j=1:surf.nsph
                switch EC.nod.draw
                    case 1
                        DrawSphere(surf,j,i,8,EC);
                    case 2
                        switch EC.nod.draw_threshold_type
                            case 1
                                if surf.sphere(j,5)>EC.nod.draw_threshold
                                    DrawSphere(surf,j,i,8,EC);
                                end
                            case 2
                                if surf.sphere(j,4)>EC.nod.draw_threshold
                                    DrawSphere(surf,j,i,8,EC);
                                end
                        end
                end
            end
    end
    if n>1
        axis tight; axis vis3d off;eval(['material ',EC.glb.material,';']);eval(['lighting ',EC.glb.lighting,';']);
        cam = camlight(EC.glb.lightdirection);
    end
    hold off
end


function PlotLabel6(surf,i,j)
global EC
switch i %%% Edited by Mingrui Xia, 111028. Adjust label postion. Edited by Mingrui Xia, 20111113, label position plus radius times ratio.
    case {1,4}
        text(surf.sphere(j,1),surf.sphere(j,2),surf.sphere(j,3)+surf.sphere(j,7)*EC.nod.size_ratio+2,surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','center');
    case 2
        if surf.sphere(j,1)<=0
            text(surf.sphere(j,1),surf.sphere(j,2)+surf.sphere(j,7)*EC.nod.size_ratio+2,surf.sphere(j,3),surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','right')
        else
            text(surf.sphere(j,1),surf.sphere(j,2)+surf.sphere(j,7)*EC.nod.size_ratio+2,surf.sphere(j,3),surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','left')
        end
    case 3
        if surf.sphere(j,1)<=0
            text(surf.sphere(j,1),surf.sphere(j,2),surf.sphere(j,3)+surf.sphere(j,7)*EC.nod.size_ratio+2,surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','left')
        else
            text(surf.sphere(j,1),surf.sphere(j,2),surf.sphere(j,3)+surf.sphere(j,7)*EC.nod.size_ratio+2,surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','right')
        end
    case 5
        if surf.sphere(j,1)<=0
            text(surf.sphere(j,1),surf.sphere(j,2)-surf.sphere(j,7)*EC.nod.size_ratio-2,surf.sphere(j,3),surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','right')
        else
            text(surf.sphere(j,1),surf.sphere(j,2)-surf.sphere(j,7)*EC.nod.size_ratio-2,surf.sphere(j,3),surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','left')
        end
    case 6
        if surf.sphere(j,1)<=0
            text(surf.sphere(j,1),surf.sphere(j,2),surf.sphere(j,3)+surf.sphere(j,7)*EC.nod.size_ratio+2,surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','right')
        else
            text(surf.sphere(j,1),surf.sphere(j,2),surf.sphere(j,3)+surf.sphere(j,7)*EC.nod.size_ratio+2,surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','left')
        end
end


function PlotLabel8(surf,i,j)
global EC
switch i
    case {1,3,4,6} %%% Edited by Mingrui Xia, 111028. Combine several same situation, adjust label postion.Edited by Mingrui Xia, 20111113, label position plus radius times ratio.
        text(surf.sphere(j,1),surf.sphere(j,2),surf.sphere(j,3)+surf.sphere(j,7)*EC.nod.size_ratio+2,surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','center');
        %     case {4,6}
        %         text(surf.sphere(j,1),surf.sphere(j,2),surf.sphere(j,3)+surf.sphere(j,7)*2,surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','center');
        %     case 3
        %         text(surf.sphere(j,1),surf.sphere(j,2),surf.sphere(j,3)+surf.sphere(j,7)*2,surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','center');
    case 2
        if surf.sphere(j,1)<=0
            text(surf.sphere(j,1),surf.sphere(j,2)+surf.sphere(j,7)*EC.nod.size_ratio+2,surf.sphere(j,3),surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','right')
        else
            text(surf.sphere(j,1),surf.sphere(j,2)+surf.sphere(j,7)*EC.nod.size_ratio+2,surf.sphere(j,3),surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','left')
        end
    case 7
        if surf.sphere(j,1)<=0
            text(surf.sphere(j,1),surf.sphere(j,2),surf.sphere(j,3)+surf.sphere(j,7)*EC.nod.size_ratio+2,surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','left')
        else
            text(surf.sphere(j,1),surf.sphere(j,2),surf.sphere(j,3)+surf.sphere(j,7)*EC.nod.size_ratio+2,surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','right')
        end
    case 5
        if surf.sphere(j,1)<=0
            text(surf.sphere(j,1),surf.sphere(j,2)-surf.sphere(j,7)*EC.nod.size_ratio-2,surf.sphere(j,3),surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','right')
        else
            text(surf.sphere(j,1),surf.sphere(j,2)-surf.sphere(j,7)*EC.nod.size_ratio-2,surf.sphere(j,3),surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','left')
        end
    case 8
        if surf.sphere(j,1)<=0
            text(surf.sphere(j,1),surf.sphere(j,2),surf.sphere(j,3)+surf.sphere(j,7)*EC.nod.size_ratio+2,surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','right')
        else
            text(surf.sphere(j,1),surf.sphere(j,2),surf.sphere(j,3)+surf.sphere(j,7)*EC.nod.size_ratio+2,surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','left')
        end
end


function PlotLabel1(surf,j)
%%% Added by Mingrui Xia, 111028. Plot label for single view.
%%% Edited by Mingrui Xia, 20111113, label position plus radius times ratio.
global EC
switch EC.lot.view_direction
    case 1
        text(surf.sphere(j,1),surf.sphere(j,2),surf.sphere(j,3)+surf.sphere(j,7)*EC.nod.size_ratio+2,surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','center');
    case 2
        if surf.sphere(j,1)<=0
            text(surf.sphere(j,1),surf.sphere(j,2)+surf.sphere(j,7)*EC.nod.size_ratio+2,surf.sphere(j,3),surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','right')
        else
            text(surf.sphere(j,1),surf.sphere(j,2)+surf.sphere(j,7)*EC.nod.size_ratio+2,surf.sphere(j,3),surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','left')
        end
    case 3
        if surf.sphere(j,1)<=0
            text(surf.sphere(j,1),surf.sphere(j,2),surf.sphere(j,3)+surf.sphere(j,7)*EC.nod.size_ratio+2,surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','left')
        else
            text(surf.sphere(j,1),surf.sphere(j,2),surf.sphere(j,3)+surf.sphere(j,7)*EC.nod.size_ratio+2,surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','right')
        end
        
end


function PlotLabel4(surf,j)
% Mingrui Xia 111026 Added. For Medium View (4 views)
%%% Edited by Mingrui Xia, 20111113, label position plus radius times ratio.
global EC
text(surf.sphere(j,1),surf.sphere(j,2),surf.sphere(j,3)+surf.sphere(j,7)*EC.nod.size_ratio+2,surf.label{j}{1}{1},EC.lbl_font,'HorizontalAlignment','center');


function DrawSphere(surf,j,i,n,EC)
switch EC.nod.size
    case 1
        t=EC.nod.size_size;
    case 2
        switch EC.nod.size_value
            case 1
                t=surf.sphere(j,7);
            case 2
                if surf.sphere(j,5)<1
                    t=1;
                elseif surf.sphere(j,5)>10
                    t=10;
                else
                    t=surf.sphere(j,5);
                end
        end
    case 3
        if surf.sphere(j,5)>EC.nod.size_threshold
            switch EC.nod.size_value
                case 1
                    t=surf.sphere(j,7);
                case 2
                    if surf.sphere(j,5)>10
                        t=10;
                    else
                        t=surf.sphere(j,5);
                    end
            end
        else
            t=1;
        end
end
t=t*EC.nod.size_ratio;
switch EC.glb.detail  % Add by Mingrui Xia, 20120413, adjust graph detail
    case 1
        [x,y,z]=sphere(10);
    case 2
        [x,y,z]=sphere(50);
    case 3
        [x,y,z]=sphere(100);
end
x=x.*t+surf.sphere(j,1);
y=y.*t+surf.sphere(j,2);
z=z.*t+surf.sphere(j,3);
Node=mesh(x,y,z,'EdgeColor','none');
switch EC.nod.color
    case 1
        ci=1;
    case 2
        ci=int32(surf.sphere(j,6));
        if ci<1
            ci=1;
        elseif ci>64
            ci=64;
        end
    case 3
        ci=int32(surf.sphere(j,4));
        if ci<1
            ci=22;
        elseif ci>21
            ci=22;
        end
    case 4
        if surf.sphere(j,4)>EC.nod.color_threshold
            ci=1;
        else
            ci=64;
        end
end
set(Node,'FaceColor',EC.nod.CM(ci,:));
set(Node,'EdgeAlpha',0)
if surf.label{j}{1}{1}~='-'
    switch EC.lbl
        case 1
            if n==8
                PlotLabel8(surf,i,j);
            elseif n==6
                PlotLabel6(surf,i,j);
            elseif n==4 %%% Edited by Mingrui Xia, 111028. Add label plot for medium view and single view.
                PlotLabel4(surf,j);
            else
                PlotLabel1(surf,j);
            end
        case 3
            switch EC.lbl_threshold_type
                case 1
                    if surf.sphere(j,5)>EC.lbl_threshold
                        if n==8
                            PlotLabel8(surf,i,j);
                        elseif n==6
                            PlotLabel6(surf,i,j);
                        elseif n==4 %%% Edited by Mingrui Xia, 111028. Add label plot for medium view and single view.
                            PlotLabel4(surf,j);
                        else
                            PlotLabel1(surf,j);
                        end
                    end
                case 2
                    if surf.sphere(j,4)>EC.lbl_threshold
                        if n==8
                            PlotLabel8(surf,i,j);
                        elseif n==6
                            PlotLabel6(surf,i,j);
                        elseif n==4 %%% Edited by Mingrui Xia, 111028. Add label plot for medium view and single view.
                            PlotLabel4(surf,j);
                        else
                            PlotLabel1(surf,j);
                        end
                    end
            end
    end
end


function [centerX,flag]=JudgeNode(surf,vl,vr)
if abs(min(surf.coord(1,vl))-max(surf.coord(1,vr)))<abs(max(surf.coord(1,vl))-min(surf.coord(1,vr)))
    centerX=(min(surf.coord(1,vl))+max(surf.coord(1,vr)))/2;
else
    centerX=(max(surf.coord(1,vl))+min(surf.coord(1,vr)))/2;
end
if  max(surf.coord(1,vl))<max(surf.coord(1,vr))
    flag=1;
else
    flag=2;
end


function PlotLine6(surf,a)
global cam
global EC
for i=1:6
    axes(a(i));
    hold on
    for j=1:surf.ncyl
        DrawLine(surf,j);
    end
    axis tight; axis vis3d off;eval(['material ',EC.glb.material,';']);eval(['lighting ',EC.glb.lighting,';']);
    cam = camlight(EC.glb.lightdirection);
    hold off
end


function PlotLine1(surf)
global cam
global EC
hold on
for j=1:surf.ncyl
    DrawLine(surf,j);
end
axis tight; axis vis3d off;eval(['material ',EC.glb.material,';']);eval(['lighting ',EC.glb.lighting,';']);
cam = camlight(EC.glb.lightdirection);
hold off


function PlotLine8(surf,a,flag,centerX)
global cam
global EC
for i=1:8
    axes(a(i));
    hold on
    switch i
        case {1,4}
            if flag==1
                for j=1:surf.ncyl
                    if surf.sphere(surf.cylinder(j,1),1)<centerX&&surf.sphere(surf.cylinder(j,2),1)<centerX
                        DrawLine(surf,j);
                    end
                end
            else
                for j=1:surf.ncyl
                    if surf.sphere(surf.cylinder(j,1),1)>centerX&&surf.sphere(surf.cylinder(j,2),1)>centerX
                        DrawLine(surf,j);
                    end
                end
            end
        case{3,6}
            if flag==2
                for j=1:surf.ncyl
                    if surf.sphere(surf.cylinder(j,1),1)<centerX&&surf.sphere(surf.cylinder(j,2),1)<centerX
                        DrawLine(surf,j);
                    end
                end
            else
                for j=1:surf.ncyl
                    if surf.sphere(surf.cylinder(j,1),1)>centerX&&surf.sphere(surf.cylinder(j,2),1)>centerX
                        DrawLine(surf,j);
                    end
                end
            end
        case {2,5,7,8}
            for j=1:surf.ncyl
                DrawLine(surf,j);
            end
    end
    axis tight; axis vis3d off;eval(['material ',EC.glb.material,';']);eval(['lighting ',EC.glb.lighting,';']);
    cam = camlight(EC.glb.lightdirection);
    hold off
end


function PlotLine4(surf,a,flag,centerX)
global cam
global EC
for i=1:4
    axes(a(i));
    hold on
    switch i
        case {1,3}
            if flag==1
                for j=1:surf.ncyl
                    if surf.sphere(surf.cylinder(j,1),1)<centerX&&surf.sphere(surf.cylinder(j,2),1)<centerX
                        DrawLine(surf,j);
                    end
                end
            else
                for j=1:surf.ncyl
                    if surf.sphere(surf.cylinder(j,1),1)>centerX&&surf.sphere(surf.cylinder(j,2),1)>centerX
                        DrawLine(surf,j);
                    end
                end
            end
        case{2,4}
            if flag==2
                for j=1:surf.ncyl
                    if surf.sphere(surf.cylinder(j,1),1)<centerX&&surf.sphere(surf.cylinder(j,2),1)<centerX
                        DrawLine(surf,j);
                    end
                end
            else
                for j=1:surf.ncyl
                    if surf.sphere(surf.cylinder(j,1),1)>centerX&&surf.sphere(surf.cylinder(j,2),1)>centerX
                        DrawLine(surf,j);
                    end
                end
            end
    end
    axis tight; axis vis3d off;eval(['material ',EC.glb.material,';']);eval(['lighting ',EC.glb.lighting,';']);
    cam = camlight(EC.glb.lightdirection);
    hold off
end


function DrawLine(surf,i)
global EC
%length_cyl=norm(surf.sphere(surf.cylinder(i,2),:)-surf.sphere(surf.cylinder(i,1),:)); % Fixed a bug by Mingrui Xia, 20120411, the length calculat was wrong.
length_cyl=norm(surf.sphere(surf.cylinder(i,2),1:3)-surf.sphere(surf.cylinder(i,1),1:3));
switch EC.glb.detail % Add by Mingrui Xia, 20120413, adjust graph detail
    case 1
        t=linspace(0,2*pi,5)';
    case 2
        t=linspace(0,2*pi,10)';
    case 3
        t=linspace(0,2*pi,20)';
end
switch EC.edg.size
    case 1
        n=EC.edg.size_size;
    case 2
        switch EC.edg.size_value
            case 1
                n=surf.cylinder(i,3);
            case 2
                switch EC.edg.size_abs
                    case 0
                        n=surf.cylinder2(i,3);
                    case 1
                        n=abs(surf.cylinder2(i,3));
                end
                if n<0.2
                    n=0.2;
                elseif n>3;
                    n=3;
                end
        end
    case 3
        switch EC.edg.size_abs
            case 0
                if surf.cylinder2(i,3)>EC.edg.size_threshold
                    switch EC.edg.size_value
                        case 1
                            n=surf.cylinder(i,3);
                        case 2
                            n=surf.cylinder2(i,3);
                    end
                else
                    n=0.2;
                end
                
            case 1
                if surf.cylinder2(i,3)>EC.edg.size_threshold||surf.cylinder2(i,3)<-EC.edg.size_threshold
                    switch EC.edg.size_value
                        case 1
                            n=surf.cylinder(i,3);
                        case 2
                            n=surf.cylinder2(i,3);
                    end
                else
                    n=0.2;
                end
        end
end
n=n*EC.edg.size_ratio;
x2=n*cos(t);
x3=n*sin(t);
x1=[0 length_cyl];
xx1=repmat(x1,length(x2),1);
xx2=repmat(x2,1,2);
xx3=repmat(x3,1,2);
Line=mesh(xx1,xx2,xx3);
unit_Vx=[1 0 0];
angle_X1X2=acos( dot( unit_Vx,surf.sphere(surf.cylinder(i,2),1:3)-surf.sphere(surf.cylinder(i,1),1:3) )/( norm(unit_Vx)*norm(surf.sphere(surf.cylinder(i,2),1:3)-surf.sphere(surf.cylinder(i,1),1:3))) )*180/pi;
axis_rot=cross([1 0 0],(surf.sphere(surf.cylinder(i,2),1:3)-surf.sphere(surf.cylinder(i,1),1:3)) );
if angle_X1X2~=0
    rotate(Line,axis_rot,angle_X1X2,[0 0 0])
end
set(Line,'XData',get(Line,'XData')+surf.sphere(surf.cylinder(i,1),1));
set(Line,'YData',get(Line,'YData')+surf.sphere(surf.cylinder(i,1),2));
set(Line,'ZData',get(Line,'ZData')+surf.sphere(surf.cylinder(i,1),3));
switch EC.edg.color
    case 1
        ci=1;
    case 2
%         switch EC.edg.color_abs %%% Edited by Mingrui Xia, 20120413, fix colormap
%         for edges
%             case 0
%                 ci=int32(45*surf.cylinder3(i,3)-3.5);
                ci=int8(105*surf.cylinder(i,3)-41);
%                 if ci<1
%                     ci=1;
%                 elseif ci>64
%                     ci=64;
%                 end
%             case 1
%                 ci=int32(45*surf.cylinder3(i,3)-3.5);
%                 if ci<1
%                     ci=1;
%                 elseif ci>64
%                     ci=64;
%                 end
%         end
    case 3
        switch EC.edg.color_abs
            case 0
                if surf.cylinder2(i,3)>EC.edg.color_threshold
                    ci=1;
                else
                    ci=64;
                end
            case 1
                if surf.cylinder2(i,3)>EC.edg.color_threshold||surf.cylinder2(i,3)<-EC.edg.color_threshold
                    ci=1;
                else
                    ci=64;
                end
        end
    case 4
        if length_cyl>EC.edg.color_distance
            ci=1;
        else
            ci=64;
        end
end
set(Line,'FaceColor',EC.edg.CM(ci,:));
set(Line,'EdgeColor','none');
set(Line,'FaceAlpha',0.7);
set(Line,'EdgeAlpha',0);


function a=FileView
global FLAG
global surf
global EC

set(gcf,'Renderer',EC.glb.render);
a=[];
if FLAG.Loadfile==0
    H=errordlg('Please read files first!');
    uiwait(H);
    if exist('BrainNet_Background.jpg','file')==2
        imshow(imread('BrainNet_Background.jpg'));
    end
else
    switch EC.lot.view
        case 1
            switch FLAG.Loadfile
                case 1
                    a=PlotMesh1(surf,0);
                case 2
                    NodePrepare;
                    a=PlotNode1(surf,a,2,EC);
                case 3
                    NodePrepare;
                    a=PlotMesh1(surf,1);
                    a=PlotNode1(surf,a,2,EC);
                case 6
                    NodePrepare;
                    NetPrepare;
                    a=PlotNode1(surf,a,1,EC);
                    PlotLine1(surf);
                case 7
                    NodePrepare;
                    NetPrepare;
                    a=PlotMesh1(surf,1);
                    a=PlotNode1(surf,a,1,EC);
                    PlotLine1(surf);
                case 9
                    if FLAG.MAP==2
                        MapPrepare;
                    end %%% Edited by Mingrui Xia,111027, move FLAG.IsCalledByREST judgement into function MapCMPrepare.
                    %                     if isfield(FLAG,'IsCalledByREST') && FLAG.IsCalledByREST==1 % YAN Chao-Gan 111023. REST will define the colormap from outside
                    %                         low=EC.vol.nx;high=EC.vol.px;
                    %                     else
                    [low high]=MapCMPrepare;
                    %                     end
                    a=MapMesh1(surf,low,high,0);
                case 11 %%% Added by Mingrui Xia, 20111116, add 11 for volume and node mode
                    if FLAG.MAP==2
                        MapPrepare;
                    end
                    [low high]=MapCMPrepare;
                    a=MapMesh1(surf,low,high,1);
                    NodePrepare;
                    a=PlotNode1(surf,a,2,EC);
                case 15 %%% Added by Mingrui Xia, 20120210, add 15 for volume, node and edge mode
                    if FLAG.MAP==2
                        MapPrepare;
                    end
                    [low high]=MapCMPrepare;
                    a=MapMesh1(surf,low,high,1);
                    NodePrepare;
                    NetPrepare;
                    a=PlotNode1(surf,a,1,EC);
                    PlotLine1(surf);
            end
        case 2
            switch FLAG.Loadfile
                case 1
                    [t,tl,tr,vl,vr,h1,w1,cut,cuv]=CutMesh(surf);
                    if cut<t
                        Viewer=GenerateView8(h1,w1);
                        Surfmatrix=GenertateSurfM8(surf,tl,tr,vl,vr,cuv);
                        a=PlotMesh8(Viewer,Surfmatrix,0);
                    else
                        Viewer=GenerateView6(w1);
                        a=PlotMesh6(Viewer,surf,0);
                    end
                case 2
                    NodePrepare;
                    w1=NoMeshPage(surf);
                    Viewer=GenerateView6(w1);
                    a=PlotNode6(Viewer,surf,0,2,EC);
                case 3
                    NodePrepare;
                    [t,tl,tr,vl,vr,h1,w1,cut,cuv]=CutMesh(surf);
                    if cut<t
                        [centerX,flag]=JudgeNode(surf,vl,vr);
                        Viewer=GenerateView8(h1,w1);
                        Surfmatrix=GenertateSurfM8(surf,tl,tr,vl,vr,cuv);
                        a=PlotMesh8(Viewer,Surfmatrix,1);
                        PlotNode8(surf,a,flag,centerX,2,EC);
                    else
                        Viewer=GenerateView6(w1);
                        a=PlotMesh6(Viewer,surf,1);
                        PlotNode6(Viewer,surf,a,2,EC);
                    end
                case 6
                    NodePrepare;
                    NetPrepare;
                    w1=NoMeshPage(surf);
                    Viewer=GenerateView6(w1);
                    a=PlotNode6(Viewer,surf,0,1,EC);
                    PlotLine6(surf,a);
                case 7
                    NodePrepare;
                    NetPrepare;
                    [t,tl,tr,vl,vr,h1,w1,cut,cuv]=CutMesh(surf);
                    if cut<t
                        [centerX,flag]=JudgeNode(surf,vl,vr);
                        Viewer=GenerateView8(h1,w1);
                        Surfmatrix=GenertateSurfM8(surf,tl,tr,vl,vr,cuv);
                        a=PlotMesh8(Viewer,Surfmatrix,1);
                        PlotNode8(surf,a,flag,centerX,1,EC);
                        PlotLine8(surf,a,flag,centerX);
                    else
                        Viewer=GenerateView6(w1);
                        a=PlotMesh6(Viewer,surf,1);
                        PlotNode6(Viewer,surf,a,1,EC);
                        PlotLine6(surf,a);
                    end
                case 9
                    [t,tl,tr,vl,vr,h1,w1,cut,cuv]=CutMesh(surf);  %%% Edited by Mingrui Xia,111027, move FLAG.IsCalledByREST judgement into function MapCMPrepare.
                    %                     if isfield(FLAG,'IsCalledByREST') && FLAG.IsCalledByREST==1 % YAN Chao-Gan 111023. REST will define the colormap from outside
                    %                         low=EC.vol.nx;high=EC.vol.px;
                    %                     else
                    [low high]=MapCMPrepare;
                    %                     end
                    if FLAG.MAP==2
                        MapPrepare;
                    end
                    if cut<t
                        Viewer=GenerateView8(h1,w1);
                        Surfmatrix=GenertateSurfM8(surf,tl,tr,vl,vr,cuv);
                        a=MapMesh8(Viewer,Surfmatrix,low,high,0);
                    else
                        Viewer=GenerateView6(w1);
                        a=MapMesh6(Viewer,surf,low,high,0);
                    end
                case 11 %%% Added by Mingrui Xia, 20111116, add 11 for volume and node mode
                    [t,tl,tr,vl,vr,h1,w1,cut,cuv]=CutMesh(surf);
                    [low high]=MapCMPrepare;
                    if FLAG.MAP==2
                        MapPrepare;
                    end
                    NodePrepare;
                    if cut<t
                        [centerX,flag]=JudgeNode(surf,vl,vr);
                        Viewer=GenerateView8(h1,w1);
                        Surfmatrix=GenertateSurfM8(surf,tl,tr,vl,vr,cuv);
                        a=MapMesh8(Viewer,Surfmatrix,low,high,1);
                        PlotNode8(surf,a,flag,centerX,2,EC);
                    else
                        Viewer=GenerateView6(w1);
                        a=MapMesh6(Viewer,surf,low,high,1);
                        PlotNode6(Viewer,surf,a,2,EC);
                    end
                case 15 %%% Added by Mingrui Xia, 20120210, add 15 for volume, node and edge mode
                    [t,tl,tr,vl,vr,h1,w1,cut,cuv]=CutMesh(surf);
                    [low high]=MapCMPrepare;
                    if FLAG.MAP==2
                        MapPrepare;
                    end
                    NodePrepare;
                    NetPrepare;
                    if cut<t
                        [centerX,flag]=JudgeNode(surf,vl,vr);
                        Viewer=GenerateView8(h1,w1);
                        Surfmatrix=GenertateSurfM8(surf,tl,tr,vl,vr,cuv);
                        a=MapMesh8(Viewer,Surfmatrix,low,high,1);
                        PlotNode8(surf,a,flag,centerX,1,EC);
                        PlotLine8(surf,a,flag,centerX);
                    else
                        Viewer=GenerateView6(w1);
                        a=MapMesh6(Viewer,surf,low,high,1);
                        PlotNode6(Viewer,surf,a,1,EC);
                        PlotLine6(surf,a);
                    end
            end
            
        case 3  %%% YAN Chao-Gan 111023 Added BEGIN. For medium view (4 views). Only finished for volume view mode
            switch FLAG.Loadfile
                case 9
                    [t,tl,tr,vl,vr,h1,w1,cut,cuv]=CutMesh(surf); %%% Edited by Mingrui Xia,111027, move FLAG.IsCalledByREST judgement into function MapCMPrepare.
                    %                     if isfield(FLAG,'IsCalledByREST') && FLAG.IsCalledByREST==1 % YAN Chao-Gan 111023. REST will define the colormap from outside
                    %                         low=EC.vol.nx;high=EC.vol.px;
                    %                     else
                    [low high]=MapCMPrepare;
                    %                     end
                    if FLAG.MAP==2
                        MapPrepare;
                    end
                    Viewer=GenerateView4;
                    Surfmatrix=GenertateSurfM4(surf,tl,tr,vl,vr,cuv);
                    a=MapMesh4(Viewer,Surfmatrix,low,high,0);%%% YAN Chao-Gan 111023 Added END. %%%
                case 1 %%% Mingrui Xia 110226 Added below.
                    [t,tl,tr,vl,vr,h1,w1,cut,cuv]=CutMesh(surf);
                    Viewer=GenerateView4;
                    Surfmatrix=GenertateSurfM4(surf,tl,tr,vl,vr,cuv);
                    a=PlotMesh4(Viewer,Surfmatrix,0);
                case 3
                    NodePrepare;
                    [t,tl,tr,vl,vr,h1,w1,cut,cuv]=CutMesh(surf);
                    [centerX,flag]=JudgeNode(surf,vl,vr);
                    Viewer=GenerateView4;
                    Surfmatrix=GenertateSurfM4(surf,tl,tr,vl,vr,cuv);
                    a=PlotMesh4(Viewer,Surfmatrix,1);
                    PlotNode4(surf, a, flag, centerX, 2, EC);
                case 7
                    NodePrepare;
                    NetPrepare;
                    [t,tl,tr,vl,vr,h1,w1,cut,cuv]=CutMesh(surf);
                    [centerX,flag]=JudgeNode(surf,vl,vr);
                    Viewer=GenerateView4;
                    Surfmatrix=GenertateSurfM4(surf,tl,tr,vl,vr,cuv);
                    a=PlotMesh4(Viewer,Surfmatrix,1);
                    PlotNode4(surf,a,flag,centerX,1,EC);
                    PlotLine4(surf,a,flag,centerX);
                case 11 %%% Added by Mingrui Xia, 20111116, add 11 for volume and node mode
                    [t,tl,tr,vl,vr,h1,w1,cut,cuv]=CutMesh(surf);
                    [centerX,flag]=JudgeNode(surf,vl,vr);
                    [low high]=MapCMPrepare;
                    if FLAG.MAP==2
                        MapPrepare;
                    end
                    NodePrepare;
                    Viewer=GenerateView4;
                    Surfmatrix=GenertateSurfM4(surf,tl,tr,vl,vr,cuv);
                    a=MapMesh4(Viewer,Surfmatrix,low,high,1);
                    PlotNode4(surf, a, flag, centerX, 2, EC);
                case 15 %%% Added by Mingrui Xia, 20120210, add 15 for volume, node and edge mode
                    [t,tl,tr,vl,vr,h1,w1,cut,cuv]=CutMesh(surf);
                    [centerX,flag]=JudgeNode(surf,vl,vr);
                    [low high]=MapCMPrepare;
                    if FLAG.MAP==2
                        MapPrepare;
                    end
                    NodePrepare;
                    NetPrepare;
                    Viewer=GenerateView4;
                    Surfmatrix=GenertateSurfM4(surf,tl,tr,vl,vr,cuv);
                    a=MapMesh4(Viewer,Surfmatrix,low,high,1);
                    PlotNode4(surf, a, flag, centerX, 1, EC);
                    PlotLine4(surf,a,flag,centerX);
            end
    end
end

function MapPrepare
global surf
surf.coord(4,:)=1;
index=round(surf.hdr.mat\surf.coord);
surf.T=zeros(1,surf.vertex_number);
for i=1:surf.vertex_number
    surf.T(i)=surf.mask(index(1,i),index(2,i),index(3,i));
end

function [low high]=MapCMPrepare
global EC
global FLAG %%% Added by Mingrui Xia, 111027, judge if is called by REST.
if isfield(FLAG,'IsCalledByREST') && FLAG.IsCalledByREST==1
%     switch EC.vol.display %% Edited by Mingrui Xia, 20120414, fix a bug of compatibility with REST.
%         case 1
            low=EC.vol.nx;
            high=EC.vol.px;
%         case 2
%             low=EC.vol.pn;
%             high=EC.vol.px;
%         case 3
%             low=EC.vol.nx;
%             high=EC.vol.nn;
%     end
else
    switch EC.vol.color_map
        case 1
            EC.vol.CMt=jet(1000);
        case 2
            EC.vol.CMt=hsv(1000);
        case 3
            EC.vol.CMt=hot(1000);
        case 4
            EC.vol.CMt=cool(1000);
        case 5
            EC.vol.CMt=spring(1000);
        case 6
            EC.vol.CMt=summer(1000);
        case 7
            EC.vol.CMt=autumn(1000);
        case 8
            EC.vol.CMt=winter(1000);
        case 9
            EC.vol.CMt=gray(1000);
        case 10
            EC.vol.CMt=bone(1000);
        case 11
            EC.vol.CMt=copper(1000);
        case 12
            EC.vol.CMt=pink(1000);
        case 13
            EC.vol.CMt=lines(1000);
        case 14
            EC.vol.CMt=rand(1000,3);
        case 15 %%% Added by Mingrui Xia, 111027. seven new colorbar.
            EC.vol.CMt = [zeros(1,500),ones(1,500);linspace(1,0,500),linspace(0,1,500);ones(1,500),zeros(1,500)]';
        case 16
            EC.vol.CMt = colorcube(1000);
        case 17
            EC.vol.CMt = flag(1000);
        case 18
            EC.vol.CMt = prism(1000);
        case 19
            EC.vol.CMt = white(1000);
        case 20
            EC.vol.CMt = [ones(1,1000); linspace(0,1,1000); zeros(1,1000)]';
        case 21
            EC.vol.CMt = [zeros(1,1000); linspace(1,0,1000); ones(1,1000)]';
        case 22 % Added by Mingrui Xia, 20120113, Xjviewer negative colorbar.
            EC.vol.CMt = [zeros(1,1000); linspace(0,1,1000); ones(1,1000)]';
    end
    switch EC.vol.display
        case 1 %%% Edited by Mingrui Xia, 111025, change algorithm for color mapping.
            EC.vol.CM=AdjustColorMap(EC.vol.CMt,EC.vol.null,EC.vol.nx,EC.vol.nn,EC.vol.pn,EC.vol.px);
            low=EC.vol.nx;
            high=EC.vol.px;
        case 2
            low=EC.vol.pn;
            high=EC.vol.px;
            ind = round(linspace(1, size(EC.vol.CMt, 1), 999));
            EC.vol.CM(2:1000,:)=EC.vol.CMt(ind,:);
            EC.vol.CM(1,:)=EC.vol.null;
        case 3
            low=EC.vol.nx;
            high=EC.vol.nn;
            ind = round(linspace(1, size(EC.vol.CMt, 1), 999));
            EC.vol.CM(1:999,:)=EC.vol.CMt(ind,:);
            EC.vol.CM(1000,:)=EC.vol.null;
    end
end

function NewColorMap=AdjustColorMap(OriginalColorMap,NullColor,NMax,NMin,PMin,PMax)
%%% Added by Mingrui Xia, 20111025, to adjust colormap.
% Adjust the colormap to leave blank to values under threshold, the orginal color map with be set into [NMax NMin] and [PMin PMax]. Written by YAN Chao-Gan, 111023
% Input: OriginalColorMap - the original color map
%        NullColor - The values between NMin and PMin will be set to this color (leave blank)
%        NMax, NMin, PMin, PMax - set the axis of colorbar (the orginal color map with be set into [NMax NMin] and [PMin PMax])
% Output: NewColorMap - the generated color map, a 1000 by 3 matrix.
TempColorMap = OriginalColorMap;
% OriginalColorMap = zeros(1000,3);
ind = round(linspace(1,size(TempColorMap,1),1000));
OriginalColorMap = TempColorMap(ind,:);
NewColorMap = repmat(NullColor,[1000 1]);
% ColorLen=size(OriginalColorMap,1);
% NegativeColorSegment = fix(1000*(NMin-NMax)/(PMax-NMax)/(ColorLen/2));
% for iColor=1:fix(ColorLen/2)
%     NewColorMap((iColor-1)*NegativeColorSegment+1:(iColor)*NegativeColorSegment,:) = repmat(OriginalColorMap(iColor,:),[NegativeColorSegment 1]);
% end
%
% PositiveColorSegment = fix(1000*(PMax-PMin)/(PMax-NMax)/(ColorLen/2));
% for iColor=ColorLen:-1:ceil(ColorLen/2+1)
%     NewColorMap(end-(ColorLen-iColor+1)*PositiveColorSegment+1:end-(ColorLen-iColor)*PositiveColorSegment,:) = repmat(OriginalColorMap(iColor,:),[PositiveColorSegment 1]);
% end
NegativeColorSegment = fix(1000*(NMin-NMax)/(PMax-NMax)); %%% Edited by Mingrui Xia 20111025, use linear sampling method.
if NegativeColorSegment == 0
    NegativeColorSegment = 1;
end
NegativeIndex = round(linspace(1,500,NegativeColorSegment));
NewColorMap(1:NegativeColorSegment,:) = OriginalColorMap(NegativeIndex,:);
PositiveColorSegment = fix(1000*(PMax-PMin)/(PMax-NMax));
if PositiveColorSegment == 0
    PositiveColorSegment = 1;
end
PositiveIndex = round(linspace(501,1000,PositiveColorSegment));
NewColorMap(end-PositiveColorSegment+1:end,:) = OriginalColorMap(PositiveIndex,:);


% --------------------------------------------------------------------
function NV_m_save_Callback(hObject, eventdata, handles)
% hObject    handle to NV_m_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global EC
[filename,pathname]=uiputfile({'*.TIF','TIFF 24-bit';'*.BMP','BMP 24-bit';'*.EPS','EPS color';'*.JPG','JPEG 24-bit';'*.PNG','PNG 24-bit'},'Save Image');
if isequal(filename,0)||isequal(pathname,0)
    return;
else
    fpath=fullfile(pathname,filename);
    [pathstr, name, ext] = fileparts(fpath);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'inch');
    set(gcf,'Paperposition',[1 1 EC.img.width/EC.img.dpi EC.img.height/EC.img.dpi]);
    switch ext
        case '.PNG'
            print(gcf,fpath,'-dpng',['-r',num2str(EC.img.dpi)])
        case '.TIF'
            print(gcf,fpath,'-dtiff',['-r',num2str(EC.img.dpi)])
        case '.JPG'
            print(gcf,fpath,'-djpeg',['-r',num2str(EC.img.dpi)])
        case '.BMP'
            print(gcf,fpath,'-dbmp',['-r',num2str(EC.img.dpi)])
        case '.EPS'
            print(gcf,fpath,'-depsc',['-r',num2str(EC.img.dpi)])
    end
    msgbox('Image has saved!','Success','help');
end


% --------------------------------------------------------------------
function NV_m_es_Callback(hObject, eventdata, handles)
% hObject    handle to NV_m_es (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FLAG
global a
H=BrainNet_Option; %%% Edited by Mingrui Xia, 111027, changed option panel function name.
uiwait(H);
while FLAG.EC==2
    FLAG.EC=0;
    if ~isempty(a) && mean(ishandle(a))==1
        delete(a);
    end
    axes(handles.NV_axes);
    cla;
    a=FileView;
    uiwait(H);
end
if FLAG.EC==1
    FLAG.EC=0;
    if ~isempty(a) && mean(ishandle(a))==1
        delete(a);
    end
    axes(handles.NV_axes);
    cla;
    a=FileView;
end


% --------------------------------------------------------------------
function NV_m_LF_Callback(hObject, eventdata, handles)
% hObject    handle to NV_m_LF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FLAG
global a
H=BrainNet_LoadFiles;
uiwait(H);
if FLAG.LF==1
    %     if FLAG.Loadfile~=1
    H=BrainNet_Option;
    uiwait(H);
    while FLAG.EC==2
        FLAG.EC=3;
        if ~isempty(a) && mean(ishandle(a))==1
            delete(a);
        end
        axes(handles.NV_axes);
        cla;
        a=FileView;
        uiwait(H);
    end
    if FLAG.EC==1
        FLAG.EC=0;
        if ~isempty(a) && mean(ishandle(a))==1
            delete(a);
        end
        axes(handles.NV_axes);
        cla;
        a=FileView;
    end
    FLAG.LF=0;
end


% --------------------------------------------------------------------
function NV_m_Visualize_Callback(hObject, eventdata, handles)
% hObject    handle to NV_m_Visualize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function NV_m_tools_Callback(hObject, eventdata, handles)
% hObject    handle to NV_m_tools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function NV_m_others_Callback(hObject, eventdata, handles)
% hObject    handle to NV_m_others (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function NV_m_cf_Callback(hObject, eventdata, handles)
% hObject    handle to NV_m_cf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% global FLAG % Mingrui Xia 111029. For calling from outside.
% if isfield(FLAG,'IsCalledByREST') && FLAG.IsCalledByREST==1
%     handles.NV_axes=gca(hObject);
% end
axes(handles.NV_axes);
global a
if ~isempty(a) && mean(ishandle(a))==1
    delete(a);
    a=[];
end
cla;
if exist('BrainNet_Background.jpg','file')==2
    imshow(imread('BrainNet_Background.jpg'));
end


% --------------------------------------------------------------------
function NV_m_mm_Callback(hObject, eventdata, handles)
% hObject    handle to NV_m_mm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
H=BrainNet_MergeMesh;
uiwait(H);


% --------------------------------------------------------------------
function NV_m_help_Callback(hObject, eventdata, handles)
% hObject    handle to NV_m_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function NV_m_about_Callback(hObject, eventdata, handles)
% hObject    handle to NV_m_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox({'BrainNet Viewer 1.2 Released 20120412';'By Mingrui Xia';'mingruixia@gmail.com'},'About...','help');


% --------------------------------------------------------------------
% function NV_m_batch_Callback(hObject, eventdata, handles)
% % hObject    handle to NV_m_batch (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% global surf
% global FLAG
% global a
% global EC
% FLAG.Loadfile=3;
% surf=[];
% [filename,pathname]=uigetfile({'*.txt','Text Files (*.txt)'},'Select List File');
% fpath=fullfile(pathname,filename);
% fid=fopen(fpath);
% b=textscan(fid,'%s');
% fclose(fid);
% List=b{1,1};
%
% [filename2,pathname2]=uigetfile({'*.nv','NetViewer Files (*.nv)';'*.mesh','BrainVISA Mesh (*.mesh)';'*.pial','FreeSurfer Mesh (*.pial)';'*.*','All Files (*.*)'});
% fpath=fullfile(pathname2,filename2);
% fid=fopen(fpath);
% surf.vertex_number=fscanf(fid,'%f',1);
% surf.coord=fscanf(fid,'%f',[3,surf.vertex_number]);
% surf.ntri=fscanf(fid,'%f',1);
% surf.tri=fscanf(fid,'%d',[3,surf.ntri])';
% fclose(fid);
%
% [filename3,pathname3]=uiputfile({'*.TIF','TIFF 24-bit';'*.BMP','BMP 24-bit';'*.EPS','EPS color';'*.JPG','JPEG 24-bit';'*.PNG','PNG 24-bit'},'Save Image');
% if isequal(filename,0)||isequal(pathname,0)
%     return;
% else
%     fpath=fullfile(pathname3,filename3);
%     [pathstr, name, ext] = fileparts(fpath);
% end
% H=BrainNet_Option;
% uiwait(H);
% for i=1:length(List)
%     load([pathname List{i} '.mat']);
%     surf.nsph=size(node,1);
%     surf.sphere=node;
%     fid=fopen([pathname List{i} '.txt']);
%     b=textscan(fid,'%s');
%     fclose(fid);
%     surf.label=b{1,1};
%     axes(handles.NV_axes);
%     cla;
%     if ~isempty(a)
%         delete(a);
%         a=[];
%     end
%     a=FileView;
%     set(gcf, 'PaperPositionMode', 'manual');
%     set(gcf, 'PaperUnits', 'inch');
%     set(gcf,'Paperposition',[1 1 EC.Img_sz(1)/EC.Img_sz(3) EC.Img_sz(2)/EC.Img_sz(3)]);
%     switch ext
%         case '.PNG'
%             print(gcf,[pathname3 name List{i} ext],'-dpng',['-r',num2str(EC.Img_sz(3))])
%         case '.TIF'
%             print(gcf,[pathname3 name List{i} ext],'-dtiff',['-r',num2str(EC.Img_sz(3))])
%         case '.JPG'
%             print(gcf,[pathname3 name List{i} ext],'-djpeg',['-r',num2str(EC.Img_sz(3))])
%         case '.BMP'
%             print(gcf,[pathname3 name List{i} ext],'-dbmp',['-r',num2str(EC.Img_sz(3))])
%         case '.EPS'
%             print(gcf,[pathname3 name List{i} ext],'-depsc',['-r',num2str(EC.Img_sz(3))])
%     end
% end
% msgbox('Image has saved!','Success','help');


% --------------------------------------------------------------------
function LoadFile_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to LoadFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FLAG
global a
global EC
H=BrainNet_LoadFiles;
uiwait(H);
if FLAG.LF==1
    EC.vol.display = [];
    EC.vol.pn = [];
    EC.vol.px = [];
    EC.vol.nn = [];
    EC.vol.nx = [];
    %     if FLAG.Loadfile~=1
    H=BrainNet_Option;
    uiwait(H);
    while FLAG.EC==2
        FLAG.EC=3;
        if ~isempty(a) && mean(ishandle(a))==1
            delete(a);
        end
        axes(handles.NV_axes);
        cla;
        a=FileView;
        uiwait(H);
    end
    if FLAG.EC==1
        FLAG.EC=0;
        if ~isempty(a) && mean(ishandle(a))==1
            delete(a);
        end
        axes(handles.NV_axes);
        cla;
        a=FileView;
    end
    FLAG.LF=0;
end


% --------------------------------------------------------------------
function SaveImage_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to SaveImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global EC
[filename,pathname]=uiputfile({'*.TIF','TIFF 24-bit';'*.BMP','BMP 24-bit';'*.EPS','EPS color';'*.JPG','JPEG 24-bit';'*.PNG','PNG 24-bit'},'Save Image');
if isequal(filename,0)||isequal(pathname,0)
    return;
else
    fpath=fullfile(pathname,filename);
    [pathstr, name, ext] = fileparts(fpath);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'inch');
    set(gcf,'Paperposition',[1 1 EC.img.width/EC.img.dpi EC.img.height/EC.img.dpi]);
    switch ext
        case '.PNG'
            print(gcf,fpath,'-dpng',['-r',num2str(EC.img.dpi)])
        case '.TIF'
            print(gcf,fpath,'-dtiff',['-r',num2str(EC.img.dpi)])
        case '.JPG'
            print(gcf,fpath,'-djpeg',['-r',num2str(EC.img.dpi)])
        case '.BMP'
            print(gcf,fpath,'-dbmp',['-r',num2str(EC.img.dpi)])
        case '.EPS'
            print(gcf,fpath,'-depsc',['-r',num2str(EC.img.dpi)])
    end
    msgbox('Image has saved!','Success','help');
end


% --------------------------------------------------------------------
function SagittalView_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to SagittalView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cam
global FLAG
switch FLAG.sagittal
    case 0
        view(-90,0);
        FLAG.sagittal=1;
    case 1
        view(90,0);
        FLAG.sagittal=0;
end
if ~isempty(cam)
    camlight(cam);
end


% --------------------------------------------------------------------
function AxialView_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to AxialView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cam
global FLAG
switch FLAG.axial
    case 0
        view(0,90);
        FLAG.axial=1;
    case 1
        view(0,-90);
        FLAG.axial=0;
end
if ~isempty(cam)
    camlight(cam);
end


% --------------------------------------------------------------------
function CoronalView_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to CoronalView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cam
global FLAG
switch FLAG.coronal
    case 0
        view(180,00);
        FLAG.coronal=1;
    case 1
        view(0,0);
        FLAG.coronal=0;
end
if ~isempty(cam)
    camlight(cam);
end


% --------------------------------------------------------------------
function Presentation_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Presentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cam
global FLAG
while FLAG.Rotate<1
    camorbit(5,0,'camera');
    camlight(cam);
    drawnow;
end
FLAG.Rotate=0;


% --------------------------------------------------------------------
function Stop_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FLAG
FLAG.Rotate=1;


% --------------------------------------------------------------------
function NV_m_movie_Callback(hObject, eventdata, handles)
% hObject    handle to NV_m_movie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cam
[filename,pathname]=uiputfile({'*.avi','AVI movie'},'Save Movie');
if isequal(filename,0)||isequal(pathname,0)
    return;
else
    fpath=fullfile(pathname,filename);
    vidObj = VideoWriter(fpath);
    open(vidObj);
    for num=1:360
        camorbit(1,0,'camera');
        camlight(cam);
        drawnow;
        print(gcf,[pathname,'temp.bmp'],'-dbmp');
        tempimg=imread([pathname,'temp.bmp']);
        currFrame=im2frame(tempimg);
        currFrame.cdata=imresize(currFrame.cdata,[534,735]);
        writeVideo(vidObj,currFrame);
    end
    close(vidObj);
    delete([pathname,'temp.bmp']);
    msgbox('Movie Saved!','Success','help');
end


% --------------------------------------------------------------------
function NV_m_so_Callback(hObject, eventdata, handles)
% hObject    handle to NV_m_so (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global EC
[filename,pathname]=uiputfile({'*.mat','MAT-files (*.mat)'},'Save Option');
if isequal(filename,0)||isequal(pathname,0)
    return;
else
    fpath=fullfile(pathname,filename);
    save(fpath,'EC');
    msgbox('Configure Saved!','Success','help');
end


% --------------------------------------------------------------------
function NV_m_option_Callback(hObject, eventdata, handles)
% hObject    handle to NV_m_option (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function NV_m_lo_Callback(hObject, eventdata, handles)
% hObject    handle to NV_m_lo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname]=uigetfile({'*.mat','MAT-files (*.mat)'},'Load Configuration');
if isequal(filename,0)||isequal(pathname,0)
    return;
else
    fpath=fullfile(pathname,filename);
    load(fpath);
    msgbox('Option Loaded!','Success','help');
end



% --------------------------------------------------------------------
function uipushtool3_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printpreview;


% --------------------------------------------------------------------
function uitoggletool1_OffCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cam
camlight(cam);


% --------------------------------------------------------------------
function NV_m_manual_Callback(hObject, eventdata, handles)
% hObject    handle to NV_m_manual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if exist('BrainNet_Manual.pdf','file')==2
    open('BrainNet_Manual.pdf');
else
    msgbox('Cannot find the manual file!','Error','error');
end


% --------------------------------------------------------------------
function NV_m_ColormapEditor_Callback(hObject, eventdata, handles)
% hObject    handle to NV_m_ColormapEditor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
colormapeditor;



% --------------------------------------------------------------------
function NV_m_ApplyColormap_Callback(hObject, eventdata, handles)
% hObject    handle to NV_m_ApplyColormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global EC
global a
EC.vol.CM = get(gcf,'Colormap');
EC.vol.color_map = 22;
MapRange = get(a(end),'CLim');
for i = 1:length(a)
    axes(a(i));
    caxis(MapRange);
end


% --------------------------------------------------------------------
function uitoggletool5_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
