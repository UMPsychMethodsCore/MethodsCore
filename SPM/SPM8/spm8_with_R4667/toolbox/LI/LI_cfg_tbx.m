function cfg=LI_cfg_tbx
% SPM Configuration file for LI-toolbox
%_______________________________________________________________________
% Copyright (C) 2011 Arnold Skimminge, DRCMR
% Included in the LI-toolbox distribution with kind permission!
addpath(fullfile(spm('dir'),'toolbox','LI'));

% ---------------------------------------------------------------------
% spmT Select spmT_?.mat
% ---------------------------------------------------------------------
spmT         = cfg_files;
spmT.tag     = 'spmT';
spmT.name    = 'Select spm[TF]_? files';
spmT.help    = {'Select spmT or spmF files for contrasts of interest'};
spmT.filter  = 'image';
spmT.ufilter = 'spm[TF]_.*$';
spmT.num     = [1 inf];

% ---------------------------------------------------------------------
% Inclusive mask
% ---------------------------------------------------------------------
im1 = cfg_const;
im1.name = 'Frontal';
im1.tag = 'im1';
im1.val = {1};
im1.help = {''};

im2 = cfg_const;
im2.name = 'Parietal';
im2.tag = 'im2';
im2.val = {1};
im2.help = {''};

im3 = cfg_const;
im3.name = 'Temporal';
im3.tag = 'im3';
im3.val = {1};
im3.help = {''};

im4 = cfg_const;
im4.name = 'Occipital';
im4.tag = 'im4';
im4.val = {1};
im4.help = {''};

im5 = cfg_const;
im5.name = 'Cingulate';
im5.tag = 'im5';
im5.val = {1};
im5.help = {''};

im6 = cfg_const;
im6.name = 'Central';
im6.tag = 'im6';
im6.val = {1};
im6.help = {''};

im7 = cfg_const;
im7.name = 'Cerebellar';
im7.tag = 'im7';
im7.val = {1};
im7.help = {''};

im8 = cfg_const;
im8.name = 'Gray matter';
im8.tag = 'im8';
im8.val = {1};
im8.help = {''};

im9 = cfg_const;
im9.name = 'All standard masks';
im9.tag = 'im9';
im9.val = {1};
im9.help = {''};

im10 = cfg_const;
im10.name = 'No mask';
im10.tag = 'im10';
im10.val = {1};
im10.help = {''};

im11 = cfg_files;
im11.name = 'Custom selection';
im11.tag = 'im11';
im11.help = {''};
im11.filter  = 'image';
im11.num     = [1 inf];

inmask         = cfg_choice;
inmask.tag     = 'inmask';
inmask.name    = 'Inclusive mask';
inmask.help    = {'Any number of standard or custom mask can be selected; custom ',...
 'ones can be mirrored and binarized to avoid size biases. A mask will ',...
 'be applied to any number of statistical images (inputs) chosen above.',...
 'This is repeated for all masks and all inputs.'};
inmask.values  = {im1 im2 im3 im4 im5 im6 im7 im8 im9 im10 im11};
inmask.val = {im1};


% ---------------------------------------------------------------------
% Exclusive mask
% ---------------------------------------------------------------------
em1 = cfg_const;
em1.name = 'Midline -5 mm';
em1.tag = 'em1';
em1.val = {1};
em1.help = {''};

em2 = cfg_const;
em2.name = 'Midline -10 mm';
em2.tag = 'em2';
em2.val = {1};
em2.help = {''};

em3 = cfg_const;
em3.name = 'No exclusive mask';
em3.tag = 'em3';
em3.val = {1};
em3.help = {''};

em4 = cfg_files;
em4.name = 'Custom selection';
em4.tag = 'em4';
em4.help = {''};
em4.filter  = 'image';
em4.num     = [1 inf];

exmask         = cfg_choice;
exmask.tag     = 'exmask';
exmask.name    = 'Exclusive mask';
exmask.help    = {''};
exmask.values  = {em1 em2 em3 em4};
exmask.val = {em1};

