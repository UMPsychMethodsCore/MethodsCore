function explodedText = wfu_explode(str,needle)
  if nargin < 2, needle=' ';end
  strBreaks=strfind(str,needle);
  if isempty(strBreaks)
    explodedText = {str};
  else
    explodedText=cell(0);
    start=1;
    for i=1:length(strBreaks)
      tmp=str(start:strBreaks(i)-1);
      if ~isempty(tmp)
        explodedText{end+1}=tmp;
      end
      start = strBreaks(i) + length(needle);
    end
    %get last item
    tmp=str(start:end);
    if ~isempty(tmp)
      explodedText{end+1}=tmp;
    end
  end
return