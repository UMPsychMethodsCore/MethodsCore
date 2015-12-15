function wfu_resultsProgress(text,stepCount)
% wfu_resultsProgress(text,stepCount)
% wfu_resultsProgress(text,'timeonly')
%
% creates and displays a loading figure, with a progress bar composed of
% `stepCount` segments.
%
% wfu_resultsProgress('init',10) -> creates the figure with 10 segments
% wfu_resultsProgress('loading preferences') ->  changes text to loading
%                                                preferences and advances
%                                                a segment
% wfu_resultsProgress('done') -> closes window.
% wfu_resultsProgress('doneNOW') -> closes window.  NOW!
%
% Note: segment advances on the 2nd (and thereafter) text recieved after
% 'init'
%__________________________________________________________________________
% Created: Nov 9, 2010 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.5 $

  global WFU_LOG;
  if isempty(WFU_LOG)
    WFU_LOG=wfu_LOG();
  end
  
  persistent RESULTSPROGRESSFIGURE
  mlock;

  if isfield(RESULTSPROGRESSFIGURE,'fig') && ishandle(RESULTSPROGRESSFIGURE.fig)
    figure(RESULTSPROGRESSFIGURE.fig); %raise the figure
  end
  
  switch text
    case 'init'
      %cleanup old, if exist
      if isfield(RESULTSPROGRESSFIGURE,'fig') && ishandle(RESULTSPROGRESSFIGURE.fig)
        delete(RESULTSPROGRESSFIGURE.fig);
      end
      %create "loading figure"
      RESULTSPROGRESSFIGURE.fig = waitbar(0,'Initializing');
      RESULTSPROGRESSFIGURE.step=0;
      RESULTSPROGRESSFIGURE.segments=stepCount;
    case 'done'
      while RESULTSPROGRESSFIGURE.step < RESULTSPROGRESSFIGURE.segments
        wfu_resultsProgress('');
        pause(.1);
      end
      try, delete(RESULTSPROGRESSFIGURE.fig); end;
      clear RESULTSPROGRESSFIGURE;
      munlock;
    case 'doneNOW'
      try, delete(RESULTSPROGRESSFIGURE.fig); end;
      clear RESULTSPROGRESSFIGURE;
      munlock;
    otherwise
      WFU_LOG.info(text);
      if exist('stepCount','var')==1 && ~isempty(stepCount)
        if strcmpi(stepCount,'timeonly')
          warning('REMOVE REFERENCE TO wfu_resultsProgress(xxxx,''timeonly'')');
          return;
        end
      end
      if isempty(RESULTSPROGRESSFIGURE), return; end;
      RESULTSPROGRESSFIGURE.step=RESULTSPROGRESSFIGURE.step+1;
      if RESULTSPROGRESSFIGURE.step <= RESULTSPROGRESSFIGURE.segments
        RESULTSPROGRESSFIGURE.fig=waitbar(RESULTSPROGRESSFIGURE.step/RESULTSPROGRESSFIGURE.segments,RESULTSPROGRESSFIGURE.fig,text);
      else
        beep();
        WFU_LOG.error(sprintf('Please increase `init` of wfu_resultsProgress call to %d',RESULTSPROGRESSFIGURE.step));
      end
  end
return

%% Revision Log at end

%{
$Log: wfu_resultsProgress.m,v $
Revision 1.5  2010/07/28 17:29:44  bwagner
added doneNOW to end progress window NOWcvs -n -q update | grep ^M

Revision 1.4  2010/07/19 20:20:31  bwagner
WFU_LOG implementaiton chagnged.

revision 1.3  2010/07/09 13:35:57	 bwagner
Checkin before aHeader to iHeader Pickatlas code update

revision 1.2  2009/12/15 15:15:53	 bwagner
*** empty log message ***

revision 1.1  2009/10/09 17:11:38	 bwagner
PickAtlas Release Pre-Alpha 1
%}
