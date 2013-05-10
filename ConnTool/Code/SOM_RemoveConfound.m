% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2005
%
%
% A routine to remove a confound from the data by regression
%
%
%     theData     = theData(space,time) (this is the 
%                   standard format being used in this SOM
%                   implementation).
% 
%     theConfound = theConfound(time,1)
%                   (however, if the otherway the code will
%                    transpose for you.)
%
% 
%    function [results, b] = SOM_RemoveConfound(theData,theConfound)
%
%       "results"   is the new data with confound regressed away.
%
%       "b"         is the beta value (2xspace), first is beta
%                   confound, 2nd is beta for mean.
%
% See also SOM_RemoveMotion
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function [results, b] = SOM_RemoveConfound(theData,theConfound)

% Transpose confound if need be.

if size(theConfound,1) == 1
    theConfound = theConfound';
    SOM_LOG('WARNING : I had to transpose "theConfound"');
end

% Put the data in order of time x space.
% This is needed for solving the inverse 
% problem.

Y = theData';

% Make a simple design matrix.

X = [theConfound ones(size(Y,1),1)];

% Get the fit to the data for the 
% confound and the mean.

b = inv(X'*X)*X'*Y;

% Calculate the contribution due to the 
% confound.

Yp = X(:,1)*b(1,:);

% Calculate the new data and put back in the form 
% of space being the first dimension and time being
% the second. That is just remove the confound contribution.

results = (Y-Yp)';

return

%
% All done.
%
