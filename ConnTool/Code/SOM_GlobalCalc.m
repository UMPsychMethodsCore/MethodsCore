% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2005
%
%
% A program to return the global signal
% from a set of time series data in the SOM
% data analysis.
%
% (You could do this yourself, but just trying to make
%  code pretty).
%
% function results = SOM_GlobalCalc(theData)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_GlobalCalc(theData)

% Find the mean.

results = mean(theData,1);

% Now take the baseline off of the mean.

results = results - mean(results);

results = results';

return

%
% All done.
%
