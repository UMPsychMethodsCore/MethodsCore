% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% Calculate the Principle components from some confound time-series
% data
%
% function results = SOM_PrincipleComponents(theData,dataFraction)
%
%     theData = space x time
%
% you should linear detrend the data first.
%
%  e.g. theData = spm_detrend(theData',1)';
%
% The default is to take all voxels equally, howver, you can 
% also specify that top X% of those with variance should be used
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

%
% 2011.11.18 - RCWelsh - Fixed error on subscript to line below to
%                        reflect change:
%                        size(PCScore,1) -> size(PCScore,2);
%
% 2011.11.20 - RCWelsh - Duh, DO NOT USE "princomp" that is not right??
%                        use luis's PCAwash.m from BIRB, just stripped
%                        out code and it's fine. This will not need special toolbox.
%
% 2013.09.10 - RCWelsh - Scan for NaN

function results = SOM_PrinComp(theData,dataFraction)

global SOM

results.startCPU = cputime;

% Any NaN?

nonNANIDX = find(~isnan(sum(theData,2)));
theData   = theData(nonNANIDX,:)

if isfield(SOM,'NumberPrincipleComponents') == 0
    SOM.NumberPrincipleComponents = 50;
end

if exist('dataFraction') == 0
    dataFraction = 1.0;
else
    dataFraction = min([1.0 max([dataFraction .01])]);
end

TVAR     = var(theData,[],2);

TOTALVAR = sum(var(theData,[],2));

VARIDX   = sortrows([TVAR [1:length(TVAR)]'],-1);

NIDX     = max([2 round(dataFraction*length(TVAR))]);

VOXIDX   = VARIDX(1:NIDX,2);

% And call the PCA from BIRB, that was written by Magnus many years ago.

PCAResults  = BIRBPCA(zscore(theData(VOXIDX,:)'));

%
% Calculate the percent variance explained in the data.
%

VARCOMP = [];

SOM_LOG(sprintf('STATUS : Calculating variance explained by regressors, looking at first %d components',...
		min(SOM.NumberPrincipleComponents,size(PCAResults.TC,2))));

results.VARCOMP  = PCAResults.varComp;
results.TC       = PCAResults.TC(:,1:min(SOM.NumberPrincipleComponents,size(PCAResults.TC,2)));
results.TOTALVAR = PCAResults.totalVar;

results.stopCPU  = cputime;

return

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Calculate the Principle components from some confound time-series data
% 
% Heavily (extemly heavily) borrowed from:
% 
% (C) Luis Hernandez-Garcia and Magnus Ulfarsson at UM
% Last edits: 4/25/2007
%
% function results = UMBatchPCA(Y)
%
% Input 
%  
%    Y  = time x space array.
%
% Output
% 
%    results
% 
%       .TC   - time  x ncomp
%       .SC   - space x ncomp
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = BIRBPCA(Y)

%Magnus' Code to compute PCA
[T,M]=size(Y);

% remove mean from the data
mu=mean(Y)';
Y=Y-ones(T,1)*mu';

df = T-1;

% compute the dimensionality of the matrix
[r] = laplace_pca(Y);

%fprintf('\nData Dimensionality: %d . Begin PCA decomposition', r);

% do the decomposition
% G = temporal components
% s2 = noise variance (residual)
% l = variance of principal components
% lambda = eigenvalues
% trSy = total variance in data
[G,s2,l, lambda,trSy] = nPCA(Y,0,r);

if(r>64)
    SOM_LOG('WARNING :  More than 64 dimensions in PCA.  Reducing to 64\n');
    r=64; 
end

P=Y*G;

%load('PCA.mat')
%Tcomponents = P;
%Scomponents = G;

results.TC  = P;
results.SC  = G;

% Last thing for them, we can calculate the variance removed by each
% component independently

results.totalVar = sum(var(Y,[],1));
results.varComp  = zeros(size(results.TC,2),1);

for iC = 1:size(results.TC,2)
    X = results.TC(:,iC);
    YP = Y - X*(((X'*X)\X')*Y);
    results.varComp(iC) = sum(var(YP,[],1));
end

% And now the amount of variance absorped by the spatial average

X = mean(Y,2);
YP = Y - X*(((X'*X)\X')*Y);
results.varMean = sum(var(YP,[],1));

return

%%
function [k,p] = laplace_pca(data, e, d, n)
% LAPLACE_PCA   Estimate latent dimensionality by Laplace approximation.
%
% k = LAPLACE_PCA([],e,d,n) returns an estimate of the latent dimensionality
% of a dataset with eigenvalues e, original dimensionality d, and size n.
% LAPLACE_PCA(data) computes (e,d,n) from the matrix data 
% (data points are rows)
% [k,p] = LAPLACE_PCA(...) also returns the log-probability of each 
% dimensionality, starting at 1.  k is the argmax of p.

if ~isempty(data)
  [n,d] = size(data);
  m = mean(data);
  data0 = data - repmat(m, n, 1);
  e = svd(data0,0).^2;
end
e = e(:);
% break off the eigenvalues which are identically zero
i = find(e < eps);
e(i) = [];

%kmax = min([d-1 n-2]);
kmax = min([d-1 n-2])-length(i);
%kmax = min([kmax 15]);
ks = 1:kmax;

% normalizing constant for the prior (from James)
% the factor of 2 is cancelled when we integrate over the 2^k possible modes
z = log(2) + (d-ks+1)/2*log(pi) - gammaln((d-ks+1)/2);
for i = 1:length(ks)
  k = ks(i);
  e1 = e(1:k);
  e2 = e((k+1):length(e));
  v = sum(e2)/(d-k);
  p(i) = -sum(log(e1)) - (d-k)*log(v);
  p(i) = p(i)*n/2 - sum(z(1:k)) - k/2*log(n);
  % compute logdet(H)
  lambda_hat = 1./[e1; repmat(v, length(e2), 1)];
  h = 0;
  for j1 = 1:k
    for j2 = (j1+1):length(e)
      h = h + log(lambda_hat(j2) - lambda_hat(j1)) + log(e(j1) - e(j2));
    end
    % count the zero eigenvalues all at once
    h = h + (d-length(e))*(log(1/v - lambda_hat(j1)) + log(e(j1)));
  end
  m = d*k-k*(k+1)/2;
  h = h + m*log(n);
  p(i) = p(i) + (m+k)/2*log(2*pi) - h/2;
end
p=real(p);
[pmax,i] = max(p);
k = ks(i);
return

%%
function [G,s2,l,lambda,trSy]=nPCA(Data,covar,r)
% -----------------------------------
% Usage: [log_lik]=nPCA(Data,covar,T,M)
% -----------------------------------
% Computes the nPCA log-likelihood.
% -----------------------------------
% Input:  covar=1: Data is the covariance matrix, else TxM data matrix
%         r:       The number of PCs
% -----------------------------------
% Output:  G:       Mxr orthonormal loading matrix
%          s2:      Noise variance
%          l:       Variance of the PCs   
%          lambda = eigenvalues
%          trSy = total variance in data
% ----------------------------------
% Magnus Orn Ulfarsson, 2007.
% -----------------------------------
if(covar==1)
	Sy=Data;
    trSy=trace(Sy);
    [G,Lambda]=svd(Sy);
    G=G(:,1:r); 
    lambda=diag(Lambda);
    s2=mean(lambda(r+1:end));
    l=lambda(1:r)-s2;
else
    Y=Data;
    [T,M]=size(Y);
    trSy=trace(Y*Y')/T;
   
    Y=Y-ones(T,1)*mean(Y);
    if(T>=M)
        [G,Lambda_sqrt]=svd(Y'/sqrt(T));
        G=G(:,1:r);
    else
        [P,Lambda_sqrt]=svd(Y/sqrt(T));
        G=1/sqrt(T)*Y'*P(:,1:r)*diag(diag(Lambda_sqrt(1:r,1:r)).^(-1));
    end
    lambda=diag(Lambda_sqrt).^2;
    s2=mean(lambda(r+1:end));
    l=lambda(1:r)-s2;
end
return

%%
