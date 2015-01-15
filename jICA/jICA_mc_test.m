% this script will test the jICA_mc_central function

% set basic parameters
n = 100; % subjects
p = 1000; % features
b = 8; % predictors
o = 15; % number of components
r = 10; % how much reduction to perform
splitpts = [1 501];

% minimalist case, all defaults set on fly

s = rand(o,p);
a = randn(n,o);

clear j
j.orig = a*s + randn(n,p);

j = jICA_mc_central(j);
  
% more heavy handed option setting

s = rand(o,p);
a = randn(n,o);

clear j
j.orig = a*s + randn(n,p)
j.clean.x = randn(n,b);
j.clean.CovInt = 2;
j.pca.dim = r;

j.flip = 2;
j.split.splitpts = splitpts;

j = jICA_mc_central(j);
