function [ edited_matrix ] = matrix_edit_prompt( editable_matrix )
%MATRIX_EDIT_PROMPT Summary of this function goes here
%   Detailed explanation goes here


scrsz = get(0,'ScreenSize');

prompt_width = 750;
prompt_height = 350;

f = figure('Position', [scrsz(3)/2-prompt_width/2, ...
    scrsz(4)/2-prompt_height/2,prompt_width,prompt_height], ...
    'Name', 'Edit Matrix', 'NumberTitle', 'off');
t = uitable('Parent', f, 'Position', [25 125 700 200]);

editable_matrix = num2cell(editable_matrix);

t.setData(editable_matrix);
t.setEditable(1);

set(f,'ToolBar', 'none');
set(f,'MenuBar','none');

uicontrol(f, 'String', 'Ok', 'Position', [400 24 68 47], ...
            'Callback', {@confirm_matrix});
uicontrol(f, 'String', 'Add Row', 'Position', [200 80 75 47], ...
            'Callback', {@add_row});
uicontrol(f, 'String', 'Add Col', 'Position', [100 80 75 47], ...
            'Callback', {@add_col});
uicontrol(f, 'String', 'Del Row', 'Position', [200 24 75 47], ...
            'Callback', {@del_row});
uicontrol(f, 'String', 'Del Col', 'Position', [100 24 75 47], ...
            'Callback', {@del_col});
        
        
handles = guihandles(f);
handles.t = t;
guidata(f,handles);

uiwait(f);

if ishandle(f)
    handles = guidata(f);
    edited_matrix = handles.output;
  	close(f);
end
        
function confirm_matrix(hObject, eventData)

handles = guidata(gcbf);

x = handles.t.getData();

try 
    y = cell(x);
    final_mat = cell2mat(y);
catch 
    %y came back with mixed types of data
    %need to convert them one by one
    [p,q] = size(y);
    %iterate through the matrix, find the cell strings, and convert them 
    %to numbers
    for i = 1:p
        for j = 1:q
            if iscellstr(y(i,j))
                tmp = y(i,j);
                tmp = char(tmp);
                y(i,j) = {str2num(tmp)};
            end
        end
    end
    try
        final_mat = cell2mat(y);
    catch 
        errordlg('Failed to save data, please use a .mat file instead')
        error('');
    end
end

handles.output = final_mat;
guidata(gcbf,handles);


uiresume(gcbf);

function add_row(hObject, eventData)

handles = guidata(gcbf);

rows = handles.t.getNumRows();
handles.t.setNumRows(rows + 1);

function add_col(hObject, eventData)

handles = guidata(gcbf);
cols = handles.t.getNumColumns();
handles.t.setNumColumns(cols + 1);

function del_col(hObject, eventData)

handles = guidata(gcbf);
cols = handles.t.getNumColumns();
handles.t.setNumColumns(cols - 1);


function del_row(hObject, eventData)

handles = guidata(gcbf);
rows = handles.t.getNumRows();
handles.t.setNumRows(rows - 1);

function chad_mat_test()
display 'event fired';