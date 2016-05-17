function spm_image_pow(op,varargin)
% image and header display
% FORMAT spm_image
%_______________________________________________________________________
%
% spm_image is an interactive facility that allows orthogonal sections
% from an image volume to be displayed.  Clicking the cursor on either
% of the three images moves the point around which the orthogonal
% sections are viewed.  The co-ordinates of the cursor are shown both
% in voxel co-ordinates and millimeters within some fixed framework.
% The intensity at that point in the image (sampled using the current
% interpolation scheme) is also given. The position of the crosshairs
% can also be moved by specifying the co-ordinates in millimeters to
% which they should be moved.  Clicking on the horizontal bar above
% these boxes will move the cursor back to the origin  (analogous to
% setting the crosshair position (in mm) to [0 0 0]).
%
% The images can be re-oriented by entering appropriate translations,
% rotations and zooms into the panel on the left.  The transformations
% can then be saved by hitting the ``Reorient images...'' button.  The
% transformations that were applied to the image are saved to the
% ``.mat'' files of the selected images.  The transformations are
% considered to be relative to any existing transformations that may be
% stored in the ``.mat'' files.  Note that the order that the
% transformations are applied in is the same as in ``spm_matrix.m''.
%
% The ``Reset...'' button next to it is for setting the orientation of
% images back to transverse.  It retains the current voxel sizes,
% but sets the origin of the images to be the centre of the volumes
% and all rotations back to zero.
%
% The right panel shows miscellaneous information about the image.
% This includes:
%   Dimensions - the x, y and z dimensions of the image.
%   Datatype   - the computer representation of each voxel.
%   Intensity  - scalefactors and possibly a DC offset.
%   Miscellaneous other information about the image.
%   Vox size   - the distance (in mm) between the centres of
%                neighbouring voxels.
%   Origin     - the voxel at the origin of the co-ordinate system
%   DIr Cos    - Direction cosines.  This is a widely used
%                representation of the orientation of an image.
%
% There are also a few options for different resampling modes, zooms
% etc.  You can also flip between voxel space (as would be displayed
% by Analyze) or world space (the orientation that SPM considers the
% image to be in).  If you are re-orienting the images, make sure that
% world space is specified.  Blobs (from activation studies) can be
% superimposed on the images and the intensity windowing can also be
% changed.
%
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

  % John Ashburner, Edited by Jeanette Mumford, 2007


global st

if nargin == 0,
	spm('FnUIsetup','Display',0);
	spm('FnBanner',mfilename,'$Rev: 184 $');
	spm_help('!ContextHelp',[mfilename,'.m']);

	% get the image's filename {P}
	%-----------------------------------------------------------------------
	P      = spm_select(1,'image','Select image',[],0);
	spm_image_pow('init',P);
	return;
end;

try
	if ~strcmp(op,'init') && ~strcmp(op,'reset') && isempty(st.vols{1})
		my_reset; warning('Lost all the image information');
		return;
	end;
end

if strcmp(op,'repos'),
	% The widgets for translation rotation or zooms have been modified.
	%-----------------------------------------------------------------------
	fg      = spm_figure('Findwin','Graphics');
	set(fg,'Pointer','watch');
	i       = varargin{1};
	st.B(i) = eval(get(gco,'String'),num2str(st.B(i)));
	set(gco,'String',st.B(i));
	st.vols{1}.premul = spm_matrix(st.B);
	% spm_orthviews('MaxBB');
	spm_image_pow('zoom_in');
	spm_image_pow('update_info');
	set(fg,'Pointer','arrow');
	return;
end;

