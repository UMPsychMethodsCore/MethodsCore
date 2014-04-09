function handles = loadTemplate(handles, noUpdateBrain)
% handles = loadTemplate(handles)
%
% wfu_results internal function
%
% loads the "template" or background image, generally defined in the
% handles.data.template.header.fname var that is generally set in loadAtlas from
% the selected atlas: fullfile(handles.data.toolbox_path,
% handles.data.atlas.subdir, handles.data.atlas.dispimage);
%__________________________________________________________________________
% Created: Oct 9, 2009 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.3 $

  global WFU_LOG;
  if isempty(WFU_LOG)
    WFU_LOG=wfu_LOG();
  end
  WFU_LOG.info('Entered function $Revision: 1.3 $');

  if nargin < 2, noUpdateBrain=false; end;

  wfu_resultsProgress('Setting Background Image');
  
  brainGroup =get(handles.Brain_Panel,'Children');
  set(brainGroup,'Visible','off');

  if ~isfield(handles.data,'template'), return; end;
  if ~isfield(handles.data.template,'header'), return; end;
  if  isempty(handles.data.template.header.fname), return; end;
  
  %for shorter vars
  template=handles.data.template;
  
  templateOrigName=template.header.fname;
  template.header=spm_vol(wfu_uncompress_nifti(templateOrigName));
  template.header.fnameOrig=templateOrigName;
  template.volume=spm_read_vols(template.header);
  
  %fit brain volume to colormap
  template.volume=template.volume/max(template.volume(:))*size(handles.data.colormaps.brain,1);
  
  %reconstruct handles, template is only used for reading past this point
  handles.data.template=template;

  %preslice volume into images, for faster display
  handles = createSlices(handles);

  %set the brain panels parameters
  imat = inv(template.header.mat);
  handles.data.currPoss = voxelImageConversion(imat(13:15),handles,'voxel');
  
  set(handles.Brain_Slider, 'Min',1,...
                            'Max',template.header.dim(3),...
                            'SliderStep',[1/template.header.dim(3) (min([1/template.header.dim(3) .05]) * 10) ]);
  set(handles.Brain_Axis,'XLim',[1 template.header.dim(1)],...
          'YLim',[1 template.header.dim(2)],...
          'TickLength', [0 0],...
          'Xcolor','black',...
          'Ycolor','black',...
          'XTickLabel',{''},...
          'YTickLabel',{''},...
          'Color','Black',...
          'XLimMode','manual',...
          'YLimMode','manual',...
          'ZLimMode','manual',...
          'CLimMode','manual',...
          'AlimMode','manual');

  set(brainGroup,'Visible','on');
  
  if ~noUpdateBrain
    updateBrain(handles);
  end
  
return
  
  

%% Revision Log at end

%{
$Log: loadTemplate.m,v $
Revision 1.3  2010/07/22 14:34:55  bwagner
Allowed Up/Down flip.  Flip is now 2 element var with 1st being L/R and 2nd being U/D.  Allow secondary way of calling private/voxelImageConversion.

revision 1.2  2009/12/04 14:13:24  bwagner
Changed private/resultsProgress to wfu_resultsProgress in tbx_common

revision 1.1  2009/10/09 17:11:37  bwagner
PickAtlas Release Pre-Alpha 1
%}