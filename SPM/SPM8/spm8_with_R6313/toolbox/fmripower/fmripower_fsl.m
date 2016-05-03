function vargout=fmripower(vargin)
% Power calculation tool for FSL analyses when only changing the second
% level design matrix but not the first level design matrix.  This is a
% faster method as it doesn't require the estimation of the lower level
% covariance structure.

S = get(0,'ScreenSize');
size_win=[(S(3)-500)/2,S(4)-670,500,620];
f = figure('units', 'pixels','Visible','on',...
	   'Position',size_win,...
	 'Resize','off' , 'MenuBar', 'none', 'Name', 'fMRIpower', ...
	   'NumberTitle', 'off', 'color', [.7, .7, .7], ...
	   'HandleVisibility', 'off');
%---------------------------
%---------------------------
tmp=0;
size_b1=[10,(size_win(4)-30-240), 480, 240];
s1_box=uicontrol(f, 'Style', 'frame', 'Position', size_b1);

s1_box_text=uicontrol(f, 'Style', 'text', 'string', 'Set .gfeat options',...
		      'Position', [20, size_b1(2)+size_b1(4)-10, 190,20], ...
		      'FontWeight', 'bold', 'Fontsize', 14, ...
		      'backgroundcolor', [.7, .7, .7]);
%---------------------
gap=(size_b1(4)-150)/4;
lev3=3*gap+size_b1(2)+100;
gfeat_text=uicontrol(f, 'Style', 'text', 'String', '.gfeat directory',...
		     'Position',  [20,lev3+30,200,20],...
		      'FontWeight', 'bold',...
		      'FontSize', 12, 'backgroundcolor', [0.7, 0.7, 0.7], ...
		     'HorizontalAlignment', 'left');

gfeat_box=uicontrol(f,'Style','edit','String','',...
        'Position',[20,lev3,300,30], 'BackgroundColor',[1,1,1]);

gfeat_push=uicontrol(f,'Style','pushbutton','String',...
          'select .gfeat dir', 'Callback',{@gfeat_push_Callback},...
		     'Position',[335,lev3,140,30], ...
		     'backgroundcolor', [0.6, 0.6, 0.6]); 
%----------------------
lev2=2*gap+size_b1(2)+50;
cope_low_text=uicontrol(f, 'Style', 'text', 'String', ...
			'Select lower level cope of interest', 'Position', ...
			 [20,lev2+30,300,20], 'FontWeight', 'bold', ...
			 'FontSize', 12 );
cope_low_popup=uicontrol(f, 'Style', 'popupmenu','String','copes', ...
			 'Callback', {@cope_low_Callback},...
			 'Position', [20,lev2,300,30], ...
			 'backgroundcolor', [0.6, 0.6, 0.6]);

%----------------------
lev1=gap+size_b1(2);
cope_top_text=uicontrol(f, 'Style', 'text', 'String', ...
			'Select top level cope of interest', 'Position', ...
			 [20,lev1+30,300,20], 'FontWeight', 'bold',...
			 'FontSize', 12, 'backgroundcolor', [0.7, 0.7, 0.7] );
cope_top_popup=uicontrol(f, 'Style', 'popupmenu','String','copes', ...
			 'Callback', {@cope_top_Callback},...
			 'Position', [20,lev1,300,30], ...
			 'backgroundcolor', [0.6, 0.6, 0.6]);

%------------------------------------
%------------------------------------
size_b2=[10,(90), 480, 240];
s2_box=uicontrol(f, 'Style', 'frame', 'Position', size_b2);

s2_box_text=uicontrol(f, 'Style', 'text', ...
		      'string', 'Power calculation options',...
		      'Position', [20, size_b2(2)+size_b2(4)-10, 250,20], ...
		      'FontWeight', 'bold', 'Fontsize', 14, ...
		      'backgroundcolor', [.7, .7, .7]);
