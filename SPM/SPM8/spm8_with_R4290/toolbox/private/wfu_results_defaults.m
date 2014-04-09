function defaultStruct = wfu_results_defaults()
% defaultStruct = wfu_results_defaults()
%
% sets up assorted defaults that are to be found in the handles.data
% structure.
%__________________________________________________________________________
% Created: Nov 9, 2010 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.12 $

  global WFU_LOG;
  if isempty(WFU_LOG)
    WFU_LOG=wfu_LOG();
  end
  WFU_LOG.info('Entered function $Revision: 1.12 $');
  
  %check SPM
  try
    defaultStruct.versions.spm = wfu_get_ver;
  catch
    defaultStruct.versions.spm = [];
  end
  
  % set path(s)
  defaultStruct.toolbox_path=fileparts(which('wfu_results.fig'));
  
  if ~strcmp(defaultStruct.versions.spm,'SPM8') || isempty(defaultStruct.versions.spm)
    if isempty(which('spm_vol')) || isempty(strfind(which('spm_vol'),'spm_lite'))
      spmLitePath=fullfile(defaultStruct.toolbox_path,'spm_lite');
      fprintf('Using SPM8_lite, adding (%s) to path.\n',spmLitePath);
      addpath(spmLitePath,'-begin');
    end
  end
  
  wfu_require_tbxs('wfu_results');
  
  %check matlab
  m=ver('matlab');
  [mMajor mMinor]=strtok(m.Version,'.');
  mMinor=         strtok(mMinor,'.'); %remove leading .
  
  defaultStruct.versions.matlab.major=str2num(mMajor);
  defaultStruct.versions.matlab.minor=str2num(mMinor);
  if ~usejava('jvm'), error('Java required.  Try running matlab -nodesktop instead of of -nojvm.\n'); end

  % screen resolution
  screeninfo = get(0,'MonitorPosition');
  h=screeninfo(:,1);
  v=screeninfo(:,2);
  hind=find(h>=0);
  vind=find(v>=0);
  screenIndex=min(find(hind==vind));
  defaultStruct.screeninfo=screeninfo(screenIndex,:);

  %colormaps
  defaultStruct.colormaps.brain = gray(192);
  defaultStruct.colormaps.overlay = hot(64);
  defaultStruct.colormaps.combined = [defaultStruct.colormaps.brain; defaultStruct.colormaps.overlay];

  %default calculation specs
  defaultStruct.conspec.contrasts = 1;
  defaultStruct.conspec.mask = [];
  defaultStruct.conspec.titlestr ='';
  defaultStruct.conspec.threshdesc='none';
  defaultStruct.conspec.thresh=.0001;
  defaultStruct.conspec.extent=0;
  
  %setup ROI basic struct
  defaultStruct.ROI.header.fname=[];
  defaultStruct.ROI.header.fnameOrig=[];
  defaultStruct.ROI.volume=[];

  %temporary files
  defaultStruct.tempfiles.results=[tempname '.nii'];
  defaultStruct.tempfiles.ROI=[tempname '.nii'];
  
  %line endings (for exported,saved files)
  if ispc
    defaultStruct.lineEnding='\r\n';
  else
    defaultStruct.lineEnding='\n';
  end
  
  %find running pickatlas, get main handle
  defaultStruct.paHandle=wfu_findFigure('WFU_PickAtlas');
  
  if ishandle(defaultStruct.paHandle)
    try
      pa=guidata(defaultStruct.paHandle);
    catch ME
      WFU_LOG.errorstack(ME);
      if numel(defaultStruct.paHandle) == 1
        WFU_LOG.errordlg('Unable to sync settings between running PickAtlas and Results Viewer');
      elseif numel(defaultStruct.paHandle) > 1
        set(defaultStruct.paHandle,'Visible','on')
        WFU_LOG.errordlg(sprintf('Unable to sync settings between %d running PickAtlases and Results Viewer',numel(defaultStruct.paHandle)));
      else
        WFU_LOG.errordlg('Unable syncing to PickAtlas');
      end
    end
