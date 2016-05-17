function SPM = loadGeneric(overlay)
% wfu_results_ui Internal Function
% A SPM type SPM of generic image data loaded into WFU_RESULTS.SPMmat

global WFU_RESULTS

% SPM stuct needed

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

  statFile = wfu_uncompress_nifti(overlay);  %uncompress if needed

  if ~exist(statFile,'file')
    error('Unable to file `%s`.\n',statFile);
  end

	try  
  	[fpth fname fext junk] = fileparts(overlay);
  catch
  	[fpth fname fext] = fileparts(overlay);
  end
  if ~isempty(fpth)
    cd(fpth);
  end

  if wfu_check_nifti(statFile)
    [ic ip] = wfu_read_intent_code(statFile);
  else
    ic = 0; ip = [];
  end
  
  z=1;  %the "contrast" number
  %default, blank, values
  erdf = [];
  eidf = [];
  
  switch (ic)
    case {2} %CORRELATION
      SPM.xCon(z).STAT='X';
    case {3}
      SPM.xCon(z).STAT='T';
      if ~isempty(ip), try erdf = ip(1); end; end;
    case {4}
      SPM.xCon(z).STAT='F';
      if ~isempty(ip), try eidf = ip(1); erdf = ip(2); end; end;
    case {5}
      SPM.xCon(z).STAT='Z';
  end %switch (ic)

  %setup SPM
  SPM.xX.erdf = erdf
  SPM.xCon(z).eidf = eidf;
  SPM.xCon(z).Vspm = spm_vol(statFile);
  SPM.xCon(z).Vspm.fnameOrig = overlay;
  if isfield(SPM.xCon,'STAT') && ~isempty(SPM.xCon(z).STAT)
    SPM.xCon(z).name = sprintf('%s (%s stat)',[fname fext], SPM.xCon(z).STAT);
  else
    SPM.xCon(z).name = sprintf('%s',[fname fext]);
  end
  SPM = wfu_results_import_screen(SPM,[],[],'-conImage');
  
  %setup return variables
  WFU_RESULTS.SPMmat = SPM;
  WFU_RESULTS.job.conspec.contrasts=1;

return
