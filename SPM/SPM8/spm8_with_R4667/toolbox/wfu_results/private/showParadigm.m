function handles = showParadigm(handles)
% handles = showParadigm(handles)
%
% wfu_results_ui Internal Function
%
% prints the Paradigm on top of a TimeCourse on results axis
%
%__________________________________________________________________________
% Created: Dec 3, 2009 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.2 $

global WFU_LOG;
if isempty(WFU_LOG)
  WFU_LOG=wfu_LOG();
end
WFU_LOG.info('Entered function $Revision: 1.2 $');

  
if isfield(handles,'Results_Axis')
  paradigmPlot=get(handles.Results_Axis,'UserData');
  paradigmPlot=paradigmPlot(ishandle(paradigmPlot));
  try
    delete(paradigmPlot);
    set(handles.Results_Axis,'UserData',[]);
  end
end


if handles.data.preferences.paradigm
  handles.Options_Paradigm_Select=handles.Options_Paradigm_Select(ishandle(handles.Options_Paradigm_Select));
  selectedParadigm=find(strcmpi(get(handles.Options_Paradigm_Select,'Checked'),'on'));
  if isempty(selectedParadigm), selectedParadigm=1; end;
  if length(selectedParadigm) > 1, selectedParadigm=selectedParadigm(1); end;
  
  nVol=size(handles.data.SPM.Sess.row,2);
  pd=full(handles.data.SPM.Sess.U(selectedParadigm).u);
  divPerVol=size(pd,1)/nVol;
  x=[1:size(pd,1)]/divPerVol;
  %scale pd to graph
  gMax=max(get(handles.Results_Axis,'YTick'));
  gMin=min(get(handles.Results_Axis,'YTick'));
  gDis=gMax-gMin;
  gStepBack=1/4*gDis;
  %move to lower 1/8 of screen
  gStepBack=1/8*gStepBack;
  gMin=gMin+gStepBack;
  gMax=gMin+3*gStepBack;

  pd=pd-min(pd); % zero base pd
  pd=pd/max(pd); % normalize to 0to1;
  pd=pd*(gMax-gMin); %place in graph space
  pd=pd+gMin; %gMin base pd

  hold on;
  paradigmPlot=plot(x,pd,'r');
  hold off
  set(handles.Results_Axis,'UserData',[paradigmPlot get(handles.Results_Axis,'UserData')]);
end

%% Revision Log at end

%{
$Log: showParadigm.m,v $
Revision 1.2  2010/07/22 14:35:44  bwagner
Using WFU_LOG

revision 1.1  2009/12/03 16:00:30  bwagner
TC actual/mean and paradigm showing STICK in preferences.
%}
