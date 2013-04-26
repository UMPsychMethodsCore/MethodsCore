% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Robert C. Welsh
% Ann Arbor Michigan, USA
%
% March 2005-2013
% Copyright.
%
% UMBatchNewSeg
%
% A drivable routine for warping some images using the 
% batch options of spm8.
%
% Version 1.0
% 
%  Call as :
%
%  function results = UMBatchNewSeg(ParamImage,ReferenceImage,Img2Write,TestFlag,VoxelSize,OutputName);
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

function results = UMBatchNewSeg(ParamImage,ReferenceImage,Img2Write,TestFlag,VoxelSize,OutputName)

% Get the defaults from SPM.

global defaults
%global vbm8
global UMBatch

% This parameter you can override by using the newSeg.options file.

BETThreshold = 0.05;

%
% Set the return status to -1, that is error by default.
%

results = -1;

% Make the call to prepare the system for batch processing.

UMBatchPrep

if UMBatch == 0
  fprintf('UMBatchPrep failed.')
  results = -70;
  UMCheckFailure(results);
  return
end

% Only proceed if successful.

fprintf('Entering UMBatchNewSeg V1.0 SPM8 Compatible\n');

if TestFlag~=0
    fprintf('\nTesting only, no work to be done\n\n');
end 


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

%
% Make sure that the ParamImage is there.
%

ticStart = tic;

if isempty(ParamImage) | exist(ParamImage) == 0
    fprintf('\n\nThe Parameter Image Must EXIST!\n');
    fprintf('  * * * A B O R T I N G * * *\n\n');
    results = -65;
    UMCheckFailure(results);
    return
end

clear matlabbatch

% Get the directory of this file we are working upon.

ParamDir = fileparts(ParamImage);

cd(ParamDir);

matlabbatch{1}.spm.tools.preproc8.channel.vols      = {[ParamImage ',1']};
matlabbatch{1}.spm.tools.preproc8.channel.biasreg   = 1.0e-4;
matlabbatch{1}.spm.tools.preproc8.channel.biasfwhm  = 60;
matlabbatch{1}.spm.tools.preproc8.channel.write     = [1 1];

% Where are the tissue segments?

SPMSOURCECODE=which('spm');
SPMDIR = fileparts(SPMSOURCECODE);
TPMDIR = fullfile(SPMDIR,'toolbox','Seg','TPM.nii');

% Now assign the tissue assignments.
matlabbatch{1}.spm.tools.preproc8.tissue(1).tpm = {[TPMDIR ',1']};
matlabbatch{1}.spm.tools.preproc8.tissue(1).ngaus = 2;
matlabbatch{1}.spm.tools.preproc8.tissue(1).native = [1 0];
matlabbatch{1}.spm.tools.preproc8.tissue(1).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(2).tpm = {[TPMDIR ',2']};
matlabbatch{1}.spm.tools.preproc8.tissue(2).ngaus = 2;
matlabbatch{1}.spm.tools.preproc8.tissue(2).native = [1 0];
matlabbatch{1}.spm.tools.preproc8.tissue(2).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(3).tpm = {[TPMDIR ',3']};
matlabbatch{1}.spm.tools.preproc8.tissue(3).ngaus = 2;
matlabbatch{1}.spm.tools.preproc8.tissue(3).native = [1 0];
matlabbatch{1}.spm.tools.preproc8.tissue(3).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(4).tpm = {[TPMDIR ',4']};
matlabbatch{1}.spm.tools.preproc8.tissue(4).ngaus = 3;
matlabbatch{1}.spm.tools.preproc8.tissue(4).native = [1 0];
matlabbatch{1}.spm.tools.preproc8.tissue(4).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(5).tpm = {[TPMDIR ',5']};
matlabbatch{1}.spm.tools.preproc8.tissue(5).ngaus = 4;
matlabbatch{1}.spm.tools.preproc8.tissue(5).native = [1 0];
matlabbatch{1}.spm.tools.preproc8.tissue(5).warped = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(6).tpm = {[TPMDIR ',6']};
matlabbatch{1}.spm.tools.preproc8.tissue(6).ngaus = 2;
matlabbatch{1}.spm.tools.preproc8.tissue(6).native = [0 0];
matlabbatch{1}.spm.tools.preproc8.tissue(6).warped = [0 0];

matlabbatch{1}.spm.tools.preproc8.warp.mrf      = 0;
matlabbatch{1}.spm.tools.preproc8.warp.reg      = 4;
matlabbatch{1}.spm.tools.preproc8.warp.affreg   = 'mni';
matlabbatch{1}.spm.tools.preproc8.warp.samp     = 3;
matlabbatch{1}.spm.tools.preproc8.warp.write    = [1 1];

% Now check for the options file in this directory.

