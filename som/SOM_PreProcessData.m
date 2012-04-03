% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% Pre-processing data for connectivity analysis.
%
% [D0 parameters] = SOM_PreProcessData(parameters)
%
%
% Input Parameters that we need for preparing the data
%
% masks.
%
%     Grey Matter mask and flag to use it.
%
%      (the grey matter mask is intersected with the epi mask)
%
%     grey.
%          File         = full directory path and name to file.
%          [ImgThreshold = 0.75 (default) ]
%
% 
%     White Matter mask
%   
%     white. 
%          File           = full directory path and name to file.
%          [ImgThreshold = 0.75 (default) ]
%          
%       
%     csf mask
%
%     csf.
%          File           = full directory path and name to file.
%          [ImgThreshold = 0.75 (default) ]
%          
%       
%
%     Brain matter mask
% 
%     epi.
%          File           = full directory path and name to file.
%          [ImgThreshold = 0.75 (default) ]
%          
%     
% data. 
%
%   run[iRun].
%
%        P                 = full directory path to time-series data.
%
%        MotionParameters  = array of motion parameters
%
%        nTIME             = number of time points to test.
%
%   MaskFLAG          = 0 don't do any masking and grab all of the data
%                     = 1 mask using either what is in parameters.epi
%                       or by building a subject specific mask with
%                       SOM_CreateMask
%
%
% RegressFLAGS.
%
%      prinComp       = 0 use average if available
%                       # use [N] principle components specified
%
%      global         = 0 no global regression
%                       1 do global regression
%
%      csf            = 0 no CSF regression
%                       1 CSF regression if 'csf' is filled
%                       above.
%
%      white          = 0 no white matter regresson
%                       1 white matter regression if 'white' is filled
%                       above.
%
%      motion         = 0 no motion regression
%                       1 motion regression (default if MotionParameters
%                       are present)
%
%      order          = the order to perform the regressions etc
%                       D = detrend
%                       G = global
%                       W = white matter
%                       C = csf
%                       M = motion
%                       B = bandpass
%              
%                       Suggested order is "D[G]CWMB", if omitted
%                       then this is the order assumed. Flags still
%                       have to be set to yes though.
%
% TIME.
%
%   run[iRun].
%
%         TR             = repetition time
%
%         BandFLAG       = 0 no band pass filter
%                          1 apply bandpass filter
%
%         TrendFLAG      < 0 no linear detrending
%                          # use [N]-order polynomial to detrend.
%
%         LowF           = low frequency band cut
%
%         HiF            = high frequency band cut
%
%         gentle         = 0, no rolling
%                          1, rolling
%
%         padding        = # time points to pad on left/right
%
%         whichFilter    = 0, use the MATLAB filter
%                          #, use SOM_Filter_FFT
%
%         fraction       = fraction of variance for principle components
%                          analysis. Default 1.
% 
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


% Modified Nov 8, 2011 to have nTIME be part of data.run
% structure, previously it was part of the TIME.run structure.

% 2012.01.12 Modified to allow editing of time-series data 
% 2012.01.12 after conversation with Mike Milham on removing movement
% 2012.01.12 outliers. RCWelsh

% 2011.11.18 - RCWelsh : Fixed nSPACE -> nSPACE(1) 

function [D0 parameters] = SOM_PreProcessData(parameters)

global SOM

% Save the parameters pass for debugging later

save parameters_debug parameters

% Set up the defaults

SOM_SetDefaults;

% Default return is to fail.

D0 = -1;

%
 
parameters.startCPU.preprocess = cputime;

% Did they pass the input data?

parameters.data = SOM_CheckDataStructure(parameters);

if parameters.data.OK ~= 1
    SOM_LOG('FATAL ERROR : Missing information in parameter.data');
    return
end

% Check the time parameters.

parameters.TIME = SOM_CheckTimeParams(parameters);

if parameters.TIME.OK ~= 1
    SOM_LOG('FATAL ERROR : Missing TIME parameters');
    return
end

% Files needed for masking?

parameters.masks = SOM_CheckMasks(parameters);

if parameters.masks.OK ~= 1
  SOM_LOG('FATAL ERROR : Something wrong with masks definitions.')
  return
end

% Now prepare based on parameters.

% Store the head and names for some quick checking.

fileINDEXTemp = 0;
filesToCheck = [];

if parameters.masks.grey.MaskFLAG == 0
  parameters.masks.grey.ImgMask  = 1;
  parameters.masks.grey.ROIIDX  = [];    % Superflous but consistent.
else
  parameters.masks.grey = SOM_MaskRead(parameters.masks.grey);
  % store temp
  fileINDEXTemp = fileINDEXTemp + 1;
  filesToCheck(fileINDEXTemp).hdr  = parameters.masks.grey.ImgHDR;
