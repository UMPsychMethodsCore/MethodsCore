function varargout = wfu_pickatlas(varargin)
% WFU_PICKATLAS Application M-file for wfu_pickatlas.fig
%    FIG = WFU_PICKATLAS launch wfu_pickatlas GUI.
%    WFU_PICKATLAS('callback_name', ...) invoke the named callback.
% Last Modified by GUIDE v2.5 03-Aug-2006 11:13:03
global wfu_atlas_region wfu_atlas_mask wfu_atlas_filename
warning off;

if nargin <=1  % LAUNCH GUI
    fig = openfig(mfilename,'new');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

    % Set PickAtlas title
    set(fig, 'Name', 'WFU PickAtlas Tool Version 2.5.2');
    
    % Work around possible font clipping in MATLAB7 GUI
    if strncmp(version, '7', 1) & usejava('jvm')
        uihandles = findall(fig, 'Type', 'uicontrol');
        set(uihandles, 'FontName', 'Sans Serif');
        % set(uihandles, 'FontName', 'Palatino');
        % set(uihandles, 'FontName', 'Times');
        % set(uihandles, 'FontName', 'Courier');
    end
     
	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);
    
    %Initialization GUI
    Initialize(fig, [], handles, varargin{:})
	% Wait for callbacks to run and window to be dismissed:
	uiwait(fig);

	if nargout > 0 
        % Return result Region, Mask, Filename
        varargout{1} = wfu_atlas_region;
        varargout{2} = wfu_atlas_mask;
        varargout{3} = wfu_atlas_filename;
        clear wfu_atlas_region;
        clear wfu_atlas_mask;
        clear wfu_atlas_filename;
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
%| callback type separated by '_', e.g. 'SliceSlider_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.SliceSlider. This
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
% --------------------------------------------------------------------

    global wfu_atlas_filename aheader
    global atlas_toolbox
    global vheader
    
    vheader = [];
    % Get atlas type 
    handles.SelectedAtlasType=wfu_pickatlastype;
 
    % display a progress bar to let user know that tool is loading
    tb = waitbar(0,'Please wait...WFU Pickatlas Tool is loading');
        for i=1:100,
            % computation here %
            waitbar(i/100,tb)
        end
    close(tb)
        
    if nargin<4 % get command line parameter as wfu_atlas_filename
        wfu_atlas_filename='';
    else
        wfu_atlas_filename=varargin{1};
    end
    
    atlas_toolbox=which('wfu_pickatlas.m');
    % get working path
	d1 = max([find(atlas_toolbox == filesep) 0]);
	if (d1>0)
		atlas_toolbox = atlas_toolbox(1:(d1-1));
		else
			atlas_toolbox = '.';
	end
    % Controls used in advanced mode
    handles.AdvancedControls = ...
        [handles.txtWorkF handles.cmdCommit handles.cmdDelete handles.chkSelectAll ...
         handles.lstFinalList handles.FinalMaskName handles.FinalMaskFrame ...    
         handles.txtFinal, handles.cmdUnion, handles.cmdIntersection, handles.cmdSetdiff];
 
    % Controls used in shape mode
    handles.ShapeControls= ... 
        [handles.GenerateShape handles.frameShape ...
        handles.lblShapeX handles.lblShapeY handles.lblShapeZ handles.lblmm ... % handles.lblShapeH handles.lblShapeL ...
        handles.txtShapeX handles.txtShapeY handles.txtShapeZ]; % handles.txtShapeH handles.txtShapeL];
    % Hide shape controls
    set(handles.ShapeControls, 'Enable','off');
    set(handles.ShapeControls, 'Visible','off');     

    %handles.NumberofSlices=91;
    % initial number of slices
    handles.isSimple=1;
    % initial pick atlas mode to simple mode
    Region=[];
    Atlas=[];
    
%    LookUpFileName='atlas_integer/master_lookup.txt';
    
    set(handles.txtAtlas,'string',handles.SelectedAtlasType.atlasname);
    [Atlas]=wfu_get_atlas_list(handles.SelectedAtlasType.subdir, ...
        handles.SelectedAtlasType.lookupfile, handles.SelectedAtlasType.dispimage);
    handles.Atlas=Atlas;
    % Atlas.Name
    %      .Aheader
    %      .Atlas
    %      .Offset
    %      .Region
    % Get Region and Subregion list and Atlas of Region

    
    % Atlas number for shape
    handles.Shape=length(handles.Atlas);
    % Counter for shape's sphere and square    
    %handles.ShapeSphere=0;
    handles.ShapeValue=0;
    
    handles.WorkingLevel=1;
    %handles.AtlasList=AtlasList;
    %handles.Region=Region;
    % Region is a cell array of all regions and subregions
    %     Region.RegionName
    %           .ImageName
    %           .Offset
    %           .SubregionNames
    %           .SubregionValues
                
    
    % Atlas is cell array of image files of all regions
    %      Atlas.Aheader
    %           .Atlas
    %           .Offset
    handles.CurrentAtlas=1;
    handles.CurrentRegion=1;
    % the region user currently select
    handles.WorkList=[];
    % WorkList [Region Subregion Dilate]   
    handles.WorkListString={};
    % WorkListString
    handles.SaveIndependently=0;
    % Save Independently
    handles.Flip=0;
    %------------------------------------------------
    %Set flip based on spm version
    %If using SPM99, no flip (neurologic convention)
    %If using SPM2, set flip from spm defaults
    %------------------------------------------------	
    t=which('spm');
%    if isempty(t)
%        version='SPM2';
%    else     
%        version=spm('Ver');
%    end
    %switch version
%	case 'SPM99' 
%		handles.Flip=0;
%        set(handles.togUnlockFlip,'visible','off');
%        set(handles.chkFlip,'visible','off');
%        set(handles.frameFlip,'visible','off');
%	case 'SPM2'
%        t=which('spm_flip_analyze_images');
%        if isempty(t)
%            handles.Flip=0;
%        else     
%            handles.Flip=spm_flip_analyze_images;
%        end
%    otherwise
%		handles.Flip=0;
%    end
    set(handles.chkFlip,'value',handles.Flip);
    % Get flip status from system default
    handles.MaskSide=3;
    % Mask side  1:Right  2:Left  3:Leftand Right
    handles.FlipDisplay=0;
    % -------------------------------------------
    % initialize default gui values
    % -------------------------------------------
    handles.Dilate=0;
    handles.Dilate2D=1;
    handles.firstflag=0;
    handles.ITD=0;
    handles.range=1;
    %handles.advancedFramePos = [83 46.25 45 17];
    %handles.advancedWorkListPos= [86.5 47 38.5 13.5];
    %handles.basicFramePos = [83 11.5 45 52];
    %handles.basicWorkListPos= [86.5 13.25 38.5 47.45];
    %----------------------------------------------------------
    %Save position of original Working Frame and List:
    handles.basicFramePos = get(handles.WorkRegionFrame,'Position');
    handles.basicWorkListPos = get(handles.WorkingList,'Position');
    %----------------------------------------------------------
    handles.Formula={};
    handles.display_flag=0;
    handles.CurrentWorkRegion=1;
    handles.CurrentFinal=0;
    handles.isAll=0;
    handles.AdvancedWorkList=[];
    handles.AdvancedIndex=[];
    handles.SaveIndepentendly=0;
    
    if ~isempty(handles.Atlas)
        set(handles.RegionList,'String',{handles.Atlas.Name});
    end
    %if ~isempty(Region)
    %    set(handles.RegionList, 'String', {handles.Region.RegionName});
    %    % initialize RegionList
    %    set(handles.SubregionList, 'String', handles.Region(1).SubregionNames);
    %    % initialize SubregionList
    %end
    
    %set(handles.SliceSlider,'SliderStep', ...
    %    [1/(handles.NumberofSlices-1) 5/(handles.NumberofSlices-1)]);
    % set slice slider scroll step value
    LookUpFileName=[handles.SelectedAtlasType.subdir '/' handles.SelectedAtlasType.lookupfile];
    handles.AtlasMenuString= Get_Atlas_MenuString(LookUpFileName);
    % set atlas menu string
    set(handles.Atlas1Menu, 'String', handles.AtlasMenuString);
    set(handles.Atlas1Menu, 'Value',1);
    set(handles.Atlas2Menu, 'String', handles.AtlasMenuString);
    set(handles.Atlas1Menu, 'Value',2);
    
    screenD = get(0, 'ScreenDepth');
    if screenD>=8
        grayres=256;
        handles.bt = 256;
        handles.redcolor = 131;%129; Changed 2/1/04 BAS to fix disappearing red color problem
        handles.greencolor = 130;
    else
        grayres=128;
        handles.bt= 128;
        handles.redcolor = 65;
        handles.greencolor = 66;
    end

    scolormap = gray(grayres/2);
    scolormap(end + 1 : end + grayres/2, :) = 0;
    scolormap(handles.redcolor, :)= [1.0 0.0 0.0];
    scolormap(handles.greencolor, :)= [0.0 1.0 0.0];
    set(handles.figure1,'colormap',scolormap);    
    % set color map 
    % load display image file
    [aheader, Vol] = wfu_read_analyze_header([atlas_toolbox '/' ...
            handles.SelectedAtlasType.subdir '/' handles.SelectedAtlasType.dispimage]);
%    if ~isempty(which('spm'))
%        spmversion = wfu_get_ver;
%        if strcmp(spmversion, 'SPM5')
%            vheader = spm_vol([atlas_toolbox '/' ...
%                handles.SelectedAtlasType.subdir '/' handles.SelectedAtlasType.dispimage]);
%            aheader.magnet_transform.value = vheader.mat;
%        end
%    end

    % create an image object to display the mask

%
% adjust the GUI image box for dimensions other than 91 X 109
%
    if aheader.x_dim.value ~= 91 | aheader.y_dim.value ~= 109
        imgpos = get(handles.axes1, 'Position');
%        imgpos
        ximgscale = aheader.x_dim.value/91;
        yimgscale = aheader.y_dim.value/109;
        if ximgscale <= yimgscale
            imgwidth = imgpos(3) * ximgscale/yimgscale;
            imgheight = imgpos(4);
            imgpos(1) = imgpos(1) + (imgpos(3) - imgwidth)/2
        else
            imgwidth = imgpos(3);
            imgheight = imgpos(4) * yimgscale/ximgscale;
            imgpos(2) = imgpos(2) + (imgpos(4) - imgheight)/2
        end
        imgpos(3) = imgwidth;
        imgpos(4) = imgheight;
%        imgpos
        set(handles.axes1, 'Position', imgpos);
        set(handles.axes1, 'XLim', [.5 aheader.x_dim.value+.5], ...
                           'YLim', [.5 aheader.y_dim.value+.5]);
        handles.basicFramePos = imgpos;
        handles.basicWorkListPos = imgpos;
    end

    handles.img=image('CData',[], ...
        'CDataMapping', 'scaled', ...
        'Tag','Image', ...
        'Parent', handles.axes1, ...
        'XData', [1 aheader.x_dim.value], ...
        'YData', [1 aheader.y_dim.value]);
        %'XData',[1 91], ...
        %'YData',[1 109]);
    % initial number of slices
    handles.NumberofSlices=aheader.z_dim.value;
    % set slice slider scroll step value
    set(handles.SliceSlider,'SliderStep', [ 1/(handles.NumberofSlices -1) 5/(handles.NumberofSlices -1)]);
    set(handles.SliceSlider,'Min',1);
    set(handles.SliceSlider,'Max',handles.NumberofSlices);
    set(handles.SliceSlider,'Value',handles.NumberofSlices/2);
    Vol = Vol+40;
    mx = max(max(max(Vol)));
    mn = min(min(min(Vol)))-40;
    Vol= round((Vol - mn)/(mx-mn)*(grayres/2));
    handles.Vol=Vol;
    handles.DispVolWork = Vol;
    
    handles.slice=round(get(handles.SliceSlider,'Value'));
    DispImg = handles.DispVolWork(:,:,handles.slice)';
   
    set(handles.img, 'CData', DispImg);
    guidata(handles.figure1,handles);
 
    cmdGo3_Callback([],[],handles,[]);
    

