% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2005-2007
%
%
% function results = SOM_FindClosest(theSOM)
%
% IT IS ASSUMED THAT THE DATA AND SOM ARE UNIT NORMED
%
% global SOMMem
%    SOMMem.theData = theData(nSpace,nTime);
%
% theSOM  = theSOM(nTime,nSOM);
%
% idx     = array of indices for best matching SOM vector.
% wts     = cos(angle) or euclidean distance.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function [idx, wts, didx, dwts] = SOM_FindClosest(theSOM,slot)

global SOM

global SOMMem

idx  = [];
wts  = [];
didx = [];
dwts = [];

% make sure data is present in SOMMem

if isfield(SOMMem{slot},'theData') == 0
  fprintf('Data is missing from SOMMem\n');
  return
end

% Pre-allocate the dataBySOM, but storing it into SOM?

if isfield(SOMMem{slot},'dataBySOM')
  % Correct size?
  if prod(size(SOMMem{slot}.dataBySOM) - [size(SOMMem{slot}.theData,1) size(theSOM,2)]) ~= 0
    SOMMem{slot}.dataBySOM = zeros(size(SOMMem{slot}.theData,1),size(theSOM,2));
  end
else
  SOMMem{slot}.dataBySOM = zeros(size(SOMMem{slot}.theData,1),size(theSOM,2));
end  

% Cosing(opening angle) or Euclidean Distance.

% SOMMem{slot}.dataBySOM = SOM_CostFunction(slot,theSOM,SOM.Cost);

% Call to SOM_CostFunction - changed, SOMMem{slot}.dataBySOM is
% filled automatically by the call.

SOM_CostFunction(slot,theSOM,SOM.Cost);

% Place the sorted into global to help with memory issues?

% Think about chunking this to cut down on memory load, however, we
% would need to be careful about chunk sizes to make sure we are
% getting into redefining chunck size all of the time.

if SOM.Cost == 0 | SOM.Cost == 3
  [SOMMem{slot}.wts SOMMem{slot}.idx]   = max(SOMMem{slot}.dataBySOM,[],2);
  [SOMMem{slot}.dwts SOMMem{slot}.didx] = min(SOMMem{slot}.dataBySOM,[],2);
else
  [SOMMem{slot}.dwts SOMMem{slot}.didx] = max(SOMMem{slot}.dataBySOM,[],2);
  [SOMMem{slot}.wts SOMMem{slot}.idx]   = min(SOMMem{slot}.dataBySOM,[],2);
end  

idx = SOMMem{slot}.idx;
wts = SOMMem{slot}.wts;
didx = SOMMem{slot}.didx;
dwts = SOMMem{slot}.dwts;

% Find the index to the closest. If cost-function = 0
% then the closest is given by biggest number.
% If the cost-function = 1 (Euclidean distance), then 
% closest is by smallest number. All other cost will use the mex 
% code for calculating U.V

% Find the smallest - which if greatly negative would be deactivation or
% decorrleation? (This is not valid for Euclidean Distance as that
% is a positive definite metric, but fill up anyway.

% $$$ if SOM.Cost == 0 | SOM.Cost == 3
% $$$   % Smallest opening angle and mutual information
% $$$   idx = SOMMem{slot}.idx(:,end);
% $$$   wts = SOMMem{slot}.y(:,end);
% $$$   % largest angle, least mutual information.
% $$$   didx = SOMMem{slot}.idx(:,1);
% $$$   dwts = SOMMem{slot}.y(:,1);
% $$$ else
% $$$   % smallest euclidean distance and E.D squared.
% $$$   idx = SOMMem{slot}.idx(:,1);
% $$$   wts = SOMMem{slot}.y(:,1);
% $$$   % largest seperation
% $$$   didx = SOMMem{slot}.idx(:,end);
% $$$   dwts = SOMMem{slot}.y(:,end);
% $$$ end

% Free up memory - hopefully.

clear theSOM

return

%
% All done.
%
