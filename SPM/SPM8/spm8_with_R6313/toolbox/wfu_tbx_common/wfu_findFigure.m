function figHandle = wfu_findFigure(tag)
% figHandle = wfu_findFigure(tag)
%
% finds all active Figure window with tags and returns its handles.
%
% examples: 
% findFigure('WFU_PickAtlas')
% findFigure('WFU_Results_Window')
%

  allChildren=allchild(0);
  allTags=get(allChildren,'Tag');
  paIndex=find(strcmpi(allTags,tag));
  if ~isempty(paIndex)
    figHandle=allChildren(paIndex);
  else
    figHandle=[];
  end
return