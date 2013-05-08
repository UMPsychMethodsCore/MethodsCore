
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
end

fprintf('\nAll done with warping of High Resolution images to template\n');

%
% All done.
%
