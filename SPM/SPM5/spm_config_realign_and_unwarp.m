function opts = spm_config_realign_and_unwarp
% Configuration file for realign and unwarping jobs
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Darren R. Gitelman
% $Id: spm_config_realign_and_unwarp.m 1032 2007-12-20 14:45:55Z john $


%_______________________________________________________________________


quality.type    = 'entry';
quality.name    = 'Quality';
quality.tag     = 'quality';
quality.strtype = 'r';
quality.num     = [1 1];
quality.def     = 'realign.estimate.quality';
quality.extras  = [0 1];
quality.help    = {[...
    'Quality versus speed trade-off.  Highest quality (1) gives most ',...
    'precise results, whereas lower qualities gives faster realignment. ',...
    'The idea is that some voxels contribute little to the estimation of ',...
    'the realignment parameters. This parameter is involved in selecting ',...
    'the number of voxels that are used.']};

%------------------------------------------------------------------------

weight.type   = 'files';
weight.name   = 'Weighting';
weight.tag    = 'weight';
weight.filter = 'image';
weight.num    = [0 1];
weight.val    = {{}};
weight.help   = {[...
    'The option of providing a weighting image to weight each voxel ',...
    'of the reference image differently when estimating the realignment ',...
    'parameters.  The weights are proportional to the inverses of the ',...
    'standard deviations. ',...
    'For example, when there is a lot of extra-brain motion - e.g., during ',...
    'speech, or when there are serious artifacts in a particular region of ',...
    'the images.']};

%------------------------------------------------------------------------

einterp.type   = 'menu';
einterp.name   = 'Interpolation';
einterp.tag    = 'einterp';
einterp.labels = {'Nearest neighbour','Trilinear','2nd Degree B-spline ',...
    '3rd Degree B-Spline','4th Degree B-Spline','5th Degree B-Spline ',...
    '6th Degree B-Spline','7th Degree B-Spline'};
einterp.values = {0,1,2,3,4,5,6,7};
einterp.def   = 'realign.estimate.interp';
einterp.help  = {...
   ['The method by which the images are sampled when being written in a ',...
    'different space. '],...
    ['    Nearest Neighbour ',...
    '    - Fastest, but not normally recommended. '],...
    ['    Bilinear Interpolation ',...
    '    - OK for PET, or realigned fMRI. '],...
    ['    B-spline Interpolation/* \cite{thevenaz00a} ',...
    '    - Better quality (but slower) interpolation, especially ',...
    '      with higher degree splines.  Do not use B-splines when ',...
    '      there is any region of NaN or Inf in the images. ']};


%------------------------------------------------------------------------

ewrap.type   = 'menu';
ewrap.name   = 'Wrapping';
ewrap.tag    = 'ewrap';
ewrap.labels = {'No wrap','Wrap X','Wrap Y','Wrap X & Y','Wrap Z ',...
    'Wrap X & Z','Wrap Y & Z','Wrap X, Y & Z'};
ewrap.values = {[0 0 0],[1 0 0],[0 1 0],[1 1 0],[0 0 1],[1 0 1],[0 1 1],[1 1 1]};
ewrap.def    = 'realign.estimate.wrap';
ewrap.help   = {...
    'These are typically: ',...
    '    No wrapping - for images that have already ',...
    '                  been spatially transformed. ',...
    '    Wrap in  Y  - for (un-resliced) MRI where phase encoding ',...
    '                  is in the Y direction (voxel space).'};

%------------------------------------------------------------------------

fwhm.type    = 'entry';
fwhm.name    = 'Smoothing (FWHM)';
fwhm.tag     = 'fwhm';
fwhm.num     = [1 1];
fwhm.strtype = 'e';
p1           = [...
    'The FWHM of the Gaussian smoothing kernel (mm) applied to the ',...
    'images before estimating the realignment parameters.'];

p2           = '    * PET images typically use a 7 mm kernel.';
p3           = '    * MRI images typically use a 5 mm kernel.';
fwhm.help    = {p1,'',p2,'',p3};

%------------------------------------------------------------------------

sep.type = 'entry';
sep.name = 'Separation';
sep.tag  = 'sep';
sep.num  = [1 1];
sep.strtype = 'e';
sep.val  = {4};
sep.help = {[...
    'The separation (in mm) between the points sampled in the ',...
    'reference image.  Smaller sampling distances gives more accurate ',...
    'results, but will be slower.']};