%-----------------
gap2=(size_b2(4)-150)/4;
lev3_2=3*gap2+size_b2(2)+100;
design_text=uicontrol(f, 'Style', 'text', 'String', ...
			'group design matrix', 'Position', ...
			 [20,lev3_2+30,300,20], 'FontWeight', 'bold',...
		         'FontSize', 12,'backgroundcolor', [0.7, 0.7, 0.7]);

design_box=uicontrol(f,'Style','edit','String','',...
          'Position',[20,lev3_2,300,30], 'BackgroundColor', [.7,.7,.7],...
          'ForegroundColor', [0 0 0], ...
           'Callback', {@design_box_Callback}, 'Enable','inactive');

design_push=uicontrol(f,'Style','pushbutton','String',...
          'select design matrix', 'Callback',{@design_push_Callback},...
          'Position',[335,lev3_2,140,30], 'backgroundcolor', [0.6, 0.6, 0.6]); 
%------------------------------
lev2_2=2*gap2+size_b2(2)+50;
roi_text=uicontrol(f, 'Style', 'text', 'String', ...
			'ROI mask', 'Position', ...
			 [20,lev2_2+30,300,20], 'FontWeight', 'bold',...
		         'FontSize', 12,...
		       'backgroundcolor', [0.7, 0.7, 0.7] );

roi_box=uicontrol(f,'Style','edit',...
          'String',[fileparts(which('fmripower')), '/aal_2mm.nii'],...
          'Position',[20,lev2_2,300,30], 'BackgroundColor', [1,1,1],...
	 'Callback', {@roi_box_Callback});

roi_push=uicontrol(f,'Style','pushbutton','String',...
          'select ROI mask', 'Callback',{@roi_push_Callback},...
		     'Position',[335,lev2_2,140,30], ...
		   'backgroundcolor', [0.6, 0.6, 0.6] ); 
%-----------------------------
lev1_2=gap2+size_b2(2);
alpha_text=uicontrol(f, 'Style', 'text', 'String', ...
			'Type I error rate', 'Position', ...
			 [20,lev1_2+30,300,20], 'FontWeight', 'bold',...
		         'FontSize', 12);

alpha_box=uicontrol(f,'Style','edit','String','',...
          'Position',[20,lev1_2,300,30], 'BackgroundColor', [1,1,1],...
		 'Callback', {@alpha_box_Callback});
%-----------------------------
start_calc_push=uicontrol(f,'Style','pushbutton','String',...
          'Calculate', 'Callback',{@start_calc_push_Callback},...
		     'Position',[20,30,225,40], 'Interruptible', 'off', ...
		     'Fontsize', 18, 'FontWeight', 'bold', ...
			 'backgroundcolor', [0.6, 0.6, 0.6]); 


exit_push=uicontrol(f,'Style','pushbutton','String',...
          'Exit', 'Callback',{@exit_push_Callback},...
		     'Position',[265,30,225,40], ...
		     'Fontsize', 18, 'FontWeight', 'bold', ...
			 'backgroundcolor', [0.6, 0.6, 0.6]); 
			 
set(0,'DefaultUiControlFontSize', 13);

uicontrol(f,'DeleteFcn',{@delete_fmripower_callback}, 'Visible', 'off');

%--------------------------------
%--------------------------------
handles.f=f;
handles.gfeat_dir='';
handles.ind_des=0;
handles.pow_dir= fileparts(which('fmripower'));
handles.roi_mask=[fileparts(which('fmripower')), '/aal_2mm.nii'];
handles.range_start = NaN;
handles.range_end = NaN;

if(~exist('spm'))
	errordlg(['SPM does not appear to be installed.' ...
    ' FMRIPower requires SPM. Please make sure that SPM is in your matlab ' ...
    'path before you continue.']);
end
handles.design_box = design_box;
guidata(f, handles);



