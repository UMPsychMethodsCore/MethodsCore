function [SPM TC]= loadSPM(handlesOrSPMmat)
% [SPM TC]= loadSPM(handlesOrSPMmat)
%
% wfu_results_ui Internal Function
%
% loads an SPM.mat file and time course info
% from handlesOrSPMmat as a file or if its a structure, from:
% handlesOrSPMmat.data.overlay.fnameOrig
%__________________________________________________________________________
% Created: Oct 9, 2009 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.8 $

  global WFU_LOG;
  if isempty(WFU_LOG)
    WFU_LOG=wfu_LOG();
  end
  WFU_LOG.info('Entered function $Revision: 1.8 $');


if isstruct(handlesOrSPMmat)
  SPMmat = handlesOrSPMmat.data.overlay.fnameOrig;
  handles= handlesOrSPMmat;
else
  SPMmat = handlesOrSPMmat;
  handles.showInfo=false;
end

SPM = load(SPMmat);
SPM = SPM.SPM; %oddity

[filePath jName jExt] = fileparts(SPMmat);
if ~strcmp(filePath,SPM.swd)
  swdToUse = questdlg(sprintf('SPM.swd and location of SPM.mat do not match.\n\nLeft Option is the path emmbed in SPM.mat.\nRight Option is th directory where the SPM.mat is located.\n'),...
              'swd directory mismatch',SPM.swd,filePath,SPM.swd);
  if isempty(swdToUse), WFU_LOG.fataldlg('SWD choice is empty'); end;
  SPM.swd=swdToUse;
end
  
cd(SPM.swd);

%Read TimeCourse
TC=[];
if ~isfield(SPM,'xBF') && ~isfield(SPM,'Sess') %2nd level, no timecourses
  response = 'no';
else
  response = questdlg(sprintf('Open %i time course volumes?',size(SPM.xY.P,1)),'Load time courses?','Yes','No','Yes');
end
if strcmpi(response,'yes')
  WFU_LOG.minutia('Reading Time Course Data...');
  fmriLoc=[];
 	[p f e]=fileparts(strtok(SPM.xY.P(1,:),','));
  if exist(fullfile(pwd,[f e]),'file')==2
    fmriLoc=pwd;
  end
  if isempty(fmriLoc) && exist(fullfile(p,[f e]),'file')==2
    WFU_LOG.minutia('fmri time series found at: %s',p);
    fmriLoc=p;
  end
  if isempty(fmriLoc)
    p=spm_select('CPath','../normalized',pwd); %ANSIR Lab normal location
    if exist(fullfile(p,[f e]),'file')==2
      fmriLoc=p;
    else
      fullP=spm_select(1,['^' f  e '$'],['Select 4D time course: ' f e],[],pwd);
      p=fileparts(fullP);
      fmriLoc=p;
    end
  end
  
  try
    for i=1:size(SPM.xY.P,1)
			[p n e]=fileparts(SPM.xY.P(i,:));
      newP{i}=fullfile(fmriLoc,[n e]);
    end
    SPM.xY.P=char(newP);
    WFU_LOG.info('Loading timecourse: %s',strtok(SPM.xY.P(1,:),','));
    TC=spm_read_vols(spm_vol(SPM.xY.P));
    WFU_LOG.minutia('Finished loading timerouse');
  catch
    try %SPM.xY.P may not exist
      WFU_LOG.warndlg(sprintf('Unable to read time course data from: %s\n',strtok(SPM.xY.P(1,:),',')));
    catch
      WFU_LOG.warndlg('Unable to read time course data.');
    end
  end
end


%% Revision Log at end

%{
$Log: loadSPM.m,v $
Revision 1.8  2015/02/23 14:05:56  fmri
removed try/catch fileparts mess

Revision 1.7  2011/10/10 16:54:06  bwagner
Matlab 2011b changes to fileparts

Revision 1.6  2010/08/16 17:47:51  bwagner
Changed message for TC loading to no have cancel.  Should not prompt for TC if 2nd level analysis

Revision 1.5  2010/07/29 18:17:47  bwagner
Fixed call of spm_select for 4D image

Revision 1.4  2010/07/22 14:33:31  bwagner
Using WFU_LOG more

revision 1.3  2010/07/19 19:57:45  bwagner
Added more to WFU_LOG

revision 1.2  2010/07/09 13:37:12  bwagner
Checkin before aHeader to iHeader Pickatlas code update

revision 1.1  2009/10/09 17:11:37  bwagner
PickAtlas Release Pre-Alpha 1

%}
