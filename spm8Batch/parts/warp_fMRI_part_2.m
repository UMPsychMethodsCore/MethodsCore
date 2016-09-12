% - - - - - - - -BEGINNING OF PART II - - - - - - - - - - - - -

% Deblank just in case.

UMBatchMaster = strtrim(UMBatchMaster);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

fprintf('Looping on the subjects now\n\n');

%
% Loop over the subjects and coregister each one.
%

for iSub = 1:length(UMBatchSubjs)
  %
  fprintf('Working on %s\n',UMBatchSubjs{iSub})
  % 
  % Use the subjects SPGR that was previously normalized
  % to write normalize the fMRI volumes.
  %
  ParamImage = UMHighRes{iSub};
  % Loop on the runs and get the names of the files to normalize.
  % We use the "spm_get('files',[directory],[file wildcard])" command
  % to get the list of files.
  %
  for iRun = 1:length(UMImgDIRS{iSub})
    %
    % Find out if they are using a sandbox for the warping.
    %
    [CS SandBoxPID Images2Write Images2Write_orig] = moveToSandBox(UMImgDIRS{iSub}{iRun},UMVolumeWild,SandBoxPID);
    nFiles = size(Images2Write,1);
    fprintf('Normalizing a total of %d %s''s\n',nFiles,UMVolumeWild);
    % 
    % The other step to apply the normalization to the SPGR.
    %
    if WARPMETHOD
      results = UMBatchWarp([],ParamImage,VBM8RefImage,Images2Write,UMTestFlag,VoxelSize,OutputName,WARPMETHOD);      
    else
      results = UMBatchWarp([],ParamImage,[],Images2Write,UMTestFlag,VoxelSize,OutputName,WARPMETHOD);      
    end
    if UMCheckFailure(results)
      exit(abs(results));
    end
    %
    % Now move back out of sandbox if so specified
    %
    CSBACK = moveOutOfSandBox(UMImgDIRS{iSub}{iRun},UMVolumeWild,SandBoxPID,OutputName,CS);

    
    %
    %build json file and submit to bash_curl
    %
    [~,Run,~] = fileparts(UMImgDIRS{iSub}{iRun});

    InFiles = unique(strtrim(regexprep(mat2cell(strvcat(VBM8RefImage,ParamImage,Images2Write_orig),ones(size(Images2Write_orig,1)+size(ParamImage,1)+size(VBM8RefImage,1),1),max(max(size(VBM8RefImage,2),size(ParamImage,2)),size(Images2Write_orig,2))),',[0-9]*','')))

    OutFiles = [];
    for iFile = 3:size(InFiles,1)
        [p f e] = fileparts(InFiles{iFile});
        OutputImage = fullfile(p,[OutputName f e]);
        OutFiles{iFile-2} = OutputImage;
    end
    %need to check how to distinguish between overlay/hires call since it's the same code
    JSONFile = buildJSON('warpfMRI',MC_SHA,CommandLine,FULLSCRIPTNAME,InFiles,OutFiles,[UMBatchSubjs{iSub} '_' Run],[1:size(InFiles,1)],[3:size(InFiles,1)]);
    
    %
    %submit json file to database
    %
    submitJSON(JSONFile,DBTarget);
    
  end

end

fprintf('\nAll done with warping of fMRIs to template using HiResolution data.\n');

%
% All done.
%