%------------------------------------------------------------------------

rtm.type   = 'menu';
rtm.name   = 'Num Passes';
rtm.tag    = 'rtm';
rtm.labels = {'Register to first','Register to mean'};
rtm.values = {0,1};
p1         = [...
    'Register to first: Images are registered to the first image in the series. ',...
    'Register to mean:   A two pass procedure is used in order to register the ',...
    'images to the mean of the images after the first realignment.'];
p2         =  '    * PET images are typically registered to the mean.';
p3         =  '    * MRI images are typically registered to the first image.';
rtm.help    = {p1,'',p2,'',p3};

%------------------------------------------------------------------------

basfcn.type   = 'menu';
basfcn.name   = 'Basis Functions';
basfcn.tag    = 'basfcn';
basfcn.labels = {'8x8x*','10x10x*','12x12x*','14x14x*'};
basfcn.values = {[8 8],[10 10],[12 12],[14 14]};
basfcn.def    = 'unwarp.estimate.basfcn';
basfcn.help   = {[...
    'Number of basis functions to use for each dimension. ',...
    'If the third dimension is left out, the order for that ',...
    'dimension is calculated to yield a roughly equal spatial ',...
    'cut-off in all directions. Default: [12 12 *]']};

%------------------------------------------------------------------------

regorder.type   = 'menu';
regorder.name   = 'Regularisation';
regorder.tag    = 'regorder';
regorder.labels = {'0','1','2','3'};
regorder.values = {0,1,2,3};
regorder.def    = 'unwarp.estimate.regorder';
regorder.help   = {[...
     'Unwarp looks for the solution that maximises the likelihood ',...
     '(minimises the variance) while simultaneously maximising the ',...
     'smoothness of the estimated field (c.f. Lagrange multipliers). ',...
     'This parameter determines how to balance the compromise between ',...
     'these (i.e. the value of the multiplier). Test it on your own ',...
     'data (if you can be bothered) or go with the defaults. '],...
     '',[...
     'Regularisation of derivative fields is based on the regorder''th ',...
     '(spatial) derivative of the field. The choices are ',...
     '0, 1, 2, or 3.  Default: 1']};

%------------------------------------------------------------------------

lambda.type   = 'menu';
lambda.name   = 'Reg. Factor';
lambda.tag    = 'lambda';
lambda.labels = {'A little','Medium','A lot'};
lambda.values = {1e4, 1e5, 1e6,};
lambda.def    = 'unwarp.estimate.regwgt';
lambda.help   = {'Regularisation factor. Default: Medium.'};

%------------------------------------------------------------------------

rem.type   = 'menu';
rem.name   = 'Re-estimate movement params';
rem.tag    = 'rem';
rem.labels = {'Yes','No'};
rem.values = {1 0};
rem.def    = 'unwarp.estimate.rem';
rem.help   = {[...
    'Re-estimation means that movement-parameters should be re-estimated ',...
    'at each unwarping iteration. Default: Yes.']};

%------------------------------------------------------------------------

jm.type   = 'menu';
jm.name   = 'Jacobian deformations';
jm.tag    = 'jm';
jm.labels = {'Yes','No'};
jm.values = {1 0};
jm.def    = 'unwarp.estimate.jm';
jm.help   = {[...
     'In the defaults there is also an option to include Jacobian ',...
     'intensity modulation when estimating the fields. "Jacobian ',...
     'intensity modulation" refers to the dilution/concentration ',...
     'of intensity that ensue as a consequence of the distortions. ',...
     'Think of a semi-transparent coloured rubber sheet that you ',...
     'hold against a white background. If you stretch a part of ',...
     'the sheet (induce distortions) you will see the colour fading ',...
     'in that particular area. In theory it is a brilliant idea to ',...
     'include also these effects when estimating the field (see e.g. ',...
     'Andersson et al, NeuroImage 20:870-888). In practice for this ',...
     'specific problem it is NOT a good idea. Default: No']};

%------------------------------------------------------------------------

fot.type    = 'entry';
fot.name    = 'First-order effects';
fot.tag     = 'fot';
fot.strtype = 'e';
fot.num     = [1 Inf];
fot.val     = {[4 5]};
p1          = [...
    'Theoretically (ignoring effects of shimming) one would expect the ',...
    'field to depend only on subject out-of-plane rotations. Hence the ',...
    'default choice ("Pitch and Roll", i.e., [4 5]). Go with that unless you have very ',...
    'good reasons to do otherwise'];
