function SPM = loadFSL(overlay)
% wfu_results_ui Internal Function
% loads an FSL feat directory and time course info from "overlay"
% activates appropriate buttons
% A SPM type SPM of FSL data is loaded into WFU_RESULTS.SPMmat
%
% overlay should be FULL PATH/FILENAME


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
%__________________________________________________________________________
% Created: Nov 9, 2010 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.6 $

  global WFU_LOG;
  if isempty(WFU_LOG)
    WFU_LOG=wfu_LOG();
  end
  WFU_LOG.info('Entered function $Revision: 1.6 $');

  options.displayFiles = 0;
  options.displayDirectories = 0;

 	[statsDir statsFile statsExt] = fileparts(overlay);  %this is a potient fsldir, redefined below when truely known
  designCon = wfu_find_files('design.con',statsDir,2,options);
  if isempty(designCon)
    designCon = wfu_find_files('design.con',fullfile(statsDir,'..'),2,options);
    if isempty(designCon)
      designCon = wfu_find_files('design.con',fullfile(statsDir,'..','..'),2,options);
    end
  end
  
  WFU_LOG.info(sprintf('Found design.con file in: %s\n',fileparts(designCon{1})));
  
  resp = questdlg(sprintf('Using feat directory:\n\n%s\n\nIs this the directory you wish to read feat information from?',fileparts(designCon{1})),'Confirm feat directory','Yes','No','Yes');
  
  if ~strcmp(resp,'Yes')
    resp = wfu_pickfile('^design.con$','Select the design.con file found in the feat output directory.',fileparts(designCon{1}));
    designCon = [];
    designCon{1} = resp;
  end
  
  
  if strcmpi(statsExt,'.gz')
   	[junk statsFile statsExt] = fileparts(statsFile);
    statsExt=[statsExt '.gz'];
  end


  if isempty(designCon)
    beep();
    WFU_LOG.warndlg('Unable to find design.con.  Reverting to general image import.');
    loadGeneric(overlay);
    return;
  end

  if length(designCon) > 1
    beep();
    WFU_LOG.warndlg('WARNING:  Too many `design.con` files found.  Unable to load as FSL because of confusion.  Reverting to general image import.');
    loadGeneric(overlay);
    return;
  end

  fslDir = fileparts(char(designCon));  %this is true fsldir
  cd(fslDir);

  [fieldName fieldValue1 fieldValue2] = textread(designCon{1},'%s %s %s');

  for i=1:length(fieldName)
    sFieldName=char(fieldName(i));
    conFound = strfind(sFieldName,'ContrastName');
    if conFound
      contrastNumber = str2num(sFieldName(conFound(1)+12));
      contrastNames{contrastNumber} = char(fieldValue1(i));
    end
  end

  
  statsList={'t' 'z'};  %[t|z]stat.nii.gz files available
  statsCode={3   5};
  
  %DOF
  eidf=1;
  erdf=[];
  try erdf=load(fullfile(fslDir,'stats','dof')); end;
  SPM.xX.erdf=erdf;
  
  
  %information needed to attempt autofilling in various stats from only a
  %known overlay name
  statSuffix=[];
 	[statDirA statNameA statExtA]=fileparts(overlay);
  if strcmpi(statExtA,'.gz')
   	[junk statNameA statExtA1]=fileparts(statNameA);
    statExtA=[statExtA1 statExtA];
  end
  if strfind(statNameA,'stat')
    pos=strfind(statNameA,'stat')+4;
    while pos <= length(statNameA) && ~isempty(str2num(statNameA(pos))) 
      pos=pos+1;
    end
    statSuffix=statNameA(pos:end);
  end
  
  %fill out SPM structure some more
  z=1;
  for i=1:length(statsList)
    for j=1:length(contrastNames)
      %basic xCon settings:
      SPM.xCon(z).eidf=eidf;
      SPM.xCon(z).STAT=upper(statsList{i});
      
      %SPM.xCon.name
      imgName=sprintf('%sstat%d',lower(statsList{i}),j);
      if ~isempty(contrastNames{j})
        statText = sprintf('%s (%s image)',contrastNames{j}, imgName);
      else
        statText = sprintf('%s image', imgName);
      end
      
      SPM.xCon(z).name=statText;
      
      %SPM.xCon.Vspm
      if findstr(imgName,overlay)
        WFU_LOG.info(sprintf('Overlay used as %s',statText));
        SPM.xCon(z).Vspm.fname=overlay;
      else
        tmpImg=fullfile(statDirA,[imgName statSuffix statExtA]);
        if exist(tmpImg,'file')==2
          SPM.xCon(z).Vspm.fname=tmpImg;
          WFU_LOG.info(sprintf('Found %s as %s',statText, tmpImg));
        else
          WFU_LOG.info(sprintf('Cannot Find %s (looking for %s)',statText, tmpImg));
        end
      end
      z=z+1;
    end
  end
  
  designFsf = fullfile(fslDir,'design.fsf');
  if exist(designFsf,'file')
    [jcmd field value1 value2 value3] = textread(designFsf,'%s %s %s %s %s');
    for i=1:length(field)
      sField=char(field(i));
      fwhmFound = strfind(sField,'fmri(smooth)');
      if fwhmFound
        if isempty(value2{i}) && isempty(value3{i})
          FWHMs = value1{i};
          FWHM = str2num(value1{i}) .* [1 1 1];
        else
          FWHMs = [value1{i} ' ' value2{i} ' ' value3{i}];
          FWHM = [str2num(value1{i}) str2num(value2{i}) str2num(value3{i})];
        end
        %convert to mm string
        SPM.xVol.FWHM = sprintf('%dmm %dmm %dmm',FWHM);
        break;
      end
    end
  end
  
  %look for brain masking files
  SPM.VM.fname=fullfile(fslDir,['mask' statSuffix '.nii.gz']);
  if exist(SPM.VM.fname) ~= 2, SPM.VM.fname=fullfile(fslDir,['mask' statSuffix '.nii']); end;
  if exist(SPM.VM.fname) ~= 2, SPM.VM.fname=fullfile(fslDir,['mask' statSuffix '.img']); end;
  if exist(SPM.VM.fname) ~= 2, SPM.VM.fname=[]; end;
    

  SPM = wfu_results_import_screen(SPM,'FSL feat import','Settings imported from feat directory');
  
  %setup return variables
  WFU_RESULTS.SPMmat = SPM;
  WFU_RESULTS.job.conspec.contrasts=1;

return

%% Revision Log at end

%{
$Log: loadFSL.m,v $
Revision 1.6  2015/02/23 14:05:56  fmri
removed try/catch fileparts mess

Revision 1.5  2011/10/10 16:54:06  bwagner
Matlab 2011b changes to fileparts

Revision 1.4  2010/07/19 19:57:11  bwagner
Automatically populate with similary named stat/mask files.

Revision 1.3  2010/07/14 14:17:37  bwagner
attempts to automatically fill in assorted stat names from overlay name

Revision 1.2  2010/07/13 20:37:47  bwagner
Moving to wfu_LOG

revision 1.1  2009/10/09 17:11:38	 bwagner
PickAtlas Release Pre-Alpha 1
%}
