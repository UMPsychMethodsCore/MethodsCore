% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2013
%
% Ann Arbor, MI
%
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

function results = UMBatchPCA(Y)

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
    fprintf('\n Warning.  More than 64 dimensions.  Reducing to 64\n');
    r=64; 
end

P=Y*G;

%load('PCA.mat')
%Tcomponents = P;
%Scomponents = G;

results.TC  = P;
results.SC  = G;

% Let normalize the magnitude of the components.

for iC = 1:size(results.TC,2)
  results.TC(:,iC) = results.TC(:,iC)/max(results.TC(:,iC));
end

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
    