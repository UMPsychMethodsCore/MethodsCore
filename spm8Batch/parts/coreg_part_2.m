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
    if UMCheckFailure(results)
      exit(abs(results))
    end
    
    
    %
    %build json file and submit to bash_curl
    %

    InFiles = unique(strtrim(regexprep(mat2cell(strvcat(TargetImageFull,ObjectImageFull,UMOtherImages{iSub}),ones(size(UMOtherImages{iSub},1)+size(ObjectImageFull,1)+size(TargetImageFull,1),1),max(max(size(TargetImageFull,2),size(ObjectImageFull,2)),size(UMOtherImages{iSub},2))),',[0-9]*','')))

    OutFiles = [];
    for iFile = 2:size(InFiles,1)
        [p f e] = fileparts(InFiles{iFile});
        OutputImage = fullfile(p,[OutputName f e]);
        OutFiles{iFile-1} = OutputImage;
    end
    %need to check how to distinguish between overlay/hires call since it's the same code
    JSONFile = buildJSON('coregOverlay',MC_SHA,CommandLine,FULLSCRIPTNAME,InFiles,OutFiles,UMBatchSubjs{iSub},[1:size(InFiles,1)],[2:size(InFiles,1)]);
    
    %
    %submit json file to database
    %
    submitJSON(JSONFile,DBTarget);
        
end

fprintf('\nAll done with coregistration.\n');

%
% all done.
%