%     defaultStruct.template.name=fullfile( defaultStruct.toolbox_path,...
%                                           pa.data.SelectedAtlasType.subdir,...
%                                           pa.data.SelectedAtlasType.dispimage);
    if isfield(pa,'data') && isfield(pa.data,'SelectedAtlasType')
      WFU_LOG.info('Using Atlas selected in PickAtlas');
      defaultStruct.atlas=pa.data.SelectedAtlasType;
    else
      WFU_LOG.info('Choosing Atlas');
      clear pa;  %pa is not valid
      defaultStruct.atlas=wfu_pickatlastype;
    end
  elseif exist('wfu_pickatlastype.fig','file')==2
    WFU_LOG.info('Choosing Atlas');
    defaultStruct.atlas=wfu_pickatlastype;
  else
    WFU_LOG.info('No PickAtlas, using default MNI template');
    defaultStruct.atlas=struct([]);
    defaultStruct.template.header.fname=fullfile(defaultStruct.toolbox_path,'MNI_T1.nii');
  end
  
  %font settings for results screen
  defaultStruct.fonts.FS=1:16;                              %font sizes
  defaultStruct.fonts.PF=spm_platform('fonts');             %font names
  
  %default page (results Axis) settings
  defaultStruct.page.dy=max(defaultStruct.fonts.FS(:))+3;  %size of one line of text
  defaultStruct.page.startY=1000;
  defaultStruct.page.y=defaultStruct.page.startY;
  
  %default Preferences found in wfu_pickatlas.mat
  defaultStruct.preferences             = struct();
  defaultStruct.preferences.scroll      = 1;
  defaultStruct.preferences.drag        = 1;
  defaultStruct.preferences.clickDelay  = 0.15;
  defaultStruct.preferences.flip        = [1 0]; %(Neuro, brain up);
  %defaults TC
  % 0 = normal values
  % 1 = normalized to mean
  defaultStruct.preferences.TC          = 0;
  defaultStruct.preferences.paradigm    = 0;
  
  WFU_LOG.info('Reading Preferences');
  %load saved user preferences
  pmat = fullfile(prefdir,'wfu_pickatlas.mat');
  if exist(pmat,'file') == 2
    WFU_LOG.info(sprintf('Loading preferences file: %s\n', pmat));
    load(pmat);
    try defaultStruct.conspec.threshdesc      = wfu_results_ui_preferences.threshdesc;  end
    try defaultStruct.conspec.thresh          = wfu_results_ui_preferences.thresh;      end
    try defaultStruct.conspec.extent          = wfu_results_ui_preferences.extent;      end
    try defaultStruct.preferences.scroll      = wfu_results_ui_preferences.scroll;      end
    try defaultStruct.preferences.drag        = wfu_results_ui_preferences.drag;        end
    try defaultStruct.preferences.clickDelay  = wfu_results_ui_preferences.clickDelay;  end
    try defaultStruct.preferences.flip        = wfu_results_ui_preferences.flip;        end
    if numel(defaultStruct.preferences.flip)==1, defaultStruct.preferences.flip(2)=0;   end
    try defaultStruct.preferences.TC          = wfu_results_ui_preferences.TC;          end
    try defaultStruct.preferences.paradigm    = wfu_results_ui_preferences.paradigm;    end
  end
  
  %Setup default computation settings
  defaultStruct.preferences.threshdesc  = defaultStruct.conspec.threshdesc;
  defaultStruct.preferences.thresh      = defaultStruct.conspec.thresh;
  defaultStruct.preferences.extent      = defaultStruct.conspec.extent;

  
  %mouse scroll only works in matlab 7.6 or better
  if defaultStruct.versions.matlab.major >= 7 && defaultStruct.versions.matlab.minor >= 6
    defaultStruct.scrollEnable = true;
  else
    defaultStruct.scrollEnable = false;
  end
  
  %
  if exist('pa','var')==1 && any(pa.data.flip ~= defaultStruct.preferences.flip)
    beep();
    WFU_LOG.info('Reorienting results flip setting to match pick_atlas');
    defaultStruct.preferences.flip = pa.data.flip;
  end
  
  defaultStruct.flipText = {'L' 'R'; 'R' 'L'};
  
  %default mouse action=
  defaultStruct.mouse.action = [];
return

%% Revision Log at end

%{
$Log: wfu_results_defaults.m,v $
Revision 1.12  2010/07/29 18:21:47  bwagner
If more than one pickatlas is open, show them all in case they are hidden

Revision 1.11  2010/07/28 17:30:50  bwagner
Mouse scroll issue in matlab 7.10 (matlab showing version when str2num applied of 7.1).  Added progress bar to results computation.

Revision 1.10  2010/07/22 15:43:12  bwagner
fixed flip syncing between PA and PAR.  Also provides better error message if multiple PA's found

Revision 1.9  2010/07/22 14:37:04  bwagner
Allowed Up/Down flip.  Flip is now 2 element var with 1st being L/R and 2nd being U/D.  Allow secondary way of calling private/voxelImageConversion.

Revision 1.8  2010/07/19 20:00:54  bwagner
WFU_LOG implentation changed.  Does not readd path each time

revision 1.7  2010/07/13 20:33:05  bwagner
Move to wfu_LOG and better check in PA is running

revision 1.6  2010/07/09 13:37:13  bwagner
Checkin before aHeader to iHeader Pickatlas code update

revision 1.5  2009/12/04 14:13:24  bwagner
Changed private/resultsProgress to wfu_resultsProgress in tbx_common

revision 1.4  2009/12/03 16:00:06  bwagner
TC actual/mean and paradigm showing STICK in preferences.

revision 1.3  2009/11/06 17:22:57  bwagner
Fixed problems of loading without a pre-existing pref file

revision 1.2  2009/10/14 14:55:26  bwagner
Time Course mean centering and Paradigm Overlay

revision 1.1  2009/10/09 17:11:38  bwagner
PickAtlas Release Pre-Alpha 1
%}