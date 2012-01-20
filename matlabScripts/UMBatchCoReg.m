% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Robert C. Welsh
% Ann Arbor Michigan, USA
%
% March 2005-2011
% Copyright.
%
% UMBatchCoReg
%
% A drivable routine for coregistering some images using the 
% batch options of spm2
%
%  Call as :
%
%  function results = UMBatchCoReg(TargetImage,ObjectImage,OtherImages,ReSlice,TestFlag);
%
%  To Make this work you need to provide the following input:
%
%     TargetImage    = Full Path and Name to the Target Image.
%     ObjectImage    = Full Path and Name to the Object Image.
%     OtherImages    = Full Path and Name to other images. (cell array).
%     ReSlice        = A flag on whether to (1) or not (0) reslice.
%                      2 -> Reslice only NOT IMPLEMENTED YET.
%     TestFlag       = Flag to test file existance but do nothing.
%
%  Output
%  
%     results        = -1 if failure
%                       # of seconds to execute.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

function results = UMBatchCoReg(TargetImage,ObjectImage,OtherImages,ReSlice,TestFlag);

% We need access to SPM defaults, in the event these have been
% changed by users, we don't want to hard-code options here.

global defaults

%
% Set the return status to -1, that is error by default.
%

results = -1;

fprintf('Entering UMBatchCoReg V2.0 for SPM8\n');

if TestFlag~=0
    fprintf('\nTesting only, no work to be done\n\n');
end 

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

% 
% Make sure that the images exist that have been passed.
%

% Set the CPU timer.

tic;

% Remove any extra space.

TargetImage=strtrim(TargetImage);
ObjectImage=strtrim(ObjectImage);

% Make sure they exist. -- they really should!

if exist(TargetImage)~=2 | exist(ObjectImage)~=2
    fprintf('Problem\n');
    if exist(TargetImage) ~= 2
        fprintf('Target Image "%s"\n does not exist.\n',TargetImage);
        fprintf('  * * * A B O R T I N G * * *\n\n');
        return
    end
    if exist(ObjectImage) ~= 2
        fprintf('Object Image "%s"\n does not exist.\n',ObjectImage);
        fprintf('  * * * A B O R T I N G * * *\n\n');
        return
    end
end

%
% Check the other images.
%

if length(OtherImages) > 0 
  if iscell(OtherImages)
    for iother = 1:length(OtherImages)
      if exist(OtherImages{iother}) ~= 2
        fprintf('Other Image :%2\n does not exist\n', ...
                OtherImages{iother});
        fprintf('  * * * A B O R T I N G * * *\n\n');
        return
      end
    end
  else
    fprintf('OtherImages parameter must be cell array\n');
    fprintf('  * * * A B O R T I N G * * *\n\n');
  end
end

% 
% Ok, the files seem to exist, so let's coregister them.
%

fprintf('Coreging %s to\n         %s\n',ObjectImage,TargetImage);

if length(OtherImages) > 0
  for iother = 1:length(OtherImages)
    fprintf('     moving %s\n',OtherImages{iother});
  end
end

%
% Do the work and determine the co-registration matrix.
%

if TestFlag ~= 0
    fprintf('Test mode, files exist.\n');
else

  clear matlabbatch
  
  % Silly SPM wants the other images to be a blank rather than the
  % empty set when there are no other images.
  
  if length(OtherImages) < 1
    OtherImages = {''};
  else
    for iO = 1:length(OtherImages)
      OtherImages{iO} = [strtrim(OtherImages{iO}),',1'];
    end    
  end
  
  % Now figure out what we are doing.
  
  switch ReSlice
   case 0
    %
    % Estimate only
    % 
    % Estimation portion
    %
    matlabbatch{1}.spm.spatial.coreg.estimate.ref{1}     = [TargetImage ',1'];
    matlabbatch{1}.spm.spatial.coreg.estimate.source{1}  = [ObjectImage ',1'];
    matlabbatch{1}.spm.spatial.coreg.estimate.other      = OtherImages;
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions   = defaults.coreg.estimate;
    
   case 1
    %
    % Estimate and write
    % 
    % Estimation portion
    %
    matlabbatch{1}.spm.spatial.coreg.estwrite.ref{1}     = [TargetImage,',1'];
    matlabbatch{1}.spm.spatial.coreg.estwrite.source{1}  = [ObjectImage,',1'];
    matlabbatch{1}.spm.spatial.coreg.estwrite.other      = OtherImages;
    matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions   = defaults.coreg.estimate;
    %
    % Reslicing portion
    %
    matlabbatch{1}.spm.spatial.coreg.estwrite.roptions   = defaults.coreg.write;
   
   case 2
    %
    % Reslice only
    %
    % Reslicing portion
    %
    matlabbatch{1}.spm.spatial.coreg.write.ref{1}     = [TargetImage,',1'];
    matlabbatch{1}.spm.spatial.coreg.write.source{1}  = [ObjectImage,',1'];
    iS = 1;
    if length(OtherImages) > 0      
      for iO = 1:length(OtherImages)
	if length(OtherImages{iO}) > 0
	  iS = iS+1;
	  matlabbatch{1}.spm.spatial.coreg.write.source{iS} = ...
	      OtherImages{iO};
	end
      end
    end
    matlabbatch{1}.spm.spatial.coreg.write.roptions   = defaults.coreg.write;
    
  end
     
  spm_jobman('run_nogui',matlabbatch);
    
  % Now write out a log to the subjects directory
  
  [objectDirectory dummy1 dummy2] = fileparts(ObjectImage);
  
  UMBatchLogProcess(objectDirectory,sprintf('UMBatchCoReg : %s -> %s',ObjectImage,TargetImage));
  
end

%
% Set the flag to success.
%

results = toc;

fprintf('CoReg Done in %f seconds\n',results);

return

%
% All done.
%
