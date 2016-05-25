function [ output_matrix range_start range_end custom] = two_sample_t_prompt(varargin)


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
%the three following controls just attach the instructions and 
%pushbottons to the prompt gui we just created
uicontrol(prompt, 'Style', 'text', 'String', 'Was your original model a 2 sample t-test?', ...
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
        
handles.mat_select = uicontrol(prompt, 'String',...
			'Select a matrix stored in a file', 'Position', [32 191 286 83], ...
            'Callback', {@matrix_file_select} , 'FontSize', 13.0, 'Visible', 'off');
        
handles.mat_editor = uicontrol(prompt, 'String', 'Use the editor to create a matrix', 'Position', [32 99 287 82], ...
            'Callback', {@launch_matrix_editor}, 'FontSize', 13.0, 'Visible', 'off');
     
handles.mat_pasteboard = uicontrol(prompt, 'String', 'Copy and Paste a matrix', 'Position', [32 7 287 82], ...
            'Callback', {@launch_matrix_pasteboard}, 'FontSize', 13.0, 'Visible', 'off');
        
prompt_label(1) = {'How many subjects in group 1?'};
prompt_label(2) = {'How many subjects in group 2?'};


handles.group1_prompt= uicontrol(prompt, 'Style', 'text', 'String', prompt_label(1), ...
    'Position', [10 180 240 51], ...
    'BackgroundColor', [.7, .7, .7], ...
    'FontSize', 12.0, 'FontWeight', 'bold', 'Visible', 'off');

handles.group1_input= uicontrol(prompt, 'Style', 'edit', 'String', '0', ...
        'Position', [250 205 50 35], ...
        'SelectionHighlight','on',...
        'BackgroundColor', 'white', 'Visible', 'off');


handles.group2_prompt= uicontrol(prompt, 'Style', 'text', 'String', prompt_label(2), ...
    'Position', [10 140 240 51], ...
    'BackgroundColor', [.7, .7, .7], ...
    'FontSize', 12.0, 'FontWeight', 'bold', 'Visible', 'off');

handles.group2_input= uicontrol(prompt, 'Style', 'edit', 'String', '0', ...
        'Position', [250 165 50 35], ...
        'SelectionHighlight','on',...
        'BackgroundColor', 'white', 'Visible', 'off');

handles.pow_pushbutton = uicontrol(prompt, 'String', 'Ok', 'Position', ...
		[prompt_width/2-68/2 75 68 47], ...
        'Callback', {@create_design_matrix}, 'Visible', 'off');

calc_text(1) = {'Calculate over range of sample sizes'};
calc_text(2) = {'or a single sample size'};

sample_description(1) = {'Sample size is the number of subjects per group'};

handles.calc_text = uicontrol(prompt,'String',...
              calc_text, ...
              'Position',  [20,330,300,40], ...
              'Style', 'text', ...
              'FontWeight', 'bold',...
		      'FontSize', 12, ...
              'Visible', 'off');

handles.sample_description = uicontrol(prompt, 'String',...
			sample_description, ...
			'Position',	[20 290 300 40], ...
			'Style', 'text', ...
            'FontWeight', 'bold',...
		    'FontSize', 12, ...
            'Visible', 'off');
          
handles.radio_individual = uicontrol(prompt, 'Style', 'Radio', 'String', 'Individual', ...
             'Position', [120,250,100,20],...
             'Callback', {@individual_radio_callback}, ...
             'Visible', 'off'...
            );


handles.radio_range =  uicontrol(prompt, 'Style', 'Radio', 'String', 'Range', ...
             'Position', [120,270,100,20],...
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
            'Position', [160,170,100,30]...
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

    if(isnan(range_start))
        range_start = 0;
    end

    if(isnan(range_end))
        range_end = 0;
    end
    
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
set(handles.group1_prompt, 'Visible', 'off');
set(handles.group1_input,'Visible','off');
set(handles.group2_input, 'Visible','off');
set(handles.group2_prompt, 'Visible', 'off');
set(handles.pow_pushbutton,'Visible','off');

%this is a little bit of a dirty hack, but it's still kinda cool
%here we turn on the text prompt, then immediately call the toggle
%so that the section is turned off
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
    set(handles.group1_prompt, 'Visible', 'on');
    set(handles.group1_input,'Visible','on');
	set(handles.group2_input, 'Visible','on');
	set(handles.group2_prompt, 'Visible', 'on');
    set(handles.pow_pushbutton,'Visible','on');
    set(handles.no_toggle, 'Value', ~value);
    handles.custom = 0;
else
    set(handles.mat_select, 'Visible', 'off');
    set(handles.mat_editor, 'Visible', 'off');
    set(handles.mat_pasteboard, 'Visible', 'off');
    set(handles.group1_prompt, 'Visible', 'off');
    set(handles.group1_input,'Visible','off');
	set(handles.group2_input, 'Visible','off');
	set(handles.group2_prompt, 'Visible', 'off');
    set(handles.pow_pushbutton,'Visible','off');
    set(handles.radio_range, 'Visible','off');
end
toggle_range_section(handles);
guidata(gcbf,handles);

function matrix_file_select(hObject, eventData)
matrix_file = file_select_mat;
handles = guidata(gcbf);
handles.output_matrix = matrix_file;
guidata(gcbf,handles);
uiresume(gcbf);

function launch_matrix_editor(hObject, eventData)
handles = guidata(gcbf);
input_matrix = handles.original_design;
edited_matrix = matrix_edit_prompt(input_matrix);
handles.output_matrix = edited_matrix;
guidata(gcbf,handles);
uiresume(gcbf);

function launch_matrix_pasteboard(hObject, eventData)
handles = guidata(gcbf);
handles.output_matrix = matrix_pasteboard;
guidata(gcbf, handles);
uiresume(gcbf);

function individual_radio_callback(hObject, eventData)
handles = guidata(gcbf);
value = get(hObject,'Value');
if(value == 1)
    set(handles.range_from_string, 'Visible', 'off');
    set(handles.range_start, 'Visible', 'off');
    set(handles.range_to_string, 'Visible', 'off');
    set(handles.range_end, 'Visible', 'off');
    set(handles.radio_range, 'Value', 0);
    set(handles.group1_prompt, 'Visible', 'on');
    set(handles.group1_input,'Visible', 'on');
    set(handles.group2_input, 'Visible', 'on');
    set(handles.group2_prompt, 'Visible', 'on');
else
    set(handles.range_from_string, 'Visible', 'off');
    set(handles.range_start, 'Visible', 'off');
    set(handles.range_to_string, 'Visible', 'off');
    set(handles.range_end, 'Visible', 'off');
    set(handles.radio_range, 'Value', 0);
    set(handles.group1_prompt, 'Visible', 'off');
    set(handles.group1_input,'Visible', 'off');
    set(handles.group2_input, 'Visible', 'off');
    set(handles.group2_prompt, 'Visible', 'off');
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
else
    set(handles.range_from_string, 'Visible', 'off');
    set(handles.range_start, 'Visible', 'off');
    set(handles.range_to_string, 'Visible', 'off');
    set(handles.range_end, 'Visible', 'off');
    set(handles.radio_individual, 'Value', 0);
end
set(handles.group1_prompt, 'Visible', 'off');
set(handles.group1_input,'Visible', 'off');
set(handles.group2_input, 'Visible', 'off');
set(handles.group2_prompt, 'Visible', 'off');
guidata(gcbf, handles);

function create_design_matrix(hObject,eventdata)

%grab the surrounding object handles
handles = guidata(gcbf);

group1_subjects = get(handles.group1_input, 'String');
group2_subjects = get(handles.group2_input, 'String');
range_start = get(handles.range_start, 'String');
range_end = get(handles.range_end, 'String');

group1_subjects = str2double(group1_subjects);
group2_subjects = str2double(group2_subjects);
range_start = str2double(range_start);
range_end = str2double(range_end);

%if the value the user entered is not null, numeric, and 
%larger than zero we'll generate a matrix for them
if (~isempty(group1_subjects) && isnumeric(group1_subjects) && group1_subjects> 0 ...
    && ~isempty(group2_subjects) && isnumeric(group2_subjects) && group2_subjects > 0) ...
        ||( ~isempty(range_start) && ~isempty(range_end) && (range_end - range_start) > 0)
            
        new_design(1:group1_subjects,1) = 1;
        new_design(1:group1_subjects,2) = 0;
        new_design(group1_subjects+1 : group1_subjects + group2_subjects,1) = 0;
        new_design(group1_subjects+1 : group1_subjects + group2_subjects,2) = 1;


        %pass the value to the gui handler
        handles.output_matrix = new_design;
        guidata(gcbf,handles);
        uiresume(gcbf);
else
    errordlg('You must enter a valid number of subjects in each group')
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
set(handles.sample_description,'Visible', visible_value);
set(handles.radio_individual, 'Visible', visible_value);
set(handles.radio_range, 'Visible', visible_value);

set(handles.range_start, 'Visible', 'off');
set(handles.range_end, 'Visible', 'off');
set(handles.range_from_string, 'Visible', 'off');
set(handles.range_to_string, 'Visible', 'off');
set(handles.radio_individual, 'Value', 1);
set(handles.radio_range, 'Value', 0);
