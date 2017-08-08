function wfu_write_itksnap_labels(labelStruct,fname)
% Write out a lables file designed for ITKSnap
%   output = wfu_write_itksnap_labels(input)
%
%   Full Description:
%     
%
%   Inputs:
%     labelStruct   [REQUIRED]  See wfu_erad_itksnap for structure
%                               description.
%     fname         [REQUIRED]  File name to write to
%
%   Outputs:
%     None
%
%   Example:
%     wfu_write_itksnap_labels
%
%   See also
%
%__________________________________________________________________________
% Created: Jan 31, 2014 by bwagner
% Copyright (C) 2014 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 3.1 $

%% Program

  global WFU_LOG;
  if isempty(WFU_LOG) || ~isa(WFU_LOG,'wfu_LOG') || ~ismethod(WFU_LOG,'info')
    WFU_LOG=wfu_LOG();
  end
  WFU_LOG.info('Entered function $Revision: 3.1 $');

  if nargin ~= 2, WFU_LOG.fatal('Need 2 arguments'); end
  if isempty(labelStruct) || isempty(fname), WFU_LOG.fatal('Need 2 arguments, non-empty'); end
  if ~isstruct(labelStruct), WFU_LOG.fatal('labelStruct argument must be a structure'); end
  
  fid=fopen(fname,'w+');
  if fid < 0, WFU_LOG.fatal('Error writing %s',fname); end
  for a=0:length(labelStruct)
    if a==0
      RGB=   [0 0 0];
      ALPHA= 0;
      VIS=   0;
      MESH=  0;
      DESC=  'Clear Label';
    else
      if isempty(labelStruct(a).RGB) || isempty(labelStruct(a).DESC)
        continue;
      end
      RGB=   labelStruct(a).RGB;
      ALPHA= labelStruct(a).ALPHA;
      VIS=   labelStruct(a).VIS;
      MESH=  labelStruct(a).MESH;
      DESC=  labelStruct(a).DESC;
    end
    if ALPHA==1 || ALPHA==0
      fmt='  %3d  %3d %3d %3d       %d %d %d    "%s"\n';
    else
      fmt='  %3d  %3d %3d %3d       %f %d %d    "%s"\n';
    end
    fprintf(fid,fmt,a,RGB(1),RGB(2),RGB(3),ALPHA, VIS, MESH, DESC);
  end
  fclose(fid);
return

%% Revision Log at end

%{
$Log: wfu_write_itksnap_labels.m,v $
Revision 3.1  2014/01/31 20:08:47  bwagner
ITKSnap Button

%}
