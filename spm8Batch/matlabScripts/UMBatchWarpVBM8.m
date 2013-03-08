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
% This should ONLY BE CALLED BY UMBatchWarp and NOT directly.
% 
%  Call as :
%
%  function results = UMBatchWarpVBM8(ParamImage,ReferenceImage,Images2Write,TestFlag,VoxelSize,OutputName);
%
%  To Make this work you need to provide the following input:
%
%     ParamImage       = Image to determine warping parameters.
%     ObjectMask       = Masking Image.
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
%     results           < 0, if failure
%                       > 0, # of seconds to execute.
%
%  If you wish to use any normalization parameters other than the default
%  you must set them yourself!
%
%  You should make call to UMBatchPrep first.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

function results = UMBatchWarpVBM8(ParamImage,ReferenceImage,Images2Write,TestFlag,VoxelSize,OutputName);

% Get the defaults from SPM.

global defaults

% Make the call to prepare the system for batch processing.

UMBatchPrep

fprintf('Entering UMBatchWarpVBM8 V2.0 SPM8 Compatible\n');

if TestFlag~=0
    fprintf('\nTesting only, no work to be done\n\n');
end 

%
% Set the return status to -1, that is error by default.
%

results = -1;

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

%
% Make sure that the ParamImage is there.
%

tic;

if isempty(ParamImage) | exist(ParamImage) == 0
    fprintf('\n\nThe Parameter Image Must EXIST!\n');
    fprintf('  * * * A B O R T I N G * * *\n\n');
    results = -66;
    UMCheckFailure(results);
    return
end

% We need to make sure tha the VBM8 toolbox is present.

if exist('spm_vbm8.m') ~= 2
  fprintf('\n\n* * * * * * MISSING THE VBM8 TOOLBOX * * * * * * \n')
  fprintf('  * * * A B O R T I N G * * *\n\n');
  results = -69;
  UMCheckFailure(results);
  return
end
  
% 

% Store where we are presently to restore before going back.

CURDIR = pwd;

clear matlabbatch

% grab what we need, first break apart the file name.

[ParamImageDirectory ParamImageName ParamImageExt ParamImageNum] = spm_fileparts(ParamImage);

% Name of the deformation file

matlabbatch{1}.spm.util.defs.comp{1}.def{1} = fullfile(ParamImageDirectory,['y_r' ParamImageName ParamImageExt]);

% Check to make sure that the defomation field is there.

if isempty(matlabbatch{1}.spm.util.defs.comp{1}.def{1}) | exist(matlabbatch{1}.spm.util.defs.comp{1}.def{1}) == 0
    fprintf('\n\nDeformation field is missing!\n');
    fprintf('  * * * A B O R T I N G * * *\n\n');
    results = -66;
    UMCheckFailure(results);
    return
end

% Now if there is a reference image then we rewrite comp{2}

if length(ReferenceImage) > 0
  [d1 d2 d3 d4] = spm_fileparts(ReferenceImage);
else
  d1 = '';
  d2 = '';
  d3 = '';
end

% Option to use a reference image. This is the preferred method.

if length(ReferenceImage) > 0 & exist(fullfile(d1,[d2 d3]))
  matlabbatch{1}.spm.util.defs.comp{2}.id.space{1} = [fullfile(d1,[d2 d3]),',1'];
  USINGREF=1;
else
  % Size of the data we want to write out.
  
  if VoxelSize > 0
    matlabbatch{1}.spm.util.defs.comp{2}.idbbvox.vox = VoxelSize*ones(3,1);
  else
    matlabbatch{1}.spm.util.defs.comp{2}.idbbvox.vox = defaults.normalise.write.vox;
  end
  
  % We use the default bounding box.
  % Though we need to add the option of using a reference images as
  % well.
  
  matlabbatch{1}.spm.util.defs.comp{2}.idbbvox.bb  = defaults.normalise.write.bb;
  USINGREF=0;
end

% No option here.

matlabbatch{1}.spm.util.defs.ofname = '';

% Save to the directory where the times-series data exist.

matlabbatch{1}.spm.util.defs.savedir.savesrc = 1;

% Now get the file/frame names as the utility wants them, which is
% different from other routines.

matlabbatch{1}.spm.util.defs.fnames = {};
for iP = 1:size(Images2Write,1)
  matlabbatch{1}.spm.util.defs.fnames{iP} = strtrim(Images2Write(iP,:));
end

% Interpolation method:

matlabbatch{1}.spm.util.defs.interp = 1;

%
% Now see about the images to write. Bugger out at ANY error!
%

if isempty(Images2Write)
  fprintf('\nYou did not specify any images to write deformed\m');
  fprintf('\n  * * * A B O R T I N G * * *\n\n');
  results = -66;
  UMCheckFailure(results);
  return
