function outStruct = wfu_voxelImageConversion(varargin)
% Wrapper function for private/voxelImageConversion
%   outStruct = wfu_voxelImageConversion(varargin)
%
%   Full Description:
%     
%
%   Inputs:
%     See private/voxelImageConversion
%
%   Outputs:
%     outStruct with fields MNI, voxel, image defining location in each
%     space
%
%   Example:
%     wfu_voxelImageConversion
%
%   See also
%     private/voxelImageConversion
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

  outStruct = voxelImageConversion(varargin{:});

%% Revision Log at end

%{
$Log: wfu_voxelImageConversion.m,v $
Revision 1.1  2010/08/30 18:46:22  bwagner
Updates required for SPM8 rev 4010

%}
