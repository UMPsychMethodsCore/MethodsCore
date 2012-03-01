function OutputTemplate=GeneratePath(Template)

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
index1=strfind(Template,'[');
index2=strfind(Template,']');

if index1(1)>1
    TemplatePart{1}=Template(1:index1-1);
else
    TemplatePart{1}=''; %%% Contains everything before the first wildcard
end


if length(index1)==1
    k=0;
else

    for k=1:length(index1)-1  %%% you've already gotten everything before the first index
        TemplatePart{k+1}=horzcat(Template(index2(k)+1:index1(k+1)-1));
    end
end

%%%% this gets the last bit of the template after the final ']'
if index2(k+1)<size(Template,2)
    TemplatePart{k+2}=Template(index2(k+1)+1:end);
else
    TemplatePart{k+2}='';
end


OutputTemplate =[];

for k=1:length(varargin)
    %     if isnumeric(varargin{k})
    %         varargin{k}=num2str(varargin{k});
    %     end
    OutputTemplate=horzcat(OutputTemplate,TemplatePart{k},varargin{k});
end

OutputTemplate = [OutputTemplate TemplatePart{k+1}];



indexstar=strfind(OutputTemplate,'*');
if indexstar>0 %% if there is a wildcard
    clear filelist
    filelist=dir(OutputTemplate); %%% this returns the list of files matching the template. Allows wildcards.
    switch length(filelist)
        case 0
            error('Error -- did not find any files. Please look at your use of wildcards');
        case 1
            [OutputDir OutputName]=fileparts(OutputTemplate);
            OutputTemplate = [OutputDir,filelist(1).name];
        otherwise
            error('Error -- found more than 1 file. Please look at your use of wildcards');
    end %% case staement
end %% if statement
pizza=1;


end