else
  for iP = 1:size(Images2Write,1)
    tmpFile=Images2Write(iP,:);
    commaIDX = findstr(',',tmpFile);
    if ~isempty(commaIDX)
      tmpFile = tmpFile(1:commaIDX(1)-1);
    end
    if exist(tmpFile) == 0
      WriteImage = 0
      fprintf('Error, image file : %s \n does not exist\n',tmpFile);
      fprintf('\n  * * * A B O R T I N G * * *\n\n');
      results = -66;
      UMCheckFailure(results);
      return
    end
  end
end

%
% If we are warping some images to write then let's do that.
%

fprintf('Using deformation field \n    %s\n',matlabbatch{1}.spm.util.defs.comp{1}.def{1});

if TestFlag ~= 0
  fprintf('Would be warping %d images like %s\n',size(Images2Write,1),deblank(Images2Write(1,:)));
					   % Warping writing only.
else      
  if USINGREF
    fprintf('Warping %d images like %s to space of %s\n',size(Images2Write,1),...
      deblank(Images2Write(1,:)),matlabbatch{1}.spm.util.defs.comp{2}.id.space{1});
  else
    fprintf('Warping %d images like %s to voxel size %f\n',size(Images2Write,1),...
      deblank(Images2Write(1,:)),matlabbatch{1}.spm.util.defs.comp{2}.idbbvox.vox(1));
  end
  spm_jobman('run_nogui',matlabbatch);
  
  % Log that we finished this portion.
  
  % Get the directory of the images that we warped.
  
  % Now let's find out if successful?
  
  % We only operate on NIFTI so we can just take the unique ones,
  % and return the count.
  
  [Images2WriteUnique Images2WriteCount] = uniqueNII(Images2Write);
  
  % If the prefix is "w" then we just need to report the images that
  % vbm8 has already generated. - RCWelsh 2012-07-27
  tmpNewImages2WriteUnique = [];
  
  for iNII = 1:size(Images2WriteUnique,1)
    [d1 d2 d3 d4] = spm_fileparts(strtrim(Images2WriteUnique(iNII,:)));
    newFile = fullfile(d1,['w' d2 d3]);
    if exist(newFile) == 0
      fprintf('\n\n* * * * * * * * * * * * \n\n');
      fprintf('FATAL ERROR - I CAN''T FIND THE OUTPUT FILE EXPECTED : %s\n',newFile);
      fprintf('ABORTING\n');
      fprintf('\n\n* * * * * * * * * * * * \n\n');
      results = -74;
      UMCheckFailure(results);
      return
    end
    % If the prefix is "w" then we just need to report the images that
    % vbm8 has already generated. - RCWelsh 2012-07-27
    tmpNewImages2WriteUnique = strvcat(tmpNewImages2WriteUnique, newFile);
  end
  
  % Everything up to this point is okay
  % Okay, if the OutputName option is not specified, or it's
  % already set to 'w', then we do nothing, else we rename the file
  % for them as moveOutOfSandbox is expecting the new name.
  
  newImages2WriteUnique = [];
  if exist('OutputName') == 1 & strcmp(OutputName,'w') ~= 1
      % We need to identify all of the files that need to be renamed.
      for iNII = 1:size(Images2WriteUnique,1)
          [d1 d2 d3 d4] = spm_fileparts(strtrim(Images2WriteUnique(iNII,:)));
          oldFile = fullfile(d1,['w' d2 d3]);
          newFile = fullfile(d1,[OutputName d2 d3]);
          [mS mM mI] = movefile(oldFile,newFile);
          if ~mS
              fprintf('\n\n* * * * * * * * * * * * \n\n');
              fprintf('FATAL ERROR - I CAN''T NAME OUTPUT FILE AS EXPECTED : \n   %s\n   %s\n',oldFile,newFile);
              fprintf('ABORTING\n');
              fprintf('\n\n* * * * * * * * * * * * \n\n');
              results = -74;
	      UMCheckFailure(results);
              return
          end
          newImages2WriteUnique = strvcat(newImages2WriteUnique, newFile);
      end
  else
    % If the prefix is "w" then we just need to report the images that
    % vbm8 has already generated. - RCWelsh 2012-07-27
    newImages2WriteUnique = tmpNewImages2WriteUnique;
  end
  
  ImageDirectory = fileparts(Images2Write(1,:));
  
  for iNII = 1:size(Images2WriteUnique,1);
    UMBatchLogProcess(ImageDirectory,...
		      sprintf('UMBatchWarp : Warped images (frames:%04d) : %s -> %s',...
			      Images2WriteCount(iNII),...
			      Images2WriteUnique(iNII,:),...
			      newImages2WriteUnique(iNII,:)));
    
  end

end

clear matlabbatch

%
% Set the flag to the amount of time to execute.
%

results = toc;

fprintf('Deformation finished in %f seconds\n',results);

return

%
% All done.
%
