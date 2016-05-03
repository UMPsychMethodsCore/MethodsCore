function [ user_supplied_matrix ] = matrix_source_prompt( original_design )
%MATRIX_SOURCE_PROMPT Summary of this function goes here
%   Detailed explanation goes here
scrsz = get(0,'ScreenSize');

prompt_width = 400;
prompt_height = 300;

prompt = figure('Visible','on','Position',[scrsz(3)/2-prompt_width/2, ...
    scrsz(4)/2-prompt_height/2,prompt_width,prompt_height], ...
	   'MenuBar', 'none', 'Name', 'Select Matrix', ...
	   'NumberTitle', 'off', 'color', [.7, .7, .7]);
   
uicontrol(prompt, 'String', 'Select a matrix stored in a file', 'Position', [51 201 286 83], ...
            'Callback', {@matrix_file_select} , 'FontSize', 13.0);
        
uicontrol(prompt, 'String', 'Use the editor to create a matrix', 'Position', [51 109 287 82], ...
            'Callback', {@launch_matrix_editor}, 'FontSize', 13.0);
     
uicontrol(prompt, 'String', 'Copy and Paste a matrix', 'Position', [51 17 287 82], ...
            'Callback', {@launch_matrix_pasteboard}, 'FontSize', 13.0);
        
        
handles = guihandles(prompt);
handles.original_design = original_design;
guidata(prompt,handles);

uiwait(prompt);
if ishandle(prompt)
   handles = guidata(prompt);
   user_supplied_matrix = handles.output;
   
   close(prompt);
end

function matrix_file_select(hObject, eventData)
matrix_file = file_select_mat;
handles = guidata(gcbf);
handles.output = matrix_file;
guidata(gcbf,handles);
uiresume(gcbf);

function launch_matrix_editor(hObject, eventData)
handles = guidata(gcbf);
try
	input_matrix = handles.original_design;
	edited_matrix = matrix_edit_prompt(input_matrix);
	handles.output = edited_matrix;
	guidata(gcbf,handles);
	uiresume(gcbf);
catch
	errordlg('No matrix has been provided.');
end

function launch_matrix_pasteboard(hObject, eventData)
handles = guidata(gcbf);
try
	handles.output = matrix_pasteboard;
	guidata(gcbf, handles);
	uiresume(gcbf);
catch
	errordlg('No matrix has been pasted.');
end