if strcmp(op,'shopos'),
	% The position of the crosshairs has been moved.
	%-----------------------------------------------------------------------
	if isfield(st,'mp'),
		fg  = spm_figure('Findwin','Graphics');
		if any(findobj(fg) == st.mp),
            %these set the coords in the crosshair position
            set(st.mp,'String',sprintf('%.1f %.1f %.1f',spm_orthviews('pos')));
            pos = spm_orthviews('pos',1);
            set(st.vp,'String',sprintf('%.1f %.1f %.1f',pos));
            mean_sd_local = spm_sample_vol(st.mean_sd, pos(1),pos(2),pos(3),st.hld);
            
            %these calls set the numeric labels for each set of images
            set(st.in2,'String',sprintf('%g',spm_sample_vol(st.mean_sd, ...
                  pos(1),pos(2),pos(3),st.hld)));	
            set(st.in5,'String',sprintf('%g',...
                  spm_sample_vol(st.roi,pos(1),pos(2),pos(3),st.hld)));

            %If the plot is a valid region and it has a positive activation 
            %then plot it else display an error message on the graph
            
            if(ishandle(st.text_handle))
                delete(st.text_handle);
            end
            
            if( spm_sample_vol(st.roi,pos(1),pos(2),pos(3),st.hld) > 0 ...
                && mean_sd_local > 0)

                plot(st.axes,st.range,st.plot_matrix( ...
                    floor(spm_sample_vol(st.roi,pos(1),pos(2),pos(3),st.hld)) ...
                    ,:));
                
                
                
                xlabel(st.axes,st.xlab);
                ylabel(st.axes,'Power (%)');
                title(st.axes,'Power Curve');
                
            else
                plot(st.axes, 0, 0);
                st.text_handle = text('Parent',st.axes,'Position', [-0.5 0], ...
                    'String', 'Activation is not positive');
            end
         
            if st.name_ind==1
              try
                    set(st.in6,'String', ...
                    st.roi_names(round(spm_sample_vol(st.roi,pos(1),...
                    pos(2),pos(3),st.hld))));
              catch
                    set(st.in6, 'String', 'NaN');
              end
            end

        else
			st.Callback = ';';
			st = rmfield(st,{'mp','vp','in'});
		end;
    else
		st.Callback = ';';
	end;
	return;
end;

if strcmp(op,'setposmm'),
	% Move the crosshairs to the specified position
	%-----------------------------------------------------------------------
	if isfield(st,'mp'),
		fg = spm_figure('Findwin','Graphics');
		if any(findobj(fg) == st.mp),
			pos = sscanf(get(st.mp,'String'), '%g %g %g');
			if length(pos)~=3,
				pos = spm_orthviews('pos');
			end;
			spm_orthviews('Reposition',pos);
		end;
	end;
	return;
end;

if strcmp(op,'setposvx'),
	% Move the crosshairs to the specified position
	%-----------------------------------------------------------------------
	if isfield(st,'mp'),
		fg = spm_figure('Findwin','Graphics');
		if any(findobj(fg) == st.vp),
			pos = sscanf(get(st.vp,'String'), '%g %g %g');
			if length(pos)~=3,
				pos = spm_orthviews('pos',1);
			end;
			tmp = st.vols{1}.premul*st.vols{1}.mat;
			pos = tmp(1:3,:)*[pos ; 1];
			spm_orthviews('Reposition',pos);
		end;
	end;
	return;
end;


if strcmp(op,'addblobs'),
	% Add blobs to the image - in full colour
	spm_figure('Clear','Interactive');
	nblobs = spm_input('Number of sets of blobs',1,'1|2|3|4|5|6',[1 2 3 4 5 6],1);
	for i=1:nblobs,
		[SPM,VOL] = spm_getSPM;
		c = spm_input('Colour','+1','m','Red blobs|Yellow blobs|Green blobs|Cyan blobs|Blue blobs|Magenta blobs',[1 2 3 4 5 6],1);
		colours = [1 0 0;1 1 0;0 1 0;0 1 1;0 0 1;1 0 1];
		spm_orthviews('addcolouredblobs',1,VOL.XYZ,VOL.Z,VOL.M,colours(c,:));
		set(st.blobber,'String','Remove Blobs','Callback','spm_image_pow(''rmblobs'');');
	end;
	spm_orthviews('Redraw');
end;

if strcmp(op,'rmblobs'),
	% Remove all blobs from the images
	spm_orthviews('rmblobs',1);
	set(st.blobber,'String','Add Blobs','Callback','spm_image_pow(''addblobs'');');
