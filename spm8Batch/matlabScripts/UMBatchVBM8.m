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
% Version 1.0
% 
%  Call as :
%
%  function results = UMBatchWarpVBM8(ParamImage,TestFlag);
%
%  To Make this work you need to provide the following input:
%
%     ParamImage       = Image to determine warping parameters.
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

function results = UMBatchVBM8(ParamImage,ReferenceImage,TestFlag,VoxelSize,OutputName);

% Get the defaults from SPM.

global defaults
global vbm8
global UMBatch

%
% Set the return status to -1, that is error by default.
%

results = -1;

if isempty(vbm8)
  if exist('cg_vbm8_defaults') == 0
    fprintf('\n\n* * * * * * * * * * * * \n\n');
    fprintf('    FATAL ERROR \n');
    fprintf('    You do no have the VBM8 toolbox\n');
    fprintf('\n\n* * * * * * * * * * * * \n\n');
    return
  else
    fprintf('\nConfiguring VBM8 to defaults\n');
    cg_vbm8_defaults
  end
end

% Make the call to prepare the system for batch processing.

UMBatchPrep

if UMBatch == 0
  fprintf('UMBatchPrep failed.')
  return
end

% Only proceed if successful.

fprintf('Entering UMBatchVBM8 V2.0 SPM8 Compatible\n');

if TestFlag~=0
    fprintf('\nTesting only, no work to be done\n\n');
end 

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

% We need to make sure tha the VBM8 toolbox is present.

if exist('spm_vbm8.m') ~= 2
  fprintf('\n\n* * * * * * MISSING THE VBM8 TOOLBOX * * * * * * \n')
  fprintf('  * * * A B O R T I N G * * *\n\n');
  return
end

clear matlabbatch

matlabbatch{1}.spm.tools.vbm8.estwrite.data   = {[ParamImage ',1']};
matlabbatch{1}.spm.tools.vbm8.estwrite.opts   = vbm8.opts;
matlabbatch{1}.spm.tools.vbm8.estwrite.output = rmfield(vbm8.output,'surf');

% But now we also turn on ALL native output.

matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.native    = 1;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.warped    = 1;

matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.native    = 1;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.warped    = 1;

matlabbatch{1}.spm.tools.vbm8.estwrite.output.CSF.native   = 1;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.CSF.warped   = 1;

matlabbatch{1}.spm.tools.vbm8.estwrite.output.bias.native  = 1;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.bias.warped  = 1;

matlabbatch{1}.spm.tools.vbm8.estwrite.output.label.native = 1;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.label.warped = 1;

matlabbatch{1}.spm.tools.vbm8.estwrite.output.warps        = [1 0];

% Now the extopts.

matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.dartelwarp.normhigh.darteltpm = vbm8.extopts.darteltpm;

matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.sanlm       = 2;
matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.mrf         = 0.15;
matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.cleanup     = 1;
matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.print       = 1;

% Now call the batch manager.

spm_jobman('run_nogui',matlabbatch);

% Log that we finished this portion.

[ParamImageDirectory ParamImageName ParamImageExt] = fileparts(ParamImage);

UMBatchLogProcess(ParamImageDirectory,sprintf('UMBatchVBM8 : VBM8 processed : %s',ParamImage));

% Now create the masked image of the input. We will take the p0 image and
% use spm_imcalc to create a skull stripped which we will preprend as
% "bet_"

CURDIR=pwd;

cd(ParamImageDirectory);

% Now create the skull stripped brain.

MaskParam = fullfile(ParamImageDirectory,['p0' ParamImageName ParamImageExt]);

inputImages = strvcat(ParamImage,MaskParam);

Vi = spm_vol(inputImages);

clear Vo

Vo.fname   = fullfile(ParamImageDirectory,['bet_' ParamImageName ParamImageExt]);
Vo.dim     = Vi(1).dim;
Vo.mat     = Vi(1).mat;
Vo.descrip = ['Skull Stripped spm8Batch/VMB8 ' Vi(1).descrip];
Vo.dt      = Vi(1).dt;

spm_imcalc(Vi,Vo,'i1.*(i2>0)');

% And now log it.

UMBatchLogProcess(ParamImageDirectory,sprintf('UMBatchVBM8 : VBM8 created skull stripped : %s',Vo.fname));

% And now warp the parent image to the specification and with the
% name specified. But we only do that if they specified anything
% different.

if exist(ReferenceImage) | VoxelSize(1) > 0 | strcmp(OutputName,'w')==0
  %
  % Okay looks like they want us to override what they have, so we
  % need to build a list and then pass on to UMBatchWarpVBM8
  %
  % The images to warp are [ParamImage], bet_[ParamImage],
  % p0_[ParamImage], p1_[ParamImage], and p2_[ParamImage];
  %
  IMAGELIST={'','m','bet_','p0','p1','p2','p3'};
  PList = [];
  for iP = 1:length(IMAGELIST)
    Pthis = spm_select('ExtFPList',ParamImageDirectory,sprintf('^%s%s.nii',IMAGELIST{iP},ParamImageName),[1 inf]);
    PList = strvcat(PList,Pthis);
  end
  results = UMBatchWarpVBM8(ParamImage,ReferenceImage,PList,TestFlag,VoxelSize,OutputName);
  UMCheckFailure(results);
end

clear matlabbatch
    
% Set the flag to the amount of time to execute.
%

results = toc;

fprintf('Deformation finished in %f seconds\n',results);

return

%
% All done.
%