% --------------------------------------------------------------------
function varargout = togAdvanced_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    button_state = get(h,'Value');
    if button_state == get(h,'Max')
        % toggle button is pressed
        set (handles.togBasic, 'value',0);
    elseif button_state == get(h,'Min')
        % toggle button is not pressed
        set (handles.togBasic, 'value',1);
    end
    SwitchMode(handles);
    % call SwitchMode function to process mode switching

    
    
% --------------------------------------------------------------------
function varargout = togBasic_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    button_state = get(h,'Value');
    if button_state == get(h,'Max')
        % toggle button is pressed
        set (handles.togAdvanced, 'value',0);
    elseif button_state == get(h,'Min')
        % toggle button is not pressed
        set (handles.togAdvanced, 'value',1);
    end
    SwitchMode(handles);
    % call SwitchMode function to process mode switching


    
% --------------------------------------------------------------------
function varargout = tog2D_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    button_state = get(h,'Value');
    if button_state == get(h,'Max')
        % toggle button is pressed
        set (handles.tog3D, 'value',0);
    elseif button_state == get(h,'Min')
        % toggle button is not pressed
        set (handles.tog3D, 'value',1);
    end
    handles.Dilate2D=1;
    GenerateMask(handles);
    


% --------------------------------------------------------------------
function varargout = tog3D_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    button_state = get(h,'Value');
    if button_state == get(h,'Max')
        % toggle button is pressed
        set (handles.tog2D, 'value',0);
    elseif button_state == get(h,'Min')
        % toggle button is not pressed
        set (handles.tog2D, 'value',1);
    end
    handles.Dilate2D=0;
    GenerateMask(handles);    
    
    
    
% --------------------------------------------------------------------    
function SwitchMode(handles)
% switch between basic and advanced modes
% --------------------------------------------------------------------
    % Clear previous mode values
    set(handles.txtDilate, 'String', '0');
    set(handles.WorkingList, 'value', []);
    set(handles.txtWorkF, 'String', '');
    handles.AdvancedWorkList = [];
    handles.AdvWorkListString = {};
    handles.WorkList = [];
    handles.WorkListString = {};
    handles.Current_Work = [];
    handles.current_WorkList = {};
    handles.CurrentFinal=0;
    handles.finallist = [];
    handles.finallistString = {};
    handles.isSimple=get(handles.togBasic,'value');
    % get user selected mode from GUI
    switch (handles.isSimple)
    case 1 % simple mode  
        set(handles.AdvancedControls, 'Enable','off');
        set(handles.AdvancedControls, 'Visible','off');
        set(handles.WorkingList, 'position', handles.basicWorkListPos);
        set(handles.WorkRegionFrame, 'position', handles.basicFramePos);
        title = sprintf('WORKING REGION %d', handles.CurrentWorkRegion);
        set(handles.txtWorkRegionName, 'string' , title);
        set(handles.WorkingList, 'string', handles.WorkListString);
        set(handles.lstFinalList, 'string', handles.finallistString);
    case 0 % advanced mode
        set(handles.AdvancedControls, 'Enable','on');
        set(handles.AdvancedControls, 'Visible','on');
        set(handles.WorkingList, 'position', get(handles.smallWorkingList,'Position'));
        set(handles.WorkRegionFrame, 'position', get(handles.smallWorkingFrame,'Position'));
        %set(handles.WorkingList, 'position', handles.advancedWorkListPos);
        %set(handles.WorkRegionFrame, 'position', handles.advancedFramePos);
        set(handles.WorkingList, 'string', handles.AdvWorkListString);
    end 
    guidata(handles.figure1, handles);
    GenerateMask(handles);
   
    
    
% --------------------------------------------------------------------
function varargout = SliceSlider_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------    
    handles.slice=round(get(handles.SliceSlider,'Value'));
    set(handles.SliceNo,'String',handles.slice);
    
    Update(handles);


    
% --------------------------------------------------------------------
function varargout = RegionList_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------    
if strcmp(get(handles.figure1,'SelectionType'),'open')    
    x=0;
    SelectedValue = get(handles.RegionList,'Value');
    if length(SelectedValue)==1
        switch SelectedValue
        case 1
            switch handles.WorkingLevel
            case 1 %AtlasList, go to Region List
                handles.CurrentAtlas= SelectedValue;
                names={handles.Atlas(handles.CurrentAtlas).Region.RegionName};
                if (length([names])>1)
                    names=[{'..'} names];
                    set(handles.RegionList,'String', names);
                    set(handles.RegionList,'Value',[1]);   
                    handles.WorkingLevel=2;
                    set(handles.txtAtlas,'String',[handles.SelectedAtlasType.atlasname '->' ...
                        handles.Atlas(handles.CurrentAtlas).Name]);
                else
                    handles.CurrentRegion= 1;
                    names=handles.Atlas(handles.CurrentAtlas).Region(handles.CurrentRegion).SubregionNames;
                    names=[{'..'} names];
                    set(handles.RegionList,'String', names);
                    set(handles.RegionList,'Value',[1]);
                    handles.WorkingLevel=3;
                    set(handles.txtAtlas,'String',[handles.SelectedAtlasType.atlasname '->' ...
                        handles.Atlas(handles.CurrentAtlas).Name]);
                end
            case 2 %RegionList, back to Atlas List
                names={handles.Atlas.Name};
                set(handles.RegionList,'String', names);
                set(handles.RegionList,'Value',[1]);   
                handles.WorkingLevel=1;
                set(handles.txtAtlas,'String',handles.SelectedAtlasType.atlasname);
            case 3 %SubregionList, back to Region List
                names={handles.Atlas(handles.CurrentAtlas).Region.RegionName};
                if (length([names])>1)
                    names=[{'..'} names];
                    set(handles.RegionList,'String', names);
                    set(handles.RegionList,'Value',[1]);   
                    handles.WorkingLevel=2;
                    set(handles.txtAtlas,'String',[handles.SelectedAtlasType.atlasname '->' ...
                        handles.Atlas(handles.CurrentAtlas).Name]);
                else
                    names={handles.Atlas.Name};
                    set(handles.RegionList,'String', names);
                    set(handles.RegionList,'Value',[1]);   
                    handles.WorkingLevel=1;
                    set(handles.txtAtlas,'String',handles.SelectedAtlasType.atlasname);
                end
            end
        otherwise
            switch handles.WorkingLevel
            case 1 %AtlasList, go to Region List
                handles.CurrentAtlas= SelectedValue;
                names={handles.Atlas(handles.CurrentAtlas).Region.RegionName};
                if (length([names])>1)
                    names=[{'..'} names];
                    set(handles.RegionList,'String', names);
                    set(handles.RegionList,'Value',[1]);   
                    handles.WorkingLevel=2;
                    set(handles.txtAtlas,'String',[handles.SelectedAtlasType.atlasname '->' ...
                        handles.Atlas(handles.CurrentAtlas).Name]);
                else
                    handles.CurrentRegion= 1;
                    names=handles.Atlas(handles.CurrentAtlas).Region(handles.CurrentRegion).SubregionNames;
                    names=[{'..'} names];
                    set(handles.RegionList,'String', names);
                    set(handles.RegionList,'Value',[1]);
                    handles.WorkingLevel=3;
                    set(handles.txtAtlas,'String',[handles.SelectedAtlasType.atlasname '->' ...
                        handles.Atlas(handles.CurrentAtlas).Name]);
                end
            case 2 %RegionList, go to Subregion List
                handles.CurrentRegion= SelectedValue - 1;
                %names=handles.Region(handles.CurrentRegion).SubregionNames;
                names=handles.Atlas(handles.CurrentAtlas).Region(handles.CurrentRegion).SubregionNames;
                names=[{'..'} names];
                set(handles.RegionList,'String', names);
                set(handles.RegionList,'Value',[1]);
                handles.WorkingLevel=3;
                set(handles.txtAtlas,'String',[handles.SelectedAtlasType.atlasname '->' ...
                    handles.Atlas(handles.CurrentAtlas).Name '->' ...
                    handles.Atlas(handles.CurrentAtlas).Region(handles.CurrentRegion).RegionName]);
            case 3 %SubregionList, if double click, add subregion
                if strcmp(get(handles.figure1,'SelectionType'),'open')
                    % if double click, add clicked item to working list
                    x=1;
                else
                    x=0;
                end
            end
        end
    end
       
    % enable or disable MoveGroup and Add button        
    if (handles.WorkingLevel==3)
        set(handles.cmdMoveGroup,'enable','on');
        set(handles.cmdAdd,'enable','on');
        if (handles.CurrentAtlas==handles.Shape)
            set(handles.ShapeControls, 'Enable','on');
            set(handles.ShapeControls, 'Visible','on');
            if (handles.CurrentRegion==1)
                set(handles.lblShapeX,'string','R');
                set(handles.lblShapeY,'visible','off');
                set(handles.lblShapeZ,'visible','off');
                set(handles.txtShapeY,'visible','off');
                set(handles.txtShapeZ,'visible','off');
%                msgbox('Click on image or type in CUBE COORD to select the center point, type radius in R then click Generate Shape to generate a sphere shape','info','warn');
            else
                set(handles.lblShapeX,'string','X');
                set(handles.lblShapeY,'visible','on');
                set(handles.lblShapeZ,'visible','on');
                set(handles.txtShapeY,'visible','on');
                set(handles.txtShapeZ,'visible','on');
%                msgbox('Click on image or type CUBE COORD to select the center point, type X,Y,Z to specify box size then click Generate Shape to generate a box shape mask','info','warn');
            end
        else
            set(handles.ShapeControls, 'Enable','off');
            set(handles.ShapeControls, 'Visible','off');        
        end
    else    
        set(handles.cmdMoveGroup,'enable','off');
        set(handles.cmdAdd,'enable','off');
        set(handles.ShapeControls, 'Enable','off');
        set(handles.ShapeControls, 'Visible','off'); 
    end
    
            
    guidata(handles.figure1,handles);
    if (x==1)
        AddWorkList(handles,0);
    end
end
% --------------------------------------------------------------------
function varargout = SubregionList_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    if strcmp(get(handles.figure1,'SelectionType'),'open')
        % if double click, add clicked item to working list
        cmdAdd_Callback(h, eventdata, handles, varargin);
    end
        
    
    