p2 = [...
    'Vector of first order effects to model. Movements to be modelled ',...
    'are referred to by number. 1= x translation; 2= y translation; 3= z translation ',...
    '4 = x rotation,  5 = y rotation and 6 = z rotation.'];
p3 = 'To model pitch & roll enter: [4 5]';
p4 = 'To model all movements enter: [1:6]';
p5 = 'Otherwise enter a customised set of movements to model';

fot.help = {p1,'',p2,'',p3,'',p4,'',p5};

%------------------------------------------------------------------------

sot.type    = 'entry';
sot.name    = 'Second-order effects';
sot.tag     = 'sot';
sot.strtype = 'e';
sot.num     = [1 Inf];
sot.val     = {[]};
p1          = [...
    'List of second order terms to model second derivatives of. This is entered ',...
    'as  a vector of movement parameters similar to first order effects, or leave blank for NONE'];
p2          = 'Movements to be modelled are referred to by number:';
p3          = [...
    '1= x translation; 2= y translation; 3= z translation ',...
    '4 = x rotation,  5 = y rotation and 6 = z rotation.'];
p4          = 'To model the interaction of pitch & roll enter: [4 5]';
p5          = 'To model all movements enter: [1:6]';
p6          = [...
    'The vector will be expanded into an n x 2 matrix of effects. For example ',...
    '[4 5] will be expanded to:'];
p7 = '[ 4 4';
p8 = '  4 5';
p9 = '  5 5 ]';
sot.help = {p1,'',p2,'',p3,'',p4,'',p5,'',p6,'',p7,'',p8,'',p9};

% put the expression in the context of the base workspace.
% assignin('base','soe',@SOE)
%----------------------------------------------------------------------

uwfwhm.type    = 'entry';
uwfwhm.name    = 'Smoothing for unwarp (FWHM)';
uwfwhm.tag     = 'uwfwhm';
uwfwhm.num     = [1 1];
uwfwhm.strtype = 'r';
uwfwhm.def     = 'unwarp.estimate.fwhm';
uwfwhm.help    = {...
'FWHM (mm) of smoothing filter applied to images prior to estimation of deformation fields.'};

%----------------------------------------------------------------------
noi.type = 'entry';
noi.name = 'Number of Iterations';
noi.tag  = 'noi';
noi.num  = [1 1];
noi.strtype = 'n';
noi.def     = 'unwarp.estimate.noi';
noi.help = {'Maximum number of iterations. Default: 5.'};
%----------------------------------------------------------------------

expround.type   = 'menu';
expround.name   = 'Taylor expansion point';
expround.tag    = 'expround';
expround.labels = {'Average','First','Last'};
expround.values = {'Average','First','Last'};
expround.def    = 'unwarp.estimate.expround';
expround.help   = {[...
    'Point in position space to perform Taylor-expansion around. ',...
    'Choices are (''First'', ''Last'' or ''Average''). ''Average'' should ',...
    '(in principle) give the best variance reduction. If a field-map acquired ',...
    'before the time-series is supplied then expansion around the ''First'' ',...
    'MIGHT give a slightly better average geometric fidelity.']};

%----------------------------------------------------------------------

%----------------------------------------------------------------------

unnecessary.type = 'const';
unnecessary.tag  = 'unnecessary';
unnecessary.val  = {[]};
unnecessary.name = 'No Phase Maps';
unnecessary.help = {'Precalculated phase maps not included in unwarping.'};
%----------------------------------------------------------------------


global defaults
if ~isempty(defaults) && isfield(defaults,'modality') ...
        && strcmpi(defaults.modality,'pet'),
    fwhm.val = {7};
    rtm.val  = {1};
else
    fwhm.val = {5};
    rtm.val  = {0};
end;

eoptions.type = 'branch';
eoptions.name = 'Estimation Options';
eoptions.tag  = 'eoptions';
eoptions.val  = {quality,sep,fwhm,rtm,einterp,ewrap,weight};
eoptions.help = {['Various registration options that could be modified to improve the results. ',...
'Whenever possible, the authors of SPM try to choose reasonable settings, but sometimes they can be improved.']};

