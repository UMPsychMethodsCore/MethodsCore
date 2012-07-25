function varargout = gift(varargin)
%%%%%%%%%%%%%%% Group ICA of fMRI Toolbox (GIFT) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GIFT uses Independent Component Analysis to make group inferences from fMRI data
% For more information use the help button in the toolbox

try
    % add this statement to fix the button color
    feature('JavaFigures', 0);
catch
end

icatb_delete_gui({'groupica', 'eegift', 'sbm'});

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @gift_OpeningFcn, ...
    'gui_OutputFcn',  @gift_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gift is made visible.
function gift_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gift (see VARARGIN)


group_ica_modality = 'fmri';

setappdata(0, 'group_ica_modality', group_ica_modality);

% Choose default command line output for gift
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

icatb_check_path;

% move the gui at the center of the screen
movegui(hObject, 'center');

%% Turn off finite warning
warning('off', 'MATLAB:FINITE:obsoleteFunction');


%%%%%%% Object Callbacks %%%%%%%%%%%%%%%

% --- Outputs from this function are returned to the command line.
function varargout = gift_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function groupAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Setup ICA Analysis Callback
icatb_enterParametersGUI;

function runAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Run Analysis Callback
icatb_runAnalysis;

function analysisInfo_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Analysis Info Callback
icatb_displaySesInfo;

function dispGUI_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Display GUI Callback
icatb_displayGUI;

function utilities_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% all the strings
allStrings = get(hObject, 'string');

% get the value
getValue = get(hObject, 'value');

if ~iscell(allStrings)
    % get the selected string
    selectedString = deblank(allStrings(getValue, :));
else
    % if the selected string is cell
    selectedString = allStrings{getValue};
end

% if the selected string is other than the utilities
if getValue > 1
    % call the function
    icatb_utilities(lower(selectedString));
end

function componentExplorer_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Component Explorer callback
icatb_componentExplore;

function compositeViewer_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Composite Viewer Callback
icatb_compositeViewer;

function orthogonalViewer_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Orthogonal Viewer Callback
icatb_orthoViewer;

function about_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%icatb_directions('gift-help');

% About Callback
icatb_titleDialog;

function exit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Exit Callback

icatb_exit;

function instructions_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Help Callback
icatb_openHelp;