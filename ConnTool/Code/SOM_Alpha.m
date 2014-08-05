% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2005
% Ann Arbor MI.
%
% function results = SOM_Alpha(iter,nIter)
% 
% Routine to return current value of the learning rate.
% 
% You can change this to some other function. We use exponetial
% decay.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_Alpha(iter,nIter);

global SOM

results = SOM.alpha*exp(-iter/nIter/SOM.learningTimeConstant);

return

%
% All done.
%