function gfeat_push_Callback(source, eventdata)
  %---Reset Design Matrix Field when .gfeat is changed----%
  if length(handles.gfeat_dir)>0
    handles.new_design=[];
    handles.new_design_file=[];
    handles.ind_des=0;
    set(design_box, 'String', '');
    handles.roi_mask=[fileparts(which('fmripower')), '/aal_2mm.nii']; 
    set(roi_box, 'String', handles.roi_mask); 
    errordlg('You must reselect the design matrix and roi mask')
    guidata(f, handles);
  end
  
  %----Let user select Directory --------------------------%  
    handles.gfeat_dir = uigetdir();
    set(gfeat_box, 'String', handles.gfeat_dir);
      
  
	if(is_directory_gfeat(handles.gfeat_dir))
		handles = load_gfeat_data_from_directory(handles.gfeat_dir, handles);
	end
  
  guidata(f, handles);
end


%CANDIDATE FOR DELETION
function cope_low_Callback(source, eventdata)

   index=get(source, 'Value');
   list=get(source,'String');
   handles.chosen_cope_lower=list{index};
   handles.chosen_cope_low_ind=index;
   
   guidata(f, handles)
end
   
function cope_top_Callback(source, eventdata)
   index=get(source, 'Value');
   list=get(source,'String');
   handles.chosen_cope_top=list{index};
   handles.con_pow_calc=handles.original_con(index,:);
   handles.original_contrast_for_cope = handles.original_con(index,:);
   fprintf('Selected Contrast...')
   fprintf('%d ', handles.con_pow_calc)
   fprintf('  \n')
   guidata(f, handles)
end
   

%callback for the actual pushing of the 'select design matrix'
%button in the main gui
function design_push_Callback(source, eventdata)
    
    if(isempty(handles.gfeat_dir))
        errordlg('You must select a .gfeat directory first')
        error('');
        return;
    end

	try
		[ new_design contrast range_start range_end custom ] = ...
			get_design_matrix_from_user(handles.design_type, handles.original_design);
		
        handles.range_start = range_start;
        handles.range_end = range_end;


		if( ~isnan(contrast) )
			handles.con_pow_calc = contrast;
		else
			handles.con_pow_calc = handles.original_contrast_for_cope;
		end
        
		if(~custom)
			switch handles.design_type
				case 0
					set(handles.design_box, 'String', 'Custom Supplied Matrix');
				case 1
					set(handles.design_box, 'String', 'One Sample T');
				case 2
					set(handles.design_box, 'String', 'Two Sample T');
				case 3
					set(handles.design_box, 'String', 'Paired T Test');
			end
		else
			set(handles.design_box, 'String', 'Using Custom Matrix');
        end
		
    catch 
    	errordlg('You must provide a design matrix');
    	%should change the uicontrol string here for the edit boxd
    	set(handles.design_box, 'String', 'No Design Supplied');
    	new_design = [];
    	
	end
    
    
    if ~isnumeric(new_design)
        try
            new_design = load(new_design, '-ascii');
        catch
            new_design = load(new_design);
        end
    end

    save([handles.gfeat_dir,'/new_design.mat'],'new_design','-ascii');
    handles.new_design = [handles.gfeat_dir,'/new_design.mat'];
    
    try
        handles.new_design = load(handles.new_design,'-ascii');
    catch
        handles.new_design = load(handles.new_design);
    end
    
    handles.new_design_file = [handles.gfeat_dir,'/new_design.mat'];
    guidata(f, handles);

end

function roi_push_Callback(source, eventdata)
	[handles.roi_mask, roi_mask_path, unused_filter] = ...
    	uigetfile({'*.img; *.nii; *.img.gz; *.nii.gz', 'Image files (*.nii, *.img *.nii.gz *img.gz)'});
    handles.roi_mask = [roi_mask_path, handles.roi_mask];   
    valid_file = roi_file_check();
    if valid_file
        set(roi_box, 'String', handles.roi_mask);
    end
     
    guidata(f, handles);  
end

function design_box_Callback(source, eventdata)
   handles.new_design_file=get(source, 'String');
   design_file_check
   guidata(f, handles)
end

function roi_box_Callback(source, eventdata)
   handles.roi_mask=get(source, 'String');
   roi_file_check
   guidata(f, handles)
end