end;

if strcmp(op,'window'),
	op = get(st.win,'Value');
	if op == 1,
		spm_orthviews('window',1);
    else
		spm_orthviews('window',1,spm_input('Range','+1','e','',2));
	end;
end;


if strcmp(op,'reorient'),
	% Time to modify the ``.mat'' files for the images.
	% I hope that giving people this facility is the right thing to do....
	%-----------------------------------------------------------------------
	mat = spm_matrix(st.B);
	if det(mat)<=0
		spm('alert!','This will flip the images',mfilename,0,1);
	end;
	P = spm_select(Inf, 'image','Images to reorient');
	Mats = zeros(4,4,size(P,1));
	spm_progress_bar('Init',size(P,1),'Reading current orientations',...
		'Images Complete');
	for i=1:size(P,1),
		Mats(:,:,i) = spm_get_space(P(i,:));
		spm_progress_bar('Set',i);
	end;
	spm_progress_bar('Init',size(P,1),'Reorienting images',...
		'Images Complete');
	for i=1:size(P,1),
		spm_get_space(P(i,:),mat*Mats(:,:,i));
		spm_progress_bar('Set',i);
	end;
	spm_progress_bar('Clear');
	tmp = spm_get_space([st.vols{1}.fname ',' num2str(st.vols{1}.n)]);
	if sum((tmp(:)-st.vols{1}.mat(:)).^2) > 1e-8,
		spm_image_pow('init',st.vols{1}.fname);
	end;
	return;
end;

if strcmp(op,'resetorient'),
	% Time to modify the ``.mat'' files for the images.
	% I hope that giving people this facility is the right thing to do....
	%-----------------------------------------------------------------------
	P = spm_select(Inf, 'image','Images to reset orientation of');
	spm_progress_bar('Init',size(P,1),'Resetting orientations',...
		'Images Complete');
	for i=1:size(P,1),
		V    = spm_vol(deblank(P(i,:)));
		M    = V.mat;
		vox  = sqrt(sum(M(1:3,1:3).^2));
		if det(M(1:3,1:3))<0, vox(1) = -vox(1); end;
		orig = (V.dim(1:3)+1)/2;
                off  = -vox.*orig;
                M    = [vox(1) 0      0      off(1)
		        0      vox(2) 0      off(2)
		        0      0      vox(3) off(3)
		        0      0      0      1];
		spm_get_space(P(i,:),M);
		spm_progress_bar('Set',i);
	end;
	spm_progress_bar('Clear');
	tmp = spm_get_space([st.vols{1}.fname ',' num2str(st.vols{1}.n)]);
	if sum((tmp(:)-st.vols{1}.mat(:)).^2) > 1e-8,
		spm_image_pow('init',st.vols{1}.fname);
	end;
	return;
end;

if strcmp(op,'update_info'),
	% Modify the positional information in the right hand panel.
	%-----------------------------------------------------------------------
	mat = st.vols{1}.premul*st.vols{1}.mat;
	Z = spm_imatrix(mat);
	Z = Z(7:9);

	set(st.posinf.z,'String', sprintf('%.3g x %.3g x %.3g', Z));

	O = mat\[0 0 0 1]'; O=O(1:3)';
	set(st.posinf.o, 'String', sprintf('%.3g %.3g %.3g', O));

	R = spm_imatrix(mat);
	R = spm_matrix([0 0 0 R(4:6)]);
	R = R(1:3,1:3);

	tmp2 = sprintf('%+5.3f %+5.3f %+5.3f', R(1,1:3)); tmp2(tmp2=='+') = ' ';
	set(st.posinf.m1, 'String', tmp2);
	tmp2 = sprintf('%+5.3f %+5.3f %+5.3f', R(2,1:3)); tmp2(tmp2=='+') = ' ';
	set(st.posinf.m2, 'String', tmp2);
	tmp2 = sprintf('%+5.3f %+5.3f %+5.3f', R(3,1:3)); tmp2(tmp2=='+') = ' ';
	set(st.posinf.m3, 'String', tmp2);

	tmp = [[R zeros(3,1)] ; 0 0 0 1]*diag([Z 1])*spm_matrix(-O) - mat;

	if sum(tmp(:).^2)>1e-8,
		set(st.posinf.w, 'String', 'Warning: shears involved');
    else
		set(st.posinf.w, 'String', '');
	end;

	return;
