function OutputTemplate=GeneratePath(Template,mode)
% A tool to assist in generating paths to files and directories from user
% specified templates, with variable names filled in.
% 
% FORMAT P = GeneratePath(Template,mode)
% Template              String. For example
%                       '[Exp]/[Subject]/TASK/func/[Run]/*
%                       This will build a string by substituting [Exp]
%                       the current value of the variable Exp, etc.
%                       A wildcard is allowed at the end, but if it
%                       matches more than one file, it will generate an
%                       error dialog.
% 
% mode                  String to specify the run mode. Can be...
%                       
%                       'check' - Function will check to see if path point
%                       to extant file or directory, and raise error
%                       message for user if not.
% 
%                       'make' - If directory, make it (including any
%                       necessary parent directories). If path points to a
%                       file, make the containing directory, and any
%                       necessary parent directories.


%% Parse Template to Identify Variables
index1=strfind(Template,'[');
index2=strfind(Template,']');


%if length(index1) ~= length(index2)
%   display('Your template was not contructed properly. Your open brackets and closed brackets are not balanced')
%end

for i=1:length(index1)
    VariableList{i}=Template(index1(i)+1:index2(i)-1);
end

%% Parse String to Find Constants to fill TemplatePart
if index1(1)>1
    TemplatePart{1}=Template(1:index1-1); %Grab all of the string up to the first [
else
    TemplatePart{1}=''; %%% Contains everything before the first wildcard
end


if length(index1)==1
    k=0;
else %Fill in all of the strings in the middle

    for k=1:length(index1)-1  %%% you've already gotten everything before the first index
        TemplatePart{k+1}=horzcat(Template((index2(k)+1):index1(k+1)-1)); %Snag everything after the ith stop, up until the i+1th start
    end
end

%%%% this gets the last bit of the template after the final ']'
if index2(k+1)<size(Template,2)
    TemplatePart{k+2}=Template(index2(k+1)+1:end);
else
    TemplatePart{k+2}='';
end

%% Reconstruct the path, piece by piece, substituting in variable values
OutputTemplate =[];

for k=1:length(VariableList)
    %     if isnumeric(varargin{k})
    %         varargin{k}=num2str(varargin{k});
    %     end
    VarValue = evalin('caller',VariableList{k});
    OutputTemplate=horzcat(OutputTemplate,TemplatePart{k},VarValue); %This appears to reconstruct the template without the brackets around the variables
end

OutputTemplate = [OutputTemplate TemplatePart{k+1}];


%% Handle cases where file ends in a wildcard
indexstar=strfind(OutputTemplate,'*');
if indexstar>0 %% if there is a wildcard
    clear filelist
    filelist=dir(OutputTemplate); %%% this returns the list of files matching the template. Allows wildcards.
    switch length(filelist)
        case 0
            errordlg('Error -- did not find any files. Please look at your use of wildcards');
        case 1
            [OutputDir OutputName]=fileparts(OutputTemplate);
            OutputTemplate = [OutputDir,filelist(1).name];
        otherwise
            errordlg('Error -- found more than 1 file. Please look at your use of wildcards');
    end %% case staement
end %% if statement
pizza=1;


%% Check if path exists (if supposed to)
if strcmpi('check',mode)
    if exist(OutPutTemplate,'file') ~= 0
        errordlg(['Error -- it appears that the file %s does not exist. ' ... 
            'Double check that you haven''t made a typo and that that file actually exists'],OutputTemplate);
    end
end
    
    
%% Make path if it doesn't exist (if supposed to)
if strcmpi('make',mode)
    [templatepath, templatename, templatext, templateversn] = fileparts(OutPutTemplate);
    if exist(templatepath,'file') ~= 0
        try
            mkdir(templatepath)
        catch
            errordlg(['Error -- there was a problem generating path %s, perhaps you don''t ' ...
                'have write permissions to the directory that you specified. Confirm that you are ' ...
                'able to make the directory manually.'],templatepath);
    end
end

%% End the function
end
