function varargout = file_select_mat(dirtype)
%@TODO - this is a candidate for speedy deletion
% varargout = file_select(varargin)
%vargout is the selected directory and dirtype is the label for the top
%of the directory select window

if nargin<1
dirtype='Select File';
end

%  Create and then hide the GUI as it is being constructed.


f = figure('Visible','on','Position',[360,200,450,385], ...
	   'MenuBar', 'none', 'Name', dirtype, ...
	   'NumberTitle', 'off', 'color', [.7, .7, .7]);

   
%Construct the components of the gui

dir_frame_text=uicontrol('Style', 'frame', 'Position', [5, 305, 440, 75]);
cur_dir_text=uicontrol('Style', 'text', 'String', 'Current Dirctory',...
		       'Position', [10, 355, 430, 20], ...
		       'backgroundcolor', [.7, .7, .7], 'fontsize', 14,...
                       'fontweight', 'bold', 'horizontalalignment', 'left');
curdir=uicontrol('Style','text','String',pwd,...
          'Position',[10,310,430,45], 'fontsize', 14,...
          'backgroundcolor', [.7, .7, .7],'horizontalalignment', 'left'  );


%dir_frame_list=uicontrol('style', 'frame', 'Position', [5, 45, 222,265]);       
dir_text=uicontrol('Style', 'text','string', 'Directories', ...
                   'Position', [10, 280, 200, 20], 'fontsize', 14, ...
                   'fontweight', 'bold', 'horizontalalignment', 'left', ...
                   'backgroundcolor', [.7, .7, .7] );       
dir_list=uicontrol('Style','listbox',...
          'Position',[10,45,210,235],...
         'Callback',{@dir_list_Callback}, ...
         'String', 'start', 'fontsize', 14,'backgroundcolor', [.7, .9, .9]);     
%file_frame=uicontrol('style', 'frame', 'position', [225, 45, 220, 265]);   
dir_text=uicontrol('Style', 'text','string', 'Files', ...
                   'Position', [230, 280, 200, 20], 'fontsize', 14, ...
                   'fontweight', 'bold', 'horizontalalignment', 'left', ...
                   'backgroundcolor', [.7, .7, .7] );             
file_list=uicontrol('Style','listbox',...
          'Position',[230,45,210,235],...
       'Callback',{@file_list_Callback},...
        'String', 'start', 'fontsize', 14,'backgroundcolor', [.7, .9, .9] );          
select_button=uicontrol('Style', 'pushbutton', 'Position', [10,5,430,35],...
              'Callback', {@select_button_Callback}, 'String', ...
			'Select File', 'fontweight', 'bold', ...
               'fontsize', 14);



%Program callbacks



handles.f=f;
handles.prev_dir=pwd;
guidata(f, handles);

%load initial listboc
load_listbox(pwd);
    
%I want to suspend the output until the user clicks the button
uiwait(f);
varargout{1} = handles.select_file;
if ishandle(f)
    close(f)
end


function dir_list_Callback(source, eventdata)
     index_selected = get(source,'Value');
     file_dir_list = get(source,'String');
     filename = file_dir_list{index_selected};    
     cd (filename)
     load_listbox(pwd)   
end

function file_list_Callback(source, eventdata)
   index_selected=get(source,'Value');
   file_dir_list = get(source,'String');
   handles.select_file=[pwd, '/', file_dir_list{index_selected}];
end


% --- Executes on button press in pushbutton1.

function select_button_Callback(source, eventdata)

uiresume(f)

end




% ------------------------------------------------------------
% Read the current directory and sort the names
% ------------------------------------------------------------

function load_listbox(dir_path)
cd (dir_path)
     dir_struct = dir(dir_path);
dir_ind=[dir_struct.isdir];
all_names={dir_struct.name};

dir_names=all_names(dir_ind==1);

%Make filter for .img, .img.gz, .nii and .nii.gz

  image_no=cellfun('isempty', regexp(all_names, 'mat')); 

file_names=all_names(dir_ind==0 & image_no<1);

[sorted_dir_names,sorted_dir_index] = sortrows(dir_names');
handles.dir_names = sorted_dir_names;
handles.sorted_dir_index = sorted_dir_index;

[sorted_file_names,sorted_file_index] = sortrows(file_names');
handles.file_names = sorted_file_names;
handles.sorted_file_index = sorted_file_index;
try
handles.select_file=[pwd,'/', sorted_file_names{1}];
catch
handles.select_file=[];
end

guidata(f,handles)
set(dir_list,'String', sorted_dir_names, 'Value',1)
set(file_list,'String', sorted_file_names, 'Value',1)
set(curdir,'String',pwd)
end




end
