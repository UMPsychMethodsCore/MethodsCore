function varargout = wfu_ROI(action,varargin)
%vargout = wfu_ROI(action,vargin)
%
% Do all function for ROI statistics.  Avaliable actions are:
%     select      Select an Image for ROI analysis
%     calculate   Calculate ROI statistics
%
%
% Usage:
%..........................................................................
% maskImage = wfu_ROI('select', swd, force)
%   Returns a mask image from either a selected file or PickAtlas.
%
%   SWD (optional):
%   SPM.mat directory or the filename of the image to reslice the mask to.
%
%   Force (optional):
%   'both' (default)  allow a selection of either PickAtlas or File.  
%   'PickAtlas'       PickAtlas selection is forced.  
%   'File'            File selection is forced.
%
%..........................................................................
% xSPM = wfu_ROI('calculate', SPM, xSPM, XYZ, j, k, FWHM, D)
%   Return mask limited results from statistical inference
%
%   SPM         SPM structure (from SPM.mat)
%   xSPM        xSPM structure (from spm_getSPM)
%   XYZ         XYZ's surviving masking
%   j           ?? voxel index of surviving voxels in xSPM ??
%   k           ?? voxel index of survining voxels in SPM ??
%   FWHM
%   D           spm_vol structure from mask image.
%
%..........................................................................
%
% wfu_ROI('display', SPM, xSPM, hReg, Num, Dis, str)
%   Display "MIP" brain on SPM interacive screen
%

if ~exist('action','var'), error('Action argument required'); end;

switch lower(action)
  %------------------------------------------------------------------------
  case 'select'  %allow selection of mask image or use pickatlas
  %------------------------------------------------------------------------
  numvarargs = length(varargin);
  optargs = {pwd 'both'};
  optargs(1:numvarargs) = varargin;
  [swd, force] = optargs{:};
  
  if exist(swd,'file') & ~exist(swd,'dir')
    resliceFile = swd;
  else
    resliceFile = [];
  end
  
  if ~isdir(swd)
    try
      [directory2 jFileName jExt] = fileparts(swd);
    catch
      error('Unable to handle directory argument ''%s'' in wfu_ROI', swd);
    end
    
    if isdir(directory2)
      swd = directory2;
    else
      error('Directory argument invalid (wfu_ROI).');
    end
  end
  
  switch lower(force)
    case 'both'
       usePA = spm_input('ROI analysis from','-1','b',...
              'Saved File|Pickatlas GUI',['F','P']);
    case 'file'
      usePA = 'F';
    case 'pickatlas'
      usePA = 'P';
    otherwise
      error('Unkown force option ''%s'' in wfu_ROI',force);
  end
  
  
            
  switch usePA
    case 'F'
      Msk   = spm_select(1,'image','Image defining search volume',[],swd);
      [fPath fName fExt JUNK] = spm_fileparts(Msk);  %remove pesky ,1 at end of imagename
      Msk=fullfile(fPath,[fName fExt]);
    case 'P'
      atlas_mask_filename=[swd filesep 'atlas_mask_file.img'];
      [wfu_atlas_region,wfu_atlas_mask,Msk] = wfu_pickatlas(atlas_mask_filename);
    otherwise
      error('Unknown pickatlas usage %s',usePA);
  end
  
  if isempty(resliceFile)
    P = spm_select('List',swd, '^beta.*\.img$');   %get betas
    if isempty(P)
        P = spm_select('List',swd,'^spm.*\.img$');   %get spmT, spmF, spmC
    end
    if isempty(P)
        error('WFU_PickAtlas requires beta or spm image for realignment');
    end
    P = {char(fullfile(swd,P(1,:))),Msk};
  else
    P = {resliceFile,Msk};
  end
  
  flags.mean=0;
  flags.hold = 0;
  flags.which=1;
  flags.mask=0;

  %create temp interactive window to hold progress bar.
  Finter = spm_figure('FindWin','Interactive');
  set(Finter,'tag','holdFinter');
  FinterTemp = spm_figure('GetWin','Interactive');

  spm_reslice(P,flags);

  %restore interactive window.
  delete(FinterTemp);
  set(Finter,'tag','Interactive');

  Msk=prepend(Msk,'r');
  
  varargout{1}=Msk;

  
  
  %------------------------------------------------------------------------
  case 'calculate' %calculate ROI statistics
  %------------------------------------------------------------------------
  numvarargs = length(varargin);
  if numvarargs < 6 || numvarargs > 7, error('6 or 7 arguments required for wfu_ROI(''calculate'')'); end;
  optargs = {'SPM' 'xSPM' 'XYZ' 'j' 'k' 'FWHM' 'D'};
  optargs(1:numvarargs) = varargin;
  [SPM, xSPM, XYZ, j, k, FWHM, D] = optargs{:};

  SPACE='I';

  xSPM.S     = length(k);
  if strcmp(D,'D')
    xSPM.R   = SPM.xVol.R;
  else
    xSPM.R   = spm_resels(FWHM,D,SPACE);
  end
  xSPM.Z     = xSPM.Zum(k);
  xSPM.XYZ   = XYZ;
  

  %-Restrict FDR to the search volume
  %--------------------------------------------------------------------------
  df         = xSPM.df;
  STAT       = xSPM.STAT;
  DIM        = xSPM.DIM;
  R          = xSPM.R;
  n          = xSPM.n;
  Z          = xSPM.Z;
