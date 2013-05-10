% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2005
%
% function results = SOM_CalculateMap(theData,nSOM,nIter,[SelfOMap],[slot])
%
% theData = theData(nSpace,nTime);
% nSOM    = number of basis functions in the SOM
% nIter   = number of iterations.
% slot    = memory slot to use. 1 = time series data (default)
%                               2 = super cluster use.
%                               3 = boostrap probabilities.
%
% NOTE : The "slot" is used to help with memory management.
%        Self-Organzing Map calculations are very memory
%        intensive, so we are using global memory. However,
%        when calculating the supercluster map it would be useful
%        to not wipe out the data, so we have two slots 
%        available for memory. 
%
%        Please use them wisely.
%
%        You will break the calculation if you place
%        your time-series data in slot #2!
%
%        Hopefully you can avoid "Out of memory" error by
%        specifying slot 1 for the big time series matrix, and 
%        slot 2 for super cluster calculation.
%     
%        Between subjects you may need to execute the "pack"
%        command.
%    
%        Worst case, trim you session, save appropriate 
%       things to disk and restart matlab.
%
%
% results = results structure, it will at least contain
%           the resulting SOM.
%
% results = results.SOM  (the map)
%           results.IDX  (for each space element which SOM it is related to
%                         best)
%           results.WT   (how much of the variance is explained by that)
%
%   this is a work in progress!
%
% Currently the cost functionm is Cos(Theat) = U dot V
% where U and V have unit length.
%
% You can set the SOM parameters with
%
%  global SOM
%
%      SOM.sigma                      = Initial neighborhood size.
%      SOM.sigmaTimeConstant          = Rate the neighborhood shrinks.
%      SOM.learningTimeConstant       = Rate that learning changes.
%      SOM.alpha                      = Initial learning rate
%      SOM.Cost                       = Cost function. (0=U.V,
%                                        1=|U-V|, 2=|U-V|^2, 3=M.I.).
%               NOTE U.V is fastest metric.
%      SOM.nPnts                      = number of points in histogram range : 0 - 1[2].
%               NOTE used by SOM_CalcP. (2 is upper range for |U-V|
%               cost, a guess. See "SOM_CalcP.m")
%      SOM.saveHistory                = History level to save. (0/1/2);
%                                       0 = none;
%                                       1 = some;
%                                       2 = full - memory intensive.
%      SOM.WeightOption                 0 = no weighting of components.
%                                       1 = weight by variance
%                                       2 = weight by st-dev
%
% If you don't specify these parameters they will assume default
% values of:
%
%       SOM.alpha                = .1    (See "SOM_Alpha.m" on evolution)
%       SOM.learningTimeConstant = 2;
%       SOM.sigmaTimeConstant    = .25;
%       SOM.sigma                = nSOM/2;  guess?
%       SOM.Cost                 = 0;  (Opening angle cost function.)
%       SON.nPnts                = 1000;
%       SOM.saveHistory          = 1;   - Save most of history, but
%                                  not full weights.
%       SOM.WeightOption         = 0;
%
% Alpha (SOM_Alpha.m) changes according to:
%
%   exp(-iter/(nIter * SOM.learningTimeConstant));
%
% Neighborhood size changes according to:
%
%   exp(-iter/(nIter * SOM.sigmaTimeConstant));
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_CalculateMap(theData,nIter,SelfOMap,slot)

global time;
global SOM
global SOMMem
%--------------------------Ben added 6/28/07--------------------
[b,v] = sphere_iter(2,1);
nSOM = length(v);

% Keep track of the version.

MajorVersion = 1;
MinorVersion = 001;

SOM.Version = sprintf('%d.%03d',MajorVersion,MinorVersion);

% Keep track of the time.

results.StartTime=cputime;

tic;

% Which method to determine neighborhood (same code, just cleaned
% up?).

if ~isfield(SOM,'OldMethod')
    SOM.OldMethod = 0;
end

% Check to see which memory slot

if exist('slot') == 0
  slot = 1;
  fprintf('Defaulting to use memory slot 1.\n');
end

if slot ~= 1 & slot ~= 2
  fprintf('Forcing to use slot #1.\n');
  slot = 1;
end

fprintf('Using memory slot #%d\n',slot);

SOM.slot = slot;

% Check to see if the necessary fields exist.

% The neighborhood size
if ~isfield(SOM,'sigma')
    SOM.sigma = sqrt(nSOM)/2;
    fprintf('SOM.sigma                -> %f\n',SOM.sigma);
end

% How quickly to modify the neighborhood size.
if ~isfield(SOM,'sigmaTimeConstant')
    SOM.sigmaTimeConstant = 1/4;
    fprintf('SOM.sigmaTimeConstant    -> %f\n',SOM.sigmaTimeConstant);
