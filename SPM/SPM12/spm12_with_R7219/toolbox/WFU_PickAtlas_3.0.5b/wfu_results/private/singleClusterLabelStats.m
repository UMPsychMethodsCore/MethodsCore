function [handles table] = singleClusterLabelStats(handles,clusterIndex)
% handles = singleClusterLabelStats(handles,clusterIndex)
%
% wfu_results internal function
%
% Calculates assorted stats (num of voxels,...) for a cluster at `xyzmm` 
% and its labels.  Places into struct `stats`.
%__________________________________________________________________________
% Created: Nov 9, 2010 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.5 $

  global WFU_LOG;
  if isempty(WFU_LOG)
    WFU_LOG=wfu_LOG();
  end
  WFU_LOG.info('Entered function $Revision: 1.5 $');

  if ~isfield(handles.data,'atlasInfo')
    stats=struct();
    errordlg('Atlas infomation not loaded','Error!');
  end

  %A is cluster index for each voxel in XYZ
  A = handles.data.A; %from wfu_results_compute

  %j is voxels belonging with cluster at point xyzmm
  j=find(A.converted==clusterIndex);

  %shorten XYZ's to only those that belong to xyzmm's cluster
  clusterValues=handles.data.xSPM.Z(:,j);
  clusterVoxelCoords=handles.data.xSPM.XYZ(:,j);
  clusterMNICoords=handles.data.xSPM.XYZmm(:,j);
  
  %convert SPM to template space
%  templateCoords=voxelImageConversion(clusterMNICoords,handles.data.xSPM.M,handles.data.xSPM.DIM,'mni');
  
  templateCoords=voxelImageConversion(clusterMNICoords,handles.data.template.header.mat,handles.data.template.header.dim,'mni');
  templateIndex=sub2ind(size(handles.data.template.volume),templateCoords.voxel(1,:),templateCoords.voxel(2,:),templateCoords.voxel(3,:));


  table.max=max(clusterValues);
  table.mean=mean(clusterValues);
  table.std=std(clusterValues);
  table.voxels=size(clusterValues,2);

  mvi = find(clusterValues==table.max); %max value index
  table.peak=voxelImageConversion(clusterMNICoords(:,mvi),handles,'mni');
  

  table.headers={'Atlas','Region','Label','Voxels','mean T','std of T'};
  table.format= {'%s'   ,'%s'    ,'%s'   ,'%i'    ,'%.4f'  ,'%.4f'};
  
  selectedAtlases=unique(cell2mat(get(handles.groups.atlas,'Value')));
  selectedAtlases=selectedAtlases(selectedAtlases >=1 & selectedAtlases <= length(handles.data.atlasInfo));
  
  for h=1:length(selectedAtlases)  
    i=selectedAtlases(h);%i is atlasNumber
    unsortedOneAtlasData=[];
    sortedOneAtlasData=[];
    if strcmpi(strtrim(handles.data.atlasInfo(i).Name),'shapes'), continue; end;
    atlasIndex = handles.data.atlasInfo(i).Atlas(templateIndex);
    uniqueAtlasIndex = unique(atlasIndex);
    for j=1:length(uniqueAtlasIndex) %j is the index of the atlas region identifier in uniqueAtlasIndex
      for k=1:length(handles.data.atlasInfo(i).Region)  %k is region number
        regionIndex = find(handles.data.atlasInfo(i).Region(k).SubregionValues==uniqueAtlasIndex(j));
        if isempty(regionIndex), continue; end;
%regionName = char(WFU_RESULTS.atlasInfo(i).Region(k).SubregionNames(regionIndex));
%disp(sprintf('%s->%s->%s :: %i',char(WFU_RESULTS.atlasInfo(i).Name),char(WFU_RESULTS.atlasInfo(i).Region(k).RegionName),char(regionName),size(find(atlasIndex==uniqueAtlasIndex(j)),2)));
        voxelValues=clusterValues(find(atlasIndex==uniqueAtlasIndex(j)));
        for m=1:size(regionIndex,2)
          unsortedOneAtlasData=[unsortedOneAtlasData; i k regionIndex(m) size(find(atlasIndex==uniqueAtlasIndex(j)),2) mean(voxelValues) std(voxelValues)];
        end %end m
      end % end k
    end % end j
    if ~isempty(unsortedOneAtlasData), sortedOneAtlasData = sortrows(unsortedOneAtlasData,-4); end;
    if isfield(table,'data'), offset=size(table.data,1); else, offset=0; end;
    for a=1:size(sortedOneAtlasData,1)
      atlasName  = '';
      regionName = '';
      subregionName = '';
      voxels = '';
      if a==1 || sortedOneAtlasData(a-1,1) ~= sortedOneAtlasData(a,1)
        atlasName =  char(handles.data.atlasInfo(sortedOneAtlasData(a,1)).Name);
      end
      if a==1 || sortedOneAtlasData(a-1,2) ~= sortedOneAtlasData(a,2)
        regionName = char(handles.data.atlasInfo(sortedOneAtlasData(a,1)).Region(sortedOneAtlasData(a,2)).RegionName);
      end
      subregionName = char(handles.data.atlasInfo(sortedOneAtlasData(a,1)).Region(sortedOneAtlasData(a,2)).SubregionNames(sortedOneAtlasData(a,3)));

      table.data{a+offset,1}=atlasName;
      table.data{a+offset,2}=regionName;
      table.data{a+offset,3}=subregionName;
      table.data{a+offset,4}=sortedOneAtlasData(a,4); %number of voxels
      table.data{a+offset,5}=sortedOneAtlasData(a,5); %mean of voxels
      table.data{a+offset,6}=sortedOneAtlasData(a,6); %std
    end % end a
  end % end h
  
  
return


%% Revision Log at end

%{
$Log: singleClusterLabelStats.m,v $
Revision 1.5  2010/07/29 18:19:39  bwagner
fixed argument call of cluster not reporting correct cluster

Revision 1.4  2010/07/27 18:37:54  bwagner
WFU_LOG implemented.  Using cluster number instead of xyzmm for printing singleClusterLabelStats

revision 1.3  2010/07/26 20:07:45  bwagner
Conversion was happening to wrong space for templateCoords.  Fixed

revision 1.2  2010/07/22 14:37:04  bwagner
Allowed Up/Down flip.  Flip is now 2 element var with 1st being L/R and 2nd being U/D.  Allow secondary way of calling private/voxelImageConversion.


revision 1.1  2009/10/09 17:11:38  bwagner
PickAtlas Release Pre-Alpha 1
%}