%  u          = xSPM.u;
  S          = xSPM.S;
  
  try
    thresType = xSPM.thresType;
    u = xSPM.uum; %default  takes care of Bayesian and 'none' > 1
  catch 
    if isfield(xSPM,'thresDesc')
      if any(strfind(xSPM.thresDesc,'unc')) || any(strfind(xSPM.thresDesc,'UNC'))
        thresType='none';
      elseif any(strfind(xSPM.thresDesc,'fdr')) || any(strfind(xSPM.thresDesc,'FDR'))
        thresType='FDR';
      elseif any(strfind(xSPM.thresDesc,'fwe')) || any(strfind(xSPM.thresDesc,'FWE'))
        thresType='FWE';
      else
        error('Cannot determine threshold type');
      end
      a = strfind(xSPM.thresDesc,'<');
      if isempty(a)
        a = strfind(xSPM.thresDesc,'>');
      end
      b = strfind(xSPM.thresDesc,' ');
      u = str2num(xSPM.thresDesc(a+1:b));
      if isempty(u)
        error('Unable to extract threshold level');
      end
    else
      error('Unknown Threshold and level!');
    end
  end
      
      

  
  XYZum=xSPM.XYZ;
  Zum=xSPM.Z;

  %-Compute p-values for topological and voxel-wise FDR (all search voxels)  (from spm_getSPM)
  %----------------------------------------------------------------------
  %-Voxel-wise FDR
  switch STAT
      case 'Z'
          %Ps   = (1-spm_Ncdf(Zum)).^n;
          Ps   = (1-spm_Ncdf(xSPM.Zum)).^n;
      case 'T'
          %Ps   = (1 - spm_Tcdf(Zum,df(2))).^n;
          Ps   = (1 - spm_Tcdf(xSPM.Zum,df(2))).^n;
      case 'X'
          %Ps   = (1-spm_Xcdf(Zum,df(2))).^n;
          Ps   = (1-spm_Xcdf(xSPM.Zum,df(2))).^n;
      case 'F'
          %Ps   = (1 - spm_Fcdf(Zum,df)).^n;
          Ps   = (1 - spm_Fcdf(xSPM.Zum,df)).^n;
  end
  %----------------------------------------------------------------------
    
  Ps = Ps(j); %Pick Atlas Addition

  %-Compute mask and eliminate masked voxels  (from spm_getSPM)
  %--------------------------------------------------------------------------
  for i = xSPM.Im
      fprintf('%s%30s',repmat(sprintf('\b'),1,30),'...masking')           %-#

      Mask = spm_get_data(SPM.xCon(i).Vspm,XYZ);                             %prefix xCon with SPM.
      um   = spm_u(pm,[SPM.xCon(i).eidf,SPM.xX.erdf],SPM.xCon(i).STAT);          %prefix xCon with SPM.
      if Ex
          Q = Mask <= um;
      else
          Q = Mask >  um;
      end
      XYZ       = XYZ(:,Q);
      Z         = Z(Q);
      if isempty(Q)
          fprintf('\n')                                                   %-#
          warning(sprintf('No voxels survive masking at p=%4.2f',pm));
          break
      end
  end

  %--------------------------------------------------------------------------

  %-Height threshold - classical inference  (from spm_getSPM)
  %--------------------------------------------------------------------------

  if STAT ~= 'P'


      %-Get height threshold
      %----------------------------------------------------------------------
      switch thresType

          case 'FWE' % Family-wise false positive rate
          %------------------------------------------------------------------
          %u = spm_uc(xSPM.uum,df,STAT,R,n,S);
          u            = spm_uc(0.05,df,STAT,R,n,S);  %use u calculation found in spm_VOI

          case 'FDR' % False discovery rate
          %------------------------------------------------------------------
          sPs = sort(Ps);
          if size(sPs,1)==1, sPs=sPs'; end;
          u = spm_uc_FDR(xSPM.uum,df,STAT,n,sPs,0);

          case 'none'  % No adjustment
          % p for conjunctions is p of the conjunction SPM
          %------------------------------------------------------------------
          if u <= 1
            u = spm_u(u^(1/n),df,STAT);
          end

          otherwise
          %------------------------------------------------------------------
          error(sprintf('Unknown control method "%s".',xSPM.thresType));

      end % switch thresDesc

      xSPM.u = u;

      %-Peak FWE
      uu           = spm_uc(0.05,df,STAT,R,n,S);

  end % (if STAT)

  %-Calculate height threshold filtering  (from spm_getSPM)
  %--------------------------------------------------------------------------
  Q      = find(Z > u);

  %-Apply height threshold  (from spm_getSPM)
  %--------------------------------------------------------------------------
  Z      = Z(:,Q);
  XYZ    = XYZ(:,Q);
  if isempty(Q)
      warning(sprintf('No voxels survive height threshold u=%0.2g',u))
  end

  %-Extent threshold (disallowed for conjunctions)
  %--------------------------------------------------------------------------
  if ~isempty(XYZ)

      k = xSPM.k;

      %-Calculate extent threshold filtering
      %----------------------------------------------------------------------
      A     = spm_clusters(XYZ);
      Q     = [];
      for i = 1:max(A)
          j = find(A == i);
          if length(j) >= k; Q = [Q j]; end
      end

      % ...eliminate voxels
      %----------------------------------------------------------------------
      Z     = Z(:,Q);
      XYZ   = XYZ(:,Q);
      if isempty(Q)
          warning(sprintf('No voxels survive extent threshold k=%0.2g',k))
      end

  else

      k = 0;

  end % (if ~isempty(XYZ))

  if STAT ~= 'P'
    %-Peak FDR
    if strcmp(D,'D')
      [up, Pp]     = spm_uc_peakFDR(0.05,df,STAT,R,n,Zum,XYZum,u);
    else
      [up, Pp]     = spm_uc_peakFDR(0.05,df,STAT,R,n,Z,XYZum,u);
    end

    %-Cluster FDR
    if STAT == 'T'
        V2R      = 1/prod(SPM.xVol.FWHM(SPM.xVol.DIM>1));
        if strcmp(D,'D')
          [uc, Pc, ue] = spm_uc_clusterFDR(0.05,df,STAT,R,n,Zum,XYZum,V2R,u);
        else
          [uc, Pc, ue] = spm_uc_clusterFDR(0.05,df,STAT,R,n,Z,XYZum,V2R,u);
        end
    else
        uc       = NaN;
        ue       = NaN;
        Pc       = [];
    end
  end

  xSPM.Z     = Z;
  xSPM.XYZ   = XYZ;
  % p-values for topological and voxel-wise FDR
  %--------------------------------------------------------------------------
  try, xSPM.Ps    = Ps;             end  % voxel FDR
  try, xSPM.Pp    = Pp;             end  % peak FDR
  try, xSPM.Pc    = Pc;             end  % cluster FDR

  xSPM.XYZmm = SPM.xVol.M(1:3,:)*[XYZ; ones(1, size(XYZ,2))];

