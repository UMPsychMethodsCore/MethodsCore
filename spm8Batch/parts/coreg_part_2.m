% - - - - - - - - BEGINNING OF PART II - - - - - - - - - - - - -
%
% If all of the subjects are in the same organization scheme
% then you should not have to modify this piece of code from this point 
% forward.

%
% Loop over the subjects and coregister each one.
%

for iSub = 1:size(UMBatchSubjs,1)
    TargetImageFull = UMImgPairs{iSub}{2};
    ObjectImageFull = UMImgPairs{iSub}{1};
    fprintf('\n\nCalling UMBatchCoReg with:\n')
    fprintf('%s\n',TargetImageFull);
    fprintf('%s\n',ObjectImageFull);
    fprintf('UMReSlice:%d\n',UMReSlice);
    results = UMBatchCoReg(TargetImageFull,ObjectImageFull,UMOtherImages{iSub},UMReSlice,UMTestFlag);
    UMCheckFailure(results);
end

fprintf('\nAll done with coregistration.\n');

%
% all done.
%