function alpha_box_Callback(source, eventdata)
   handles.alpha=str2double(get(source, 'String'));
   if handles.alpha>=1 || handles.alpha<=0 || isnan(handles.alpha)
     errordlg('Entry must be a numeric value between 0 and 1')
     handles.alpha=[];
     set(alpha_box, 'String', '');
   end  
   guidata(f, handles);
end

function exit_push_Callback(source, eventdata)
	close(handles.f);
	set(0,'DefaultUiControlFontSize', 10);
end


%set the variables for the calculation and call the wrapper functions
function start_calc_push_Callback(source, eventdata)
    
    confirm_ready_for_calculation(handles);
 

	working_directory = [handles.gfeat_dir,'/',handles.chosen_cope_lower];
	handles.working_directory = working_directory;
	
	[pth_cope,name_cope, ext_cope]=fileparts(handles.chosen_cope_top);
    roi_mask = handles.roi_mask;
    [pth_mask,name_mask, ext_mask]=fileparts(roi_mask);
    original_name_mask = name_mask;
    
    if(~exist(roi_mask))
    	exception = MException('RoiMask:DoesNotExist', ...
			'The selected ROI mask does not exist');
		errordlg('The ROI mask you selected does not appear to be valid. Please reselect your mask');
		throw(exception);
    end
    
    if sum(findstr('.',name_cope))>0
        name_cope=name_cope(1:(findstr('.', name_cope)-1));  
    end
    if sum(findstr('.',name_mask))>0
        name_mask=name_mask(1:(findstr('.', name_mask)-1));  
    end
    
    %create the Power directory
	create_results_directory(working_directory, name_mask, name_cope);
	%copy and unzip the roi mask into the power directory
	roi_mask = save_mask_to_directory(handles.roi_mask, ...
    	[working_directory '/Power/' name_mask ]);
    	
    pth_save=[handles.gfeat_dir,'/',handles.chosen_cope_lower,'/Power/', ...
	     name_mask,'/',name_cope];
	     
	range_start = handles.range_start;
    range_end = handles.range_end;
    
	if(isnan(range_start))
        range_start = 0;
    end
    
    if(isnan(range_end))
        range_end = 0;
    end
    
 %    try
    	pow_est = calculate_power_estimate(handles,roi_mask,pth_save,range_start,range_end);
  %  catch 
   % 	errordlg('Cannot calculate power estimate. Check your design matrix and ROI mask');
    %end
    
    %if pow_est isn't set, we can't continue.
	if(~exist('pow_est'))
        disp 'error';
        return;
    end
    
     if exist([pth_save '/pow_results.mat'])==0
		 pow_results=pow_est;
		 save([pth_save '/pow_results.mat'], 'pow_results');
	else
		 pow_results = pow_est;
		 des_names=cell((size(pow_results.des_name)+[ 0 1]));
		 des_names(1:(end-1))=pow_results.des_name;
		 des_names(end)=pow_est.des_name;
		 pow_results.des_name=des_names;
		 
		 pow_results.power=[pow_results.power, pow_est.power];
		 pow_results.alpha=[pow_results.alpha, pow_est.alpha];
		 delete([pth_save '/pow_results.mat']);
		 save([pth_save '/pow_results.mat'], 'pow_results');
	end
	pow_results=pow_est;
	
	%---Get ready to open image viewer----------------
   %-------------------------------------------------
   standard_img=[handles.gfeat_dir,'/bg_image.nii.gz'];
   
   if(exist(standard_img) == 0)
       standard_img=[handles.gfeat_dir,'/bg_image.nii'];
   end

   [pathstr, name, ext] = fileparts(standard_img);

   %Now unzip the file if it needs it
   [pth,name, ext]=fileparts(standard_img);
     if strcmp(ext, '.gz')
      system(['gunzip '  standard_img]); 
      handles.zip_reg=1;
      standard_img=[pth,'/',name];
     else
      handles.zip_reg=0;
      standard_img=[pth,'/',name,ext];
     end
   %-------Now check roi_mask---Assumes it is at least .img or .nii
   [pth,name, ext]=fileparts(roi_mask);
     if strcmp(ext, '.gz') && ~exist( [pth,'/',name] )
            system(['gunzip '  roi_mask]);
      handles.zip_roi=1;
      roi_mask=[pth,'/',name];
     else
      handles.zip_roi=0;
      roi_mask=[pth,'/',name,ext];
     end
    
   %-------Run the image viewer--------%
   if(range_end - range_start <= 0)
        spm_image_pow_individual('init',standard_img,[pth_save, '/pow_tmp.nii'],...
             [pth_save, '/mn_sd.nii'],...
             [pth_save, '/mn.nii'],...
             [pth_save, '/sd.nii'],...
             roi_mask);
   else
       spm_image_pow('init',standard_img,[pth_save, '/pow_tmp.nii'],...
             [pth_save, '/mn_sd.nii'],...
             [pth_save, '/mn.nii'],...
             [pth_save, '/sd.nii'],...
             roi_mask, pow_results.power, (range_start:range_end), handles.design_type);
   end

   guidata(f, handles)
