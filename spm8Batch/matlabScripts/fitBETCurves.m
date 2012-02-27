
readVoxelCounts

global fitVoxelCurveMem


fprintf('Fitting pve0\n');
[params0 chiSq] = minLines(pve0);

fprintf('Fitting pve1\n');
[params1 chiSq] = minLines(pve1);

fprintf('Fitting pve2\n');
[params2 chiSq] = minLines(pve2);

BET.params0 = params0;
BET.params1 = params1;
BET.params2 = params2;

BET.params = [params0;params1;params2];
BET.subject = pwd;
BET.midPoint = mean([min(BET.params(:,2))  max(BET.params(:,1))]);

BET.pve0 = pve0;
BET.pve1 = pve1;
BET.pve2 = pve2;

xBaseMin = abs(fitVoxelCurveMem.xVals - BET.midPoint);
xBaseMinIDX = find(min(xBaseMin)==xBaseMin);

BET.BETThreshold = fitVoxelCurveMem.xVals(xBaseMinIDX);

fidBEST = fopen('BET_best.txt','w');
fprintf(fidBEST,'%d\n',BET.BETThreshold);
fclose(fidBEST);

save BET_best

fprintf('Best guess at threshold : %d\n',BET.BETThreshold);

%
% all done.
%