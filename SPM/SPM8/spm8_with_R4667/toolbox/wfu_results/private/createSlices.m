function handles = createSlices(handles,optVolume)
% handles = createSlices(handles,volume)
%
% wfu_results internal function
%
% optVolume is OPTIONAL.  If present, this volume will be used to create
% slices, but will not affect the fused or template data structure.  For
% example, when called from the "Show ROI button".
%
% creates slices a volume (in Z direction) and places in
% handles.data.slices.  volume will be handles.data.template.volume if
% handles.data.fused.volume doesn't exist
% 
% handles.data.template.volume and handles.data.template.header should be
% populated before this call is ever made.
%__________________________________________________________________________
% Created: Oct 9, 2009 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.2 $

  global WFU_LOG;
  if isempty(WFU_LOG)
    WFU_LOG=wfu_LOG();
  end
  WFU_LOG.info('Entered function $Revision: 1.2 $');

  if isfield(handles.data,'slices'), handles.data.slices=[]; end;

  if nargin > 1
    volume=optVolume;
  elseif isfield(handles.data,'fused') && isfield(handles.data.fused,'volume') && ~isempty(handles.data.fused.volume)
    volume=handles.data.fused.volume;
  elseif ~isempty(handles.data.template.volume)
    volume=handles.data.template.volume;
  else
    WFU_LOG.error('Unable to decided on volume to slice.');
  end

  if xor(handles.data.preferences.flip(1), handles.data.template.header.mat(1) < 0)
    volume = flipdim(volume,1);
  end
  
  if handles.data.preferences.flip(2) == 1 %down is 1
    volume = flipdim(volume,2);
  end;
  
  for i=1:handles.data.template.header.dim(3)
    slice = volume(:,:,i);
    slice = rot90(slice);
    handles.data.slices(i).image=uint8(slice);
  end
  
return

%{
$Log: createSlices.m,v $
Revision 1.2  2010/07/22 14:32:45  bwagner
Allowed Up/Down flip.  Flip is now 2 element var with 1st being L/R and 2nd being U/D

revision 1.1  2009/10/09 17:11:37  bwagner
PickAtlas Release Pre-Alpha 1
%}