end

function design_file_check(varargin)
   if isempty(handles.gfeat_dir)
     errordlg('Must select .gfeat directory first')  
     set(design_box, 'String', '');
     handles.new_design_file='';
   else
   
   try
     user_des=load(handles.new_design_file, '-ascii');
   catch 
     user_des = load(handles.new_design_file);
   end
   
   
   des_size=size(user_des);
   old_des_size=size(handles.original_design);
   if des_size(1)<des_size(2)
     set(design_box, 'String', '');
     handles.new_design_file='';
     errordlg('Design must have more rows than columns')
   end
   
   if des_size(2)~=old_des_size(2)
     set(design_box, 'String', '');
     handles.new_design_file='';
     errordlg('Design must have same number of columns as original design');
   end
    handles.new_design=user_des;
    check_design(handles.original_design, user_des, handles.con_pow_calc);
    set(design_box, 'String', handles.new_design_file);
    handles.ind_des=1;
    guidata(f, handles)
   end
end

function design_check(varargin)
    if isempty(handles.gfeat_dir)
     errordlg('Must select .gfeat directory first')  
     set(design_box, 'String', '');
     handles.new_design_file='';
     handles.new_design='';
    end
    
    des_size=size(handles.new_design);
    old_des_size=size(handles.original_design);
       
    if des_size(1)<des_size(2)
     set(design_box, 'String', '');
     handles.new_design_file='';
     handles.new_design = '';
     errordlg('Design must have more rows than columns')
    end
    if des_size(2)~=old_des_size(2)
     set(design_box, 'String', '');
     handles.new_design_file='';
     handles.new_design = '';
     errordlg('Design must have same number of columns as original design');
    end
    
    try
        check_design(handles.original_design, handles.new_design, handles.con_pow_calc);
    catch 
        handles.con_pow_calc=handles.original_con(1,:);
    end
    set(design_box, 'String', handles.new_design_file);
    handles.ind_des=1;
    guidata(f, handles)
    uiwait;
    
end

function [valid_file] = roi_file_check(varargin)
   
    valid_file = 1;
    if exist(handles.roi_mask, 'file')==0
      errordlg('Please select a file')
      error('');
      valid_file = 0;
      return;
    end
    
   if sum(findstr(handles.roi_mask, '.nii'))+...
	  sum(findstr(handles.roi_mask, '.img'))==0
      errordlg('ROI image must be a .nii or .img file')
      error('');
      valid_file=0;
   end
   
 end

function display_matrix_designer
    try
        user_supplied_matrix = matrix_source_prompt(handles.original_design);

        if isnumeric(user_supplied_matrix)
            handles.new_design = user_supplied_matrix;
        else
            try
                handles.new_design = load(user_supplied_matrix, '-ascii');
            catch
                handles.new_design = load(user_supplied_matrix);
            end
        end

        if ~exist('handles.new_design_file')
            handles.new_design_file = 'user supplied matrix';
        end

        design_check;
    catch 
        errordlg('You must select a design matrix')
        error('');
    end
