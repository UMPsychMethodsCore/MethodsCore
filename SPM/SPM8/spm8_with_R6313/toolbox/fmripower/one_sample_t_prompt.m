function [ output_matrix range_start range_end custom ] = one_sample_t_prompt(varargin)

%grab the screen size so we can center the windows
scrsz = get(0,'ScreenSize');

prompt_width = 350;
prompt_height = 510;

output_matrix = varargin{1};

%this constructs the main gui in the center of the scene
prompt = figure('Visible','on','Position',[scrsz(3)/2-prompt_width/2, ...
    scrsz(4)/2-prompt_height/2,prompt_width,prompt_height], ...
	   'MenuBar', 'none', 'Name', 'Design Matrix Setup', ...
	   'NumberTitle', 'off', 'color', [.7, .7, .7]);
   
%we will be storing all the handles of the ui controls so we can turn
%them on and off later.
handles = guihandles(prompt);

%grab the original design from the input arguments
handles.original_design = varargin{1};

if varargin{2}
	test_type = 'paired t test';
else
	test_type = '1 sample t test';
end
%the three following controls just attach the instructions and 
%pushbottons to the prompt gui we just created
uicontrol(prompt, 'Style', 'text', 'String', ['Was the previous test a ' test_type '?'], ...
        'Position', [27 440 305 47], ...
        'BackgroundColor', [.7, .7, .7], ...
        'FontSize', 13.0);
    
handles.no_toggle = uicontrol(prompt, 'Position', [225 385 101 73], ...
            'String', 'No',...
            'Style', 'togglebutton', ...
            'Callback', {@pushbutton_no_callback});
handles.yes_toggle = uicontrol(prompt, 'Position', [25 385 101 73], ...
            'String', 'Yes',...
            'Style', 'togglebutton', ...
            'Callback', {@pushbutton_yes_callback});
        
handles.mat_select = uicontrol(prompt, 'String', 'Select a matrix stored in a file', 'Position', [32 191 286 83], ...
            'Callback', {@matrix_file_select} , 'FontSize', 13.0, 'Visible', 'off');
        
handles.mat_editor = uicontrol(prompt, 'String', 'Use the editor to create a matrix', 'Position', [32 99 287 82], ...
            'Callback', {@launch_matrix_editor}, 'FontSize', 13.0, 'Visible', 'off');
     
handles.mat_pasteboard = uicontrol(prompt, 'String', 'Copy and Paste a matrix', 'Position', [32 7 287 82], ...
            'Callback', {@launch_matrix_pasteboard}, 'FontSize', 13.0, 'Visible', 'off');
        
prompt_label(1) = {'How many subjects do you wish'};
prompt_label(2) = {'to perform power analysis on?'};

handles.pow_prompt = uicontrol(prompt, 'Style', 'text', 'String', prompt_label, ...
    'Position', [10 180 230 51], ...
    'BackgroundColor', [.7, .7, .7], ...
    'FontSize', 12.0, 'FontWeight', 'bold', 'Visible', 'off');

handles.pow_input = uicontrol(prompt, 'Style', 'edit', 'String', '0', ...
        'Position', [250 190 75 47], ...
        'SelectionHighlight','on',...
        'BackgroundColor', 'white', 'Visible', 'off');

handles.pow_pushbutton = uicontrol(prompt, 'String', 'Ok', 'Position', [prompt_width/2-68/2 75 68 47], ...
        'Callback', {@set_number_subjects}, 'Visible', 'off');

handles.calc_text = uicontrol(prompt,'String', 'Calculate power for an individual or range of sample sizes', ...
              'Position',  [20,310,300,40], ...
              'Style', 'text', ...
              'FontWeight', 'bold',...
		      'FontSize', 12, ...
              'Visible', 'off');
          
handles.radio_individual = uicontrol(prompt, 'Style', 'Radio', 'String', 'Individual', ...
             'Position', [120,280,100,20],...
             'Callback', {@individual_radio_callback}, ...
             'Visible', 'off'...
            );


handles.radio_range =  uicontrol(prompt, 'Style', 'Radio', 'String', 'Range', ...
             'Position', [120,260,100,20],...
             'Callback', {@range_radio_callback}, ...
             'Visible', 'off'...
            );
        
handles.range_from_string = uicontrol(prompt, 'Style', 'text', 'String', 'From:',...
        'Position', [90,200,50,20] ...
        , 'Visible', 'off' ...
        , 'FontWeight', 'bold' ...
        );
        
