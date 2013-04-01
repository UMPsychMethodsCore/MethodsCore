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
  UMWMMask=UMHighRes{iSub,1};
  UMCSFMask=UMHighRes{iSub,2};
  % Loop on the runs and get the names of the files to normalize.
  % We use the "spm_get('files',[directory],[file wildcard])" command
  % to get the list of files.
  %
  for iRun = 1:length(UMImgDIRS{iSub})
    %
    % Find out if they are using a sandbox for the warping.
    %
    Images2Read = dir([fullfile(UMImgDIRS{iSub}{iRun},UMVolumeWild) '*.nii']);
    nFiles = size(Images2Read,1);
    fprintf('Calculatiung PCA from a total of %d %s''s\n',nFiles,UMVolumeWild);
    % 
    % The other step to apply the normalization to the SPGR.
    %
    if length(Images2Read) == 1
    results = UMBatchPrinComp(UMWMMask,UMCSFMask,fullfile(UMImgDIRS{iSub}{iRun},Images2Read.name),detrendFlag,NComponents,dataFraction,UMTestFlag)
    else
      fprintf('\n\n* * * * * * FAILURE * * * * \n');
      fprintf('* * * *\n');
      fprintf('* * * *  Run file %s expected but missing\n',[fullfile(UMImgDIRS{iSub}{iRun},UMVolumeWild) '*.nii']);
      fprintf('* * * *\n');
      fprintf('* * * *\n');
      fprintf('\n\n* * * * * * FAILURE * * * * \n');
      results = -1;
    end
    if UMCheckFailure(results)
      exit(abs(results));
    end
  end
end

fprintf('\nAll done with warping of fMRIs to template using HiResolution data.\n');

%
% All done.
%
