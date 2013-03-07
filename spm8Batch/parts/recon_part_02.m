
% - - - - - - - START OF PART II - - - - - - - - - - - - - - - 

% Deblank just in case.

UMBatchMaster = strtrim(UMBatchMaster);

% If all of the subjects are in the same organization scheme
% then you should not have to modify this piece of code from this point 
% forward.

fprintf('\nDoing spiral reconstruction using UMBatchRecon\n');

fprintf('Looping on the subjects now\n\n');

%
% Loop over the subjects and coregister each one.
%

for iSub = 1:length(UMBatchSubjs)
    %
    fprintf('Working on %s\n',UMBatchSubjs{iSub});
    %
    %
    results = UMBatchRecon(UMBatchMaster,UMSubjDir,UMBatchSubjs{iSub},UMfmriPATH,UMPfile,UMReconRunNo,UMMatrixSize,UMTestFlag);
    if UMCheckFailure(results)
      exit(abs(results))
    else
      fprintf('Subject reconnned in %f seconds\n',results);
    end        
end

fprintf('\nAll done with reconSpiral processing.\n');

%
% All done.
%
