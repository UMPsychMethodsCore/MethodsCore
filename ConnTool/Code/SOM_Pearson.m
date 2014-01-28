% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2007
%
%
% A routine to calculate the Pearson Rho correlation coefficient
% between times series for voxels and SOM examplars.
%
% 
% function Rho = SOM_Pearson(SelfOMap);
%
% global SOMMem
%
%      SOMMem{slot}.theData(nVoxel,nTime);
%      SelfOMap(nTime,nSOM);
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function Rho = SOM_Pearson(SelfOMap);

global SOMMem

% Force to use slot #1

slot = 1;

% Check to see if the data is present as part of the global.

if isfield(SOMMem{slot},'theData') == 0
  fprintf('Error - no data present in "global SOMMem"\n');
  Rho = [];
  return
end

nSpace = size(SOMMem{slot}.theData,1);
nTime1 = size(SOMMem{slot}.theData,2);

nTime2 = size(SelfOMap,1);
nSOM   = size(SelfOMap,2);

if nTime1 ~= nTime2 
  fprintf(['\n\nError, matrices not correct. Data(%d,%d)' ...
	   'SelfOMap(%d,%d) are impossible to calc' ...
	   'correlation.\n\n'],nSpace,nTime1,nTime2,nSOM);
  Rho = [];
  return
end

% Calculate part in matlab since this is faster.

mu_theData       = mean(SOMMem{slot}.theData,2);
mu_SelfOMap      = mean(SelfOMap,1);
sigma_theData    = std(SOMMem{slot}.theData,0,2);
sigma_SelfOMap   = std(SelfOMap,0,1);

% Do the other part in mex code as that is faster.

%Rho = SOM_PearsonEngin(SOMMem{slot}.theData,SelfOMap,...
%		       mu_theData,mu_SelfOMap,...
%		       sigma_theData,sigma_SelfOMap);


theData = SOMMem{slot}.theData - repmat(mu_theData,[1,nTime1]);
SelfOMap_mc = SelfOMap - repmat(mu_SelfOMap,[nTime2,1]);
Rho = theData*SelfOMap_mc./repmat(sigma_theData,[1,nSOM])./repmat(sigma_SelfOMap,[nSpace,1])/(nTime1-1);

return

%
% All done.
%