% --------------------------------------------------------------------
function varargout = WorkingList_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    Index = get(h, 'value');
   
    if (handles.isSimple)
 	    handles.Current_Work = Index;
 	    handles.Current_WorkList = [];
        handles.Current_WorkList = [handles.Current_WorkList handles.WorkList(handles.Current_Work)];
        set(handles.txtDilate, 'enable', 'on');
        set(handles.txtDilate, 'string', num2str(handles.Dilate));
    else
        handles.AdvancedIndex = [];
        ShowIndex=[];
        LineNum = 1;
     	%get advancedindex
    	for i =1:length(handles.AdvancedWorkList)
       	    NewIndex=[LineNum : (LineNum + handles.AdvancedWorkList(i).Lines -1)];
            if(~isempty(intersect(Index, NewIndex)))
                 handles.AdvancedIndex = [handles.AdvancedIndex i];
                 ShowIndex = [ShowIndex NewIndex];
           	end
       	    LineNum = LineNum + handles.AdvancedWorkList(i).Lines;
        end
        if(length(handles.AdvancedIndex) == 1 & handles.AdvancedWorkList(handles.AdvancedIndex(1)).Lines == 1)
            set(handles.txtDilate, 'enable', 'on');
            set(handles.txtDilate, 'string', num2str(handles.AdvancedWorkList(handles.AdvancedIndex(1)).Elements(1).Dilate));
                switch (handles.AdvancedWorkList(handles.AdvancedIndex(1)).Elements(1).MaskSide);
                case 1
                    set(handles.chkLeft,'value',0);
                    set(handles.chkRight,'value',1);
                    set(handles.chkLeftRight,'value',0);
                case 2
                    set(handles.chkRight,'value',0);
                    set(handles.chkLeft,'value',1);                    
                    set(handles.chkLeftRight,'value',0);                    
                otherwise
                    set(handles.chkLeft,'value',0);
                    set(handles.chkRight,'value',0);
                    set(handles.chkLeftRight,'value',1);
                end
        else
            set(handles.txtDilate, 'enable', 'off');
            set(handles.txtDilate, 'string', '-');          
        end
        if(length(handles.AdvancedIndex) == 1)
            handles.Formula = getadvancedformula(handles.AdvancedWorkList(handles.AdvancedIndex), handles);
            set(handles.txtWorkF, 'String', handles.Formula);
        else
            handles.Formula = '----';
            set(handles.txtWorkF, 'String', handles.Formula); 
        end
  
        if(~isempty(Index))
            set(handles.lstFinalList, 'Value', []);
            handles.display_flag = 0;
	    end       
        set(handles.WorkingList, 'value', ShowIndex);          
    end
    
    guidata(handles.figure1, handles);
    GenerateMask(handles);
    

    
% --------------------------------------------------------------------
function varargout = lstFinalList_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    set(handles.WorkingList, 'Value', []);
    
    Index = get(handles.lstFinalList, 'value');
    clickType = get(handles.figure1, 'SelectionType');
    
    %get the real index
    FinalIndex = [];
    ShowIndex=[];
    LineNum = 1;
    %get Finalindex
    for i =1:length(handles.finallist)
       	NewIndex=[LineNum : (LineNum + handles.finallist(i).Lines -1)];
       	if(~isempty(intersect(Index, NewIndex)))
             FinalIndex = [FinalIndex i];
             ShowIndex = [ShowIndex NewIndex];
       	end
       	LineNum = LineNum + handles.finallist(i).Lines;
    end
    
    set(handles.lstFinalList, 'value', ShowIndex);         
    handles.display_flag = 1;
    
%    if(handles.CurrentFinal ~= FinalIndex)
        handles.CurrentFinal = FinalIndex;
        guidata(handles.figure1, handles);
        GenerateMask(handles);
%    end
    
    set(handles.txtFinal, 'String', handles.finallist(handles.CurrentFinal).Formula);
    
    if ~strcmp(clickType, 'open') 
        return;
	end

    if(isempty(FinalIndex) | length(FinalIndex) > 1)
       return; 
    end
    
    if(~isempty(handles.AdvancedWorkList) & handles.Modified == 1)
     	ButtonName=questdlg('Commit the current working region?', ...
									'WARNING', ...
                           'Yes','No','Cancel');
	  	switch ButtonName,
        	case 'Yes', 
                cmdCommit(gcbo,[],handles,guidata(gcbo));
            case 'No',
                handles.Modified = 0;
           	case 'Cancel',
         		return;
        end % switch    
    end  
    handles.AdvancedWorkList = handles.finallist(FinalIndex).AdvancedWorkList;
    handles.WorkList = handles.finallist(FinalIndex).WorkList;
    handles.WorkListString = handles.finallist(FinalIndex).WorkListString;
    handles.CurrentWorkRegion = FinalIndex;
  	
    handles.AdvancedIndex = [];
    
    guidata(handles.figure1, handles);
    
    handles.AdvWorkListString = getadvancedstring('--',handles.AdvancedWorkList, handles.WorkListString);
    set(handles.WorkingList, 'string', handles.AdvWorkListString);
    set(handles.WorkingList, 'value', handles.AdvancedIndex);
    title = sprintf('WORKING REGION %d', FinalIndex);
    set(handles.txtWorkRegionName, 'string' , title);
    set(handles.lstFinalList, 'string', handles.finallistString);
    handles.Formula = getadvancedformula(handles.AdvancedWorkList, handles);
    set(handles.txtWorkF, 'String', handles.Formula);
  
    guidata(handles.figure1, handles);
    GenerateMask(handles);

        
    
% --------------------------------------------------------------------
function varargout = cmdAdd_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    % call AddWorkList subroutine to add selected subregions to WorkList
    AddWorkList(handles,0);
    % 0 indicates add selected subregion to worklist
    
    
    
% --------------------------------------------------------------------
function varargout = cmdMoveGroup_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    % call AddWorkList subroutine to add all subregions to WorkList
    AddWorkList(handles,1);
    % 1 indicates add all subregions to worklist
    
    
    
% --------------------------------------------------------------------
function varargout = cmdRemoveSelected_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    % call RemoveWorkList subroutine to remove selected subregions from WorkList
    RemoveWorkList(handles,0);
    % 0 indicates remove selected subregion from worklist
    

    
% --------------------------------------------------------------------
function varargout = cmdRemoveAll_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    % call RemoveWorkList subroutine to remove all subregions from WorkList
    RemoveWorkList(handles,1);
    % 1 indicates remove all subregions from worklist

    
        
% --------------------------------------------------------------------
function varargout = cmdSaveMask_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------    
    [wfu_atlas_mask,wfu_atlas_filename] = SaveMask([], handles);


    
% --------------------------------------------------------------------
function varargout = cmdUnion_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    RegionOperation(handles, 'union');
    % RegionOperation function processes union and intersection

    

% --------------------------------------------------------------------
function varargout = cmdIntersection_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    RegionOperation(handles, 'intersection');
    % RegionOperation function processes union and intersection
    
% --------------------------------------------------------------------
function varargout = cmdSetdiff_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    RegionOperation(handles, 'setdiff');
    % RegionOperation function processes union and intersection


    
% --------------------------------------------------------------------
function varargout = cmdCommit_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    if(isempty(handles.AdvancedIndex) | length(handles.AdvancedIndex) > 1) 
        % nothing to commit       
        return; 
    end
    
    %remove redundant list 
    if(length(handles.AdvancedWorkList) > 1)
        ind = 1:length(handles.AdvancedWorkList);
        handles.AdvancedIndex = ind(find(ind - handles.AdvancedIndex));
        guidata(handles.figure1, handles);    
        RemoveWorkList(handles,0);
    end
     
    if(handles.CurrentWorkRegion > length(handles.finallist))
        newregion.AdvancedWorkList = handles.AdvancedWorkList(1);
        newregion.WorkListString = handles.WorkListString;
        newregion.WorkList = handles.WorkList;
        newregion.Formula = handles.Formula;
        newregion.Lines = handles.AdvancedWorkList(1).Lines+1;
        handles.finallist = [handles.finallist newregion];
       
        handles.finallistString (end+1)= {sprintf('Region %d', length(handles.finallist))};
        Strings	= getadvancedstring('   ',newregion.AdvancedWorkList, newregion.WorkListString);
        handles.finallistString(end + 1:end+length(Strings)) = Strings;
    else
        handles.finallist(handles.CurrentWorkRegion).AdvancedWorkList = handles.AdvancedWorkList(1);
        handles.finallist(handles.CurrentWorkRegion).WorkListString = handles.WorkListString;
        handles.finallist(handles.CurrentWorkRegion).WorkList = handles.WorkList;
        handles.finallist(handles.CurrentWorkRegion).Formula = handles.Formula;
        handles.finallist(handles.CurrentWorkRegion).Lines = handles.AdvancedWorkList(1).Lines+1;
        handles.finallistString = {};
        for i = 1: length(handles.finallist)
            handles.finallistString(end + 1) = {sprintf('Region %d', i)};
            Strings	= getadvancedstring('   ',handles.finallist(i).AdvancedWorkList, ...
                handles.finallist(i).WorkListString);
            handles.finallistString(end + 1:end+length(Strings)) = Strings;
        end
    end
    handles.CurrentWorkRegion = length(handles.finallist)+1;
    %get Finalindex
    ShowIndex=[];
    handles.CurrentFinal = 1;
    ShowIndex=[1 : (handles.finallist(1).Lines)];
    set(handles.lstFinalList, 'Value', ShowIndex); 
    
    handles.display_flag = 1;
          
    title = sprintf('WORKING REGION %d', handles.CurrentWorkRegion);
    set(handles.txtWorkRegionName, 'string' , title);
      
    handles.AdvancedWorkList = [];
    handles.AdvancedIndex = [];
    handles.AdvWorkListString = {};
    handles.WorkList = [];
    handles.WorkListString = {};
    set(handles.WorkingList, 'string', handles.AdvWorkListString);
    set(handles.WorkingList, 'value', handles.AdvancedIndex);
    set(handles.lstFinalList, 'String', handles.finallistString);
    set(handles.txtFinal, 'String', handles.Formula);
    set(handles.txtWorkF, 'String', '');    
    
    handles.Formula = [];
    handles.Modified = 0;
    guidata(handles.figure1, handles);
    GenerateMask(handles);

    
    

% --------------------------------------------------------------------
function varargout = cmdDelete_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    if(isempty(handles.CurrentFinal))
        return; %nothing to delete
    end
    set(handles.figure1, 'pointer', 'watch');
   
    ind = 1: length(handles.finallist);
    ind = ind(find(ind - handles.CurrentFinal));
   
    handles.finallist = handles.finallist(ind);
   
    handles.finallistString = {};
    for i = 1: length(ind)
        handles.finallistString(end + 1) = {sprintf('Region %d', i)};
        Strings	= getadvancedstring('   ',handles.finallist(i).AdvancedWorkList, ...
            handles.finallist(i).WorkListString);
        handles.finallistString(end + 1:end+length(Strings)) = Strings;
    end
    set(handles.lstFinalList, 'string',  handles.finallistString);
    set(handles.lstFinalList, 'value',  []);
    set(handles.txtFinal, 'String', []);
    
    if(handles.CurrentFinal == handles.CurrentWorkRegion)
        guidata(handles.figure1, handles);
        RemoveWorkList(handles,1);
        handles.CurrentWorkRegion = length(handles.finallist) + 1;
    else
        if handles.CurrentFinal < handles.CurrentWorkRegion
            handles.CurrentWorkRegion = handles.CurrentWorkRegion - 1;
        end    
    end
    title = sprintf('WORKING REGION %d', handles.CurrentWorkRegion);
    set(handles.txtWorkRegionName, 'string' , title);

    handles.CurrentFinal = [];
   
	%deal with the ud data and global data

	guidata(handles.figure1, handles);
	if(handles.display_flag == 1)
        GenerateMask(handles);
    end
    set(handles.figure1, 'pointer', 'arrow');
   

    
% --------------------------------------------------------------------
function varargout = cmdGo1_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    global aheader
	
	%deal with the ud data and global data
    xpos = str2num(get(handles.txtCubeX,'string'));
    ypos = str2num(get(handles.txtCubeY,'string'));
    zpos = str2num(get(handles.txtCubeZ,'string'));
   
    if(xpos >= 0 & ypos >=0 & zpos >=0 & xpos < aheader.x_dim.value ...
         & ypos < aheader.y_dim.value & zpos < aheader.z_dim.value)
        handles.selectedpoint.x = xpos;
        handles.selectedpoint.y = ypos;
        handles.selectedpoint.z = zpos;
    else
        return
    end
    
    mnicoords = aheader.magnet_transform.value*[xpos ypos zpos 1]';
    mnicoords = mnicoords(1:3)';
    talcoords = wfu_mni2tal(mnicoords);
    set(handles.txtMniX, 'string', num2str(mnicoords(1)));
    set(handles.txtMniY, 'string', num2str(mnicoords(2)));
    set(handles.txtMniZ, 'string', num2str(mnicoords(3)));
   
    set(handles.txtTalX, 'string', num2str(talcoords(1)));
    set(handles.txtTalY, 'string', num2str(talcoords(2)));
    set(handles.txtTalZ, 'string', num2str(talcoords(3)));
   
    handles.slice = zpos;
    set(handles.SliceSlider, 'value', handles.slice);
    set(handles.SliceNo, 'String', num2str(handles.slice));
 
    guidata(handles.figure1, handles);
    
    Atlas1Menu_Callback([],[],handles,[]);
    Atlas2Menu_Callback([],[],handles,[]);
   
    
    if (handles.ITD == 1)
        %point2td(handles.range);
        point2td(handles);
    else
        set(handles.txtITD,'string','*');
    end

    Update(handles);

    
    
