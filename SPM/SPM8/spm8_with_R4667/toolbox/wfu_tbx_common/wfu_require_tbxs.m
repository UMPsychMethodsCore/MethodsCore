function wfu_require_tbxs(tbxs)
% wfu_require_tbxs(tbxs)
%
% checks path for a tbx(s) (assuming toolboxes have a function of the same
% name as the path).  If not found, it tries to add it, assuming the
% typical spm structure of toolboxes all under one directory.
%__________________________________________________________________________
% Created: Dec 15, 2010 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.2 $

  global WFU_LOG;
  if isempty(WFU_LOG)
    WFU_LOG=wfu_LOG();
  end
  WFU_LOG.info('Entered function $Revision: 1.2 $');

  if nargin < 1, return; end;
  if ischar(tbxs), tbxs=cellstr(tbxs); end;

  for i=1:length(tbxs)
    if exist(tbxs{i},'file')==2
      continue;
    else
      tbxPath=fileparts(which(mfilename)); %remove filename (wfu_require_tbxs.m)
      tbxPath=fileparts(tbxPath); %remove first path (wfu_tbx_common)
      potentialPath=fullfile(tbxPath,tbxs{i});
      if exist(potentialPath,'dir')==7
        WFU_LOG.info(sprintf('adding %s to path\n',potentialPath));
        addpath(potentialPath);
      else
        disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        disp('!!! Unable to find toolbox:   !!!');
        fprintf('!!! %-25s !!!\n',tbxs{i});
        disp('!!! Please add path manually. !!!');
        disp('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        WFU_LOG.fatal(sprintf('missing toolbox: %s',tbxs{i}));
      end
    end
  end
return
  
%% Revision Log at end

%{
$Log: wfu_require_tbxs.m,v $
Revision 1.2  2010/07/19 20:20:01  bwagner
WFU_LOG implemented.

revision 1.1  2009/12/15 15:15:53  bwagner
*** empty log message ***
%}