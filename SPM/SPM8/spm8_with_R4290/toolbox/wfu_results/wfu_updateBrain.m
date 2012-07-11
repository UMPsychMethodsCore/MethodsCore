function handles = wfu_updateBrain(varargin)
% Wrapper function for private/updateBrain
%   handles = wfu_updateBrain(handles)
%
%   Description:
%     
%
%   Inputs:
%     handle structure from wfu_results_viewer
%
%   Outputs:
%     handle structure for wfu_results_viewer
%
%   Example:
%     wfu_updateBrain
%
%   See also
%     private/updateBrain
%__________________________________________________________________________
% Created: Aug 27, 2010 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.1 $

%% Program

  global WFU_LOG;
  if isempty(WFU_LOG)
    WFU_LOG=wfu_LOG();
  end
  WFU_LOG.info('Entered function $Revision: 1.1 $');

  handles = updateBrain(varargin{:});

%% Revision Log at end

%{
$Log: wfu_updateBrain.m,v $
Revision 1.1  2010/08/30 18:46:21  bwagner
Updates required for SPM8 rev 4010

%}