end

if parameters.masks.white.MaskFLAG == 0
  parameters.masks.white.ImgMask = 0;
  parameters.masks.white.ROIIDX  = [];
else
  parameters.masks.white = SOM_MaskRead(parameters.masks.white);
  % store temp
  fileINDEXTemp = fileINDEXTemp + 1;
  filesToCheck(fileINDEXTemp).hdr  = parameters.masks.white.ImgHDR;
end

if parameters.masks.csf.MaskFLAG == 0
  parameters.masks.csf.ImgMask   = 0;
  parameters.masks.csf.ROIIDX    = [];
else
  parameters.masks.csf = SOM_MaskRead(parameters.masks.csf);
  
  % store temp
  fileINDEXTemp = fileINDEXTemp + 1;
  filesToCheck(fileINDEXTemp).hdr  = parameters.masks.csf.ImgHDR;
end

% Check the reression flags.

parameters.RegressFLAGS = SOM_CheckRegressFLAGS(parameters);

if parameters.RegressFLAGS.OK < 1
  SOM_LOG('FATAL : SOM_CheckRegressFLAGS returned an error');
  return
end

  
curDir = pwd;

% Where is the data?

[fP fN fE] = fileparts(parameters.data.run(1).P(1,:));

% Make the mask file, masking out non-brain. Using a standard mask.

if parameters.data.MaskFLAG == 1
    if parameters.masks.epi.MaskFLAG == 0
        SOM_LOG('Calculating subject specific epi mask');
        % Create the mask from the very first/only run.
        parameters.maskHdr = SOM_CreateMask(parameters.data.run(1).P);
    else
        parameters.maskHdr = spm_vol(parameters.masks.epi.File);
    end
    % store temp
    fileINDEXTemp = fileINDEXTemp + 1;
    filesToCheck(fileINDEXTemp).hdr  = parameters.maskHdr;
else
  % changed this on 2012-03-29 (RCWelsh), this will force some sort of masking, but that is okay.
  % This will prevent SOM_CalculateCorrelationImages from failing if no mask is indicated at all
  parameters.maskHdr = SOM_CreateMask(parameters.data.run(1).P);
  %parameters.maskHdr.fname = [];   % If no name then SOM_PrepData can deal.
end

%
% Now make sure all headers comply with each other:
%

for iHDR = 1:fileINDEXTemp
  if SOM_SpaceVerify(parameters.data.run(1).hdr,filesToCheck(iHDR).hdr) ~= 1
    SOM_LOG('FATAL ERROR : Error with consistent (mask) image space definition.');
    return
  end
end

% Read in the data.

% Loop on the runs to be able to read it all in.

% We need to be able to figure out how many time points total.
% and the space points by definition have to be the same!

nTIME  = [];
nSPACE = [];

D0RUN  = [];