end

% How quickly to modify the map learning rate.
if ~isfield(SOM,'learningTimeConstant')
    SOM.learningTimeConstant = 2;
    fprintf('SOM.learningTimeConstant -> %f\n',SOM.learningTimeConstant);
end

% The initial map learning rate.
if ~isfield(SOM,'alpha')
    SOM.alpha = .1;
    fprintf('SOM.alpha                -> %f\n',SOM.alpha);
end

% The cost function
if ~isfield(SOM,'Cost')
    SOM.Cost = 0;
    fprintf('SOM.Cost                 -> %f\n',SOM.Cost);
end

% The saving history.
if ~isfield(SOM,'saveHistory')
    SOM.saveHistory = 1;
    fprintf('SOM.saveHistory          -> %f\n',SOM.saveHistory);
end

% The saving history.
if ~isfield(SOM,'WeightOption')
    SOM.WeightOption = 0;
    fprintf('SOM.WeightOption          -> %f\n',SOM.WeightOption);
end

% Make sure that the Weight Option is Valid.
SOM.WeightOption = SOM.WeightOption(1);

if sum(ismember([0 1 2],SOM.WeightOption)) == 0
  SOM.WeightOption = 0;
  fprintf('SOM.WeightOption          -> %f\n',SOM.WeightOption);
end

% Determine the size of the space we are dealing with.

%if sqrt(nSOM)~=floor(sqrt(nSOM))
%    fprintf('Can only do square SOM!\n');
%    fprintf('Forcing SOM to be square\n');
%    nSOM = floor(sqrt(nSOM)+.5)^2;
%    fprintf('New size is : %d\n',nSOM);
%end

% Record the size of the SOM.
SOM.nSOM = nSOM;
SOM.nIter = nIter;

nGrid = sqrt(nSOM);
SOM.nGrid = nGrid;

nSpace = size(theData,1);
nTime  = size(theData,2);

fprintf('Number of time points  : %d\n',nTime);
fprintf('Number of space points : %d\n',nSpace);

% Randomize our initial SOM and normalize the basis.
%
% Modified on 8/23/2005 to use normaly distributed
% elements of vector. This will make it uniformly
% distributed on a sphere in n-space.
%
% Found by doing google search and getting
% argument of Steve Rayhawk at Harvey Mudd.
% Seems to work by graphical validation - still need
% to find the paper for citation. See reference in
% Donald Knuth book: The Art of Computer Programming, vol2
% Seminumerical Algorithms, Addison-Wesley, 1969.
%

if exist('SelfOMap') == 1 & ~any([nTime nSOM]-size(SelfOMap))
  fprintf('Using passed initialized SelfOMap\n');
else
  fprintf('Randomizing SelfOMap\n');
  SelfOMap = randn(nTime,nSOM);
  SelfOMap = SOM_UnitNormMatrix(SelfOMap,1);
end

% Store a copy of the initial one.
iSelfOMap = SelfOMap;

clear SOM_UnitNormMatrix;

% Unit norm the data. We are not necessarily interested in effect
% size at the moment versus explanatory basis. We can
% get the "beta's" later!

% This is not the best, as when SOM_SuperClusterEasy calls us, we globber 
% what was in here. Not good! 2007-03-23.
% Come up with a mex solution?

SOMMem{slot}.theData = SOM_UnitNormMatrix(theData,2);

% Calculate the Variance for weights.
SOMMem{slot}.varData = var(SOMMem{slot}.theData,[],2);

% Weights for biasing the SOM to voxels that have high variance but
% low population number.

switch SOM.WeightOption
 case 0
  SOMMem{slot}.Weights = ones(size(theData,1),1);
 case 1
  SOMMem{slot}.Weights = var(SOMMem{slot}.theData,[],2);
 case 2
  SOMMem{slot}.Weights = std(SOMMem{slot}.theData,[],2);
 case default
  SOMMem{slot}.Weights = ones(size(theData,1),1);
end
SOMMem{slot}.Weights = repmat(SOMMem{slot}.Weights,[1 size(SOMMem{slot}.theData,2)]);
clear theData
  
clear SOM_UnitNormMatrix;

% Ok, let's go iterate the map. At the moment
% we'll just stop the calculation after a sufficient number
% iterations.

iter = 0;

%neighborDist = SOM_NeighborDist(nGrid);

%lneighborDist = reshape(neighborDist,[nGrid nGrid nGrid*nGrid]);
%--------------------------Ben added 6/12/07--------------------


