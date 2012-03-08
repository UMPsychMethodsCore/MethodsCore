function OutputTemplate=mc_GenPath(Template)
% A tool to assist in generating paths to files and directories from user
% specified templates, with variable names filled in.
%
% FORMAT P = mc_GenPath(STRUCT)
% In this format, a STRUCT(ure) object is passed to GeneratePath.
%
% STRUCT                The struct object contains fields for various
%                       settings to be communicated to GeneratePath
%
% STRUCT.Template       REQUIRED - String. For example
%                       '[Exp]/[Subject]/TASK/func/[Run]/'
%                       This will build a string by substituting [Exp]
%                       with the current value of the variable Exp, etc.
%                       Wildcards are allowed throughout to signify none,
%                       one, or many characters.
%
% STRUCT.mode           Optional - String to specify the run mode. Can be...
%
%                       'check' - Function will check to see if path point
%                       to extant file or directory, and raise error
%                       message for user if not.
%
%                       'makedir' - Make the directory as specified by the
%                       path template exactly. Be careful in using this, as
%                       you could end up with directories named
%                       'run_01.nii' if your path returns a pointer to what
%                       should be a file rather than a directory. If
%                       Template includes any wildcard this mode will be
%                       disabled.
%
%                       'makeparentdir' - Parse out the parent path by
%                       removing the "file" part of your path (anything
%                       at the end of the string that isn't terminated by a
%                       "/"). This is useful if GeneratePath is returning
%                       an absolute path to a file you're planning to make
%                       later, but for now you want it to make a directory
%                       where you can place this file. If Template includes
%                       any wildcards this mode will be disabled.
%
%                       NOTE - If STRUCT.Template includes any wildcards,
%                       both makedir and makeparentdir modes will be
%                       disabled.
%
% STRUCT.suffix         Optional - If you expect the final resolution of the call to
%                       include be a particular suffix (e.g. .nii) indicate
%                       it in this slot. This will use the suffix to
%                       whittle down the list of potential matches when
%                       working with wildcards, and, if the final result
%                       does not end in the specified suffix, it will be
%                       appended. Suffix means suffix, not extension, so if
%                       you want to make sure a file ends in .nii, include
%                       the dot in STRUCT.suffix
%                       NOTE - Specifying a suffix will disable makedir mode.
%
% STRUCT.type           Numeric. Can be...
%
%                       1 - STRUCT.Template should resolve to a DIRECTORY
%                       path. This will influence appropriateness of error
%                       messages when failing to find a particular path.
%
%
%
%
% FORMAT P = mc_GenPath(Template)
% In this simplified format, GeneratePath is passed simply a string. All
% other options as discussed above are effectively disabled when this
% format is used.
%
% Template              String. For example
%                       '[Exp]/[Subject]/TASK/func/[Run]/*
%                       This will build a string by substituting [Exp]
%                       the current value of the variable Exp, etc.
%                       A wildcard is allowed at the end, but if it
%                       matches more than one file, it will generate an
%                       error dialog.
%
%
% -------------------------------------------------

%% Parse arguments

type=0; %default to 0
mode='null';

if(isstruct(Template))
    if(isfield(Template,'mode')) mode=Template.mode; end;
    if(isfield(Template,'suffix')) suffix=Template.suffix; end;
    if(isfield(Template,'type')) type=Template.type; end;
    Template = Template.Template;
end

%% Clean up template based on type
if(type==1)
    if(~strcmpi(Template(end),filesep))
        Template = [Template filesep];
    end
end

%% Do bracket expansion
% Parse Template to Identify Variables
index1=strfind(Template,'[');
index2=strfind(Template,']');

