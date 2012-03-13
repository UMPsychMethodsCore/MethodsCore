
% - - - - - - - START OF PART II - - - - - - - - - - - - - - - 

% Deblank just in case.

UMBatchMaster = deblank(UMBatchMaster);

% If all of the subjects are in the same organization scheme
% then you should not have to modify this piece of code from this point 
% forward.

fprintf('\nWarping images using UMBatchVBM8\n');

fprintf('Looping on the subjects now\n\n');

%
% Loop over the subjects and coregister each one.
%

for iSub = 1:length(UMBatchSubjs)
    %
    fprintf('Working on %s\n',UMBatchSubjs{iSub});
    %
    % Break into two steps, one to calculate the normalization for the
    % SPGR.
    %
    ParamImage = UMImg2Warp{iSub};
    %
    % Make sure the image exists.
    %
    ParamImage=UMImg2Warp{iSub};
    if exist(ParamImage) == 2
      results = UMBatchVBM8(ParamImage,VBM8RefImage,UMTestFlag,VoxelSize,OutputName);
      UMCheckFailure(results);
    else
      fprintf('FATAL ERROR : Image to warpVBM8 process does not exist: %s\n',ParamImage)
      break
    end
end

fprintf('\nAll done with warpingVBM8 processing of High Resolution image.\n');

%
% All done.
%
