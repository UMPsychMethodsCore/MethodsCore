% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2006
%
%
% A routine to remove motion confounds from the data by regression
%
% It is the same as SOM_RemoveConfound, just expanded to general
% number of confounds. Most likely could replace
% SOM_RemoveConfound. But will leave for now.
%
%     theData     = theData(space,time) (this is the 
%                   standard format being used in this SOM
%                   implementation).
% 
%     theMotion   = theConfound(time,[3 6])
% 
%                   you can also use more, such as the first derivatives.
%
% 
%    function [results, b] = SOM_RemoveConfound(theData,theMotion)
%
%       "results"   is the new data with confound regressed away.
%
%       "b"         is the beta value ([4 or 7]xspace), first 3/6 are beta
%                   for motion, last is beta for mean.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function [results, b] = SOM_RemoveMotion(theData,theMotion)

% Check for number of motion parameters, just warn if not 3 or 6

if size(theMotion,2) ~= 3 | size(theMotion,2) ~= 6 | size(theMotion,2) ~= 9 | size(theMotion,2) ~= 12
  SOM_LOG('INFO : You have non-standard # of motion parameters, but continuing anyway.');
end

% Mean center the regressors

SOM_LOG(sprintf('INFO : Motion Size : %d %d',size(theMotion,1),size(theMotion,2)));

theMotionMeans = mean(theMotion,1);

theMotionMeaned = theMotion;

for iParam = 1:size(theMotionMeaned,2)
  theMotionMeaned(:,iParam) = theMotionMeaned(:,iParam) - theMotionMeans(iParam);
end

% Put the data in order of time x space.
% This is needed for solving the inverse 
% problem.

% Ok, normally we solve the GLM:
%
%     Y = X * Beta
% 
% however, our data is organized as time along columns, so
% we need to solve the equation:
%
%     Y = Beta * X
 
X = [theMotionMeaned';ones(1,size(theData,2))];

b = theData*X'*inv(X*X');

% Calculate the contribution due to the 
% confound.

Yp = b(:,1:end-1)*X(1:end-1,:);

SOM_LOG(sprintf('INFO : Data/%d %d : Motion/%d %d : X/%d %d : b/%d %d : Yp/%d %d',...
		size(theData,1),size(theData,2),...
		size(theMotion,1),size(theMotion,2),...
		size(X,1),size(X,2),size(b,1),size(b,2),size(Yp,1),size(Yp,2)));

% Calculate the new data and put back in the form 
% of space being the first dimension and time being
% the second. That is just remove the confound contribution.

% And put data back in the right orientation. Space X Time.

results = (theData - Yp);

return

%
% All done.
%
