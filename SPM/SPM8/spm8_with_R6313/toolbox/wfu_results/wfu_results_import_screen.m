function SPM = wfu_results_import_screen(SPM,title,subtitle,editList)
% function SPM = wfu_results_import_screen(SPM[,title,subtitle,editList])
% 
% takes an input "SPM" and uses it, returning a fuller SPM for wfu_results
%
% editList = Cell Array of items to edit.  If empty, all are editable.
%            The below options may be prefixed with a minus to exclude them, 
%            -conImage for example.  NOTE: excluded items will override any
%            included item.
%            options: erdf conImage stat eidf fwhm mask
%
% SPM stuct returned, required items noted [REQUIRED]
%
% SPM.xCon(i).Vspm = spm_vol(overlay)     the image
% SPM.xCon(i).eidf (dof low)              UI (Effective interest degrees of freedom)
% SPM.xCon(i).STAT                        UI (poss from intent code)
% SPM.xCon(i).name                        [REQUIRED FOR EACH CONTRAST, UNLESS YOU WANT AN EMPTY BOX!!!]
% -------------------------------------
% SPM.xVol.XYZ = XYZ of "brain region"    UI (brain mask voxel coordinates)
% SPM.xVol.M =                            from image
% SPM.xVol.FWHM                           UI
% SPM.xVol.DIM                            from image
% SPM.xVol.S                              ??
% SPM.xVol.R = spm_resels(FWHM,D,SPACE)   Auto calc
% -------------------------------------
% SPM.xX.erdf (dof hi)                    UI (effective residual degrees of freedom)
% -------------------------------------
% SPM.VM = spm_vol(mask)                  Whole Brain mask
%
% --CUSTOM ADDITIONS TO SPM STRUCTURE--
% SPM.VM.fnameOrig                        Original name of SPM.VM.fname before wfu_uncompress_nifti
% SPM.xCon(i).Vspm.fnameOrig              Original name of SPM.xCon(i).Vspm.fname before wfu_uncompress_nifti
%
%
% All fields are read from handles.xxx handles, except for the filenames.  
% These use the "fitTextInField" which destroys the 'string' part of the 
% handle. These original file names are stored in "data" var and then saved 
% as GUIDATA to be used and modified as need when the form is active and the
% retrieved aferwards.  Also saved to the GUIDATA is the handles var for use as
% needed.
%
%
%__________________________________________________________________________
% Created: Nov 9, 2010 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.5 $

  global WFU_LOG;
  if isempty(WFU_LOG)
    WFU_LOG=wfu_LOG();
  end
  WFU_LOG.info('Entered function $Revision: 1.5 $');
  global WFU_RESULTS;
  
  %create blank places as needed in SPM, creating full structure
  
  curEditListDefault = {'erdf','conImage','stat','eidf','fwhm','mask'};
  
  if nargin < 1, SPM = []; end;
  if nargin < 2 || isempty(title), title = 'Load image information'; end;
  if nargin < 3 || isempty(subtitle), subtitle=[]; end;
  if nargin < 4, editList=curEditListDefault; end;
  
  if ~iscell(editList)
    editList = {editList};
  end
  
  %remove unwanted editable items
  removeEditListIndex=find(~cellfun('isempty',strfind(editList,'-')));
  if length(removeEditListIndex) == length(editList) %only -options exist, need all options to start with
    editList={curEditListDefault{:} editList{:}};
    removeEditListIndex=find(~cellfun('isempty',strfind(editList,'-')));
  end;  
  removeEditListItems=editList(removeEditListIndex);
  if any(removeEditListIndex)
    for i=1:length(removeEditListItems)
      tok = removeEditListItems(i);
      tok=strrep(char(tok),'-','');
      tokListIndex=find(~cellfun('isempty',strfind(editList,tok)));
      editList(tokListIndex) = [];
    end
  end
  
  % %%%%%%%%%%%%%%%%%%%%%%
  % BUILD SPM STRUCTURE UP 
  % %%%%%%%%%%%%%%%%%%%%%%
  
  
  %SPM.xCon CONTRASTS
  if ~isfield(SPM,'xCon'),      SPM.xCon=   struct(); end;
  if ~isfield(SPM.xCon,'Vspm'), SPM.xCon(1).Vspm= struct('fname', [], 'fnameOrig', []); end;
  if ~isfield(SPM.xCon,'eidf'), SPM.xCon(1).eidf= []; end;
  if ~isfield(SPM.xCon,'STAT'), SPM.xCon(1).STAT= []; end;
  if ~isfield(SPM.xCon,'name'), SPM.xCon(1).name= []; end;

  for i=1:length(SPM.xCon)
    if ~isfield(SPM.xCon(i).Vspm,'fname'),     SPM.xCon(i).Vspm.fname=    []; end;
    if ~isfield(SPM.xCon(i).Vspm,'fnameOrig'), SPM.xCon(i).Vspm.fnameOrig=[]; end;
  end
  
  %SPM.xVol STATISTICS VOLUME INFORMATION
  if ~isfield(SPM,'xVol'),      SPM.xVol=     []; end;
  if ~isfield(SPM.xVol,'XYZ'),  SPM.xVol.XYZ= []; end;
  if ~isfield(SPM.xVol,'M'),    SPM.xVol.M=   []; end;
  if ~isfield(SPM.xVol,'FWHM'), SPM.xVol.FWHM=[]; end;
  if ~isfield(SPM.xVol,'DIM'),  SPM.xVol.DIM= []; end;
  if ~isfield(SPM.xVol,'S'),    SPM.xVol.S=   []; end;
  if ~isfield(SPM.xVol,'R'),    SPM.xVol.R=   []; end;
  
  %SPM.xX   DOF (hi)
  if ~isfield(SPM,'xX'),      SPM.xX=      []; end;
  if ~isfield(SPM.xX,'erdf'), SPM.xX.erdf= []; end;
  
  %SPM.VM   VOLUME MASK
  if ~isfield(SPM,'VM'),            SPM.VM=[];            end;
  if ~isfield(SPM.VM,'fname'),      SPM.VM.fname=[];      end;
  if ~isfield(SPM.VM,'fnameOrig'),  SPM.VM.fnameOrig=[];  end;
  
  %assorted vars need later
  %statXXXX should conform in order and index to NiFTI standards
  statList={ '' 'x' 't' 'f' 'z' };  
  statNames='Select Stat|Correlation|t stat|F stat|Z score';  %for dropdown

  %col settings do not directly affect the scroll pane and scroll panel
  %same for all Col setups
  border=[0.005 0.005]; %[left right]
  
  %1 col setup
  width1Col=1-sum(border);
  loc1Col=[border(1)];
  
  %2 col setup
  numCol=2;
  width2Col=(1-(numCol+1)*sum(border))/numCol;
  loc2Col=[border(1) border(1)+width2Col+border(1)];
  
  %4 col setup
  numCol=4;
  width4Col=(1-(numCol+1)*sum(border))/numCol;
  loc4Col=[border(1) border(1)+1*width4Col+border(1) border(1)+2*width4Col+2*border(1) border(1)+3*width4Col+3*border(1)];
  
  %line spacing (and start)
  lineNum=1;
  lineWidth=1.15;
  
  %init the editHAndles var
  handles=struct();
  
  parHandle=wfu_findFigure('WFU_Results_Window');
  parData=guidata(parHandle);
  parData=parData.data; %remove the handles stuct
  
  %create window, set baic attributes
   importParent = figure('Units', 'normalized',...
    'HandleVisibility', 'on',...
    'IntegerHandle', 'off',...
    'NumberTitle', 'off',...
    'Name', title,...
    'MenuBar', 'none', ...
    'Tag','WFU_RESULTS_VIEWER_IMPORTER',...
    'Toolbar', 'none', ...
    'Units','normalized',...
    'Position',[.1 .1 600/parData.screeninfo(3) 600/parData.screeninfo(4)], ...  %divide by Screen for "normalized" space
    'Visible', 'on');

  if parData.versions.matlab.major >= 7 & parData.versions.matlab.minor >= 6 & parData.preferences.scroll
		set(importParent,'WindowScrollWheelFcn',{@sliderCallback,true});
	end

  
  importWindow = uipanel('Units', 'normalized',...
    'Position',[.01 .01 .94 .98],...
    'BackGroundColor',get(importParent,'Color'),...
    'BorderType','none');
  
  set(importParent,'DeleteFcn',sprintf('uiresume(%.20f)',importParent));

  handles.scrollbar = uicontrol('Parent',importParent,...
    'Style','slider',...
    'Units','Normalized',...
    'Position',[.95 .01 .04 .98],...
		'Enable','off',...
    'Min', 0,...
    'Max', 1,...
    'Value', .5,...
		'Visible','on',...
    'Callback',@sliderCallback);
  
  %place on screen to get extents...then move to correct locations
  t = uicontrol('Parent',importWindow,...
    'Style','text',...
    'FontWeight','bold',...
    'String','Please wait...',...
    'Units','Normalized',...
    'Position',[loc1Col(1) .5 width1Col .10]);

  extent = get(t,'Extent');
  lineHeight = extent(4);

  set(t,'Position',[loc1Col(1) 1-(lineNum*lineWidth)*lineHeight width1Col lineHeight]);
  if isempty(subtitle)
    set(t,'Visible','off');
  else
    set(t,'String',subtitle);
    lineNum=lineNum+2; %SPACE
  end
  
  
  
  %
  % CONTRAST UN-SPECIFIC
  %  
  
  uicontrol('Parent',importWindow,...
    'Style','text',...
    'FontWeight','bold',...
    'String','Items related to all contrasts',...
    'Units','Normalized',...
    'Position',[loc1Col(1) 1-(lineNum*lineWidth)*lineHeight width1Col lineHeight]);
  lineNum=lineNum+1;

  if any(strcmpi(editList,'erdf'))
    uicontrol('Parent',importWindow,...
      'Style','text',...
      'String','Effective Residual Degrees of Freedom',...
      'Units','Normalized',...
      'HorizontalAlignment','left',...
      'Position',[loc4Col(1) 1-(lineNum*lineWidth)*lineHeight 3*width4Col lineHeight]);

    handles.erdf = uicontrol('Parent',importWindow,...
      'Style','edit',...
      'String',num2str(SPM.xX.erdf),...
      'Tooltip','Also known as Denominator DOF or ERDF',...
      'Units','Normalized',...
      'Callback',{@local_check_numeric,struct('positive',true,'interger',true)},...
      'Position',[loc4Col(4) 1-(lineNum*lineWidth)*lineHeight width4Col lineHeight]);
    lineNum=lineNum+1;
  end

  if any(strcmpi(editList,'fwhm'))
    uicontrol('Parent',importWindow,...
      'Style','text',...
      'String','Full Width Half Max (numeric voxels or NNmm)',...
      'Units','Normalized',...
      'HorizontalAlignment','left',...
      'Position',[loc2Col(1) 1-(lineNum*lineWidth)*lineHeight width2Col lineHeight]);
    
    if isnumeric(SPM.xVol.FWHM)
      buttonText=num2str(SPM.xVol.FWHM);
    else
      buttonText=SPM.xVol.FWHM;
    end
    
    handles.fwhm = uicontrol('Parent',importWindow,...
      'Style','edit',...
      'HorizontalAlignment','center',...
      'Units','Normalized',...
      'String',buttonText,...
      'Tooltip',sprintf('This may be entered in voxels (numeric only) or mm (number with mm prefix).\nSample voxels: `5`or `5 5 5`\nSample mm: `5mm` or `5mm 5mm 5mm`'),...
      'Callback',@local_check_fwhm,...
      'Position',[loc2Col(2) 1-(lineNum*lineWidth)*lineHeight width2Col lineHeight]);
    
    local_check_fwhm(handles.fwhm,[]);  %cleanup any imports with mm in them or that come across as a sinlge number.
    lineNum=lineNum+1;
  end
  
  if any(strcmpi(editList,'mask'))
    uicontrol('Parent',importWindow,...
      'Style','text',...
      'String','Whole brain mask',...
      'Units','Normalized',...
      'HorizontalAlignment','left',...
      'Position',[loc2Col(1) 1-(lineNum*lineWidth)*lineHeight width2Col lineHeight]);

    if ~isempty(SPM.VM.fnameOrig)
      buttonText= SPM.VM.fnameOrig;
      data.mask=  SPM.VM.fnameOrig;
    elseif ~isempty(SPM.VM.fname)
      buttonText= SPM.VM.fname;
      data.mask=  SPM.VM.fname;
    else
      buttonText= 'Click to select image';
      data.mask=  [];
    end
    
    btnH = uicontrol('Parent',importWindow,...
      'Style','pushbutton',...
      'Units','Normalized',...
      'HorizontalAlignment','center',...
      'Callback',{@local_choose_image,'mask'},...
      'Position',[loc2Col(2) 1-(lineNum*lineWidth)*lineHeight width2Col lineHeight]);

    fitTextInField(buttonText,btnH);
    
    lineNum=lineNum+1;
  end

  
  lineNum=lineNum+1;  %spacing between sections

  
  
  %
  % CONTRAST SPECIFIC
  %
  
  uicontrol('Parent',importWindow,...
    'Style','text',...
    'FontWeight','bold',...
    'String','Contrast specific',...
    'Units','Normalized',...
    'Position',[loc1Col(1) 1-(lineNum*lineWidth)*lineHeight width1Col lineHeight]);
  lineNum=lineNum+1;

  %items applying to all of the contrast image selections, but settings
  %dependent.
  if any(strcmpi(editList,'conImage'))
    imgStyle='pushbutton';
    imgTextDef='Select contrast image';
  else
    imgStyle='text';
    imgTextDef='WARNING!! No contrast image defined';
  end

  for z=1:length(SPM.xCon)
    if ~isfield(SPM.xCon,'name') || isempty(SPM.xCon(z).name)
      SPM.xCon(z).name=sprintf('Contrast %d',z);
    end
    uicontrol('Parent',importWindow,...
      'Style','text',...
      'String',SPM.xCon(z).name,...
      'Units','Normalized',...
      'HorizontalAlignment','left',...
      'Position',[loc2Col(1) 1-(lineNum*lineWidth)*lineHeight width2Col lineHeight]);
    
    if isfield(SPM.xCon(z).Vspm,'fnameOrig') && ~isempty(SPM.xCon(z).Vspm.fnameOrig)
      imgText=                SPM.xCon(z).Vspm.fnameOrig;
      data.conImage{z}.fname= SPM.xCon(z).Vspm.fnameOrig;
    elseif ~isempty(SPM.xCon(z).Vspm.fname)
      imgText=                SPM.xCon(z).Vspm.fname;
      data.conImage{z}.fname= SPM.xCon(z).Vspm.fname;
    else
      imgText=                imgTextDef;
      data.conImage{z}.fname= [];
    end
    

    btnH = uicontrol('Parent',importWindow,...
      'Style',imgStyle,...
      'Units','Normalized',...
      'HorizontalAlignment','center',...
      'Callback',{@local_choose_image,'conImage',z},...
      'Position',[loc2Col(2) 1-(lineNum*lineWidth)*lineHeight width2Col lineHeight]);

    fitTextInField(imgText,btnH);

    lineNum=lineNum+1;

    if any(strcmpi(editList,'stat'))
      uicontrol('Parent',importWindow,...
        'Style','text',...
        'String','Statistic type',...
        'Units','Normalized',...
        'HorizontalAlignment','left',...
        'Position',[loc4Col(2) 1-(lineNum*lineWidth)*lineHeight 2*width4Col lineHeight]);

      handles.stat(z) = uicontrol('Parent',importWindow,...
        'Style','popupmenu',...
        'String',statNames,...
        'Units','Normalized',...
        'Position',[loc4Col(4) 1-(lineNum*lineWidth)*lineHeight width4Col lineHeight]);
      statIndexes=find(strcmpi(statList,SPM.xCon(z).STAT));
      if length(statIndexes)
        set(handles.stat(z),'Value',statIndexes(1));
      end
      lineNum=lineNum+1;
    end
      
    if any(strcmpi(editList,'eidf'))
      uicontrol('Parent',importWindow,...
        'Style','text',...
        'String','Effective interest DOF',...
        'Units','Normalized',...
        'HorizontalAlignment','left',...
        'Position',[loc4Col(2) 1-(lineNum*lineWidth)*lineHeight 2*width4Col lineHeight]);

      handles.eidf(z) = uicontrol('Parent',importWindow,...
        'Style','edit',...
        'String',num2str(SPM.xCon(z).eidf),...
        'Tooltip','Also known as Numerator DOF or EIDF',...
        'Value',1,...
        'Units','Normalized',...
        'Callback',{@local_check_numeric,struct('positive',true,'interger',true)},...
        'Position',[loc4Col(4) 1-(lineNum*lineWidth)*lineHeight width4Col lineHeight]);
      lineNum=lineNum+1;
    end
  end
  
  lineNum=lineNum+2; %SPACE
  
  %done button
  
  doneButton=uicontrol('Parent',importWindow,...
        'Style','pushbutton',...
        'HorizontalAlignment','center',...
        'String','Done',...
        'Units','Normalized',...
        'Callback',sprintf('uiresume(%.20f)',importParent),...
        'Position',[loc4Col(4) 1-(lineNum*lineWidth)*lineHeight width4Col lineHeight]);

      
  %enable the scrollbar if needed
  if 1-(lineNum*lineWidth)*lineHeight < .01
    set(handles.scrollbar,'Enable','on');
    set(handles.scrollbar,'Value',1);
  end
  
  %other variables to data:
  data.statList=statList;
  data.statNames=statNames;
  data.handles=handles;
  data.importWindow=importWindow;
  data.importParent=importParent;
  data.lineNumMin=1-(lineNum*lineWidth)*lineHeight;

  
  guidata(importParent,data);
