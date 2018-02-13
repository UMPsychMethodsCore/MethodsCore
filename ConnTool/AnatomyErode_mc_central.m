%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Code to create logfile name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LogDirectory = mc_GenPath(struct('Template',LogTemplate,'mode','makedir'));
result = mc_Logger('setup',LogDirectory);
if (~result)
    %error with setting up logging
    mc_Error('There was an error creating your logfiles.\nDo you have permission to write to %s?',LogDirectory);
end
global mcLog

spmver = spm('Ver');
if (strcmp(spmver,'SPM12')==1) 
    spm_jobman('initcfg');
    spm_get_defaults('cmdline',true);
    if (exist('spmdefaults','var'))
        mc_SetSPMDefaults(spmdefaults);
    end
end

spm('defaults','fmri');
global defaults
warning off all

matlabbatch{1}.spm.util.imcalc.input = {''};
matlabbatch{1}.spm.util.imcalc.output = '';
matlabbatch{1}.spm.util.imcalc.outdir = {''};
matlabbatch{1}.spm.util.imcalc.expression = '';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 0;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

nSub = size(SubjDir,1);
nImage = max(size(AnatomyFiles));

if (max(size(ErosionSteps))==1)
    ErosionSteps = repmat(ErosionSteps,1,nImage);
elseif (max(size(ErosionSteps))~=nImage)
    mc_Error('The number of values in ErosionSteps does not equal the number of images provided.');
end

if (max(size(ImageThreshold))==1)
    ImageThreshold = repmat(ImageThreshold,1,nImage);
elseif (max(size(ImageThreshold))~=nImage)
    mc_Error('The number of values in ImageThreshold does not equal the number of images provided.');
end

kernel = zeros(3,3,3);

if (iscell(ErosionKernel))
    switch ErosionKernel{1}
        case 7
            [x,y,z] = ndgrid(-1:1);
            kernel = sqrt(x.^2 + y.^2 + z.^2) <=1;
        case 19
            [x,y,z] = ndgrid(-1:1);
            kernel = sqrt(x.^2 + y.^2 + z.^2) <=1.5;
        case 27
            [x,y,z] = ndgrid(-1:1);
            kernel = sqrt(x.^2 + y.^2 + z.^2) <=2;
        otherwise
            mc_Error('Invalid predefined kernel value, only 7, 19, or 27 are accepted');
    end
else
    if (ndims(ErosionKernel)~=3)
        mc_Error('You supplied a custom erosion kernel, but it does not have 3 dimensions.');
    end
    kernel = ErosionKernel;
end

kernel = double(kernel);

for iSubject = 1:nSub
    Subject = SubjDir{iSubject,1};
    %grab reference image
    refimage = [mc_GenPath(ResampleTemplate) ',1'];
    
    %build path
    outdir = mc_GenPath(AnatomyPath);
    
    for iImage = 1:nImage
        job = matlabbatch;
        image = [fullfile(outdir,AnatomyFiles{iImage}) ',1'];
        input = {refimage;image};
        threshold = ImageThreshold(iImage);
        job{1}.spm.util.imcalc.expression = strrep('i2>threshold','threshold',num2str(threshold));
        
        output = ['t' sprintf('%0.3f',ImageThreshold(iImage)) '_' AnatomyFiles{iImage}];
        job{1}.spm.util.imcalc.input = input;
        job{1}.spm.util.imcalc.output = output;
        job{1}.spm.util.imcalc.outdir = {outdir};
        spm_jobman('run',job);
        hdr = spm_vol(fullfile(outdir,output));
        d = spm_read_vols(hdr);
        
        for iErode = 1:ErosionSteps(iImage)
            d = spm_erode(d,kernel);
        end
        
        Vo = hdr;
        Vo = rmfield(Vo,'pinfo');
        output = fullfile(outdir,['e' num2str(ErosionSteps(iImage)) '_' output]);
        Vo.fname = output;
        spm_write_vol(Vo,d);
        s = sum(d(:));
        if (s<=MinMask)
            fprintf(1,'WARNING: Eroded mask %s has very few voxels (%g). You may want to erode less or threshold differently.\n',output,s);
            mc_Logger('log',sprintf('Eroded mask %s has very few voxels (%g). You may want to erode less or threshold differently.',output,s),2);
        end
    end
end
