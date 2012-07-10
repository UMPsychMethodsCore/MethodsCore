function wfu_results_uiPosition
% Sets up the actual 'Position' for various UI controls.  Used
% with wfu_results_uiSetup when the screen is resized to redraw
% the interface

	global WFU_RESULTS;

	try, set(WFU_RESULTS.handle.mainTab,						'Position',[(WFU_RESULTS.location.firstTabX + 0*WFU_RESULTS.sizes.mainTabX) WFU_RESULTS.location.firstTabY WFU_RESULTS.sizes.mainTabX WFU_RESULTS.sizes.mainTabY]); end;
	try, set(WFU_RESULTS.handle.mainPanel,					'Position',[WFU_RESULTS.location.mainPanelX WFU_RESULTS.location.mainPanelY WFU_RESULTS.sizes.mainPanelX WFU_RESULTS.sizes.mainPanelY]); end;
	try, set(WFU_RESULTS.handle.optionsTab,					'Position',[(WFU_RESULTS.location.firstTabX + 1*WFU_RESULTS.sizes.mainTabX) WFU_RESULTS.location.firstTabY WFU_RESULTS.sizes.mainTabX WFU_RESULTS.sizes.mainTabY]); end;
	try, set(WFU_RESULTS.handle.optionsPanel,				'Position',[WFU_RESULTS.location.mainPanelX WFU_RESULTS.location.mainPanelY WFU_RESULTS.sizes.mainPanelX WFU_RESULTS.sizes.mainPanelY]); end;
	try, set(WFU_RESULTS.handle.statsTab,           'Position',[(WFU_RESULTS.location.firstTabX + 2*WFU_RESULTS.sizes.mainTabX) WFU_RESULTS.location.firstTabY WFU_RESULTS.sizes.mainTabX WFU_RESULTS.sizes.mainTabY]); end;
	try, set(WFU_RESULTS.handle.statsPanel,         'Position',[WFU_RESULTS.location.mainPanelX WFU_RESULTS.location.mainPanelY WFU_RESULTS.sizes.mainPanelX WFU_RESULTS.sizes.mainPanelY]); end;
	try, set(WFU_RESULTS.handle.brainPanel,					'Position',[WFU_RESULTS.location.brainPanelX WFU_RESULTS.location.brainPanelY WFU_RESULTS.sizes.brainPanelX WFU_RESULTS.sizes.brainPanelY]); end;
	try, set(WFU_RESULTS.handle.resultsPanel,				'Position',[WFU_RESULTS.location.resultsPanelX WFU_RESULTS.location.resultsPanelY WFU_RESULTS.sizes.resultsPanelX WFU_RESULTS.sizes.resultsPanelY]); end;

	% TABBED PANELS, GLOBAL SETTINGS
	nextLine=WFU_RESULTS.sizes.nextLine;
	linePos=WFU_RESULTS.location.startingLinePos;

	% ITEMS IN MAIN PANEL
	try, set(WFU_RESULTS.handle.atlasGroupText, 		'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*1/4 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.atlasGroupPopUp(1), 'Position',[WFU_RESULTS.location.leftBorder+1*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*1/4 WFU_RESULTS.sizes.lineHeight]); end
	try, set(WFU_RESULTS.handle.atlasGroupPopUp(2), 'Position',[WFU_RESULTS.location.leftBorder+2*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*1/4 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.atlasGroupPopUp(3), 'Position',[WFU_RESULTS.location.leftBorder+3*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*1/4 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-(nextLine * 1.125); %large uicontrol

	try, set(WFU_RESULTS.handle.overlayText, 				'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*1/4 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.overlayButton, 			'Position',[WFU_RESULTS.location.leftBorder+1*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*3/4 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-nextLine;

	try, set(WFU_RESULTS.handle.contrastText, 			'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*1/4 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.contrastButton, 		'Position',[WFU_RESULTS.location.leftBorder+1*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*3/4 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-(nextLine * 1.125); %large uicontrol

	try, set(WFU_RESULTS.handle.roiText, 						'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*1/4 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.roiButton, 					'Position',[WFU_RESULTS.location.leftBorder+1*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*3/4 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-(nextLine * 1.125); %large uicontrol

	try, set(WFU_RESULTS.handle.correctionText, 		'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*1/4 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.fweButton, 					'Position',[WFU_RESULTS.location.leftBorder+1*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*1/4 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.fdrButton, 					'Position',[WFU_RESULTS.location.leftBorder+2*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*1/4 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.noneButton, 				'Position',[WFU_RESULTS.location.leftBorder+3*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*1/4 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-nextLine;

	try, set(WFU_RESULTS.handle.thresholdText, 			'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth/4 linePos WFU_RESULTS.sizes.lineWidth/2 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.thresholdEdit, 			'Position',[WFU_RESULTS.location.leftBorder+2*WFU_RESULTS.sizes.lineWidth/4 linePos WFU_RESULTS.sizes.lineWidth/4 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.thresholdTValue, 		'Position',[WFU_RESULTS.location.leftBorder+3*WFU_RESULTS.sizes.lineWidth/4 linePos WFU_RESULTS.sizes.lineWidth/4 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-nextLine;
	
	try, set(WFU_RESULTS.handle.extentText,					'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth/2 linePos WFU_RESULTS.sizes.lineWidth/2 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.extentEdit,					'Position',[WFU_RESULTS.location.leftBorder+1*WFU_RESULTS.sizes.lineWidth/2 linePos WFU_RESULTS.sizes.lineWidth/2 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-nextLine;

%	try, set(WFU_RESULTS.handle.computeButton,				'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth/4 linePos WFU_RESULTS.sizes.lineWidth/4 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.wholeBrainListButton,	'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth/2 linePos WFU_RESULTS.sizes.lineWidth/2 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.wholeBrainLabelButton,'Position',[WFU_RESULTS.location.leftBorder+1*WFU_RESULTS.sizes.lineWidth/2 linePos WFU_RESULTS.sizes.lineWidth/2 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-nextLine;

	try, set(WFU_RESULTS.handle.clusterListButton,	'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth/2 linePos WFU_RESULTS.sizes.lineWidth/2 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.clusterLabelButton,	'Position',[WFU_RESULTS.location.leftBorder+1*WFU_RESULTS.sizes.lineWidth/2 linePos WFU_RESULTS.sizes.lineWidth/2 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-nextLine;

	try, set(WFU_RESULTS.handle.clusterTimeCourseButton,	'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth/2 linePos WFU_RESULTS.sizes.lineWidth/2 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-nextLine;

	fixedButtonLinePos = linePos;
	
		
	% ITEMS IN OPTIONS PANEL
	
	linePos=WFU_RESULTS.location.startingLinePos;

	try, set(WFU_RESULTS.handle.atlasText,					'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*1/4 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.atlasButton,				'Position',[WFU_RESULTS.location.leftBorder+1*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*3/4 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-nextLine;

	try, set(WFU_RESULTS.handle.templateText,				'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*1/4 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.templateButton,			'Position',[WFU_RESULTS.location.leftBorder+1*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*3/4 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-nextLine;
	
	try, set(WFU_RESULTS.handle.dragText, 					'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*3/4 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.dragButton, 				'Position',[WFU_RESULTS.location.leftBorder+3*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*1/4 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-nextLine;

	try, set(WFU_RESULTS.handle.clickDelayText, 		'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth/2 linePos WFU_RESULTS.sizes.lineWidth/2 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.clickDelayEdit, 		'Position',[WFU_RESULTS.location.leftBorder+1*WFU_RESULTS.sizes.lineWidth/2 linePos WFU_RESULTS.sizes.lineWidth/2 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-nextLine;

	try, set(WFU_RESULTS.handle.scrollText, 				'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*3/4 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.scrollButton, 			'Position',[WFU_RESULTS.location.leftBorder+3*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*1/4 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-nextLine;
	
	try, set(WFU_RESULTS.handle.defaultCorrectionText, 		'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth/2 linePos WFU_RESULTS.sizes.lineWidth/2 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.defaultCorrectionButton, 	'Position',[WFU_RESULTS.location.leftBorder+1*WFU_RESULTS.sizes.lineWidth/2 linePos WFU_RESULTS.sizes.lineWidth/2 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-nextLine;

	try, set(WFU_RESULTS.handle.defaultThresholdText, 'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth/2 linePos WFU_RESULTS.sizes.lineWidth/2 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.defaultThresholdEdit, 'Position',[WFU_RESULTS.location.leftBorder+1*WFU_RESULTS.sizes.lineWidth/2 linePos WFU_RESULTS.sizes.lineWidth/2 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-nextLine;

	try, set(WFU_RESULTS.handle.defaultExtentText, 	'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth/2 linePos WFU_RESULTS.sizes.lineWidth/2 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.defaultExtentEdit, 	'Position',[WFU_RESULTS.location.leftBorder+1*WFU_RESULTS.sizes.lineWidth/2 linePos WFU_RESULTS.sizes.lineWidth/2 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-nextLine;

	try, set(WFU_RESULTS.handle.flipText, 	'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth/2 linePos WFU_RESULTS.sizes.lineWidth/2 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.flipButton, 'Position',[WFU_RESULTS.location.leftBorder+1*WFU_RESULTS.sizes.lineWidth/2 linePos WFU_RESULTS.sizes.lineWidth/2 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-nextLine;

	if (linePos < fixedButtonLinePos), fixedButtonLinePos = linePos; end;

	% ITEMS IN STATS PANEL
	
	linePos=WFU_RESULTS.location.startingLinePos;
  
	try, set(WFU_RESULTS.handle.statsImageText,     'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*1/4 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.statsImageEdit,     'Position',[WFU_RESULTS.location.leftBorder+1*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*3/4 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-nextLine;
  
	try, set(WFU_RESULTS.handle.brainMaskText,      'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*1/4 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.brainMaskEdit,      'Position',[WFU_RESULTS.location.leftBorder+1*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*3/4 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-nextLine;
  
	try, set(WFU_RESULTS.handle.statTypeText,       'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*3/4 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.statTypeButton,     'Position',[WFU_RESULTS.location.leftBorder+1*WFU_RESULTS.sizes.lineWidth*3/4 linePos WFU_RESULTS.sizes.lineWidth*1/4 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-nextLine;

  try, set(WFU_RESULTS.handle.dofText,            'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth*1/4 linePos WFU_RESULTS.sizes.lineWidth*3/4 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.dofEdit,            'Position',[WFU_RESULTS.location.leftBorder+1*WFU_RESULTS.sizes.lineWidth*3/4 linePos WFU_RESULTS.sizes.lineWidth*1/4 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-nextLine;
  
  try, set(WFU_RESULTS.handle.fwhmText,          'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth*1/2 linePos WFU_RESULTS.sizes.lineWidth*1/2 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.fwhmEdit,          'Position',[WFU_RESULTS.location.leftBorder+1*WFU_RESULTS.sizes.lineWidth*1/2 linePos WFU_RESULTS.sizes.lineWidth*1/2 WFU_RESULTS.sizes.lineHeight]); end;
	linePos=linePos-nextLine;

  
 	if (linePos < fixedButtonLinePos), fixedButtonLinePos = linePos; end;

  
	% fixed buttons
	%these buttons start on the Main Panel, but will have their parents change
	%when a new tab is selected.

	linePos = fixedButtonLinePos;
	try, set(WFU_RESULTS.handle.quitButton,					'Position',[WFU_RESULTS.location.leftBorder+0*WFU_RESULTS.sizes.lineWidth/4 linePos WFU_RESULTS.sizes.lineWidth/4 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.showROIMaskButton,	'Position',[WFU_RESULTS.location.leftBorder+2*WFU_RESULTS.sizes.lineWidth/4 linePos WFU_RESULTS.sizes.lineWidth/4 WFU_RESULTS.sizes.lineHeight]); end;
	try, set(WFU_RESULTS.handle.saveButton,					'Position',[WFU_RESULTS.location.leftBorder+3*WFU_RESULTS.sizes.lineWidth/4 linePos WFU_RESULTS.sizes.lineWidth/4 WFU_RESULTS.sizes.lineHeight]); end;

	
	% ITEMS IN BRAIN PANEL
  try, set(WFU_RESULTS.handle.brain,							'Position',[WFU_RESULTS.location.brainX WFU_RESULTS.location.brainY WFU_RESULTS.sizes.brainX WFU_RESULTS.sizes.brainY]); end;
	try, set(WFU_RESULTS.handle.sliceSlider,				'Position',[WFU_RESULTS.location.sliceSliderX WFU_RESULTS.location.sliceSliderY WFU_RESULTS.sizes.sliceSliderWidth WFU_RESULTS.sizes.sliceSliderHeight]); end;
  try, set(WFU_RESULTS.handle.voxelText,					'Position',[WFU_RESULTS.location.voxelTextX WFU_RESULTS.location.voxelTextY WFU_RESULTS.sizes.voxelTextWidth WFU_RESULTS.sizes.voxelTextHeight]); end;
	try, set(WFU_RESULTS.handle.voxelText2,					'Position',[WFU_RESULTS.location.voxelTextX WFU_RESULTS.location.voxelTextY-WFU_RESULTS.sizes.voxelTextHeight WFU_RESULTS.sizes.voxelTextWidth WFU_RESULTS.sizes.voxelTextHeight]); end;
	try, set(WFU_RESULTS.handle.leftText,						'Position',[WFU_RESULTS.location.leftTextX WFU_RESULTS.location.leftTextY WFU_RESULTS.sizes.flipTextX WFU_RESULTS.sizes.flipTextY]); end;
	try, set(WFU_RESULTS.handle.rightText,					'Position',[WFU_RESULTS.location.rightTextX WFU_RESULTS.location.rightTextY WFU_RESULTS.sizes.flipTextX WFU_RESULTS.sizes.flipTextY]); end;


	%RESULTS PANEL
	try, set(WFU_RESULTS.handle.resultsSlider,			'Position',[1-WFU_RESULTS.sizes.resultsSliderWidth-.01 .01 WFU_RESULTS.sizes.resultsSliderWidth .98]); end;
	try, set(WFU_RESULTS.handle.resultsSubPanel,		'Position',[.01 .01 1-WFU_RESULTS.sizes.resultsSliderWidth-.01 .98]); end;


return