%------------------------------------------------------------------------

which.type = 'menu';
which.name = 'Resliced images';
which.tag  = 'which';
which.labels = {' All Images (1..n)',' Images 2..n ',...
    ' All Images + Mean Image',' Mean Image Only'};
which.values = {[2 0],[1 0],[2 1],[0 1]};
which.val    = {[2 1]};
which.help = {...
    'All Images (1..n) ',...
    ['  This reslices all the images - including the first image selected '...
    '  - which will remain in its original position. '],...
    ' ',...
    'Images 2..n ',...
    ['   Reslices images 2..n only. Useful for if you wish to reslice ',...
    '   (for example) a PET image to fit a structural MRI, without ',...
    '   creating a second identical MRI volume. '],...
    ' ',...
    'All Images + Mean Image ',...
    ['   In addition to reslicing the images, it also creates a mean of the ',...
    '   resliced image. '],...
    ' ',...
    'Mean Image Only ',...
    '   Creates the mean image only.'};

%------------------------------------------------------------------------

uwwhich.type = 'menu';
uwwhich.name = 'Reslices images (unwarp)?';
uwwhich.tag  = 'uwwhich';
uwwhich.labels = {' All Images (1..n)',' All Images + Mean Image'};
uwwhich.values = {[2 0],[2 1]};
uwwhich.val    = {[2 1]};
uwwhich.help = {...
    'All Images (1..n) ',...
    '  This reslices and unwarps all the images. ',...
    ' ',...
    'All Images + Mean Image ',...
    ['   In addition to reslicing the images, it also creates a mean ',...
    '   of the resliced images.']};
%------------------------------------------------------------------------

rinterp.type = 'menu';
rinterp.name = 'Interpolation';
rinterp.tag  = 'rinterp';
rinterp.labels = {'Nearest neighbour','Trilinear','2nd Degree B-spline ',...
    '3rd Degree B-Spline','4th Degree B-Spline','5th Degree B-Spline ',...
    '6th Degree B-Spline','7th Degree B-Spline'};
rinterp.values = {0,1,2,3,4,5,6,7};
rinterp.def  = 'realign.write.interp';
rinterp.help = {...
   ['The method by which the images are sampled when being written in a ',...
    'different space. '],...
   ['    Nearest Neighbour ',...
    '    - Fastest, but not normally recommended.'],...
    ['    Bilinear Interpolation ',...
    '    - OK for PET, or realigned fMRI. ',...
    '    B-spline Interpolation/*\cite{thevenaz00a}*/'],...
    ['    - Better quality (but slower) interpolation, especially ',...
    '      with higher degree splines.  Do not use B-splines when ',...
    '      there is any region of NaN or Inf in the images. ']};

%------------------------------------------------------------------------

wrap.type = 'menu';
wrap.name = 'Wrapping';
wrap.tag  = 'wrap';
wrap.labels = {'No wrap','Wrap X','Wrap Y','Wrap X & Y','Wrap Z ',...
    'Wrap X & Z','Wrap Y & Z','Wrap X, Y & Z'};
wrap.values = {[0 0 0],[1 0 0],[0 1 0],[1 1 0],[0 0 1],[1 0 1],[0 1 1],[1 1 1]};
wrap.def    = 'realign.write.wrap';
wrap.help = {...
    'These are typically: ',...
    ['    No wrapping - for PET or images that have already ',...
    '                  been spatially transformed. '],...
    ['    Wrap in  Y  - for (un-resliced) MRI where phase encoding ',...
    '                  is in the Y direction (voxel space).']};

%------------------------------------------------------------------------

mask.type = 'menu';
mask.name = 'Masking';
mask.tag  = 'mask';
mask.labels = {'Mask images','Dont mask images'};
mask.values = {1,0};
mask.def    = 'realign.write.mask';
mask.help = {[...
    'Because of subject motion, different images are likely to have different ',...
    'patterns of zeros from where it was not possible to sample data. ',...
    'With masking enabled, the program searches through the whole time series ',...
    'looking for voxels which need to be sampled from outside the original ',...
    'images. Where this occurs, that voxel is set to zero for the whole set ',...
    'of images (unless the image format can represent NaN, in which case ',...
    'NaNs are used where possible).']};

%------------------------------------------------------------------------

