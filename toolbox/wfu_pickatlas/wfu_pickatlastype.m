function SelectedAtlasType = wfu_pickatlastype(varargin)
global SelectedAtlasType SelectFlag
% WFU_PICKATLASTYPE Application M-file for wfu_pickatlastype.fig
%    FIG = WFU_PICKATLASTYPE launch wfu_pickatlastype GUI.
%    WFU_PICKATLASTYPE('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 21-Apr-2003 11:58:05

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);
    %Initialization GUI
    Initialize(fig, [], handles, varargin{:});
    if (SelectFlag==1)
        uiwait(fig);
    else
        %[varargout{1}] = SelectedAtlasType;
    end
    if (nargout > 0)
		%[varargout{1}] = SelectedAtlasType;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
        if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
                feval(varargin{:}); % FEVAL switchyard
        end
	catch
		disp(lasterr);
	end

end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.

% ---------------------------------------------------------------------
function varargout=Initialize(h, eventdata, handles, varargin)
% Initialize GUI
% ---------------------------------------------------------------------
global SelectedAtlasType SelectFlag
    SelectFlag=1;
    handles.AtlasType=wfu_get_atlas_type;
    if (length(handles.AtlasType)==1)
        SelectedAtlasType=handles.AtlasType;
        SelectFlag=0;
        delete (handles.figure1);    
    else
        %set(handles.figure1,'visible','on');
        set(handles.lstAtlasType, 'String', {handles.AtlasType.atlasname});
        guidata(handles.figure1,handles);
    end
    return


% --------------------------------------------------------------------
function [AtlasType] = wfu_get_atlas_type
%This program will construct the atlas type from atlas_type.txt file
    atlas_toolbox=which('wfu_pickatlas.m');
	d1 = max([find(atlas_toolbox == filesep) 0]);
	if (d1>0)
		atlas_toolbox = atlas_toolbox(1:(d1-1));
	else
			atlas_toolbox = '.';
	end
    
atlas_fname = [atlas_toolbox '/atlas_type.txt'];
fid = fopen(atlas_fname, 'rt');
AtlasType=[];
if (fid == -1)
    beep;
    h=msgbox('Cannot open atlas type file','Error','error');
    pause(3);
    return
end
    while ~feof(fid)
        tline = fgetl(fid);
        if  ~strncmp(tline,'%',1)
            [atlasname,tline]=strtok(tline,','); % region name
            [subdir,tline]=strtok(tline,','); % image name
            [lookupfile,tline]=strtok(tline,','); % subregion text file name
            [dispimage,tline]=strtok(tline,','); % offset
            a.atlasname=atlasname;
            a.subdir=subdir;
            a.lookupfile=lookupfile;
            a.dispimage=dispimage;
            AtlasType=[AtlasType a];
        end
    end
    fclose(fid); 
return


% --------------------------------------------------------------------
function varargout = lstAtlasType_Callback(h, eventdata, handles, varargin)
    global SelectedAtlasType;
    SelectedAtlasType=[];
    w=get(handles.lstAtlasType,'value');
    SelectedAtlasType=handles.AtlasType(w);
    %varargout{1}=SelectedAtlasType;
    delete (handles.figure1);
return
