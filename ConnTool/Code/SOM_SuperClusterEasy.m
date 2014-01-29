% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2006
%
% Routine to make a superclusters
%
% function [results] = SOM_SuperClusterEasy(SelfOMap)
%
% Just call the SOM_CalculateMap again with the results.
% 
% You should look at the matlab on how to use. Basically
% pass it the SOM calculation configuration as the global SOMSC
% You need to fill in all of the necessary parameters.
%
% You can control the super clustering with (defaults shown)
%
%   global SOMSC
%
%      SOMSC.oldMethod              = 0
%      SOMSC.sigma                  = 0.001
%      SOMSC.sigmaTimeConstant      = 1/4
%      SOMSC.learningTimeConstant   = 2
%      SOMSC.alpha                  = 0.1
%      SOMSC.nSOM                   = 16
%      SOMSC.nIter                  = 25
%
%   You will want to have SOMSC.sigma = 0.001, else 
%   there is the risk that the super cluster smoothers 
%   the results.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function [results] = SOM_SuperClusterEasy(SelfOMap)

global SOM
global SOMSC

% Which method to determine neighborhood (same code, just cleaned
% up?).

if ~isfield(SOMSC,'OldMethod') 
  SOMSC.OldMethod = 0;
end

% Check to see if the necessary fields exist.

% The neighborhood size
if ~isfield(SOMSC,'sigma')
    SOMSC.sigma = .0001;
    fprintf('SOMSC.sigma                -> %f\n',SOMSC.sigma);
end

% How quickly to modify the neighborhood size.
if ~isfield(SOMSC,'sigmaTimeConstant')
    SOMSC.sigmaTimeConstant = 1/4;
    fprintf('SOMSC.sigmaTimeConstant    -> %f\n',SOMSC.sigmaTimeConstant);
end

% How quickly to modify the map learning rate.
if ~isfield(SOMSC,'learningTimeConstant')
    SOMSC.learningTimeConstant = 2;
    fprintf('SOMSC.learningTimeConstant -> %f\n',SOMSC.learningTimeConstant);
end

% The initial map learning rate.
if ~isfield(SOMSC,'alpha')
    SOMSC.alpha = .1;
    fprintf('SOMSC.alpha                -> %f\n',SOMSC.alpha);
end

% How big of a map.
if ~isfield(SOMSC,'nSOM')
    SOMSC.nSOM = 16;
    fprintf('SOMSC.nSOM                -> %f\n',SOMSC.nSOM);
end

% How many iterations.
if ~isfield(SOMSC,'nIter')
    SOMSC.nIter = 25;
    fprintf('SOMSC.nIter                -> %f\n',SOMSC.nIter);
end

% Store the current SOM settings.

SOMS = SOM;

% Now set them for supercluster calculation.

SOM = SOMSC;

% Call the SOM Calculate map function.

% Use memory slot #2.

results = SOM_CalculateMap(SelfOMap',SOM.nSOM,SOM.nIter,[],2);

% Now reset the SOM parameters.

SOM = SOMS;

clear SOMS;

%
% All done and return.
%



