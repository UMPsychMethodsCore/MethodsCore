function wfu_require_tbx_common
% wfu_require_tbx_common
%
% Function checks the path for wfu_tbx_common directory.  If not found it
% tries to add it.  Function errors out if tbx_common cannot be sourced.
%
% This file lives in the wfu_tbx_common directory, but should be copied
% back to the directory of the toolbox for which it is needed.
%
% Any changes should be ported back to the wfu_tbx_common directory
% version!!!
%__________________________________________________________________________
% Created: Jul 13, 2010 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.5 $

%
% In the repository, it is easier to make a LINK to
% /ansir2/WFU/repository/WFU/WFU_development/wfu_tbx_common/wfu_require_tbx_common.m,v
% in the correct working director of the repository rather than worry about
% copying about all the time!

%
% wfu_LOG may not exist BEFORE HAND!!!
%

global WFU_LOG;
if isempty(WFU_LOG)
  try
    WFU_LOG=wfu_LOG();
  end
end

try
  % minutia as oppsoed to info because it can be called 
  % NUMEROUS times in some mouse callbacks
  WFU_LOG.minutia('Entered function $Revision: 1.5 $');
end  

fileOnlyInCommonToolBox='wfu_check_nifti.m';

if exist(fileOnlyInCommonToolBox)==2
  return;
else
  tbx=which('wfu_pickatlas.m');
  if isempty(tbx)
    tbx=which('wfu_results_viewer.m');
  end
  if isempty(tbx)
    tbx=which('wfu_roi.m');
  end
  if isempty(tbx)
    tbx=which('wfu_require_tbx_common.m');
  end
  
  if isempty(tbx)
    msg='Unable to find a wfu toolbox to base wfu_tbx_common off of.  Please manually add to path.';
    try
      WFU_LOG.fatal(msg);
    catch
      error(msg);
    end
  end
  
	try
	  [p f e j] = fileparts(tbx); %removes wfu_pickatklas.m
	  [p f e j] = fileparts(p);   %removes wfu_pickatklas directory
	catch
	  [p f e j] = fileparts(tbx); %removes wfu_pickatklas.m
	  [p f e j] = fileparts(p);   %removes wfu_pickatklas directory
	end
  tbxPath=fullfile(p,'wfu_tbx_common');
  
  if exist(tbxPath,'dir')==7
    addpath(fullfile(p,'wfu_tbx_common'));
    if isempty(WFU_LOG)
      WFU_LOG=wfu_LOG();
    end
    WFU_LOG.info(sprintf('Added %s to path.\n',tbxPath));
  end
  
  if exist(fileOnlyInCommonToolBox)~=2
    msg=sprintf('Unable to add %s OR find %s which is in wfu_tbx_common\n',...
      fullfile(p,'wfu_tbx_common'),fileOnlyInCommonToolBox);
    try
      WFU_LOG.fatal(msg);
    catch
      error(msg);
    end
  end
end

%% Revision Log at end

%{
$Log: wfu_require_tbx_common.m,v $
Revision 1.5  2010/07/22 19:36:32  bwagner
changed enter WFU_LOG message to minutia level...too verbose

Revision 1.4  2010/07/19 20:22:26  bwagner
wfu_require_tbx_common.m

Revision 1.3  2010/07/13 20:27:54  bwagner
Change to using wfu_LOG.

revision 1.2	2009/10/23 18:08:44  bwagner
WFU_fcon added to path

revision 1.1  2009/10/09 17:11:38	 bwagner
PickAtlas Release Pre-Alpha 1
%}
