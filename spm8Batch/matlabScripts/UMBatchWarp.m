% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Robert C. Welsh
% Ann Arbor Michigan, USA
%
% March 2005-2011
% Copyright.
%
% UMBatchWarp
%
% A drivable routine for warping some images using the 
% batch options of spm2.
%
% Version 2.0
%
% 
%  Call as :
%
%  function results = UMBatchWarp(TemplateImage,ParamImage,ObjectMask,Images2Write,TestFlag,VoxelSize,OutputName);
%
%  To Make this work you need to provide the following input:
%
%     TemplateImage    = Image to warp the Parameter image.
%     ParamImage       = Image to determine warping parameters.
%     ObjectMask       = Masking Image/ReferenceImage for VBM8
%     Images2Write     = Images to write normalize.
%     TestFlag         = Flag to test file existance but do nothing.
%
%    If the TemplateImage is blank then we are doing "Write Normalized Only"
%  
%    If Images2Write is blank then we are doing "Determine Parameters Only"
%
%    If ObjectMask = [] or '' then no masking.
%
%    ParamImage CAN NOT BE BLANK and must exist, as must its "_sn.mat" file.
%
%    If TestFlag   = 0 then execute, else just test files.
%
%  Output
%  
%     results        = -1 if failure
%                       # of seconds to execute.
%
%  If you wish to use any normalization parameters other than the default
%  you must set them yourself!
%
%  You should make call to UMBatchPrep first.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

function results = UMBatchWarp(TemplateImage,ParamImage,ObjectMask,Images2Write,TestFlag,VoxelSize,OutputName,WARPMETHOD);

% Get the defaults from SPM.

global defaults
global UMBatch

% Make the call to prepare the system for batch processing.

UMBatchPrep

if UMBatch == 0
  fprintf('UMBatchPrep failed.')
  return
end

% Only proceed if successful.

fprintf('Entering UMBatchWarp V2.0 SPM8 Compatible\n');

if TestFlag~=0
    fprintf('\nTesting only, no work to be done\n\n');
end 

%
% Set the return status to -1, that is error by default.
%

if exist('WARPMETHOD') == 1 & WARPMETHOD
  results = UMBatchWarpVBM8(ParamImage,ObjectMask,Images2Write,TestFlag,VoxelSize,OutputName);
  return
end

results = -1;

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

%
% Make sure that the ParamImage is there.
%

tic;

if isempty(ParamImage) | exist(ParamImage) == 0
    fprintf('\n\nThe Parameter Image Must EXIST!\n');
    fprintf('  * * * A B O R T I N G * * *\n\n');
    return
end

%  
% Check to see if the template image exists?
% 

if isempty(TemplateImage) | exist(TemplateImage) == 0
    DetermineParam = 0;
else
    DetermineParam = 1;
end

% 
% Check to see if they want a mask on the object.
%

if isempty(ObjectMask) | ObjectMask == ''
    ObjectMask = '';
else
    if exist(ObjectMask) == 0
        fprintf('Object mask specified is missing\n');
        fprintf('  * * * A B O R T I N G * * *\n\n');
        return
    end
end

%
% Now see about the images to write. Bugger out at ANY error!
%

WarpMATName = [spm_str_manip(ParamImage,'sd') '_sn.mat'];

if isempty(Images2Write)
  WriteImage = 0;
else
  WriteImage = 1;
  for iP = 1:size(Images2Write,1)
    tmpFile=Images2Write(iP,:);
    commaIDX = findstr(',',tmpFile);
    if ~isempty(commaIDX)
      tmpFile = tmpFile(1:commaIDX(1)-1);
    end
    if exist(tmpFile) == 0
      WriteImage = 0
      fprintf('Error, image file : %s \n does not exist\n',tmpFile);
    end
  end
  %
  % Only require the warping matrix to pre-exist if we are NOT
  % attempting to determine the warping parameters.
  %
  if DetermineParam == 0 & exist(WarpMATName) == 0
    fprintf('Error, warping matrix file: %s\n does not exist.\n',WarpMATName);
    WriteImage == 0;
  end
  if WriteImage == 0
    fprintf('\n  * * * A B O R T I N G * * *\n\n');
  end  
