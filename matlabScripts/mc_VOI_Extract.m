function xY = mc_VOI_Extract(path,contrast,threshold,extent,name,session,def,spec,xyz,adjust)
% usage: xY = mc_VOI_Extract(path, contrast, threshold, extent, name, session, def, spec, xyz, adjust#);
% path = path to SPM.mat file
% contrast = contrast number to extract from
% threshold = p threshold to use for contrast
% extent = extent threshold to use for contrast
% name = name of VOI output file
% session = session number to extract from
% def = type of ROI to extract: 'sphere','image'
% spec = for 'sphere' the radius of the sphere, for 'image' the path to the ROI
% xyz = the center of the sphere, or [] for image
% adjust# = contrast number of F contrast to use for adjustment, 0 for no adjustment



%spm8 structure
% matlabbatch{1}.spm.util.voi
%         spmmat: {[1x60 char]}
%         adjust: 0
%        session: 1
%           name: 'test'
%            roi{1}
%             .spm
%                  spmmat: {''}
%                contrast: 1
%             conjunction: 1
%              threshdesc: 'none'
%                  thresh: 1.0000e-03
%                  extent: 0
%                    mask: [0x0 struct]
%            .sphere
%                 centre: [0 0 0]
%                 radius: 5
%                   move.fixed = 1
%           .mask
%                 image: {'/net/dysthymia/mangstad/eht1spgr.nii,1'}
%             threshold: 0.5000
%         
%     expression: 'i1&i2'

xY = [];

spm('defaults','fmri');

switch (lower(spm('Ver')))
    case 'spm2'
        %call voi_extract_batch code
        [Y,xY] = voi_extract_batch(path,contrast,threshold,extent,name,session,def,spec,xyz,[],adjust);
    case 'spm5'
        jobs{1}.stats{1}.results.spmmat = cellstr(path);
        jobs{1}.stats{1}.results.conspec(1).titlestr = '';
        jobs{1}.stats{1}.results.conspec(1).contrasts = contrast;
        jobs{1}.stats{1}.results.conspec(1).threshdesc = 'none';
        jobs{1}.stats{1}.results.conspec(1).thresh = threshold;
        jobs{1}.stats{1}.results.conspec(1).extent = extent;
        jobs{1}.stats{1}.results.print = 0;
        spm_jobman('run',jobs);
   
        hReg = evalin('base','hReg');
        SPM = evalin('base','SPM');
        xSPM = evalin('base','xSPM');
        
        xY.xyz = spm_mip_ui('SetCoords',xyz);
        xY.name = name;
        xy.Ic = adjust;
        xY.Sess = session;
        xY.def = def;
        xY.spec = spec;
        [Y,xY] = spm_regions(xSPM,SPM,hReg,xY);
        
    case 'spm8'
        spm_jobman('initcfg');
        jobs{1}.stats{1}.results.spmmat = cellstr(path);
        jobs{1}.stats{1}.results.conspec(1).titlestr = '';
        jobs{1}.stats{1}.results.conspec(1).contrasts = contrast;
        jobs{1}.stats{1}.results.conspec(1).threshdesc = 'none';
        jobs{1}.stats{1}.results.conspec(1).thresh = threshold;
        jobs{1}.stats{1}.results.conspec(1).extent = extent;
        jobs{1}.stats{1}.results.print = 0;
        spm_jobman('run',jobs);
        
        hReg = evalin('base','hReg');
        SPM = evalin('base','SPM');
        xSPM = evalin('base','xSPM');
        
        xY.xyz = spm_mip_ui('SetCoords',xyz);
        xY.name = name;
        xy.Ic = adjust;
        xY.Sess = session;
        xY.def = def;
        xY.spec = spec;
        [Y,xY] = spm_regions(xSPM,SPM,hReg,xY);
        
    otherwise
        %error using unsupported version of SPM
        mc_Error('You are using an unsupported version of SPM.  Currently mc_VOI_Extract only supports SPM5 and SPM8');
        
end
  
return;