if(any(index1>0) && any(index2>0))

    for i=1:length(index1)
        VariableList{i}=Template(index1(i)+1:index2(i)-1);
    end

    %% Parse String to Find Constants to fill TemplatePart
    if index1(1)>1
        TemplatePart{1}=Template(1:index1-1); %Grab all of the string up to the first [
    else
        TemplatePart{1}=''; %%% Contains everything before the first wildcard
    end


    if(length(index1)==1)
        k=0;
    else %Fill in all of the strings in the middle

        for k=1:length(index1)-1  %%% you've already gotten everything before the first index
            TemplatePart{k+1}=horzcat(Template((index2(k)+1):index1(k+1)-1)); %Snag everything after the ith stop, up until the i+1th start
        end
    end

    %%%% this gets the last bit of the template after the final ']'
    if(index2(k+1)<size(Template,2))
        TemplatePart{k+2}=Template(index2(k+1)+1:end);
    else
        TemplatePart{k+2}='';
    end
end

%% Check if file ends with suffix. If not, append it.
if(exist('suffix') && ~strcmpi('makedir',mode))
    if(~strcmp(OutputTemplate((length(OutputTemplate)-length(suffix)+1):length(OutputTemplate)),suffix))
        OutputTemplate = [OutputTemplate suffix];
    end
end


%% Reconstruct the path, piece by piece, substituting in variable values
OutputTemplate =[];

for k=1:length(VariableList)
    try
        VarValue = evalin('caller',VariableList{k});
    catch
        errormsg = sprintf(['Error -- The variable "%s" that you enclosed in brackets does not have a ' ...
            'defined value. Double check that you have not made a typo (e.g. [EXP] instead of Exp) and carefully ' ...
            'read the commented instructions around your path template specification to be sure of which variables ' ...
            'you can use in bracketed expressions.'],VariableList{k});
        errordlg(errormsg,'Path Generation Error')
        error(errormsg)
    end
    OutputTemplate=horzcat(OutputTemplate,TemplatePart{k},VarValue); %This appears to reconstruct the template without the brackets around the variables
end

OutputTemplate = [OutputTemplate TemplatePart{k+1}];

%% Handle cases with wildcards
wildcardflag=0;
indexstar=strfind(OutputTemplate,'*');
indexsep=strfind(OutputTemplate,filesep); %return indices of file separators
if any(indexstar>0) %% if there are any wildcards present
    wildcardflag=1;
    for index=2:length(indexsep) %run over all directory names
        indexsep=strfind(OutputTemplate,filesep); %update indices of separators (they might move around after substitution, but number will not change)
        prePath = OutputTemplate(1:(indexsep(index)-1));
        postPath = OutputTemplate(indexsep(index):end);

        if any(strfind(prePath,'*')>0) %if any wildcards exist in present chunk
            [preParent, preWild, preExt] = fileparts(prePath);
            preWild = [preWild preExt];
            starmatch=dir(prePath);
            switch length(starmatch)
                case 0

                    %Raise error CHECKED
                    errormsg = sprintf(['Error -- No subdirectories found in "%s" that match your wildcard expression "%s". ' ...
                        'Please check your use of wildcards.'], ...
                        preParent, preWild);
                    errordlg(errormsg,'Path Generation Error')
                    error(errormsg)
                case 1
                    preParent = fileparts (prePath) ;
                    preMatch = starmatch.name ;
                    prePath=fullfile(preParent,preMatch) ;
                    OutputTemplate = [prePath postPath] ;
                otherwise
                    %CHECKED
                    errormsg = sprintf(['Error -- More than one subdirectory found in "%s" matches your wildcard expression "%s". ' ...
                        'Please check your use of wildcards.'], ...
                        preParent, preWild);
                    errordlg(errormsg,'Path Generation Error')
                    error(errormsg)
            end
        end
    end
end

% handle the last piece
if any(strfind(OutputTemplate,'*')>0) %if any wildcards STILL exist (they must be in a file spec at the end of OutputTemplate)
    starmatch=dir(OutputTemplate);
    [preParent, preWild, preExt] = fileparts(OutputTemplate);
    preWild = [preWild preExt];
    switch length(starmatch)
        case 0
            %Raise error CHECKED
            if(exist('suffix')
                errormsg=sprintf(['Error -- found no files in "%s" matching your wildcard "%s". ' ...
                    'Note: the suffix "%s" may have been added to your wildcard. ' ...
                    'Please look at your use of wildcards.'], ...
                    preParent,preWild,suffix);
                errordlg(errormsg,'Path Generation Error')
                error(errormsg)
            else
                errormsg = sprintf(['Error -- No files found in "%s" that match your wildcard expression "%s". ' ...
                    'Please check your use of wildcards.'], ...
                    preParent, preWild);
                errordlg(errormsg,'Path Generation Error')
                error(errormsg)
            end
        case 1
            Parent = fileparts (OutputTemplate) ;
            Match = starmatch.name ;
            OutputTemplate=fullfile(Parent,Match) ;
        otherwise
            if exist('suffix')
                errormsg = sprintf(['Error -- More than one file found in "%s" matches your wildcard "%s". ' ...
                    'Note: the suffix "%s" may have been added to your wildcard. Please check your use of wildcards.'], ...
                    preParent, preWild, suffix);
                errordlg(errormsg,'Path Generation Error')
                error(errormsg)
            else
                %Checked
                errormsg = sprintf(['More than one file found in "%s" matches your wildcard expression "%s". ' ...
                    'Please check your use of wildcards.'], ...
                    preParent, preWild);
                errordlg(errormsg,'Path Generation Error')
                error(errormsg)
            end
    end
end






%% Check if path exists (if supposed to)
if strcmpi('check',mode)
    if exist(OutputTemplate,'file') == 0
        errormsg = sprintf(['Error -- it appears that the directory or file "%s" does not exist. ' ...
            'Double check that you haven''t made a typo and that the file actually exists'],OutputTemplate);
        errordlg(errormsg,'Path Generation Error');
        error(errormsg)

    end
end


%% Make path if it doesn't exist (if supposed to)
if strcmpi('makedir',mode) && wildcardflag==0
    if exist(OutputTemplate,'file') == 0
        try
            mkdir(OutputTemplate)
        catch
            errormsg=sprintf(['Error -- there was a problem writing the file/directory "%s", perhaps you don''t ' ...
                'have write permissions to the directory that you specified. Confirm that you are ' ...
                'able to make the directory manually.'],templatepath);
            errordlg(errormsg,'Path Generation Error');
            error(errormsg);
        end
    end
end

%% Make parent path if it doesn't exist (if supposed to)
if strcmpi('makeparentdir',mode) && wildcardflag==0
    [templatepath, templatename, templatext, templateversn] = fileparts(OutputTemplate);
    if exist(templatepath,'file') == 0
        try
            mkdir(templatepath)
        catch
            errordmsg=sprintf(['Error -- there was a problem making the directory "%s", perhaps you don''t ' ...
                'have write permissions to the directory that you specified. Confirm that you are ' ...
                'able to make the directory manually.'],templatepath);
            errordlg(errormsg,'Path Generation Error');
            error(errormsg);
        end
    end
end



%% End the function
end
