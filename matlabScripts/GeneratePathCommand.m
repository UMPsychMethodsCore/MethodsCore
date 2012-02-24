function pathcallcmd=GeneratePathCommand(InputTemplate)

VariableList=GenerateStrings(InputTemplate);
LengthList = length(VariableList);

pathcallcmd=['GeneratePath(''',InputTemplate,''''];   %%%% to put single quote within string, put two single quotes in a row 
for iVar=1:LengthList
    pathcallcmd=[pathcallcmd ',' 'num2str(' VariableList{iVar} ')'];
end

pathcallcmd=[pathcallcmd ')'];
pizza=1;
end