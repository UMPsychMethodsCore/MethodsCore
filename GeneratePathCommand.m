function pathcallcmd=generate_PathCommand(InputTemplate)

VariableList=generate_strings_CSS(InputTemplate);
LengthList = length(VariableList);

pathcallcmd=['generate_path_CSS(''',InputTemplate,''''];   %%%% to put single quote within string, put two single quotes in a row 
for iVar=1:LengthList
    pathcallcmd=[pathcallcmd ',' 'num2str(' VariableList{iVar} ')'];
end

pathcallcmd=[pathcallcmd ')'];
pizza=1;
end