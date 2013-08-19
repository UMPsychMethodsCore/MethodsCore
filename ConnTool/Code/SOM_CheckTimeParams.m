% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% Validate the time parameters
% pass for SOM_PreProcessData
%
% TIME = SOM_CheckTimeParams(parameters)
%
%   TIME.run(iRUN).
%      TR             = repetition time
%      BandFLAG       = 0 no band pass filter
%                       1 apply bandpass filter
%      TrendFLAG      < 0 no linear detrending
%                       # use [N]-order polynomial to detrend.
%      LowF           = low frequency band cut
%      HiF            = high frequency band cut
%      gentle         = 0, no rolling
%                       1, rolling
%      padding        = # time points to pad on left/right
%      whichFilter    = 0, use the MATLAB filter
%                       #, use SOM_Filter_FFT
%
%      fraction       = fraction of variance for principle components
%                       analysis. Default 1.
%
% Returne TIME.OK = 1 if all okay, else -1 if bad.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


% Modified Nov 8, 2011 to have nTIME be part of data.run
% structure, previously it was part of the TIME.run structure.

function TIME = SOM_CheckTimeParams(parameters)

global SOM

% Figure out if parameters are okay.

TIME = [];

if isfield(parameters,'TIME') == 0
  SOM_LOG('WARNING : Missing TIME parameters');
else
  TIME = parameters.TIME;
end

% Default to be all OK.

TIME.OK = 1;

if isfield(TIME,'run') == 0
  SOM_LOG('WARNING : Missing run specific timing information');
  SOM_LOG('WARNING : I will create using defaults for each run.');
  for iRUN = 1:length(parameters.data.run)
    TIME.run(iRUN) = SOM.defaults.TIME;
  end   
  return
end

% If the number of runs specified by TIME.run == 1, but we have 
% more runs than that specified by data.run, then we will replicate
% for each run.

if length(TIME.run) == 1 & length(parameters.data.run) > 1 
  SOM_LOG('STATUS : Replicating timing parameters for all runs.\n');
  % Make the passed the new defaults.
  SOM.defaults.TIME = TIME.run(1);
  TIME = rmfield(TIME,'run');
  %TIME.run = [];
  for iRUN = 1:length(parameters.data.run)
    TIME.run(iRUN) = SOM.defaults.TIME;
  end
  return
end

% If they have sufficient then we just check each parameter to make
% sure it is present.

for iRUN = 1:length(TIME.run)
  if isfield(TIME.run(iRUN),'TR') == 0
    SOM_LOG(sprintf('WARNING : Missing TIME.run(%d).TR, using default of TR=2',iRUN));
    TIME.run(iRUN).TR = SOM.defaults.TIME.TR;
  end
  
% % %   if isfield(TIME.run(iRUN),'BandFLAG') == 0
% % %     SOM_LOG(sprintf('WARNING : Missing TIME.run(%d).BandFLAG, setting to 1',iRUN));
% % %     TIME.run(iRUN).BandFLAG = SOM.defaults.TIME.BandFLAG;
% % %   end
  
  if isfield(TIME.run(iRUN),'DetrendOder') == 0
    SOM_LOG(sprintf('WARNING : Missing TIME.run(%d).DetrendOder, setting to 1',iRUN));
    TIME.run(iRUN).DetrendOder = SOM.defaults.TIME.DetrendOder;
  end
  
  if isfield(TIME.run(iRUN),'LowF') == 0
    SOM_LOG(sprintf('WARNING : Missing TIME.run(%d).LowF, setting to 0.01',iRUN));
    TIME.run(iRUN).LowF = SOM.defaults.TIME.LowF;
  end
  
  if isfield(TIME.run(iRUN),'HiF') == 0
    SOM_LOG(sprintf('WARNING : Missing TIME.run(%d).HiF, setting to 0.10',iRUN));
    TIME.run(iRUN).HiF = SOM.defaults.TIME.HiF;
  end
  
  if isfield(TIME.run(iRUN),'padding') == 0
    SOM_LOG(sprintf('WARNING : Missing TIME.run(%d).padding, setting to 10',iRUN));
    TIME.run(iRUN).padding = SOM.defaults.TIME.padding;
  end
  
  if isfield(TIME.run(iRUN),'gentle') == 0
    SOM_LOG(sprintf('WARNING : Missing TIME.run(%d).gentle, setting to 1',iRUN));
    TIME.run(iRUN).gentle = SOM.defaults.TIME.gentle;
  end
  
  if isfield(TIME.run(iRUN),'whichFilter') == 0
    SOM_LOG(sprintf('WARNING : Missing TIME.run(%d).whichFilter, setting to 1',iRUN));
    TIME.run(iRUN).whichFilter = SOM.defaults.TIME.whichFilter;
  end
  
  if isfield(TIME.run(iRUN),'fraction') == 0
    SOM_LOG(sprintf('WARNING : Missing TIME.run(%d).fraction, setting to 1',iRUN));
    TIME.run(iRUN).fraction = SOM.defaults.TIME.fraction;
  end
    
  if TIME.run(iRUN).LowF >= TIME.run(iRUN).HiF
    SOM_LOG(sprintf('FATAL ERROR : low frequency equal or exceed high frequency cut off. run:%d',iRUN));
    TIME.OK = -1;
  end

end

% All done.

return