end

function bool = is_directory_gfeat(directory)
	bool = 1;
	if exist(directory, 'dir')==0 && ~isempty(directory)
		errordlg(['Directory does not exist',directory]);
		error('');
		bool = 0;
	end
	
	if sum(findstr(directory, '.gfeat'))+5~=length(directory)
		errordlg('You must select a .gfeat directory.');
		directory = [];
		set(gfeat_box, 'String', '');
		bool = 0;
  	end
end

function handles = load_gfeat_data_from_directory(directory, handles)

	handles.mask = get_brain_mask(directory);
	
	cd(directory) 

	if(~has_one_variance_group(directory))
		warning(['Note: Pilot data used different between-subject variance estimates as indicated by the '...
		'group column in design setup, but due to limitations the power analysis will instead use a pooled variance ']);
    end
    
    %---Check that this is not a fixed effects analysis -----%
     %check the high level analysis design 
	design_fsf_file = [ directory , '/design.fsf' ];
	fsf_text = fileread(design_fsf_file);
	fsf_offset = strfind(fsf_text,'set fmri(mixed_yn)');
	fsf_offset = fsf_offset + 18;%string above is 18 chars long
	analysis_type = textscan(fsf_text(fsf_offset:end), '%d');
	%analysis type is a cell, grab the data inside
	analysis_type = analysis_type{1};
	 
	if analysis_type == 3
		errordlg('FMRIPower does not support power calculations for fixed effects analysis');
		exception = MException('VerifyDesign:DesignNotSupported', ...
			'This tool does not support power calculations for fixed effects analysis');
		throw(exception);
	end



	%----Read in Design matrix and contrasts matrix----------%
	
	system(['sed ''1,/\Matrix/d'' design.mat > design_only.mat']);
	system(['sed ''1,/\Matrix/d''  design.con > con_only.mat']);

	handles.original_design = agnostic_matfile_load('design_only.mat');
  
    handles.original_con = agnostic_matfile_load('con_only.mat');

	handles.con_pow_calc = handles.original_con(1,:);
	handles.original_contrast_for_cope = handles.original_con(1,:);

	%----Set up lower level cope.feat directory list --------%
	copes_lower=dir('cope*.feat');
	handles.copes_lower={copes_lower.name};
	handles.chosen_cope_lower_ind=1;
	set(cope_low_popup, 'String',handles.copes_lower);
	set(cope_low_popup, 'Value', handles.chosen_cope_lower_ind);
	handles.chosen_cope_lower=handles.copes_lower{1};
	
	%-----determine original design matrix type-------------%
	
	handles.design_type = design_matrix_type(handles.original_design);
	
	
	%-----set upper level cope list-------------------------%
	
	copes_top=dir('./cope1.feat/stats/cope*');
	
	if sum(findstr([copes_top.name], 'img'))>0
		copes_top=dir('./cope1.feat/stats/cope*.img*');
	else
		copes_top=dir('./cope1.feat/stats/cope*.nii*');
	end
	handles.copes_top={copes_top.name};
	len_copes_top=size(copes_top);
	if len_copes_top(1)==0;
		errordlg('No upper level copes exist')
	end 
	
	handles.chosen_cope_top=handles.copes_top{1};  
	set(cope_top_popup, 'String', handles.copes_top);
	set(cope_top_popup, 'Value', 1);
	
	guidata(f,handles);
end

function mask = get_brain_mask(gfeat_directory)

 %----Get the brain mask-----------%
  
  mask_file=dir([gfeat_directory, '/mask.*']);
  
  if length(mask_file)==0
    errordlg('Cannot find mask.img, .img.gz, .nii or .nii.gz file in .gfeat directory')
  elseif length(mask_file)==1
    mask=[gfeat_directory,'/', mask_file.name];
  elseif length(mask_file)>1
    if exist([gfeat_directory, '/mask.img'])
      mask=[gfeat_directory, '/mask.img'];
    elseif exist([gfeat_directory, '/mask.img.gz'])
      mask=[gfeat_directory, '/mask.img.gz'];
	elseif exist([gfeat_directory, '/mask.nii'])
	  mask = [ gfeat_directory, '/mask.nii' ] ;
	elseif exist([gfeat_directory , '/mask.nii.gz' ])
	  mask = [ gfeat_directory , '/mask.nii.gz' ];
    else
      errordlg('Cannot find mask image, must be .img, .img.gz, .nii, or .nii.gz')
    end
   end

