function saveReport(handles)
%
%
% wfu_results internal function
%
%

  if get(handles.Single_Cluster_TimeCourse,'Value')
    defaultName=sprintf('TimeCourse_%i_%i_%i',handles.data.currPoss.MNI(1:3));
  elseif get(handles.Single_Cluster_Labels,'Value')
		defaultName=sprintf('ClusterLabels_%i_%i_%i',handles.data.currPoss.MNI(1:3));
  elseif get(handles.Whole_Brain_Labels,'Value')
		defaultName=sprintf('BrainLabels');
  elseif get(handles.Single_Cluster_Stats,'Value')
		defaultName=sprintf('ClusterStatistics_%i_%i_%i',handles.data.currPoss.MNI(1:3));
  elseif get(handles.Whole_Brain_Stats,'Value')
  	defaultName=sprintf('BrainStatistics');
  else
			defaultName='';
	end

	imageFileTypes={...  %format is print declaration, file extension, file Name, options
	'psc2' '*.ps'  'Color PostScript' '-r150';...
	'ps2'  '*.ps'  'PostScript'       '-r150';...
	'png'  '*.png' 'PNG'              '-r150';...
	'jpeg' '*.jpg' 'JPEG'             '-r150';...  %not using '*.jpg;*.jpeg' as this would not give an extension if selected
	'tiff' '*.tif' 'TIFF'             '-r150';...  %not using '*.tiff;*.tif' as this would not give an extension if selected
	'pdf'  '*.pdf' 'PDF'              '-r150';...
	'bmp'  '*.bmp' 'Bitmap'           '-r150';...
	};
	
	availableImageTypes=print('-d');
	for i=1:size(imageFileTypes,1)
		if any(strmatch(imageFileTypes(i,1),availableImageTypes,'exact'))
			if exist('imageFilter')
				imageFilter(end+1,:)={char(imageFileTypes(i,2)) char(imageFileTypes(i,3))};
			else
				imageFilter(1,:)={char(imageFileTypes(i,2)) char(imageFileTypes(i,3))};
			end
		end
	end
	
	%add the text options here as they would not make it through the avaliable image type loops above.
	%this isn't available for a timecourse
	if ~get(handles.Single_Cluster_TimeCourse,'Value')
		imageFilter(end+1,:)={'*.txt' 'Text'};
		imageFileTypes(end+1,:)={'txt'	'*.txt' 'Text' ''};
	end
		
	[saveFile savePath index] = uiputfile(imageFilter, 'Save output as:',defaultName);
	
	if isequal(saveFile,0) || isequal(savePath,0)
		disp('Save Canceled');
		return;
	end
	try
		[junk_path saveFile saveExt junk]=fileparts(saveFile);
	catch
		[junk_path saveFile saveExt]=fileparts(saveFile);
	end
	
	printIndex=strmatch(imageFilter(index,2),imageFileTypes(:,3),'exact');
	if isempty(printIndex)
		disp('Unknown file format selected.  Save canceled.');
		return;
	end
	
	printDriver=char(imageFileTypes(printIndex,1));
	printType=char(imageFileTypes(printIndex,3));
	printOptions=char(imageFileTypes(printIndex,4));
	
	if (strcmpi(printDriver,'txt'))
		%if this is a text only print, only do these things, then exit
		fileName=fullfile(savePath,sprintf('%s%s',saveFile,'.txt'));  

    if get(handles.Single_Cluster_Stats,'Value')
      complete = saveTableDataToText(handles.data.tableDataCluster,handles.data.xSPM,fileName);
    elseif get(handles.Whole_Brain_Stats,'Value')
			complete = saveTableDataToText(handles.data.tableData,handles.data.xSPM,fileName);
    elseif get(handles.Whole_Brain_Labels,'Value')
      cluster=0;
      for i=1:size(handles.data.tableData.dat,1)
        %cell 3 is empty for subpeaks
        if isempty(handles.data.tableData.dat{i,3}), continue; end  
        cluster=cluster+1;
        [handles stats] = singleClusterLabelStats(handles,cluster);
        if cluster==1
          complete = saveClusterLabelToText(handles,stats,cluster,fileName,'new');
        else
          complete = saveClusterLabelToText(handles,stats,cluster,fileName,'append');
        end
        if ~complete  % check complete of each cluster
          beep();
          disp(sprint('Error writing to %s.  Save operation did not complete.',fileName));
          return;
        end
      end
    elseif get(handles.Single_Cluster_Labels,'Value')
      [xyzmm i] = spm_XYZreg('NearestXYZ',handles.data.currPoss.MNI,handles.data.xSPM.XYZmm);
      [handles stats] = singleClusterLabelStats(handles,i);
      complete = saveClusterLabelToText(handles,stats,[],fileName,'new');
    else
      beep();
      fprintf('Unknown button selected for text file writing');
    end
    
    if ~complete
      beep();
      disp(sprint('Error writing to %s.  Save operation did not complete.',fileName));
      return;
    end
		return;  % DONE!  don't do any more
	end
	
	
  saveFig=wfu_findFigure('WFU_RESULTS_SAVE_WINDOW');
  if saveFig
    delete(saveFig);
  end
  
  saveFig=figure;
	set(saveFig,'Visible','off');
  colormap(handles.data.colormaps.combined);
  set(saveFig,'Tag','WFU_RESULTS_SAVE_WINDOW');

	figurePropertiesToCopy={'Units',...
		'MenuBar' 'ToolBar' 'Renderer'
	};
	for i=1:size(figurePropertiesToCopy,2)
		set(saveFig,figurePropertiesToCopy(i),get(handles.WFU_Results_Window,figurePropertiesToCopy(i)));
	end
	set(saveFig,'Color','w');
	
  pageSize = [1 1 8.5 11];
	oldSaveFigureUnits=get(saveFig,'Units');
	set(saveFig,'Units','inches');
	newLoc = get(saveFig,'Position');
	oldLoc = get(handles.Results_Axis,'Position');
	set(saveFig,'Position',[newLoc(1) newLoc(2) pageSize(3) pageSize(4)]);
	set(saveFig,'Units',oldSaveFigureUnits);


  %BRAINS
  if (...
        get(handles.Single_Cluster_TimeCourse,'Value') || ...
        get(handles.Single_Cluster_Labels,'Value') || ...
        get(handles.Single_Cluster_Stats,'Value')...
     )
      [xyzmm i] = spm_XYZreg('NearestXYZ',handles.data.currPoss.MNI,handles.data.xSPM.XYZmm);
      v.MNI=handles.data.xSPM.XYZmm(:,find(handles.data.A.converted==handles.data.A.converted(i)));
      v=voxelImageConversion(v.MNI,handles,'mni');
      brainHandles = local_showSlices(handles,saveFig,[min(v.image(3,:)):max(v.image(3,:))]);
  else
    brainHandles = local_showSlices(handles,saveFig,[1:size(handles.data.fused.volume,3)]);
  end
  
  
  %REPORT AXIS
  saveAx=subplot('Position',[0 0 1 .5]);
  line;
	cla(saveAx);

  %copy items in axes
	copyobj(allchild(handles.Results_Axis),saveAx);

	axisPropertiesToCopy={'Units',...
		'PlotBoxAspectRatio' 'PlotBoxAspectRatioMode',...
		'XColor' 'XLim' 'XLimMode' 'XTick' 'XTickLabel' 'XTickLabelMode',...
		'YColor' 'YLim' 'YLimMode' 'YTick' 'YTickLabel' 'YTickLabelMode'};
	for i=1:size(axisPropertiesToCopy,2)
		set(saveAx,axisPropertiesToCopy(i),get(handles.Results_Axis,axisPropertiesToCopy(i)))
	end

	%items to override after the copy
  if get(handles.Single_Cluster_TimeCourse,'Value')
		% information that should have a tight fit (graphs)
    set(saveAx,'OuterPosition',[0 0 1 .5]);
		yl=get(saveAx,'YLim');
		pagePointsY=yl(2)-yl(1);
		startY=yl(2);
		endY=yl(1);
    yLim=[endY startY];
  else
    %delete possible left over title
    axH=get(saveAx);
    if isfield(axH,'Title'), delete(axH.Title); end
		% information that should have a page fit (results text)
    pagePointsY=floor(pageSize(4)*70/handles.data.page.dy)*handles.data.page.dy; %points in one page's length (70 is number of text lines on page)
		set(saveAx,'XLim',[-.05 1.05]); %SPM results go past the right (1) on screen.  This adjusts so all text is on screen
		startY=handles.data.page.startY;
		endY=handles.data.page.y;
    yLim=[startY-ceil(pagePointsY/2) startY];
  end
  
	h=legend(handles.Results_Axis);
	if isempty(h)
		legend OFF;
		set(saveAx,'box','off');
	else
		legend(get(h,'String'));
		legend('boxoff');
		set(saveAx,'box','on');
	end
	
	set(saveFig,'PaperPositionMode','auto');
	append=0;
  page=1;
  
  if yLim(1) > endY
    multiplePages=true;
  else
    multiplePages=false;
  end
  
	while yLim(2) > endY
		set(saveAx,'YLim',yLim);
    if multiplePages
			if strcmp(printDriver,'ps2') | strcmp(printDriver,'psc2')
				%poscripts append, don't change file name
				fileName=fullfile(savePath,sprintf('%s%s',saveFile,saveExt));
				if page == 2, append=1; end; % starting will page 2, use the append method for ps files
			else
				%everything else saves pages as single images
				fileName=fullfile(savePath,sprintf('%s_page_%i%s',saveFile,page,saveExt));
			end
    else
      fileName=fullfile(savePath,sprintf('%s%s',saveFile,saveExt));
    end
    if ~append
			fprintf('Saving page %i as %s in file %s\n', page, printType, fileName);
			print(sprintf('-f%i',saveFig),sprintf('-d%s', printDriver), printOptions, fileName);
		else
			fprintf('Appending page %i to file %s\n',page, fileName);
			print(sprintf('-f%i',saveFig),sprintf('-d%s', printDriver), printOptions, '-append', fileName);
    end
    if ~isempty(brainHandles)
      delete(brainHandles);
      brainHandles = [];
      set(saveAx,'Position',[0,0,1,1]);
    end
    page=page+1;
    yLim=[yLim(1)-pagePointsY yLim(1)];
  end % while yLim(2) > endY
  fprintf('Done.  Wrote %i pages.\n',page-1);
