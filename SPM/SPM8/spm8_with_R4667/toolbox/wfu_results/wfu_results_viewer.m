function varargout = wfu_results_viewer(varargin)
%WFU_RESULTS M-file for wfu_results.fig
%      WFU_RESULTS, by itself, creates a new WFU_RESULTS or raises the existing
%      singleton*.
%
%      H = WFU_RESULTS returns the handle to a new WFU_RESULTS or the handle to
%      the existing singleton*.
%
%      WFU_RESULTS('Property','Value',...) creates a new WFU_RESULTS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to wfu_results_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      WFU_RESULTS('CALLBACK') and WFU_RESULTS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in WFU_RESULTS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%__________________________________________________________________________
% Created: Oct 9, 2009 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.20 $

% Edit the above text to modify the response to help wfu_results

% Last Modified by GUIDE v2.5 14-Feb-2011 09:34:44

wfu_require_tbx_common;
global WFU_LOG;
if isempty(WFU_LOG)
  WFU_LOG=wfu_LOG('ERROR');
  WFU_LOG.on;
  %for testing:
  WFU_LOG.level('minutia');
  %WFU_LOG.level('info');
end
wfu_require_spm_lite({'SPM8'});

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wfu_results_OpeningFcn, ...
                   'gui_OutputFcn',  @wfu_results_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargin
  minutiaeList={'WFU_Results_Window_WindowButtonUpFcn',...
                'WFU_Results_Window_WindowButtonDownFcn'}; %mouse commands fill logs WAY too much
  if any(strcmp(varargin{1},minutiaeList))
    WFU_LOG.minutia(sprintf('Cmd: `%s` called',varargin{1}));
  else
    WFU_LOG.info(sprintf('Cmd: `%s` called',varargin{1}));
  end
else
  WFU_LOG.info('Entered function $Revision: 1.20 $');
end

try
  if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
  else
    gui_mainfcn(gui_State, varargin{:});
  end
catch ME
  WFU_LOG.errorstack(ME);
end
% End initialization code - DO NOT EDIT


% --- Executes just before wfu_results is made visible.
function wfu_results_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for wfu_results
global WFU_LOG;
handles.output = hObject;

WFU_LOG.info('Creating Main Display');

%Add wfu_pickatlas tbx, if available
wfu_add_tbx('wfu_results');
junk = wfu_add_tbx('wfu_pickatlas');
if junk==0
  disp('WFU_PickAtlas toolbox not found.  Disabling that functionality');
end


% Set assorted defaults:
handles.originalPath=path;
handles.data = wfu_results_defaults();

wfu_resultsProgress('init',4);
wfu_resultsProgress('setting defaults');

handles.data.timerObj=timer('TimerFcn',@handDownFunction,'StartDelay', handles.data.preferences.clickDelay);

%update menu based on defaults
if handles.data.preferences.drag
  set(handles.Options_Mouse_Click_Drag,'Checked','on');
else
  set(handles.Options_Mouse_Click_Drag,'Checked','off');
end
if handles.data.preferences.flip(1)
  set(handles.Options_Neuro,'Checked','on');
  set(handles.Options_Rad,'Checked','off');
else
  set(handles.Options_Neuro,'Checked','off');
  set(handles.Options_Rad,'Checked','on');
end
if handles.data.preferences.flip(2)
  set(handles.Options_FlipUP,'Check','off');
  set(handles.Options_FlipDOWN,'Check','on');
else
  set(handles.Options_FlipUP,'Check','on');
  set(handles.Options_FlipDOWN,'Check','off');
end

%mouse scrollwheel is a little special
if handles.data.versions.matlab.major >= 7 && handles.data.versions.matlab.minor >= 6 && handles.data.preferences.scroll
  set(handles.WFU_Results_Window,'WindowScrollWheelFcn',{@WFU_Results_Window_WindowScrollWheelFcn,handles.WFU_Results_Window});
  set(handles.Options_Mouse_Wheel_Scrolling,'Checked','on');
elseif handles.data.versions.matlab.major >= 7 && handles.data.versions.matlab.minor >= 6
  set(handles.Options_Mouse_Wheel_Scrolling,'Checked','off');
else %below 7.6, don't show option
  set(handles.Options_Mouse_Wheel_Scrolling,'Visible','off');
end

%threshhold settings
switch lower(handles.data.preferences.threshdesc)
  case 'none'
    set(handles.Options_Stats_Correction_None,'Checked','on');
  case 'fdr'
    set(handles.Options_Stats_Correction_FDR,'Checked','on');
  case 'fwe'
    set(handles.Options_Stats_Correction_FWE,'Checked','on');
end

switch handles.data.preferences.TC
  case 1
    set(handles.Options_TC_Mean,'Checked','on');
  otherwise % 0
    set(handles.Options_TC_Recorded,'Checked','on');
end

if handles.data.preferences.paradigm
  set(handles.Options_Paradigm,'Checked','on');
end

handles=clearResultsAxis(handles);

%assorted toggling groups
handles.groups.correction = [handles.Correction_None handles.Correction_FWE handles.Correction_FDR];
handles.groups.reports = [handles.Single_Cluster_TimeCourse,...
                          handles.Single_Cluster_Labels   handles.Single_Cluster_Stats,...
                          handles.Whole_Brain_Labels      handles.Whole_Brain_Stats];
handles.groups.atlas =[handles.Atlas_Group_1,          handles.Atlas_Group_2,          handles.Atlas_Group_3];
handles.groups.text = [ handles.Extent_Text,  handles.Threshold_Text,   handles.Correction_Text,...
                        handles.Contrast_Text,  handles.Overlay_Text,     handles.Atlas_Group_Text,...
                        handles.ROI_Text];
handles.groups.menuItems = [handles.File_Save_Session,   handles.File_Save_Report];
handles.groups.all = [handles.ROI_PopUpMenu,          handles.Contrast_PopUpMenu,...
                      handles.Extent_Edit,            handles.Threshold_Edit,          handles.Threshold_Status,...
                      handles.Show_ROI,...
                      handles.groups.correction(:)',  handles.groups.reports(:)',      handles.groups.atlas(:)',...
                      handles.groups.text(:)',            handles.groups.menuItems(:)'];
                      

%update assorted screen elements based on preferences/data received;
set(handles.Brain_Left_Text,  'String',handles.data.flipText{handles.data.preferences.flip(1) + 1, 1});
set(handles.Brain_Right_Text, 'String',handles.data.flipText{handles.data.preferences.flip(1) + 1, 2});
set(handles.Threshold_Edit,   'String',num2str(handles.data.preferences.thresh));
set(handles.Extent_Edit,      'String',num2str(handles.data.preferences.extent));

switch upper(handles.data.preferences.threshdesc)
  case('FWE')
    set(handles.Correction_FWE,'Value',1);
  case('FDR')
    set(handles.Correction_FDR,'Value',1);
  otherwise
    set(handles.Correction_None,'Value',1);
end

set(handles.Whole_Brain_Stats,'Value',1);

if isfield(handles.data,'atlas') && ~isempty(handles.data.atlas)
  handles = loadAtlas(handles,true);
  if ~isempty(handles.data.paHandle)
    try
      set(handles.Atlas_Group_1,'Value',getFigureTagValue(handles.data.paHandle,'Atlas1Menu','Value'));
      set(handles.Atlas_Group_2,'Value',getFigureTagValue(handles.data.paHandle,'Atlas2Menu','Value'));
    catch
      disp('Difficulty syncing atlas groups with possibly open pickatlas window.');
    end
  end
else
  handles = loadTemplate(handles);
end

try 
  spm('CheckModality');
catch
  WFU_LOG.minutia('Setting spm_lite defaults');
  spm('Defaults','FMRI');
end

if spm_get_defaults('stats.topoFDR')
  loc = get(handles.Correction_FDR,'Position');
  set(handles.Correction_FWE,'Position',loc);
  set(handles.Correction_FDR,'Position',[-10 -10 1 1]);
end

