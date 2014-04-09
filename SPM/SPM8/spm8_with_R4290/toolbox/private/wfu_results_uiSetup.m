	function wfu_results_uiSetup
%
% Sets up the size/position of various elements on the wfu_results_ui figure.
% Defaults are still kept at the beging of wfu_results_ui

	global WFU_RESULTS
	
	%this is the size of the screen in pixels (3 & 4 are length and with respectively)
	Screen = get(WFU_RESULTS.handle.f,'Position') .* WFU_RESULTS.Screen;
	
	try %MAIN PANEL SECTION
		set(WFU_RESULTS.handle.mainPanel,'Units','Pixels');
		mainPanelPixelsRes = get(WFU_RESULTS.handle.mainPanel,'Position');
		set(WFU_RESULTS.handle.mainPanel,'Units','Normalized');
	catch
		mainPanelPixelsRes = [0 0 476 297];
  end
	
	try %BRAIN PANEL SECTION
		set(WFU_RESULTS.handle.brainPanel,'Units','Pixels');
		brainPanelPixelsRes = get(WFU_RESULTS.handle.brainPanel,'Position');
		set(WFU_RESULTS.handle.brainPanel,'Units','Normalized');
  catch
  	brainPanelPixelsRes = [0 0 264 316];
	end
	
	try %RESULTS PANEL SECTION
		set(WFU_RESULTS.handle.resultsPanel,'Units','Pixels');
		resultsPanelPixelsRes = get(WFU_RESULTS.handle.resultsPanel,'Position');
		set(WFU_RESULTS.handle.resultsPanel,'Units','Normalized');
	catch
		resultsPanelPixelsRes = [0 0 760 239]; 
	end

	try %ALL SETTINGS HERE AFTER BASED OFF THE HEIGHT OF A POPUPMENU THAT DOES NOT SEEM TO CHANGE HEIGHT WELL
		oldUnits = get(WFU_RESULTS.handle.atlasGroupPopUp(1),'Units');
		set(WFU_RESULTS.handle.atlasGroupPopUp(1),'Units','Pixels');
		WFU_RESULTS.sizes.popUpHeight = get(WFU_RESULTS.handle.atlasGroupPopUp(1),'Extent');
		WFU_RESULTS.sizes.popUpHeight = WFU_RESULTS.sizes.popUpHeight(4);
		set(WFU_RESULTS.handle.atlasGroupPopUp,'Units',oldUnits);
  catch
		WFU_RESULTS.sizes.popUpHeight = 20;
  end
  
	%main panel and tabs
  try javaFigures = feature('javafigures'); catch javaFigures = 0; end;
  if (javaFigures)
		spacing = 1.25;
	else
		spacing = 1;
	end
	% WFU_RESULTS.sizes.mainTabX defined in config of wfu_results_ui.m
	WFU_RESULTS.sizes.mainTabY = WFU_RESULTS.sizes.popUpHeight/Screen(4);
	WFU_RESULTS.sizes.mainPanelX = 1 - 3*WFU_RESULTS.sizes.borderX - WFU_RESULTS.sizes.brainPanelX;
	WFU_RESULTS.sizes.mainPanelY = ((WFU_RESULTS.sizes.numberOfLines + 1.5) * spacing * WFU_RESULTS.sizes.popUpHeight)/Screen(4);
	WFU_RESULTS.location.firstTabX = WFU_RESULTS.sizes.borderX;
	WFU_RESULTS.location.firstTabY = 1 - WFU_RESULTS.sizes.mainTabY - WFU_RESULTS.sizes.borderY;
	WFU_RESULTS.location.mainPanelX = WFU_RESULTS.location.firstTabX;
	WFU_RESULTS.location.mainPanelY = WFU_RESULTS.location.firstTabY - WFU_RESULTS.sizes.mainPanelY;
	
	%lines in menu
	WFU_RESULTS.sizes.lineHeight = WFU_RESULTS.sizes.popUpHeight/((WFU_RESULTS.sizes.numberOfLines + 1.5) * spacing * WFU_RESULTS.sizes.popUpHeight);
	WFU_RESULTS.sizes.nextLine=WFU_RESULTS.sizes.lineHeight*spacing; %line spacing
	WFU_RESULTS.location.startingLinePos = 1-1.35*WFU_RESULTS.sizes.nextLine; %The top most line's position


	%brain panel
	WFU_RESULTS.location.brainPanelX = WFU_RESULTS.location.mainPanelX + WFU_RESULTS.sizes.mainPanelX + WFU_RESULTS.sizes.borderX;
	WFU_RESULTS.location.brainPanelY = WFU_RESULTS.location.mainPanelY;
	WFU_RESULTS.sizes.brainPanelX = 1 - WFU_RESULTS.location.brainPanelX - WFU_RESULTS.sizes.borderX;
	WFU_RESULTS.sizes.brainPanelY = WFU_RESULTS.sizes.mainPanelY + WFU_RESULTS.sizes.mainTabY;  
	if WFU_RESULTS.sizes.brainLineHeight > 1, WFU_RESULTS.sizes.brainLineHeight = WFU_RESULTS.sizes.brainLineHeight/Screen(4); end;
	WFU_RESULTS.sizes.brain=.95-2*WFU_RESULTS.sizes.brainLineHeight; % This has to be set before the main figure is created.  Ideally, this is the size of the brain X and Y
	WFU_RESULTS.location.brainX = WFU_RESULTS.sizes.borderX;
	WFU_RESULTS.location.brainY = WFU_RESULTS.sizes.borderY-2*WFU_RESULTS.sizes.brainLineHeight;
	
	%items in Results panel
	WFU_RESULTS.sizes.resultsPanelX = 1 - 2*WFU_RESULTS.sizes.borderX;
	WFU_RESULTS.sizes.resultsPanelY = 1 - 3*WFU_RESULTS.sizes.borderY - WFU_RESULTS.sizes.brainPanelY;
	WFU_RESULTS.location.resultsPanelX = WFU_RESULTS.sizes.borderX;
	WFU_RESULTS.location.resultsPanelY = WFU_RESULTS.sizes.borderY;
	WFU_RESULTS.location.textStartingY = 1000; %starting "pixel" for linex of text in results screen
	WFU_RESULTS.sizes.resultsSliderWidth= .20;
	
	%items in control panel (any tab)
	WFU_RESULTS.sizes.lineWidth=1-2*WFU_RESULTS.sizes.borderY;
	WFU_RESULTS.sizes.controlPanelX = 1 - 3*WFU_RESULTS.sizes.borderX - WFU_RESULTS.sizes.brainPanelX;
	%	WFU_RESULTS.sizes.controlPanelY = 1 - 3*WFU_RESULTS.sizes.borderY - WFU_RESULTS.sizes.brainPanelY;  %NOT USED
	WFU_RESULTS.location.leftBorder=WFU_RESULTS.sizes.borderX;
	WFU_RESULTS.location.topBorder=WFU_RESULTS.sizes.borderY;
	
	
	%
	%
	% ASSORTED COMPUTATIONAL POSITIONS
	%
	%
	

	WFU_RESULTS.sizes.brainX=WFU_RESULTS.sizes.brain;
  WFU_RESULTS.sizes.brainY=WFU_RESULTS.sizes.brainX*Screen(3)/Screen(4)-2*WFU_RESULTS.sizes.brainLineHeight-2*WFU_RESULTS.sizes.borderY;
  if (WFU_RESULTS.sizes.brainY > WFU_RESULTS.sizes.brainX) % This makes sure that if the brain is going to eat more space Y wise, we start adjusting the X
    WFU_RESULTS.sizes.brainY=WFU_RESULTS.sizes.brainX-WFU_RESULTS.sizes.borderY;
    WFU_RESULTS.sizes.brainX=WFU_RESULTS.sizes.brainX*Screen(4)/Screen(3);
  end
  WFU_RESULTS.location.brainY=1-WFU_RESULTS.location.topBorder-WFU_RESULTS.sizes.brainY;
  WFU_RESULTS.sizes.sliceSliderWidth=1-WFU_RESULTS.location.brainX-WFU_RESULTS.sizes.brainX;

  if exist('brainPanelPixelsRes','var')
		if WFU_RESULTS.sizes.sliceSliderWidth > 20/brainPanelPixelsRes(3) %don't allow the slider's width to get bulky
	  	WFU_RESULTS.sizes.sliceSliderWidth= 20/brainPanelPixelsRes(3);
