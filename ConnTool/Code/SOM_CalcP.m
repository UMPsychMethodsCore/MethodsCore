% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2006-2007
%
%
% A routine to calculate the probability "p" for the 
% voxel to be associated with a random examplar.
%
% This uses the metric : U.V
%
% function [results] = SOM_CalcP(SelfOMap,[N])
%
%
%  global SOMMem
%
%    SOMMem.theData          - time courses (space,time)
%
%  Input:
%    SelfOMap                - self-organizing map (time,exemplar#)
%
%   Option:
%    |N|                     - number of times to run 
%                              bootstrap calculation.
% 
%    Sign(N)                 - + = include all voxels in calculation.
%                            - - = exclude assosciated voxels from null.
%                                  dist.
%  global SOM
%
%    SOM.nPnts               - number of points in histogram range : 0 - 1.
%
%               NOTE : Other code uses the SOM global as well.
%       
%  Output:
%    results.dataBySOMNull   - weights.
%    results.SOMHist         - histograms of null dist.
%    results.SOMCDFH         - tail cdf. 0 = very end of dist.
%    results.pVals           - if < 0 then anti-correlated.
%
% Probability calcuted is the probability of making observation >=
% U.V or some other cost function.
%
%
% Modified on 2007-03-18
% 
%  Using SOMMem global memory to avoid out of memory errors?
%
%  Also made some changes in the histogram so that we don't store
%  huge cost metric array.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function [results] = SOM_CalcP(SelfOMap,varargin)

global SOM

global SOMMem

global SOMGaussian

% Force to use slot #1
 
slot = 1;

% However, bootstrap returns data into slot 3.

% We need to lookup the SOM associated with a given voxel.

[results.IDX results.WTS results.DIDX results.DWTS] = SOM_FindClosest(SelfOMap,1);

% Have 1001 bins by default. Should this
% be increased for resolution of the p-value?

nPnts = 1000;

% Hard code limits on the histograms to build for PDF'.s This is
% not good, but we need to have something? Fix later.

histUpperLimits = [1 2 4 2];

% Did the user set the number of points to use in histograms?

if ~isfield(SOM,'nPnts')
    SOM.nPnts = nPnts;
end

% Grab the number of points used in the histogram.

nPnts = SOM.nPnts;

% Size of the Self Organizing Map.

nSOM = size(SelfOMap,2);

% Check for the N option, that is the number of times to run the
% null distribution.

N = 1;

if nargin >= 2
    if isnumeric(varargin{1})
        N = varargin{1}(1);
    end
end

N = floor(N);

if N < 0
    fprintf('Excluding associated voxels from null calculation.\n');
end

results.N = N;

fprintf('Running %d iteration(s) of the null distributions.\n',N);

% Do this just in case.

SelfOMapN      = SOM_UnitNormMatrix(SelfOMap,1);

clear SOM_UnitNormMatrix;

% Now calculate the null hypothesis distribution.
% and then calculate the new dataBySOM for nulls. Question is how many times to
% do this? Assuming that our data is on order of 30,000 voxels, then
% once should be enough?

%results.dataBySOMNull = zeros(size(SOMMem{3}.theData,1),size(SelfOMap,2));

% Get the upper limit of the histograms to accumulate.

histUPPER = histUpperLimits(SOM.Cost+1);

% Store original data.

results.SOMHist = zeros(nSOM,nPnts+1);
results.SOMCDFH = zeros(nSOM,nPnts+1);

results.NAssoc = zeros(nSOM,1);

for iNull = 1:abs(N)                    % Run 'N' null distributions?
  SOM_Bootstrap;  % This creates slot #3.s
  SOM_CostFunction(3,SelfOMapN,SOM.Cost);
  %  SOMMem{slot}.theData                 = SOMMem{slot}.theDataO;
  for iSOM = 1:nSOM;
    % Only construct null distribution from voxels NOT associated with
    % that exemplar.
    %    idxVoxel = ones(size(results.dataBySOMNull,1),1);
    idxVoxel = ones(size(SOMMem{3}.dataBySOM,1),1);
    % Find those voxels associated with this exemplar.
    idxTmp = find(results.IDX == iSOM);
    results.NAssoc(iSOM) = length(idxTmp);
    if N > 0
      idxTmp = [];
    end
    idxVoxel(idxTmp) = 0;
    idxTmp = find(idxVoxel==1);
    if length(idxTmp) == 0
      fprintf('Fatal Error in Determining null distribution for %d exemplar, all voxels are associated!\n',iSOM);
    else
      tHist = hist(abs(SOMMem{3}.dataBySOM(idxTmp,iSOM)),(0:histUPPER/nPnts:histUPPER));   % Do just one tailed our cost function is symmetric.
%      tHist = hist(abs(results.dataBySOMNull(idxTmp,iSOM)),(0:histUPPER/nPnts:histUPPER));   % Do just one tailed our cost function is symmetric.
      if SOM.Cost ~= 0 & SOM.Cost ~= 3
        tHist = fliplr(tHist)
      end
        results.SOMHist(iSOM,:) = results.SOMHist(iSOM,:) + tHist;
    end
  end
end

fprintf('Done with histogram building.\n');

% Now calculate the histograms for each SOM exemplar.
% Min and Max of the histograms are -1 and 1. 

results.xBins = [0:histUPPER/nPnts:histUPPER];

results.nEntries = N*size(SOMMem{3}.theData,1);

results.SOMHistE = sqrt(results.SOMHist);

% Place to put the fit of the gaussian and the theoritical curve.
results.SOMpdfParms = zeros(nSOM,2);
results.SOMpdfChi2  = zeros(nSOM,1);
results.SOMpdfNDFS  = zeros(nSOM,1);
results.SOMpdfFit   = zeros(nSOM,length(results.xBins));

% Make the theoritical pdfs have 10x the resolution of the histograms.
results.xBins10     = [0:histUPPER/(nPnts*10):histUPPER];
results.SOMpdf      = zeros(iSOM,length(results.xBins10));
results.SOMcdf      = zeros(iSOM,length(results.xBins10));

fprintf('Calculating pdf''s and cdf''s. Fitting curves\n');

for iSOM = 1:nSOM;
  % Unit norm the histogram.
  NormFactor = sum(results.SOMHist(iSOM,:));
  results.SOMHist(iSOM,:) = results.SOMHist(iSOM,:)/NormFactor;
  results.SOMHistE(iSOM,:) = results.SOMHistE(iSOM,:)/NormFactor;
  results.SOMCDFH(iSOM,:) = 1-cumsum(results.SOMHist(iSOM,:));
  results.SOMCDFE(iSOM,:) = sqrt(cumsum(results.SOMHistE(iSOM,:).^2));
  SOMGaussian.Y = results.SOMHist(iSOM,:);
  SOMGaussian.Ye = results.SOMHistE(iSOM,:);
  SOMGaussian.X = results.xBins;
  [results.SOMpdfParms(iSOM,:) results.SOMpdfChi2(iSOM)] = ...
      fminsearch(@SOM_FitGaussian,[max(SOMGaussian.Y) .08]);
  results.SOMpdfFit(iSOM,:) = SOMGaussian.Yth;
  results.SOMpdfNDFS(iSOM) = SOMGaussian.nDF-2;
  results.SOMpdf(iSOM,:) = exp(-.5*((results.xBins10/ ...
				     results.SOMpdfParms(iSOM,2)).^2))*results.SOMpdfParms(iSOM,1);
  % Unit norm the pdf
  results.SOMpdf(iSOM,:) = results.SOMpdf(iSOM,:)/sum(results.SOMpdf(iSOM,:));
  results.SOMcdf(iSOM,:) = 1-cumsum(results.SOMpdf(iSOM,:));
end

% Find the index of a given weight for the voxels based on 1001 bins.
% Bounded by 1 and 1001.

fprintf('Find P values for associated Exemplars.\n');

IWTS = max( [ ones(length(results.WTS),1) ...
	      min([(nPnts*10+1)*ones(length(results.WTS),1) floor((abs(results.WTS*nPnts*10)+.5)/histUPPER)],[],2)],[],2);
% Now the index for the whole array.

fprintf('Calculating p-value indices\n');

% We use the cost-function that is stored in slot #1.

IArray = reshape(max( [ ones(prod(size(SOMMem{slot}.dataBySOM)),1) ...
		min([(nPnts*10+1)*ones(prod(size(SOMMem{slot}.dataBySOM)),1) ...
		    floor((abs(reshape(SOMMem{slot}.dataBySOM, ...
				       [prod(size(SOMMem{slot}.dataBySOM)) ...
		    1])*nPnts*10)+.5)/histUPPER)],[],2)],[],2),[size(SOMMem{slot}.dataBySOM)]);

IISOM =  [0:nSOM-1]*(nPnts*10+1);

%
% Now lookup the probability.
%
   
% The table is P(iSOM,metric);

fprintf('Looking up p-values.\n');

results.pVals = results.SOMcdf( ( results.IDX - 1 ) * size(results.SOMCDFH,2) + IWTS).*sign(results.WTS);

SOMMem{slot}.pVals = 0*SOMMem{slot}.dataBySOM;

crap = results.SOMcdf';

for iV = 1:size(SOMMem{slot}.dataBySOM,1)
  SOMMem{slot}.pVals(iV,:) = crap(IArray(iV,:)+IISOM);
end

clear crap

%
% All done.
%



