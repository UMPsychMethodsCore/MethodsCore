function handles = updateBrain(handles,noMouseAction)
% handles = updateBrain(handles)
%
% wfu_results internal function
%
% if noMouseAction is true, then the action stored in
% handles.data.mouse.action will not be executed.  This is to elminate
% endless recusion loops
%
% this function assumes handles.data.template.[header/volume] is set.
%__________________________________________________________________________
% Created: Oct 9, 2009 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.4 $

  global WFU_LOG;
  if isempty(WFU_LOG)
    WFU_LOG=wfu_LOG();
  end
  WFU_LOG.info('Entered function $Revision: 1.4 $');

  if nargin < 2, noMouseAction = false; end;
  if isempty(handles.data.mouse.action), noMouseAction = true; end;
  
  axes(handles.Brain_Axis);
  
  currPoss=handles.data.currPoss;  %makes things a little easier to read below
  
  if isempty(currPoss.image)
    imat=inv(handles.data.template.header.mat);
    currPoss = voxelImageConversion( imat(13:15),handles,'voxel');
    handles.data.currPoss=currPoss;
  end

  if ~isequal(currPoss.voxel,round(currPoss.voxel))
    currPoss = voxelImageConversion( round(handles.data.currPoss.image),handles,'image');
    handles.data.currPoss=currPoss;
  end
  
  sliceNumber=currPoss.image(3);
  
  if ~isfield(handles.data,'slices'), return; end;
    
  image(handles.data.slices(sliceNumber).image,...
    'Parent',handles.Brain_Axis,...
    'ButtonDownFcn', {@brainCallback, handles.WFU_Results_Window},...
    'CDataMapping','direct');
  
  axis image;
  axis off;
  
  
  %set brain space labels
  set(handles.Brain_Voxel_Text,'String',sprintf('Template Voxel: %i %i %i',currPoss.voxel(1:3)));

  if isfield(handles.data,'overlay') && isfield(handles.data.overlay,'volume') && ~isempty(handles.data.overlay.volume)
    value = handles.data.overlay.volume(currPoss.voxel(1),currPoss.voxel(2),currPoss.voxel(3));
    vstr = num2str(value);
  else
    vstr = 'n/a';
  end
  
  if any(abs(currPoss.MNI(1:3)-round(currPoss.MNI(1:3))) > .01)
    set(handles.Brain_MNI_Text,'String',sprintf('MNI: %.2f %.2f %.2f  Value: %s',...
      currPoss.MNI(1:3),vstr));
  else
    set(handles.Brain_MNI_Text,'String',sprintf('MNI: %i %i %i  Value: %s',...
      currPoss.MNI(1:3),vstr));
  end
  
  imgDim = size(handles.data.slices(sliceNumber).image);
  xline=imgDim(1)*.05;
  yline=imgDim(2)*.05;
  line([currPoss.image(1)-xline; currPoss.image(1)+xline],[currPoss.image(2); currPoss.image(2)],'Color','g');
  line([currPoss.image(1); currPoss.image(1)],[currPoss.image(2)-yline; currPoss.image(2)+yline],'Color','g');
%   line([currPoss.image(1)-xline; currPoss.image(1)+xline],[currPoss.image(2)-yline; currPoss.image(2)+yline],'Color','g');
%   line([currPoss.image(1)-xline; currPoss.image(1)+xline],[currPoss.image(2)+yline; currPoss.image(2)-yline],'Color','g');
  
	set(handles.Brain_Axis, 'Color',get(0,'defaultaxesXColor'),...
	  'XGrid','off',...
	  'XTickLabelMode','manual',...
	  'XTickMode','manual',...
	  'YColor',get(0,'defaultaxesYColor'),...
	  'YGrid','off',...
	  'YTickLabelMode','manual',...
	  'YTickMode','manual');
  
  % save the data for later use
  guidata(handles. WFU_Results_Window,handles);

  if ~noMouseAction
		feval('wfu_results_viewer',handles.data.mouse.action,handles.WFU_Results_Window,[],handles);
	end
return

function brainCallback(src, eventData, fig)
  % Mouse button click function
  %
  % get current guidata....handles are set when the function is associated
  % with the callback, causing problems with scrolling!!!
  global WFU_LOG;

  WFU_LOG.minutia('updateBrain -> brainCallback called');
  
  handles=guidata(fig);
  clickPos = get(handles.Brain_Axis,'CurrentPoint');
  handles.data.currPoss.image(1) = round(clickPos(1,1));
  handles.data.currPoss.image(2) = round(clickPos(1,2));
  
  % ADD CODE FOR FLIP HERE!!!!!!
  
  
  handles.data.currPoss = voxelImageConversion( handles.data.currPoss.image,handles,'image');

  % save the data for later use
  guidata(handles. WFU_Results_Window,handles);
  %udpate brain
  updateBrain(handles);
return

%% Revision Log at end

%{
$Log: updateBrain.m,v $
Revision 1.4  2010/07/22 14:37:04  bwagner
Allowed Up/Down flip.  Flip is now 2 element var with 1st being L/R and 2nd being U/D.  Allow secondary way of calling private/voxelImageConversion.

Revision 1.3  2010/07/19 19:59:13  bwagner
Added WFU_LOG.  MNI location report will now show decimals if needed.

revision 1.2  2009/10/14 14:55:26  bwagner
Time Course mean centering and Paradigm Overlay

revision 1.1  2009/10/09 17:11:37  bwagner
PickAtlas Release Pre-Alpha 1
%}