%  uiwait(importParent);
  uiwait
  
  %check returns true when everything is good, place it in SPM
  [sts SPM] = local_check_and_set(importParent,editList,SPM);
  
  while ~sts  %continue to wait until it is good.
%    uiwait(importParent);
    uiwait
    set(doneButton,'Enable','off');
    drawnow();
    [sts SPM] = local_check_and_set(importParent,editList,SPM);
    set(doneButton,'Enable','on');
    drawnow();
  end
  
  %only delete the window when we have what we need from it.
  if ishandle(importParent)
    delete(importParent);
  end
return


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % CALLBACKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function local_choose_image(hObj,eventData,imageType,index)
%hObj is the handle of the "button"
%eventData is not used, but required by matlab
  if nargin < 3
    error('atleast 3 arguments required to wfu_results_import_screen::local_choose_image');
  end
  if nargin < 4
    index = [];
  end
  hProperties = get(hObj);
  data = guidata(hProperties.Parent);
  
  if strcmpi(imageType,'mask')
    fname=data.mask;
    title='Select mask image';
  else
    fname=data.conImage{index}.fname;
    title='Select contrast image';
  end
  
  if ~isempty(fname)
    startPath = fileparts(fname);
  else
    startPath = [];
  end
  
  fname = wfu_pickfile('image',title,startPath);
  
  if strcmpi(imageType,'mask')
    data.mask=fname;
  else
    data.conImage{index}.fname=fname;
    [ic ip] = wfu_read_intent_code(wfu_uncompress_nifti(fname));
    if ~isempty(ic) && ic ~= 0
      if isfield(data.conImage,'statCode') && ic ~= data.conImage{index}.statCode
        beep();
        fprintf('Changing stat code from %d to %d\n', data.conImage{index}.statCode, ic);
      end
      data.conImage{index}.statCode = ic;
    end
  end
  
  fitTextInField(fname,hObj);
  
  guidata(hProperties.Parent,data);
  
