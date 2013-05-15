function H_BrainNet = BrainNet_MapCfg(varargin)
% BrainNet Viewer, a graph-based brain network mapping tool, by Mingrui Xia
% Function to draw graph from commandline
%-----------------------------------------------------------
%	Copyright(c) 2012
%	State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%	Written by Mingrui Xia
%	Mail to Author:  <a href="mingruixia@gmail.com">Mingrui Xia</a>
%   Version 1.41;
%   Date 20121031;
%   Last edited 20121123
%-----------------------------------------------------------
%
% Usage:
% H_BrainNet = BrainNet_MapCfg(Filenames); Filenames can be any kinds of
% files supported by BrainNet Viewer.
%
% Example:
%
% Surface file only:
% BrainNet_MapCfg('BrainMesh_ICBM152.nv');
%
% Surface and node files:
% BrainNet_MapCfg('BrainMesh_ICBM152.nv','Node_AAL90.node');
%
% Surface, node and edge files:
% BrainNet_MapCfg('BrainMesh_ICBM152.nv','Node_AAL90.node','Edge_AAL90_Binary.edge');
%
% Surface, node, edge and pre-saved option files:
% BrainNet_MapCfg('BrainMesh_ICBM152.nv','Node_AAL90.node','Edge_AAL90_Binary.edge','Cfg.mat');
%
% Surface, volume and pre-saved option files:
% BrainNet_MapCfg('BrainMesh_ICBM152_smoothed.nv','OneSample_T.nii','Cfg.mat');
%
% Surface file only and save to image file (jpe, tif, bmp, png, and eps are supported)
% BrainNet_MapCfg('BrainMesh_ICBM152.nv','Surf.jpg');
%
% If the pre-saved option file is not input, BNV draw graphs in default
% settings.



% Initialize input file names
SurfFileName = '';
NodeFileName = '';
EdgeFileName = '';
VolFileName = '';
CfgFileName = '';
PicFileEnable = '';

for i = 1:nargin-1
    [path, fname, ext] = fileparts(varargin{i});
    switch ext
        case '.nv'
            SurfFileName = varargin{i};
        case '.node'
            NodeFileName = varargin{i};
        case '.edge'
            EdgeFileName = varargin{i};
        case {'.nii','.img','.txt'}
            VolFileName = varargin{i};
        case '.mat'
            CfgFileName = varargin{i};
        case {'.jpg','.tif','.bmp','.png','.eps'}
            PicFileEnable = varargin{i};
    end
end
ind=varargin{nargin};

% Start BrainNet
[H_BrainNet] = BrainNet;
global FLAG
FLAG.Loadfile = 0;
FLAG.IsCalledByCMD = 1;
global EC
global surf

% Load Surf file
if ~isempty(SurfFileName)
    if ~exist('SurfFileName','var')
        [BrainNetViewerPath, fileN, extn] = fileparts(which('BrainNet.m'));
        SurfFileName=[BrainNetViewerPath,filesep,'Data',filesep,...
            'SurfTemplate',filesep,'BrainMesh_ICBM152.nv'];
    end
    fid=fopen(SurfFileName);
    surf.vertex_number=fscanf(fid,'%f',1);
    surf.coord=fscanf(fid,'%f',[3,surf.vertex_number]);
    surf.ntri=fscanf(fid,'%f',1);
    surf.tri=fscanf(fid,'%d',[3,surf.ntri])';
    fclose(fid);
    FLAG.Loadfile = FLAG.Loadfile + 1;
end

% Load Node file
if ~isempty(NodeFileName)
    fid=fopen(NodeFileName);
    i=0;
    while ~feof(fid)
        curr=fscanf(fid,'%f',5);
        if ~isempty(curr)
            i=i+1;
            textscan(fid,'%s',1);
        end
    end
    surf.nsph=i;
    fclose(fid);
    surf.sphere=zeros(surf.nsph,5);
    surf.label=cell(surf.nsph,1);
    fid=fopen(NodeFileName);
    i=0;
    while ~feof(fid)
        curr=fscanf(fid,'%f',5);
        if ~isempty(curr)
            i=i+1;
            surf.sphere(i,1:5)=curr;
            surf.label{i}=textscan(fid,'%s',1);
        end
    end
    fclose(fid);
    FLAG.Loadfile = FLAG.Loadfile + 2;
