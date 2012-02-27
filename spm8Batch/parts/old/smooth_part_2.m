
% --------------- BEGINNING OF PART II ----------------------
%
% If all of the subjects are in the same organization scheme
% then you should not have to modify this piece of code from this point 
% forward.

%
% Loop over the subjects and smooth each one.
%

curDIR = pwd;

warning off

for iSub = 1:length(UMBatchSubjs)
  WorkingSubject = [deblank(UMBatchMaster) '/' UMBatchSubjs{iSub}];
  for iRun = 1:length(UMImgDIRS{iSub})
    cd(UMImgDIRS{iSub}{iRun});
    P = spm_select('ExtFPList',UMImgDIRS{iSub}{iRun},['^' UMVolumeWild '.*.nii'],inf);
    fprintf('Smoothing %d "%s" images in %s with %2.1f %2.1f %2.1f\n',size(P,1),UMImgWildCard,UMImgDIRS{iSub}{iRun},UMKernel(1),UMKernel(2),UMKernel(3));
    UMBatchSmooth(P,UMKernel,OutputName,UMTestFlag);
  end
end

fprintf('\nAll done with smoothing images.\n');

cd(curDIR);

%
% all done.
%