return

function local_check_numeric(hObj,eventData,flags)
  %flags.positive is x >0, otherwise x can be any number
  %flags.interger allows only intergers
  global WFU_LOG;
  
  num = str2num(get(hObj,'String'));
  if isempty(num)
    WFU_LOG.warndlg('Invalid number','Invalid number');
    set(hObj,'String','');
    uicontrol(hObj);
  end
  if nargin > 2 
    if isfield(flags,'positive') && flags.positive
      if num <= 0
        WFU_LOG.warndlg('Number must be greater than 0 (Positive)','Positive Number Required');
        set(hObj,'String','');
        uicontrol(hObj);
      end
    end
    if isfield(flags,'interger') && flags.interger
      if round(num) ~= num
        WFU_LOG.warndlg('Number must be an interger, rounding.','Interger Required');
        set(hObj,'String',num2str(round(num)));
        uicontrol(hObj);
      end
    end
  end
return


function local_check_fwhm(hObj,eventData)
  global WFU_LOG;

  FWHM_t=lower(get(hObj,'String'));
  if isempty(FWHM_t), return; end;
  if findstr(FWHM_t,'mm')
    FWHM = str2num(strrep(FWHM_t,'mm',''));
    if length(FWHM) == 1
      FWHM = FWHM .* [1 1 1];
    elseif length(FWHM) ~= 3
      WFU_LOG.warndlg('FWHM must be specified as a single number or trip array.');
      FWHM = FWHM(1) .* [1 1 1];
      uicontrol(hObj);
    end
    FWHM_newtext = sprintf('%dmm %dmm %dmm',FWHM(1),FWHM(2), FWHM(3));
  else
    FWHM = str2num(FWHM_t);
    if length(FWHM) == 1
      FWHM = FWHM .* [1 1 1];
    elseif length(FWHM) ~= 3
      WFU_LOG.warndlg('FWHM must be specified as a single number or triple array.');
      try, FWHM = FWHM(1) .* [1 1 1]; catch, FWHM=[]; end
      uicontrol(hObj);
    end
    FWHM_newtext=num2str(FWHM);
  end
  set(hObj,'String',FWHM_newtext);
