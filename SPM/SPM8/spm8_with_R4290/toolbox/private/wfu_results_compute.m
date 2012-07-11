function handles = wfu_results_compute(handles)
% handles = wfu_results_compute(handles)
%
% wfu_results internal function
%
% reads the settins from the wfu_results screen given in handles and
% computes the activation map, then updates the image on screen.
%__________________________________________________________________________
% Created: Nov 9, 2010 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.7 $
  
  global WFU_LOG;
  if isempty(WFU_LOG)
    WFU_LOG=wfu_LOG();
  end
  WFU_LOG.info('Entered function $Revision: 1.7 $');
  
  set(handles.WFU_Results_Window,'Pointer','Watch');
  set(handles.Threshold_Status,'String','Please wait...');
  wfu_resultsProgress('init',10);
  wfu_resultsProgress('Initializing Calculations');
  
  % get settings for calculations from gui
  % --------------------------------------
  if isempty(handles.data.conspec.extent) || isempty(handles.data.conspec.thresh)
    return;
  end
  
  %setup the mask
  switch get(handles.ROI_PopUpMenu,'Value')
    case 1 %None
      %do nothing.
    case 2 %From PickAtlas
      %if pa is active, check that it matchs active PA's
      handles.data.paHandle = wfu_findFigure('WFU_PickAtlas');
      if ~isempty(handles.data.paHandle)
        paData=guidata(handles.data.paHandle);
        if ~isequal(handles.data.ROI.volume,paData.data.Mask)
          btns={'Yes','No'};
          response = questdlg('PickAtlas Mask has changed since the thast computation, update?','Masked Changed',btns{1},btns{2},btns{1});
          if strcmp(response,btns{1})
            h.fname=handles.data.tempfiles.ROI;
            h.dim=size(paData.data.Mask);
            h.dt=[2 0];
            h.mat=paData.data.iheader.mat;
            h.pinfo=[1; 0; 0];
            spm_write_vol(h,uint8(paData.data.Mask));
            
            handles.data.ROI.header=spm_vol(h.fname);
            handles.data.ROI.header.fnameOrig=h.fname;
            handles.data.ROI.volume=spm_read_vols(handles.data.ROI.header);
          end
        end
      end
    case 3 %From File
      %do nothing
  end
  
  % calculate
  % --------------------------------------
  
  wfu_resultsProgress('Preparing Mask');
	try 
		spm('CheckModality');
	catch
		WFU_LOG.minutia('Setting spm_lite defaults');
		spm('Defaults','FMRI');
  end

  %rename internal variables for easier workings
  SPM=handles.data.SPM;
  
  try, cd(SPM.swd); end;
  
  %-Compute Z's
  %-----------------------------------------------------------------------
  Z         = Inf;
  for i     = handles.data.conspec.contrasts
    Z = min(Z,spm_get_data(SPM.xCon(i).Vspm,SPM.xVol.XYZ));
  end
  
  
  xX   = SPM.xX;              %-Design definition structure
  XYZ  = SPM.xVol.XYZ;        %-XYZ coordinates
  M    = SPM.xVol.M(1:3,1:3);	%-voxels to mm matrix
  FWHM = SPM.xVol.FWHM;
  spmVOX  = sqrt(diag(M'*M))';		%-voxel dimensions
  
  
  if isempty(handles.data.ROI.header.fname)
    if strcmpi(handles.data.overlay.type,'SPM')
      Msk=[];
    else
      if isempty(handles.data.mask.header.fname), error('No Whole Brain mask definded'); end;
      Msk = handles.data.mask.header.fname;
    end
  else
    Msk = handles.data.ROI.header.fname;
  end
  
%   wfu_resultsProgress('Reslcing Mask');
%   P = {SPM.xCon(i).Vspm.fname,Msk};
%   
%   flags.mean=0;
%   flags.hold = 0;
%   flags.which=1;
%   flags.mask=0;
% 
%   spm_reslice(P,flags);
% 
%   Msk=prepend(Msk,'r');
  
%   wfu_resultsProgress('Create xSPM structure');
% 	WFU_LOG.minutia('creating xSPM');  
%   %compute with mask
%   XYZmm = SPM.xVol.M(1:3,:)*[XYZ; ones(1,size(XYZ,2))];
%   D     = spm_vol(Msk);
%   VOX   = sqrt(sum(D.mat(1:3,1:3).^2));
%   FWHM  = FWHM.*(spmVOX./VOX);
%   XYZ   = D.mat \ [     XYZmm; ones(1, size(    XYZmm, 2))];
%   j     = find(spm_sample_vol(D, XYZ(1,:), XYZ(2,:), XYZ(3,:),0) > 0);
%   k     = find(spm_sample_vol(D, XYZ(1,:), XYZ(2,:), XYZ(3,:),0) > 0);
%   
%   XYZ=round(XYZ(1:3,:));  %cleanup for odd data (spm_clusters requires ints, for ex).
%   if any(XYZ(:) < 1) || ...
%       any(XYZ(1,:) > SPM.xVol.DIM(1)) ||...
%       any(XYZ(2,:) > SPM.xVol.DIM(2)) ||...
%       any(XYZ(3,:) > SPM.xVol.DIM(3))
%     WFU_LOG.fataldlg('Mask space transformation failled.  Possible Mask and Overlay are not in the same "space" (ex: normalized v/s native).',...
%       'XYZ outside SPM.xVol.DIM bounds');
%   end
%   
%   %basic xSPM structure:
%   xSPM.Zum        = Z;
%   xSPM.df         = [SPM.xCon(handles.data.conspec.contrasts).eidf SPM.xX.erdf];
%   xSPM.STAT       = SPM.xCon(handles.data.conspec.contrasts).STAT;
%   xSPM.DIM        = SPM.xVol.DIM;
%   xSPM.n          = 1; %no doing anything more than simple masking
% %  xSPM.u          = %?????? (gets in wfu_ROI)
%   xSPM.S          = SPM.xVol.S;
%   xSPM.XYZ        = XYZ;
% %  xSPM.Ps         = %?????? (gets in wfu_ROI)
%   xSPM.Im         = [];  %no "image mask"
%   xSPM.uum        = handles.data.conspec.thresh;
%   xSPM.thresType  = handles.data.conspec.threshdesc;
%   xSPM.k          = handles.data.conspec.extent;
%   xSPM.M          = SPM.xVol.M;
%   xSPM.FWHM       = FWHM;
%   xSPM.VOX        = VOX;
%   
%   WFU_LOG.minutia('wfu_ROI')
%   wfu_resultsProgress('Calculating');
%   try
%     if isempty(handles.data.ROI.header.fname)
%       xSPM=wfu_ROI('calculate', SPM, xSPM, XYZ, j, k, FWHM);
%     else
%       xSPM=wfu_ROI('calculate', SPM, xSPM, XYZ(:,k), j, k, FWHM, D);
%     end
%   catch ME
%     wfu_resultsProgress('doneNOW');
%     set(handles.WFU_Results_Window,'Pointer','Arrow');
%     set(handles.Threshold_Status,'String','ERROR');
%     msg=sprintf('Error calculating:\n%s\n%s:%d',ME.message,ME.stack(1).name,ME.stack(1).line);
%     WFU_LOG.errordlg(msg);
%     ME.rethrow();
%   end

% xSPM      - structure containing SPM, distribution & filtering details
% .swd      - SPM working directory - directory containing current SPM.mat
% .title    - title for comparison (string)
% .Ic       - indices of contrasts (in SPM.xCon)
% .n        - conjunction number <= number of contrasts
% .Im       - indices of masking contrasts (in xCon)
% .pm       - p-value for masking (uncorrected)
% .Ex       - flag for exclusive or inclusive masking
% .u        - height threshold
% .k        - extent threshold {voxels}
% .thresDesc - description of height threshold (string)
  wfu_resultsProgress('Create xSPM structure');
  try 
    xSPM.swd=SPM.swd; 
  catch
    %wfu_spm_getSPM requires these fields
    SPM.swd=pwd;
    xSPM.swd=pwd;
  end;
  xSPM.title='WFU PickAtlas Results Viewer';
  xSPM.Ic=handles.data.conspec.contrasts;
  xSPM.n=1; %simple masking
  xSPM.Im=[];
  %   xSPM.pm=
  xSPM.Ex=0; %only those results found in mask
  xSPM.u=handles.data.conspec.thresh;
  xSPM.k=handles.data.conspec.extent;
  xSPM.thresDesc=handles.data.conspec.threshdesc;
  xSPM.roi=Msk;
  
  [SPM xSPM]=wfu_spm_getSPM(xSPM,SPM);
  
  if isempty(xSPM) || isempty(xSPM.Z)
    wfu_resultsProgress('doneNOW');
%    handles.data.SPM=SPM;
    handles.data.xSPM=xSPM;
    WFU_LOG.warndlg('No voxels survive thresholding.');
    handles.data.fused.volume=[];
    handles=createSlices(handles);
    set(handles.WFU_Results_Window,'Pointer','Arrow');
    try
      set(handles.Threshold_Status,'String',sprintf('T (unc) = %.3f',handles.data.xSPM.u));
    catch
      set(handles.Threshold_Status,'String','');
    end
    return
  end

  WFU_LOG.minutia('creating filtered header');  
  wfu_resultsProgress('Creating Filtered Image');
	% from spm_write_filtered.m v.168 (modified)
	V = struct(...
		'fname',	handles.data.tempfiles.results,...
		'dim',		xSPM.DIM',...
		'dt',		[spm_type('uint8') spm_platform('bigend')],...
		'mat',		xSPM.M,...
		'descrip', 	'SPM filtered results');

	%-Reconstruct (filtered) image from XYZ & Z pointlist  (OFF is voxel OFFset)
	%-----------------------------------------------------------------------
	Y      = zeros(xSPM.DIM(1:3)');
	OFF    = xSPM.XYZ(1,:) + xSPM.DIM(1)*(xSPM.XYZ(2,:)-1 + xSPM.DIM(2)*(xSPM.XYZ(3,:)-1));
	Y(OFF) = xSPM.Z.*(xSPM.Z > 0);
	
  WFU_LOG.minutia('creating filtered img');	
	%-Write the reconstructed volume
	%-----------------------------------------------------------------------
	V = spm_write_vol(V,Y);
  
  WFU_LOG.minutia('reslice');
  wfu_resultsProgress('Reslice Filtered Image to Template');
	P = {handles.data.template.header.fname; V.fname};
	spm_reslice(P);
	try
		[r_path r_name r_ext junk]=fileparts(V.fname);
	catch
		[r_path r_name r_ext]=fileparts(V.fname);
	end
	reslicedName = [r_path filesep 'r' r_name r_ext];
  
  WFU_LOG.minutia('read resliced');
  wfu_resultsProgress('Reading New Filtered Image');
	V = spm_vol(reslicedName);
	overlayVolume = spm_read_vols(V);
	handles.data.overlay.header=V;
	handles.data.overlay.volume=overlayVolume;
	
	if size(overlayVolume) ~= size(handles.data.overlay.volume)
		size(overlayVolume)
		size(handes.data.overlay.volume)
		WFU_LOG.error('Size mismatch between resliced volume and template');
	end
	
	overlayVolume = overlayVolume - min(overlayVolume(:)); % make 0 the lowest point
	overlayVolume = overlayVolume/max(overlayVolume(:))*size(handles.data.colormaps.overlay,1); %place in contect of the colormap
	activeVoxels = find(overlayVolume);
	
	handles.data.fused.volume=handles.data.template.volume;
	handles.data.fused.volume(activeVoxels)=overlayVolume(activeVoxels)+ size(handles.data.colormaps.brain,1);
	handles.data.fused.volume=uint8(handles.data.fused.volume);

	
  WFU_LOG.minutia('wfu_spm_list')
  wfu_resultsProgress('Generating Statistics Table');
  handles.data.tableData = wfu_list('list',xSPM,[],[],[],[],handles.data.currPoss.MNI');
	try
		handles.data.A.orig = spm_clusters(xSPM.XYZ);
		handles.data.A.converted = zeros(size(handles.data.A.orig));
		j=1;
		for i=1:size(handles.data.tableData.dat,1)
			if ~isempty(handles.data.tableData.dat{i,3})
				[xyzmm index] = spm_XYZreg('NearestXYZ',handles.data.tableData.dat{i,12}',xSPM.XYZmm);
				handles.data.A.converted(handles.data.A.orig == handles.data.A.orig(index)) = j;
        %handles.data.A.orig(index)
        %A.converted is the order in which the clusters appear on the spm_list
				j=j+1;
			end
		end
  catch
    WFU_LOG.error('caught error for A''s :( ');
		handles.data.A.orig = [];
		handles.data.A.converted = [];
  end
  
  
  % update gui
  % --------------------------------------
%  handles.data.SPM=SPM;
  handles.data.xSPM=xSPM;
  
  handles=createSlices(handles);
%  handles=updateBrain(handles,true);
  
  wfu_resultsProgress('Update Results View Based on Action Button.');
  if get(handles.Whole_Brain_Stats,'Value')
    handles=printResultsTable(handles,handles.data.tableData);
  elseif get(handles.Single_Cluster_Stats,'Value')
    feval('wfu_results_viewer','Single_Cluster_Stats_Callback',handles.Single_Cluster_Stats,[],handles);
  elseif get(handles.Whole_Brain_Labels,'Value')
    feval('wfu_results_viewer','Whole_Brain_Labels_Callback',handles.Whole_Brain_Labels,[],handles);
  elseif get(handles.Single_Cluster_Labels,'Value')
    feval('wfu_results_viewer','Single_Cluster_Labels_Callback',handles.Single_Cluster_Labels,[],handles);
  elseif get(handles.Single_Cluster_TimeCourse,'Value')
    feval('wfu_results_viewer','Single_Cluster_TimeCourse_Callback',handles.Single_Cluster_TimeCourse,[],handles);
  else
    handles=printResultsTable(handles,handles.data.tableData);
    set(handles.Whole_Brain_Stats,'Value',1)
  end
    
  try
    set(handles.Threshold_Status,'String',sprintf('T (unc) = %.3f',handles.data.xSPM.u));
  catch
    set(handles.Threshold_Status,'String','');
  end
  
  wfu_resultsProgress('done');
  set(handles.WFU_Results_Window,'Pointer','Arrow');
  return

function PO = prepend(PI,pre)
	try
  	[pth,nm,xt,vr] = fileparts(deblank(PI));
  catch
  	[pth,nm,xt,vr] = fileparts(deblank(PI));
  end
  PO             = fullfile(pth,[pre nm xt vr]);
return;

%% Revision Log at end

%{
$Log: wfu_results_compute.m,v $
Revision 1.7  2010/08/30 18:46:22  bwagner
Updates required for SPM8 rev 4010

Revision 1.6  2010/07/29 18:20:34  bwagner
Change progress bar.  Computation of cluster (handles.data.A) cleaned up.

Revision 1.5  2010/07/28 19:24:57  bwagner
Poll Pickatlas for change on any event to threshold or extent

Revision 1.4  2010/07/28 17:30:50  bwagner
Mouse scroll issue in matlab 7.10 (matlab showing version when str2num applied of 7.1).  Added progress bar to results computation.

Revision 1.3  2010/07/19 19:59:58  bwagner
WFU_LOG implemented. Changed name of results viewer function

revision 1.2  2010/07/09 13:37:13  bwagner
Checkin before aHeader to iHeader Pickatlas code update

revision 1.1  2009/10/09 17:11:38  bwagner
PickAtlas Release Pre-Alpha 1
%}
