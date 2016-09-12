
% - - - - - - - START OF PART II - - - - - - - - - - - - - - - 

% Deblank just in case.

UMBatchMaster = deblank(UMBatchMaster);

% If all of the subjects are in the same organization scheme
% then you should not have to modify this piece of code from this point 
% forward.

fprintf('\nWarping images using UMBatchWarp\n');
fprintf('\nTemplate Image\n     %s\n\n',TemplateImage);

fprintf('Looping on the subjects now\n\n');

%
% Loop over the subjects and coregister each one.
%

for iSub = 1:length(UMBatchSubjs)
    %
    fprintf('Working on %s\n',UMBatchSubjs{iSub});
    %
    % Break into two steps, one to calculate the normalization for the
    % HiRes.
    %
    ParamImage = UMImg2Warp{iSub};
    %
    % Make sure the image exists.
    %
    if exist(ParamImage) == 2
      Img2Write = [];
      for iW = 1:length(UMOtherImages{iSub})
	Img2Write = strvcat(Img2Write,[UMOtherImages{iSub}{iW},',1']);
      end
      % Force the warping method to be the standard SPM8
      results = UMBatchWarp(TemplateImage,ParamImage,[],Img2Write,UMTestFlag,VoxelSize,OutputName,0);
      if UMCheckFailure(results)
	exit(abs(results))
      end
    else
      fprintf('FATAL ERROR : Image to warp does not exist: %s\n',ParamImage)
      results = -65;
      UMCheckFailure(results);
      exit(abs(results));
    end
    
    %
    %build json file and submit to bash_curl
    %

    InFiles = unique(strtrim(regexprep(mat2cell(strvcat(TemplateImage,ParamImage,Img2Write),ones(size(Img2Write,1)+size(ParamImage,1)+size(TemplateImage,1),1),max(max(size(TemplateImage,2),size(ParamImage,2)),size(Img2Write,2))),',[0-9]*','')))

    OutFiles = [];
    for iFile = 2:size(InFiles,1)
        [p f e] = fileparts(InFiles{iFile});
        OutputImage = fullfile(p,[OutputName f e]);
        OutFiles{iFile-1} = OutputImage;
    end

    JSONFile = buildJSON('warpHiRes',MC_SHA,CommandLine,FULLSCRIPTNAME,InFiles,OutFiles,UMBatchSubjs{iSub},[1:size(InFiles,1)],[2:size(InFiles,1)]);
    
    %
    %submit json file to database
    %
    submitJSON(JSONFile,DBTarget);
end

fprintf('\nAll done with warping of High Resolution images to template\n');

%
% All done.
%
