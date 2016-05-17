function handles = timeCourse(handles)
% handles = timeCourse(handles)
%
% wfu_results_ui Internal Function
%
% prints the Time course to the results axis
%
  handles = clearResultsAxis(handles);

  [xyzmm i] = spm_XYZreg('NearestXYZ',handles.data.currPoss.MNI,handles.data.xSPM.XYZmm);
  
  if isempty(i)
    handles = clearResultsAxis(handles);
    handles.data.mouse.action='Single_Cluster_TimeCourse_Callback';
    return;
  end

  %use the template mat/dim below because we are drawing to the template, not
  %the xSPM.
  handles.data.currPoss=voxelImageConversion(xyzmm,handles,'MNI');
  handles=updateBrain(handles,true); %place where xyzmm is, which may have changed in spm_XYZreg

  set(handles.Brain_Slider,'Value',handles.data.currPoss.image(3));

  handles = clearResultsAxis(handles);
  set(handles.Results_Axis,'OuterPosition',[0 0 1 1]);
  set(handles.Results_Slider,'Enable','off');

  A=spm_clusters(handles.data.xSPM.XYZ);
  j=find(A==A(i));

  %shorten XYZ's to only those that belong to xyzmm's cluster
  clusterValues=handles.data.xSPM.Z(:,j);
  clusterCoords.voxel=handles.data.xSPM.XYZ(:,j);
  clusterCoords.MNI=handles.data.xSPM.XYZmm(:,j);

  %convert SPM to template space
  templateCoords=voxelImageConversion(clusterCoords.MNI,handles,'mni');

  %stats
  tc.maxValue=max(clusterValues);
%  tc.std=std(clusterValues);
  tc.voxels=length(clusterValues);
  mvi=find(clusterValues==tc.maxValue); %max value index
  tc.peak=voxelImageConversion(clusterCoords.MNI(:,mvi),handles.data.xSPM.M, handles.data.xSPM.DIM,'mni');

  %tc for peak
  tc.data.peak=squeeze(handles.data.TC(tc.peak.voxel(1),tc.peak.voxel(2),tc.peak.voxel(3),:));
  a=NaN([size(tc.data.peak,1) size(clusterCoords.voxel,2)]);
  for i=1:size(clusterCoords.voxel,2)
    a(:,i)=squeeze(handles.data.TC(clusterCoords.voxel(1,i),clusterCoords.voxel(2,i),clusterCoords.voxel(3,i),:));
  end
  tc.data.mean=mean(a,2);
  
  %Normization Corrections
  switch handles.data.preferences.TC
    case 0
      %do nothing
    case 1 %mean centered
%       normalMean=mean(tc.data.peak);
%       tc.data.peak=tc.data.peak/normalMean;
%       tc.data.mean=tc.data.mean/normalMean;
%         tmpDiv=tc.data.peak;
%         tc.data.peak=tc.data.peak./tmpDiv;
%         tc.data.mean=tc.data.mean./tmpDiv;
      nScans=size(tc.data.peak,1);
      tc.data.peak=tc.data.peak - ones(nScans,1)*mean(tc.data.peak);
      tc.data.mean=tc.data.mean - ones(nScans,1)*mean(tc.data.mean);
  end

  %save data in hadnles, then print
  handles.data.timeCourseData=tc;
  
  if size(clusterCoords.voxel,2)==1
    plot(1:size(tc.data.peak,1), tc.data.peak);
    legend('Single Voxel in Cluster');
  else
    plot(1:size(tc.data.peak,1), tc.data.peak, 1:size(tc.data.mean,1), tc.data.mean);
    legend('Peak Voxel','Mean of Voxels');
  end
  legend('boxoff');
  title(sprintf('Timecourse of cluster with peak at %g %g %g',tc.peak.MNI),...
    'FontSize',handles.data.fonts.FS(9),...
    'Fontweight','bold',...
    'ButtonDownFcn',[...
      'handles=guidata(gcf);',...
      'handles.data.currPoss = wfu_voxelImageConversion( [' num2str(tc.peak.MNI') '],handles,''MNI'');',...
      'handles=wfu_updateBrain(handles,true);',...
      'guidata(gcf,handles);'],...
    'Interruptible','off','BusyAction','Cancel')
  handles.data.mouse.action='Single_Cluster_TimeCourse_Callback';
  
  %paradigm showing (and quirkiness in checkbox)
  handles=showParadigm(handles);
  if handles.data.preferences.paradigm
    set(handles.Options_Paradigm,'Checked','on');
  else
    set(handles.Options_Paradigm,'Checked','off');
  end
return
