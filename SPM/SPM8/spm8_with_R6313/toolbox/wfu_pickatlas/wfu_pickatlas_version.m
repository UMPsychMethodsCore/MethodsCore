function output = wfu_pickatlas_version()
% WFU_PICKATLAS_VERSION  Report the current PickAtlas version
%   output = wfu_pickatlas_version(input)
%
%   Description:
%     Report the current PickAtlas version
%
%   Inputs:
%     none
%
%   Outputs:
%     string
%
%   Example:
%     wfu_pickatlas_version
%
%   See also
%
%__________________________________________________________________________
% Created: Jul 27, 2010 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.4 $

%% Program

  global WFU_LOG;
  if isempty(WFU_LOG)
    WFU_LOG=wfu_LOG();
  end
  WFU_LOG.info('Entered function $Revision: 1.4 $');

  output = '3.0.4';

%% Revision Log at end

%{
$Log: wfu_pickatlas_version.m,v $
Revision 1.4  2010/08/31 20:08:03  bwagner
Bug fixes. Bump ver to 3.0.3

Revision 1.3  2010/08/30 19:53:36  bwagner
updated to version 3.0.2

Revision 1.2  2010/08/18 15:50:23  bwagner
Updated to 3.0.1

Revision 1.1  2010/07/27 15:36:48  bwagner
Added wfu_pickatlas_version.  PickAtlas gets version info from this script. Added Help menu (About/About Atlas) to viewer.

%}
