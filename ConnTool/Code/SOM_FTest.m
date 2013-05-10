% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2007
%
%
% A routine to calculate a two-sample F-Test.
%
% [FMap Nu] = SOM_Fest(DataSample1,DataSample2);
%
% Input :
%
%           DataSample1 = DataSample1(nVoxels,nSubjects1)
%           DataSample2 = DataSample2(nVoxels,nSubjects2)
%
% Output:
%
%           FMap = TMap(nVoxels)
%           Nu   - Number of degree of freedom.
%
% The F-Test is calculated such that is an upper one tailed.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function [FMap Nu] = SOM_FTest(DataSample1,DataSample2)

FMap = [];
Nu   = [];

% Get the first group information.

nVoxels1  = size(DataSample1,1);
nSubject1 = size(DataSample1,2);

% Is there a second group available.

nVoxels2  = size(DataSample2,1);
nSubject2 = size(DataSample2,2);

if any ( [nVoxels1] - [nVoxels2] )
  fprintf('Error, you have specified data arrays with different number of voxels.\n');
  return
end

if nSubject2 < 2 | nSubject1 < 2
  fprintf('You need to have at least 2 subjects per group.\n');
  return
end

G1Var = var(DataSample1,[],2);
G2Var = var(DataSample2,[],2);

G1Mu  = mean(DataSample1,2);
G2Mu  = mean(DataSample2,2);

FMap  = max([G1Var G2Var],[],2)./min([G1Var G2Var],[],2);

return

%
% All done.
% 