% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
%
%
% Set the defaults
%
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function SOM_SetDefaults

global SOM

% Timing parameters

SOM.defaults.TIME.TR          = 2;    %Seconds.
SOM.defaults.TIME.BandFLAG    = 1;
SOM.defaults.TIME.TrendFLAG   = 1;
SOM.defaults.TIME.LowF        = .01;  %Hz
SOM.defaults.TIME.HiF         = .10;
SOM.defaults.TIME.padding     = 10; 
SOM.defaults.TIME.gentle      = 1;
SOM.defaults.TIME.whichFilter = 1;
SOM.defaults.TIME.fraction    = 1;
SOM.defaults.TIME.nTIME       = Inf;

% Some regression defaults, some, not all.

SOM.defaults.RegressFLAGS.prinComp = 5;
SOM.defaults.RegressFLAGS.global   = 0;
SOM.defaults.RegressFLAGS.order    = 'DCWMB';

% ROI deaults

SOM.defaults.roi.mni.size     = 19;

% Some file stuff.

SOM.defaults.MaskImgThreshold = 0.75;

% okay, done with that.

SOM_LOG('STATUS : Setting defaults.');

%
% All done.
%

return
