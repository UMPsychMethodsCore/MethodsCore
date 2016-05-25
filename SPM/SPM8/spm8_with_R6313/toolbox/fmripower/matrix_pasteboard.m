function pasted_matrix = matrix_pasteboard
%MATRIX_PASTEBOARD Summary of this function goes here
%   Detailed explanation goes here

scrsz = get(0,'ScreenSize');

prompt_width = 430;
prompt_height = 475;

prompt = figure('Position', [scrsz(3)/2-prompt_width/2, ...
    scrsz(4)/2-prompt_height/2,prompt_width,prompt_height], ...
    'Toolbar', 'none', 'Menubar', 'none', 'Color', [.7 .7 .7], ...
    'NumberTitle', 'off', 'Name', 'Matrix Pasteboard');

uicontrol(prompt, 'Style', 'edit', 'Position', [13 69 401 353], ...
    'ForegroundColor', 'black', 'BackgroundColor', 'white', ...
    'HorizontalAlignment' , 'left', 'Max', 3, 'Min', 0);

uicontrol(prompt, 'Style', 'text', 'FontSize', 14, 'String', ...
    'Paste Matrix Below', 'Position', [93 435 246 19]);

uicontrol(prompt, 'Position', [306 16 108 39], 'String', 'Done', ...
    'Callback', {@confirm_matrix});

handles = guihandles(prompt);
guidata(prompt,handles);
uiwait(prompt);

if ishandle(prompt)
    handles = guidata(prompt);
    pasted_matrix = handles.pasted_matrix;
    close(prompt);
end



function confirm_matrix(hObject, eventData)
edit_field = findobj('Style','edit');
handles = guidata(gcbf);
raw_matrix = get(edit_field,'String');
if(iscell(raw_matrix))
	[rows cols] = size(raw_matrix);
	if(2 <= rows && isempty(raw_matrix{2}))
		raw_matrix = raw_matrix{1};
	end
end

[rows cols] = size(raw_matrix);


completed_matrix = [];
for i = 1:rows
    current_row = sscanf(raw_matrix(i,:), '%i');
    completed_matrix = cat(1, completed_matrix, rot90(current_row));
end

if(isempty(completed_matrix))
	errordlg('Your pasted matrix appears to be empty. This can cause errors in the calculation.');
end

handles.pasted_matrix = completed_matrix;


guidata(gcbf,handles);
uiresume(gcbf);
