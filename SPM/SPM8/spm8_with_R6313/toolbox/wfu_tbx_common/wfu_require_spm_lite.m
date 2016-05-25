function wfu_require_spm_lite(acceptableSPMVersions)
% wfu_require_spm_lite
%
% Function checks the path for spm_vol.m  If not found it
% tries to add the spm_lite direcotry.  Function errors out if 
% wfu_require_spm_lite cannot be sourced.
%__________________________________________________________________________
% Created: Oct 9, 2009 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.3 $

global WFU_LOG;
if isempty(WFU_LOG)
  WFU_LOG=wfu_LOG();
end

if nargin < 1
  acceptableSPMVersions={};
  WFU_LOG.warn('Acceptable SPM versions set to {}');
end

spmVer=wfu_get_ver();
if isempty(spmVer)
  WFU_LOG.minutia(sprintf('SPM ver is: %s','empty'));
else
  WFU_LOG.minutia(sprintf('SPM ver is: %s',spmVer));
end

if ~isempty(spmVer) && ~any(strcmpi(spmVer,acceptableSPMVersions))
  disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
  disp('!!!!                            !!!!');
  disp('!!!!   POTENTIAL SPM CONFLICT   !!!!');
  disp('!!!!                            !!!!');
  disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
  disp([]);
  disp([]);
  WFU_LOG.fatal('Please remove %s from your path before using this tool.',spmVer);
  
end
if ~any(strcmpi(spmVer,acceptableSPMVersions))
  spmVolFile=which('spm_vol.m');
  if ~isempty(spmVolFile)
  	try
	    [p f e j]=fileparts(spmVolFile);
	    [p spmDir e j]=fileparts(p);
	  catch
	    [p f e]=fileparts(spmVolFile);
	    [p spmDir e]=fileparts(p);
	  end
    if strcmp(spmDir,'spm_lite')
      WFU_LOG.minutia(sprintf('Found spm_lite dir: %s',spmDir));
      return;
    end
  end

	try  
	  [tbxCommonPath f e j] = fileparts(mfilename('fullpath'));
	catch
	  [tbxCommonPath f e j] = fileparts(mfilename('fullpath'));
	end
  spmLitePath=fullfile(tbxCommonPath,'spm_lite');
  WFU_LOG.info(sprintf('Adding SPM_lite (%s) to top of path.',spmLitePath));
  addpath(spmLitePath,'-begin');
end

%% Revision Log at end

%{
$Log: wfu_require_spm_lite.m,v $
Revision 1.3  2010/07/22 15:41:21  bwagner
Cleaned up non-spm8 fatal call

Revision 1.2  2010/07/19 20:19:34  bwagner
WFU_LOG implemented.

revision 1.1  2009/10/09 17:11:38	 bwagner
PickAtlas Release Pre-Alpha 1
%}