handles.range_start = uicontrol(prompt, 'Style', 'edit', ...
            'Position', [160,200,100,30] ...
            , 'Visible', 'off','BackgroundColor', [1,1,1] ...
            );
        
handles.range_to_string = uicontrol(prompt, 'Style', 'text', 'String', 'To:',...
        'Position', [90,170,30,20] ...
        , 'Visible', 'off' ...
        , 'FontWeight', 'bold' ...
        );
    
handles.range_end = uicontrol(prompt, 'Style', 'edit', ...
            'Position', [160,170,100,30] ...
            , 'Visible', 'off','BackgroundColor', [1,1,1] ...
            );    

handles.custom = 0;        

set(handles.radio_individual, 'Value', 1);
set(handles.radio_range, 'Value', 0);

set(handles.range_from_string, 'Visible', 'off');
set(handles.range_start, 'Visible', 'off');
set(handles.range_to_string, 'Visible', 'off');
set(handles.range_end, 'Visible', 'off');

%prep the callback handles for use        
guidata(prompt,handles);

%hold UI execution until the user clicks a button
uiwait(prompt);

%close the prompt window
if ishandle(prompt)
    %load the handles and get the output
    handles = guidata(prompt);
    output_matrix = handles.output_matrix;
    
    custom = handles.custom;
    
    range_start = get(handles.range_start, 'String');
    range_start = str2double(range_start);
    
    range_end = get(handles.range_end, 'String');
    range_end = str2double(range_end);
    
    
    close(prompt);
end   

function pushbutton_no_callback(hObject,eventdata)
%inherit the handles from the parent
handles = guidata(gcbf);
%set and store the output
%grab the toggle state
value = get(hObject, 'Value');


errordlg('Cannot determine design type');
if value == 1
    %toggle down
    %display the hidden uicontrol objects
    set(handles.yes_toggle, 'Value', ~value);
end
set(handles.mat_select, 'Visible', 'off');
set(handles.mat_editor, 'Visible', 'off');
set(handles.mat_pasteboard, 'Visible', 'off');
set(handles.pow_prompt, 'Visible', 'off');
set(handles.pow_input,'Visible','off');
set(handles.pow_pushbutton,'Visible','off');
set(handles.radio_range, 'Value', 0);
set(handles.range_from_string, 'Visible', 'off');
set(handles.range_to_string, 'Visible', 'off');
set(handles.range_start, 'Visible', 'off');
set(handles.range_end, 'Visible', 'off');
set(handles.radio_individual, 'Visible', 'off');
set(handles.radio_range, 'Visible','off');
set(handles.calc_text, 'Visible', 'off');

set(handles.calc_text, 'Visible', 'on');
toggle_range_section(handles);

throw(MException('Matrix:Error','Cannot determine matrix type'));
guidata(gcbf,handles);



function pushbutton_yes_callback(hObject,eventdata)
%inherit the handles from the parent
handles = guidata(gcbf);
%set and store the output
%grab the toggle state
value = get(hObject, 'Value');
if value == 1
    %toggle down
    %display the hidden uicontrol objects
    set(handles.mat_select, 'Visible', 'off');
    set(handles.mat_editor, 'Visible', 'off');
    set(handles.mat_pasteboard, 'Visible', 'off');
    set(handles.pow_prompt, 'Visible', 'on');
    set(handles.pow_input,'Visible','on');
    set(handles.pow_pushbutton,'Visible','on');
    
    set(handles.calc_text, 'Visible', 'on');
    set(handles.radio_individual, 'Visible', 'on');
    set(handles.radio_range, 'Visible','on');
    set(handles.no_toggle, 'Value', ~value);
    handles.custom = 0;
else
    set(handles.mat_select, 'Visible', 'off');
    set(handles.mat_editor, 'Visible', 'off');
    set(handles.mat_pasteboard, 'Visible', 'off');
    set(handles.pow_prompt, 'Visible', 'off');
    set(handles.pow_input,'Visible','off');
    set(handles.pow_pushbutton,'Visible','off');
    set(handles.radio_range, 'Value', 0);
    set(handles.range_from_string, 'Visible', 'off');
    set(handles.range_to_string, 'Visible', 'off');
    set(handles.range_start, 'Visible', 'off');
    set(handles.range_end, 'Visible', 'off');
    set(handles.calc_text, 'Visible', 'off');
    set(handles.radio_individual, 'Visible', 'off');
    set(handles.radio_range, 'Visible','off');
end
guidata(gcbf,handles);

