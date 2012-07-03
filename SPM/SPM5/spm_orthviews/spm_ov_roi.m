function ret = spm_ov_roi(varargin)
% ROI tool - plugin for spm_orthviews
%
% With ROI tool it is possible to create new or modify existing mask images
% interactively. ROI tool can be launched via the spm_orthviews image
% context menu.
% While ROI tool is active, mouse buttons have the following functions:
% left       Reposition crosshairs
% middle     Perform ROI tool box selection according to selected edit mode at
%            crosshair position
% right      context menu
% 
% Menu options and prompts explained:
% Launch     Initialise ROI tool in current image
%            'Load existing ROI image? (yes/no)' 
%              If you want to modify an existing mask image (e.g. mask.img from
%              a fMRI analysis), press 'yes'. You will then be prompted to
%            'Select ROI image'
%              This is the image that will be loaded as initial ROI.
%              If you want to create a new ROI image, you will first be
%              prompted to
%            'Select image defining ROI space'
%              The image dimensions, voxel sizes and slice orientation will
%              be read from this image. Thus you can edit a ROI based on a
%              image with a resolution and slice orientation different from
%              the underlying displayed image.
%
% Once ROI tool is active, the menu consists of three parts: settings,
% edit operations and load/save operations.
% Settings
% --------
% Selection  Operation performed when pressing the middle mouse button or
% mode       by clustering operations.
%            'Set selection'
%              The selection made with the following commands will
%              be included in your ROI.
%            'Clear selection' 
%              The selection made with the following commands will
%              be excluded from your ROI.
% Box size   Set size of box to be (de)selected when pressing the
%            middle mouse button.
% Polygon    Set number of adjacent slices selected by one polygon
% slices     drawing. 
% Cluster    Set minimum cluster size for "Cleanup clusters" and
% size       "Connected cluster" operations.
% Erosion/   During erosion/dilation operations, the binary mask will be
% dilation   smoothed. At boundaries, this will result in mask values 
% threshold  that are not exactly zero or one, but somewhere in
%            between. Whether a mask will be eroded (i.e. be smaller than
%            the original) or dilated (i.e. grow) depends on this
%            threshold. A threshold below 0.5 dilates, above 0.5 erodes a
%            mask. 
% Edit actions
% ------------
% Polygon    Draw an outline on one of the 3 section images. Voxels
%            within the outline will be added to the ROI. The same
%            outline can be applied to a user-defined number of
%            consecutive slices around the current crosshair position.
% Threshold  You will be prompted to enter a [min max] threshold. Only
%            those voxels in the ROI image where the intensities of the
%            underlying image are within the [min max] range will survive
%            this operation.
% Connected  Select only voxels that are connected to the voxel at
% cluster    current crosshair position through the ROI.
% Cleanup    Keep only clusters that are larger than a specified cluster 
% clusters   size.
% Erode/     Erode or dilate a mask, using the current erosion/dilation
% Dilate     threshold.
% Invert     Invert currently defined ROI
% Clear      Clear ROI, but keep ROI space information
% Add ROI from file(s)
%            Add ROIs from file(s) into current ROI set. According to the
%            current edit mode voxels unequal zero will be set or
%            cleared. The image files will be resampled and thus do not
%            need to have the same orientation or voxel size as the
%            original ROI.
% Save actions
% ------------
% Save       Save ROI image
% Save As    Save ROI image under a new file name
% Quit       Quit ROI tool
%
% This routine is a plugin to spm_orthviews for SPM5. For general help about
% spm_orthviews and plugins type
%             help spm_orthviews
% at the matlab prompt.
%_____________________________________________________________________________
% $Id: spm_ov_roi.m 2672 2009-01-30 13:32:08Z volkmar $

% Note: This plugin depends on the blobs set by spm_orthviews('addblobs',...) 
% They should not be removed while ROI tool is active and no other blobs be
% added. This restriction may be removed when switching to MATLAB 6.x and
% using the 'alpha' property to overlay blobs onto images.

rev = '$Revision: 2672 $';

global st;
if isempty(st)
  error('roi: This routine can only be called as a plugin for spm_orthviews!');
end;

if nargin < 2
  error('roi: Wrong number of arguments. Usage: spm_orthviews(''roi'', cmd, volhandle, varargin)');
end;

cmd = lower(varargin{1});
volhandle = varargin{2};

toset = [];
toclear = [];
tochange = [];
update_roi = 0;

