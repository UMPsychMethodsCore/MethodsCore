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

% Version of the release

SOM.defaults.version = 3.0;

% Timing parameters

SOM.defaults.TIME.TR          = 2;    %Seconds.
%SOM.defaults.TIME.BandFLAG    = 1;
SOM.defaults.TIME.DetrendOder = 1;
SOM.defaults.TIME.LowF        = 0.01;  %Hz
SOM.defaults.TIME.HiF         = 0.10;
SOM.defaults.TIME.padding     = 10; 
SOM.defaults.TIME.gentle      = 1;
SOM.defaults.TIME.whichFilter = 1;
SOM.defaults.TIME.fraction    = 1;

% Some regression defaults, some, not all.

SOM.defaults.RegressFLAGS.prinComp = 5;
SOM.defaults.RegressFLAGS.order    = 'DCWMB';

% Despiking defaults

SOM.defaults.DespikeNumberOption      = 5;
SOM.defaults.DespikeOption            = 'sgolay';
SOM.defaults.DespikeReplacementInterp = 'pchip';

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