if exist('newSeg_options.m','file')
    %
    % Okay the options file exists, so we need to read those in and figure out what to do with them
    %
    fprintf('Found "newSeg_options.m", executing that.\n');
    fprintf('- - - - - - - - - - - - - - - - - - - - - -\n');
    type newSeg_options.m
    try
        newSeg_options
    catch
        fprintf('\n\n\n * * * * * * FAILURE * * * * * *\n');
        fprintf('   ABORTING THIS JOB AS YOUR\n');
        fprintf('   newSeg_options.m file\n');
        fprintf('   contains an error\n');
        fprintf(' * * * * * * FAILURE * * * * * *\n\n\n');  
        results = -70;
        UMCheckFailure(results);
        return
    end
    fprintf('- - - - - - - - - - - - - - - - - - - - - -\n');
    %
    % Now some stuff about the derivation.
    %
    if exist('channel','var')
        if isfield('channel','biasreg')
            matlabbatch{1}.spm.tools.preproc8.channel.biasreg     = channel.biasreg;
            fprintf('Using option matlabbatch{1}.spm.tools.preproc8.channel.biasreg  = %f\n',channel.biasreg);
        end
        if isfield('channel','biasfwhm')
            matlabbatch{1}.spm.tools.preproc8.channel.biasfwhm  = channel.biasfwhm;
            fprintf('Using option matlabbatch{1}.spm.tools.preproc8.channel.biasfwhm = %f\n',channel.biasfwhm);
        end
    end
    %
    % Now the warping stuff.
    %
    if exist('warp','var')
        if isfield('warp','mrf');
            matlabbatch{1}.spm.tools.preproc8.warp.mrf      = warp.mrf;
            fprintf('Using option matlabbatch{1}.spm.tools.preproc8.warp.mrf         = %d\n',warp.mrf);
        end
        if isfield('warp','reg');
            matlabbatch{1}.spm.tools.preproc8.warp.reg      = warp.reg;
            fprintf('Using option matlabbatch{1}.spm.tools.preproc8.warp.reg         = %d\n',warp.reg);
        end
        if isfield('warp','affreg');  % mni, eastern, subj, none
            matlabbatch{1}.spm.tools.preproc8.warp.affreg   = warp.affreg;
            fprintf('Using option matlabbatch{1}.spm.tools.preproc8.warp.affreg      = %d\n',warp.affreg);
        end
        if isfield('warp','samp');
            matlabbatch{1}.spm.tools.preproc8.warp.samp      = warp.samp;
            fprintf('Using option matlabbatch{1}.spm.tools.preproc8.warp.samp        = %d\n',warp.samp);
        end
    end
end


% Now call the batch manager.

spm_jobman('run_nogui',matlabbatch);

% Log that we finished this portion.

[ParamImageDirectory ParamImageName ParamImageExt] = fileparts(ParamImage);

UMBatchLogProcess(ParamImageDirectory,sprintf('UMBatchNewSeg : newSeg processed : %s',ParamImage));

% Now create the masked image of the input. We will take the p0 image and
% use spm_imcalc to create a skull stripped which we will preprend as
% "bet_"

CURDIR=pwd;

cd(ParamImageDirectory);

% Get the masking image, which is the "p0" image.

MaskParamGM = fullfile(ParamImageDirectory,['c1' ParamImageName ParamImageExt]);
MaskParamWM = fullfile(ParamImageDirectory,['c2' ParamImageName ParamImageExt]);

% Now create the skull stripped brain.

inputImages = strvcat(ParamImage,MaskParamGM,MaskParamWM);

Vi = spm_vol(inputImages);

clear Vo

Vo.fname   = fullfile(ParamImageDirectory,['bet_' ParamImageName ParamImageExt]);
Vo.dim     = Vi(1).dim;
Vo.mat     = Vi(1).mat;
Vo.descrip = ['Skull Stripped spm8Batch/newSeg ' Vi(1).descrip];
Vo.dt      = Vi(1).dt;

spm_imcalc(Vi,Vo,sprintf('i1.*((i2+i3)>%f)',BETThreshold));

% Now create an intensity normalized stripped brain.

ParamImageNorm = fullfile(ParamImageDirectory,['m' ParamImageName ParamImageExt]);

inputImages = strvcat(ParamImageNorm,MaskParamGM,MaskParamWM);

Vi = spm_vol(inputImages);

clear Vo

Vo.fname   = fullfile(ParamImageDirectory,['bet_m' ParamImageName ParamImageExt]);
Vo.dim     = Vi(1).dim;
Vo.mat     = Vi(1).mat;
Vo.descrip = ['Skull Stripped spm8Batch/VMB8 (intensity normalized)' Vi(1).descrip];
Vo.dt      = Vi(1).dt;

spm_imcalc(Vi,Vo,sprintf('i1.*((i2+i3)>%f)',BETThreshold));

% And now log it.

UMBatchLogProcess(ParamImageDirectory,sprintf('UMBatchNewSeg : NewSeg created skull stripped : %s',Vo.fname));

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
  IMAGELIST={'','m','bet_','bet_m','c1','c2','c3'};
  PList = [];
  for iP = 1:length(IMAGELIST)
    Pthis = spm_select('ExtFPList',ParamImageDirectory,sprintf('^%s%s.nii',IMAGELIST{iP},ParamImageName),[1 inf]);
    PList = strvcat(PList,Pthis);
  end
  results = UMBatchWarpVBM8(ParamImage,ReferenceImage,PList,TestFlag,VoxelSize,OutputName);
  if UMCheckFailure(results)
    return;
  end
end

% Now warp other images that might be speficied.

if length(Img2Write) > 0
  results = UMBatchWarpVBM8(ParamImage,ReferenceImage,Img2Write,TestFlag,VoxelSize,OutputName);
  if UMCheckFailure(results)
    return
  end
end

clear matlabbatch
    
% Set the flag to the amount of time to execute.
%

results = toc(ticStart);

fprintf('Deformation finished in %f seconds\n',results);

return

%
% All done.
%