end

function bool = has_one_variance_group(directory)

	bool = 1;
	%---Check if more than one variance group exists-----%
	
	group_design = fopen([directory '/design.grp']);
	design_line = fgetl(group_design);
	while(ischar(design_line))
		if(strncmp(design_line, '/', 1) == 0)
			design_num = str2double(design_line);
			if(design_num ~= 1 && ~isnan(design_num) && design_num ~= 0)
				bool = 0;
			end
		end
		design_line = fgetl(group_design);
	end

end

%loads a matfile into the workspace regardless of its status as a binary or ascii file
function file_handle = agnostic_matfile_load(filename)

	try
		file_handle = load(filename, '-ascii');
	catch
		file_handle = load(filename);
	end
	
end

function power_estimate = calculate_power_estimate(handles,roi_mask,pth_save,range_start,range_end)
    
   %try
    generate_power_data(handles.working_directory, handles.gfeat_dir, handles.chosen_cope_lower,...
      '');
   %catch 
     %  rethrow(exception);
   %end
   
 

   ctop=[handles.gfeat_dir,'/', handles.chosen_cope_lower,'/stats/', handles.chosen_cope_top];   
   
   
   var_avg=dir([handles.gfeat_dir,'/',handles.chosen_cope_lower,'/Power/var_avg.*']);
   if length(var_avg)>1
     var_avg=[handles.gfeat_dir,'/',handles.chosen_cope_lower,...
            '/Power/var_avg.img'];
   else
     var_avg=[handles.gfeat_dir,'/',handles.chosen_cope_lower,...
            '/Power/var_avg.nii.gz'];
   end 
    
    

   if(range_end - range_start <= 0)
    power_estimate = calc_pow_lev2_individual(ctop,var_avg,handles.new_design_file, ...
    	handles.con_pow_calc,roi_mask,handles.mask,handles.alpha,pth_save, handles.design_type);
   else
       power_estimate = calc_pow_lev2(ctop,var_avg,handles.new_design_file, ... 
           handles.con_pow_calc,roi_mask,handles.mask, ...
           handles.alpha,pth_save, range_start, range_end, handles.design_type);
   end
   
end

function delete_fmripower_callback(hObject, eventData)
	set(0,'DefaultUiControlFontSize', 10);

end

function create_results_directory(working_directory, name_mask, name_cope)

	if exist([working_directory '/Power/' name_mask '/' name_cope])==0
    	mkdir([working_directory '/Power/' name_mask '/' name_cope]);
    end
    
end

function roi_mask_location = save_mask_to_directory(mask, mask_directory)

	[mask_path mask_file_name mask_extension] = fileparts(mask);

	if(strcmp(mask_extension, '.gz'))
		[ temp_path mask_name_only image_ext ] = fileparts(mask_file_name);
	else
		mask_name_only = mask_file_name;
		image_ext = mask_extension;
	end

	if(exist([mask_directory '/'  mask_name_only image_ext ]))
        delete([mask_directory '/' mask_name_only image_ext]);
    end
    
    if(exist([mask_directory '/'  mask_file_name mask_extension ]))
    	delete([mask_directory '/'  mask_file_name mask_extension ]);
    end

	copyfile(mask, [ mask_directory '/'  mask_file_name mask_extension ], 'f');

	if(strcmp('.gz', mask_extension))
		gunzip([ mask_directory '/'  mask_file_name mask_extension ]);
		delete([ mask_directory '/'  mask_file_name mask_extension ]);
		roi_mask_location = [ mask_directory '/'  mask_file_name ];
	else
		roi_mask_location = [ mask_directory '/'  mask_file_name mask_extension ];
	end

