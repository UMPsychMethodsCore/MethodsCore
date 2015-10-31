function handles = printResultsTable(handles,tableData)
% handles = printResultsTable(handles)
%
% wfu_results internal function
%

	if nargin < 2
		warning('printResultsTable called without sufficient arguments');
		return;
  end
  
	handles = clearResultsAxis(handles);
  
  %easier variables
  FS=handles.data.fonts.FS;
  PF=handles.data.fonts.PF;
  dy=handles.data.page.dy;
  y =handles.data.page.startY;
  SPM =handles.data.SPM;
  xSPM=handles.data.xSPM;
  axisSize=handles.data.axisSize;
  

	set(gca,'DefaultTextInterpreter','Tex',...
		'DefaultTextVerticalAlignment','Baseline');

	%set the first line
	y = y - dy;
	
	% FROM spm_list.m
	Hc = [];
	text(0,y,['Statistics:  \it\fontsize{',num2str(FS(9)),'}',tableData.tit],...
	'FontSize',FS(11),'FontWeight','Bold');
	line([0 1],[y-1/3*dy y-1/3*dy],'LineWidth',1,'Color','r');
	y = y - dy;
	
	text(0.01,y,	'set-level','FontSize',FS(9));
	line([0,0.11],[1,1]*(y-dy/4),'LineWidth',0.5,'Color','r');
	text(0.08,y-9*dy/8,	'\itc ');
	text(0.02,y-9*dy/8,	'\itp ');
  
  text(0.22,y,        'cluster-level','FontSize',FS(9));
  line([0.14,0.44],[1,1]*(y-dy/4),'LineWidth',0.5,'Color','r');
  text(0.15,y-9*dy/8,    '\itp\rm_{FWE-corr}');
  text(0.24,y-9*dy/8,    '\itq\rm_{FDR-corr}');
  text(0.39,y-9*dy/8,    '\itp\rm_{uncorr}');
  text(0.34,y-9*dy/8,    '\itk\rm_E');

  
  text(0.64,y,        'peak-level','FontSize',FS(9));
  line([0.48,0.88],[1,1]*(y-dy/4),'LineWidth',0.5,'Color','r');
  text(0.49,y-9*dy/8,    '\itp\rm_{FWE-corr}');
  text(0.58,y-9*dy/8,    '\itq\rm_{FDR-corr}');
  text(0.82,y-9*dy/8,    '\itp\rm_{uncorr}');
  text(0.67,y-9*dy/8,     sprintf('\\it%c',xSPM.STAT));
  text(0.75,y-9*dy/8,    '(\itZ\rm_\equiv)');

  text(0.92,y - dy/2,['x,y,z \fontsize{',num2str(FS(8)),'}\{mm\}'],'Fontsize',FS(8));
  
	y     = y - 7*dy/4;
	line([0 1],[y y],'LineWidth',1,'Color','r');
	y     = y - 5*dy/4;
	y0    = y;

	if ~length(xSPM.Z)
		y = y-1*dy;
		text(0.5,y,'no suprathreshold clusters',...
			'HorizontalAlignment','Center',...
			'FontAngle','Italic','FontWeight','Bold',...
			'FontSize',FS(16),'Color',[1,1,1]*.5);
