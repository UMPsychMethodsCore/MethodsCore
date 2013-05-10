% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2007
%
%
% A routine to calculate a one-sample or two-sample t-test.
%
% It is assumed that there is equal variance, however, this
% can be overridden with options. NOT IMPLEMENTED YET.
%
% results = SOM_TTest(DataSample1,[DataSample2]);
%
% Input :
%
%           DataSample1 = DataSample1(nVoxels,ns1)
%           DataSample2 = DataSample2(nVoxels,ns2)
%
%
% Output:
%
%           TMap = TMap(Voxels)
%           Nu   - Number of degree of freedom.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function [TMap Nu] = SOM_TTest(DataSample1,varargin)

TMap = [];
Nu   = [];

% Get the first group information.

nVoxels1 = size(DataSample1,1);
n1       = size(DataSample1,2);

if nargin > 2
  fprintf('You have passed too many arrays.\n');
  return
end

% Is there a second group available.

if nargin == 1
  TTest = 1;
  % 
  % Make sure we have enough subejcts to do T-Test.
  %
  if n1 < 3
    fprintf('You need to give me at least 3 subjects.\n');
    return
  end
else
  if isnumeric(varargin{1})
    nVoxels2  = size(varargin{1},1);
    n2 = size(varargin{1},2);
    if any ( [nVoxels1] - [nVoxels2] )
      fprintf('Error, you have specified data arrays with different number of voxels.\n');
      return
    end
    if n2 < 2 | n1 < 2
      fprintf('You need to have at least 2 subjects per group.\n');
      return
    end
    TTest = 2;
    DataSample2 = varargin{1};
  end
end

switch TTest
  %
  % One sample t-test
  %
 case {1}
  G1Var = var(DataSample1,[],2);
  G1Mu  = mean(DataSample1,2);
  TMap  = G1Mu./sqrt(G1Var/n1);
  Nu    = n1-1;
  % 
  % Two sample t-test
  % 
 case {2}
  G1Var = var(DataSample1,[],2);
  G2Var = var(DataSample2,[],2);
  G1Mu  = mean(DataSample1,2);
  G2Mu  = mean(DataSample2,2);
  TMap  = (G1Mu-G2Mu) ./ ...
	  sqrt((G1Var*(n1-1)+G2Var*(n2-1))/(n1+n2-2)*(1/n1+1/n2));
  Nu    = n1+n2-2;
end

return

%
% All done.
% 