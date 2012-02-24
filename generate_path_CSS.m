function OutputTemplate=generate_path_CSS(Template, varargin)

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

test=1;
%template = strrep(template, ['[' k ']'], varargin{k});
end