uweoptions.type = 'branch';
uweoptions.name = 'Unwarp Estimation Options';
uweoptions.tag  = 'uweoptions';
uweoptions.val  = {basfcn,regorder,lambda,jm,fot,sot,uwfwhm,rem,noi,expround};
uweoptions.help = {'Various registration & unwarping estimation options.'};

%------------------------------------------------------------------------

uwroptions.type = 'branch';
uwroptions.name = 'Unwarp Reslicing Options';
uwroptions.tag  = 'uwroptions';
uwroptions.val  = {uwwhich,rinterp,wrap,mask};
uwroptions.help = {'Various registration & unwarping estimation options.'};
%------------------------------------------------------------------------


scans.type = 'files';
scans.name = 'Images';
scans.tag  = 'scans';
scans.num  = [1 Inf];
scans.filter = 'image';
scans.help   = {...
    'Select scans for this session. ',[...
    'In the coregistration step, the sessions are first realigned to ',...
    'each other, by aligning the first scan from each session to the ',...
    'first scan of the first session.  Then the images within each session ',...
    'are aligned to the first image of the session. ',...
    'The parameter estimation is performed this way because it is assumed ',...
    '(rightly or not) that there may be systematic differences ',...
    'in the images between sessions.']};

%------------------------------------------------------------------------

pmscan.type = 'files';
pmscan.name = 'Phase map (vdm* file)';
pmscan.tag  = 'pmscan';
pmscan.num  = [0 1];
pmscan.val  = {{}};
pmscan.filter = 'image';
pmscan.ufilter = '^vdm5_.*';
pmscan.help   = {[...
    'Select pre-calculated phase map, or leave empty for no phase correction. ',...
    'The vdm* file is assumed to be already in alignment with the first scan ',...
    'of the first session.']};

%----------------------------------------------------------------------

data.type = 'branch';
data.name = 'Session';
data.tag  = 'data';
data.val  = {scans, pmscan};
p2        = [...
'Only add similar session data to a realign+unwarp branch, i.e., ',...
'choose Data or Data+phase map for all sessions, but don''t use them ',...
'interchangeably.'];
p3        = [...
'In the coregistration step, the sessions are first realigned to ',...
'each other, by aligning the first scan from each session to the ',...
'first scan of the first session.  Then the images within each session ',...
'are aligned to the first image of the session. ',...
'The parameter estimation is performed this way because it is assumed ',...
'(rightly or not) that there may be systematic differences ',...
'in the images between sessions.'];
data.help   = {p2,'',p3};

%------------------------------------------------------------------------
ruwdata.type   = 'repeat';
ruwdata.name   = 'Data';
ruwdata.tag    = 'ruwdata';
ruwdata.values = {data};
ruwdata.num    = [1 Inf];
ruwdata.help   = {'Data sessions to unwarp.'};
%------------------------------------------------------------------------

