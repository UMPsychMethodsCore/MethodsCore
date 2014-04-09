function handles = loadAtlas(handles,noEnable,noUpdateBrain)
% handles = loadAtlas(handles,noEnable)
%
% wfu_results internal function
%
% loads the atlas found in handles.data.atlas, then calls
% wfu_results_loadTemplate to setup the image
%
% noEnable is used in the initialization of the window
% so that the atlas buttons don't flash
%__________________________________________________________________________
% Created: Oct 9, 2009 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.3 $

  global WFU_LOG;
  if isempty(WFU_LOG)
    WFU_LOG=wfu_LOG();
  end
  WFU_LOG.info('Entered function $Revision: 1.3 $');

  if nargin < 2, noEnable=false; end;
  if nargin < 3, noUpdateBrain=false; end;

  wfu_resultsProgress('Loading Atlas Images & Data');

	if ~isfield(handles.data,'atlas'), return; end;
  paTbxFig=which('wfu_pickatlas.fig');
  if isempty(paTbxFig)
    WFU_LOG.fatal('Attempted to load PickAtlas atlas, but could not find PickAtlas');
  end
  paTbxPath=fileparts(paTbxFig);
	handles.data.template.header.fname=fullfile(paTbxPath, handles.data.atlas.subdir, handles.data.atlas.dispimage);
	atlasInfo = wfu_get_atlas_list(handles.data.atlas.subdir, handles.data.atlas.lookupfile, handles.data.atlas.dispimage);

  if isempty(atlasInfo)
    WFU_LOG.errordlg('ERROR loading atlas, defaulting to MNI template, no atlases');
    handles.data.atlas=struct([]);
    handles.data.template.header.fname=fullfile(handles.data.toolbox_path,'MNI_T1.nii');
  	handles = loadTemplate(handles,noUpdateBrain);
    return; 
  end;
  
	j=1;
  if isfield(handles.data,'atlasInfo')
    handles.data=rmfield(handles.data,'atlasInfo');
  end
	for i=1:size(atlasInfo,2)
    WFU_LOG.minutia(sprintf('%i is %s with value of %i',i,atlasInfo(i).Name,strcmpi(strtrim(atlasInfo(i).Name),'shapes')));
		if strcmpi(strtrim(atlasInfo(i).Name),'shapes'), continue; end;
		handles.data.atlasInfo(j)=atlasInfo(i);
		j=j+1;
	end
	atlasSelections=sprintf('%s|',handles.data.atlasInfo.Name);
%	atlasSelections=atlasSelections(1:end-1); % Remove trailling | in above sprintf
	%set defaults
	for i=1:3
    atlasGroupField=sprintf('Atlas_Group_%d',i);
		set(handles.(atlasGroupField),'Enable','off');
		if size(handles.data.atlasInfo,2) > i-1
			set(handles.(atlasGroupField),'String',atlasSelections);
			set(handles.(atlasGroupField),'Value',i);
      set(handles.(atlasGroupField),'Visible','on');
			if ~noEnable
        set(handles.(atlasGroupField),'Enable','on');
      end
			handles.data.activeAtlas(i)=true;
		else
			handles.data.activeAtlas(i)=false;
			set(handles.(atlasGroupField),'Value',1);
			set(handles.(atlasGroupField),'String','n/a');
      set(handles.(atlasGroupField),'Visible','off');
		end
  end
  
  %this should be cleared ahead of createSlices called in in loadTemplate
  %below
  handles.data.fused.volume=[];
  handles.data.fused.header=[];
	handles = loadTemplate(handles,noUpdateBrain);
return


%% Revision Log at end

%{
$Log: loadAtlas.m,v $
Revision 1.3  2010/07/19 19:56:21  bwagner
wfu_LOG implemented. Clear out atlasInfo on load to clean up drop down selection boxes

Revision 1.1  2010/07/13 12:13:38  bwagner
revision 1.2  2009/12/04 14:13:24  bwagner
Changed private/resultsProgress to wfu_resultsProgress in tbx_common

revision 1.1  2009/10/09 17:11:37  bwagner
PickAtlas Release Pre-Alpha 1
%}