% --------------------------------------------------------------------
function varargout = cmdGo2_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    global aheader
  	
	%deal with the ud data and global data
    xpos = str2num(get(handles.txtMniX,'string'));
    ypos = str2num(get(handles.txtMniY,'string'));
    zpos = str2num(get(handles.txtMniZ,'string'));
    
    talcoords = wfu_mni2tal([xpos ypos zpos]);
    cubecoords = inv(aheader.magnet_transform.value)*[xpos ypos zpos 1]';
    cubecoords = round(cubecoords(1:3)');
   
            
    xpos = cubecoords(1);
    if (handles.FlipDisplay)
        xpos= aheader.x_dim.value+2-xpos;
    end
    ypos = cubecoords(2);
    zpos = cubecoords(3);
       
    if(xpos >= 0 & ypos >=0 & zpos >=0 & xpos < aheader.x_dim.value ...
         & ypos < aheader.y_dim.value & zpos < aheader.z_dim.value)
        handles.selectedpoint.x = xpos;
        handles.selectedpoint.y = ypos;
        handles.selectedpoint.z = zpos;
    else
        return
    end
   
    set(handles.txtTalX, 'string', num2str(talcoords(1)));
    set(handles.txtTalY, 'string', num2str(talcoords(2)));
    set(handles.txtTalZ, 'string', num2str(talcoords(3)));
   
    if (handles.FlipDisplay)
        posx= num2str(aheader.x_dim.value+2-cubecoords(1));
    else
        posx= num2str(cubecoords(1));
    end
    set(handles.txtCubeX, 'string', posx);
    set(handles.txtCubeY, 'string', num2str(cubecoords(2)));
    set(handles.txtCubeZ, 'string', num2str(cubecoords(3))); 
   
    handles.slice = zpos;
    set(handles.SliceSlider, 'value', handles.slice);
    set(handles.SliceNo, 'String', num2str(handles.slice));

    guidata(handles.figure1, handles);

%    Atlas1Menu_Callback;
%    Atlas2Menu_Callback;
    Atlas1Menu_Callback([],[],handles,[]);
    Atlas2Menu_Callback([],[],handles,[]);   
    if (handles.ITD == 1)
        %point2td(handles.range);
        point2td(handles);
    else
        set(handles.txtITD,'string','*');    
    end
    
    Update(handles);


    
% --------------------------------------------------------------------
function varargout = cmdGo3_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    global aheader
    
    xpos = str2num(get(handles.txtTalX,'string'));
    ypos = str2num(get(handles.txtTalY,'string'));
    zpos = str2num(get(handles.txtTalZ,'string'));
%[xpos ypos zpos]
%transform  = aheader.magnet_transform.value;
%transform
   
    mnicoords = wfu_tal2mni([xpos ypos zpos]);
    cubecoords = inv(aheader.magnet_transform.value)*[mnicoords 1]';
    cubecoords = round(cubecoords(1:3)');
   
    xpos = cubecoords(1);
    if (handles.FlipDisplay)
        xpos=aheader.x_dim.value+2-xpos;
    end
    ypos = cubecoords(2);
    zpos = cubecoords(3);

%mnicoords
%cubecoords
%[xpos ypos zpos]
       
    if(xpos >= 0 & ypos >=0 & zpos >=0 & xpos < aheader.x_dim.value ...
         & ypos < aheader.y_dim.value & zpos < aheader.z_dim.value)
        handles.selectedpoint.x = xpos;
        handles.selectedpoint.y = ypos;
        handles.selectedpoint.z = zpos;
    else
        return
    end
   
    set(handles.txtMniX, 'string', num2str(mnicoords(1)));
    set(handles.txtMniY, 'string', num2str(mnicoords(2)));
    set(handles.txtMniZ, 'string', num2str(mnicoords(3)));
   
    if (handles.FlipDisplay)
        posx= num2str(aheader.x_dim.value+2-cubecoords(1));
    else
        posx= num2str(cubecoords(1));
    end
    set(handles.txtCubeX, 'string', posx);
    set(handles.txtCubeY, 'string', num2str(cubecoords(2)));
    set(handles.txtCubeZ, 'string', num2str(cubecoords(3))); 
   
    handles.slice = zpos;
    set(handles.SliceSlider, 'value', handles.slice);
    set(handles.SliceNo, 'String', num2str(handles.slice));
    
    guidata(handles.figure1, handles);
    
    if (handles.ITD== 1)
        %point2td(handles.range);
        point2td(handles);
    end
%    Atlas1Menu_Callback;
%    Atlas2Menu_Callback;
    Atlas1Menu_Callback([],[],handles,[]);
    Atlas2Menu_Callback([],[],handles,[]);
    
    	  	
    Update(handles);

    

% --------------------------------------------------------------------
function varargout = cmdDone_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    global wfu_atlas_region wfu_atlas_mask wfu_atlas_filename

    wfu_atlas_region=[];

    if handles.isSimple == 1
        wfu_atlas_region.names= {};
        wfu_atlas_region.values = [];
        wfu_atlas_region.range = 1;
        wfu_atlas_region.segments = 0;
        wfu_atlas_region.groups = {};
        wfu_atlas_region.rgb = [];
        for i = 1: length(handles.WorkList)
            R = handles.WorkList(i).Region;
            S = handles.WorkList(i).Subregion;
            wfu_atlas_region.names(end + 1) = handles.Atlas(handles.WorkList(i).Atlas).Region(R).SubregionNames(S);
            wfu_atlas_region.values = [wfu_atlas_region.values handles.Atlas(handles.WorkList(i).Atlas).Region(R).SubregionValues(S)];
            wfu_atlas_region.range = 1;
            wfu_atlas_region.segments = length(handles.WorkList);
            wfu_atlas_region.groups(end +1) = {handles.Atlas(handles.WorkList(i).Atlas).Region(R).RegionName};
        end
    else
       %make region structure under Advanced mode.
        if(handles.display_flag == 0)
            wfu_atlas_region = getadvancedregion (handles.AdvancedWorkList(handles.AdvancedIndex), handles);
        else
            if (handles.isAll)
                wfu_atlas_region = [];
                for i = 1: length(handles.finallist)
                    wfu_atlas_region = ...
                        [wfu_atlas_region getadvancedregion(handles.finallist(i).AdvancedWorkList, handles)]
                end
            else
                wfu_atlas_region = getadvancedregion(handles.finallist(handles.CurrentFinal).AdvancedWorkList,handles);
            end
        end   
    end
    if(isempty(wfu_atlas_filename) | strcmp(wfu_atlas_filename, 'filename_variable_name'))
        res = questdlg('Save the last mask?', 'Warning!');
        if strcmp(res, 'Cancel')
            wfu_atlas_region = [];
            wfu_atlas_mask = [];
            return;
        else
            if strcmp(res, 'Yes') 
                %wfu_atlas_filename = handles.defaultfilename;
                [wfu_atlas_mask,wfu_atlas_filename] = SaveMask(wfu_atlas_filename, handles);
                wfu_atlas_filename = [wfu_atlas_filename '.img'];
                delete (handles.figure1);
            else
                wfu_atlas_mask = GenerateMask(handles);
                wfu_atlas_filename = [];
                delete (handles.figure1);
    	        return;
            end
        end
    else
        [wfu_atlas_mask,wfu_atlas_filename] = SaveMask(wfu_atlas_filename, handles);
        wfu_atlas_filename = [wfu_atlas_filename '.img'];
        delete (handles.figure1);
    end
    handles.handles.output='1';
    return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --------------------------------------------------------------------
function varargout = cmdCancel_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    global wfu_atlas_filename
    wfu_atlas_filename = []; %to avoid error in spm_getSPM or equivalent
    
    if isempty(handles.WorkList) %nothing to clear
        delete (handles.figure1);
        return;
    end
    
    set(handles.figure1, 'pointer', 'watch');
     
    handles.Current_Work=[];
    handles.Current_WorkList=[];
    handles.WorkList = [];
    handles.AdvancedSorkList = [];
    handles.AdvancedIndex = [];
    handles.WorkListString = {};   
    handles.AdvWorkListString = {};   
      
    set(handles.WorkingList, 'string', handles.WorkListString);
    set(handles.WorkingList, 'value', []);
    set(handles.txtDilate, 'String', '');
    handles.DispVolWork = handles.Vol; 
    set(handles.txtWorkF, 'String', '');
    
    set(handles.figure1, 'pointer', 'arrow');  
          
    guidata(handles.figure1, handles);
   
    Update(handles);
    delete (handles.figure1);
    return;

    
    
% --------------------------------------------------------------------
function varargout = chkIndependent_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    handles.SaveIndependently =get(handles.chkIndependent, 'value');
    guidata(handles.figure1,handles);


    
% --------------------------------------------------------------------
function varargout = chkLeft_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    CheckMaskSide(handles, 2); % Right
    


% --------------------------------------------------------------------
function varargout = chkRight_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    CheckMaskSide(handles, 1); % Left

    

% --------------------------------------------------------------------
function varargout = chkLeftRight_Callback(h, eventdata, handles, varargin)

    CheckMaskSide(handles, 3); % Left and Right




% --------------------------------------------------------------------
function varargout = chkFlip_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    
    handles.Flip=get(handles.chkFlip,'value');

    
    temp=get(handles.txtDisplay,'string');
    if strcmp(temp,'Display: Neurologic')
        handles.FlipDisplay=1;
        set(handles.txtL,'string','R');
        set(handles.txtR,'string','L');
        set(handles.txtDisplay,'string','Display: Radiologic');
        %set(handles.chkLeft,'string','Right');
        %set(handles.chkRight,'string','Left');
    else
        handles.FlipDisplay=0;
        set(handles.txtL,'string','L');
        set(handles.txtR,'string','R');
        set(handles.txtDisplay,'string','Display: Neurologic');
        %set(handles.chkLeft,'string','Left');
        %set(handles.chkRight,'string','Right');
    end
    guidata(handles.figure1, handles);
    CheckMaskSide(handles,0);
% --------------------------------------------------------------------
function varargout = chkSelectAll_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    handles.isAll = get(handles.chkSelectAll, 'value');   
    guidata(handles.figure1, handles);
	GenerateMask(handles);

    

% --------------------------------------------------------------------
function varargout = chkITD_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    if handles.ITD == 0
        handles.ITD = 1;
        set(handles.RangeMenu, 'Enable', 'on');
        RangeMenu_Callback([],[],handles,[]);
    else
        handles.ITD = 0;
        set(handles.RangeMenu, 'Enable', 'off');
    end
    
    set(handles.chkITD, 'Value', handles.ITD);    
    guidata(handles.figure1, handles);    


    
% --------------------------------------------------------------------
function varargout = txtDilate_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    handles.Dilate = str2num(get(handles.txtDilate, 'string'));
    if ~(handles.isSimple)

        handles.AdvancedWorkList(handles.AdvancedIndex(1)).Elements(1).Dilate = str2num(get(handles.txtDilate, 'string'));
        s = wfu_cell2mat(handles.AdvancedWorkList(handles.AdvancedIndex(1)).Strings);      
        ind = find(strcmp(s, handles.WorkListString));
        if(length(s) > 5 & s(end-5)=='('& s(end)==')')
            s = s(1:end-6);
        end
      
        handles.WorkListString(ind) = strcat({s}, ...
        sprintf('(d%3d)',handles.AdvancedWorkList(handles.AdvancedIndex(1)).Elements(1).Dilate));
        handles.AdvancedWorkList(handles.AdvancedIndex(1)).Strings = handles.WorkListString(ind);
        guidata(handles.figure1, handles);
        handles.AdvWorkListString = getadvancedstring('--',handles.AdvancedWorkList, handles.WorkListString);   
   	    set(handles.WorkingList, 'string', handles.AdvWorkListString);
    end
   
    GenerateMask(handles);


    
% --------------------------------------------------------------------
function varargout = Atlas1Menu_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    atlas1 = get(handles.Atlas1Menu, 'Value');
    %atlasname = handles.AtlasMenuString(atlas1);
    value=handles.Atlas(atlas1).Offset;
    sel_atlas=handles.Atlas(atlas1).Atlas;
        
    x = str2num(get(handles.txtCubeX, 'String'));
    y = str2num(get(handles.txtCubeY, 'String'));
    value = value + sel_atlas(x, y, handles.slice);
    
    found = 0;
    for k=1 : length(handles.Atlas)
        for j=1 : length(handles.Atlas(k).Region)
            for i =1 : length(handles.Atlas(k).Region(j).SubregionValues)
                if ((handles.Atlas(k).Region(j).SubregionValues(i)+handles.Atlas(k).Offset) == value)
                    found =1;
                    break;
                end
            end
            if (found) 
                break;
            end
        end
        if(found)
            break;
        end
    end
    
    set(handles.txtValue1, 'String', num2str(value));
    if( found == 1)
        set(handles.txtSubregion1, 'String', deblank(handles.Atlas(k).Region(j).SubregionNames(i)));
    else
        set(handles.txtSubregion1, 'String', 'NA');
    end   



    
% --------------------------------------------------------------------
function varargout = Atlas2Menu_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    atlas2 = get(handles.Atlas2Menu, 'Value');
    %atlasname = handles.AtlasMenuString(atlas1);
    value=handles.Atlas(atlas2).Offset;
    sel_atlas=handles.Atlas(atlas2).Atlas;
        
    x = str2num(get(handles.txtCubeX, 'String'));
    y = str2num(get(handles.txtCubeY, 'String'));
    value = value + sel_atlas(x, y, handles.slice);
    
    found = 0;
    for k=1 : length(handles.Atlas)
        for j=1 : length(handles.Atlas(k).Region)
            for i =1 : length(handles.Atlas(k).Region(j).SubregionValues)
                if ((handles.Atlas(k).Region(j).SubregionValues(i)+handles.Atlas(k).Offset) == value)
                    found =1;
                    break;
                end
            end
            if (found) 
                break;
            end
        end
        if (found)
            break;
        end
    end
    
    
    set(handles.txtValue2, 'String', num2str(value));
    if( found == 1)
        set(handles.txtSubregion2, 'String', deblank(handles.Atlas(k).Region(j).SubregionNames(i)));
    else
        set(handles.txtSubregion2, 'String', 'NA');
    end   
    
    %guidata(handles.figure1, handles);

    
    
% --------------------------------------------------------------------
function varargout = RangeMenu_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    handles.range = get(handles.RangeMenu, 'value');
    guidata(handles.figure1, handles);
    point2td(handles);    
    
    
    
% --------------------------------------------------------------------
function varargout = figure1_WindowButtonMotionFcn(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
% If no display in the window, set cursor to arrow
% Set the cursor to a Cross-Hair when above the Original image, and back
% to an arrow when not.
% This is the normal motion function for the window when we are not in
% a MyGetline selection state.

    global aheader

    pos = get(handles.axes1, 'Position');
    pt = get(handles.figure1, 'CurrentPoint');
	x = pt(1,1);
	y = pt(1,2);

	if (x>=pos(1) & x<=pos(1)+pos(3) & y>=pos(2) & y<=pos(2)+pos(4))
        set(handles.figure1, 'Pointer', 'cross');
        pt = get(handles.axes1,'CurrentPoint');
		x = round(pt(1,1) - 0.5);
        if (handles.FlipDisplay)
            x=aheader.x_dim.value+2-x;
        end
        y = round(pt(1,2) - 0.5);
        postxt = sprintf('(%3d,%3d)',x,y);
        set(handles.txtPosition, 'visible', 'on');
        set(handles.txtPosition, 'string', postxt);
    else
        set(handles.txtPosition, 'visible', 'off');
   	    set(handles.figure1, 'Pointer', 'arrow');
    end
   

    
% --------------------------------------------------------------------
function varargout = figure1_WindowButtonDownFcn(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    global aheader
	
    pos = get(handles.axes1, 'Position');
    pt = get(handles.figure1, 'CurrentPoint');
	x = pt(1,1);
	y = pt(1,2);

	if (x>=pos(1) & x<=pos(1)+pos(3)-1 & y>=pos(2) & y<=pos(2)+pos(4))
        if (~strcmp(get(handles.figure1, 'SelectionType'), 'normal'))
            %clear the point
            handles.selectedpoint.x = [];
            handles.selectedpoint.y = [];
            handles.selectedpoint.z = []; 
            set(handles.txtMniX, 'string', []);
            set(handles.txtMniY, 'string', []);
            set(handles.txtMniZ, 'string', []);
   
            set(handles.txtTalX, 'string', []);
            set(handles.txtTalY, 'string', []);
            set(handles.txtTalZ, 'string', []);
       	    set(handles.txtValue1, 'String', []);
            set(handles.txtSubregion1, 'String', []);
            set(handles.txtValue2, 'String', []);
            set(handles.txtSubregion2, 'String', []);
    	else	
        	pt = get(handles.axes1, 'CurrentPoint');
            x = round(pt(1,1)-0.5);
            if (handles.FlipDisplay)
                x=aheader.x_dim.value+2-x;
            end
            y = round(pt(1,2)-0.5);
            handles.selectedpoint.x = x;
   	        handles.selectedpoint.y = y;
            handles.selectedpoint.z = handles.slice;
        end
        set(handles.txtCubeX, 'string', num2str(handles.selectedpoint.x));
        set(handles.txtCubeY, 'string', num2str(handles.selectedpoint.y));
        set(handles.txtCubeZ, 'string', num2str(handles.selectedpoint.z));
     
	    %deal with the ud data and global data
        guidata(handles.figure1, handles);
        cmdGo1_Callback([],[],handles,[]);
        Atlas1Menu_Callback([],[],handles,[]);
        Atlas2Menu_Callback([],[],handles,[]);
        Update(handles);
    end


    
% --------------------------------------------------------------------
function varargout = figure1_DeleteFcn(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
    global aheader
    
	clear aheader
    
    
    
% --------------------------------------------------------------------
function AddWorkList( handles,bAll )
% Add selected subregions or all subregions to WorkList
% Usage: AddWorkList(handles,bAll)
% bAll: 0 for adding selected subregions, 1 for adding all subregions
% --------------------------------------------------------------------

    if bAll
        %index=1:length(handles.Subregions(handles.CurrentRegion).names);
        index=1:length(handles.Atlas(handles.CurrentAtlas).Region(handles.CurrentRegion).SubregionNames);
    else
        index=get(handles.RegionList,'value')-1;
        if (index==0)
            return;
        end
    end
    
    if isempty(index)
        return;
    else
        if (index(1)==0)
            index=index(2:end);
        end
    end

    
    set(handles.figure1,'Pointer','Watch');
    
    for i = 1: length(index)
        found = 0;
        for j = 1: length(handles.WorkList)
            if handles.CurrentAtlas==handles.WorkList(j).Atlas & ...
                    handles.CurrentRegion == handles.WorkList(j).Region & ...
                    index(i) == handles.WorkList(j).Subregion;
                found = 1;
            end
        end
        if (found == 0)
            new.Atlas = handles.CurrentAtlas;
            new.Region = handles.CurrentRegion;
            new.Subregion = index(i);
            new.Dilate = 0;
            new.MaskSide=handles.MaskSide;
            %new.SubregionName = handles.Region(new.Region).SubregionNames(new.Subregion);
            handles.WorkList = [handles.WorkList new];
            handles.WorkListString( end + 1) = handles.Atlas(handles.CurrentAtlas).Region(new.Region).SubregionNames(new.Subregion);
            if(~handles.isSimple)
                a.Atlas=handles.CurrentAtlas;
                a.Operator=[];
                a.Elements=new;
                a.Lines=1;
                a.Strings=handles.WorkListString(end);
                handles.AdvancedWorkList=[handles.AdvancedWorkList a];
                handles.display_flag=0;
            end
        end   
    end
%    guidata(handles.figure1,handles);          
    if (handles.isSimple)
        set(handles.WorkingList, 'string', handles.WorkListString);
        %et(handles.WorkingList, 'Value',length(handles.WorkListString));
    else
        handles.AdvWorkListString = getadvancedstring('--',handles.AdvancedWorkList,handles.WorkListString);
        set(handles.WorkingList, 'string', handles.AdvWorkListString);
        %set(handles.WorkingList, 'Value',length(handles.AdvWorkListString));
    end      
    guidata(handles.figure1,handles);   
    GenerateMask(handles);
    set(handles.figure1, 'pointer', 'arrow');
    
    
   
% --------------------------------------------------------------------   
function RemoveWorkList(handles, bAll)
% Remove selected subregions or all subregions from WorkList
% Usage: RemoveWorkList(handles,bAll)
% bAll: 0 for removing selected subregions, 1 for removing all subregions
% --------------------------------------------------------------------
    set(handles.figure1,'pointer','watch');
    if bAll
        if isempty(handles.WorkList)
            set(handles.figure1,'pointer','arrow');
            return;
        end
        handles.WorkList=[];
        handles.WorkListString={};
        handles.AdvancedWorkList=[];
    else
        index=get(handles.WorkingList,'value');
        if isempty(index)
            set(handles.figure1,'pointer','arrow');
            return;
        end
        if(handles.isSimple)
            ind=1:length(handles.WorkList);
            % remove selected item from WorkingList
            for i=1:length(index);
                ind=ind(find(ind-index(i)));
            end
            handles.WorkList=handles.WorkList(ind);
            handles.WorkListString=handles.WorkListString(ind);
        else
            ind=1: length(handles.AdvancedWorkList);
            for i=1: length(handles.AdvancedIndex)
                ind=ind(find(ind - handles.AdvancedIndex(i)));
            end
            WorkingInd=[];
            for i=ind
                for j=1: length(handles.AdvancedWorkList(i).Strings)
                    WorkingInd=[WorkingInd find(strcmp(handles.AdvancedWorkList(i).Strings(j),handles.WorkListString))];
                end
            end
            %Update WorkingList
            handles.WorkList=handles.WorkList(WorkingInd);
            handles.WorkListString=handles.WorkListString(WorkingInd);
            guidata(handles.figure1, handles);
            
            handles.AdvancedWorkList=handles.AdvancedWorkList(ind);
            handles.AdvWorkListString=getadvancedstring('--', handles.AdvancedWorkList, handles.WorkListString);
            set(handles.WorkingList, 'string', handles.AdvWorkListString);
               
            if(length(handles.AdvancedWorkList) == 0)
    			handles.AdvancedIndex = [];
   	        	set(handles.WorkingList, 'value', []); 
   
           		handles.Formula = '';
           		set(handles.txtWorkF, 'String', handles.Formula);    
            else      
    			handles.AdvancedIndex = 1;
   	        	set(handles.WorkingList, 'value', [1: handles.AdvancedWorkList(1).Lines]); 
   
           		handles.Formula = getadvancedformula(handles.AdvancedWorkList(1), handles);
           		set(handles.txtWorkF, 'String', handles.Formula);
            end   
        end         
    end
    
    guidata(handles.figure1,handles);
    GenerateMask(handles);
    set(handles.WorkingList,'string',handles.WorkListString);
    set(handles.WorkingList,'value',[]);
    set(handles.figure1,'pointer','arrow');
    


% --------------------------------------------------------------------
function CheckMaskSide(handles, nSide)
% --------------------------------------------------------------------
% Get mask side from gui then update display to coordinate
    temp=0;

    switch nSide
    case 1 % Right
        set(handles.chkRight,'value',1);
        set(handles.chkLeft,'value',0);
        set(handles.chkLeftRight,'value',0);
        temp=1;
    case 2 % Left
        set(handles.chkLeft,'value',1);
        set(handles.chkRight,'value',0);
        set(handles.chkLeftRight,'value',0);
        temp=2;
    case 3 % Left & Right
        set(handles.chkLeftRight,'value',1);
        set(handles.chkRight,'value',0);
        set(handles.chkLeft,'value',0);
        temp=3;
    otherwise % side doesn't change
        if(get(handles.chkRight,'value'))
            temp=1;
        end
        if(get(handles.chkLeft,'value'))
            temp=2;
        end
        if(get(handles.chkLeftRight,'value'))
            temp=3;
        end
    end

    if (temp==0) 
        temp=3;
    end
    handles.MaskSide=temp;
    if (~handles.isSimple)
        if(length(handles.AdvancedIndex) == 1 & handles.AdvancedWorkList(handles.AdvancedIndex(1)).Lines == 1)
%        item = get(handles.WorkingList,'value');
%        if ~isempty(item)
%            if (length(item)==1)
                handles.AdvancedWorkList(handles.AdvancedIndex(1)).Elements(1).MaskSide=temp;
         else
                msgbox('Cannot change mask side on this region!','Warning','warn');
        end
        %       end
    end
    guidata(handles.figure1,handles);
    GenerateMask(handles);
    
    

% --------------------------------------------------------------------
function [AtlasMenu]= Get_Atlas_MenuString(LookUpFileName)
% --------------------------------------------------------------------
    global atlas_toolbox

    atlas_fname = LookUpFileName;
    fid = fopen([atlas_toolbox '/' atlas_fname], 'rt');
    AtlasMenu=[];
    if (fid ~= -1)
        while feof(fid) == 0
            tline = fgetl(fid);
            if ~strncmp(tline,'%',1)
                [R,tline]=strtok(tline,',');
                [I,tline]=strtok(tline,',');
                [T,tline]=strtok(tline,',');
                [J,tline]=strtok(tline,',');
                O=str2num(J);
                %fprintf('\nR:%s I:%s T:%s O:%d\n',R,I,T,O);
                if ~isempty(AtlasMenu)
                    R=sprintf('|%s',R);
                end
                AtlasMenu=[AtlasMenu R];
            end
        end
        fclose(fid); 
    end
    return

    
    
%---------------------------------------------------------------------
function advstring = getadvancedstring(prefix, AdvancedWorkList, WorkListString)   
% recursive algorithm to get strings in advancedworklist
% --------------------------------------------------------------------
    advstring = {};
    for i = 1: length(AdvancedWorkList)
        ind = find(strcmp(AdvancedWorkList(i).Strings(1), WorkListString));
        if(length(AdvancedWorkList(i).Strings) ==1)
       	    firststr = sprintf('%d.', ind(1));          
        else   
       	    firststr = sprintf('%s%d.', prefix, ind(1));
        end
        firststr = strcat(firststr,wfu_cell2mat(AdvancedWorkList(i).Strings(1)));%
		advstring(end+1) = {firststr};     
        for j = 2 : length(AdvancedWorkList(i).Strings)
            ind = find(strcmp(AdvancedWorkList(i).Strings(j), WorkListString));
            str = sprintf('%s%d.%s', blanks(length(prefix)),ind(1),  ...
                wfu_cell2mat(AdvancedWorkList(i).Strings(j)));    
            advstring(end+1) = {str};     
        end
    end      
    return;

        

%---------------------------------------------------------------------
function advlist =getadvancedlist(AdvancedWorkList,handles)
% recursive algorithm to get advancedworklist
% --------------------------------------------------------------------    
    global aheader
	advlist = [];
    temp=[];
    
    if(isempty(AdvancedWorkList.Operator))
        A = AdvancedWorkList.Atlas;
        R = AdvancedWorkList.Elements(1).Region;
      	SubR = AdvancedWorkList.Elements(1).Subregion;
        
      	the_value = handles.Atlas(A).Region(R).SubregionValues(SubR);
        %Offset=handles.Region(R).Offset;
        Offset=handles.Atlas(A).Offset;
        MaskSide=AdvancedWorkList.Elements(1).MaskSide;
        temp=findindex(handles,the_value, AdvancedWorkList.Elements(1).Dilate, ...
            Offset,MaskSide);
        advlist =[advlist ; temp];
       	return;
    end
	advlist = getadvancedlist(AdvancedWorkList.Elements(1),handles);
    for i =2 :length(AdvancedWorkList.Elements)
        if(strcmp(AdvancedWorkList.Operator, 'union'))
            advlist = union(advlist, getadvancedlist(AdvancedWorkList.Elements(i),handles));
        end
        if(strcmp(AdvancedWorkList.Operator, 'intersection'))
            advlist = intersect(advlist, getadvancedlist(AdvancedWorkList.Elements(i),handles));
        end
 	if(strcmp(AdvancedWorkList.Operator, 'setdiff'))
            advlist = setdiff(advlist, getadvancedlist(AdvancedWorkList.Elements(i),handles));
        end

    end
    
    
    
% --------------------------------------------------------------------
function formula = getadvancedformula(AdvancedWorkList,handles)
% recursive algorithm to get formula
% --------------------------------------------------------------------
    formula = [];
    if(isempty(AdvancedWorkList.Operator))
        ind = find(strcmp(AdvancedWorkList.Strings, handles.WorkListString));
   		formula = sprintf('%d',ind);
       	return;
    end
    formula = sprintf('(%s',getadvancedformula(AdvancedWorkList.Elements(1),handles));
    for i =2 :length(AdvancedWorkList.Elements)
        if(strcmp(AdvancedWorkList.Operator, 'union'))
            formula = strcat(formula, '+');
            formula = strcat(formula, getadvancedformula(AdvancedWorkList.Elements(i),handles));
        end
        if(strcmp(AdvancedWorkList.Operator, 'intersection'))
            formula = strcat(formula, '*');
            formula = strcat(formula, getadvancedformula(AdvancedWorkList.Elements(i),handles));
        end
 	if(strcmp(AdvancedWorkList.Operator, 'setdiff'))
            formula = strcat(formula, '-');
            formula = strcat(formula, getadvancedformula(AdvancedWorkList.Elements(i),handles));
        end

    end
         formula = strcat(formula, ')');

         
         
% --------------------------------------------------------------------
% recursive algorithm to get advancedworklist
function region =getadvancedregion(AdvancedWorkList, handles)
% --------------------------------------------------------------------
    region.names= {};
    region.values = [];
    region.range = 1;
    region.segments = 0;
    region.groups = {};
    region.rgb = [];
    if(isempty(AdvancedWorkList.Operator))
        A = AdvancedWorkList.Atlas;
        R = AdvancedWorkList.Elements(1).Region;
      	SubR = AdvancedWorkList.Elements(1).Subregion;
      	the_value = handles.Atlas(A).Region(R).SubregionValues(SubR);
        region.names(end + 1) = handles.Atlas(A).Region(R).SubregionNames(SubR); %ud.sub_regions(g).names(s);
        region.values = [region.values the_value];
        region.range = 1;
        region.segments = region.segments+1;
        region.groups(end +1) = {handles.Atlas(A).Region(R).RegionName};
        return;
    end
    for i =1 :length(AdvancedWorkList.Elements)
        thisregion = getadvancedregion(AdvancedWorkList.Elements(i),handles);
        region.names(end + 1: end + length(thisregion.names)) = thisregion.names;
        region.values =[region.values thisregion.values];
        region.range = 1;
        region.segments = region.segments+thisregion.segments;
        region.groups(end + 1: end + length(thisregion.groups)) = thisregion.groups;
    end
         
    
    
% --------------------------------------------------------------------
function RegionOperation(handles, Operator)         
% --------------------------------------------------------------------
    if(length(handles.AdvancedIndex) <= 1) 
       return;
    end
    a.Atlas=handles.AdvancedWorkList(handles.AdvancedIndex(1)).Atlas;
    a.Operator = Operator;% union, intersection, or setdiff
    a.Elements = [handles.AdvancedWorkList(handles.AdvancedIndex)];
    a.Lines = 0;
    a.Strings = {};
    for i = 1: length(handles.AdvancedIndex)
        a.Strings(end+1:end+ length(handles.AdvancedWorkList(handles.AdvancedIndex(i)).Strings))= ...
          handles.AdvancedWorkList(handles.AdvancedIndex(i)).Strings;
        a.Lines = a.Lines + handles.AdvancedWorkList(handles.AdvancedIndex(i)).Lines;
    end
      
    %------------------------------------------------------------------------------
    %remove selected AdvancedIndex from the advancedlist
    %------------------------------------------------------------------------------
    ind = 1: length(handles.AdvancedWorkList);
    for i = 1: length(handles.AdvancedIndex)
        ind = ind(find(ind - handles.AdvancedIndex(i)));
    end
    %if ~isempty(ind)
    handles.AdvancedWorkList = [a handles.AdvancedWorkList(ind)];
    %else
    %handles.AdvancedWorkList = [a];
    %end
    handles.AdvWorkListString = getadvancedstring('--',  handles.AdvancedWorkList, handles.WorkListString);

    set(handles.WorkingList, 'string',handles.AdvWorkListString);
	handles.AdvancedIndex = 1;
    set(handles.WorkingList, 'value', [1: handles.AdvancedWorkList(1).Lines]); 
   
    handles.Formula = getadvancedformula(handles.AdvancedWorkList(1), handles);
    set(handles.txtWorkF, 'String', handles.Formula);
   
    handles.Modified = 1;
    
    guidata(handles.figure1, handles);
    GenerateMask(handles);         
   
       
   
% --------------------------------------------------------------------
function [mask, outfilename] = SaveMask(filename, handles)
% --------------------------------------------------------------------
    global aheader atlas_toolbox
    global vheader

  template=fullfile(atlas_toolbox,...
	 handles.SelectedAtlasType.subdir,...
	handles.SelectedAtlasType.dispimage);
   mat = wfu_get_space(template);
   if handles.Flip, mat = diag([-1 1 1 1])*mat; end;
   M = mat;
    mask = GenerateMask(handles);
    if ~exist('filename') filename=[]; end
    if isempty(filename)	
%       [outfilename path] = uiputfile('./mask/*.*', 'Save analyze file as');
        [outfilename path] = uiputfile('', 'Save analyze file as');

        outfilename=[path,outfilename];
        if (outfilename == 0) & (path ==0)
       	    return;
     	end
    else
        outfilename = filename;
    end
    if isempty(vheader)
        wfu_write_analyze_header(uint8(mask), aheader, outfilename,mat,M);
    else
        [pathstr,name,ext,versn] = fileparts(outfilename);
	if isempty(ext) || strcmp(ext, '.hdr')
	    ext = '.img';
        end
	vheader.fname = fullfile(pathstr, [name ext]);
        vheader.mat = mat;
        spm_write_vol(vheader, uint8(mask));
    end
    Update(handles);
    
   
   
% --------------------------------------------------------------------
function st = point2td(handles)
% function to call Point2TD
% --------------------------------------------------------------------
    global atlas_toolbox

    set(handles.figure1, 'pointer', 'watch');

    x = str2num(get(handles.txtTalX, 'String'));
    x = round(x);
    x = num2str(x);
    x = strcat(x, ','); 
    
    y = str2num(get(handles.txtTalY, 'String'));
    y = round(y);
    y = num2str(y);
    y = strcat(y, ','); 
    
    z = str2num(get(handles.txtTalZ, 'String'));
    z = round(z);
    z = num2str(z); 
    
%    cmd = [atlas_toolbox '/PointtoTD'];
    cmd = ['java -classpath ' atlas_toolbox '/talairach.jar org.brainmap.talairach.PointToTD '];
    if handles.range == 1
        cmd = strcat(cmd, ' 2,');
    else
        cmd = strcat(cmd, ' 3:');
        %cmd = strcat(cmd, num2str(2*get(handles.RangeMenu, 'value')-1));
        cmd=strcat(cmd, num2str((handles.range-1)*2+1));
        cmd = strcat(cmd, ',');
    end
    cmd = strcat(cmd, [x y z]);
    
    disp('=================')
    disp(cmd);
    
    [s, w] = unix(cmd); % strange Matlab, it execute the former sys cmd 
    [s, w] = unix(cmd);
    disp(w);
    
    if(strncmp('ERROR', w, 5)) 
        set(handles.txtITD, 'String', 'unix command error');
    end
   
    if(handles.range == 1)
        ind = findstr(w, 'Returned:');
        w1 = w(ind:end);
        ind = findstr(w1, ',');
        if(isempty(ind))
            finalstr = '*';
        else 
            finalstr = w1(ind(end)+1:end);
       end 
   else
        dbstr = double(w);
        ind = find(~(dbstr - 10));
        if(ind(end) ~= length(w))
            ind(end+1) = length(w)+1; % if the last character is not \n
        end  
        from = 1;
        start = 0;
        strings = [];
        for i = 1: length(ind)
            if start == 0
                if(~isempty(findstr(char(dbstr(from : ind(i)-1)), 'Returned:')))
                    start = 1;
                end
                from = ind(i)+1;
            else
                str = char(dbstr(from : ind(i)-1));
                index = findstr(str, ',');
                if(isempty(index))
                    str = '*';
                else
                    str = str(index(end)+1: end);
                end
                found = 0;
                for j = 1: length(strings)
                    if(strcmp(strings(j).string, str))
                        found = 1;
                        strings(j).number = strings(j).number +1;
                    end
                end
                if found == 0 
                    strings(end+1).string = str;
                    strings(end).number = 1;
                end
                from = ind(i)+1;
            end
        end
        maxnumber = 0;
        if(length(strings) == 1)
            finalstr = strings(1).string;
        else   
          	for i = 1: length(strings)
                if(isempty(findstr(strings(i).string, '*')) & strings(i).number > maxnumber )
                    maxnumber = strings(i).number;
                    finalstr = strings(i).string;
                end
            end
        end
    end
    set(handles.txtITD, 'String', finalstr);
    set(handles.figure1, 'pointer', 'arrow');
    %guidata(handles.figure1, handles); 


% --------------------------------------------------------------------
function OutMask=GenerateMask(handles)
% --------------------------------------------------------------------   
    global aheader
    
    set(handles.figure1,'pointer','watch');
    temp=[];
    if nargout>0 & handles.SaveIndependently==1
        IndependentMask=zeros(size(handles.Vol));
        MaskValue=1;
    end
    
    if (handles.isSimple)
        index=1:length(handles.WorkList);
        for i=index
            A=handles.WorkList(i).Atlas;
            R=handles.WorkList(i).Region;
            SubR=handles.WorkList(i).Subregion;
            TheValue=handles.Atlas(A).Region(R).SubregionValues(SubR);
            Offset=handles.Atlas(A).Region(R).Offset;
            MaskSide=handles.MaskSide;
            List=findindex(handles, TheValue, handles.Dilate, Offset,MaskSide);
            temp=[temp ; List];
            if nargout>0 & handles.SaveIndependently==1
                IndependentMask(List)=MaskValue;
                MaskValue=MaskValue+1;
            end
        end
    else
        if(handles.display_flag==0)
            if(~isempty(handles.AdvancedWorkList) & ~isempty(handles.AdvancedIndex))
                temp=getadvancedlist(handles.AdvancedWorkList(handles.AdvancedIndex(1)),handles);
                
            end
        else
            if(handles.isAll)
                for i=1:length(handles.finallist)
                    list=getadvancedlist(handles.finallist(i).AdvancedWorkList, handles);
                    temp=union(temp, list);
                    if (nargout>0 & handles.SaveIndepentendly==1)
                        independentmask(list)=maskvalue;
                        maskvalue=maskvalue+1;
                    end
                end
            else
                %if(~isempty(handles.CurrentFinal))
                if(handles.CurrentFinal>0)
                    temp=getadvancedlist(handles.finallist(handles.CurrentFinal).AdvancedWorkList, handles);
                    if (nargout>0 & handles.SaveIndepentendly==1)
                        independentmask(list)=maskvalue;
                        maskvalue=maskvalue+1;
                    end
                end
            end
        end
    end
        
    Mask=zeros(size(handles.Vol));
    Mask(temp)=1;
    
    if nargout > 0 & handles.SaveIndependently == 1
 	if (handles.Flip)
            OutMask=flipdim(IndependentMask,1);
        else
            OutMask = IndependentMask;
        end
    end
    if nargout > 0 & handles.SaveIndependently == 0
      %OutMask = Mask;
        if (handles.Flip)
            OutMask=flipdim(Mask,1);
        else
            OutMask=Mask;
        end
    end
      
    handles.DispVolWork = handles.Vol;
    
    handles.DispVolWork(temp) = handles.redcolor;
    if (handles.FlipDisplay)
        handles.DispVolWork=flipdim(handles.DispVolWork,1);
    end
    guidata(handles.figure1,handles);

    Update(handles);
    set(handles.figure1, 'pointer', 'arrow');
       
% --------------------------------------------------------------------
function Update( handles)
% Update, (it is not corresponding to any control component, however, most
%	control components need to call this function to update display)
% --------------------------------------------------------------------
    global aheader
    
    if (handles.firstflag == 0) 
        cubecoords = inv(aheader.magnet_transform.value)*[0 0 0 1]';
        talcoords = wfu_mni2tal([0 0 0]);
  
        set(handles.txtTalX, 'string', num2str(talcoords(1)));
        set(handles.txtTalY, 'string', num2str(talcoords(2)));
        set(handles.txtTalZ, 'string', num2str(talcoords(3)));
  
        set(handles.txtCubeX, 'string', num2str(cubecoords(1)));
        set(handles.txtCubeY, 'string', num2str(cubecoords(2)));
        set(handles.txtCubeZ, 'string', num2str(cubecoords(3))); 
  
        set(handles.SliceNo, 'String', num2str(cubecoords(3)));
        set(handles.SliceSlider, 'Value', cubecoords(3));
        handles.slice = cubecoords(3);
        
        handles.selectedpoint.x = cubecoords(1);
        handles.selectedpoint.y = cubecoords(2);
        handles.selectedpoint.z = cubecoords(3);
       
        guidata(handles.figure1, handles);

        Atlas1Menu_Callback([],[],handles,[]);
		Atlas2Menu_Callback([],[],handles,[]);
        handles.firstflag = 1;
        %set(handles.figure1, 'Visible',1);    
    end

    handles.DispImg = handles.DispVolWork(:,:,handles.slice)';
   
    if(handles.selectedpoint.z == handles.slice)
        posy=handles.selectedpoint.y;
        if (handles.FlipDisplay)
            posx=aheader.x_dim.value+2- handles.selectedpoint.x;
        else
            posx= handles.selectedpoint.x;
        end
        handles.DispImg(posy,posx) = handles.greencolor;
    end
    set(handles.img, 'CData', handles.DispImg)   
    guidata(handles.figure1,handles);
    
    
% --------------------------------------------------------------------
function varargout = togUnlockFlip_Callback(h, eventdata, handles, varargin)
    if get(h,'value')
        set(handles.chkFlip,'enable','off');
    else
        set(handles.chkFlip,'enable','on');
    end



% --------------------------------------------------------------------
function varargout = GenerateShape_Callback(h, eventdata, handles, varargin)

X = str2num(get(handles.txtCubeX,'string'));
Y = str2num(get(handles.txtCubeY,'string'));
Z = str2num(get(handles.txtCubeZ,'string'));

% sX, sY, sZ is shape's size in mm
szX = get(handles.txtShapeX,'string');
sX = str2num(szX)/(handles.Atlas(handles.Shape).Aheader.x_size.value);
szY = get(handles.txtShapeY,'string');
sY = str2num(szY)/(handles.Atlas(handles.Shape).Aheader.y_size.value);
szZ=get(handles.txtShapeZ,'string');
sZ = str2num(szZ)/(handles.Atlas(handles.Shape).Aheader.z_size.value);

szRegionName=handles.Atlas(handles.Shape).Region(handles.CurrentRegion).RegionName;

% aX, aY, aZ is image's dimension
aX=handles.Atlas(handles.Shape).Aheader.x_dim.value;
aY=handles.Atlas(handles.Shape).Aheader.y_dim.value;
aZ=handles.Atlas(handles.Shape).Aheader.z_dim.value;
    
handles.ShapeValue=handles.ShapeValue + 1;

% generate mask
[mX,mY,mZ]=ndgrid(1:aX, 1:aY, 1:aZ);
switch handles.CurrentRegion
case 1 % sphere
    tmpSubRegionName=[szRegionName '_' num2str(X) '_' num2str(Y) '_' num2str(Z) '_' szX];
    ind=find(((mX-X).^2 + (mY-Y).^2 + (mZ-Z).^2 )<=(sX)^2);
case 2 % box
    tmpSubRegionName=[szRegionName '_' num2str(X) '_' num2str(Y) '_' num2str(Z) '_' szX '_' szY '_' szZ];
    ind = find ((abs(mX-X) <=(sX)) .* (abs(mY-Y)<=(sY)) .* (abs(mZ-Z) <=(sZ)));
end
    % apply mask to shape atlas
    mask1=zeros(aX, aY, aZ);
    mask1(ind)=2^handles.ShapeValue;
    %%mask1(ind)=handles.ShapeValue;
    handles.Atlas(handles.Shape).Atlas= handles.Atlas(handles.Shape).Atlas + mask1;
    %%ind=find(handles.Atlas(handles.Shape).Atlas>=handles.ShapeValue);
    %%handles.Atlas(handles.Shape).Atlas(ind)=handles.ShapeValue;

    % add subregion value
    handles.Atlas(handles.Shape).Region(handles.CurrentRegion).SubregionValues = ...
    [handles.Atlas(handles.Shape).Region(handles.CurrentRegion).SubregionValues handles.ShapeValue];
    
    % add subregion name
    if (length(handles.Atlas(handles.Shape).Region(handles.CurrentRegion).SubregionNames)==0)
        handles.Atlas(handles.Shape).Region(handles.CurrentRegion).SubregionNames = ...
            {tmpSubRegionName};
    else
        handles.Atlas(handles.Shape).Region(handles.CurrentRegion).SubregionNames(end +1)= {tmpSubRegionName};
    end    
    names=handles.Atlas(handles.CurrentAtlas).Region(handles.CurrentRegion).SubregionNames;
    names=[{'..'} names];
    set(handles.RegionList,'String', names);
    
    set(handles.RegionList,'Value',[length(handles.Atlas(handles.Shape).Region(handles.CurrentRegion).SubregionNames)+1]);

    % Add new shape subregion to list
    handles.WorkingLevel=3;
    set(handles.txtAtlas,'String',[handles.SelectedAtlasType.atlasname '->' ...
        handles.Atlas(handles.CurrentAtlas).Name '->' ...
        handles.Atlas(handles.CurrentAtlas).Region(handles.CurrentRegion).RegionName]);
    
    guidata(handles.figure1,handles);

    % Add new shape subregion to WorkingList
    AddWorkList(handles,0);


% --------------------------------------------------------------------


% --- Executes during object creation, after setting all properties.
function smallWorkingList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smallWorkingList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in smallWorkingList.
function smallWorkingList_Callback(hObject, eventdata, handles)
% hObject    handle to smallWorkingList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns smallWorkingList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from smallWorkingList


% --- Executes during object creation, after setting all properties.
function SliceSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliceSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to SliceSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%-----------------------------------------------------------------------
% This is the handler for the 'Generate Table' button.
% --- Executes on button press in generatetablebtn.
%-----------------------------------------------------------------------
function generatetablebtn_Callback(hObject, eventdata, handles)
% hObject    handle to generatetablebtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.txtITD, 'String', '');
      
    retStat = wfu_generate_table(handles);
    if (retStat==0)
        set(handles.txtITD, 'String', 'Table generated');
    else
        set(handles.txtITD, 'String', 'Table not generated');
    end
%   openfig('wfu_pickatlas.fig','reuse'); %bring main fig back to forefront
    fullfigpath = which('wfu_pickatlas.fig');
    openfig(fullfigpath,'reuse'); %bring main fig back to forefront

% disp(handles)
% disp(handles.Atlas(2))
% disp(handles.Atlas(2).Name)
% return;
% varargout{10} = handles; 
% disp('new print')
return; 
function retStat = wfu_generate_table(handles)

%--------------------------------------------------------------------------
% Function: wfu_generate_table(handles)
%
% Purpose:  This function is called when the user clicks the Generate Table
%           button in the wfu_pickatlas application. It does the following:
%           1. presents a dialog box to the user for selection of filenames.
%           2. If user makes a single selection, and it is a file with
%           extension '.flist', that file is assumed to contain a list of
%           Analyze .img files to read. These are then read and grouped into a
%           list.
%           3. In all other cases, the selected filenames are simply grouped into a list
%           4. The user is prompted to enter the name of an output ROI file
%           that will hold the table created by this function.
%           5. If the user did NOT select an .flist file, the file list is
%           saved as an .flist file with the same name as
%           that entered for the output ROI table.
%           6. The ROI table is created and saved.
%
% Calling Args:
%           handles = structure with handles and user data (see GUIDATA)
%
% Returns:  0 if processing completed successfully, 1 otherwise.
%
%==========================================================================
% C H A N G E   L O G
% BAS   06/04/04    Added check for existence of spm_get() and, if not
%                   found, calls wfu_pickfile() instead. Also added retStat
%                   (returned status indicator) so won't display 'Table
%                   Generated' message if cancel out of file selection
%                   dialog. Also replaced spm_input() with Matlab function inputdlg().
%--------------------------------------------------------------------------

global atlas_toolbox
retStat = 1; %in case get out early

PA = strcat(atlas_toolbox,	'/', handles.SelectedAtlasType.subdir, ...
					'/', handles.SelectedAtlasType.dispimage   );
%--------------------------------------------------------------------
% Display file selection dialog box and get user's choice(s):
%--------------------------------------------------------------------
%    if (exist('spm_get'))
    if (exist('spm_select'))
        P_list=spm_select(Inf, 'IMAGE', 'Select list of Analyze image files');
    elseif (exist('spm_get'))
 	    P_list = spm_get( Inf, '*.img', 'Select list of Analyze image files' );
    else
        P_list = wfu_pickfile('*.img', 'Select list of Analyze image files');
    end
	if size( P_list, 1) == 0, 
		disp( 'No files selected. Table generation canceled.' );
		return; 
	end;

   
    %------------------------------------
    % If user gave a .flist file, use it:
    %------------------------------------
    if (size( P_list, 1)==1)
        [pathstr,name,ext] = fileparts(P_list(1,:));
        if (strcmp(strtok(ext),'.flist'))%note: strtok needed to remove any trailing blanks before test
            listOfFiles=P_list(1,:); %save the selected filename for the listOfFiles
            P_list = wfu_read_flist(listOfFiles);
        end
    end 
  
    %--------------------------------------------------------------
    % Display ROI table name dialog box to let user change it:
    %--------------------------------------------------------------
    ofid  = 1;
    default_name = strcat( 'ROI_Table_', datestr(now,30) );
%    if (exist('spm_get'))
    if (exist('spm_input'))
        set(handles.txtITD, 'String', 'Please select ROI table name');
        ofile_name = spm_input( 'Give a file name for the output: ', '1', 's', default_name);
        %Finter = spm_input('!GetWin');    %formerly spm_input_ui
        %delete(Finter);                    
        spm_figure('Clear','Interactive'); %clear input window
    else
        prompt = {'Give a file name for the output: '};
        dlg_title = 'Please select ROI table name';
        answer  = inputdlg(prompt,dlg_title,1,{default_name},'on');  
        if (isempty(answer))%if user canceled, return
            disp('User clicked cancel button. Table generation canceled.');
            return
        elseif (length(answer{1})==0)
            disp('User did not enter an output filename. Table generation canceled.');
            return        
        else
            ofile_name = answer{1};%else change from cell to array type for fopen call below.
        end
    end
    
    %---------------------------------
    % Open the output file for writing:
    %---------------------------------
    ofid = fopen( strcat( ofile_name, '.tbl'), 'w' );
    if (ofid==-1)
        errordlg(sprintf('Error opening file %s',strcat( ofile_name, '.tbl')));
        return
    end
    fprintf(ofid,'    Size\tAverage     \tStd.Dev.\tT        \t Region   \tROI name   \tL/R/B\tStudy     \tImage\n');
    disp(sprintf('Reading files, please wait...'));

    %------------------------------------------------
    % Create a .flist file from the ROI table name 
    % and write the list of filenames into it:
    %------------------------------------------------
    lfid  = 1;
    [pathstr,name] = fileparts(ofile_name);
    if (isempty(pathstr))
        pathstr=pwd;
    end
    listOfFiles = sprintf( '%s/%s.flist',pathstr,name);
    lfid = fopen(listOfFiles, 'w' );
    %------------------------------------------------
    % Write list (first record = number of filenames):
    %------------------------------------------------
    fprintf(lfid,'%d\n',size( P_list, 1));
    for ip = 1:size(P_list, 1)
        fprintf(lfid,'%s\n',P_list(ip,:));
    end
    fclose(lfid);
    
    %%%%%%%	Code borrowed from GenerateMask
	CMaskSide = [ 'R' 'L' 'B' ];
	List      = [];

	if (handles.isSimple)				% isSimple
	   AWL   = handles.WorkList;
	   AIndex      = 1:length( AWL );
	   for idx = AIndex
		A = AWL(idx).Atlas; 	R = AWL(idx).Region;	SubR = AWL(idx).Subregion;

		TheValue    = handles.Atlas(A).Region(R).SubregionValues(SubR);
		Offset      = handles.Atlas(A).Region(R).Offset;
		MaskSide    = handles.MaskSide;

		% Get the Point List and construct a Regn
		List    	= findindex( handles, TheValue, handles.Dilate, Offset, MaskSide);
    		Regn.names{1}	= handles.Atlas(A).Region(R).SubregionNames{SubR}; 
    		Regn.groups{1}	= handles.Atlas(A).Region(R).RegionName;

	    	print_ROI(ofid, List, Regn, CMaskSide(handles.MaskSide), PA, P_list, handles );
	   end
    	else % Not Simple = Advanced
           if(handles.display_flag==0) % NOT display_flag
             if(     ~isempty( handles.AdvancedWorkList ) &  ~isempty( handles.AdvancedIndex)   )
            	List = getadvancedlist(   handles.AdvancedWorkList( handles.AdvancedIndex(1)), handles);
            	Regn = getadvancedregion( handles.AdvancedWorkList( handles.AdvancedIndex(1)), handles);
	    	print_ROI(ofid, List, Regn, CMaskSide(handles.MaskSide), PA, P_list , handles);
             end
           else % display_flag
             if(handles.isAll)				% if isAll, then get all of finallist
                for i=1:length(handles.finallist)	
                    List = getadvancedlist(   handles.finallist(i).AdvancedWorkList, handles);
            	    Regn = getadvancedregion( handles.finallist(i).AdvancedWorkList, handles);
	    	    print_ROI(ofid, List, Regn, CMaskSide(handles.MaskSide), PA, P_list , handles);
             	end
             else 					%else if( ~isempty(CurrentFinal)) get that
                if(handles.CurrentFinal>0)
		  for i = 1:length(handles.CurrentFinal)	
                    List = getadvancedlist(   handles.finallist( handles.CurrentFinal(i) ).AdvancedWorkList, handles);
            	    Regn = getadvancedregion( handles.finallist( handles.CurrentFinal(i) ).AdvancedWorkList, handles);
	    	    print_ROI(ofid, List, Regn, CMaskSide(handles.MaskSide), PA, P_list , handles);
		  end
                end
             end % isAll
           end % is displayflag
	end % not isSimple
        
	fclose(ofid);
    retStat = 0;
	disp(sprintf(['Table written to ' pwd '/' ofile_name '.tbl']));
    return;
 

% --- Print ROI function
function print_ROI( ofid, reg_idx, Regn, Side, PA, P_list, handles )
% %%% 
	VA = spm_vol( PA );

	dim     = VA.dim;  plane = dim(1)*dim(2);
	reg_x   =      mod(reg_idx, dim(1));  % + 1 --> debugging found this off by one
	reg_y   =  fix(mod(reg_idx, plane ) / dim(1)) +1;
	reg_z   =  fix(    reg_idx/ plane ) +1;

	atlas_pix = [ reg_x, reg_y, reg_z, ones(length(reg_idx), 1) ]';
	atlas_mm  = VA.mat*atlas_pix; % VA.mat = pix2mm  

    nFiles = size(P_list, 1);
	for ip = 1:nFiles
        set(handles.txtITD, 'String', sprintf('processing file %d of %d...',ip,nFiles));
        drawnow; 
		PF = strtok(P_list( ip,:),' ');%strip trailing blanks
		VF = spm_vol( PF );
        %Get study ID from the pathname:
        [fpath fname fext fver ] = fileparts( PF );
        [fstem fdir  fext fver ] = fileparts( fpath );%back up one
		mm2pix   = inv( VF.mat);
		fmri_pix = mm2pix*atlas_mm;
        
		% hold = 1 --> trilinear interp; hold = 0 --> nearest neighbor
		% use 0 to debug when sampling original atlas, use 1 otherwise
		fmri_I   = spm_sample_vol( VF, fmri_pix(1,:), fmri_pix(2,:), fmri_pix(3,:), 1); 

		finite_idx = find( isfinite( fmri_I));
		if length( finite_idx) > 0,
			fmri_I = fmri_I( find( isfinite( fmri_I)));

			n_reg   = size(fmri_I,2); sum_reg = sum(fmri_I); ssq_reg = sum( fmri_I .* fmri_I);
			avg_reg = sum_reg/n_reg;  std_reg = sqrt(ssq_reg/n_reg - (avg_reg)^2);
			if std_reg > 0,         T_reg = avg_reg/std_reg;
			else,                   T_reg = sign(avg_reg)*Inf;      end;
            
			for ir = 1:length( Regn.groups )
				gRoups = union( Regn.groups(1), Regn.groups(ir) );
			end
			Region    = sprintf( '%s ', gRoups{:}      );
			Subregion = sprintf( '%s ', Regn.names{:}  );
		
			fprintf( ofid, ...
			      '%8g\t%8g\t%8g\t%8g\t%s\t%s\t%s\t%s\t%s\n',...
			       n_reg, avg_reg,std_reg,  T_reg, Region, Subregion, Side,   fdir, fname);
             
		end % fMRI_idx not empty
	end; % P_list 
%end print_ROI
    