%  try, xSPM.Ps  = xSPM.Ps(k); end
  uu            = spm_uc(0.05,df,STAT,R,n,S);
  xSPM.uc       = [uu up ue uc];

  varargout{1}=xSPM;
  
  

  %------------------------------------------------------------------------
  case 'display' %display ROI statistics
  %------------------------------------------------------------------------
  numvarargs = length(varargin);
  if numvarargs < 2, error('At least two arguments required for wfu_ROI(''display'')'); end;
  optargs = {'SPM', 'xSPM' [] 16 4 ''};
  optargs(1:numvarargs) = varargin;
  [SPM, xSPM, hReg, Num, Dis, str] = optargs{:};
  
  DIM = xSPM.DIM;
    
  %-Tabulate p values
  %--------------------------------------------------------------------------
  str       = sprintf('(WFU PickAtlas VOI): %s',str);

  %clear MIP first BEFORE putting table up....otherwise table will be cleared
  Fgraph = spm_figure('GetWin','Graphics');
  Finter = spm_figure('FindWin','Interactive');
  spm_results_ui('Clear',Fgraph)

  TabDat    = spm_list('List',xSPM,hReg,Num,Dis,str);

  %-Setup Maximium intensity projection (MIP) & register
  %----------------------------------------------------------------------
  if ~ishandle(Finter), error('invalid handle'), end
  h=findobj(Finter,'Tag','hFxyz');
  delete(h);

  hMIPax = axes('Parent',Fgraph,'Position',[0.05 0.60 0.55 0.36],'Visible','off');
  hMIPax = spm_mip_ui(xSPM.Z,xSPM.XYZmm,SPM.xVol.M,DIM,hMIPax);

  %verify this line makes GUI return.
  spm_results_ui('SetupGUI',SPM.xVol.M,DIM,xSPM);
  
  %------------------------------------------------------------------------
  otherwise
  %------------------------------------------------------------------------
    error('Unkown action %s given to wfu_ROI',action);
end    



%--------------------------------------------------------------------------
function PO = prepend(PI,pre)
[pth,nm,xt] = fileparts(deblank(PI));
PO             = fullfile(pth,[pre nm xt]);
return;
%--------------------------------------------------------------------------
