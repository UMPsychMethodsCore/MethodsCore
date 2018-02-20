function SPM = loadAFNI(overlay)
% wfu_results_ui Internal Function
% loads AFNI data and time course info from "overlay" from 3dAFNItoNIFTI
%
% 3dAFNItoNIFTI flags
% -float option supported (allows multiple "buckets" in the nifti file)
% -pure NOT RECOMMENED
%
% activates appropriate buttons
% A SPM type SPM of AFNI data is loaded into WFU_RESULTS.SPMmat
%__________________________________________________________________________
% Created: Nov 9, 2010 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.2 $

  global WFU_LOG;
  if isempty(WFU_LOG)
    WFU_LOG=wfu_LOG();
  end
  WFU_LOG.info('Entered function $Revision: 1.2 $');
  global WFU_RESULTS;

% SPM struct needed

% SPM.xCon(i).Vspm = spm_vol(overlay)     the image
% SPM.xCon(i).eidf (dof low)              UI (Effective interest degrees of freedom)
% SPM.xCon(i).STAT                        UI (poss from intent code)
% SPM.xCon(i).name                        (optional, contrast name)
% -------------------------------------
% SPM.xVol.XYZ = XYZ of "brain region"    UI (brain mask or if image is already masked
% SPM.xVol.M =                            from image
% SPM.xVol.FWHM                           UI
% SPM.xVol.DIM                            from image
% SPM.xVol.S                              ??
% SPM.xVol.R = spm_resels(FWHM,D,SPACE)   Auto calc
% -------------------------------------
% SPM.xX.erdf (dof hi)                    UI (effective residual degrees of freedom)

  overlayOriginalName = overlay;
  overlay = wfu_correct_afni_nifti(overlay);  %swap 4/5th dimensional maddness
  [afni spmHeaders] = wfu_read_afni_extra_data(overlay);

%possible flipping issue....but can't see it with known tumor and stats
%
% checks internal AFNI MAT against NiFTI mat, rewrite with correctted mat
% if needed
%   newAfniOverlay=wfu_convert_afni_nifti(overlay);  
%   if ~strcmp(newAfniOverlay,overlay)
%     WFU_LOG.warndlg('Statistical image''s ANFI and nifti header do not match.  Using AFNI''s IJK_TO_DICOM_REAL.  DATA MAY BE FLIPPED.');
%     spmHeaders=spm_vol(newAfniOverlay);
%   end
%   overlay=newAfniOverlay; clear newAfniOverlay;
  
  %setup each xCon
  indx = 1;
  SPM.xX.erdf = [];
  useAfniVols=[];
  
  for i=1:length(spmHeaders)
    if isempty(afni.BRICK_STATAUX(i).statCode)
      beep();
      WFU_LOG.warn(sprintf('!! Skipping volume %d (bucket %d) labeled ''%s'' in %s as it has no Intent Code. !!\n',...
        i, i-1, char(afni.BRICK_LABS(i)), overlay));
      continue;
    end
    useAfniVols(end+1)=i;
    
    SPM.xCon(indx).name = char(afni.BRICK_LABS(i));
    %this is returned as an extra field in wfu_read_afni_extra_data, but is 
    %removed if the MAT is changed due to IJK_TO_DICOM_REAL mismatch
    if isfield(spmHeaders,'afni') 
      SPM.xCon(indx).Vspm = rmfield(spmHeaders(i),'afni');
    else
      SPM.xCon(indx).Vspm = spmHeaders(i);
    end
    SPM.xCon(indx).Vspm.fnameOrig = overlayOriginalName;
    
    erdf = [];
    defaultEidf = 1;
    eidfDefaultSetText = 'EIDF set to %d for Volume %d (Bucket %d).  A stat type %s labeled ''%s''.\n';

    switch afni.BRICK_STATAUX(i).statCode
      case {2} %CORRELATION
        SPM.xCon(indx).STAT='X';
        SPM.xCon(indx).eidf=defaultEidf;
        beep(); 
        WFU_LOG.info(sprintf(eidfDefaultSetText ,defaultEidf,i,i-1,SPM.xCon(indx).STAT,SPM.xCon(indx).name));
        erdf=afni.BRICK_STATAUX(i).statValues(1);
      case {3}
        SPM.xCon(indx).STAT='T';
        SPM.xCon(indx).eidf=defaultEidf; 
        beep(); 
        WFU_LOG.info(sprintf(eidfDefaultSetText ,defaultEidf,i,i-1,SPM.xCon(indx).STAT,SPM.xCon(indx).name));
        erdf=afni.BRICK_STATAUX(i).statValues(1);
      case {4}
        SPM.xCon(indx).STAT='F';
        SPM.xCon(indx).eidf=afni.BRICK_STATAUX(i).statValues(1);
        erdf=afni.BRICK_STATAUX(i).statValues(2);
      case {5}
        SPM.xCon(indx).STAT='Z';
        SPM.xCon(indx).eidf=defaultEidf; 
        beep(); 
        WFU_LOG.info(sprintf(eidfDefaultSetText ,defaultEidf,i,i-1,SPM.xCon(indx).STAT,SPM.xCon(indx).name));
      otherwise
        WFU_LOG.errordlg('Unknown STAT type');
    end %switch (statCode)
    if ~isempty(erdf)
      if isempty(SPM.xX.erdf) 
        SPM.xX.erdf = erdf;
      elseif SPM.xX.erdf ~= erdf
        WFU_LOG.errordlg(sprintf('ERDF established as %d.  Volume %d (Bucket %d) tried to set it to %d.\n',...
          SPM.xX.erdf, i, i-1, erdf));
      end
    end

    indx=indx+1;
  end
  
  SPM = wfu_results_import_screen(SPM,'AFNI NiFTI BRIK import','Setting imported from AFNI XML in NiFTI files header',{'-conImage'});
  
  %setup return variables
  WFU_RESULTS.SPMmat = SPM;
  WFU_RESULTS.job.conspec.contrasts=1;
  
return


%% Revision Log at end

%{
$Log: loadAFNI.m,v $
Revision 1.2  2010/07/19 19:55:32  bwagner
wfu_LOG implemented.

revision 1.1  2009/10/09 17:11:38	 bwagner
PickAtlas Release Pre-Alpha 1
%}