return

function sliderCallback(hObj,eventData,mouse)
  if exist('mouse','var') == 1 && mouse
    %this call is from the parent figure
    data = guidata(hObj);
    speedStep=eventData.VerticalScrollCount;
    scrollValue=get(data.handles.scrollbar,'Value');
    scrollValue=scrollValue-.05*speedStep;
    if scrollValue < 0
      scrollValue=0;
    elseif scrollValue > 1
      scrollValue=1;
    end
    set(data.handles.scrollbar,'Value',scrollValue);
  else
    %this call is from the panel
    hProperties = get(hObj);
    data = guidata(hProperties.Parent);
  end
  scrollPosition=get(data.handles.scrollbar,'Value');
  scrollDistance=.01-data.lineNumMin;
  panelLocation=get(data.importWindow,'Position');
  panelLocation(2)=(1-scrollPosition)*scrollDistance;
  set(data.importWindow,'Position',panelLocation);
return

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % INTERNAL FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sts SPM] = local_check_and_set(gui,editList,SPM)
  global WFU_LOG WFU_RESULTS;
  wfu_resultsProgress('init',9);
  wfu_resultsProgress('Getting handles');
  
  sts=false;
  if ishandle(gui)
    data=guidata(gui);
    handles=data.handles;
  else
    beep();
    wfu_resultsProgress('doneNOW');
    WFU_LOG.warndlg('GUI disappeared unexpectedly.  Imported settings returned to the program may be incomplete.');
    sts=true;
    return;
  end
  
  %go through checks, returning if bad...at end, change sts to if
  %everything checks out.  While going through, update SPM fields as needed
  
  wfu_resultsProgress('Checking ERDF');
  if any(strcmpi(editList,'erdf'))
    erdf=str2num(get(handles.erdf,'String'));
    if isempty(erdf)
      beep();
      wfu_resultsProgress('doneNOW');
      WFU_LOG.errordlg('Need ERDF');
      return;
    end;
    SPM.xX.erdf=erdf;
  end

  % check contrast(s) before mask and FWHM as the first contrast is the
  % "overlay" file needed for possible reslicing.
  wfu_resultsProgress('Checking Contrasts');
  if length(data.conImage) == 0
    wfu_resultsProgress('doneNOW');
    WFU_LOG.errordlg('At least one contrast image must be passed to wfu_results_import_screen::local_check_and_set'); 
  end
  for i=1:length(data.conImage)
    if isempty(data.conImage{i}.fname)
      beep();
      wfu_resultsProgress('doneNOW');
      WFU_LOG.errordlg('No Image Defined for Contrast.\n',i);
      return;
    else
      if any(strcmpi(editList,'conImage'))
        SPM.xCon(i).Vspm=spm_vol(wfu_uncompress_nifti(data.conImage{i}.fname));
        SPM.xCon(i).Vspm.fnameOrig=data.conImage{i}.fname;
      end
      if any(strcmpi(editList,'stat'))
        STAT_Value=get(handles.stat(i),'Value');
        STAT=char(upper(data.statList(STAT_Value)));
        if isempty(STAT), beep(); fprintf('Need Conrast %d STAT\n',i); return; end;
        SPM.xCon(i).STAT=STAT;
      end
      
      if any(strcmpi(editList,'eidf'))
        EIDF=str2num(get(handles.eidf(i),'String'));
        if isempty(EIDF), beep(); fprintf('Need Conrast %d EIDF\n',i); return; end;
        SPM.xCon(i).eidf=EIDF;
      end
    end
  end

  %check for FWHM...place here so that empty check comes before possibly
  %long check of loading mask.
  wfu_resultsProgress('Checking FWHM');
  if any(strcmpi(editList,'fwhm'))
    FWHM_t=get(handles.fwhm,'String');
    if isempty(FWHM_t)
      beep(); 
      wfu_resultsProgress('doneNOW');
      WFU_LOG.errordlg('Need FWHM'); 
      return; 
    end;
  end
  
  
  %check mask before FWHM as FWHM depends on mask, if specified in mm.
  %check contrasts before checking mask, as mask may need resliced to 1st
  %contrast.
  wfu_resultsProgress('Checking Mask');
  if any(strcmpi(editList,'mask'))
    if isempty(data.mask)
      beep(); 
      wfu_resultsProgress('doneNOW');
      WFU_LOG.errordlg('Need Whole brain mask.'); 
      return; 
    end;
    maskfile=data.mask;
    WFU_RESULTS.wholeBrainMaskLabel=maskfile;
    maskfile=wfu_uncompress_nifti(maskfile); %uncompress if needed
    WFU_RESULTS.wholeBrainMask=maskfile; 

    