return


function brainHandles = local_showSlices(handles,saveFig,slicesToShow)
  brainHandles=[];
  bufferX=0;
  bufferY=.005;
  
  %larger pictures if fewer slices
  if length(slicesToShow) > 20
    sizeX=.065;
    sizeY=.06;
  elseif length(slicesToShow) > 12
    sizeX=.10;
    sizeY=.095;
  elseif length(slicesToShow) > 10
    sizeX=.15;
    sizeY=.145;
  else
    sizeX=.20;
    sizeY=.195;
  end

  
  %available area
  availWidth=1;
  availHeight=.5;
  availArea=availHeight*availWidth;
  sizeOfOne=availArea/length(slicesToShow);
  lengthOfSide=sqrt(sizeOfOne);
  while (floor(availWidth/(lengthOfSide+bufferX)) * floor(availHeight/(lengthOfSide+bufferY)) < length(slicesToShow))
%debug    [lengthOfSide floor(availWidth/(lengthOfSide+bufferX)) * floor(availHeight/(lengthOfSide+bufferY)) length(slicesToShow)]
    lengthOfSide=lengthOfSide*.99;
  end

%debug  [lengthOfSide floor(availWidth/(lengthOfSide+bufferX)) * floor(availHeight/(lengthOfSide+bufferY)) length(slicesToShow)]
  sizeX=lengthOfSide;
  sizeY=lengthOfSide;
  
  X=0;
  Y=1-bufferY-sizeY;

  %current crosshair possition
  currPoss=handles.data.currPoss;

  for slice=slicesToShow
    X=X+bufferX;
    if (X +sizeX> 1)
      X=0+bufferX;
      Y=Y-sizeY-bufferY;
    end
    if sum(handles.data.slices(slice).image(:))==0
      X=X-bufferX;
      continue;
    end
    brainHandles = [brainHandles subplot('Position',[X Y sizeX sizeY])];
    image(handles.data.slices(slice).image,'CDataMapping','direct');
    axis image;
    axis off;

    if slice==currPoss.image(3) && ...
       (...
         get(handles.Single_Cluster_TimeCourse,'Value') || ...
         get(handles.Single_Cluster_Labels,'Value') || ...
         get(handles.Single_Cluster_Stats,'Value')...
       )

      imgDim = size(handles.data.slices(slice).image);
      xline=imgDim(1)*.1;
      yline=imgDim(2)*.1;
      line([currPoss.image(1)-xline; currPoss.image(1)+xline],[currPoss.image(2); currPoss.image(2)],'Color','g');
      line([currPoss.image(1); currPoss.image(1)],[currPoss.image(2)-yline; currPoss.image(2)+yline],'Color','g');
    end


    X=X+sizeX;  %to account for just plotted axis
  end
return
