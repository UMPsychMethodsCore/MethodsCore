function handles = printClusterLabelStats(handles, table, clusterNumber, y)
% handles = printClusterLabelStats(handles, stats, clusterNum)
%
% wfu_results internal function
%
% prints the `stats` to handles.Results_Axis.  If clusterNum is given, at
% title of `Cluster N` is given above the stats.  `stats` should be the
% results of the singleClusterLabelStats function.
%
% y is the starting "line" to print on

	if nargin < 2
		warning('printResultsTable called without sufficient arguments');
		return;
  end
  
  if nargin < 3, clusterNumber=[]; end;
  if nargin < 4, y = handles.data.page.startY; end;
  
  %easier variables
  FS=handles.data.fonts.FS;
  PF=handles.data.fonts.PF;
  dy=handles.data.page.dy;
  axisSize=handles.data.axisSize;

	y=y-dy;  %so the first line isn't off the screen

	set(handles.Results_Axis,'DefaultTextInterpreter','Tex',...
		'DefaultTextVerticalAlignment','Baseline');
	
	%title
	if isempty(clusterNumber)
		titleText=sprintf('Cluster Statistics and Labels:  \\it\\fontsize{%i} Cluster with peak at (%g %g %g)',FS(9),table.peak.MNI);
	else
		titleText=sprintf('Cluster %i Statistics and Labels:  \\it\\fontsize{%i} Cluster with peak at (%g %g %g)',clusterNumber, FS(9),table.peak.MNI);
	end
	text(0,y,titleText,...
		'FontSize',FS(11),...
		'FontWeight','Bold',...
    'ButtonDownFcn',[...
      'handles=guidata(gcf);',...
      'handles.data.currPoss = wfu_voxelImageConversion( [' num2str(table.peak.MNI') '],handles,''MNI'');',...
      'handles=wfu_updateBrain(handles,true);',...
      'guidata(gcf,handles);'],...
    'Interruptible','off','BusyAction','Cancel');
	
	line([0,1],[y-1/3*dy y-1/3*dy],'LineWidth',1,'Color','r');
	y=y-dy;
	
	%Cluster Stats
	text(0.01,y,sprintf('Voxels in cluster: %i',table.voxels));
	text(0.26,y,sprintf('Peak T: %.4f',table.max));
	text(0.50,y,sprintf('Mean T: %.4f',table.mean));
	text(0.74,y,sprintf('Std T: %.4f',table.std));
%	line([0,1],[y-1/3*dy y-1/3*dy],'LineWidth',1,'Color','r');
	y=y-dy;

	y=y-dy; %spacer line
	
	%Region Stats
	text(0.06,y,table.headers(1),'FontSize',FS(9));
	text(0.26,y,table.headers(2),'FontSize',FS(9));
	text(0.46,y,table.headers(3),'FontSize',FS(9));
	text(0.71,y,table.headers(4),'FontSize',FS(9));
	text(0.81,y,table.headers(5),'FontSize',FS(9));
	text(0.91,y,table.headers(6),'FontSize',FS(9));

	line([.05,1],[y-1/3*dy y-1/3*dy],'LineWidth',1,'Color','blue');
	y=y-dy;

	%column Locations
	tCol = [ 0.05 .25 .45,...  %Atlas naming
					 .72 .82 .92]; % Voxels Mean Std
	set(gca,'DefaultTextFontName',PF.helvetica,...
		'DefaultTextInterpreter','none',...
		'DefaultTextFontSize',FS(8));
	
	if isfield(table,'data')
		for i=1:size(table.data,1)
			if isempty(table.data{i,1})
				fontWeightDesc='normal';
			else
				fontWeightDesc='Bold';
			end
			text(tCol(1),y,sprintf(table.format{1},table.data{i,1}),'FontWeight',fontWeightDesc);
			text(tCol(2),y,sprintf(table.format{2},table.data{i,2}),'FontWeight',fontWeightDesc);
			text(tCol(3),y,sprintf(table.format{3},table.data{i,3}),'FontWeight',fontWeightDesc);
			text(tCol(4),y,sprintf(table.format{4},table.data{i,4}),'FontWeight',fontWeightDesc);
			text(tCol(5),y,sprintf(table.format{5},table.data{i,5}),'FontWeight',fontWeightDesc);
			text(tCol(6),y,sprintf(table.format{6},table.data{i,6}),'FontWeight',fontWeightDesc);
			y=y-dy;
		end
	else
		text(tCol(1),y,'Voxel not found in atlas(es).','FontWeight','Bold','Color','r','FontSize',FS(10),'FontAngle','italic');
  end

  handles.data.page.y = y;

return