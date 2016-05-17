function varargout = wfu_timeCourseExport(varargin)
% wfu_timeCourseExport M-file for wfu_timeCourseExport.fig
%      wfu_timeCourseExport, by itself, creates a new wfu_timeCourseExport or raises the existing
%      singleton*.
%
%      H = wfu_timeCourseExport returns the handle to a new wfu_timeCourseExport or the handle to
%      the existing singleton*.
%
%      wfu_timeCourseExport('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in wfu_timeCourseExport.M with the given input arguments.
%
%      wfu_timeCourseExport('Property','Value',...) creates a new wfu_timeCourseExport or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before wfu_timeCourseExport_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to wfu_timeCourseExport_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help wfu_timeCourseExport

% Last Modified by GUIDE v2.5 14-Oct-2009 12:46:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @wfu_timeCourseExport_OpeningFcn, ...
                   'gui_OutputFcn',  @wfu_timeCourseExport_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before wfu_timeCourseExport is made visible.
function wfu_timeCourseExport_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to wfu_timeCourseExport (see VARARGIN)

% Choose default command line output for wfu_timeCourseExport
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes wfu_timeCourseExport wait for user response (see UIRESUME)
% uiwait(handles.wfu_timeCourseExport);


% --- Outputs from this function are returned to the command line.
function varargout = wfu_timeCourseExport_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in MeanCheckBox.
function MeanCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to MeanCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of MeanCheckBox


% --- Executes on button press in PeakCheckBox.
function PeakCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to PeakCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PeakCheckBox



function FileName_Callback(hObject, eventdata, handles)
% hObject    handle to FileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FileName as text
%        str2double(get(hObject,'String')) returns contents of FileName as a double


% --- Executes during object creation, after setting all properties.
function FileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ExportButton.
function ExportButton_Callback(hObject, eventdata, handles)
% hObject    handle to ExportButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

parH=wfu_findFigure('WFU_Results_Window');
if isempty(parH) || length(parH) > 1
  warndlg('Unable to retrieve Time Course Data.  Either WFU_PickAtlas Results is not open, or there is more than one open.');
  return;
end
parD=guidata(parH);
TC=parD.data.timeCourseData;
clear parH parD;

fileName=get(handles.FileName,'string');
if isempty(fileName)
  warndlg('Please enter a file name first');
  return;
end
useMean=get(handles.MeanCheckBox,'Value');
usePeak=get(handles.PeakCheckBox,'Value');

if useMean || usePeak
  fid=fopen(fileName,'w+');
  if fid < 0
    errordlg('Unable to write to file %s.',fileName);
    return;
  end
  if useMean+usePeak==1
    if useMean
      fprintf(fid,'Mean_Of_Voxels\n');
      format='%f\n';
      out=TC.data.mean;
    else
      fprintf(fid,'Peak_Voxel\n');
      format='%f\n';
      out=TC.data.peak;
    end
  else
    fprintf(fid,'Mean_Of_Voxels Peak_Voxel\n');
    format='%f %f\n';
    out=[TC.data.mean TC.data.peak];
  end
  for i=1:length(out)
    fprintf(fid,format,out(i,:));
  end
  fclose(fid);
else
  warndlg('No Time Course(s) selected. Nothing to write');
end

%delete(get(hObject,'Parent'));


% --- Executes on button press in CancelButton.
function CancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(get(hObject,'Parent'));


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over FileName.
function FileName_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to FileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if isempty(get(hObject,'string'))
  [filename, pathname] = uiputfile('timecourse.regressor','Save Time Course Regressor file as:');
else
  [filename, pathname] = uiputfile(get(hObject,'string'),'Save Time Course Regressor file as:');
end

if ~isequal(filename,0) && ~isequal(pathname,0)
  set(handles.FileName,'String',fullfile(pathname,filename));
end
