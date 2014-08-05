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
    [CS SandBoxPID Images2Write] = moveToSandBox(UMImgDIRS{iSub}{iRun},UMVolumeWild,SandBoxPID);
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
  end
end

fprintf('\nAll done with warping of fMRIs to template using HiResolution data.\n');

%
% All done.
%