opts.type = 'branch';
opts.name = 'Realign & Unwarp';
opts.tag  = 'realignunwarp';
opts.val = {ruwdata,eoptions,uweoptions,uwroptions};
opts.prog   = @realunwarp;
opts.vfiles = @vfiles_rureslice;
opts.modality = {'PET','FMRI','VBM'};
opts.help = {...
'Within-subject registration and unwarping of time series.',...
'',...
[...
'The realignment part of this routine realigns a time-series of images ',...
'acquired from the same subject using a least squares approach and a ',...
'6 parameter (rigid body) spatial transformation.  The first image in ',...
'the list specified by the user is used as a reference to which all ',...
'subsequent scans are realigned. The reference scan does not have to ',...
'the the first chronologically and it may be wise to chose a ',...
'"representative scan" in this role.'],...
'',...
[...
'The aim is primarily to remove movement artefact in fMRI and PET ',...
'time-series (or more generally longitudinal studies). ',...
'".mat" files are written for each of the input images. ',...
'The details of the transformation are displayed in the results window ',...
'as plots of translation and rotation. ',...
'A set of realignment parameters are saved for each session, named ',...
'rp_*.txt.'],...
'',...
[...
'In the coregistration step, the sessions are first realigned to ',...
'each other, by aligning the first scan from each session to the ',...
'first scan of the first session.  Then the images within each session ',...
'are aligned to the first image of the session. ',...
'The parameter estimation is performed this way because it is assumed ',...
'(rightly or not) that there may be systematic differences ',...
'in the images between sessions.'],...
[...
'The paper/* \cite{ja_geometric}*/ is unfortunately a bit old now and describes none of ',...
'the newer features. Hopefully we''ll have a second paper out any ',...
'decade now.'],...
'',...
[...
'See also spm_uw_estimate.m for a detailed description of the ',...
'implementation. ',...
'Even after realignment there is considerable variance in fMRI time ',...
'series that covary with, and is most probably caused by, subject ',...
'movements/* \cite{ja_geometric}*/. It is also the case that this variance is typically ',...
'large compared to experimentally induced variance. Anyone interested ',...
'can include the estimated movement parameters as covariates in the ',...
'design matrix, and take a look at an F-contrast encompassing those ',...
'columns. It is quite dramatic. The result is loss of sensitivity, ',...
'and if movements are correlated to task specificity. I.e. we may ',...
'mistake movement induced variance for true activations. ',...
'The problem is well known, and several solutions have been suggested. ',...
'A quite pragmatic (and conservative) solution is to include the ',...
'estimated movement parameters (and possibly squared) as covariates ',...
'in the design matrix. Since we typically have loads of degrees of ',...
'freedom in fMRI we can usually afford this. The problems occur when ',...
'movements are correlated with the task, since the strategy above ',...
'will discard "good" and "bad" variance alike (i.e. remove also "true" ',...
'activations.'],...
'',...
[...
'The "covariate" strategy described above was predicated on a model ',...
'where variance was assumed to be caused by "spin history" effects, ',...
'but will work pretty much equally good/bad regardless of what the ',...
'true underlying cause is. Others have assumed that the residual variance ',...
'is caused mainly by errors introduced by the interpolation kernel in the ',...
'resampling step of the realignment. One has tried to solve this through ',...
'higher order resampling (huge Sinc kernels, or k-space resampling). ',...
'Unwarp is based on a different hypothesis regarding the residual ',...
'variance. EPI images are not particularly faithful reproductions of ',...
'the object, and in particular there are severe geometric distortions ',...
'in regions where there is an air-tissue interface (e.g. orbitofrontal ',...
'cortex and the anterior medial temporal lobes). In these areas in ',...
'particular the observed image is a severely warped version of reality, ',...
'much like a funny mirror at a fair ground. When one moves in front of ',...
'such a mirror ones image will distort in different ways and ones head ',...
'may change from very elongated to seriously flattened. If we were to ',...
'take digital snapshots of the reflection at these different positions ',...
'it is rather obvious that realignment will not suffice to bring them ',...
'into a common space.'],...
'',...
[...
'The situation is similar with EPI images, and an image collected for ',...
'a given subject position will not be identical to that collected at ',...
'another. We call this effect susceptibility-by-movement interaction. ',...
'Unwarp is predicated on the assumption that the susceptibility-by- ',...
'movement interaction is responsible for a sizable part of residual ',...
'movement related variance.'],...
'',...
[...
'Assume that we know how the deformations change when the subject ',...
'changes position (i.e. we know the derivatives of the deformations ',...
'with respect to subject position). That means that for a given time ',...
'series and a given set of subject movements we should be able to ',...
'predict the "shape changes" in the object and the ensuing variance ',...
'in the time series. It also means that, in principle, we should be ',...
'able to formulate the inverse problem, i.e. given the observed ',...
'variance (after realignment) and known (estimated) movements we should ',...
'be able to estimate how deformations change with subject movement. ',...
'We have made an attempt at formulating such an inverse model, and at ',...
'solving for the "derivative fields". A deformation field can be ',...
'thought of as little vectors at each position in space showing how ',...
'that particular location has been deflected. A "derivative field" ',...
'is then the rate of change of those vectors with respect to subject ',...
'movement. Given these "derivative fields" we should be able to remove ',...
'the variance caused by the susceptibility-by-movement interaction. ',...
'Since the underlying model is so restricted we would also expect ',...
'experimentally induced variance to be preserved. Our experiments ',...
'have also shown this to be true.'],...
'',...
[...
'In theory it should be possible to estimate also the "static" ',...
'deformation field, yielding an unwarped (to some true geometry) ',...
'version of the time series. In practise that doesn''t really seem to ',...
'work. Hence, the method deals only with residual movement related ',...
'variance induced by the susceptibility-by-movement interaction. ',...
'This means that the time-series will be undistorted to some ',...
'"average distortion" state rather than to the true geometry. ',...
'If one wants additionally to address the issue of anatomical ',...
'fidelity one should combine Unwarp with a measured fieldmap.'],...
'',...
[...
'The description above can be thought of in terms of a Taylor ',...
'expansion of the field as a function of subject movement. Unwarp ',...
'alone will estimate the first (and optionally second, see below) ',...
'order terms of this expansion. It cannot estimate the zeroth ',...
'order term (the distortions common to all scans in the time ',...
'series) since that doesn''t introduce (almost) any variance in ',...
'the time series. The measured fieldmap takes the role of the ',...
'zeroth order term. Refer to the FieldMap toolbox and the ',...
'documents FieldMap.man and FieldMap_principles.man for a ',...
'description of how to obtain fieldmaps in the format expected ',...
'by Unwarp.'],...
'',...
[...
'If we think of the field as a function of subject movement it ',...
'should in principle be a function of six variables since rigid ',...
'body movement has six degrees of freedom. However, the physics ',...
'of the problem tells us that the field should not depend on ',...
'translations nor on rotation in a plane perpendicular to the ',...
'magnetic flux. Hence it should in principle be sufficient to ',...
'model the field as a function of out-of-plane rotations (i.e. ',...
'pitch and roll). One can object to this in terms of the effects ',...
'of shimming (object no longer immersed in a homogenous field) ',...
'that introduces a dependence on all movement parameters. In ',...
'addition SPM/Unwarp cannot really tell if the transversal ',...
'slices it is being passed are really perpendicular to the flux ',...
'or not. In practice it turns out thought that it is never (at ',...
'least we haven''t seen any case) necessary to include more ',...
'than Pitch and Roll. This is probably because the individual ',...
'movement parameters are typically highly correlated anyway, ',...
'which in turn is probably because most heads that we scan ',...
'are attached to a neck around which rotations occur. ',...
'On the subject of Taylor expansion we should mention that there ',...
'is the option to use a second-order expansion (through the ',...
'defaults) interface. This implies estimating also the ',...
'rate-of-change w.r.t. to some movement parameter of ',...
'the rate-of-change of the field w.r.t. some movement parameter ',...
'(colloquially known as a second derivative). It can be quite ',...
'interesting to watch (and it is amazing that it is possible) ',...
'but rarely helpful/necessary.'],...
'',...
[...
'In the defaults there is also an option to include Jacobian ',...
'intensity modulation when estimating the fields. "Jacobian ',...
'intensity modulation" refers to the dilution/concentration ',...
'of intensity that ensue as a consequence of the distortions. ',...
'Think of a semi-transparent coloured rubber sheet that you ',...
'hold against a white background. If you stretch a part of ',...
'the sheet (induce distortions) you will see the colour fading ',...
'in that particular area. In theory it is a brilliant idea to ',...
'include also these effects when estimating the field (see e.g. ',...
'Andersson et al, NeuroImage 20:870-888). In practice for this ',...
'specific problem it is NOT a good idea.'],...
'',...
[...
'It should be noted that this is a method intended to correct ',...
'data afflicted by a particular problem. If there is little ',...
'movement in your data to begin with this method will do you little ',...
'good. If on the other hand there is appreciable movement in your ',...
'data (>1deg) it will remove some of that unwanted variance. If, ',...
'in addition, movements are task related it will do so without ',...
'removing all your "true" activations. ',...
'The method attempts to minimise total (across the image volume) ',...
'variance in the data set. It should be realised that while ',...
'(for small movements) a rather limited portion of the total ',...
'variance is removed, the susceptibility-by-movement interaction ',...
'effects are quite localised to "problem" areas. Hence, for a ',...
'subset of voxels in e.g. frontal-medial and orbitofrontal cortices ',...
'and parts of the temporal lobes the reduction can be quite dramatic ',...
'(>90). ',...
'The advantages of using Unwarp will also depend strongly on the ',...
'specifics of the scanner and sequence by which your data has been ',...
'acquired. When using the latest generation scanners distortions ',...
'are typically quite small, and distortion-by-movement interactions ',...
'consequently even smaller. A small check list in terms of ',...
'distortions is '],...
'a) Fast gradients->short read-out time->small distortions ',...
'b) Low field (i.e. <3T)->small field changes->small distortions ',...
'c) Low res (64x64)->short read-out time->small distortions ',...
'd) SENSE/SMASH->short read-out time->small distortions ',[...
'If you can tick off all points above chances are you have minimal ',...
'distortions to begin with and you can say "sod Unwarp" (but not ',...
'to our faces!).']};...

