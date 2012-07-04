function str = wfu_implode(strArray,delim)
% takes a stringArray and glues parts together with delim inbetween,
% returning a single string
  str = '';
  for i=1:size(strArray,2)
    if i==size(strArray,2), delim = ''; end;
    str = sprintf('%s%s%s',str,char(strArray(i)),delim);
  end
return  