end

% Load Edge file
if ~isempty(EdgeFileName)
    surf.net=load(EdgeFileName);
    FLAG.Loadfile = FLAG.Loadfile + 4;
end


% Load Volume file
if ~isempty(VolFileName)
    [path, fname, ext] = fileparts(VolFileName);
    switch ext
        case {'.nii','.img'}
            [BrainNetPath] = fileparts(which('BrainNet.m'));
            BrainNet_SPMPath = fullfile(BrainNetPath, 'BrainNet_spm8_files');
            if exist('spm.m','file')
                surf.hdr=spm_vol(VolFileName);
                surf.mask=spm_read_vols(surf.hdr);
            else
                addpath(BrainNet_SPMPath);
                surf.hdr=BrainNet_spm_vol(VolFileName);
                surf.mask=BrainNet_spm_read_vols(surf.hdr);
                rmpath(BrainNet_SPMPath);
            end
            FLAG.MAP = 2;
            FLAG.Loadfile = FLAG.Loadfile + 8;
            EC.vol.px = max(surf.mask(:));
            EC.vol.nx = min(surf.mask(:));
            EC.msh.alpha = 1;
        case '.txt' %% Add by Mingrui, support text file
            surf.T=load(VolFileName);
            FLAG.MAP = 1;
            FLAG.Loadfile = FLAG.Loadfile + 8;
            EC.vol.px = max(surf.T(:));
            EC.vol.nx = min(surf.T(:));
    end
    EC.vol.display = 1;
    EC.vol.pn = 0;
    EC.vol.nn = 0;
end

% Load Configure file
if ~isempty(CfgFileName)
    load(CfgFileName);
end

if FLAG.Loadfile ==1 || FLAG.Loadfile == 9 % Add by Mingrui, 20121123, set mesh opacity to 1
    EC.msh.alpha = 1;
end


%superior view

for i=1:length(ind.orig.sup)
rois=find(surf.sphere(:,1)==ind.orig.sup(i,1)&surf.sphere(:,2)==ind.orig.sup(i,2));
outlier_rois = rois;
if ~isempty(outlier_rois)
surf.sphere(outlier_rois,1:2)=repmat(ind.edit.sup(i,:),length(outlier_rois),1);
end
end

%lateral view

% Here I find ROIs and co-ordinates of outliers
for i=1:length(ind.orig.lat)
    rois=find(surf.sphere(:,2)==ind.orig.lat(i,1)&surf.sphere(:,3)==ind.orig.lat(i,2));
    outlier_rois = rois;
    if ~isempty(outlier_rois)
        surf.sphere(outlier_rois,2:3)=repmat(ind.edit.lat(i,:),length(outlier_rois),1);
    end
end

%anterior view

for i=1:length(ind.orig.ant)
rois=find(surf.sphere(:,1)==ind.orig.ant(i,1)&surf.sphere(:,3)==ind.orig.ant(i,2));
outlier_rois = rois;
if ~isempty(outlier_rois)
surf.sphere(outlier_rois,[1 3])=repmat(ind.edit.ant(i,:),length(outlier_rois),1);
end
end

save_view={'lateral','superior','anterior'};
for i=1:3
    EC.lot.view_direction=i;
    EC.edg.CM=zeros(max(ind.CM(:,1)),3);
    EC.edg.CM(ind.CM(:,1),:)=ind.CM(:,2:4);
    % Draw
    set(H_BrainNet,'handlevisib','on');
    BrainNet('NV_m_nm_Callback',H_BrainNet);
    PicFileName=sprintf('%s/%s_%s.bmp',path,fname,save_view{i});
    % Save to image
    if ~isempty(PicFileEnable)
        [pathstr, name, ext] = fileparts(PicFileName);
        set(H_BrainNet, 'PaperPositionMode', 'manual');
        set(H_BrainNet, 'PaperUnits', 'inch');
        set(H_BrainNet,'Paperposition',[1 1 EC.img.width/EC.img.dpi EC.img.height/EC.img.dpi]);
        print(H_BrainNet,PicFileName,'-dbmp',['-r',num2str(EC.img.dpi)]);
    end
end
