function handles = resultsClearSetDataFields(handles)
% handles = resultsClearSetDataFields(handles)
% 
% wfu_results_ui Internal Function
%
% Sets/Clears the default data anaylsis fields, such as when opening a file
%__________________________________________________________________________
% Created: Nov 9, 2010 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.2 $

  global WFU_LOG;
  if isempty(WFU_LOG)
    WFU_LOG=wfu_LOG();
  end
  WFU_LOG.info('Entered function $Revision: 1.2 $');

  handles.data.SPM=[];
  handles.data.xSPM=[];
  handles.data.mask.header=[];
  handles.data.mask.volume=[];
  handles.data.A.orig=[];
  handles.data.A.converted=[];
  handles.data.fused.header=[];
  handles.data.fused.volume=[];
  handles.data.tableData=[];
%  handles.data.slices=[];  %keep slices!!!  Anything in here will be
%  overwritten later.
  handles.data.TC=[];
  handles.data.overlay=struct('fname',[],'fnameOrig',[],'type',[]);
return

%{
$Log: resultsClearSetDataFields.m,v $
Revision 1.2  2010/07/22 14:35:14  bwagner
Using WFU_LOG

revision 1.1  2009/10/09 17:11:38  bwagner
PickAtlas Release Pre-Alpha 1
%}