lneighborDist = zeros(nSOM,nSOM);
for ii=1:nSOM
    for jj=1:nSOM
        lneighborDist(ii,jj) = abs(acos(dot(v(ii,:),v(jj,:)))*2);
    end
end

history = {};

fprintf('iter,alpha,NeighSigma,cpu\n');

%mov = avifile('animated4.avi','compression','Cinepak')

while iter < nIter
    tic;
    % Increment the iteration
    iter = iter + 1;
    % Learning function = g(time);
    alpha = SOM_Alpha(iter,nIter);
    % Determine the neighbor map.
    % For each element of the SOM, there will be an associated
    % neighborhood. The call should return the indices of these
    % SOM vectors as well as the distance for use in the weight
    % calculation.
    NeighSigma = SOM.sigma*exp(-iter/nIter/SOM.sigmaTimeConstant);
    if SOM.OldMethod == 0
        SOMNeighborMap = exp(-lneighborDist.^2/NeighSigma^2);
        %keyboard;
    else
        SOMNeighborMap = SOM_NeighborMap([nGrid nGrid],NeighSigma);
    end
    
    % Determine the SOM vectors the data are closest to and save the
    % history.
    [idx wts] = SOM_FindClosest(SelfOMap,slot);
    if SOM.saveHistory > 0
        history{iter}.idx      = idx;
        history{iter}.wts      = wts;
        history{iter}.SelfOMap = SelfOMap;
        history{iter}.sigma    = NeighSigma;
        history{iter}.alpha    = alpha;
        %history{iter}.neighMap = SOMNeighborMap(:,:,(nGrid-1)*floor(nGrid/2));
        if SOM.saveHistory > 1
            history{iter}.dataBySOM = SOMMem{slot}.dataBySOM;
        end
	history{iter}.cpuTime = cputime;
    end
    %
    clear SOM_FindClosest;
    % Now calculate the perturbation to the SOM.
    dSelfOMap = 0*SelfOMap;
    nullSOM   = 0*SelfOMap;
    pV_init = SOMMem{slot}.theData.*SOMMem{slot}.Weights;
    for iSOM = 1:nSOM
      % Deterimine which data affect this SOM vector.
      dI = find(idx==iSOM);
      if length(dI) > 0
	% pertube all the same regardless of number of perturbers.
	% 
	% Modified to allow heavier weighting based on variance of
        % the time-series vector for a voxel. This is under the 
	% assumption that we want variance explained by the model.
	%
	% This also makes the assumption that signal is high
        % variance?
	%
	% 2007.03.20   Robert C. Welsh
	%
	pV = sum(pV_init(dI,:),1)'/...
	     sum(SOMMem{slot}.Weights(dI,1));    
%tic
%sum(SOMMem{slot}.theData(dI,:));
%toc
%tic
%SOMMem{slot}.Weights(dI);
%toc
%keyboard;
    %-------------------Ben changed 6/13/07-----------------------
    if SOM.OldMethod == 0
          vlx = pV*reshape(SOMNeighborMap(:,iSOM),[1 nSOM]);
          %SOM_ModBasis(pV,nullSOM,SOMNeighborMap(:,iSOM));
	  dSelfOMap = dSelfOMap + vlx;
	else
	  dSelfOMap = dSelfOMap + SOM_ModBasis(pV,nullSOM, ...
					       SOMNeighborMap{iSOM},iter,nIter);
    end
	clear SOM_ModBasis;
      end
    end
    % Update the SOM.
    SelfOMap = SelfOMap + alpha*dSelfOMap;
    SelfOMap = SOM_UnitNormMatrix(SelfOMap,1);
    if(any(any(isnan(SelfOMap))))
         keyboard
     end
    clear SOM_UnitNormMatrix;
    xx=toc;
    if SOM.saveHistory > 0
      history{iter}.toc = xx;
    end	
    fprintf('%03d %f %f %f\n',iter,alpha,NeighSigma,xx);
end
%mov = close(mov);

% All done, and now pack up the results to be sent back to the calling
% function.

results.SelfOMap = SelfOMap;

[results.IDX results.WTS results.DIDX results.DWTS] = SOM_FindClosest(SelfOMap,slot);

clear SOM_FindClosest;

% Final cost function evaluation.

results.dataBySOM = SOMMem{slot}.dataBySOM;

% Return a copy of the initial one used.

results.iSelfOMap = iSelfOMap;
results.history   = history;

results.weights = [];
for iter = 1:nIter
    results.weights = [results.weights sum(results.history{iter}.wts)];
end

% Record the configuation.

results.SOM                  = SOM;
results.H                    = hist(results.IDX,[0:results.SOM.nSOM]);

clear history;
clear SelfOMap;

% Store the finish time.

results.StopTime=cputime;

return

%
% All done.
%
