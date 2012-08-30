%
% Loop over the subjects and physio-correct each one.
%

for iSub = 1:length(UMBatchSubjs)
  %
  fprintf('Working on %s\n',UMBatchSubjs{iSub});
  % 
ALLOK = UMBatchPhysioCorr(UMBatchMaster,UMSubjectDir,UMBatchSubjs{iSub},UMFuncDir,UMRunList,UMVolumeWILD,UMOutName,UMPhysioTable,UMrate,UMdown,UMdisdaq,UMfMRITR,UMTestFlag,UMqualitycheck);
end

%
%
%
