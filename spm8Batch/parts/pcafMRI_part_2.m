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
    
    %
    %build json file and submit to bash_curl
    %
    [~,Run,~] = fileparts(UMImgDIRS{iSub}{iRun});
    
    OutputNames = {'WM_PCA_','CSF_PCA_','BOTH_PCA_'};
    [TimeSeriesDir TimeSeriesName] = fileparts(Images2Read);
    OutputFiles = {};
    for (iOutputFile = 1:size(OutputNames,2)) 
        OutputFiles{iOutputFile} = fullfile(TimeSeriesDir,[OutputNames{iOutputFile} TimeSeriesName,'.csv']);
    end
    
    InFiles = unique(strtrim(regexprep(mat2cell(strvcat(UMWMMask,UMCSFMask,Images2Read),ones(size(Images2Read,1)+size(UMWMMask,1)+size(UMCSFMask,1),1),max(max(size(UMWMMask,2),size(UMCSFMask,2)),size(Images2Read,2))),',[0-9]*','')))
    
    OutputNames = {'WM_PCA_','CSF_PCA_','BOTH_PCA_'};
    [TimeSeriesDir TimeSeriesName] = fileparts(Images2Read);
    OutFiles = [];
    for (iOutputFile = 1:size(OutputNames,2)) 
        OutputFiles{iOutputFile} = fullfile(TimeSeriesDir,[OutputNames{iOutputFile} TimeSeriesName,'.csv']);
    end
 
    %need to check how to distinguish between overlay/hires call since it's the same code
    JSONFile = buildJSON('warpfMRI',MC_SHA,CommandLine,FULLSCRIPTNAME,InFiles,OutFiles,[UMBatchSubjs{iSub} '_' Run],[1:size(InFiles,1)],[(size(InFiles,1)+1):(size(InFiles,1)+size(OutFiles,1))]);
    
    %
    %submit json file to database
    %
    submitJSON(JSONFile,DBTarget);
    
  end
end

fprintf('\nAll done with calculating PCA.\n');

%
% All done.
%
