
% - - - - - - - START OF PART II - - - - - - - - - - - - - - - 

% Deblank just in case.

UMBatchMaster = deblank(UMBatchMaster);

% If all of the subjects are in the same organization scheme
% then you should not have to modify this piece of code from this point 
% forward.

fprintf('\nSegmenting images using UMBatchSegment\n');
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
    % SPGR.
    %
    FullImage2Segment = UMImg2Seg{iSub};
    %
    % Make sure the image exists.
    %
    if exist(FullImage2Segment) == 2
       [fP fN fE] = fileparts(FullImage2Segment);
       % 
       % cd into the directory for the segmentation.
       %
       cd(fP);       
       UMBatchSegment([fN fE],UMTestFlag,UMNormedFlag);
    end
end

fprintf('\nAll done with segmenting of SPGRs to template\n');

%
% All done.
%
