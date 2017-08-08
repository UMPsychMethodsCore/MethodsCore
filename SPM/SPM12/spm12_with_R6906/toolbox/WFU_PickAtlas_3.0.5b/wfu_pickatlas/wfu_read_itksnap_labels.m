function labelStruct = wfu_read_itksnap_labels(fname)
% Read in a lables file designed for ITKSnap
%   output = wfu_read_itksnap_labels(input)
%
%   Full Description:
%     
%
%   Inputs:
%     fname   [REUQIRED]  A ITKSnap formated labels structure
%
%   Outputs:
%     labelStruct         A structure (index based) containing RGB (0-225),
%                         Alpha (0-1), VIS - Label Visibility (bool), 
%                         MESH - Mesh Visibility (bool), and description
%
%   Example:
%     wfu_read_itksnap_labels
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

  if nargin ~= 1 || isempty(fname), WFU_LOG.fatal('Input Filename required'); end
  
  labelStruct=struct();
  
  fid=fopen(fname,'r');
  if fid < 0, WFU_LOG.fatal('Error reading %s',fname); end
  
  while true
    l = fgetl(fid);
    if ~ischar(l), break; end
    l = strtrim(l);
    if l(1)=='#', continue; end
    [IDK l]    =strtok(l);
    [R l]      =strtok(l);
    [G l]      =strtok(l);
    [B l]      =strtok(l);
    [ALPHA l]  =strtok(l);
    [VIS l]    =strtok(l);
    [MESH DESC]=strtok(l);
    
    IDK=  str2double(IDK);
    R=    str2double(R);
    G=    str2double(G);
    B=    str2double(B);
    ALPHA=str2double(ALPHA);
    VIS=  str2double(VIS);
    MESH= str2double(MESH);
    DESC(DESC=='"')=[];
    
    if any(isnan([IDK R G B ALPHA VIS MESH]))
      WFU_LOG.warn('unable to read line for lable: %s', DESC);
      continue;
    end

    if (IDK==0), continue; end  %0 is Clear Label
    
    labelStruct(IDK).RGB  =[R G B];
    labelStruct(IDK).ALPHA=ALPHA;
    labelStruct(IDK).VIS  =logical(VIS);
    labelStruct(IDK).MESH =logical(MESH);
    labelStruct(IDK).DESC =strtrim(DESC);
  end
  fclose(fid);
return

%% Revision Log at end

%{
$Log: wfu_read_itksnap_labels.m,v $
Revision 3.1  2014/01/31 20:08:47  bwagner
ITKSnap Button

%}