wfu_resultsProgress('done');

%default mouse action
handles.data.mouse.action='';

%default state of action buttons
buttonEnableState(handles,'disable');
set(handles.File,'Enable','on');
set(handles.Options,'Enable','on');

if exist('wfu_pickatlastype.fig','file') ~= 2
  set(handles.Options_Atlas,'Visible','off');
  set(handles.Whole_Brain_Labels,'Visible','off');
  set(handles.Single_Cluster_Labels,'Visible','off');
  set(handles.groups.atlas,'Visible','off');
  set(handles.Atlas_Group_Text,'Visible','off');
end

if exist('wfu_dicomtk.m','file') == 2 && exist('wfu_dicom_magilla.m','file') == 2
  set(handles.Dicom,'Visible','on');
end

if exist('/ansir2/WFU/distribution/WFU','dir')==7
  set(handles.WFU,'Visible','on');
end

% Update handles structure
guidata(hObject, handles);
WFU_LOG.info('Entered Functioning Program');

% UIWAIT makes wfu_results wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = wfu_results_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN FIGURE FUNCTIONS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes during object deletion, before destroying properties.
function WFU_Results_Window_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to WFU_Results_Window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


cleanupAndExit(guidata(hObject));


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function WFU_Results_Window_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to WFU_Results_Window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mouse=handles.data.mouse;
mouse.screenArea=[];
mouse.start=get(handles.WFU_Results_Window,'CurrentPoint');
mouse.screenArea = findScreenArea(handles);

if ~isempty(mouse.screenArea) && handles.data.preferences.drag
  mouse.oldPointer=get(handles.WFU_Results_Window,'Pointer');
  start(handles.data.timerObj); 
else
  set(handles.WFU_Results_Window,'WindowButtonMotionFcn',[]);
end

% Update handles structure
%mouseD=mouse
handles.data.mouse=mouse;
guidata(hObject, handles);


% --- Executes on mouse motion over figure - except title and menu.
function WFU_Results_Window_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to WFU_Results_Window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%use the guidata from the hObject becuase the setting of this function in
%buttondown makes the handles static...which is what we don't want
handles = guidata(hObject);
mouse=handles.data.mouse;

if ~isfield(mouse,'screenArea') || isempty(mouse.screenArea), return; end;

mouse.end=get(handles.WFU_Results_Window,'CurrentPoint');
change=mouse.end-mouse.start;
speedStep=floor(abs(change(2))/.0075) + 1;

switch lower(mouse.screenArea)
  case 'brain'
    handle=handles.Brain_Slider;
    action='updateBrain(handles,true);';
  case 'results'
    handle=handles.Results_Slider;
    action='resultsSliderCallback;';
    sliderSteps=get(handle,'SliderStep')*-1;
    speedStep=speedStep*sliderSteps(1)*(get(handle,'Max')-get(handle,'Min')) * -1;
  otherwise
    return;
end

if strcmpi(get(handle,'Enable'),'off'), return; end;

newValue=get(handle,'Value')+sign(change(2))*speedStep;
if newValue > get(handle,'Max'), newValue = get(handle,'Max'); end;
if newValue < get(handle,'Min'), newValue = get(handle,'Min'); end;

if newValue ~= get(handle,'Value')
  set(handle,'Value',newValue);
  switch lower(mouse.screenArea)
    case 'brain'
      image=handles.data.currPoss.image;
      image(3)=newValue;
      handles.data.currPoss = voxelImageConversion( image,handles,'image');
    case 'results'
      set(handles.Results_Axis,'YLim',[newValue newValue+handles.data.axisSize(4)]);
  end
  try, eval(action); end;
end
mouse.start=mouse.end;

% Update handles structure
handles.data.mouse=mouse;
guidata(hObject, handles);



% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function WFU_Results_Window_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to WFU_Results_Window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mouse=handles.data.mouse;
try,
  set(handles.WFU_Results_Window,'Pointer',mouse.oldPointer);
catch
  set(handles.WFU_Results_Window,'Pointer','arrow');
end
stop(handles.data.timerObj);
set(handles.WFU_Results_Window,'WindowButtonMotionFcn',[]);


% --- Executes when WFU_Results_Window is resized.
function WFU_Results_Window_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to WFU_Results_Window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on scroll wheel click while the figure is in focus.
function WFU_Results_Window_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to WFU_Results_Window (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)

% handles and eventdata are unassigned, due to way callback is created.

handles = guidata(hObject);
mouse=handles.data.mouse;

mouse.screenArea=[];
mouse.start=get(handles.WFU_Results_Window,'CurrentPoint');
mouse.screenArea = findScreenArea(handles);
if isempty(mouse.screenArea), return; end;

speedStep=abs(eventdata.VerticalScrollCount);

switch lower(mouse.screenArea)
  case 'brain'
    handle=handles.Brain_Slider;
    action='updateBrain(handles,true);';
  case 'results'
    handle=handles.Results_Slider;
    action='resultsSliderCallback;';
    sliderSteps=get(handle,'SliderStep')*-1;
    speedStep=speedStep*sliderSteps(1)*(get(handle,'Max')-get(handle,'Min'));
  otherwise
    return;
end

if strcmpi(get(handle,'Enable'),'off'), return; end;

newValue=get(handle,'Value')+ sign(eventdata.VerticalScrollCount)*speedStep;%

if newValue > get(handle,'Max'), newValue = get(handle,'Max'); end;
if newValue < get(handle,'Min'), newValue = get(handle,'Min'); end;

if newValue ~= get(handle,'Value')
  set(handle,'Value',newValue);
  switch lower(mouse.screenArea)
    case 'brain'
      image=handles.data.currPoss.image;
      image(3)=newValue;
      handles.data.currPoss = voxelImageConversion( image,handles,'image');
    case 'results'
      set(handles.Results_Axis,'YLim',[newValue newValue+handles.data.axisSize(4)]);
  end
  try, eval(action); end;
end

% Update handles structure
handles.data.mouse=mouse;
guidata(hObject, handles);



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MENU FUNCTIONS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%                                                   +-------------------+
%                                                   | FUNCTION NOT USED |
%                                                   +-------------------+

% --------------------------------------------------------------------
function File_Open_Callback(hObject, eventdata, handles)
% hObject    handle to File_Open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WFU_LOG;

buttonEnableState(handles,'disable');
try
  handles = loadSelect(handles);
  handles = wfu_results_compute(handles);
  handles=updateBrain(handles,true);
catch ME
	set(gcf,'Pointer','Arrow');
  w=wfu_findFigure('WFU_RESULTS_VIEWER_IMPORTER');
  if ~isempty(w)
    delete(w);
  end
  WFU_LOG.errorstack(ME);
  WFU_LOG.errordlg('Error opening data...');
  return;
end

buttonEnableState(handles,'enable');
guidata(hObject,handles);
WFU_LOG.info(sprintf('Opened File %s',handles.data.overlay.fnameOrig));