function matrix_file_select(hObject, eventData)
matrix_file = file_select_mat;
handles = guidata(gcbf);
handles.output_matrix = matrix_file;
handles.output_matrix
if(exist(handles.output_matrix))
	guidata(gcbf,handles);
	uiresume(gcbf);
else
	errordlg('You must select a design matrix');
end

function launch_matrix_editor(hObject, eventData)
handles = guidata(gcbf);
try
	input_matrix = handles.original_design;
	edited_matrix = matrix_edit_prompt(input_matrix);
	handles.output_matrix = edited_matrix;
	guidata(gcbf,handles);
	uiresume(gcbf);
catch
	errordlg('You must provide a design matrix');
end


function launch_matrix_pasteboard(hObject, eventData)
handles = guidata(gcbf);
try
	handles.output_matrix = matrix_pasteboard;
	guidata(gcbf, handles);
	uiresume(gcbf);
catch
	errordlg('No matrix has been pasted');
end


function individual_radio_callback(hObject, eventData)
handles = guidata(gcbf);

value = get(hObject, 'Value');
if(value == 1)
    set(handles.range_from_string, 'Visible', 'off');
    set(handles.range_start, 'Visible', 'off');
    set(handles.range_to_string, 'Visible', 'off');
    set(handles.range_end, 'Visible', 'off');
    set(handles.radio_range, 'Value', 0);
    set(handles.pow_input, 'Visible', 'on');
    set(handles.pow_prompt, 'Visible', 'on');
else
    set(handles.range_from_string, 'Visible', 'off');
    set(handles.range_start, 'Visible', 'off');
    set(handles.range_to_string, 'Visible', 'off');
    set(handles.range_end, 'Visible', 'off');
    set(handles.radio_range, 'Value', 0);
    set(handles.pow_input, 'Visible', 'off');
    set(handles.pow_prompt, 'Visible', 'off');
end
guidata(gcbf, handles);

function range_radio_callback(hObject, eventData)
handles = guidata(gcbf);

value = get(hObject, 'Value');
if(value == 1)
    set(handles.range_from_string, 'Visible', 'on');
    set(handles.range_start, 'Visible', 'on');
    set(handles.range_to_string, 'Visible', 'on');
    set(handles.range_end, 'Visible', 'on');
    set(handles.radio_individual, 'Value', 0);
    set(handles.pow_input, 'Visible', 'off');
    set(handles.pow_prompt, 'Visible', 'off');
else
    set(handles.range_from_string, 'Visible', 'off');
    set(handles.range_start, 'Visible', 'off');
    set(handles.range_to_string, 'Visible', 'off');
    set(handles.range_end, 'Visible', 'off');
    set(handles.radio_individual, 'Value', 0);
    set(handles.pow_input, 'Visible', 'off');
    set(handles.pow_prompt, 'Visible', 'off');
end
guidata(gcbf, handles);

function set_number_subjects(hObject,eventdata)

%grab the surrounding object handles
handles = guidata(gcbf);
num_subjects = get(handles.pow_input, 'String');
range_start = get(handles.range_start, 'String');
range_end = get(handles.range_end, 'String');

num_subjects = str2double(num_subjects);
range_start = str2double(range_start);
range_end = str2double(range_end);
%if the value the user entered is not null, numeric, and 
%larger than zero we'll generate a matrix for them
if (~isempty(num_subjects) && isnumeric(num_subjects) && num_subjects > 0) ...
    ||( ~isempty(range_start) && ~isempty(range_end) && (range_end - range_start) > 0)
    num_subjects = uint32(num_subjects);
    %pass the value to the gui handler
    handles.output_matrix = ones(num_subjects,1);
    guidata(gcbf,handles);
    uiresume(gcbf);
else
    errordlg('Please enter a positive integer')
    error('');
end
    
    
function toggle_range_section(handles)
visible_value = get(handles.calc_text,'Visible');

if(strcmp(visible_value,'on'))
	visible_value = 'off';
else
	visible_value = 'on';
end

set(handles.calc_text,'Visible', visible_value);
set(handles.radio_individual, 'Visible', visible_value);
set(handles.radio_range, 'Visible', visible_value);

set(handles.range_start, 'Visible', 'off');
set(handles.range_end, 'Visible', 'off');
set(handles.range_from_string, 'Visible', 'off');
set(handles.range_to_string, 'Visible', 'off');
set(handles.radio_individual, 'Value', 1);
set(handles.radio_range, 'Value', 0);