disp('resize');
	  end
disp('done');
	end

  WFU_RESULTS.sizes.sliceSliderHeight=WFU_RESULTS.sizes.brainY;
	WFU_RESULTS.location.sliceSliderX=1 - WFU_RESULTS.sizes.sliceSliderWidth;
	WFU_RESULTS.location.sliceSliderY=1-WFU_RESULTS.location.topBorder-WFU_RESULTS.sizes.brainY;
	
	WFU_RESULTS.location.brainX = (1-WFU_RESULTS.sizes.sliceSliderWidth-WFU_RESULTS.sizes.brainX)/2;

	WFU_RESULTS.sizes.voxelTextWidth=WFU_RESULTS.sizes.brainX;
	WFU_RESULTS.sizes.voxelTextHeight=WFU_RESULTS.sizes.brainLineHeight*1.1;  %add a little bit of line spacing so text doesn't overlap
	WFU_RESULTS.location.voxelTextX=WFU_RESULTS.location.brainX;
	WFU_RESULTS.location.voxelTextY=WFU_RESULTS.location.brainY-WFU_RESULTS.sizes.brainLineHeight;

	WFU_RESULTS.sizes.flipTextX = WFU_RESULTS.sizes.borderX*3;
	WFU_RESULTS.sizes.flipTextY = WFU_RESULTS.sizes.borderY*3;
	WFU_RESULTS.location.leftTextX = WFU_RESULTS.location.brainX - WFU_RESULTS.sizes.borderX - WFU_RESULTS.sizes.flipTextX;
	WFU_RESULTS.location.leftTextY = WFU_RESULTS.location.brainY + WFU_RESULTS.sizes.brainY/2 - WFU_RESULTS.sizes.flipTextY/2;
	WFU_RESULTS.location.rightTextX = WFU_RESULTS.location.brainX + WFU_RESULTS.sizes.brainX;
	WFU_RESULTS.location.rightTextY = WFU_RESULTS.location.leftTextY; 


	if exist('resultsPanelPixelsRes','var')
		if WFU_RESULTS.sizes.resultsSliderWidth > 20/resultsPanelPixelsRes(3) %don't allow the slider's width to get bulky
	  	WFU_RESULTS.sizes.resultsSliderWidth= 20/resultsPanelPixelsRes(3);
	  end
	end	

return 