end;

if strcmp(op,'reset'),
	my_reset;
end;

if strcmp(op,'zoom_in'),
	op = get(st.zoomer,'Value');
	if op==1,
		spm_orthviews('resolution',1);
		spm_orthviews('MaxBB');
    else
		vx = sqrt(sum(st.Space(1:3,1:3).^2));
		vx = vx.^(-1);
		pos = spm_orthviews('pos');
		pos = st.Space\[pos ; 1];
		pos = pos(1:3)';
		if     op == 2, st.bb = [pos-80*vx ; pos+80*vx] ; spm_orthviews('resolution',1);
		elseif op == 3, st.bb = [pos-40*vx ; pos+40*vx] ; spm_orthviews('resolution',.5);
		elseif op == 4, st.bb = [pos-20*vx ; pos+20*vx] ; spm_orthviews('resolution',.25);
		elseif op == 5, st.bb = [pos-10*vx ; pos+10*vx] ; spm_orthviews('resolution',.125);
        else            st.bb = [pos- 5*vx ; pos+ 5*vx] ; spm_orthviews('resolution',.125);
		end;
	end;
	return;
end;

if strcmp(op,'init'),
    fg = spm_figure('GetWin','Graphics');
    if isempty(fg), error('Can''t create graphics window'); end
    spm_figure('Clear','Graphics');

    %varargin{1} is the full filename of the brain.nii.gz file
    P = varargin{1};
    if ischar(P), P = spm_vol(P); end;
    P = P(1);

    P2 = varargin{2};
    if ischar(P2), P2 = spm_vol(P2); end;
    P2 = P2(1);

    P3 = varargin{3};
    if ischar(P3), P3 = spm_vol(P3); end;
    P3 = P3(1);

    P4 = varargin{4};
    if ischar(P4), P4 = spm_vol(P4); end;
    P4 = P4(1);

    P5 = varargin{5};
    if ischar(P5), P5 = spm_vol(P5); end;
    P5 = P5(1);
 
    plot_matrix = varargin{7};
    
    
   


    spm_orthviews('Reset');

    %Each image has the reference brain as a background
    
    %the call to spm_orthviews('addimage', figure_handle, filename)
    %are using the last created figures as handles (eg the numeric
    %representation). 


    %I'm adding mean in SD units (top right)
    spm_orthviews('Image', P, [0.28 0.55 .45 0.55]);
    spm_orthviews('addimage',1, P3);
    

    %build the axes for the graph
    axe_handle = axes('Position', [0.28 0.27 0.45 0.3]);
    set(fg,'CurrentAxes',axe_handle);
     
     
    
    
    
    
	plot(axe_handle,0,0);
	%turn off the graph's ability to retain curves
	%now when we update the plot the old line will be removed automatically
	hold off;

   
	xlabel('N');
	ylabel('Power (%)');
	title('Power Curve');
	st.text_handle = text('Position', [.1 0], ...
				'String', 'Activation is not positive', ...
				'Visible', 'off');
    

    %setting the various figure handles into a struct so we can manipulate
    %them later.
    st.axes = axe_handle;
    st.power=P2;
    st.mean_sd=P3;
    st.mean=P4;
    st.sd=P5;
    st.roi=spm_vol(varargin{6});
    st.plot_matrix = plot_matrix;
    st.range = varargin{8};
    st.destype=varargin{9};
    
     
   
    if st.destype==1
        st.xlab='Number of Subjects';
    elseif st.destype==2
        st.xlab='Number of Subjects (per group)';
    elseif st.destype==3 | 4
        st.xlab='Number of Pairs of Data';
    end
    
    if isempty(st.vols{1}), return; end;

    
    spm_orthviews('MaxBB');
    st.callback = 'spm_image_pow(''shopos'');';

    st.B = [0 0 0  0 0 0  1 1 1  0 0 0];

    % locate Graphics window and clear it
    %-----------------------------------------------------------------------
    WS = spm('WinScale');



    %%%Titles for each brain image
    uicontrol(fg,'Style','Text', 'Position',[200 830 230 20].*WS,'String','Mean  (SD units)',...
              'FontSize', spm('FontSize',13), 'Backgroundcolor', [1 1 1]);

	%Mean SD L and R
    uicontrol(fg, 'Style','Text', 'Position', [170 565 10 13].*WS, 'String', 'L', ...
    		'FontSize', spm('FontSize',10), 'Backgroundcolor', [0 0 0], 'ForegroundColor', [1 1 1]);


   
    % Crosshair position
    %-----------------------------------------------------------------------


    uicontrol(fg,'Style','Frame','Position',[125 5 320 160].*WS);
    uicontrol(fg,'Style','Text', 'Position',[130 140 305 020].*WS,...
           'String','Crosshair Position', ...
              'Fontsize', spm('FontSize',13), 'Fontweight', 'bold');
  
    % Crosshair titles
    uicontrol(fg,'Style','Text', 'Position',[130 105 60 030].*WS,'String','mm:', ...
               'Fontsize', spm('FontSize',13), 'HorizontalAlignment', 'left');
    uicontrol(fg,'Style','Text', 'Position',[130 70 60 030].*WS,'String','vx:', ...
               'Fontsize', spm('FontSize',13),'HorizontalAlignment', 'left' );
    uicontrol(fg,'Style','Text', 'Position',[130 35 90 030].*WS,...
               'String','Region #','Fontsize', spm('FontSize',13),'HorizontalAlignment', 'left');


    st.mp = uicontrol(fg,'Style','edit', 'Position',[240 105 200 030].*WS,...
                    'String','','Callback','spm_image_pow(''setposmm'')',...
                    'ToolTipString','move crosshairs to mm coordinates', ...
                     'Fontsize', spm('Fontsize',14));
    st.vp = uicontrol(fg,'Style','edit', 'Position',[240 70 200 030].*WS,...
                     'String','','Callback','spm_image_pow(''setposvx'')',...
                      'ToolTipString','move crosshairs to voxel coordinates', ...
                       'Fontsize', spm('Fontsize',14));
                   
    %these calls control the location and styling of the 
    %numeric values that appear on update.
    
    st.in2 = uicontrol(fg,'Style','Text', 'Position',[360 655  85 020].*WS, ...
               'String','', 'Fontsize', spm('Fontsize',14), 'BackgroundColor', [1,1,1]);
    
    st.in5 = uicontrol(fg,'Style','Text', 'Position',[240 35  200 030].*WS, ...
               'String','', 'Fontsize', spm('Fontsize',14),'HorizontalAlignment', 'center');

    if length(findstr(varargin{6}, 'aal_2mm.nii') )>0 || length(findstr(varargin{6}, 'aal_spm.nii'))>0
      uicontrol(fg,'Style','Text', 'Position',[130 10 90 030].*WS,...
               'String','Region:','Fontsize', spm('Fontsize',12),'HorizontalAlignment', 'left');
      st.in6 = uicontrol(fg,'Style','Text', 'Position',[240 10  200 030].*WS, ...
               'String','', 'Fontsize', spm('Fontsize',12),'HorizontalAlignment', 'center');
      st.name_ind=1;
      try
        labels=load([fileparts(which('fmripower')), '/aal_labels.mat']);
      catch
          labels=load([fileparts(which('fmripower')), '/aal_labels.mat'], '-ASCII');
      end
      st.roi_names=labels.aal_labels;
    else
      st.name_ind=0;
    end

end;
return;


function my_reset
spm_orthviews('reset');
spm_figure('Clear','Graphics');
return;