end

function confirm_ready_for_calculation(handles)
    if(isfield(handles, 'gfeat_dir'))
       if(~exist(handles.gfeat_dir,'dir'))
           exception = MException('Calculate:HandlesNotSet', ...
               'Gfeat directory invalid');
           errordlg('GFeat directory is invalid');
           throw(exception);
       end
    else
        exception = MException('Calculate:HandlesNotSet', ...
               'Gfeat directory not set');
        errordlg('You must set the gfeat directory first');
        throw(exception);
    end
    
    if(isfield(handles, 'roi_mask'))
       if(~exist(handles.roi_mask, 'file'))
           exception = MException('Calculate:HandlesNotSet', ...
               'ROI Mask invalid');
           errordlg('ROI Mask is invalid');
           throw(exception);
       end
    else
        exception = MException('Calculate:HandlesNotSet', ...
               'ROI Mask not set');
        errordlg('You must set the ROI Mask first');
        throw(exception);
    end
    
    
    
    if(isfield(handles, 'con_pow_calc'))
       if(~isnumeric(handles.con_pow_calc))
           exception = MException('Calculate:HandlesNotSet', ...
               'Contrast is not set. Reselect design matrix.');
           errordlg('con_pow_calc is invalid');
           throw(exception);
       end
    else
        exception = MException('Calculate:HandlesNotSet', ...
               'con_pow_calc not set');
        errordlg('Please reselect your design matrix');
        throw(exception);
    end
    
    if(isfield(handles, 'new_design'))
       if(~isnumeric(handles.new_design))
           exception = MException('Calculate:HandlesNotSet', ...
               'Design matrix invalid');
           errordlg('Please select your design matrix first');
           throw(exception);
       end
    else
        exception = MException('Calculate:HandlesNotSet', ...
               'new_design not set');
        errordlg('Please select your design matrix.');
        throw(exception);
    end
    
    if(isfield(handles, 'chosen_cope_top'))
       if(~isstr(handles.chosen_cope_top))
           exception = MException('Calculate:HandlesNotSet', ...
               'Top level cope not selected');
           errordlg('Please select a top level cope of interest');
           throw(exception);
       end
    else
        exception = MException('Calculate:HandlesNotSet', ...
               'Top level cope not set');
        errordlg('Please select a top level cope of interest');
        throw(exception);
    end
    
    if(isfield(handles, 'chosen_cope_lower'))
       if(~isstr(handles.chosen_cope_lower))
           exception = MException('Calculate:HandlesNotSet', ...
               'Lower level cope not set');
           errordlg('Please select a lower level cope of interest');
           throw(exception);
       end
    else
        exception = MException('Calculate:HandlesNotSet', ...
               'Lower level cope not set');
        errordlg('Please select a lower level cope of interest');
        throw(exception);
    end
    
    if(isfield(handles, 'alpha'))
       if(~isnumeric(handles.alpha))
           exception = MException('Calculate:HandlesNotSet', ...
               'Type 1 error rate not set');
           errordlg('Please fill in your type 1 error rate');
           throw(exception);
       end
       if(isempty(handles.alpha))
       		handles.alpha = 0;
       end
       if( (handles.alpha <= 0) || (handles.alpha >= 1) )
       		exception = MException('Calculate:HandlesNotSet', ...
               'Type 1 error rate invalid');
           errordlg('Your type 1 error rate must be between 0 and 1');
           throw(exception);
       end
    else
        exception = MException('Calculate:HandlesNotSet', ...
               'Type 1 error rate not set');
        errordlg('Please fill in your type 1 error rate');
        throw(exception);
    end
    if(isfield(handles, 'new_design') && isfield(handles, 'range_start') )
    	if(isnan(handles.range_start) && isempty(handles.new_design))
    		exception = MException('Calculate:HandlesNotSet', ...
               'No design or range specified');
        errordlg('Please reselect your design matrix');
        throw(exception);
    	end
    end
    
end

end
