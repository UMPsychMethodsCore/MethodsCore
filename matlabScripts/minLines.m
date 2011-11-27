function [params chiSq] = minLines(pve)

global fitVoxelCurveMem

%
% fit and maybe plot?
% 

params = [];

% pve(:,1) = x-percentage
%
% pve(:,2) = voxel count

% we can assume that below 10% we have a straight line, between 10 and 60%
% another straight line and finally between 60 and 80% a final straight
% line. though we can fit these individualy, basically a spline fit, with
% the cross-over being variable.

params = [15 60];

fitVoxelCurveMem.xVals  = pve(:,1);
fitVoxelCurveMem.yVals  = pve(:,2);
fitVoxelCurveMem.yScale = max(fitVoxelCurveMem.yVals);
fitVoxelCurveMem.yVals  = fitVoxelCurveMem.yVals/fitVoxelCurveMem.yScale;

chiSq = zeros(9,9);

for iP1 = 2:10
    for iP2 = 15:23
    params = [fitVoxelCurveMem.xVals(iP1) fitVoxelCurveMem.xVals(iP2)];
    chiSq(iP1-1,iP2-14) = fitLines(params);
    end
end

chiSqMin = min(chiSq(:));

[iP1 iP2] = find(chiSq==chiSqMin);

iP1 = iP1 + 2;
iP2 = iP2 + 14;

params = [fitVoxelCurveMem.xVals(iP1) fitVoxelCurveMem.xVals(iP2)];
dummy = fitLines(params);


return

