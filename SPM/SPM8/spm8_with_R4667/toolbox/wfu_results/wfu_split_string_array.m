function cellArray = wfu_split_string_array(string, delimiter)

if nargin < 2 || isempty(delimiter)
    delimiter = filesep;
end


remainder = inf; 
cellArray = {};
a = 0; 
string = deblank(string);
while length(string)>0
    [cellArray{a+1},string] = strtok(string,delimiter);
    a = a+1; 
end
return 