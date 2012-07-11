function handles = loadSelect(handles)
% handles = loadSelect(handles)
% 
% wfu_results_ui Internal Function
%
% Allows user selection of an image, then passes to the appropirate load
% routine.
%
% overlay should be FULL PATH/FILENAME, when sent to load* routine.
%__________________________________________________________________________
% Created: Nov 9, 2010 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.5 $

  global WFU_LOG;
  if isempty(WFU_LOG)
    WFU_LOG=wfu_LOG();
  end
  WFU_LOG.info('Entered function $Revision: 1.5 $');

  if ~isfield(handles.data,'overlay'), handles.data.overlay=struct('fname',[],'fnameOrig',[]); end

  tmp = wfu_pickfile('imageAndSPM','Select a T, F, or Z image or an SPM.mat file');
  if isempty(tmp), return; end;
  if any(strcmp({handles.data.overlay.fname handles.data.overlay.fnameOrig},tmp)), return; end;
  
  set(handles.WFU_Results_Window,'Pointer','Watch');
  drawnow;
  
  handles = resultsClearSetDataFields(handles);  %this clears out overlay field
  overlay=handles.data.overlay;
  overlay.fnameOrig=tmp;

	try
  	[fPath fName fExt fJunk] = fileparts(overlay.fnameOrig);
  catch
  	[fPath fName fExt] = fileparts(overlay.fnameOrig);
  end
  
  if strcmpi(fExt,'.mat')  % as in SPM.mat
    WFU_LOG.minutia('Has mat extension, load as SPM');
    overlay.fname=overlay.fnameOrig;
    overlay.type='SPM';
    handles.data.overlay=overlay;
    [SPM TC] = loadSPM(handles);
    handles.data.TC = TC;
    handles.data.SPM=SPM;
    brainMask=fullfile(SPM.swd,SPM.VM.fname);
  else
  
    % Choose type from here...
    overlay.type = 'generic';
    overlay.fname = wfu_uncompress_nifti(overlay.fnameOrig);
    processType='';
    
    h=spm_vol(overlay.fname);
    fslRank=sum( [  any(strfind(h(1).descrip,'FSL')),...
                    any(strfind(fPath,'stats')),...
                    any(strfind(fPath,'feat')),...
                 ] );

    WFU_LOG.info(sprintf('fslRank: %d',fslRank));
    if (fslRank >= 2)
      btns={'Load as feat' 'Process as single Image'};
      res = questdlg('Image appears to be from an FSL feat directory.  Would you like to process it as a feat directory, gathering required variables from the feat directory, or process it as a generic image?',...
                     'Process as Feat or Generic Image',...
                     btns{1}, btns{2}, btns{1});
      switch (res)
        case btns{1}  
          processType='fsl';
        case btns{2}
          processType='generic';
        otherwise
          processType='generic';
      end
    end

    %simple check for AFNI
    [voxelOffset offsetSize additionalHeader] = wfu_read_nifti_voxel_offset(overlay.fname,'char');
    afniRank=sum( [ any(strfind(char(additionalHeader)','xml')),...
                    any(strfind(char(additionalHeader)','AFNI')),...
                    any(strfind(char(additionalHeader)','BRICK')),...
                    any(strfind(fName,'+tlrc')),...
                    any(strfind(fName,'+orig')),...
                  ] );

    WFU_LOG.info(sprintf('afniRank: %d',afniRank));
    if (afniRank >= 2)
      btns={'Load as AFNI' 'Process as single Image'};
      res = questdlg('Image appears to be from an AFNI study.  Would you like to process it as a AFNI functional bucket, gathering required variables from additial header information, or process it as a generic image?',...
                     'Process as Feat or Generic Image',...
                     btns{1}, btns{2}, btns{1});
      switch (res)
        case btns{1}  
          processType='afni';
        case btns{2}
          processType='generic';
        otherwise
          processType='generic';
      end
    end

    %return overlay to handles before processing
    handles.data.overlay=overlay;

    WFU_LOG.info(sprintf('processType: %s',processType));
    switch processType
      case 'fsl'
        handles.data.SPM = loadFSL(overlay.fnameOrig);
      case 'afni'
        handles.data.SPM = loadAFNI(overlay.fnameOrig);
      case 'generic'
        handles.data.SPM = loadGeneric(overlay.fnameOrig);
      otherwise
        handles.data.SPM = loadGeneric(overlay.fnameOrig);
    end
    brainMask=handles.data.SPM.VM.fnameOrig;
  end  %SPM/other split

  if exist(brainMask,'file') ~= 2
    beep();
    fprintf('WARNING: Whole brain mask file %s does not exist',brainMask);
    handles.data.mask.header=[];
    handles.data.mask.volume=[];
    handles.data.SPM=[];
  end
  
  handles.data.mask.header=spm_vol(wfu_uncompress_nifti(brainMask));
  handles.data.mask.header.fnameOrig=brainMask;

  handles.data.mask.volume=spm_read_vols(handles.data.mask.header);
  
  SPM = handles.data.SPM;  %make things easier to reference
  
  %setup a few buttons
  if size(SPM.xCon,2) > 1
    for i=1:size(SPM.xCon,2)
      if i==1
        listText = SPM.xCon(i).name;
      else
        listText=[listText '|' SPM.xCon(i).name];
      end
    end
    set(handles.Contrast_PopUpMenu,'Enable','on','BackgroundColor',[1 1 1],'String',listText);
  else
    set(handles.Contrast_PopUpMenu,'String',SPM.xCon(1).name,'BackgroundColor',[.8 .8 .8]);
  end
  set(handles.Contrast_PopUpMenu,'Value',1);

  if ~isempty(handles.data.TC)
    set(handles.Single_Cluster_TimeCourse,'Enable','on');
  else
    set(handles.Single_Cluster_TimeCourse,'Enable','off');
  end
  
  fitTextInField(overlay.fnameOrig,handles.Overlay_Edit);
  
  
  %Update Paradigm Fields, if found
  if isfield(SPM,'Sess') && isfield(SPM.Sess,'U')
    set(handles.Options_Paradigm,'Enable','on','Visible','on');
    set(handles.Options_Paradigm_Select_Parent,'Enable','on','Visible','on');
    if isfield(handles,'Options_Paradigm_Select')
      try
        delete(handles.Options_Paradigm_Select);
      catch ME
        WFU_LOG.infostack(ME);
      end
      handles.Options_Paradigm_Select=[];
    end
%{
    for i=1:length(SPM.Sess.U)
      handles.Options_Paradigm_Select(i)=uimenu(handles.Options_Paradigm_Select_Parent,...
                  'Label',char(SPM.Sess.U(i).name));
      %set callback afterwards, need to know handle
      set(handles.Options_Paradigm_Select(i),'Callback',...
          @(hObject,eventdata)wfu_results_viewer('Options_Paradigm_Select_Callback',hObject,eventdata,guidata(hObject)));
      if i==1
        set(handles.Options_Paradigm_Select(i),'Checked','on');
      end
    end
%}
  else
    set(handles.Options_Paradigm,'Enable','off','Visible','off');
    set(handles.Options_Paradigm_Select_Parent,'Enable','off','Visible','off');
  end
  
	set(gcf,'Pointer','Arrow');
  
return

%% Revision Log at end

%{
$Log: loadSelect.m,v $
Revision 1.5  2010/07/19 19:58:24  bwagner
Change to WFU_LOG call, also added stack on try/catch

Revision 1.4  2010/07/13 20:37:47  bwagner
Moving to wfu_LOG

revision 1.3  2010/07/09 13:37:12  bwagner
Checkin before aHeader to iHeader Pickatlas code update

revision 1.2  2009/10/14 16:00:16  bwagner
Updated Paradigm selection, it is not tied to contrasts

revision 1.1  2009/10/09 17:11:38	 bwagner
PickAtlas Release Pre-Alpha 1
%}
