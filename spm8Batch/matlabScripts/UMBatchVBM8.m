% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Robert C. Welsh
% Ann Arbor Michigan, USA
%
% March 2005-2013
% Copyright.
%
% UMBatchVBM8
%
% A drivable routine for warping some images using the
% batch options of spm8.
%
% Version 1.0
%
%  Call as :
%
%  function results = UMBatchVBM8(ParamImage,ReferenceImage,Img2Write,TestFlag,VoxelSize,OutputName,BIASFIELDFLAG);
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

function results = UMBatchVBM8(ParamImage,ReferenceImage,Img2Write,TestFlag,VoxelSize,OutputName,BIASFIELDFLAG)

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
        results = -69;
        UMCheckFailure(results);
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
    results = -70;
    UMCheckFailure(results);
    return
end

% Only proceed if successful.

fprintf('Entering UMBatchVBM8 V2.0 SPM8 Compatible\n');

if TestFlag~=0
    fprintf('\nTesting only, no work to be done\n\n');
end

% make sure the biasfield flag it passed, else default to 0.

if exist('BIASFIELDFLAG') == 0
    BIASFIELDFLAG=1;
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

% We need to make sure tha the VBM8 toolbox is present.

if exist('spm_vbm8.m') ~= 2
    fprintf('\n\n* * * * * * MISSING THE VBM8 TOOLBOX * * * * * * \n')
    fprintf('  * * * A B O R T I N G * * *\n\n');
    results = -69;
    UMCheckFailure(results);
    return
end

clear matlabbatch

matlabbatch{1}.spm.tools.vbm8.estwrite.data   = {[ParamImage ',1']};
matlabbatch{1}.spm.tools.vbm8.estwrite.opts   = vbm8.opts;
matlabbatch{1}.spm.tools.vbm8.estwrite.output = rmfield(vbm8.output,'surf');

% But now we also turn on ALL native output.

matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.native    = BIASFIELDFLAG;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.GM.warped    = BIASFIELDFLAG;

matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.native    = BIASFIELDFLAG;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.WM.warped    = BIASFIELDFLAG;

matlabbatch{1}.spm.tools.vbm8.estwrite.output.CSF.native   = BIASFIELDFLAG;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.CSF.warped   = BIASFIELDFLAG;

matlabbatch{1}.spm.tools.vbm8.estwrite.output.bias.native  = 1;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.bias.warped  = BIASFIELDFLAG;

matlabbatch{1}.spm.tools.vbm8.estwrite.output.label.native = BIASFIELDFLAG;
matlabbatch{1}.spm.tools.vbm8.estwrite.output.label.warped = BIASFIELDFLAG;

matlabbatch{1}.spm.tools.vbm8.estwrite.output.warps        = [1 0];

% Now the extopts.

matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.dartelwarp.normhigh.darteltpm = vbm8.extopts.darteltpm;

matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.sanlm       = 2;
matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.mrf         = 0.15;
matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.cleanup     = 1;
matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.print       = 1;

if exist('vbm8HiRes_options.m','file')
    %
    % Okay the options file exists, so we need to read those in and figure out what to do with them
    %
    fprintf('Found "vbm8HiRes_options.m", executing that.\n');
    fprintf('- - - - - - - - - - - - - - - - - - - - - -\n');
    type vbm8HiRes_options.m
    try
        vbm8HiRes_options
    catch
        fprintf('\n\n\n * * * * * * FAILURE * * * * * *\n');
        fprintf('   ABORTING THIS JOB AS YOUR\n');
        fprintf('   vbm8HiRes_options.m file\n');
        fprintf('   contains an error\n');
        fprintf(' * * * * * * FAILURE * * * * * *\n\n\n');  
        results = -70;
        UMCheckFailure(results);
        return
    end
    fprintf('- - - - - - - - - - - - - - - - - - - - - -\n');
    %
    % Now see if they put in opts?
    %
    if exist('opts','var');
        if isfield('opts','biasreg')
            matlabbatch{1}.spm.tools.vbm8.estwrite.opts.biasreg = opts.biasreg;
            fprintf('Using option matlabbatch{1}.spm.tools.vbm8.estwrite.opts.biasreg    = %f\n',opts.biasreg);
        end
        if isfield('opts','biasfwhm')
            matlabbatch{1}.spm.tools.vbm8.estwrite.opts.biasfwhm = opts.biasfwhm;
            fprintf('Using option matlabbatch{1}.spm.tools.vbm8.estwrite.opts.biasfwhm   = %f\n',opts.biasfwhm);
        end
        if isfield('opts','affreg')
            matlabbatch{1}.spm.tools.vbm8.estwrite.opts.affreg = opts.affreg;
            fprintf('Using option matlabbatch{1}.spm.tools.vbm8.estwrite.opts.affreg     = %s\n',opts.affreg);
        end
        if isfield('opts','warpreg')
            matlabbatch{1}.spm.tools.vbm8.estwrite.opts.biasreg = opts.warpreg;
            fprintf('Using option matlabbatch{1}.spm.tools.vbm8.estwrite.opts.warpreg    = %d\n',opts.warpreg);
        end
        if isfield('opts','samp')
            matlabbatch{1}.spm.tools.vbm8.estwrite.opts.samp = opts.samp;
            fprintf('Using option matlabbatch{1}.spm.tools.vbm8.estwrite.opts.samp       = %d\n',opts.samp);
        end
    end
    %
    % Now see if they put in extopts?
    %
    if exist('extopts','var');
        if isfield('extopts','sanlm')
            matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.sanlm = extopts.sanlm;
            fprintf('Using option matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.sanlm   = %d\n',extopts.sanlm);
        end
        if isfield('extopts','mrf')
            matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.mrf = extopts.mrf;
            fprintf('Using option matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.mrf     = %f\n',extopts.mrf);
        end
        if isfield('extopts','cleanup')
            matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.cleanup = extopts.cleanup;
            fprintf('Using option matlabbatch{1}.spm.tools.vbm8.estwrite.extopts.cleanup = %d\n',extopts.cleanup);
        end
    end
end

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

% Get the masking image, which is the "p0" image.

MaskParam = fullfile(ParamImageDirectory,['p0' ParamImageName ParamImageExt]);

% Now create the skull stripped brain.

inputImages = strvcat(ParamImage,MaskParam);

Vi = spm_vol(inputImages);

clear Vo

Vo.fname   = fullfile(ParamImageDirectory,['bet_' ParamImageName ParamImageExt]);
Vo.dim     = Vi(1).dim;
Vo.mat     = Vi(1).mat;
Vo.descrip = ['Skull Stripped spm8Batch/VMB8 ' Vi(1).descrip];
Vo.dt      = Vi(1).dt;

spm_imcalc(Vi,Vo,'i1.*(i2>0)');

% Now create an intensity normalized stripped brain.

ParamImageNorm = fullfile(ParamImageDirectory,['m' ParamImageName ParamImageExt]);

inputImages = strvcat(ParamImageNorm,MaskParam);

Vi = spm_vol(inputImages);

clear Vo

Vo.fname   = fullfile(ParamImageDirectory,['bet_m' ParamImageName ParamImageExt]);
Vo.dim     = Vi(1).dim;
Vo.mat     = Vi(1).mat;
Vo.descrip = ['Skull Stripped spm8Batch/VMB8 (intensity normalized)' Vi(1).descrip];
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
