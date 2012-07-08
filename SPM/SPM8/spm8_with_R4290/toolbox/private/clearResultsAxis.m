function handles = clearResultsAxis(handles)
% axisSize = clearResultsAxis(handles)
%
% wfu_results internal function
%
% axisSize is in points
%

  FS=handles.data.fonts.FS;
  PF=handles.data.fonts.PF;
  dy=handles.data.page.dy;
  y =handles.data.page.startY;
  
  axes(handles.Results_Axis);
	set(gca,'Units','Normalized');

	%get axis size...in pixels
  oldUnits=get(gca,'Units');
  set(gca,'Units','Points');
  axisSize=get(gca,'Position');
	set(gca,'Units',oldUnits);
  
  cla;
  legend('off');
  set(gca,'DefaultTextFontName',PF.helvetica,...
          'FontName',PF.helvetica,...
          'TickLength',[0 0],...
          'Xcolor','white',...
          'Ycolor','white',....
          'XTickLabel',{''},...
          'YTickLabel',{''},...
          'Position',[0 0 1 1],...
          'Color','white',...
          'DataAspectRatio',[1 axisSize(3)-3*dy 1],...
          'YLim',[y-axisSize(4), y],...
          'XLim',[-.05 1.05]);
  
  handles.data.axisSize=axisSize;
return
