function value = getFigureTagValue(fig,tagName,tagProperty)
% value = getFigureTagValue(fig,TagName,TagProperty)
%
% returns the `value` of `tagProperty` in a ojection found in `fig` figure
% tagged as `tagName`, otherwise returns [];
  
  value = [];
  if ~ishandle(fig), return; end;
  children = get(fig,'Children');
  tags =  get(children,'Tag');
  index = find(strcmp(tags,tagName));
  if length(index) == 1
    value = get(children(index),tagProperty);
  elseif length(index) > 1
    error('Too many children tagged as `%s`.\n',tagName);
  else
    fprintf('No tagName of `%s` found in specificed figure.\n)',tagName);
  end
return
  