%------------------------------------------------------------------------

%------------------------------------------------------------------------

return;

%------------------------------------------------------------------------

%------------------------------------------------------------------------
function realunwarp(varargin)
job = varargin{1};

% assemble flags
%-----------------------------------------------------------------------
% assemble realignment estimation flags.
flags.quality = job.eoptions.quality;
flags.fwhm    = job.eoptions.fwhm;
flags.sep     = job.eoptions.sep;
flags.rtm     = job.eoptions.rtm;
flags.PW      = strvcat(job.eoptions.weight);
flags.interp  = job.eoptions.einterp;
flags.wrap    = job.eoptions.ewrap;

uweflags.order     = job.uweoptions.basfcn;
uweflags.regorder  = job.uweoptions.regorder;
uweflags.lambda    = job.uweoptions.lambda;
uweflags.jm        = job.uweoptions.jm;
uweflags.fot       = job.uweoptions.fot;

if ~isempty(job.uweoptions.sot)
    cnt = 1;
    for i=1:size(job.uweoptions.sot,2)
        for j=i:size(job.uweoptions.sot,2)
            sotmat(cnt,1) = job.uweoptions.sot(i);
            sotmat(cnt,2) = job.uweoptions.sot(j);
            cnt = cnt+1;
        end
    end
else
    sotmat = [];