switch cmd
 case 'init'
  spm('pointer','watch');
  Vroi = spm_vol(varargin{3});
  switch varargin{4} % loadasroi
  case 1,
    roi = spm_read_vols(Vroi)>0;
    [x y z] = ndgrid(1:Vroi.dim(1),1:Vroi.dim(2),1:Vroi.dim(3));
    xyz = [x(roi(:))'; y(roi(:))'; z(roi(:))'];
  case {0,2} % ROI space image or SPM mat
    Vroi = rmfield(Vroi,'private');
    roi = zeros(Vroi.dim(1:3));
    Vroi.fname = fileparts(Vroi.fname); % save path
    Vroi.dt(1) = spm_type('uint8');
    xyz = varargin{5};
    if ~isempty(xyz)
	ind = sub2ind(Vroi.dim(1:3),xyz(1,:),xyz(2,:),xyz(3,:));
	roi(ind) = 1;
    end;
  end;
  Vroi.pinfo(1:2) = Inf;
  clear x y z

  % draw a frame only if ROI volume different from underlying GM volume
  if any(Vroi.dim(1:3)-st.vols{volhandle}.dim(1:3))| ...
	any(Vroi.mat(:)-st.vols{volhandle}.mat(:))
    [xx1 yx1 zx1] = ndgrid(1            , 1:Vroi.dim(2), 1:Vroi.dim(3));
    [xx2 yx2 zx2] = ndgrid(Vroi.dim(1)  , 1:Vroi.dim(2), 1:Vroi.dim(3));
    [xy1 yy1 zy1] = ndgrid(1:Vroi.dim(1), 1            , 1:Vroi.dim(3));
    [xy2 yy2 zy2] = ndgrid(1:Vroi.dim(1), Vroi.dim(2)  , 1:Vroi.dim(3));
    [xz1 yz1 zz1] = ndgrid(1:Vroi.dim(1), 1:Vroi.dim(2), 1);
    [xz2 yz2 zz2] = ndgrid(1:Vroi.dim(1), 1:Vroi.dim(2), Vroi.dim(3));
      
    fxyz = [xx1(:)' xx2(:)' xy1(:)' xy2(:)' xz1(:)' xz2(:)'; ...
	    yx1(:)' yx2(:)' yy1(:)' yy2(:)' yz1(:)' yz2(:)'; ...
	    zx1(:)' zx2(:)' zy1(:)' zy2(:)' zz1(:)' zz2(:)'];
    clear xx1 yx1 zx1 xx2 yx2 zx2 xy1 yy1 zy1 xy2 yy2 zy2 xz1 yz1 zz1 xz2 yz2 zz2
    hframe = 1;
  else
    hframe = [];
    fxyz  = [];
  end;

  for k=1:3
    cb{k}=get(st.vols{volhandle}.ax{k}.ax,'ButtonDownFcn');
    set(st.vols{volhandle}.ax{k}.ax,...
	'ButtonDownFcn',...
	['switch get(gcf,''SelectionType'')',...
	 'case ''normal'', spm_orthviews(''Reposition'');',...
	 'case ''extend'', spm_orthviews(''roi'',''edit'',', ...
	 num2str(volhandle), ');',...
	 'case ''alt'', spm_orthviews(''context_menu'',''ts'',1);',...
	 'end;']);
  end;

  st.vols{volhandle}.roi = struct('Vroi',Vroi, 'xyz',xyz, 'roi',roi,...
				  'hroi',1, 'fxyz',fxyz,...
				  'hframe',hframe, 'mode','set',...
				  'tool', 'box', ...
				  'thresh',[60 140], 'box',[4 4 4],...
				  'cb',[], 'polyslices',1, 'csize',5,...
                                  'erothresh',.5);
  st.vols{volhandle}.roi.cb = cb;

  if ~isempty(st.vols{volhandle}.roi.fxyz)
    if isfield(st.vols{volhandle}, 'blobs')
      st.vols{volhandle}.roi.hframe = prod(size(st.vols{volhandle}.blobs))+1;
    end;
    spm_orthviews('addcolouredblobs',volhandle, ...
		  st.vols{volhandle}.roi.fxyz,...
		  ones(size(st.vols{volhandle}.roi.fxyz,2),1), ... 
		  st.vols{volhandle}.roi.Vroi.mat,[1 .5 .5]);
    st.vols{volhandle}.blobs{st.vols{volhandle}.roi.hframe}.max=1.3;
  end;
  update_roi=1;

 case 'edit'
  switch st.vols{volhandle}.roi.tool
      case 'box'
	  spm('pointer','watch');
	  pos = round(inv(st.vols{volhandle}.roi.Vroi.mat)* ...
		      [spm_orthviews('pos'); 1]); 
	  tmp = round((st.vols{volhandle}.roi.box-1)/2);
	  [sx sy sz] = meshgrid(-tmp(1):tmp(1), -tmp(2):tmp(2), -tmp(3):tmp(3));
	  sel = [sx(:)';sy(:)';sz(:)']+repmat(pos(1:3), 1,prod(2*tmp+1));
	  tochange = sel(:, (all(sel>0) &...
			     sel(1,:)<=st.vols{volhandle}.roi.Vroi.dim(1) & ...
			     sel(2,:)<=st.vols{volhandle}.roi.Vroi.dim(2) & ...
			     sel(3,:)<=st.vols{volhandle}.roi.Vroi.dim(3)));
	  update_roi = 1;
  
      case 'poly'
  
	  % @COPYRIGHT  :
	  %             Copyright 1993,1994 Mark Wolforth and Greg Ward, McConnell
	  %             Brain Imaging Centre, Montreal Neurological Institute, McGill
	  %             University.
	  %             Permission to use, copy, modify, and distribute this software
	  %             and its documentation for any purpose and without fee is
	  %             hereby granted, provided that the above copyright notice
	  %             appear in all copies.  The authors and McGill University make
	  %             no representations about the suitability of this software for
	  %             any purpose.  It is provided "as is" without express or
	  %             implied warranty.
	  for k = 1:3
	      if st.vols{volhandle}.ax{k}.ax == gca
		  axhandle = k;
		  break;
	      end;
	  end;
	  line_color = [1 1 0];
	  axes(st.vols{volhandle}.ax{axhandle}.ax);
	  
	  hold on;
	  Xlimits = get (st.vols{volhandle}.ax{axhandle}.ax,'XLim');
	  Ylimits = get (st.vols{volhandle}.ax{axhandle}.ax,'YLim');
	  XLimMode = get(st.vols{volhandle}.ax{axhandle}.ax,'XLimMode');
	  set(st.vols{volhandle}.ax{axhandle}.ax,'XLimMode','manual');
	  YLimMode = get(st.vols{volhandle}.ax{axhandle}.ax,'YLimMode');
	  set(st.vols{volhandle}.ax{axhandle}.ax,'YLimMode','manual');
	  ButtonDownFcn = get(st.vols{volhandle}.ax{axhandle}.ax,'ButtonDownFcn');
	  set(st.vols{volhandle}.ax{axhandle}.ax,'ButtonDownFcn','');
	  UIContextMenu = get(st.vols{volhandle}.ax{axhandle}.ax,'UIContextMenu');
	  set(st.vols{volhandle}.ax{axhandle}.ax,'UIContextMenu',[]);
	  set(st.vols{volhandle}.ax{axhandle}.ax,'Selected','on');
	  disp (['Please mark the ROI outline in the highlighted image' ...
		 ' display.']);
	  disp ('Points outside the ROI image area will be clipped to');
	  disp ('the image boundaries.');
	  disp ('Left-Click on the vertices of the ROI...');
	  disp ('Middle-Click to finish ROI selection...');
	  disp ('Right-Click to cancel...');
	  x=Xlimits(1);
	  y=Ylimits(1);
	  i=1;
	  lineHandle = [];
	  xc = 0; yc = 0; bc = 0;
	  while ~isempty(bc)
	      [xc,yc,bc] = ginput(1);
	      if isempty(xc) | bc > 1
		  if bc == 3
		      x = []; y=[];
		  end;
		  if bc == 2 | bc == 3
		      bc = [];
		      break;
		  end;
	      else
		  if xc > Xlimits(2)
		      xc = Xlimits(2);
		  elseif xc < Xlimits(1)
		      xc = Xlimits(1);
		  end;
		  if yc > Ylimits(2)
		      yc = Ylimits(2);
		  elseif yc < Ylimits(1)
		      yc = Ylimits(1);
		  end;
		  x(i) = xc;
		  y(i) = yc;
		  i=i+1;
		  if ishandle(lineHandle)
		      delete(lineHandle);
		  end;
		  lineHandle = line (x,y,ones(1,length(x)), ...
				     'Color',line_color,...
				     'parent',st.vols{volhandle}.ax{axhandle}.ax,...
				     'HitTest','off');
	      end;
	  end
	  
	  if ishandle(lineHandle)
	      delete(lineHandle);
	  end;
	  if ~isempty(x)
	      spm('pointer','watch');
	      x(i)=x(1);
	      y(i)=y(1);
	      prms=spm_imatrix(st.vols{volhandle}.roi.Vroi.mat);
	      % Code from spm_orthviews('redraw') for determining image
	      % positions
	      is   = inv(st.Space);
	      cent = is(1:3,1:3)*st.centre(:) + is(1:3,4);
	      polyoff = [0 0 0];
	      switch axhandle
		  case 1,
		      M0 = [ 1 0 0 -st.bb(1,1)+1
			     0 1 0 -st.bb(1,2)+1
			     0 0 1 -cent(3)
			     0 0 0 1];
		      polyoff(3) = st.vols{volhandle}.roi.polyslices/2;
		      polythick = prms(9);
		  case 2,
		      M0 = [ 1 0 0 -st.bb(1,1)+1
			     0 0 1 -st.bb(1,3)+1
			     0 1 0 -cent(2)
			     0 0 0 1];
		      polyoff(2) = st.vols{volhandle}.roi.polyslices/2;
		      polythick = prms(8);
		  case 3,
		      if st.mode ==0,
			  M0 = [ 0 0 1 -st.bb(1,3)+1
				 0 1 0 -st.bb(1,2)+1
				 1 0 0 -cent(1)
				 0 0 0 1];
		      else,
			  M0 = [ 0 -1 0 +st.bb(2,2)+1
				 0  0 1 -st.bb(1,3)+1
				 1  0 0 -cent(1)
				 0  0 0 1];
		      end;
		      polyoff(1) = st.vols{volhandle}.roi.polyslices/2;
		      polythick = abs(prms(7));
	      end;
	      polvx = inv(st.vols{volhandle}.roi.Vroi.mat)*st.Space*inv(M0)*...
		      [x(:)';y(:)'; zeros(size(x(:)')); ones(size(x(:)'))];
	      % Bounding volume for polygon in ROI voxel space
	      [xbox ybox zbox] = ndgrid(max(min(floor(polvx(1,:)-polyoff(1))),1):...
					min(max(ceil(polvx(1,:)+polyoff(1))),...
					    st.vols{volhandle}.roi.Vroi.dim(1)),...
					max(min(floor(polvx(2,:)-polyoff(2))),1):...
					min(max(ceil(polvx(2,:)+polyoff(2))),...
					    st.vols{volhandle}.roi.Vroi.dim(2)),...
					max(min(floor(polvx(3,:)-polyoff(3))),1):...
					min(max(ceil(polvx(3,:)+polyoff(3))),...
					    st.vols{volhandle}.roi.Vroi.dim(3)));
	      % re-transform in polygon plane
	      xyzbox = M0*is*st.vols{volhandle}.roi.Vroi.mat*[xbox(:)';ybox(:)';zbox(:)';...
		    ones(size(xbox(:)'))];
	      xyzbox = xyzbox(:,abs(xyzbox(3,:))<=.6*polythick*...
			      st.vols{volhandle}.roi.polyslices); % nearest neighbour to polygon
	      sel = logical(inpolygon(xyzbox(1,:),xyzbox(2,:),x,y));
	      xyz = inv(st.vols{volhandle}.roi.Vroi.mat)*st.Space*inv(M0)*xyzbox(:,sel);
	      if ~isempty(xyz)
		  tochange = round(xyz(1:3,:));
		  update_roi = 1;
	      end;
	  end;
	  set(st.vols{volhandle}.ax{axhandle}.ax,...
	      'Selected','off', 'XLimMode',XLimMode, 'YLimMode',YLimMode,...
	      'ButtonDownFcn',ButtonDownFcn, 'UIContextMenu',UIContextMenu);
  end;
 case 'thresh'
  spm('pointer','watch');
  rind = find(st.vols{volhandle}.roi.roi);
  [x y z]=ind2sub(st.vols{volhandle}.roi.Vroi.dim(1:3),rind);
  tmp = round(inv(st.vols{volhandle}.mat) * ...
	      st.vols{volhandle}.roi.Vroi.mat*[x'; y'; z'; ones(size(x'))]); 
  dat = spm_sample_vol(st.vols{volhandle}, ...
		       tmp(1,:), tmp(2,:), tmp(3,:), 0);
  sel = ~((st.vols{volhandle}.roi.thresh(1) < dat) & ...
	  (dat < st.vols{volhandle}.roi.thresh(2)));
  if strcmp(st.vols{volhandle}.roi.mode,'set')
      toclear = [x(sel)'; y(sel)'; z(sel)'];
  else
      toset   = [x(sel)'; y(sel)'; z(sel)'];
      toclear = st.vols{volhandle}.roi.xyz;
  end;
  update_roi = 1;
  
case 'erodilate'
    spm('pointer','watch');
    V = zeros(size(st.vols{volhandle}.roi.roi));
    spm_smooth(double(st.vols{volhandle}.roi.roi), V, 2);
    [ero(1,:) ero(2,:) ero(3,:)] = ind2sub(st.vols{volhandle}.roi.Vroi.dim(1:3),...
                                           find(V(:)>st.vols{volhandle}.roi.erothresh));
    if strcmp(st.vols{volhandle}.roi.mode,'set')
        toset   = ero;
        toclear = st.vols{volhandle}.roi.xyz;
    else
        toclear = ero;
    end;
    update_roi = 1;
    
case {'connect', 'cleanup'}
    spm('pointer','watch');    
    [V L] = spm_bwlabel(double(st.vols{volhandle}.roi.roi),6);
    sel = [];
    switch cmd
    case 'connect'
        pos = round(inv(st.vols{volhandle}.roi.Vroi.mat)* ...
                    [spm_orthviews('pos'); 1]); 
        sel = V(pos(1),pos(2),pos(3));
        if sel == 0
            sel = [];
        end;
    case 'cleanup'
        for k = 1:L
            numV(k) = sum(V(:)==k);
        end;
        sel = find(numV>st.vols{volhandle}.roi.csize);
    end;
    if ~isempty(sel)
        ind = [];
        for k=1:numel(sel)
            ind = [ind; find(V(:) == sel(k))];
        end;
	conn = zeros(3,numel(ind));
        [conn(1,:) conn(2,:) conn(3,:)] = ind2sub(st.vols{volhandle}.roi.Vroi.dim(1:3),ind);

        if strcmp(st.vols{volhandle}.roi.mode,'set')
            toset   = conn;
            toclear = st.vols{volhandle}.roi.xyz;
        else
            toclear = conn;
        end;
    end;
    update_roi = 1;
  
 case 'invert'
  spm('pointer','watch');
  toclear = st.vols{volhandle}.roi.xyz;
  [x y z] = ndgrid(1:st.vols{volhandle}.roi.Vroi.dim(1),...
		   1:st.vols{volhandle}.roi.Vroi.dim(2),...
		   1:st.vols{volhandle}.roi.Vroi.dim(3));
  if ~isempty(toclear)
    toset = setdiff([x(:)'; y(:)'; z(:)']', toclear', 'rows')';
  else
    toset = [x(:)'; y(:)'; z(:)'];
  end;
  update_roi = 1;
  clear x y z;
    
 case 'clear'
  spm('pointer','watch');
  st.vols{volhandle}.roi.roi = zeros(size(st.vols{volhandle}.roi.roi));
  st.vols{volhandle}.roi.xyz=[];
  update_roi = 1;
    
case 'addfile'
    V = spm_vol(spm_select([1 Inf],'image','Image(s) to add'));
    [x y z] = ndgrid(1:st.vols{volhandle}.roi.Vroi.dim(1),...
                     1:st.vols{volhandle}.roi.Vroi.dim(2),...
                     1:st.vols{volhandle}.roi.Vroi.dim(3));
    xyzmm = st.vols{volhandle}.roi.Vroi.mat*[x(:)';y(:)';z(:)'; ...
                        ones(1, prod(st.vols{volhandle}.roi.Vroi.dim(1:3)))];
    msk = zeros(1,prod(st.vols{volhandle}.roi.Vroi.dim(1:3)));
    for k = 1:numel(V)
        xyzvx = inv(V(k).mat)*xyzmm;
        msk = msk | spm_sample_vol(V(k), xyzvx(1,:), xyzvx(2,:), xyzvx(3,:), 0);
    end;
    [tochange(1,:) tochange(2,:) tochange(3,:)] = ind2sub(st.vols{volhandle}.roi.Vroi.dim(1:3),find(msk));
    clear xyzmm xyzvx msk
    update_roi = 1;
    
case {'save','saveas'}
  if strcmp(cmd,'saveas') | ...
          exist(st.vols{volhandle}.roi.Vroi.fname)==7
      flt = {'*.nii','NIfTI (1 file)';'*.img','NIfTI (2 files)'};
      [name pth idx] = uiputfile(flt, 'Output image');
      if ~ischar(pth)
          warning('Save cancelled');
          return;
      end;
      [p n e v] = spm_fileparts(fullfile(pth,name));
      if isempty(e)
	  e = flt{idx,1}(2:end);
      end;
      st.vols{volhandle}.roi.Vroi.fname = fullfile(p, [n e v]);
  end;
  spm('pointer','watch');
  spm_write_vol(st.vols{volhandle}.roi.Vroi, ...
		st.vols{volhandle}.roi.roi);
  spm('pointer','arrow');
  return;
    
 case 'redraw'
  % do nothing
  return;
    
 %-------------------------------------------------------------------------
 % Context menu and callbacks
 case 'context_menu'  
  item0 = uimenu(varargin{3}, 'Label', 'ROI tool');
  item1 = uimenu(item0, 'Label', 'Launch', 'Callback', ...
	  ['feval(''spm_ov_roi'',''context_init'', ', ...
	    num2str(volhandle), ');'], 'Tag', ['ROI_0_', num2str(volhandle)]);
  item2 = uimenu(item0, 'Label', 'Selection mode', ...
	  'Visible', 'off', 'Tag', ['ROI_1_', num2str(volhandle)]);
  item2_1a = uimenu(item2, 'Label', 'Set selection', 'Callback', ...
	    ['feval(''spm_ov_roi'',''context_selection'',', ...
	      num2str(volhandle), ',''set'');'], ...
	    'Tag', ['ROI_SELECTION_', num2str(volhandle)], 'Checked','on');
  item2_1b = uimenu(item2, 'Label', 'Clear selection', 'Callback', ...
	    ['feval(''spm_ov_roi'',''context_selection'',', ...
	      num2str(volhandle), ',''clear'');'], ...
	    'Tag', ['ROI_SELECTION_', num2str(volhandle)]);
  item3 = uimenu(item0, 'Label', 'Box size', 'Callback', ...
	  ['feval(''spm_ov_roi'',''context_box'', ', ...
	    num2str(volhandle), ');'], 'Visible', 'off', ...
	  'Tag', ['ROI_1_', num2str(volhandle)]);
  item4 = uimenu(item0, 'Label', 'Polygon slices', 'Callback', ...
	  ['feval(''spm_ov_roi'',''context_polyslices'', ', ...
	    num2str(volhandle), ');'], 'Visible', 'off', ...
	  'Tag', ['ROI_1_', num2str(volhandle)]);
  item5 = uimenu(item0, 'Label', 'Cluster size', 'Callback', ...
	  ['feval(''spm_ov_roi'',''context_csize'', ', ...
	    num2str(volhandle), ');'], 'Visible', 'off', ...
	  'Tag', ['ROI_1_', num2str(volhandle)]);
  item6 = uimenu(item0, 'Label', 'Erosion/Dilation threshold', 'Callback', ...
	  ['feval(''spm_ov_roi'',''context_erothresh'', ', ...
	    num2str(volhandle), ');'], 'Visible', 'off', ...
	  'Tag', ['ROI_1_', num2str(volhandle)]);
  item7 = uimenu(item0, 'Label', 'Edit tool', ...
		 'Visible', 'off', 'Tag', ['ROI_1_', num2str(volhandle)],...
                 'Separator','on');
  item7_1a = uimenu(item7, 'Label', 'Box tool', 'Callback', ...
	    ['feval(''spm_ov_roi'',''context_edit'',', ...
	      num2str(volhandle), ',''box'');'], ...
	    'Tag', ['ROI_EDIT_', num2str(volhandle)], 'Checked','on');
  item7_1b = uimenu(item7, 'Label', 'Polygon tool', 'Callback', ...
	    ['feval(''spm_ov_roi'',''context_edit'',', ...
	      num2str(volhandle), ',''poly'');'], ...
	    'Tag', ['ROI_EDIT_', num2str(volhandle)]);
  item8 = uimenu(item0, 'Label', 'Threshold', 'Callback', ...
	  ['feval(''spm_ov_roi'',''context_thresh'', ', ...
	    num2str(volhandle), ');'], 'Visible', 'off', ...
	  'Tag', ['ROI_1_', num2str(volhandle)]);
  item9 = uimenu(item0, 'Label', 'Connected cluster', 'Callback', ...
	  ['feval(''spm_ov_roi'',''connect'', ', ...
	    num2str(volhandle), ');'], 'Visible', 'off', ...
	  'Tag', ['ROI_1_', num2str(volhandle)]);
  item10 = uimenu(item0, 'Label', 'Cleanup clusters', 'Callback', ...
	  ['feval(''spm_ov_roi'',''cleanup'', ', ...
	    num2str(volhandle), ');'], 'Visible', 'off', ...
	  'Tag', ['ROI_1_', num2str(volhandle)]);
  item11 = uimenu(item0, 'Label', 'Erode/Dilate', 'Callback', ...
	  ['feval(''spm_ov_roi'',''erodilate'', ', ...
	    num2str(volhandle), ');'], 'Visible', 'off', ...
	  'Tag', ['ROI_1_', num2str(volhandle)]);
  item12 = uimenu(item0, 'Label', 'Invert', 'Callback', ...
	  ['feval(''spm_ov_roi'',''invert'', ', ...
	    num2str(volhandle), ');'], 'Visible', 'off', ...
	  'Tag', ['ROI_1_', num2str(volhandle)]);
  item13 = uimenu(item0, 'Label', 'Clear', 'Callback', ...
	  ['feval(''spm_ov_roi'',''clear'', ', ...
	    num2str(volhandle), ');'], 'Visible', 'off', ...
	  'Tag', ['ROI_1_', num2str(volhandle)]);
  item14 = uimenu(item0, 'Label', 'Add ROI from file(s)', 'Callback', ...
	  ['feval(''spm_ov_roi'',''addfile'', ', ...
	    num2str(volhandle), ');'], 'Visible', 'off', ...
	  'Tag', ['ROI_1_', num2str(volhandle)]);
  item15 = uimenu(item0, 'Label', 'Save', 'Callback', ...
                  ['feval(''spm_ov_roi'',''save'', ', ...
                   num2str(volhandle), ');'], 'Visible', 'off', ...
                  'Tag', ['ROI_1_', num2str(volhandle)],...
                  'Separator','on');
  item16 = uimenu(item0, 'Label', 'Save As', 'Callback', ...
	  ['feval(''spm_ov_roi'',''saveas'', ', ...
	    num2str(volhandle), ');'], 'Visible', 'off', ...
	  'Tag', ['ROI_1_', num2str(volhandle)]);
  item17 = uimenu(item0, 'Label', 'Quit', 'Callback', ...
	  ['feval(''spm_ov_roi'',''context_quit'', ', ...
	    num2str(volhandle), ');'], 'Visible', 'off', ...
	  'Tag', ['ROI_1_', num2str(volhandle)]);
  item18 = uimenu(item0, 'Label', 'Help', 'Callback', ...
	  ['feval(''spm_help'',''' mfilename ''');']);
  % add some stuff outside ROI tool menu
  iorient = findobj(st.vols{volhandle}.ax{1}.cm, 'Label', 'Orientation');
  item19 =  uimenu(iorient, 'Label', 'ROI Space', 'Callback', ...
	  ['feval(''spm_ov_roi'',''context_space'', ', ...
	    num2str(volhandle), ');'], 'Visible', 'off', ...
	  'Tag', ['ROI_1_', num2str(volhandle)]);
  return;
    
 case 'context_init'
  Finter = spm_figure('FindWin', 'Interactive');
  spm_input('!DeleteInputObj',Finter);
  loadasroi = spm_input('Initial ROI','!+1','m',{'ROI image',...
		    'ROI space definition', 'SPM result'},[1 0 2],1);
  xyz = [];
  switch loadasroi
  case 1,
    imfname = spm_select(1, 'image', 'Select ROI image');
  case 0,
    imfname = spm_select(1, 'image', 'Select image defining ROI space');
    [p n e v] = fileparts(imfname);
  case 2,
      [SPM, xSPM] = spm_getSPM;
      xyz = xSPM.XYZ;
      imfname = SPM.Vbeta(1).fname;
  end;
  feval('spm_ov_roi','init',volhandle,imfname,loadasroi,xyz);
  obj = findobj(0, 'Tag',  ['ROI_1_', num2str(volhandle)]);
  set(obj, 'Visible', 'on');
  obj = findobj(0, 'Tag',  ['ROI_0_', num2str(volhandle)]);
  set(obj, 'Visible', 'off');
  spm_input('!DeleteInputObj',Finter);
  return;
    
 case 'context_selection'
  st.vols{volhandle}.roi.mode = varargin{3};
  obj = findobj(0, 'Tag', ['ROI_SELECTION_', num2str(volhandle)]);
  set(obj, 'Checked', 'off');
  set(gcbo, 'Checked', 'on');
  return;
 
 case 'context_edit'
  st.vols{volhandle}.roi.tool = varargin{3};
  obj = findobj(0, 'Tag', ['ROI_EDIT_', num2str(volhandle)]);
  set(obj, 'Checked', 'off');
  set(gcbo, 'Checked', 'on');
  return;
 
 case 'context_box'
  Finter = spm_figure('FindWin', 'Interactive');
  spm_input('!DeleteInputObj',Finter);
  box = spm_input('Selection size {vx vy vz}','!+1','e', ...
		   num2str(st.vols{volhandle}.roi.box), [1 3]);
  spm_input('!DeleteInputObj',Finter);
  st.vols{volhandle}.roi.box = box;
  return;
    
 case 'context_polyslices'
  Finter = spm_figure('FindWin', 'Interactive');
  spm_input('!DeleteInputObj',Finter);
  polyslices = spm_input('Polygon: slices around current slice','!+1','e', ...
		   num2str(st.vols{volhandle}.roi.polyslices), [1 1]);
  spm_input('!DeleteInputObj',Finter);
  st.vols{volhandle}.roi.polyslices = polyslices;
  return;
    
case 'context_csize'
  Finter = spm_figure('FindWin', 'Interactive');
  spm_input('!DeleteInputObj',Finter);
  csize = spm_input('Minimum cluster size (#vx)','!+1','e', ...
		   num2str(st.vols{volhandle}.roi.csize), [1 1]);
  spm_input('!DeleteInputObj',Finter);
  st.vols{volhandle}.roi.csize = csize;
  return;

case 'context_erothresh'
  Finter = spm_figure('FindWin', 'Interactive');
  spm_input('!DeleteInputObj',Finter);
  erothresh = spm_input('Erosion/Dilation threshold','!+1','e', ...
		   num2str(st.vols{volhandle}.roi.erothresh), [1 1]);
  spm_input('!DeleteInputObj',Finter);
  st.vols{volhandle}.roi.erothresh = erothresh;
  return;

    case 'context_space'
	spm_orthviews('space', volhandle, ...
		      st.vols{volhandle}.roi.Vroi.mat, ...
		      st.vols{volhandle}.roi.Vroi.dim(1:3));
	iorient = get(findobj(0,'Label','Orientation'),'children');
	if iscell(iorient)
	    iorient = cell2mat(iorient);
	end;
	set(iorient, 'Checked', 'Off');
	ioroi = findobj(iorient, 'Label','ROI space');
	set(ioroi, 'Checked', 'On');
	return;
	
  case 'context_thresh'
    Finter = spm_figure('FindWin', 'Interactive');
    spm_input('!DeleteInputObj',Finter);
    thresh = spm_input('Threshold  {min max}','!+1','e', ...
	num2str(st.vols{volhandle}.roi.thresh), [1 2]);
    spm_input('!DeleteInputObj',Finter);
    st.vols{volhandle}.roi.thresh = thresh;
    feval('spm_ov_roi', 'thresh', volhandle);
    return;
    
  case 'context_quit'
    obj = findobj(0, 'Tag',  ['ROI_1_', num2str(volhandle)]);
    set(obj, 'Visible', 'off');
    obj = findobj(0, 'Tag',  ['ROI_0_', num2str(volhandle)]);
    set(obj, 'Visible', 'on');
    spm_orthviews('rmblobs', volhandle);
    for k=1:3
      set(st.vols{volhandle}.ax{k}.ax,'ButtonDownFcn', st.vols{volhandle}.roi.cb{k});
    end;
    st.vols{volhandle} = rmfield(st.vols{volhandle}, 'roi');
    spm_orthviews('redraw');
    return;
    
  otherwise    
    fprintf('spm_orthviews(''roi'', ...): Unknown action %s', cmd);
    return;
end;

if update_roi
  if ~isempty(tochange) % change state according to mode
    if strcmp(st.vols{volhandle}.roi.mode,'set')
      toset = tochange;
    else
      toclear = tochange;
    end;
  end;
  % clear first, then set (needed for connect operation)
  if ~isempty(toclear)
    itoclear = sub2ind(st.vols{volhandle}.roi.Vroi.dim(1:3), ...
	      toclear(1,:), toclear(2,:), toclear(3,:)); 
    st.vols{volhandle}.roi.roi(itoclear) = 0;
    if ~isempty(st.vols{volhandle}.roi.xyz)
      st.vols{volhandle}.roi.xyz = setdiff(st.vols{volhandle}.roi.xyz',toclear','rows')';
    else
      st.vols{volhandle}.roi.xyz = [];
    end;
  end;

  if ~isempty(toset)
    % why do we need this round()?? I don't know, but Matlab thinks
    % it is necessary
    itoset = round(sub2ind(st.vols{volhandle}.roi.Vroi.dim(1:3), ...
            toset(1,:), toset(2,:), toset(3,:))); 
    st.vols{volhandle}.roi.roi(itoset) = 1;
    if ~isempty(st.vols{volhandle}.roi.xyz)
      st.vols{volhandle}.roi.xyz = union(st.vols{volhandle}.roi.xyz',toset','rows')';
    else
      st.vols{volhandle}.roi.xyz = toset;
    end;
  end;

  if isfield(st.vols{volhandle}, 'blobs')
    nblobs=length(st.vols{volhandle}.blobs);
    if nblobs>1
      blobstmp(1:st.vols{volhandle}.roi.hroi-1) = st.vols{volhandle}.blobs(1:st.vols{volhandle}.roi.hroi-1);
      blobstmp(st.vols{volhandle}.roi.hroi:nblobs-1) = st.vols{volhandle}.blobs(st.vols{volhandle}.roi.hroi+1:nblobs);
      st.vols{volhandle}.blobs=blobstmp;
    else
      if isempty(st.vols{volhandle}.roi.hframe) % save frame
	st.vols{volhandle}=rmfield(st.vols{volhandle},'blobs');
      end;
    end;
  end;
  if isfield(st.vols{volhandle}, 'blobs')
    st.vols{volhandle}.roi.hroi = prod(size(st.vols{volhandle}.blobs))+1;
  else
    st.vols{volhandle}.roi.hroi = 1;
  end;
  if isempty(st.vols{volhandle}.roi.xyz)  % initialised with empty roi
    spm_orthviews('addcolouredblobs', volhandle, ...
      [1; 1; 1], 0, st.vols{volhandle}.roi.Vroi.mat,[1 3 1]); 
  else
    spm_orthviews('addcolouredblobs', volhandle, ...
      st.vols{volhandle}.roi.xyz, ones(size(st.vols{volhandle}.roi.xyz,2),1), ... 
      st.vols{volhandle}.roi.Vroi.mat,[1 3 1]); % use color that is more intense than standard rgb range
  end;
  st.vols{volhandle}.blobs{st.vols{volhandle}.roi.hroi}.max=2;
  spm_orthviews('redraw');
end;

spm('pointer','arrow');


function varargout = stack(cmd, varargin)

switch cmd
  case 'init'
    varargout{1}.st = cell(varargin{1},1);
    varargout{1}.top= 0;

  case 'isempty'
    varargout{1} = (varargin{1}.top==0);

  case 'push'
    stck = varargin{1};
    if (stck.top < size(stck.st,1))
      stck.top = stck.top + 1;
      stck.st{stck.top} = varargin{2};
      varargout{1}=stck;
    else
      error('Stack overflow\n');
    end;

  case 'pop'
    if stack('isempty',varargin{1})
      error('Stack underflow\n');
    else
      varargout{2} = varargin{1}.st{varargin{1}.top};
      varargin{1}.top = varargin{1}.top - 1;
      varargout{1} = varargin{1};
    end;
end;
