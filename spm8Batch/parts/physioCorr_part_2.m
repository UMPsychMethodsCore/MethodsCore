%
% Loop over the subjects and physio-correct each one.
%

for iSub = 1:length(UMBatchSubjs)
  %
  fprintf('Working on %s\n',UMBatchSubjs{iSub});
  % 
  results = UMBatchPhysioCorr(UMBatchMaster,UMSubjectDir,UMBatchSubjs{iSub},UMFuncDir,UMRunList,UMVolumeWILD,UMOutName,UMPhysioTable,UMrate,UMdown,UMdisdaq,UMfMRITR,UMTestFlag,UMQualityCheck);
  if UMCheckFailure(results)
    exit(abs(results))
  end
end

%
%
%
