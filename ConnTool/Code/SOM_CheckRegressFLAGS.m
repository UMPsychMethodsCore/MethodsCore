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
%      motion         = 0 no motion regression
%                       1 motion regression (default if MotionParameters
%                       are present)
%                       THIS IS AN INTERNAL FLAG
%
%      despikeParameters
%
%           .method        - method to edit (smooth) the data. see matlab/smooth
%           .span          - data span for fitting. see matlab/smooth
%           .interpMethod  - interpolation method. see matlab/interp1
%                            (supported : 'nearest','linear','spline','pchip')
%
%      order          = alphabetic order of signal processing.
%                       D = detrend
%                       G = global
%                       C = CSF
%                       W = white matter
%                       M = motion
%                       B = band pass
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
    RegressFLAGS.motion   = 1;
    RegressFLAGS.despikeParameters.span         = SOM.defaults.DespikeNumberOption;
    RegressFLAGS.despikeParameters.method       = SOM.defaults.DespikeOption;
    RegressFLAGS.despikeParameters.interpMethod = SOM.defaults.DespikeReplacementInterp;
    
    
% % %     for iRUN = 1:length(parameters.data.run)
% % %         %
% % %         % If motion parameters are missing for any run then we turn
% % %         % the regression off for all runs.
% % %         %
% % %         %
% % %         if isfield(parameters.data.run(iRUN),'MotionParameters') == 0
% % %             parameters.data.run(iRUN).MotionParameters = [];
% % %             RegressFLAGS.motion = 0;
% % %             SOM_LOG(sprintf('WARNING : No motion parameters for run %d, setting RegressFLAGS.motion = 0',iRUN));
% % %         end
% % %         %
% % %         % Fatal error if motion parameters are not sufficient.
% % %         %
% % %         if ~isnumeric(parameters.data.run(iRUN).MotionParameters) || ...
% % %                 parameters.data.run(iRUN).nTIME > size(parameters.data.MotionParameters,1)
% % %             SOM_LOG(sprintf('FATAL ERROR : Problem with motion parameters for run %d',iRUN));
% % %             return
% % %         else
% % %             RegressFLAGS.motion = 1;
% % %         end
% % %     end
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

if isfield(RegressFLAGS,'despikeParameters') == 0
    SOM_LOG('WARNING : despikeParameters not set, using defaults');
    RegressFLAGS.despikeParameters.span         = SOM.defaults.DespikeNumberOption;
    RegressFLAGS.despikeParameters.method       = SOM.defaults.DespikeOption;
    RegressFLAGS.despikeParameters.interpMethod = SOM.defaults.DespikeReplacementInterp;
end

if isfield(RegressFLAGS.despikeParameters,'span') == 0
    SOM_LOG('WARNING : despikeParameters.span not set, using default');
    RegressFLAGS.despikeParameters.span         = SOM.defaults.DespikeNumberOption;
end

if isfield(RegressFLAGS.despikeParameters,'method') == 0
    SOM_LOG('WARNING : despikeParameters.method not set, using default');
    RegressFLAGS.despikeParameters.method       = SOM.defaults.DespikeOption;
end

if isfield(RegressFLAGS.despikeParameters,'interpMethod') == 0
    SOM_LOG('WARNING : despikeParameters.interpMethod not set, using default');
    RegressFLAGS.despikeParameters.interpMethod = SOM.defaults.DespikeReplacementInterp;
end

% % % % Check the motion parameters for each run
% % % 
% % % for iRUN = 1:length(parameters.data.run)
% % %     if isfield(parameters.data.run(iRUN),'MotionParameters') == 0 || length(parameters.data.run(iRUN).MotionParameters) < 1
% % %         SOM_LOG('WARNING : Motion parameters not specified');
% % %         MotionParameters = [];
% % %         RegressFLAGS.motion = 0;
% % %     else
% % %         MotionParameters = parameters.data.run(iRUN).MotionParameters;
% % %         
% % %         if ~isnumeric(MotionParameters) || ...
% % %                 parameters.data.run(iRUN).nTIME > size(MotionParameters,1)
% % %             SOM_LOG('FATAL ERROR : motion parameters missing, or mismatched, not using.');
% % %             return
% % %         else
% % %             if isfield(RegressFLAGS,'motion') == 0
% % %                 SOM_LOG('WARNING : motion flag not there, but motion parameters present, setting flag to 1.');
% % %                 RegressFLAGS.motion = 1;
% % %             end
% % %         end
% % %     end
% % % end

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
        if ~isempty(strfind('DSGCWMEB',upper(RegressFLAGS.order(iOrder))))
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