% --------------------------------------------------------------------
function File_Save_Report_Callback(hObject, eventdata, handles)
% hObject    handle to File_Save_Report (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WFU_LOG;
saveReport(handles);
WFU_LOG.info('Saved report.');


% --------------------------------------------------------------------
function File_Save_Session_Callback(hObject, eventdata, handles)
% hObject    handle to File_Save_Session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WFU_LOG;
handles=guidata(hObject);
[saveFile savePath] = uiputfile('*.mat','Save current results display as:');
if isempty(saveFile), return; end;
matfile=fullfile(savePath,saveFile);
savedata=handles.data;
save(matfile,'savedata');
WFU_LOG.info(sprintf('Saved Session: %s',matfile));

% --------------------------------------------------------------------
function File_Load_Session_Callback(hObject, eventdata, handles)
% hObject    handle to File_Load_Session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WFU_LOG;
handles=guidata(hObject);

[handles matfile] = load_saved_results_session(handles);
if isempty(matfile), return; end;

%handles = wfu_results_compute(handles);  %would like not to have to recompute
handles=updateBrain(handles,true);

%update reports

if isfield(handles.data,'xSPM') && ~isempty(handles.data.xSPM)
  if ~isempty(handles.data.mouse.action)
    switch handles.data.mouse.action
      case 'Single_Cluster_Stats_Callback'
        feval('Single_Cluster_Stats_Callback',handles.Single_Cluster_Stats,[],handles);
      case 'Whole_Brain_Labels_Callback'
        feval('Whole_Brain_Labels_Callback',handles.Whole_Brain_Labels,[],handles);
      case 'Single_Cluster_Labels_Callback'
        feval('Single_Cluster_Labels_Callback',handles.Single_Cluster_Labels,[],handles);
      case 'Single_Cluster_TimeCourse_Callback'
        feval('Single_Cluster_TimeCourse_Callback',handles.Single_Cluster_TimeCourse,[],handles);
      otherwise
        feval('Whole_Brain_Stats_Callback',handles.Whole_Brain_Stats,[],handles);
    end  
  end
end

buttonEnableState(handles,'enable');
guidata(hObject,handles);
WFU_LOG.info(sprintf('Loaded Session: %s',matfile));


% --------------------------------------------------------------------
function File_Exit_Callback(hObject, eventdata, handles)
% hObject    handle to File_Exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cleanupAndExit(handles);


% --------------------------------------------------------------------
function Options_Callback(hObject, eventdata, handles)
% hObject    handle to Options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%                                                   +-------------------+
%                                                   | FUNCTION NOT USED |
%                                                   +-------------------+


% --------------------------------------------------------------------
function Options_Atlas_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Atlas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WFU_LOG;
handles=guidata(hObject);
handles.data.atlas=wfu_pickatlastype;

handles = loadAtlas(handles,true,true);
if isfield(handles.data,'overlay') && isfield(handles.data.overlay,'volume') && ~isempty(handles.data.overlay.volume)
  %only turn on these options if there is a reason.
  for i=1:length(handles.data.activeAtlas)
    if handles.data.activeAtlas(i)
      set(handles.groups.atlas(i),'Enable','on');
    else
      set(handles.groups.atlas(i),'Enable','off');
    end
  end
  
  handles=wfu_results_compute(handles);
end

handles.data.currPoss.image=[]; %reset to origin of image.
handles = updateBrain(handles);
set(handles.Brain_Slider,'Value',handles.data.currPoss.image(3));

guidata(hObject,handles);
WFU_LOG.info(sprintf('Changed Atlas to %s',handles.data.atlas.atlasname));

% --------------------------------------------------------------------
function Options_Background_Image_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Background_Image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WFU_LOG;
handles=guidata(hObject);
template = wfu_pickfile('image','Select a background image',...
                        fileparts(handles.data.template.header.fnameOrig),...
                        []);
if isempty(template), return; end;
templateHdr=spm_vol(wfu_uncompress_nifti(template));
if any(templateHdr.mat~=handles.data.atlasInfo(1).Iheader.mat)
  WFU_LOG.errordlg('Magnet Transforms do not match those of currently loaded atlas, unable to load new template.');
  return;
end
handles.data.template.header.fname=template;
handles=loadTemplate(handles);
if isfield(handles.data,'overlay') && isfield(handles.data.overlay,'volume') && ~isempty(handles.data.overlay.volume)
  handles=wfu_results_compute(handles);
end
handles = updateBrain(handles);
guidata(hObject,handles);
WFU_LOG.info(sprintf('Changed Background image to %s',template));


% --------------------------------------------------------------------
function Options_Stats_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Stats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%                                                   +-------------------+
%                                                   | FUNCTION NOT USED |
%                                                   +-------------------+


% --------------------------------------------------------------------
function Options_Stats_Correction_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Stats_Correction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%                                                   +-------------------+
%                                                   | FUNCTION NOT USED |
%                                                   +-------------------+


% --------------------------------------------------------------------
function Options_Stats_Correction_None_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Stats_Correction_None (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WFU_LOG;
handles = guidata(hObject);
handles = changeDefaultCorrection('none',handles);
guidata(hObject,handles);
WFU_LOG.info('Changed default statistics method to `none`.');



% --------------------------------------------------------------------
function Options_Stats_Correction_FDR_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Stats_Correction_FDR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WFU_LOG;
handles = guidata(hObject);
handles = changeDefaultCorrection('fdr',handles);
guidata(hObject,handles);
WFU_LOG.info('Changed default statistics method to `FDR`.');


% --------------------------------------------------------------------
function Options_Stats_Correction_FWE_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Stats_Correction_FWE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WFU_LOG;
handles = guidata(hObject);
handles = changeDefaultCorrection('fwe',handles);
guidata(hObject,handles);
WFU_LOG.info('Changed default statistics method to `FWE`.');


% --------------------------------------------------------------------
function Options_Stats_Threshold_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Stats_Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WFU_LOG;
handles = guidata(hObject);
rsp=inputdlg('Please enter the default threshold to use when first loading a statistical image',...
             'Default Threshold',1,...
             {num2str(handles.data.preferences.thresh)});
if isempty(rsp), return; end;
newThresh=str2num(char(rsp));

while isempty(newThresh)
  beep();
  rsp=inputdlg('Input not understood.  Please enter desired threshold. ',...
               'Default Threshold',1,...
               {num2str(handles.data.preferences.thresh)});
  if isempty(rsp), return; end;
  newThresh=str2num(char(rsp));
end
handles.data.preferences.thresh=newThresh;
guidata(hObject,handles);
WFU_LOG.info(sprintf('Changed default statistics threshold to %f.',newThresh));


% --------------------------------------------------------------------
function Options_Stats_Extent_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Stats_Extent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WFU_LOG;
handles = guidata(hObject);
rsp=inputdlg('Please enter the default voxel extent to use when first loading a statistical image',...
             'Default Extent',1,...
             {num2str(handles.data.preferences.extent)});
if isempty(rsp), return; end;
newExtent=str2num(char(rsp));

while isempty(newExtent)
  beep();
  rsp=inputdlg('Input not understood.  Please enter desired extent. ',...
               'Default Extent',1,...
               {num2str(handles.data.preferences.extent)});
  if isempty(rsp), return; end;
  newExtent=str2num(char(rsp));
end
handles.data.preferences.extent=newExtent;
guidata(hObject,handles);
WFU_LOG.info(sprintf('Changed default statistics extent to %f.',newExtent));


% --------------------------------------------------------------------
function Options_Mouse_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Mouse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%                                                   +-------------------+
%                                                   | FUNCTION NOT USED |
%                                                   +-------------------+

% --------------------------------------------------------------------
function Options_Mouse_Click_Drag_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Mouse_Click_Drag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WFU_LOG;
handles = guidata(hObject);

switch lower(get(handles.Options_Mouse_Click_Drag,'Checked'))
  case 'on'
    handles.data.preferences.drag = 0;
    set(handles.Options_Mouse_Click_Drag,'Checked','off')
  case 'off'
    handles.data.preferences.drag = 1;
    set(handles.Options_Mouse_Click_Drag,'Checked','on')
end
guidata(hObject,handles);
WFU_LOG.info(sprintf('Changed click/drag preference to %s.',get(handles.Options_Mouse_Click_Drag,'Checked')));


% --------------------------------------------------------------------
function Options_Mouse_Delay_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Mouse_Delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WFU_LOG;
handles = guidata(hObject);
rsp=inputdlg(['Please enter the delay (in seconds) between clicking ',...
              'and when dragging should become available.',...
              'Default is .15.'],'Click/Drag delay',1,...
              {num2str(handles.data.preferences.clickDelay)});
if isempty(rsp), return; end;
newDelay=str2num(char(rsp));

while isempty(newDelay)
  beep();
  rsp=inputdlg(['Input not understood.  Please enter the Click/Drag delay in seconds. ',...
              'Default is .15.'],'Click/Drag delay',1,...
              {num2str(handles.data.preferences.clickDelay)});
  if isempty(rsp), return; end;
  newDelay=str2num(char(rsp));
end
handles.data.preferences.clickDelay=newDelay;
set(handles.data.timerObj,'StartDelay', handles.data.preferences.clickDelay);
guidata(hObject,handles);
WFU_LOG.info(sprintf('Changed default mouse click delay to %f.',newDelay))


% --------------------------------------------------------------------
function Options_Mouse_Wheel_Scrolling_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Mouse_Wheel_Scrolling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WFU_LOG;
handles = guidata(hObject);
if handles.data.versions.matlab < 7.6, return; end;

switch lower(get(handles.Options_Mouse_Wheel_Scrolling,'Checked'))
  case 'on'
    handles.data.preferences.scroll = 0;
    set(handles.Options_Mouse_Wheel_Scrolling,'Checked','off')
    set(handles.WFU_Results_Window,'WindowScrollWheelFcn',[]);
  case 'off'
    handles.data.preferences.scroll = 1;
    set(handles.Options_Mouse_Wheel_Scrolling,'Checked','on')
    set(handles.WFU_Results_Window,'WindowScrollWheelFcn',{@WFU_Results_Window_WindowScrollWheelFcn,handles.WFU_Results_Window});
end
guidata(hObject,handles);
WFU_LOG.info(sprintf('Changed scrolling preference to %s.',get(handles.Options_Mouse_Wheel_Scrolling,'Checked')));



% --------------------------------------------------------------------
function Options_Neuro_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Neuro (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WFU_LOG;
handles = guidata(hObject);
handles = changeView('n',handles);
guidata(hObject,handles);
WFU_LOG.info('Changed display preference to Neurological.');

% --------------------------------------------------------------------
function Options_Rad_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Rad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WFU_LOG;
handles = guidata(hObject);
handles = changeView('r',handles);
guidata(hObject,handles);
WFU_LOG.info('Changed display preference to Radiological.');

% --------------------------------------------------------------------
function Options_FlipUP_Callback(hObject, eventdata, handles)
% hObject    handle to Options_FlipUP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global WFU_LOG;
handles = guidata(hObject);
handles = changeView('u',handles);
guidata(hObject,handles);
WFU_LOG.info('Changed display preference to Up.');

function Options_FlipDOWN_Callback(hObject, eventdata, handles)
% hObject    handle to Options_FlipUP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global WFU_LOG;
handles = guidata(hObject);
handles = changeView('d',handles);
guidata(hObject,handles);
WFU_LOG.info('Changed display preference to Down.');

% --------------------------------------------------------------------
function Options_TC_Recorded_Callback(hObject, eventdata, handles)
% hObject    handle to Options_TC_Recorded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WFU_LOG;
handles = guidata(hObject);
set(handles.Options_TC_Recorded,'Checked','on');
set(handles.Options_TC_Mean','Checked','off');
handles.data.preferences.TC=0;
guidata(hObject,handles);
if strcmpi(handles.data.mouse.action,'Single_Cluster_TimeCourse_Callback')
  feval('Single_Cluster_TimeCourse_Callback',handles.Single_Cluster_TimeCourse,[],handles);
end
WFU_LOG.info('Changed Time Course preference to Real Values.');


% --------------------------------------------------------------------
function Options_TC_Mean_Callback(hObject, eventdata, handles)
% hObject    handle to Options_TC_Mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WFU_LOG;
handles = guidata(hObject);
set(handles.Options_TC_Recorded,'Checked','off');
set(handles.Options_TC_Mean','Checked','on');
handles.data.preferences.TC=1;
guidata(hObject,handles);
if strcmpi(handles.data.mouse.action,'Single_Cluster_TimeCourse_Callback')
  feval('Single_Cluster_TimeCourse_Callback',handles.Single_Cluster_TimeCourse,[],handles);
end
WFU_LOG.info('Changed Time Course preference to Normalized Mean.');


% --------------------------------------------------------------------
function Options_Paradigm_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Paradigm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WFU_LOG;
handles = guidata(hObject);

if strcmpi(get(handles.Options_Paradigm,'Checked'),'off')
  %turn paradigm on
  set(handles.Options_Paradigm,'Checked','on');
  handles.data.preferences.paradigm=1;
else
  %turn paradigm off
  set(handles.Options_Paradigm,'Checked','off');
  handles.data.preferences.paradigm=0;
end
handles=showParadigm(handles);
guidata(hObject,handles);
WFU_LOG.info(sprintf('Changed default show paradigm to %d.',handles.data.preferences.paradigm));


% --------------------------------------------------------------------
function Options_Paradigm_Select_Parent_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Paradigm_Select_Parent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%                                                   +-------------------+
%                                                   | FUNCTION NOT USED |
%                                                   +-------------------+

% --------------------------------------------------------------------
function Options_Paradigm_Select_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Paradigm_Select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(hObject);
set(handles.Options_Paradigm_Select,'Checked','off');
set(hObject,'Checked','on');
set(handles.Options_Paradigm,'Checked','off');  %so the update below will work
guidata(hObject,handles);

%update graph
Options_Paradigm_Callback(hObject,[],[]);


% --------------------------------------------------------------------
function Options_Save_Callback(hObject, eventdata, handles)
% hObject    handle to Options_Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WFU_LOG;

handles = guidata(hObject);
pmat = fullfile(prefdir,'wfu_pickatlas.mat');

wfu_results_ui_preferences.threshdesc   = handles.data.preferences.threshdesc;
wfu_results_ui_preferences.thresh       = handles.data.preferences.thresh;
wfu_results_ui_preferences.extent       = handles.data.preferences.extent;
wfu_results_ui_preferences.scroll       = handles.data.preferences.scroll;
wfu_results_ui_preferences.drag         = handles.data.preferences.drag;
wfu_results_ui_preferences.clickDelay   = handles.data.preferences.clickDelay;
wfu_results_ui_preferences.flip         = handles.data.preferences.flip;
wfu_results_ui_preferences.TC           = handles.data.preferences.TC;
wfu_results_ui_preferences.paradigm     = handles.data.preferences.paradigm;


save(pmat,'wfu_results_ui_preferences');
WFU_LOG.info('Preferences saved');

% --------------------------------------------------------------------
function WFU_Callback(hObject, eventdata, handles)
% hObject    handle to WFU (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%                                                   +-------------------+
%                                                   | FUNCTION NOT USED |
%                                                   +-------------------+

% --------------------------------------------------------------------
function WFU_TC_Regressor_File_Callback(hObject, eventdata, handles)
% hObject    handle to WFU_TC_Regressor_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wfu_timeCourseExport();

% --------------------------------------------------------------------
function Help_Callback(hObject, eventdata, handles)
% hObject    handle to Help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%                                                   +-------------------+
%                                                   | FUNCTION NOT USED |
%                                                   +-------------------+


% --------------------------------------------------------------------
function Help_About_Callback(hObject, eventdata, handles)
% hObject    handle to Help_About (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(msgbox(sprintf('WFU Results Viewer \n Part of WFU PickAtlas %s \n\n http://ansir.wfubmc.edu/ \n\n http://www.nitrc.org/projects/wfu_pickatlas/',wfu_pickatlas_version),'About','help'));

% --------------------------------------------------------------------
function Help_About_Atlas_Callback(hObject, eventdata, handles)
% hObject    handle to Help_About_Atlas (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WFU_LOG;
handles=guidata(hObject);
atlas_toolbox=fileparts(which('wfu_pickatlas'));
licensefile=fullfile(atlas_toolbox, handles.data.atlas.subdir, handles.data.atlas.licensefile);
%popupmessage(licensefile,sprintf('Licensefile for %s',handles.data.SelectedAtlasType.atlasname));
if web(['file://' licensefile]) % returns 0 if successfull
  WFU_LOG.errordlg(sprintf('Unable to launch browser to view document %s',licensefile));
end



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATE FUNCTIONS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% --- Executes during object creation, after setting all properties.
function Atlas_Group_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Atlas_Group_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Atlas_Group_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Atlas_Group_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Atlas_Group_3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Atlas_Group_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Contrast_PopUpMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Contrast_PopUpMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
% --- Executes during object creation, after setting all properties.
function ROI_PopUpMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_PopUpMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Threshold_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Threshold_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Extent_Edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Extent_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function Brain_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Brain_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function Results_Slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Results_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALLBACK FUNCTIONS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on selection change in Atlas_Group_3.
function Atlas_Group_Change_Callback(hObject, eventdata, handles, groupNum)
% hObject    handle to Atlas_Group_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Atlas_Group_3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Atlas_Group_3
global WFU_LOG;

handleString=sprintf('Atlas_Group_%d',groupNum);
handles.data.activeAtlas(groupNum)=get(handles.(handleString),'Value');
if handles.data.activeAtlas(groupNum) > size(handles.data.atlasInfo,2)
  handles.data.activeAtlas(groupNum)= 0;
end

% Update handles structure first, as mouse action might change it
guidata(hObject, handles);

if get(handles.Whole_Brain_Stats,'Value')
  handles=printResultsTable(handles,handles.data.tableData);
elseif get(handles.Single_Cluster_Stats,'Value')
  feval('wfu_results_viewer','Single_Cluster_Stats_Callback',handles.Single_Cluster_Stats,[],handles);
elseif get(handles.Whole_Brain_Labels,'Value')
  feval('wfu_results_viewer','Whole_Brain_Labels_Callback',handles.Whole_Brain_Labels,[],handles);
elseif get(handles.Single_Cluster_Labels,'Value')
  feval('wfu_results_viewer','Single_Cluster_Labels_Callback',handles.Single_Cluster_Labels,[],handles);
elseif get(handles.Single_Cluster_TimeCourse,'Value')
  feval('wfu_results_viewer','Single_Cluster_TimeCourse_Callback',handles.Single_Cluster_TimeCourse,[],handles);
else
  handles=printResultsTable(handles,handles.data.tableData);
  set(handles.Whole_Brain_Stats,'Value',1)
end

WFU_LOG.info(sprintf('Changed atlas group %d to index %d.',groupNum,handles.data.activeAtlas(groupNum)));




% --- Executes on selection change in Contrast_PopUpMenu.
function Contrast_PopUpMenu_Callback(hObject, eventdata, handles)
% hObject    handle to Contrast_PopUpMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Contrast_PopUpMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Contrast_PopUpMenu
global WFU_LOG;
handles=guidata(hObject);

if handles.data.conspec.contrasts == get(hObject,'Value'), return; end

handles.data.conspec.contrasts=get(hObject,'Value');

buttonEnableState(handles,'disable'); drawnow();
handles = wfu_results_compute(handles);
handles = updateBrain(handles);
buttonEnableState(handles,'enable'); drawnow();

% Update handles structure
guidata(hObject, handles);
WFU_LOG.info(sprintf('Changed contrast to index %d.',handles.data.conspec.contrasts));


% --- Executes on button press in ROI_PopUpMenu.
function ROI_PopUpMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_PopUpMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ROI_PopUpMenu
global WFU_LOG;
handles=guidata(hObject);

switch get(handles.ROI_PopUpMenu,'Value')
  case 1 % None
    set(handles.Show_ROI,'Visible','off');
    set(handles.ROI_PopUpMenu,'String',{'None','From PickAtlas','From File'});
    handles.data.ROI.header=struct('fname',[],'fnameOrig',[]);
    handles.data.ROI.volume=[];
    handles=wfu_results_compute(handles);
  case 2 % From PA
    paFig=wfu_findFigure('WFU_PickAtlas');
    if isempty(paFig)
      wfu_pickatlas;
      paFig=wfu_findFigure('WFU_PickAtlas');
    end
    if length(paFig)==1
      paHandles=guidata(paFig);
      if isfield(paHandles.data,'Mask')
        if isequal(handles.data.ROI.volume,paHandles.data.Mask)
          WFU_LOG.info('pickatlas mask has not changed, no update needed');
        else
          if ~isempty(handles.data.ROI.volume)
            rsp=questdlg('PickAtlas Mask has changed.  Load the new mask from the PickAtlas?');
            if ~strcmpi(rsp,'yes'), return; end;
          end
          if ~isempty(handles.data.ROI.header.fname), try delete(handles.data.ROI.header.fname); end; end;
          
          handles.data.ROI.volume=paHandles.data.Mask;
          handles.data.ROI.header.fname=handles.data.tempfiles.ROI;
          handles.data.ROI.header.fnameOrig=handles.data.ROI.header.fname;
          handles.data.ROI.header.dim=paHandles.data.iheader.dim;
          handles.data.ROI.header.dt=[2 0];
          handles.data.ROI.header.pinfo=[1;0;0];
          handles.data.ROI.header.mat=paHandles.data.iheader.mat;
          spm_write_vol(handles.data.ROI.header,handles.data.ROI.volume);
          
          handles=wfu_results_compute(handles);
          set(handles.Show_ROI,'Visible','on');
          set(handles.Show_ROI,'Value',0);
        end
      else
        WFU_LOG.warndlg(sprintf('Please define an ROI in the PickAtlas.  Do not exit.\nUpdate or re-enter threshold or extent to update statistics.'),'Information');
      end
    else
      WFU_LOG.errordlg('Too Many WFU PickAtlas windows open, please close all but one');
    end
  case 3 % From file
    roi = wfu_pickfile('image','Select an ROI image');
    if isempty(roi)
      set(handles.Show_ROI,'Visible','off');
      set(handles.ROI_PopUpMenu,'Value',1);
      set(handles.ROI_PopUpMenu,'String',{'None','From PickAtlas','From File'});
      handles.data.ROI.header=struct('fname',[],'fnameOrig',[]);
      handles.data.ROI.volume=[];
      handles=wfu_results_compute(handles);
    else
      [fp fn fe] = fileparts(roi);
      set(handles.ROI_PopUpMenu,'String',{'None','From PickAtlas',sprintf('From File: %s',[fn fe])});
      roi_un=wfu_uncompress_nifti(roi);
      handles.data.ROI.header=spm_vol(roi_un);
      handles.data.ROI.header.fnameOrig=roi;
      handles=wfu_results_compute(handles);
      set(handles.Show_ROI,'Visible','on');
      set(handles.Show_ROI,'Value',0);
    end
end

handles = updateBrain(handles);

% Update handles structure
guidata(hObject, handles);
WFU_LOG.info(sprintf('ROI Option changed to index %d.',get(handles.ROI_PopUpMenu,'Value')));




% --- Executes on button press in Correction_Method_Callback.
function Correction_Method_Callback(hObject, eventdata, handles, method)
% hObject    handle to Correction Button Clicked (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of selected button
global WFU_LOG;
handles=guidata(hObject);

if strcmpi(handles.data.conspec.threshdesc,method), return; end

set(handles.groups.correction,'Value',0);
set(hObject,'Value',1);
handles.data.conspec.threshdesc=method;

buttonEnableState(handles,'disable'); drawnow();
try
  handles = wfu_results_compute(handles);
catch ME
  WFU_LOG.errorstack(ME);
  handles.data.fused.volume=[];
  handles=createSlices(handles);
end
handles = updateBrain(handles);
buttonEnableState(handles,'enable'); drawnow();

% Update handles structure
guidata(hObject, handles);
WFU_LOG.info(sprintf('Changed correction method to %s.',method));


function Threshold_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Threshold_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Threshold_Edit as text
%        str2double(get(hObject,'String')) returns contents of Threshold_Edit as a double
global WFU_LOG;
handles=guidata(hObject);


if ~pollPickAtlasChange(handles) 
  if strcmp(num2str(handles.data.conspec.thresh),get(hObject,'String'))
    return; 
  end
end

num=str2num(get(hObject,'String'));
if isempty(num)
  WFU_LOG.warndlg(sprintf('`%s` is not a recognizable number',get(hObject,'String')),'Invalid numerical string'); 
  return; 
end
handles.data.conspec.thresh=num;

buttonEnableState(handles,'disable'); drawnow();
try
  handles = wfu_results_compute(handles);
catch ME
  try
    wfu_resultsProgress('doneNOW');
  end
  set(handles.WFU_Results_Window,'Pointer','Arrow');
  set(handles.Threshold_Status,'String','ERROR');
  set(hObject,'String',num2str(handles.data.xSPM.uum));
  WFU_LOG.infostack(ME);
  WFU_LOG.errordlg('Unable to compute xSPM at given cost/treshold');
end
handles = updateBrain(handles);
buttonEnableState(handles,'enable'); drawnow();

guidata(hObject,handles);
WFU_LOG.info(sprintf('Changed threshold to %f.',num));


function Extent_Edit_Callback(hObject, eventdata, handles)
% hObject    handle to Extent_Edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Extent_Edit as text
%        str2double(get(hObject,'String')) returns contents of Extent_Edit as a double
global WFU_LOG;
handles=guidata(hObject);

if ~pollPickAtlasChange(handles) 
  if strcmp(num2str(handles.data.conspec.extent),get(hObject,'String'))
    return; 
  end
end

num=str2num(get(hObject,'String'));
if isempty(num)
  WFU_LOG.warndlg(sprintf('`%s` is not a recognizable number',get(hObject,'String')),'Invalid numerical string'); 
  return; 
end
handles.data.conspec.extent=num;

buttonEnableState(handles,'disable'); drawnow();
handles = wfu_results_compute(handles);
handles = updateBrain(handles);
buttonEnableState(handles,'enable'); drawnow();

guidata(hObject,handles);
WFU_LOG.info(sprintf('Changed extent to %f.',num));



% --- Executes on button press in Whole_Brain_Stats.
function Whole_Brain_Stats_Callback(hObject, eventdata, handles)
% hObject    handle to Whole_Brain_Stats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Whole_Brain_Stats
global WFU_LOG;
handles=guidata(hObject);

toggleGroup(handles.groups.reports,handles.Whole_Brain_Stats);
set(handles.WFU_Results_Window,'Pointer','Watch'); drawnow;

%create new var to store table data so name can be changed
%each time without prepending the same text and having it repeat
tableData=handles.data.tableData;
if isempty(handles.data.ROI.header.fname)
  tableData.tit = sprintf('%s (whole brain mask)',tableData.tit);
else
  tableData.tit = sprintf('%s (ROI mask)',tableData.tit);
end

handles = printResultsTable(handles,tableData);
handles.data.mouse.action=[];

guidata(hObject, handles);
set(handles.WFU_Results_Window,'Pointer','Arrow'); drawnow;
WFU_LOG.info('Generate `whole brain stats` report.');


% --- Executes on button press in Single_Cluster_Stats.
function Single_Cluster_Stats_Callback(hObject, eventdata, handles)
% hObject    handle to Single_Cluster_Stats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Single_Cluster_Stats
global WFU_LOG;
handles=guidata(hObject);

toggleGroup(handles.groups.reports,handles.Single_Cluster_Stats);
set(handles.WFU_Results_Window,'Pointer','Watch'); drawnow;

[xyzmm i] = spm_XYZreg('NearestXYZ',handles.data.currPoss.MNI,handles.data.xSPM.XYZmm);

%use the template mat/dim below because we are drawing to the template, not
%the xSPM.
handles.data.currPoss=voxelImageConversion(xyzmm,handles,'MNI');
handles=updateBrain(handles,true);

set(handles.Brain_Slider,'Value',handles.data.currPoss.image(3));

handles.data.tableDataCluster = wfu_list('listcluster',handles.data.xSPM,[],[],[],[],handles.data.currPoss.MNI');
handles.data.tableDataCluster.tit = sprintf('Cluster %i: %s',handles.data.A.converted(i),handles.data.tableDataCluster.tit);

handles = printResultsTable(handles,handles.data.tableDataCluster);
handles.data.mouse.action='Single_Cluster_Stats_Callback';

guidata(hObject, handles);
set(handles.WFU_Results_Window,'Pointer','Arrow'); drawnow;
WFU_LOG.info('Generate `single cluster stats` report.');


% --- Executes on button press in Whole_Brain_Labels.
function Whole_Brain_Labels_Callback(hObject, eventdata, handles)
% hObject    handle to Whole_Brain_Labels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Whole_Brain_Labels
global WFU_LOG;
toggleGroup(handles.groups.reports,handles.Whole_Brain_Labels);
handles=guidata(hObject);
set(handles.WFU_Results_Window,'Pointer','Watch'); drawnow;

handles = clearResultsAxis(handles);

[xyzmm i] = spm_XYZreg('NearestXYZ',handles.data.currPoss.MNI,handles.data.xSPM.XYZmm);

%use the template mat/dim below because we are drawing to the template, not
%the xSPM.
handles.data.currPoss=voxelImageConversion(xyzmm,handles,'MNI');
handles=updateBrain(handles,true); %place where xyzmm is, which may have changed in spm_XYZreg

set(handles.Brain_Slider,'Value',handles.data.currPoss.image(3));

handles = clearResultsAxis(handles);

y=handles.data.page.startY;
cluster=0;

for i=1:size(handles.data.tableData.dat,1)
  %cell 3 is empty for subpeaks
  if isempty(handles.data.tableData.dat{i,3}), continue; end  
  cluster=cluster+1;
  [handles stats] = singleClusterLabelStats(handles,cluster);
  handles = printClusterLabelStats(handles, stats, cluster,y);
  y=handles.data.page.y;
end

y=handles.data.page.y;
axisSize=handles.data.axisSize;
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


handles.data.mouse.action=[];%'Whole_Brain_Labels_Callback';

guidata(hObject, handles);
set(handles.WFU_Results_Window,'Pointer','Arrow'); drawnow;
WFU_LOG.info('Generate `whole brain labels` report.');


% --- Executes on button press in Single_Cluster_Labels.
function Single_Cluster_Labels_Callback(hObject, eventdata, handles)
% hObject    handle to Single_Cluster_Labels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Single_Cluster_Labels
global WFU_LOG;
toggleGroup(handles.groups.reports,handles.Single_Cluster_Labels);
handles=guidata(hObject);
set(handles.WFU_Results_Window,'Pointer','Watch'); drawnow;

handles = clearResultsAxis(handles);

%tmp =voxelImageConversion(handles.data.currPoss.MNI,handles,'mni');
%tmp2=voxelImageConversion(tmp.voxel,handles.data.xSPM.M,handles.data.xSPM.DIM,'voxel');
%[xyzmm i] = spm_XYZreg('NearestXYZ',tmp2.MNI,handles.data.xSPM.XYZmm);
[xyzmm i] = spm_XYZreg('NearestXYZ',handles.data.currPoss.MNI,handles.data.xSPM.XYZmm);
cluster=handles.data.A.converted(i);

%use the template mat/dim below because we are drawing to the template, not
%the xSPM.
handles.data.currPoss=voxelImageConversion(xyzmm,handles,'MNI');
handles=updateBrain(handles,true); %place where xyzmm is, which may have changed in spm_XYZreg

set(handles.Brain_Slider,'Value',handles.data.currPoss.image(3));

handles = clearResultsAxis(handles);
[handles stats] = singleClusterLabelStats(handles,cluster);
handles = printClusterLabelStats(handles, stats);

y=handles.data.page.y;
axisSize=handles.data.axisSize;
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


 handles.data.mouse.action='Single_Cluster_Labels_Callback';

guidata(hObject, handles);
set(handles.WFU_Results_Window,'Pointer','Arrow'); drawnow;
WFU_LOG.info('Generate `single cluster labels` report.');


% --- Executes on button press in Single_Cluster_TimeCourse.
function Single_Cluster_TimeCourse_Callback(hObject, eventdata, handles)
% hObject    handle to Single_Cluster_TimeCourse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Single_Cluster_TimeCourse
global WFU_LOG;
toggleGroup(handles.groups.reports,handles.Single_Cluster_TimeCourse);
handles=guidata(hObject);
set(handles.WFU_Results_Window,'Pointer','Watch'); drawnow;
set(handles.Options_Paradigm,'Checked','off');

handles=timeCourse(handles);

guidata(hObject, handles);
set(handles.WFU_Results_Window,'Pointer','Arrow'); drawnow;
WFU_LOG.info('Generate `single cluster timecourse` graph.');


% --- Executes on button press in Show_ROI.
function Show_ROI_Callback(hObject, eventdata, handles)
% hObject    handle to Show_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Show_ROI
global WFU_LOG;
handles=guidata(hObject);

if get(handles.Show_ROI,'Value') == 0
  %turning off, reset display
  handles = createSlices(handles);
else
  %turning on, create temp volume
  handles = createSlices(handles);
  preExist =  isfield(handles.data,'roi_mask') && ...
              isfield(handles.data.roi_mask,'header') && ~isempty(handles.data.roi_mask.header) && ...
              isfield(handles.data.roi_mask,'volume') && ~isempty(handles.data.roi_mask.volume) && ...
              (strcmp(handles.data.roi_mask.header.fname,handles.data.ROI.header.fname) || ...
              strcmp(handles.data.roi_mask.header.fnameOrig,handles.data.ROI.header.fname));
  if ~preExist
    %reslice image, and load
    disp('reslicing mask to template space');
    P={handles.data.template.header.fname,handles.data.ROI.header.fname};
    spm_reslice(P);
    try
    	[fp fn fe fj] = fileparts(handles.data.ROI.header.fname);
    catch
    	[fp fn fe fj] = fileparts(handles.data.ROI.header.fname);
    end
    handles.data.roi_mask.header=spm_vol(fullfile(fp,['r' fn fe]));
    handles.data.roi_mask.header.fnameOrig=handles.data.ROI.header.fname;
    handles.data.roi_mask.volume=spm_read_vols(handles.data.roi_mask.header);
  end

  if size(handles.data.roi_mask.header.mat) ~= size(handles.data.template.header.mat)
    error('Mask/Template Mat Mismatch');
  end
  
  if size(handles.data.roi_mask.volume) ~= size(handles.data.template.volume)
    error('Mask/Template Size Mismatch');
  end
  
  %place mask in terms of overlay colormap
  if min(handles.data.roi_mask.volume(:)) < 0, error('Mask contains values less than 0'); end;
  activeVox=find(handles.data.roi_mask.volume);
  volume=handles.data.template.volume;
  volume(activeVox)=size(handles.data.colormaps.combined,1);
  volume=uint8(volume);
  handles = createSlices(handles,volume);
end

handles = updateBrain(handles);
% Update handles structure
guidata(hObject, handles);
WFU_LOG.info('Show ROI toggled.');


% --- Executes on slider movement.
function Brain_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to Brain_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

currentSlice=round(get(handles.Brain_Slider,'Value'));
if currentSlice < 1, currentSlice=1; end;
if currentSlice > handles.data.template.header.dim(3), currentSlice = handles.data.template.header.dim(3); end;

handles.data.currPoss.image(3) = currentSlice;
handles.data.currPoss = voxelImageConversion( handles.data.currPoss.image,handles,'image');

if strcmpi(handles.data.mouse.action,'clusterLabelCallback') || strcmpi(handles.data.mouse.action,'clusterCallback')
  updateBrain(handles,true);
else
  updateBrain(handles);
end


% --- Executes on slider movement.
function Results_Slider_Callback(hObject, eventdata, handles)
% hObject    handle to Results_Slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

lowerYLim=get(handles.Results_Slider,'Value');
set(handles.Results_Axis,'YLim',[lowerYLim lowerYLim+handles.data.axisSize(4)]);






















% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MISC FUNCTIONS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Misc functions that are SHORT.  Longer ones should be placed in the 
% private directory.

function handDownFunction(hObject, eventdata)
  handles=guidata(gcf);
  wfu_pointers(handles.WFU_Results_Window,'handdown');
  set(handles.WFU_Results_Window,'WindowButtonMotionFcn',@WFU_Results_Window_WindowButtonMotionFcn);

function screenArea = findScreenArea(handles)
% returns which area of the screen the mouse 'click' is located
  mouseLoc=get(handles.WFU_Results_Window,'CurrentPoint');
  brainPanel=get(handles.Brain_Panel,'Position');
  resultsPanel=get(handles.Results_Panel,'Position');

  screenArea=[];
  if mouseLoc(2) > brainPanel(2) & mouseLoc(2) < brainPanel(2)+brainPanel(4) & mouseLoc(1) > brainPanel(1) & mouseLoc(1) < brainPanel(1) + brainPanel(3)
  %    disp('brain');
      screenArea='brain';
  end
  if mouseLoc(2) > resultsPanel(2) & mouseLoc(2) < resultsPanel(2)+resultsPanel(4) & mouseLoc(1) > resultsPanel(1) & mouseLoc(1) < resultsPanel(1) + resultsPanel(3)
  %  disp('results');
    screenArea='results';
  end

function buttonEnableState(handles,state)
%enables or disables buttons, generally before/after a file load
  switch lower(state)
    case {'enable' 'on'}
      set(handles.groups.all,'Enable','on');
      set(handles.groups.all,'Visible','on');
      
      if exist('wfu_pickatlastype.fig','file') ~= 2
        set(handles.Options_Atlas,'Visible','off');
        set(handles.Whole_Brain_Labels,'Visible','off');
        set(handles.Single_Cluster_Labels,'Visible','off');
        set(handles.groups.atlas,'Visible','off');
        set(handles.Atlas_Group_Text,'Visible','off');
      end

      if ~isfield(handles.data,'TC') || isempty(handles.data.TC)
        set(handles.Single_Cluster_TimeCourse,'Enable','off');
      end
      if ~isfield(handles.data,'ROI') || ~isfield(handles.data.ROI,'header') || isempty(handles.data.ROI.header.fname)
        set(handles.Show_ROI,'Visible','off');
      end
      
      %don't enable buttons if Z's are empty
      if isempty(handles.data.xSPM.Z)
        set(handles.groups.reports,'Enable','off');
        set(handles.groups.reports,'Value',0);
        clearResultsAxis(handles);
      end  
    case {'disable' 'off'}
      set(handles.groups.all,'Enable','off');
    otherwise
      fprintf('unknown buttonEnableState state `%s`\n',state);
  end

function toggleGroup(groupHandles,activeButton)
  set(groupHandles,'Value',0);
  set(activeButton,'Value',1);
  
function handles = changeView(view,handles)
%changes view from radiologic to neruologic and back (along with preferences)  
  global WFU_LOG
  switch lower(view)
    case 'r'
      handles.data.preferences.flip(1) = 0;
      set(handles.Options_Neuro,'Checked','off');
      set(handles.Options_Rad,'Checked','on');
    case 'n'
      handles.data.preferences.flip(1) = 1;
      set(handles.Options_Neuro,'Checked','on');
      set(handles.Options_Rad,'Checked','off');
    case 'u'
      handles.data.preferences.flip(2) = 0;
      set(handles.Options_FlipUP,'Checked','on');
      set(handles.Options_FlipDOWN,'Checked','off');
    case 'd'
      handles.data.preferences.flip(2) = 1;
      set(handles.Options_FlipUP,'Checked','off');
      set(handles.Options_FlipDOWN,'Checked','on');
    otherwise
      WFU_LOG.error('Unknown view preference for flip');
  end
  set(handles.Brain_Left_Text,  'String',handles.data.flipText{handles.data.preferences.flip(1) + 1, 1});
  set(handles.Brain_Right_Text, 'String',handles.data.flipText{handles.data.preferences.flip(1) + 1, 2});
  handles=createSlices(handles);
  handles=updateBrain(handles,true);


function handles = changeDefaultCorrection(method,handles)
%changes default correction (on load) between fdr, fwe, and none
  set(handles.Options_Stats_Correction_None,'Checked','off');
  set(handles.Options_Stats_Correction_FWE,'Checked','off');
  set(handles.Options_Stats_Correction_FDR,'Checked','off');
  switch lower(method)
    case 'none'
      handles.data.preferences.threshdesc = 'none';
      set(handles.Options_Stats_Correction_None,'Checked','on');
    case 'fdr'
      handles.data.preferences.threshdesc = 'FDR';
      set(handles.Options_Stats_Correction_FDR,'Checked','on');
    case 'fwe'
      handles.data.preferences.threshdesc = 'FWE';
      set(handles.Options_Stats_Correction_FWE,'Checked','on');
    otherwise
      error('Unknown correction method');
  end

function bool = pollPickAtlasChange(handles)
  paHandle = wfu_findFigure('WFU_PickAtlas');
  paData=[];
  if ~isempty(paHandle) && numel(paHandle)==1
    paData=guidata(paHandle);
  end
  if ~isempty(paData) && isfield(paData.data,'Mask') && ~isequal(handles.data.ROI.volume,paData.data.Mask)
    bool = true;
  else
    bool = false;
  end

function cleanupAndExit(handles)
  global WFU_LOG;

  if isfield(handles,'data')
    %delete temp files
  	try
	    [fp fn fe fj] = fileparts(handles.data.tempfiles.results);
	  catch
	    [fp fn fe] = fileparts(handles.data.tempfiles.results);
	  end
    rResults = fullfile(fp,['r' fn fe]);
    try
	    [fp fn fe fj] = fileparts(handles.data.tempfiles.ROI);
	  catch
	    [fp fn fe] = fileparts(handles.data.tempfiles.ROI);
	  end
    rROI = fullfile(fp,['r' fn fe]);

    if exist(handles.data.tempfiles.results,'file')==2, try delete(handles.data.tempfiles.results); end; end;
    if exist(handles.data.tempfiles.ROI,'file')==2, try delete(handles.data.tempfiles.ROI); end; end;
    if exist(rResults,'file')==2, try delete(rResults); end; end;
    if exist(rROI,'file')==2, try delete(rROI); end; end;
  end

  %clean up compressed nifti's
  wfu_uncompress_nifti('cleanup');
  delete(handles.WFU_Results_Window);
  WFU_LOG.info('Exited Session.  Good-bye!');


function setup_wfu_data
  %sets up the global wfu_data for intereacting with wfu_dicomtk functions
  global wfu_data;
  if isempty(wfu_data)
    wfu_data.code_path=fileparts(which('wfu_dicomtk'));
    wfu_data.gui=[];
    wfu_dicomtk_pacs_read_table();
  end




% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ANYTHING PAST HERE IS A NEW FUNCTION.
% PLACE THESE FUNCTIONS IN THE CORRECT 
% PLACE!!!
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% --------------------------------------------------------------------
function Dicom_Callback(hObject, eventdata, handles)
% hObject    handle to Dicom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Dicom_Setup_PACS_Server_Callback(hObject, eventdata, handles)
% hObject    handle to Dicom_Setup_PACS_Server (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Dicom_Setup_PACS_Server_Add_Node_Callback(hObject, eventdata, handles)
% hObject    handle to Dicom_Setup_PACS_Server_Add_Node (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global wfu_data; %needed for wfu_dicomtk routines
  setup_wfu_data();
  wfu_dicomtk_pacs_edit_entry('add',length(wfu_data.pacs)+1);


% --------------------------------------------------------------------
function Dicom_Setup_PACS_Server_Edit_Node_Callback(hObject, eventdata, handles)
% hObject    handle to Dicom_Setup_PACS_Server_Edit_Node (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global wfu_data; %needed for wfu_dicomtk routines
  setup_wfu_data();
  idx=wfu_dicomtk_pacs_chooser('edit');
  wfu_dicomtk_pacs_edit_entry('edit',idx);


% --------------------------------------------------------------------
function Dicom_Setup_PACS_Server_Delete_Node_Callback(hObject, eventdata, handles)
% hObject    handle to Dicom_Setup_PACS_Server_Delete_Node (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global wfu_data; %needed for wfu_dicomtk routines
  setup_wfu_data();
  idx=wfu_dicomtk_pacs_chooser('delete');
  wfu_dicomtk_pacs_delete_entry(idx);


% --------------------------------------------------------------------
function Dicom_Setup_PACS_Server_Save_Nodes_Callback(hObject, eventdata, handles)
% hObject    handle to Dicom_Setup_PACS_Server_Save_Nodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  global wfu_data; %needed for wfu_dicomtk routines
  setup_wfu_data();
  wfu_dicomtk_pacs_write_table();

% --------------------------------------------------------------------
function Dicom_Select_PACS_Callback(hObject, eventdata, handles)
% hObject    handle to Dicom_Select_PACS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  global wfu_data; %needed for wfu_dicomtk routines
  setup_wfu_data();
  wfu_dicomtk_pacs_chooser('select');
  %data is stored in wfu_data.pacs(:).onoff


% --------------------------------------------------------------------
function Dicom_Send_To_PACS_Callback(hObject, eventdata, handles)
% hObject    handle to Dicom_Send_To_PACS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function Brain_Axis_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Brain_Axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%% Revision Log at end

%{
$Log: wfu_results_viewer.m,v $
Revision 1.20  2010/08/30 18:46:21  bwagner
Updates required for SPM8 rev 4010

Revision 1.19  2010/07/29 18:16:58  bwagner
Change in singleClusterLabelStats call needed fixed here.  Showing of ROI button was erratic and fixed.

Revision 1.18  2010/07/28 19:51:38  bwagner
Show ROI button not showing up when ROI active.  FIXED.

Revision 1.17  2010/07/28 19:24:57  bwagner
Poll Pickatlas for change on any event to threshold or extent

Revision 1.16  2010/07/28 17:30:50  bwagner
Mouse scroll issue in matlab 7.10 (matlab showing version when str2num applied of 7.1).  Added progress bar to results computation.

Revision 1.15  2010/07/27 18:37:35  bwagner
Using cluster number instead of xyzmm for printing singleClusterLabelStats

Revision 1.14  2010/07/27 15:36:48  bwagner
Added wfu_pickatlas_version.  PickAtlas gets version info from this script. Added Help menu (About/About Atlas) to viewer.

Revision 1.13  2010/07/22 15:42:24  bwagner
Throw error and stack if call to wfu_results_viewer fails

Revision 1.12  2010/07/22 14:32:45  bwagner
Allowed Up/Down flip.  Flip is now 2 element var with 1st being L/R and 2nd being U/D

Revision 1.11  2010/07/19 20:06:04  bwagner
WFU_LOG implementation changed.  Import no longer leaves ugly screen after fail. Assorted small fixes

Revision 1.10  2010/07/13 20:27:55  bwagner
Change to using wfu_LOG

revision 1.9  2010/07/13 13:35:35  bwagner
using wfu_LOG

revision 1.8  2010/07/09 13:37:12  bwagner
Checkin before aHeader to iHeader Pickatlas code update

revision 1.7  2009/12/21 15:07:23  bwagner
moved explode from local to wfu_ function, removing SPM override scripts

revision 1.6  2009/12/04 14:13:23  bwagner
Changed private/resultsProgress to wfu_resultsProgress in tbx_common

revision 1.5  2009/12/03 16:00:06  bwagner
TC actual/mean and paradigm showing STICK in preferences.

revision 1.4  2009/10/14 18:07:08  bwagner
Time course export to regressor file

revision 1.3  2009/10/14 16:00:16  bwagner
Updated Paradigm selection, it is not tied to contrasts

revision 1.2  2009/10/14 14:55:26  bwagner
Time Course mean centering and Paradigm Overlay

revision 1.1  2009/10/09 17:11:36  bwagner
PickAtlas Release Pre-Alpha 1
%}

