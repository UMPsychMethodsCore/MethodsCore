% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% Validate the FLAG parameters
% pass for SOM_PreProcessData
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
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% Modified Nov 8, 2011 to have nTIME be part of data.run
% structure, previously it was part of the TIME.run structure.

function RegressFLAGS = SOM_CheckRegressFLAGS(parameters)

global SOM

if isfield(parameters,'RegressFLAGS') == 0
    SOM_LOG('WARNING : No regression flags specified, going to build defaults');
    RegressFLAGS = [];
    RegressFLAGS.prinComp = SOM.defaults.RegressFLAGS.prinComp;
    RegressFLAGS.global   = SOM.defaults.RegressFLAGS.global;
    RegressFLAGS.csf      = parameters.csf.MaskFLAG;
    RegressFLAGS.white    = parameters.white.MaskFLAG;
    RegressFLAGS.motion   = 1;
    for iRUN = 1:length(parameters.data.run)
      % 
      % If motion parameters are missing for any run then we turn
      % the regression off for all runs.
      %
      %
      if isfield(parameters.data.run(iRUN),'MotionParameters') == 0
        parameters.data.run(iRUN).MotionParameters = [];
	RegressFLAGS.motion = 0;
	SOM_LOG(sprintf('WARNING : No motion parameters for run %d, setting RegressFLAGS.motion = 0',iRUN));
      end
      % 
      % Fatal error if motion parameters are not sufficient.
      %
      if ~isnumeric(parameters.data.run(iRUN).MotionParameters) | ...
            parameters.data.run(iRUN).nTIME > size(parameters.data.MotionParameters,1)
        SOM_LOG(sprintf('FATAL ERROR : Problem with motion parameters for run %d',iRUN));
	return
      else
        RegressFLAGS.motion = 1;
      end
    end
    % Default the order.
    RegressFLAGS.order = SOM.defaults.RegressFLAGS.order;
    RegressFLAGS.OK    = 1;
    return
end

RegressFLAGS = parameters.RegressFLAGS;

% Default to being okay.

RegressFLAGS.OK = 1;

if isfield(RegressFLAGS,'prinComp') == 0
    SOM_LOG('WARNING : prinComp FLAG no set, using default of 5');
    RegressFLAGS.prinComp = SOM.defaults.RegressFLAGS.prinComp;
end

if isfield(RegressFLAGS,'global') == 0
    SOM_LOG('WARNING : global FLAG no set, using default of 0');
    RegressFLAGS.global = SOM.defaults.RegressFLAGS.global;
end

if isfield(RegressFLAGS,'csf') == 0
    SOM_LOG('WARNING : csf FLAG no set, using default of parameters.csf.MaskFLAG');
    RegressFLAGS.csf = parameters.csf.MaskFLAG;
end

if isfield(RegressFLAGS,'white') == 0
    SOM_LOG('WARNING : white FLAG no set, using default of parameters.white.MaskFLAG');
    RegressFLAGS.white = parameters.white.MaskFLAG;
end

% Check the motion parameters for each run

for iRUN = 1:length(parameters.data.run)
  if isfield(parameters.data.run(iRUN),'MotionParameters') == 0
    SOM_LOG('WARNING : Motion parameters not specified');
    MotionParameters = [];
  else
    MotionParameters = parameters.data.run(iRUN).MotionParameters;
  end
  
  if ~isnumeric(MotionParameters) | ...
        parameters.data.run(iRUN).nTIME > size(MotionParameters,1)
    SOM_LOG('FATAL ERROR : motion parameters missing, or mismatched, not using.');
    return
  else
    if isfield(RegressFLAGS,'motion') == 0
      SOM_LOG('WARNING : motion flag not there, but motion parameters present, setting flag to 1.');
      RegressFLAGS.motion = 1;
    end
  end
end

% The regression order.

if isfield(RegressFLAGS,'order') == 0
  SOM_LOG(sprintf('WARNING : Assuming regression order of : %s',SOM.defaults.RegressFLAGS.order));
  RegressFLAGS.order = SOM.defaults.RegressFLAGS.order;
else
  if ischar(RegressFLAGS.order) == 0
    SOM_LOG('FATAL : Regression order must be a character array');
    RegressFLAGS.OK = -1;
    return
  end
  nOrder = '';
  for iOrder = 1:length(RegressFLAGS.order)
    if length(findstr(upper(RegressFLAGS.order(iOrder)),'DGCWMB')) > 0
      nOrder = [nOrder upper(RegressFLAGS.order(iOrder))];
    else
      SOM_LOG(sprintf('FATAL : I don''t recognize the regression order symbol : %s',RegressFLAGS.order(iOrder)));
      RegressFLAGS.OK = -1;
      return
    end
  end
  RegressFLAGS.order = nOrder;
end

return

%
% All done.
% 