%		set(gca,'Units',oldUnits);
%		return;
	end
	
	set(gca,'DefaultTextFontName',PF.courier,'DefaultTextFontSize',FS(7),...
		'DefaultTextInterpreter','None','DefaultTextFontSize',FS(8));

	%-Column Locations
	%-----------------------------------------------------------------------
	tCol       = [  0.00      0.07 ...				%-Set
					        0.14      0.24      0.32 ... %0.16      0.26      0.34 ...			%-Cluster
					        0.42      0.51      0.58     0.67       0.76 ... %0.46      0.55      0.62      0.71      0.80 ...%-Voxel
	                0.88];      %0.92];						%-XYZ

  tCol = [ 0.01      0.08 ...                                %-Set
           0.15      0.24      0.33      0.39 ...            %-Cluster
           0.49      0.58      0.65      0.74      0.83 ...  %-Peak
           0.92];                                            %-XYZ

                
                
	if ~isempty(tableData.dat) & tableData.dat{1,2} > 1;
		h     = text(tCol(1),y,sprintf(tableData.fmt{1},tableData.dat{1,1}),'FontWeight','Bold');
		h     = text(tCol(2),y,sprintf(tableData.fmt{2},tableData.dat{1,2}),'FontWeight','Bold');
	else
		set(Hc,'Visible','off')
  end
  
  count=0;
  for i=1:size(tableData.dat,1)
		%-Print cluster and maximum voxel-level p values {Z}
   	%---------------------------------------------------------------
   	if isempty(tableData.dat{i,3})
   		fontWeightDesc='normal';
      count=count+1;
   	else
   		fontWeightDesc='Bold';
      count=1;
    end
    if count > tableData.Num, continue; end
		text(tCol(3),y,sprintf(tableData.fmt{3},tableData.dat{i,3}),'FontWeight',fontWeightDesc);
		text(tCol(4),y,sprintf(tableData.fmt{4},tableData.dat{i,4}),'FontWeight',fontWeightDesc);
		text(tCol(5),y,sprintf(tableData.fmt{5},tableData.dat{i,5}),'FontWeight',fontWeightDesc);
		text(tCol(6),y,sprintf(tableData.fmt{6},tableData.dat{i,6}),'FontWeight',fontWeightDesc);
		text(tCol(7),y,sprintf(tableData.fmt{7},tableData.dat{i,7}),'FontWeight',fontWeightDesc);
		text(tCol(8),y,sprintf(tableData.fmt{8},tableData.dat{i,8}),'FontWeight',fontWeightDesc);
		text(tCol(9),y,sprintf(tableData.fmt{9},tableData.dat{i,9}),'FontWeight',fontWeightDesc);
		text(tCol(10),y,sprintf(tableData.fmt{10},tableData.dat{i,10}),'FontWeight',fontWeightDesc);
		text(tCol(11),y,sprintf(tableData.fmt{11},tableData.dat{i,11}),'FontWeight',fontWeightDesc);
    text(tCol(12),y,...
      sprintf(tableData.fmt{12},tableData.dat{i,12}),...
      'FontWeight',fontWeightDesc,...
      'ButtonDownFcn',[...
                        'handles=guidata(gcf);',...
                        'handles.data.currPoss = wfu_voxelImageConversion( [' num2str(tableData.dat{i,12}') '],handles,''MNI'');',...
                        'handles=wfu_updateBrain(handles,true);',...
                        'guidata(gcf,handles);'],...
      'Interruptible','off','BusyAction','Cancel');
	y=y-dy;
	end %

	y      = y - dy; %spacer
	
	%footer
	text(0.5,y,tableData.str,'HorizontalAlignment','Center','FontName',PF.helvetica,...
	  'FontSize',FS(8),'FontAngle','Italic');
	
	line([0 1],[y y],'LineWidth',1,'Color','r');
	
	set(gca,'DefaultTextFontName',PF.helvetica);
	
	text(0.0,y-1*dy,tableData.ftr{1},'FontSize',FS(7));
	text(0.0,y-2*dy,tableData.ftr{2},'FontSize',FS(7));
	text(0.0,y-3*dy,tableData.ftr{3},'FontSize',FS(7));
	text(0.0,y-4*dy,tableData.ftr{4},'FontSize',FS(7));
	text(0.0,y-5*dy,tableData.ftr{5},'FontSize',FS(7));
	text(0.5,y-1*dy,tableData.ftr{6},'FontSize',FS(7));
	text(0.5,y-2*dy,tableData.ftr{7},'FontSize',FS(7));
	text(0.5,y-3*dy,tableData.ftr{8},'FontSize',FS(7));
	text(0.5,y-4*dy,tableData.ftr{9},'FontSize',FS(7));
	
	y=y-6*dy; %for the above text (footer)
	
	
	if handles.data.page.startY - y > axisSize(4)
		page=(handles.data.page.startY-axisSize(4)-y)/axisSize(4);
		if page < 1, page=1; end;
		set(handles.Results_Slider,...
			'Enable','on',...
			'Min',y,...
			'Max',handles.data.page.startY-axisSize(4),...
			'Value',handles.data.page.startY-axisSize(4),...
			'SliderStep',[1/page/8 1/page]);
	else
		set(handles.Results_Slider,'Enable','off');
  end
  handles.data.page.y=y;
return