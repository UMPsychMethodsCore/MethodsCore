function [handles matfile] = load_saved_results_session(handles)
% handles = load_saved_results_session(handles)
%
% Load a previous wfu_results session
%
% WFU_results internal function
%
  matfile=wfu_pickfile('mat');
  if isempty(matfile), return; end;
  
  t=load(matfile);
  handles.data=t.savedata;

  % UPDATE THE BUTTONS, FIELDS, etc
  
  %Atlases
  tmpString='';
  for i=1:length(handles.data.atlasInfo);
    tmpString=[tmpString, handles.data.atlasInfo(i).Name, '|'];
  end
  set(handles.groups.atlas,'String',tmpString);
  for i=1:length(handles.data.activeAtlas)
    eval(sprintf('set(handles.Atlas_Group_%d,''Value'',%d)',i,handles.data.activeAtlas(i)));
  end
  
  %SPMmat text
  if isfield(handles.data, 'overlay') && isfield(handles.data.overlay,'fnameOrig')
    fitTextInField(handles.data.overlay.fnameOrig,handles.Overlay_Edit);
  end
  
  %Contrast
  if isfield(handles.data,'SPM') && isfield(handles.data.SPM,'xCon')
    tmpString='';
    for i=1:length(handles.data.SPM.xCon);
      tmpString=[tmpString, handles.data.SPM.xCon(i).name, '|'];
    end
    if length(tmpString), tmpString=tmpString(1:end-1); end;
    set(handles.Contrast_PopUpMenu,'String',tmpString);
    set(handles.Contrast_PopUpMenu,'Value',handles.data.conspec.contrasts);
  end
    
  %ROI
  % ROI.header only (no volume) comes from file
  % ROI.header and ROI.volume comes from PA
  if ~isempty(handles.data.ROI.header.fname) 
    if isempty(handles.data.ROI.volume)
      %from saved file
     	[fp fn fe] = fileparts(handles.data.ROI.header.fnameOrig);
      set(handles.ROI_PopUpMenu,'String',{'None','From PickAtlas',sprintf('From File: %s',[fn fe])});
      set(handles.ROI_PopUpMenu,'Value',3)
    else
      %from pickatlas
      btns={'Use mask and save','Use mask','Use mask from PickAtlas'};
      paFig=wfu_findFigure('WFU_PickAtlas');
      if length(paFig)==1
        questString='This session has a ROI mask from PickAtlas that does not match the mask currently in PickAtlas.  You may wish to save this mask for later use.';
        questTitle='Session contains an ROI from PickAtlas';
        paHandles=guidata(paFig);
        if isfield(paHandles.data,'Mask') && ~isequal(handles.data.ROI.volume,paHandles.data.Mask)
          resp = questdlg(questString,questTitle,btns{1},btns{2},btns{3},btns{1});
        else
          resp = questdlg(questString,questTitle,btns{1},btns{2},btns{1});
        end
      else
        questString='This session has a ROI mask from PickAtlas.  You may wish to save this mask for later use.';
        questTitle='Session contains an ROI from PickAtlas';
        resp = questdlg(questString,questTitle,btns{1},btns{2},btns{1});
      end

      switch resp
        case btns{1} % Use mask and save
          roiFile=uiputfile({'*.nii';'*.img'},'Save as');
          if roiFile~=0
            %save mask as roiFile
            handles.data.ROI.header.fname=roiFile;
            handles.data.ROI.header.fnameOrig=roiFile;
            spm_write_vol(handles.data.ROI.header,handles.data.ROI.volume);
           	[fp fn fe] = fileparts(roiFile);
            set(handles.ROI_PopUpMenu,'String',{'None','From PickAtlas',sprintf('From File: %s',[fn fe])});
            set(handles.ROI_PopUpMenu,'Value',3)
          else
            %save mask as tempfile
            handles.data.ROI.header.fname=handles.data.tempfile.ROI;
            handles.data.ROI.header.fnameOrig=handles.data.tempfile.ROI;
            spm_write_vol(handles.data.ROI.header,handles.data.ROI.volume);
            set(handles.ROI_PopUpMenu,'String',{'None','From PickAtlas','From File'});
            set(handles.ROI_PopUpMenu,'Value',2)
          end
        case btns{2} % Use mask && save mask as tempfile
          handles.data.ROI.header.fname=handles.data.tempfiles.ROI;
          handles.data.ROI.header.fnameOrig=handles.data.tempfiles.ROI;
          spm_write_vol(handles.data.ROI.header,handles.data.ROI.volume);
          set(handles.ROI_PopUpMenu,'String',{'None','From PickAtlas','From File'});
          set(handles.ROI_PopUpMenu,'Value',2)
        case btns{3} % Use mask from PickAtlas  && save mask as tempfile
          handles.data.ROI.volume=paHandles.data.Mask;
          handles.data.ROI.header.fname=handles.data.tempfiles.ROI;
          handles.data.ROI.header.fnameOrig=handles.data.ROI.header.fname;
          handles.data.ROI.header.dim=[paHandles.data.aheader.x_dim.value paHandles.data.aheader.y_dim.value paHandles.data.aheader.z_dim.value];
          handles.data.ROI.header.dt=[2 0];
          handles.data.ROI.header.pinfo=[1;0;0];
          handles.data.ROI.header.mat=paHandles.data.aheader.magnet_transform.value;
          spm_write_vol(handles.data.ROI.header,handles.data.ROI.volume);
          set(handles.ROI_PopUpMenu,'Value',2)
        otherwise
      end
    end
  end
  
  if exist(handles.data.ROI.header.fname,'file') == 2
    P={handles.data.template.header.fname,handles.data.ROI.header.fname};
    spm_reslice(P);
   	[fp fn fe] = fileparts(handles.data.ROI.header.fname);
    handles.data.roi_mask.header=spm_vol(fullfile(fp,['r' fn fe]));
    handles.data.roi_mask.header.fnameOrig=handles.data.ROI.header.fname;
    handles.data.roi_mask.volume=spm_read_vols(handles.data.roi_mask.header);
  else
    beep();
    warning('MASK FILE DOES NOT EXIST, REMOVING FROM SESSION');
    handles.data.ROI.header=struct('fname',[],'fnameOrig',[]);
    handles.data.ROI.volume=[];
    handles.data.roi_mask.header=struct('fname',[],'fnameOrig',[]);
    handles.data.roi_mask.volume=[];
  end
    
  set(handles.Show_ROI,'Value',0);
  if isempty(handles.data.roi_mask.volume)
    set(handles.Show_ROI,'Visible','off');
  else
    set(handles.Show_ROI,'Visible','on');
  end

  %Correction
  set(handles.groups.correction,'Value',0);
  switch upper(handles.data.conspec.threshdesc)
    case('FWE'), set(handles.Correction_FWE,'Value',1);
    case('FDR'), set(handles.Correction_FDR,'Value',1);
    otherwise, set(handles.Correction_None,'Value',1);
  end
  
  %Threshold
  set(handles.Threshold_Edit,'String',num2str(handles.data.conspec.thresh));
  if isfield(handles.data,'xSPM') && isfield(handles.data.xSPM,'u')
    set(handles.Threshold_Status,'String',sprintf('T (unc) = %0.3f',handles.data.xSPM.u));
  else
    set(handles.Threshold_Status,'String','');
  end
  
  %Extent
  set(handles.Extent_Edit,'String',num2str(handles.data.conspec.extent))
  
  %Report buttons
  set(handles.groups.reports,'Value',0);
  if ~isempty(handles.data.mouse.action)
    switch handles.data.mouse.action
      case 'Single_Cluster_Stats_Callback'
        set(handles.Single_Cluster_Stats,'Value',1);
      case 'Whole_Brain_Labels_Callback'
        set(handles.Whole_Brain_Labels,'Value',1);
      case 'Single_Cluster_Labels_Callback'
        set(handles.Single_Cluster_Labels,'Value',1);
      case 'Single_Cluster_TimeCourse_Callback'
        set(handles.Single_Cluster_TimeCourse,'Value');
      otherwise
        set(handles.Whole_Brain_Stats,'Value',1)
    end
  end
  
  %update brain image, WITHOUT MASK OVERLAY.
  handles = createSlices(handles);
  handles = updateBrain(handles);
return;