end

% 
% Check to see if they actually want anything done?
%

if DetermineParam == 0 & WriteImage == 0
    fprintf('You have chosen to do nothing, check your input params.\n');
    return
end

%
% Now if we are determining the warping parameters let's do that.
%

if DetermineParam == 1
    if TestFlag ~= 0
        fprintf('Would be calculating warp for \n%s to\n%s\n',ParamImage,TemplateImage)
    else
      % Warping estimating and writing
      
      fprintf('Warping %s to \n        %s\n',ParamImage,TemplateImage);

      % We need to add the ",1" to the name for spm to handle
      % nifti/nifti_gz images.

      % Pull out the directory 
      
      ParamImageDirectory = fileparts(ParamImage);
      
      % Need to indicate to SPM which frame to use.
      
      TemplateImage = [ TemplateImage ',1'];
      ParamImage    = [ParamImage ',1'];
      
      % Set up the estimation
      
      matlabbatch{1}.spm.spatial.normalise.estwrite.subj.source{1} = ParamImage;
      matlabbatch{1}.spm.spatial.normalise.estwrite.subj.wtsrc = '';
      matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample{1} = ParamImage;
      
      matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions = defaults.normalise.estimate;
      matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.template{1} = TemplateImage;

      % And set up the write options.
      
      matlabbatch{1}.spm.spatial.normalise.estwrite.roptions = defaults.normalise.write;
      
      % Only override the default if explicitly set > 0
      
      if VoxelSize > 0
	matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.vox ...
	    = VoxelSize * ones(1,3);
      else
	VoxelSize = defaults.normalise.write.vox(1);
      end
      
      % And the output name prefix.
      
      matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.prefix ...
	  = OutputName;
      
      % Now call the batch manager.
      
      spm_jobman('run_nogui',matlabbatch);
      
      % Log that we finished this portion.
      
      UMBatchLogProcess(ParamImageDirectory,sprintf('UMBatchWarp : Determined parameter for : %s',ParamImage));
    
    end
    clear matlabbatch
end

%
% If we are warping some images to write then let's do that.
%

if WriteImage == 1
    fprintf('Using warping matrix \n%s\n',WarpMATName);
    if TestFlag ~= 0
      fprintf('Would be warping %d images like %s\n',size(Images2Write,1),deblank(Images2Write(1,:)));
      % Warping writing only.
    else      
      matlabbatch{1}.spm.spatial.normalise.write.subj.matname{1} = WarpMATName;
      matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {};
      for iP = 1:size(Images2Write,1)
	matlabbatch{1}.spm.spatial.normalise.write.subj.resample{iP,1} ...
	    = strtrim(Images2Write(iP,:));
      end
      matlabbatch{1}.spm.spatial.normalise.write.roptions = defaults.normalise.write;
      
      % Only override the default if explicitly set > 0

      if VoxelSize > 0
	matlabbatch{1}.spm.spatial.normalise.write.roptions.vox ...
	    = VoxelSize * ones(1,3);
      else
	VoxelSize = defaults.normalise.write.vox(1);
      end
      
      % And the output name prefix.
      
      matlabbatch{1}.spm.spatial.normalise.write.roptions.prefix ...
	  = OutputName;
      
      fprintf('Warping %d images like %s to voxel size %f\n',size(Images2Write,1),deblank(Images2Write(1,:)),VoxelSize);

      spm_jobman('run_nogui',matlabbatch);

      % Log that we finished this portion.
      
      % Get the directory of the images that we warped.
      
      ImageDirectory = fileparts(Images2Write(1,:));
      
      UMBatchLogProcess(ImageDirectory,sprintf('UMBatchWarp : Warped images (%04d) : %s -> %s',size(Images2Write,1),Images2Write(1,:),OutputName));
      
      if size(Images2Write,1) > 1
	UMBatchLogProcess(ImageDirectory,sprintf('UMBatchWarp : through image        : %s',Images2Write(end,:)));
      end
      
    end
    clear matlabbatch
end

%
% Set the flag to the amount of time to execute.
%

results = toc;

fprintf('Warping finished in %f seconds\n',results);

return

%
% All done.
%
