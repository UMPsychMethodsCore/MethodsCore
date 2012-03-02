function OutputTemplate=GeneratePath(Template,mode,suffix)
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
%                       'makedir' - Make the directory as specified by the
%                       path template exactly. Be careful in using this, as
%                       you could end up with directories named
%                       'run_01.nii' if your path returns a pointer to what
%                       should be a file rather than a directory.
% 
%                       'makeparentdir' - Parse out the parent path by
%                       removing the "file" part of your path (anything
%                       at the end of the string that isn't terminated by a
%                       "/"). This is useful if GeneratePath is returning
%                       an absolute path to a file you're planning to make
%                       later, but for now you want it to make a directory
%                       where you can place this file.


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
wildcardflag=0;
indexstar=strfind(OutputTemplate,'*');
if any(indexstar>0) %% if there is a wildcard
    wildcardflag=1;
    clear filelist
%     filelist=spm_select('filter',OutputTemplate); %%% this returns the list of files matching the template. Allows wildcards.
for index=1:length(indexstar)
    startemplate=OutputTemplate;
    curTemplate=OutputTemplate(1:indexstar(index));
    starmatch=dir(curTemplate);
    switch length(starmatch)
        case 0
            %Raise error
        case 1
            curTemplate = fileparts(curTemplate);
            replacedtemplate=fullfile(curTemplate,starmatch.name);
            OutputTemplate(1:length(replacedtemplate)) = replacedtemplate;
        otherwise
            %Raise error
    end
end

filelist=dir(OutputTemplate);
switch length(filelist)
        case 0
            errmsg='Error -- did not find any files. Please look at your use of wildcards';
            errordlg(errmsg);
            error(errmsg)
        case 1
            [OutputDir OutputName]=fileparts(OutputTemplate);
            OutputTemplate = [OutputDir,filelist(1).name];
        otherwise
            if exist('suffix')
                suffixmatch=[];
                for ifile=1:length(filelist)
                    substr=filelist(ifile).name(length((filelist(ifile).name-length(suffix)):length(filelist(ifile).name)));
                    suffixmatch(ifile)=strcmp(substr,suffix);
                end

                filelist=filelist(substr);

                switch length(filelist)
                    case 0
                        errordlg(['Error -- found no files matching your wildcard with the required suffix. ' ...
                            'Please look at your use of wildcards.'])
                    case 1
                        OutputTemplate = filelist(1).name;
                    otherwise
                        errordlg('Error -- found more than 1 file. Please look at your use of wildcards');
                end
            else
                errordlg('Error -- found more than 1 file. Please look at your use of wildcards');
            end
    end %% case staement
end %% if statement
pizza=1;


%% Check if path exists (if supposed to)
if strcmpi('check',mode)
    if exist(OutputTemplate,'file') == 0
        errordlg(sprintf(['Error -- it appears that the directory or file %s does not exist. ' ... 
            'Double check that you haven''t made a typo and that the file actually exists'],OutputTemplate));
    end
end
    
    
%% Make path if it doesn't exist (if supposed to)
if all(strcmpi('makedir',mode),wildcardflag==0)
    if exist(OutputTemplate,'file') == 0
        try
            mkdir(OutputTemplate)
        catch
            errordlg(sprintf(['Error -- there was a problem writing the file/directory %s, perhaps you don''t ' ...
                'have write permissions to the directory that you specified. Confirm that you are ' ...
                'able to make the directory manually.'],templatepath));
        end
    end
end

%% Make parent path if it doesn't exist (if supposed to)
if all(strcmpi('makeparentdir',mode),wildcardflag==0)
    [templatepath, templatename, templatext, templateversn] = fileparts(OutputTemplate);
    if exist(templatepath,'file') == 0
        try
            mkdir(templatepath)
        catch
            errordlg(sprintf(['Error -- there was a problem making the directory %s, perhaps you don''t ' ...
                'have write permissions to the directory that you specified. Confirm that you are ' ...
                'able to make the directory manually.'],templatepath));
        end
    end
end

%% Check if file ends with suffix. If not, append it.
if exist('suffix')
    if strcmp(OutputTemplate((length(OutputTemplate)-length(suffix)+1):length(OutputTemplate)),suffix)
        OutputTemplate = [OutputTemplate suffix];
    end
end


%% End the function
end
