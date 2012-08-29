% - - - - - - - -BEGINNING OF PART II - - - - - - - - - - - - -

% Deblank just in case.

UMBatchMaster = strtrim(UMBatchMaster);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

fprintf('Looping on the subjects now\n\n');

%
% Loop over the subjects and test each run.
%

for iSub = 1:length(UMBatchSubjs)
  %
  fprintf('Working on %s\n',UMBatchSubjs{iSub})

  % Loop on the runs and get the names of the files to test.
  % We use the "spm_select('FPLIst',[directory],[file wildcard])" command
  % to get the list of files.
  for iRun = 1:length(UMImgDIRS{iSub})
    %
    % Grab the images
    %
    Images = spm_select('FPList',UMImgDIRS{iSub}{iRun},['^' UMVolumeWild '.*.nii']);
    nFiles = size(Images,1);
    fprintf('Testing a total of %d %s''s\n',nFiles,UMVolumeWild);
    %
    % Create OutputFile name
    %
    index = strfind(UMImgDIRS{iSub}{iRun},'run');
    if isempty(index)
        OutputFile = fullfile( UMImgDIRS{iSub}{iRun},[UMBatchSubjs{iSub} '_ds.txt'] );
    else
        %
        % Find out what run it is and put in in OutputFile name
        %
        temp   = UMImgDIRS{iSub}{iRun};
        temp   = temp(index(1):end);
        index2 = strfind(temp,filesep);
        if isempty(index2)
            RunStr = strtrim(temp);
        else
            RunStr = temp( 1:index2(1)-1 );
        end
        OutputFile = fullfile( UMImgDIRS{iSub}{iRun},[UMBatchSubjs{iSub} '_' RunStr '_ds.txt'] );
    end
    % 
    % Detect the spikes
    %
    results = UMBatchDetectSpike(Images,OutputFile,UMImgDIRS{iSub}{iRun});
    if UMCheckFailure(results)
      exit(abs(results))
    end

  end
end

fprintf('\nAll done spike detection.\n');

%
% All done.
%