% ---------------------------------------------------------------------
% Threshold methods
% ---------------------------------------------------------------------
% thr1 = 1 (use same threshold for all images)
%       = 0 (individual thresholding for all images)
%       = -1 (adaptive thresholding
%       = -2 (rank-based thresholding)
%       = -3 (iterative thresholding, LI-curves)
%       = -4 (no threshold)
%       = -5 (bootstrapping)
% 

thr1 = cfg_entry;
thr1.name = 'Use same threshold for all images';
thr1.tag = 'thr1';
thr1.help = {''};
thr1.strtype = 'e';
thr1.num = [1 1];

thr2 = cfg_entry;
thr2.name = 'Individual thresholding for all images';
thr2.tag = 'thr2';
thr2.help = {''};
thr2.strtype = 'e';
thr2.num = [1 1];

thr3 = cfg_const;
thr3.name = 'Adaptive thresholding';
thr3.tag = 'thr3';
thr3.val = {1};
thr3.help = {''};

thr4 = cfg_const;
thr4.name = 'Rank-based thresholding';
thr4.tag = 'thr4';
thr4.val = {1};
thr4.help = {''};

thr5 = cfg_const;
thr5.name = 'Iterative thresholding, LI-curves';
thr5.tag = 'thr5';
thr5.val = {1};
thr5.help = {''};

thr6 = cfg_const;
thr6.name = 'No thresholding';
thr6.tag = 'thr6';
thr6.val = {1};
thr6.help = {''};

thr7 = cfg_const;
thr7.name = 'Bootstrapping';
thr7.tag = 'thr7';
thr7.val = {1};
thr7.help = {''};

method         = cfg_choice;
method.tag     = 'method';
method.name    = 'Threshold method';
method.help    = {'A threshold can be entered for all or for each',...
'input image individually, or it can be derived from',...
'the data, using an adaptive (mean intensity[positive Voxels]',...
'or a ranking procedure. No threshold is also possible. An',...
'spmT_image is necessary for the ranking procedure, otherwise',...
'any image can be assessed, also from the non-spm-world (yes,',...
'there is one :). Variance weighting (see below), though, will not work',...
'in this case. Lastly, iterative thresholding is available which',...
'will yield nice lateralization curves as a function of thresholds.',...
'An extension to this is based on a bootstrap approach.'};
method.values  = {thr1 thr2 thr3 thr4 thr5 thr6 thr7};
method.val = {thr7};


% ---------------------------------------------------------------------
% Additional options LI toolbox
% ---------------------------------------------------------------------
% pre  = 0 (default)
%       = 1 (enables preprocessing for custom masks, only necessary if B1 > 10 or char)
% thr3 = 0 (default; meaningless if not thr1 = 1; if so, adapt value to your needs)
%       = [3 4 4 5] (supplies multiple thresholds if thr1 = 2)
% op   = 1 (use optional data clustering; may not be allowed)
%       = 2 (use optional variance weighting
%       = 3 (use combined clustering and variance weighting; may not be allowed)
%       = 4 (default; no optional steps)
% vc   = 1 (use total voxel count; may not be allowed)
%       = 0 (use total voxel values; default)
% ni    = 0 (images not normalized)
%       = 1 (images normalized; default)
% outfile = string with name of a custom output file (defaults to 'li.txt')
pre = cfg_menu;
pre.name = 'Preprocess custom masks';
pre.tag = 'pre';
pre.help = {'Enables preprocessing for custom masks'};
pre.labels = {'No',...
    'Yes'};
pre.values = {0 1};
pre.val = {0};

op  = cfg_menu;
op.name = 'Optional steps';
op.tag = 'op';
op.help = {'Data clustering refers to the Gaussian smoothing of the input',...
'image prior to thresholding, which will remove outliers and ',...
'effectively cluster the data. This is an optional step.',...
'',...
'Also optionally, variance weighting can be done, taking into acount',...
'the variability of each voxel as assessed during the statistical',...
'analysis and as expressed in the ResMS.img. Both optional steps ',...
'can also be combined. They are only recommended if you have reason',...
'to believe that outliers influence your results; they can have a ',...
'substantial influence on your results, so be careful here.'};
op.labels = {'Use optional data clustering; may not be allowed',...
    'Use optional variance weighting',...
    'Use combined clustering and variance weighting; may not be allowed',...
    'default; no optional steps'};
op.values = {1 2 3 4};
op.val = {4};

vc  = cfg_menu;
vc.name = 'Voxel counts/values';
vc.tag  = 'vc';
vc.help = {'The results can be calculated on the voxel values (seems to',...
'make more sense, but may be more vulnerable to outliers)',...
'or on the absolute voxel count.'};
vc.labels = {'Use total voxel count; may not be allowed',...
    'Default; use total voxel values'};
vc.values = { 1 0 };
vc.val = {0};

ni  = cfg_menu;
ni.name = 'Normalize images';
ni.tag = 'ni';
ni.help = {''};
ni.labels = {'Normalize images','Default; Images already normalized'};
ni.values = {0 1};
ni.val = {1};

outfile=cfg_entry;
outfile.name = 'Output file';
outfile.tag = 'outfile';
outfile.help = {'Custom output file (defaults to ''li.txt'')'};
outfile.strtype = 's';
outfile.val = {'li.txt'};


% ---------------------------------------------------------------------
% cfg LI toolbox
% ---------------------------------------------------------------------
cfg          = cfg_exbranch;
cfg.tag      = 'LI_cfg';
cfg.name     = 'Lateralization index';
cfg.val      = {spmT inmask exmask method pre op vc ni outfile};
cfg.help     = {''};
cfg.prog     = @LI_run_tbx;
cfg.modality = {'FMRI' 'PET' 'EEG'};

function out=LI_run_tbx(job)

my_li.A = char(job.spmT);

switch char(fieldnames(job.inmask))
    case 'im1'
        my_li.B1 = 1;
    case 'im2'
        my_li.B1 = 2;
    case 'im3'
        my_li.B1 = 3;
    case 'im4'
        my_li.B1 = 4;
    case 'im5'
        my_li.B1 = 5;
    case 'im6'
        my_li.B1 = 6;
    case 'im7'
        my_li.B1 = 7;
    case 'im8'
        my_li.B1 = 8;
    case 'im9'
        my_li.B1 = 9;
    case 'im10'
        my_li.B1 = 10;
    case 'im11'
        my_li.B1 = char(job.inmask.im11);
    otherwise
        error('Unsupported option');
end

switch char(fieldnames(job.exmask))
    case 'em1' % Midline -5 mm
        my_li.C1 = 1;
    case 'em2' % Midline -10 mm
        my_li.C1 = 2;
    case 'em3' % No mask
        my_li.C1 = 3;
    case 'em4' % Custom masks
        my_li.C1 = char(job.exmask.em4);
    otherwise
        error('Unsupported option');
end

switch char(fieldnames(job.method))
    case 'thr1'
        my_li.thr1 = 1;
        my_li.thr3 = job.method.thr1;
    case 'thr2'
        my_li.thr1 = 0;
        my_li.thr3 = job.method.thr2;
    case 'thr3'
        my_li.thr1 = -1;
    case 'thr4'
        my_li.thr1 = -2;
    case 'thr5'
        my_li.thr1 = -3;
    case 'thr6'
        my_li.thr1 = -4;
    case 'thr7' % bootstrap
        my_li.thr1 = -5;
    otherwise
        error('Unsupported option');
end

my_li.op = job.op;
my_li.vc = job.vc;
my_li.ni = job.ni;
my_li.pre = job.pre;
my_li.outfile = char(job.outfile);

LI(my_li);



