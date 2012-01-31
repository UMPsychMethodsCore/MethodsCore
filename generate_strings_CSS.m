function OutputStrings=generate_strings_CSS(Template, varargin)
Template2=strrep(Template,'*','');

index1=strfind(Template2,'[');
index2=strfind(Template2,']');


%if length(index1) ~= length(index2)
 %   display('Your template was not contructed properly. Your open brackets and closed brackets are not balanced')
%end

for i=1:length(index1)
    OutputStrings{i}=Template2(index1(i)+1:index2(i)-1);
end

end