end
uweflags.sot       = sotmat;
uweflags.fwhm      = job.uweoptions.uwfwhm;
uweflags.rem       = job.uweoptions.rem;
uweflags.noi       = job.uweoptions.noi;
uweflags.exp_round = job.uweoptions.expround;

uwrflags.interp    = job.uwroptions.rinterp;
uwrflags.wrap      = job.uwroptions.wrap;
uwrflags.mask      = job.uwroptions.mask;
uwrflags.which     = job.uwroptions.uwwhich(1);
uwrflags.mean      = job.uwroptions.uwwhich(2);

if uweflags.jm == 1
    uwrflags.udc = 2;
else
    uwrflags.udc = 1;
end
%---------------------------------------------------------------------

% assemble files
%---------------------------------------------------------------------
P             = {};
for i = 1:numel(job.data)
        P{i} = strvcat(job.data(i).scans{:});
        if ~isempty(job.data(i).pmscan)
            sfP{i} = job.data(i).pmscan{1};
        else
            sfP{i} = [];
        end
end
% realign
%----------------------------------------------------------------
spm_realign(P,flags);

for i = 1:numel(P)
    uweflags.sfP = sfP{i};

    % unwarp estimate
    %----------------------------------------------------------------
    tmpP = spm_vol(P{i}(1,:));
    uweflags.M = tmpP.mat;
    ds = spm_uw_estimate(P{i},uweflags);
    ads(i) = ds;
    [path,name] = fileparts(P{i}(1,:));
    pefile =  fullfile(path,[name '_uw.mat']);

    if spm_matlab_version_chk('7') >= 0
        save(pefile,'-V6','ds');
    else
        save(pefile,'ds');
    end;
end;
% unwarp write - done at the single subject level since Batch
% forwards one subjects data at a time for analysis, assuming
% that subjects should be grouped as new spatial nodes. Sessions
% should be within subjects.
%----------------------------------------------------------------
spm_uw_apply(ads,uwrflags);
return;


%------------------------------------------------------------------------

%------------------------------------------------------------------------

function vf = vfiles_rureslice(job)
P = job.data;
if numel(P)>0 && iscell(P(1).scans),
    P = cat(1,P(:).scans);
end;

switch job.uwroptions.uwwhich(1),
    case 0,
        vf = {};
    case 2,
        vf = cell(numel(P),1);
        for i=1:length(vf),
            [pth,nam,ext,num] = spm_fileparts(P{i});
            vf{i} = fullfile(pth,['u', nam, ext, num]);
        end;
end;
if job.uwroptions.uwwhich(2),
    [pth,nam,ext,num] = spm_fileparts(P{1});
    vf = {vf{:}, fullfile(pth,['meanu', nam, ext, num])};
end;