for iRUN = 1:length(parameters.data.run)

  [D0RUN(iRUN).D0 parameters.maskInfo] = SOM_PrepData(parameters.data.run(iRUN).P,parameters.maskHdr.fname,[]);
  
  % Trim the data as needed.
  
  if size(D0RUN(iRUN).D0,2) > parameters.data.run(iRUN).nTIME;
    D0RUN(iRUN).D0 = D0RUN(iRUN).D0(:,1:parameters.data.run(iRUN).nTIME);
    SOM_LOG(sprintf('WARNING : Trimming data to adhere to length specified in parameters.data.run.nTIME : %d',parameters.data.run(iRUN).nTIME));
  end
  
  % Capture how many time points we have read.
  
  parameters.data.run(iRUN).nTimeAnalyzed = size(D0RUN(iRUN).D0,2);
  
  % Record for all runs.
  
  nTIME  = [nTIME parameters.data.run(iRUN).nTimeAnalyzed];
  nSPACE = [nSPACE size(D0RUN(iRUN).D0,1)];

  % Loop on the preprocessing steps requested.
  
  for iOrder = 1:length(parameters.RegressFLAGS.order)
    
    % Determine which is the present step
    %
    %   possibilities are : DGCWMB
    %
    switch parameters.RegressFLAGS.order(iOrder)
      
      %
      % Detrend
      %
     case 'D'
      
      % Detrend the data.
      %
      % SPM wants the data presented as Time X Space, hence the transpose
      % operator. This will also mean center the data.
      %
      
      parameters.startCPU.run(iRUN).detrend = cputime;
      
      if parameters.TIME.run(iRUN).TrendFLAG > 0
	D0RUN(iRUN).D0 = spm_detrend(D0RUN(iRUN).D0',parameters.TIME.run(iRUN).TrendFLAG)';
      end
      
      parameters.stopCPU.run(iRUN).detrend = cputime;
      
      %
      % Global (controversial, prepare to defend your usage)
      %
     case 'G'
      
      parameters.startCPU.run(iRUN).global = cputime;
      
      % Global regression
      
      parameters.TIME.run(iRUN).GS = SOM_GlobalCalc(D0RUN(iRUN).D0);
      
      SOM_LOG('STATUS : Doing global regression');
      D0RUN(iRUN).D0 = SOM_RemoveConfound(D0RUN(iRUN).D0,parameters.TIME.run(iRUN).GS);
      
      parameters.stopCPU.run(iRUN).global = cputime;
      
      %
      % CSF, helps pick up residual physio, or so says the theory?
      %   
     case 'C'
      % Remove the CSF.
      
      parameters.startCPU.run(iRUN).csf = cputime;
      
      if parameters.masks.csf.MaskFLAG > 0
	
	SOM_LOG('STATUS : CSF Regression');
	parameters.masks.csf.IDX  = [];
	
	% Now convert the ROI indices to the indices in the mask.
	
	parameters.masks.csf.IDX = SOM_ROIIDXnMASK(parameters,parameters.masks.csf.ROIIDX);
	
	if length(parameters.masks.csf.IDX) < 1
	  SOM_LOG(sprintf('STATUS : Not enough voxels to determine CSF time course'))
	else
	  SOM_LOG(sprintf('STATUS : %d CSF Voxels in extracted data.',length(parameters.masks.csf.IDX)));
	  parameters.masks.csf.run(iRUN).PRINCOMP = [];
	  %
	  % Are we doing principle components are we taking the mean of the ROI?
	  %
	  if parameters.RegressFLAGS.prinComp > 0
	    parameters.masks.csf.run(iRUN).PRINCOMP   = SOM_PrinComp(D0RUN(iRUN).D0(parameters.masks.csf.IDX,:),parameters.TIME.run(iRUN).fraction);
	    % How many components are we to use?
	    parameters.masks.csf.run(iRUN).nComp      = min([parameters.RegressFLAGS.prinComp size(parameters.masks.csf.run(iRUN).PRINCOMP.PCScore,2)]);
	    parameters.masks.csf.run(iRUN).regressors = (parameters.masks.csf.run(iRUN).PRINCOMP.PCScore(:,1:parameters.masks.csf.run(iRUN).nComp));
	  else
	    parameters.masks.csf.run(iRUN).regressors = mean(D0RUN(iRUN).D0(parameters.masks.csf.IDX,:))';
	  end
	  
	  % Now remove them.
	  
	  D0RUN(iRUN).D0 = SOM_RemoveMotion(D0RUN(iRUN).D0,parameters.masks.csf.run(iRUN).regressors);
	end
      else
	parameters.masks.csf.run(iRUN).regressors = [];
	SOM_LOG('WARNING : CSF speficied but no CSF regression mask available.');
      end
      
      parameters.stopCPU.run(iRUN).csf = cputime;
      
      %
      % White matter, helps pick up residual physio, or so says the theory?
      %
     case 'W'
      % Now remove the White Matter.
      
      parameters.startCPU.run(iRUN).white = cputime;
      
      if parameters.masks.white.MaskFLAG > 0
	
	SOM_LOG('STATUS : WM Regression');
	parameters.masks.white.IDX  = [];
	
	% Now convert the ROI indices to the indices in the mask.
	
	parameters.masks.white.IDX = SOM_ROIIDXnMASK(parameters,parameters.masks.white.ROIIDX);
	
	SOM_LOG(sprintf('STATUS : %d WM Voxels in extracted data.',length(parameters.masks.white.IDX)));
	
	% Are we regressing out the principle components or the mean.
	
	parameters.masks.white.run(iRUN).PRINCOMP = [];
	
	%
	% Are we doing principle components are we taking the mean of the ROI?
	%
	if parameters.RegressFLAGS.prinComp > 0
	  parameters.masks.white.run(iRUN).PRINCOMP   = SOM_PrinComp(D0RUN(iRUN).D0(parameters.masks.white.IDX,:),parameters.TIME.run(iRUN).fraction);
	  % How many components are we to use?
	  parameters.masks.white.run(iRUN).nComp      = min([parameters.RegressFLAGS.prinComp size(parameters.masks.white.run(iRUN).PRINCOMP.PCScore,2)]);
	  parameters.masks.white.run(iRUN).regressors = (parameters.masks.white.run(iRUN).PRINCOMP.PCScore(:,1:parameters.masks.white.run(iRUN).nComp));
	else
	  parameters.masks.white.run(iRUN).regressors = mean(D0RUN(iRUN).D0(parameters.masks.white.IDX,:))';
	end
	
	% Now remove them.
	
	D0RUN(iRUN).D0 = SOM_RemoveMotion(D0RUN(iRUN).D0,parameters.masks.white.run(iRUN).regressors);
      else
	parameters.masks.white.run(iRUN).regressors = [];
	SOM_LOG('WARNING : WM speficied but no WM regression mask available.');
      end
      
      parameters.stopCPU.run(iRUN).white = cputime;
      
      %
      % Motion, just because we can and typically I like to regress out
      % also the 1st motion derivative.
      %
     case 'M'
      % Regress out the motion etc.
      
      parameters.startCPU.run(iRUN).motion = cputime;
      
      if parameters.RegressFLAGS.motion > 0
	D0RUN(iRUN).D0 = SOM_RemoveMotion(D0RUN(iRUN).D0,parameters.data.run(iRUN).MotionParameters(1:parameters.data.run(iRUN).nTimeAnalyzed,:));
	SOM_LOG('STATUS : Motion Correction Implemented');
      else
	SOM_LOG('WARNING : Motion speficied by motion regression internally turned off???');
      end
      
      parameters.stopCPU.run(iRUN).motion = cputime;
      
      %
      % Bandpass filter, because low-freqency BOLD should be band-passed.
      %
     case 'B'
      
      parameters.startCPU.run(iRUN).band = cputime;
      
      % Now band-pass filter
      
      if parameters.TIME.run(iRUN).BandFLAG > 0
	[D0RUN(iRUN).D0 b] = SOM_Filter(D0RUN(iRUN).D0,...
					parameters.TIME.run(iRUN).TR,...
					parameters.TIME.run(iRUN).LowF,...
					parameters.TIME.run(iRUN).HiF,...
					parameters.TIME.run(iRUN).gentle,...
					parameters.TIME.run(iRUN).padding,...
					parameters.TIME.run(iRUN).whichFilter);
	parameters.TIME.run(iRUN).b = b(1,:);
	SOM_LOG('STATUS : Band Pass Filter Implemented.');
      else
	parameters.TIME.run(iRUN).b = [];
	SOM_LOG(sprintf('WARNING : No Band Pass Filter Speficied for this run : %d.',iRUN));
      end
      
      parameters.stopCPU.run(iRUN).band = cputime;
      
      %
      % Major error.
      %   
     otherwise
      D0RUN(iRUN).D0 = -1;
      D0 = -1;
      SOM_LOG(sprintf('FATAL : regression step not recongnized : %s',parameters.RegressFLAGS.order));
      return
    end
  end
end

% Make sure the space is all the same!

if length(nSPACE>1)
  if any(diff(nSPACE))
    SOM_LOG(sprintf('FATAL : regression step not recongnized : %s',parameters.RegressFLAGS.order));
    return
  end
end

% Number of time points before editing

cnTIME = [0 cumsum(nTIME)];

SOM_LOG(sprintf('STATUS : Starting with data : %d space by %d time-points',nSPACE(1),cnTIME(end)));

% 2011.11.18 - RCWelsh : Fixed nSPACE -> nSPACE(1) 

% Edit the data if needed.

enTIME = [];

for iRUN = length(parameters.data.run)
  if isfield(parameters.data.run(iRUN),'censorVector')
    D0RUN(iRUN).D0 = SOM_editTimeSeries(D0RUN(iRUN.D0),parameters.data.run(iRUN).censorVector);
    if D0RUN(iRUN).D0 == -1
      SOM_LOG('FATAL : SOM_editTimeSeries failed.');
      exit
    else
      enTIME = [enTIME size(D0RUN(iRUN).D0,2)];
      SOM_LOG(sprintf('STATUS : Changed run %d from %d time-points to %d',iRUN,nTIME(iRUN),enTIME(iRUN)));
    end
  end
end

% Now calculate the new length, that is if we need to.

if length(enTIME) > 0
  SOM_LOG(sprintf('STATUS : Edited data to : %d space by total  %d time-points',nSPACE(1),cenTIME(end)));
else
  enTIME=nTIME;
  SOM_LOG(sprintf('STATUS : No editing of data : %d space by total % time-points',nSPACE(1),cnTIME(end)));
end

cenTIME = [0 cumsum(enTIME)];

% We can store all of this for posterity

parameters.data.nTIME  = nTIME;
parameters.data.enTIME = enTIME;

% Now contactenate the data.

D0 = zeros(nSPACE(1),cenTIME(end));

for iRUN = 1:length(parameters.data.run)
  D0(:,cenTIME(iRUN)+1:cenTIME(iRUN+1)) = D0RUN(iRUN).D0;
end

parameters.stopCPU.preprocess = cputime;

SOM_LOG(sprintf('STATUS : Total cpu usage during pre-processing step : %f sec',parameters.stopCPU.preprocess - parameters.startCPU.preprocess));

%
% All done.
%

return