%
%     %possible flipping issue....but can't see it with known tumor and stats
%     maskfile=wfu_convert_afni_nifti(maskfile);
%     if ~strcmp(maskfile,WFU_RESULTS.wholeBrainMask)
%       WFU_LOG.warndlg('Mask image''s ANFI and nifti header do not match.  Using AFNI''s IJK_TO_DICOM_REAL.  DATA MAY BE FLIPPED.');
%     end
    
    mh=spm_vol(maskfile);
    %mh=spm_vol('/ansir2/bwagner/Development/PickAtlas/testFMRI-spm/RUN1/spm_mat/mask.hdr');
    if any(mh.dim ~= SPM.xCon(1).Vspm.dim) || any(mh.mat(:) ~= SPM.xCon(1).Vspm.mat(:))
      wfu_resultsProgress('Reslicing mask to statistical data');
      WFU_LOG.info('reslicing mask file to match statistical data');
      try
      	[fPath fName fExt fJunk] = fileparts(maskfile);
      catch
      	[fPath fName fExt fJunk] = fileparts(maskfile);
      end
      P = strvcat(SPM.xCon(1).Vspm.fname,maskfile);
      spm_reslice(P);
      WFU_RESULTS.wholeBrainMask = fullfile(fPath,['r' fName fExt]);
    else
      wfu_resultsProgress('Checking Mask'); %no change needed, mask is same
    end
    clear mh;
    
    SPM.VM=spm_vol(WFU_RESULTS.wholeBrainMask);
    SPM.VM.fnameOrig=WFU_RESULTS.wholeBrainMaskLabel;
  end
  
  %check Contrast Images and mask before computing FWHM.
  wfu_resultsProgress('Checking FWHM against Mask');
  if any(strcmpi(editList,'fwhm'))

    inMM=false;
    if findstr(FWHM_t,'mm')
      FWHM_t = strrep(FWHM_t,'mm','');
      inMM=true;
    end
    
    FWHM=str2num(FWHM_t);
    
    if inMM 
      if isempty(SPM.VM) || ~isfield(SPM.VM,'mat') || isempty(SPM.VM.mat)
        beep(); 
        wfu_resultsProgress('doneNOW');
        WFU_LOG.errordlg('No Mask available to compute FWHM.  Please enter in voxels, not millimeters'); 
        return; 
      else
        FWHM = FWHM / abs(SPM.VM.mat(1:3,1:3));
        set(handles.fwhm,'String',num2str(FWHM));
      end;
    end
    
    SPM.xVol.FWHM=FWHM;
  end
  
  wfu_resultsProgress('Reading Mask');
  mv=spm_read_vols(SPM.VM);
  wfu_resultsProgress('Creating Stats structure');
  ind=find(mv(:)>0);
  [X Y Z] = ind2sub(size(mv),ind);
  XYZ = [X Y Z]';
  SPM.xVol.XYZ  = round(XYZ);  %double->uint16->double cleans up preceission
  SPM.xVol.M    = SPM.VM.mat;
  SPM.xVol.iM   = inv(SPM.xVol.M);
  SPM.xVol.DIM  = SPM.VM.dim';
  SPM.xVol.S    = size(ind,1);
  SPM.xVol.R    = spm_resels_vol(SPM.VM,FWHM)';
  if ~isfield(SPM.xVol,'units') || isempty(SPM.xVol.units), SPM.xVol.units={'mm' 'mm' 'mm'}; end;

  %end of checks, sts is true
  wfu_resultsProgress('done');
  sts=true;
return



%% Revision Log at end

%{
$Log: wfu_results_import_screen.m,v $
Revision 1.5  2010/07/29 18:13:11  bwagner
progressBar on import

Revision 1.4  2010/07/28 17:30:50  bwagner
Mouse scroll issue in matlab 7.10 (matlab showing version when str2num applied of 7.1).  Added progress bar to results computation.

Revision 1.3  2010/07/19 20:04:16  bwagner
WFU_LOG implemented.  Fixed error report SPM.xVol in original mask and not resliced mask

revision 1.2  2010/07/09 13:37:12  bwagner
Checkin before aHeader to iHeader Pickatlas code update

revision 1.1  2009/10/09 17:11:38	 bwagner
PickAtlas Release Pre-Alpha 1
%}
