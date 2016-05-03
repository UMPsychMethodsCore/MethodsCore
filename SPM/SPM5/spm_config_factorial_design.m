function conf = spm_config_factorial_design
% Configuration file for specification of factorial designs
%
% This function configures the design matrix (describing the general
% linear model), data specification, and other parameters necessary for
% the statistical analysis. These parameters are saved in a
% configuration file (SPM.mat) in the current directory, and are
% passed on to spm_spm.m (via the Estimate button) which estimates the design.
% Inference on these estimated parameters is then handled by the SPM
% results section.
%
% This function comprises two parts. The first defines
% the user interface and the second sets up the necessary SPM structures.
% The second part has been largely cannibalised from spm_spm_ui.m which
% we have retained for developmental continuity.
%
% It has in common with spm_spm_ui.m its use of the I factor matrix,
% the H,C,B,G design matrix partitions, the sF,sCFI,CFIforms,sCC,CCforms,
% sGXcalc,sGloNorm,sGMsca option definition variables and use of the
% functions spm_DesMtx.m, spm_meanby.m and spm_non_sphericity.m.
%
% It departs from spm_spm_ui.m in that it does not use the design
% definition data structure D. Also, it uses the new SPM.factor field,
% which for the case of full factorial designs, is used to automatically
% generate contrasts testing for main effects and interactions.
%
% This function departs from spm_spm_ui.m in that it does not provide
% the same menu of design options (these were hardcoded in D). Instead it
% provides a number of options for simple designs (1) One-sample t-test,
% (2) Two-sample t-test, (3) Paired t-test and (4) Multiple regression.
% Two facilities are provided for specifying more complicated designs
% (5) Full-factorial and (6) Flexible-factorial. These should be able to
% specify all design options (and more) that were available in SPM2.
% For each of these design types one can additionally specify regressors using the
% `covariates' option.
%
% Options (5) and (6) differ in the
% efficiency (eg. number of key strokes/button presses) with which a given
% design can be specified. For example, one-way ANOVAs can be specified
% using either option, but (5) is usually more efficient.
%
% Full-factorial designs
% ______________________
%
% This option is best used when you wish to test for all
% main effects and interactions in one-way, two-way or three-way ANOVAs.
%
% Design specification proceeds in 2 stages. Firstly, by creating new
% factors and specifying the
% number of levels and name for each. Nonsphericity, ANOVA-by-factor (for PET data)
% and
% scaling options (for PET data) can also be specified at this stage. Secondly,
% scans are assigned separately to each cell. This accomodates unbalanced designs.
%
% For example, if you wish to test for a main effect in the population
% from which your subjects are drawn
% and have modelled that effect at the first level using K basis functions
% (eg. K=3 informed basis functions) you can use a one-way ANOVA with K-levels.
% Create a single factor with K levels and then assign the data to each
% cell eg. canonical, temporal derivative and dispersion derivative cells,
% where each cell is assigned scans from multiple subjects.
%
% SPM will automatically generate the contrasts necessary to test for all
% main effects and interactions
%
% Flexible-factorial designs
% __________________________
%
% In this option the design matrix is created a block at a time. You can
% decide whether you wish each block to be a main effect or a (two-way)
% interaction.
%
% This option is best used for one-way, two-way or
% three-way ANOVAs but where you do not wish to test for all possible
% main effects and interactions. This is perhaps most useful for PET
% where there is usually not enough data to test for all possible
% effects. Or for 3-way ANOVAs where you do not wish to test for all
% of the two-way interactions. A typical example here would be a
% group-by-drug-by-task analysis where, perhaps, only (i) group-by-drug or
% (ii) group-by-task interactions are of interest. In this case it is only
% necessary to have two-blocks in the design matrix - one for each
% interaction. The three-way interaction can then be tested for using a
% contrast that computes the difference between (i) and (ii).
%
% Design specification then proceeds in 3 stages. Firstly, factors
% are created and names specified for each. Nonsphericity, ANOVA-by-factor and
% scaling options can also be specified at this stage.
%
% Secondly, a list of
% scans is produced along with a factor matrix, I. This is an nscan x 4 matrix
% of factor level indicators (see xX.I below). The first factor must be
% 'replication' but the other factors can be anything. Specification of I and
% the scan list can be achieved in
% one of two ways (a) the 'Specify All' option allows I
% to be typed in at the user interface or (more likely) loaded in from the matlab
% workspace. All of the scans are then selected in one go. (b) the
% 'Subjects' option allows you to enter scans a subject at a time. The
% corresponding experimental conditions (ie. levels of factors) are entered
% at the same time. SPM will then create the factor matrix I. This style of
% interface is similar to that available in SPM2.
%
% Thirdly, the design matrix is built up a block at a time. Each block
% can be a main effect or a (two-way) interaction.
%
%
% ----------------------------------------------------------------------
%
% Variables saved in the SPM stucture
%
% xY.VY         - nScan x 1 struct array of memory mapped images
%                 (see spm_vol for definition of the map structure)
% xX            - structure describing design matrix
% xX.I          - nScan x 4 matrix of factor level indicators
%                 I(n,i) is the level of factor i corresponding to image n
% xX.sF         - 1x4 cellstr containing the names of the four factors
%                 xX.sF{i} is the name of factor i
% xX.X          - design matrix
% xX.xVi        - correlation constraints for non-spericity correction
% xX.iH         - vector of H partition (condition effects) indices,
%                 identifying columns of X correspoding to H
% xX.iC         - vector of C partition (covariates of interest) indices
% xX.iB         - vector of B partition (block effects) indices
% xX.iG         - vector of G partition (nuisance variables) indices
% xX.name     - p x 1 cellstr of effect names corresponding to columns
%                 of the design matrix
%
% xC            - structure array of covariate details
% xC(i).rc      - raw (as entered) i-th covariate
% xC(i).rcname  - name of this covariate (string)
% xC(i).c       - covariate as appears in design matrix (after any scaling,
%                 centering of interactions)
% xC(i).cname   - cellstr containing names for effects corresponding to
%                 columns of xC(i).c
% xC(i).iCC     - covariate centering option
% xC(i).iCFI    - covariate by factor interaction option
% xC(i).type    - covariate type: 1=interest, 2=nuisance, 3=global
% xC(i).cols    - columns of design matrix corresponding to xC(i).c
% xC(i).descrip - cellstr containing a description of the covariate
%
% xGX           - structure describing global options and values
% xGX.iGXcalc   - global calculation option used
% xGX.sGXcalc   - string describing global calculation used
% xGX.rg        - raw globals (before scaling and such like)
% xGX.iGMsca    - grand mean scaling option
% xGX.sGMsca    - string describing grand mean scaling
% xGX.GM        - value for grand mean (/proportional) scaling
% xGX.gSF       - global scaling factor (applied to xGX.rg)
% xGX.iGC       - global covariate centering option
% xGX.sGC       - string describing global covariate centering option
% xGX.gc        - center for global covariate
% xGX.iGloNorm  - Global normalisation option
% xGX.sGloNorm  - string describing global normalisation option
%
% xM            - structure describing masking options
% xM.T          - Threshold masking value (-Inf=>None,
%                 real=>absolute, complex=>proportional (i.e. times global) )
% xM.TH         - nScan x 1 vector of analysis thresholds, one per image
% xM.I          - Implicit masking (0=>none, 1=>implicit zero/NaN mask)
% xM.VM         - struct array of explicit mask images
%                 (empty if no explicit masks)
% xM.xs         - structure describing masking options
%                 (format is same as for xsDes described below)
%
% xsDes         - structure of strings describing the design:
%                 Fieldnames are essentially topic strings (use "_"'s for
%                 spaces), and the field values should be strings or cellstr's
%                 of information regarding that topic. spm_DesRep.m
%                 uses this structure to produce a printed description
%                 of the design, displaying the fieldnames (with "_"'s
%                 converted to spaces) in bold as topics, with
%                 the corresponding text to the right%
%
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience

% Will Penny
% $Id: spm_config_factorial_design.m 1601 2008-05-12 14:11:02Z guillaume $

% Define inline types.
%-----------------------------------------------------------------------

entry = inline(['struct(''type'',''entry'',''name'',name,'...
    '''tag'',tag,''strtype'',strtype,''num'',num,''help'',hlp)'],...
    'name','tag','strtype','num','hlp');

files = inline(['struct(''type'',''files'',''name'',name,'...
    '''tag'',tag,''filter'',fltr,''num'',num,''help'',hlp)'],...
    'name','tag','fltr','num','hlp');

mnu = inline(['struct(''type'',''menu'',''name'',name,'...
    '''tag'',tag,''labels'',{labels},''values'',{values},''help'',hlp)'],...
    'name','tag','labels','values','hlp');

branch = inline(['struct(''type'',''branch'',''name'',name,'...
    '''tag'',tag,''val'',{val},''help'',hlp)'],...
    'name','tag','val','hlp');

repeat = inline(['struct(''type'',''repeat'',''name'',name,'...
    '''tag'',tag,''values'',{values},''help'',hlp)'],...
    'name','tag','values','hlp');

choice = inline(['struct(''type'',''choice'',''name'',name,'...
    '''tag'',tag,''values'',{values},''help'',hlp)'],...
    'name','tag','values','hlp');

%-----------------------------------------------------------------------

sp_text = ['                                                      ',...
    '                                                      '];

%-------------------------------------------------------------------------
% Covariates for general use

iCFI    = mnu('Interactions','iCFI',{'None','With Factor 1',...
    'With Factor 2','With Factor 3'},{1,2,3,4},'');
iCFI.val={1};
p1 = ['For each covariate you have defined, there is an opportunity to ',...
    'create an additional regressor that is the interaction between the ',...
    'covariate and a chosen experimental factor. '];
iCFI.help={p1,sp_text};

iCC    = mnu('Centering','iCC',{'Overall mean','Factor 1 mean',...
    'Factor 2 mean','Factor 3 mean','No centering',...
    'User specified value','As implied by ANCOVA',...
    'GM'},{1,2,3,4,5,6,7,8},'');
iCC.val={1};
p1 = ['The appropriate centering option is usually the one that ',...
    'corresponds to the interaction chosen, and ensures that main ',...
    'effects of the interacting factor aren''t affected by the covariate. ',...
    'You are advised to choose this option, unless you have other ',...
    'modelling considerations. '];
iCC.help={p1,sp_text};

cname      = entry('Name','cname','s', [1 Inf],'Name of covariate');

c   = entry('Vector','c','e',[Inf 1],'Vector of covariate values');

cov  = branch('Covariate','cov',{c,cname,iCFI,iCC},'Covariate');

cov.help = {'Add a new covariate to your experimental design'};

covs = repeat('Covariates','covariates',{cov},'');
p1 = ['This option allows for the specification of covariates and ',...
    'nuisance variables. Unlike SPM94/5/6, where the design was ',...
    'partitioned into effects of interest and nuisance effects ',...
    'for the computation of adjusted data and the F-statistic ',...
    '(which was used to thresh out voxels where there appeared to ',...
    'be no effects of interest), SPM5 does not partition the design ',...
    'in this way. The only remaining distinction between effects of ',...
    'interest (including covariates) and nuisance effects is their ',...
    'location in the design matrix, which we have retained for ',...
    'continuity.  Pre-specified design matrix partitions can be entered. '];

covs.help={p1,sp_text};

%-------------------------------------------------------------------------
% Covariates for multiple regression

miCC    = mnu('Centering','iCC',{'Overall mean','No centering'},...
    {1,5},'');
miCC.val= {1};

mcov  = branch('Covariate','mcov',{c,cname,miCC},'Covariate');
mcov.help = {'Add a new covariate to your experimental design'};

mcovs = repeat('Covariates','covariates',{mcov},'Covariates');

incint = mnu('Intercept','incint',{'Include Intercept','Omit Intercept'},{1,0},'');
incint.val = {1};
p1=['By default, an intercept is always added to the model. If the ',...
    'covariates supplied by the user include a constant effect, the ',...
    'intercept may be omitted.'];
incint.help = {p1,sp_text};

%-----------------------------------------------------------------------
%  Specify names of factors, numbers of levels and statistical dependencies

name     = entry('Name','name','s',[1 Inf],'');
name.val = {'Covariate'};
p1=['Enter name of covariate eg. reaction time'];
name.help={p1};

val      = entry('Value','val','e',[Inf 1],'');
val.help={['Enter the vector of covariate values']};

variance    = mnu('Variance','variance',{'Equal','Unequal'},{0,1},'');
variance.val={1};
p1=['By default, the measurements in each level are assumed to have unequal variance. '];
p2=['This violates the assumption of ''sphericity'' and is therefore an example of ',...
    '''non-sphericity''.'];
p3=['This can occur, for example, in a 2nd-level analysis of variance, one ',...
    'contrast may be scaled differently from another.  Another example would ',...
    'be the comparison of qualitatively different dependent variables ',...
    '(e.g. normals vs. patients).  Different variances ',...
    '(heteroscedasticy) induce different error covariance components that ',...
    'are estimated using restricted maximum likelihood (see below).'];
p4=['Restricted Maximum Likelihood (REML): The ensuing covariance components ',...
    'will be estimated using ReML in spm_spm (assuming the same for all ',...
    'responsive voxels) and used to adjust the ',...
    'statistics and degrees of freedom during inference. By default spm_spm ',...
    'will use weighted least squares to produce Gauss-Markov or Maximum ',...
    'likelihood estimators using the non-sphericity structure specified at this ',...
    'stage. The components will be found in SPM.xVi and enter the estimation ',...
    'procedure exactly as the serial correlations in fMRI models.'];
variance.help = {p1,sp_text,p2,sp_text,p3,sp_text,p4,sp_text};

dept    = mnu('Independence','dept',{'Yes','No'},{0,1},'');
dept.val={0};
p1=['By default, the measurements are assumed to be independent between levels. '];
p2=['If you change this option to allow for dependencies, this will violate ',...
    'the assumption of sphericity. It would therefore be an example ',...
    'of non-sphericity. One such example would be where you had repeated ',...
    'measurements from the same subjects - it may then be the case that, over ',...
    'subjects, measure 1 is correlated to measure 2. '];

dept.help = {p1,sp_text,p2,sp_text,p4,sp_text};

fname.type    = 'entry';
fname.name    = 'Name';
fname.tag     = 'name';
fname.strtype = 's';
fname.num     = [1 1];
fname.help    = {'Name of factor, eg. ''Repetition'' '};

levels = entry('Levels','levels','e',[Inf 1],'');
p1=['Enter number of levels for this factor, eg. 2'];
levels.help ={p1};

gmsca = mnu('Grand mean scaling','gmsca',...
    {'No','Yes'},{0,1},'');
gmsca.val={0};
p0=['This option is only used for PET data.'];

p1=['Selecting YES will specify ''grand mean scaling by factor'' which could ',...
    'be eg. ''grand mean scaling by subject'' if the factor is ''subject''. '];

p2 =['Since differences between subjects may be due to gain and sensitivity ',...
    'effects, AnCova by subject could be combined with "grand mean scaling ',...
    'by subject" to obtain a combination of between subject proportional ',...
    'scaling and within subject AnCova. '];
gmsca.help={p0,sp_text,p1,sp_text,p2,sp_text};

ancova = mnu('ANCOVA','ancova',...
    {'No','Yes'},{0,1},'');
ancova.val={0};

p1=['Selecting YES will specify ''ANCOVA-by-factor'' regressors. ',...
    'This includes eg. ''Ancova by subject'' or ''Ancova by effect''. ',...
    'These options allow eg. different subjects ',...
    'to have different relationships between local and global measurements. '];
ancova.help={p0,sp_text,p1,sp_text};

factor.type   = 'branch';
factor.name   = 'Factor';
factor.tag    = 'fact';
factor.val    = {fname,levels,dept,variance,gmsca,ancova};
factor.help = {'Add a new factor to your experimental design'};

factors.type = 'repeat';
factors.name = 'Factors';
factors.tag  = 'factors';
factors.values = {factor};
factors.num  = [1 Inf];
p1 = ['Specify your design a factor at a time. '];
factors.help ={p1,sp_text};

%-------------------------------------------------------------------------
% Associate each cell in factorial design with a list of images

scans    = files('Scans','scans','image',[1 Inf],'Select scans');
scans.help = {[...
    'Select the images for this cell.  They must all have the same ',...
    'image dimensions, orientation, voxel size etc.']};

levels = entry('Levels','levels','e',[Inf 1],'');
p1=['Enter a vector or scalar that specifies which cell in the factorial ',...
    'design these images belong to. The length of this vector should '...
    'correspond to the number of factors in the design'];
p2=['For example, length 2 vectors should be used for two-factor designs ',...
    'eg. the vector [2 3] specifies the cell corresponding to the 2nd-level of the first ',...
    'factor and the 3rd level of the 2nd factor.'];
levels.help ={p1,sp_text,p2,sp_text};

icell.type   = 'branch';
icell.name   = 'Cell';
icell.tag    = 'icell';
icell.val    = {levels,scans};
icell.help = {'Enter data for a cell in your design'};

cells.type = 'repeat';
cells.name = 'Specify cells';
cells.tag  = 'cells';
cells.values = {icell};
cells.num  = [1 Inf];
p1 = ['Enter the scans a cell at a time'];
cells.help={p1,sp_text};

%-------------------------------------------------------------------------
% Create a design block-by-block

fac.type   = 'branch';
fac.name   = 'Factor';
fac.tag    = 'fac';
fac.val    = {fname,dept,variance,gmsca,ancova};
p1=['Add a new factor to your design.'];
p2=['If you are using the ''Subjects'' option to specify your scans ',...
    'and conditions, you may wish to make use of the following facility. ',...
    'There are two reserved words for the names of factors. These are ',...
    '''subject'' and ''repl'' (standing for replication). If you use these ',...
    'factor names then SPM can automatically create replication and/or ',...
    'subject factors without you having to type in an extra entry in the ',...
    'condition vector.'];
p3=['For example, if you wish to model Subject and Task effects (two factors), ',...
    'under Subjects->Subject->Conditions you can type in simply ',...
    '[1 2 1 2] to specify eg. just the ''Task'' factor level. You do not need to ',...
    'eg. for the 4th subject enter the matrix [1 4; 2 4; 1 4; 2 4]. '];

fac.help = {p1,sp_text,p2,sp_text,p3,sp_text};

facs.type = 'repeat';
facs.name = 'Factors';
facs.tag  = 'facs';
facs.values = {fac};
facs.num  = [1 Inf];
p1=['Specify your design a factor at a time.'];
facs.help={p1,sp_text};

fnum = entry('Factor number','fnum','e',[Inf 1],'');
p1=['Enter the number of the factor.'];
fnum.help ={p1};

fnums = entry('Factor numbers','fnums','e',[2 1],'');
p1=['Enter the numbers of the factors of this (two-way) interaction.'];
fnums.help ={p1};

fmain.type   = 'branch';
fmain.name   = 'Main effect';
fmain.tag    = 'fmain';
fmain.val    = {fnum};
fmain.help = {'Add a main effect to your design matrix'};

inter.type   = 'branch';
inter.name   = 'Interaction';
inter.tag    = 'inter';
inter.val    = {fnums};
inter.help = {'Add an interaction to your design matrix'};

maininters.type = 'repeat';
maininters.name = 'Main effects & Interactions';
maininters.num  = [1 Inf];
maininters.tag  = 'maininters';
maininters.values = {fmain, inter};

scans    = files('Scans','scans','image',[1 Inf],'Select scans');
scans.help = {[...
    'Select the images to be analysed.  They must all have the same ',...
    'image dimensions, orientation, voxel size etc.']};

imatrix   = entry('Factor matrix','imatrix','e',[Inf Inf],'');
imatrix.val = {0};
imatrix.help = {['Specify factor/level matrix as a nscan-by-4 matrix. Note' ...
    ' that the first row of I is reserved for the internal' ...
    ' replication factor and must not be used for experimental' ...
    ' factors.']};

specall.type   = 'branch';
specall.name   = 'Specify all';
specall.tag    = 'specall';
specall.val    = {scans,imatrix};
p1=['Specify (i) all scans in one go and (ii) all conditions using a ',...
    'factor matrix, I. This option is for ''power users''. The matrix ',...
    'I must have four columns and as ',...
    'as many rows as scans. It has the same format as SPM''s internal ',...
    'variable SPM.xX.I. '];
p2=['The first column of I denotes the replication number and entries in' ...
    ' the other columns denote the levels of each experimental factor.'];
p3=['So, for eg. a two-factor design the first column ',...
    'denotes the replication number and columns two and three have entries ',...
    'like 2 3 denoting the 2nd level of the first factor and 3rd level of ',...
    'the second factor. The 4th column in I would contain all 1s.'];
specall.help = {p1,sp_text,p2,sp_text,p3};

conds   = entry('Conditions','conds','e',[Inf Inf],'');

fsubject.type   = 'branch';
fsubject.name   = 'Subject';
fsubject.tag    = 'fsubject';
fsubject.val    = {scans,conds};
fsubject.help = {'Enter data and conditions for a new subject'};

fsubjects.type = 'repeat';
fsubjects.name = 'Subjects';
fsubjects.tag  = 'fsubjects';
fsubjects.values = {fsubject};
fsubjects.num  = [1 Inf];

fsuball.type = 'choice';
fsuball.name = 'Specify Subjects or all Scans & Factors';
fsuball.tag  = 'fsuball';
fsuball.values = {fsubjects specall};

%-------------------------------------------------------------------------
% Two-sample t-test

scans1    = files('Group 1 scans','scans1','image',[1 Inf],'Select scans');
scans1.help = {[...
    'Select the images from sample 1.  They must all have the same ',...
    'image dimensions, orientation, voxel size etc.']};

scans2    = files('Group 2 scans','scans2','image',[1 Inf],'Select scans');
scans2.help = {[...
    'Select the images from sample 2.  They must all have the same ',...
    'image dimensions, orientation, voxel size etc.']};

%-------------------------------------------------------------------------
% Paired t-test

pscans    = files('Scans [1,2]','scans','image',[1 2],'Select scans');
pscans.help = {[...
    'Select the pair of images. ']};

pair.type   = 'branch';
pair.name   = 'Pair';
pair.tag    = 'pair';
pair.val    = {pscans};
pair.help = {'Add a new pair of scans to your experimental design'};

pairs.type = 'repeat';
pairs.name = 'Pairs';
pairs.tag  = 'pairs';
pairs.num  = [1 Inf];
pairs.values = {pair};
p1 = [' ',...
    ' '];
pairs.help ={p1,sp_text};

%-------------------------------------------------------------------------
% One sample t-test

t1scans    = files('Scans','scans','image',[1 Inf],'Select scans');
t1scans.help = {[...
    'Select the images.  They must all have the same ',...
    'image dimensions, orientation, voxel size etc.']};

%-------------------------------------------------------------------------
% Design menu

t1 = branch('One-sample t-test','t1',...
    {t1scans},'');

t2 = branch('Two-sample t-test','t2',...
    {scans1,scans2,dept,variance,gmsca,ancova},'');

pt = branch('Paired t-test','pt',...
    {pairs,dept,variance,gmsca,ancova},'');

mreg = branch('Multiple regression','mreg',...
    {t1scans,mcovs,incint},'');

fblock = branch('Flexible factorial','fblock',...
    {facs,fsuball,maininters},'');
pb1 = ['Create a design matrix a block at a time by specifying which ',...
    'main effects and interactions you wish to be included.'];


pb2=['This option is best used for one-way, two-way or ',...
    'three-way ANOVAs but where you do not wish to test for all possible ',...
    'main effects and interactions. This is perhaps most useful for PET ',...
    'where there is usually not enough data to test for all possible ',...
    'effects. Or for 3-way ANOVAs where you do not wish to test for all ',...
    'of the two-way interactions. A typical example here would be a ',...
    'group-by-drug-by-task analysis where, perhaps, only (i) group-by-drug or ',...
    '(ii) group-by-task interactions are of interest. In this case it is only ',...
    'necessary to have two-blocks in the design matrix - one for each ',...
    'interaction. The three-way interaction can then be tested for using a ',...
    'contrast that computes the difference between (i) and (ii).'];

pb3=['Design specification then proceeds in 3 stages. Firstly, factors ',...
    'are created and names specified for each. Nonsphericity, ANOVA-by-factor and ',...
    'scaling options can also be specified at this stage.'];

pb4=['Secondly, a list of ',...
    'scans is produced along with a factor matrix, I. This is an nscan x 4 matrix ',...
    'of factor level indicators (see xX.I below). The first factor must be ',...
    '''replication'' but the other factors can be anything. Specification of I and ',...
    'the scan list can be achieved in ',...
    'one of two ways (a) the ''Specify All'' option allows I ',...
    'to be typed in at the user interface or (more likely) loaded in from the matlab ',...
    'workspace. All of the scans are then selected in one go. (b) the ',...
    '''Subjects'' option allows you to enter scans a subject at a time. The ',...
    'corresponding experimental conditions (ie. levels of factors) are entered ',...
    'at the same time. SPM will then create the factor matrix I. This style of ',...
    'interface is similar to that available in SPM2.'];

pb5=['Thirdly, the design matrix is built up a block at a time. Each block ',...
    'can be a main effect or a (two-way) interaction. '];
fblock.help={pb1,sp_text,pb2,sp_text,pb3,sp_text,pb4,sp_text,pb5,sp_text};

fd = branch('Full factorial','fd',...
    {factors,cells},'');
pfull1=['This option is best used when you wish to test for all ',...
    'main effects and interactions in one-way, two-way or three-way ANOVAs. ',...
    'Design specification proceeds in 2 stages. Firstly, by creating new ',...
    'factors and specifying the ',...
    'number of levels and name for each. Nonsphericity, ANOVA-by-factor and ',...
    'scaling options can also be specified at this stage. Secondly, scans are ',...
    'assigned separately to each cell. This accomodates unbalanced designs.'];

pfull2=['For example, if you wish to test for a main effect in the population ',...
    'from which your subjects are drawn ',...
    'and have modelled that effect at the first level using K basis functions ',...
    '(eg. K=3 informed basis functions) you can use a one-way ANOVA with K-levels. ',...
    'Create a single factor with K levels and then assign the data to each ',...
    'cell eg. canonical, temporal derivative and dispersion derivative cells, ',...
    'where each cell is assigned scans from multiple subjects.'];

pfull3 = ['SPM will also automatically generate ',...
    'the contrasts necessary to test for all main effects and interactions. '];

fd.help={pfull1,sp_text,pfull2,sp_text,pfull3,sp_text};



des = choice('Design','des',...
    {t1,t2,pt,mreg,fd,fblock},'');


%-------------------------------------------------------------------------
% Masking options

im    = mnu('Implicit Mask','im',{'Yes','No'},{1,0},'');
im.val={1};
p1=['An "implicit mask" is a mask implied by a particular voxel ',...
    'value. Voxels with this mask value are excluded from the ',...
    'analysis. '];
p2=['For image data-types with a representation of NaN ',...
    '(see spm_type.m), NaN''s is the implicit mask value, (and ',...
    'NaN''s are always masked out). '];
p3=['For image data-types without a representation of NaN, zero is ',...
    'the mask value, and the user can choose whether zero voxels ',...
    'should be masked out or not.'];
p4=['By default, an implicit mask is used. '];
im.help = {p1,sp_text,p2,sp_text,p3,sp_text,p4,sp_text};

em = files('Explicit Mask','em','image',[0 1],'');
em.val={''};
em.help = {['Select an explicit mask ']};
p1=['Explicit masks are other images containing (implicit) masks ',...
    'that are to be applied to the current analysis.'];
p2=['All voxels with value NaN (for image data-types with a ',...
    'representation of NaN), or zero (for other data types) are ',...
    'excluded from the analysis. '];
p3=['Explicit mask images can have any orientation and voxel/image ',...
    'size. Nearest neighbour interpolation of a mask image is used if ',...
    'the voxel centers of the input images do not coincide with that ',...
    'of the mask image.'];
em.help = {p1,sp_text,p2,sp_text,p3,sp_text};

tm_none.type = 'const';
tm_none.name = 'None';
tm_none.tag = 'tm_none';
tm_none.val = {[]};
tm_none.help = {'No threshold masking'};

athresh = entry('Threshold','athresh','e',[1 1],'');
athresh.val={100};
p1=['Enter the absolute value of the threshold.'];
athresh.help = {p1,sp_text};

tma = branch('Absolute','tma',...
    {athresh},'');
p1=['Images are thresholded at a given value and ',...
    'only voxels at which all images exceed the threshold are included. '];
p2=['This option allows you to specify the absolute value of the threshold.'];
tma.help = {p1,sp_text,p2,sp_text};

p2=['By default, Relative Threshold Masking is turned off. '];
rselect.help = {p1,sp_text,p2,sp_text};

rthresh = entry('Threshold','rthresh','e',[1 1],'');
rthresh.val={0.8};
p1=['Enter the threshold as a proportion of the global value'];
rthresh.help = {p1,sp_text};

tmr = branch('Relative','tmr',...
    {rthresh},'');
p1=['Images are thresholded at a given value and ',...
    'only voxels at which all images exceed the threshold are included. '];
p2=['This option allows you to specify the value of the threshold ',...
    'as a proportion of the global value. '];
tmr.help = {p1,sp_text,p2,sp_text};

tm = choice('Threshold masking','tm',...
    {tm_none,tma,tmr},'');
p1=['Images are thresholded at a given value and ',...
    'only voxels at which all images exceed the threshold are included. '];
tm.help={p1,sp_text};

masking = branch('Masking','masking',...
    {tm,im,em},'');
p1=['The mask specifies the voxels within the image volume which are to be ',...
    'assessed. SPM supports three methods of masking (1) Threshold, ',...
    '(2) Implicit and (3) Explicit. The volume analysed ',...
    'is the intersection of all masks.'];
masking.help={p1,sp_text};

%-------------------------------------------------------------------------
% Global calculation

global_uval = entry('Global values','global_uval','e',[Inf 1],'');
p1=['Enter the vector of global values'];
global_uval.val={0};
global_uval.help={p1,sp_text};

g_user = branch('User','g_user',{global_uval},'');
g_user.help={'User defined  global effects (enter your own ',...
    'vector of global values)'};

g_mean.type = 'const';
g_mean.name = 'Mean';
g_mean.tag = 'g_mean';
g_mean.val = {[]};
p1=['SPM standard mean voxel value'];
p2=['This defines the global mean via a two-step process. Firstly, the overall ',...
    'mean is computed. Voxels with values less than 1/8 of this value are then ',...
    'deemed extra-cranial and get masked out. The mean is then recomputed on the ',...
    'remaining voxels.'];
g_mean.help = {p1,sp_text,p2,sp_text};

g_omit.type = 'const';
g_omit.name = 'Omit';
g_omit.tag = 'g_omit';
g_omit.val = {[]};
g_omit.help = {'Omit'};

globalc = choice('Global calculation','globalc',...
    {g_omit,g_user,g_mean},'');
p1=['There are three methods for estimating global effects ',...
    '(1) Omit (assumming no other options requiring the global value chosen) ',...
    '(2) User defined (enter your own vector of global values) ',...
    '(3) Mean: SPM standard mean voxel value (within per image fullmean/8 mask) '];
globalc.help={p0,sp_text,p1,sp_text};

%-------------------------------------------------------------------------
% Global options

gmsca_no.type = 'const';
gmsca_no.name = 'No';
gmsca_no.tag  = 'gmsca_no';
gmsca_no.val  = {[]};
gmsca_no.help = {'No overall grand mean scaling'};

gmscv      = entry('Grand mean scaled value','gmscv','e',[Inf 1],'');
gmscv.val={50};
p1=['The default value of 50, scales the global flow to a physiologically ',...
    'realistic value of 50ml/dl/min.'];
gmscv.help={p1,sp_text};

gmsca_yes=branch('Yes','gmsca_yes',{gmscv},'');
p1 =['Scaling of the overall grand mean simply ',...
    'scales all the data by a common factor such that the mean of all the ',...
    'global values is the value specified. For qualitative data, this puts ',...
    'the data into an intuitively accessible scale without altering the ',...
    'statistics. '];
gmsca_yes.help={p1,sp_text};

gmsca = choice('Overall grand mean scaling','gmsca',...
    {gmsca_no,gmsca_yes},'');

p2=['When proportional scaling global normalisation is used ',...
    'each image is separately scaled such that it''s global ',...
    'value is that specified (in which case the grand mean is also ',...
    'implicitly scaled to that value). ',...
    'So, to proportionally scale each image so that its global value is ',...
    'eg. 20, select <Yes> then type in 20 for the grand mean scaled value.'];

p3=['When using AnCova or no global ',...
    'normalisation, with data from different subjects or sessions, an ',...
    'intermediate situation may be appropriate, and you may be given the ',...
    'option to scale group, session or subject grand means separately. '];
gmsca.help={p1,sp_text,p2,sp_text,p3,sp_text};



glonorm = mnu('Normalisation','glonorm',...
    {'None','Proportional','ANCOVA'},{1,2,3},'');
glonorm.val={1};
p1 = ['Global nuisance effects are usually ',...
    'accounted for either by scaling the images so that they all have the ',...
    'same global value (proportional scaling), or by including the global ',...
    'covariate as a nuisance effect in the general linear model (AnCova). ',...
    'Much has been written on which to use, and when. Basically, since ',...
    'proportional scaling also scales the variance term, it is appropriate ',...
    'for situations where the global measurement predominantly reflects ',...
    'gain or sensitivity. Where variance is constant across the range of ',...
    'global values, linear modelling in an AnCova approach has more ',...
    'flexibility, since the model is not restricted to a simple ',...
    'proportional regression. '];

p2=['''Ancova by subject'' or ''Ancova by effect'' options are implemented ',...
    'using the ANCOVA options provided where each experimental factor ',...
    '(eg. subject or effect), is defined. These allow eg. different subjects ',...
    'to have different relationships between local and global measurements. '];

p3 =['Since differences between subjects may be due to gain and sensitivity ',...
    'effects, AnCova by subject could be combined with "grand mean scaling ',...
    'by subject" (an option also provided where each experimental factor is ',...
    'originally defined) to obtain a combination of between subject proportional ',...
    'scaling and within subject AnCova. '];
glonorm.help={p1,sp_text,p2,sp_text,p3,sp_text};

globalm = branch('Global normalisation','globalm',...
    {gmsca,glonorm},'');
globalm.help={p0,sp_text,p1,sp_text,p2,sp_text,p3,sp_text};

%-------------------------------------------------------------------------
% Directory

cdir = files('Directory','dir','dir',1,'');
cdir.help = {[...
    'Select a directory where the SPM.mat file containing the ',...
    'specified design matrix will be written.']};

%-------------------------------------------------------------------------
% Main routine

conf = branch('Factorial design specification','factorial_design',...
    {des,covs,masking,globalc,globalm,cdir},'');
p1=['This interface is used for setting up analyses of PET data. It is also ',...
    'used for ''2nd level'' or ''random effects'' analysis which allow ',...
    'one to make a population inference. First level models can be used to produce ',...
    'appropriate summary data, which can then be used as raw data for a second-level ',...
    'analysis. For example, a simple t-test on contrast images from the first-level ',...
    'turns out to be a random-effects analysis with random subject effects, inferring ',...
    'for the population based on a particular sample of subjects.'];

p2=['This interface configures the design matrix, describing the general ',...
    'linear model, data specification, and other parameters necessary for ',...
    'the statistical analysis. These parameters are saved in a ',...
    'configuration file (SPM.mat), which can then be ',...
    'passed on to spm_spm.m which estimates the design. This is achieved by ',...
    'pressing the ''Estimate'' button. Inference on these ',...
    'estimated parameters is then handled by the SPM results section. '];

p3=['A separate interface handles design configuration ',...
    'for fMRI time series.'];

p4=['Various data and parameters need to be supplied to specify the design ',...
    '(1) the image files, (2) indicators of the corresponding condition/subject/group ',...
    '(2) any covariates, nuisance variables, or design matrix partitions ',...
    '(3) the type of global normalisation (if any) ',...
    '(4) grand mean scaling options ',...
    '(5) thresholds and masks defining the image volume to analyse. ',...
    'The interface supports a comprehensive range of options for all these parameters.'];

conf.help={p1,sp_text,p2,sp_text,p3,sp_text,p4,sp_text};
conf.prog   = @run_stats;
conf.vfiles = @vfiles_stats;
return;
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function vf = vfiles_stats(job)
direc = job.dir{1};
vf    = {fullfile(direc,'SPM.mat')};

% Should really create a few vfiles for beta images etc here as well.
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function run_stats(job)

spm_defaults;

original_dir = pwd;
cd(job.dir{1});

%-Ask about overwriting files from previous analyses...
%-------------------------------------------------------------------
if exist(fullfile(job.dir{1},'SPM.mat'),'file')
    str = {	'Current directory contains existing SPM file:',...
        'Continuing will overwrite existing file!'};
    if spm_input(str,1,'bd','stop|continue',[1,0],1,mfilename);
        fprintf('%-40s: %30s\n\n',...
            'Abort...   (existing SPM file)',spm('time'));
        return
    end
end

% If we've gotten to this point we're committed to overwriting files.
% Delete them so we don't get stuck in spm_spm
%------------------------------------------------------------------------
files = {'^mask\..{3}$','^ResMS\..{3}$','^RPV\..{3}$',...
    '^beta_.{4}\..{3}$','^con_.{4}\..{3}$','^ResI_.{4}\..{3}$',...
    '^ess_.{4}\..{3}$', '^spm\w{1}_.{4}\..{3}$'};

for i=1:length(files)
    j = spm_select('List',pwd,files{i});
    for k=1:size(j,1)
        spm_unlink(deblank(j(k,:)));
    end
end


%-Option definitions
%-------------------------------------------------------------------
%-Generic factor names
sF = {'sF1','sF2','sF3','sF4'};

%-Covariate by factor interaction options
sCFI = {'<none>';...							%-1
    'with sF1';'with sF2';'with sF3';'with sF4';...			%-2:5
    'with sF2 (within sF4)';'with sF3 (within sF4)'};		%-6,7

%-DesMtx argument components for covariate by factor interaction options
% (Used for CFI's Covariate Centering (CC), GMscale & Global normalisation)
CFIforms = {	'[]',		'C',	'{}';...			%-1
    'I(:,1)',	    'FxC',	'{sF{1}}';...			%-2
    'I(:,2)',	    'FxC',	'{sF{2}}';...			%-3
    'I(:,3)',	    'FxC',	'{sF{3}}';...			%-4
    'I(:,4)',	    'FxC',	'{sF{4}}';...			%-5
    'I(:,[4,2])',	'FxC',	'{sF{4},sF{2}}';...	%-6
    'I(:,[4,3])',	'FxC',	'{sF{4},sF{3}}'	};	%-7

%-Centre (mean correction) options for covariates & globals            (CC)
% (options 9-12 are for centering of global when using AnCova GloNorm) (GC)
sCC = {		'around overall mean';...				%-1
    'around sF1 means';...					%-2
    'around sF2 means';...					%-3
    'around sF3 means';...					%-4
    'around sF4 means';...					%-5
    'around sF2 (within sF4) means';...			%-6
    'around sF3 (within sF4) means';...			%-7
    '<no centering>';...					%-8
    'around user specified value';...			%-9
    '(as implied by AnCova)';...				%-10
    'GM';...						%-11
    '(redundant: not doing AnCova)'}';			%-12
%-DesMtx I forms for covariate centering options
CCforms = {'ones(nScan,1)',CFIforms{2:end,1},''}';

%-Global calculation options                                       (GXcalc)
sGXcalc  = {	'omit';...						%-1
    'user specified';...					%-2
    'mean voxel value (within per image fullmean/8 mask)'};	%-3


%-Global normalization options  (GloNorm)
sGloNorm = {	'AnCova';...						%-1
    'AnCova by sF1';...					%-2
    'AnCova by sF2';...					%-3
    'AnCova by sF3';...					%-4
    'AnCova by sF4';...					%-5
    'AnCova by sF2 (within sF4)';...			%-6
    'AnCova by sF3 (within sF4)';...			%-7
    'proportional scaling';...				%-8
    '<no global normalisation>'};				%-9


%-Grand mean scaling options                                        (GMsca)
sGMsca = {	'scaling of overall grand mean';...			%-1
    'scaling of sF1 grand means';...			%-2
    'scaling of sF2 grand means';...			%-3
    'scaling of sF3 grand means';...			%-4
    'scaling of sF4 grand means';...			%-5
    'scaling of sF2 (within sF4) grand means';...		%-6
    'scaling of sF3 (within sF4) grand means';...		%-7
    '(implicit in PropSca global normalisation)';...	%-8
    '<no grand Mean scaling>'	};			%-9
%-NB: Grand mean scaling by subject is redundent for proportional scaling

% Conditions of no interest defaults
B=[];
Bnames={};

switch strvcat(fieldnames(job.des)),
    case 't1',
        % One sample t-test
        DesName='One sample t-test';

        P=job.des.t1.scans;
        n=length(P);
        I=[1:n]';
        I=[I,ones(n,3)];

        [H,Hnames]=spm_DesMtx(I(:,2),'-','mean');

        SPM.factor(1).name='Group';
        SPM.factor(1).levels=1;
        SPM.factor(1).variance=0;
        SPM.factor(1).dept=0;
    case 't2',
        % Two-sample t-test
        DesName='Two-sample t-test';

        P=job.des.t2.scans1;
        n1=length(job.des.t2.scans1);
        P=[P;job.des.t2.scans2];
        n2=length(job.des.t2.scans2);

        I=[];
        I=[1:n1]';
        I=[I;[1:n2]'];
        I=[I,[ones(n1,1);2*ones(n2,1)]];
        I=[I,ones(n1+n2,2)];

        [H,Hnames]=spm_DesMtx(I(:,2),'-','Group');

        % Names and levels
        SPM.factor(1).name='Group';
        SPM.factor(1).levels=2;

        % Ancova options
        SPM.factor(1).gmsca=job.des.t2.gmsca;
        SPM.factor(1).ancova=job.des.t2.ancova;

        % Nonsphericity options
        SPM.factor(1).variance=job.des.t2.variance;
        SPM.factor(1).dept=job.des.t2.dept;

    case 'pt',
        % Paired t-test
        DesName='Paired t-test';

        Npairs=length(job.des.pt.pair);
        P=[];
        for p=1:Npairs,
            P=[P;job.des.pt.pair(p).scans];
        end

        I=ones(Npairs*2,1);
        I(:,2)=kron([1:Npairs]',ones(2,1));
        I(:,3)=kron(ones(Npairs,1),[1 2]');
        I(:,4)=I(:,1);

        [H,Hnames]=spm_DesMtx(I(:,2),'-','Subject');
        [B,Bnames]=spm_DesMtx(I(:,3),'-','Condition');

        % Names and levels
        SPM.factor(1).name='Subject';
        SPM.factor(1).levels=Npairs;
        SPM.factor(2).name='Condition';
        SPM.factor(2).levels=2;

        % Ancova options
        SPM.factor(1).gmsca=0;
        SPM.factor(1).ancova=0;
        SPM.factor(2).gmsca=job.des.pt.gmsca;
        SPM.factor(2).ancova=job.des.pt.ancova;

        % Nonsphericity options
        SPM.factor(1).variance=0;
        SPM.factor(1).dept=0;
        SPM.factor(2).variance=job.des.pt.variance;
        SPM.factor(2).dept=job.des.pt.dept;

    case 'mreg',
        % Multiple regression
        DesName='Multiple regression';

        P=job.des.mreg.scans;
        n=length(P);
        I=[1:n]';
        I=[I,ones(n,3)];

        % Names and levels
        SPM.factor(1).name='';
        SPM.factor(1).levels=1;

        % Nonsphericity options
        SPM.factor(1).variance=0;
        SPM.factor(1).dept=0;

        H=[];Hnames=[];
        if job.des.mreg.incint==0
            B = []; Bnames = '';
        else
            [B,Bnames] = spm_DesMtx(I(:,2),'-','mean');
        end

        for i=1:length(job.des.mreg.mcov)
            job.cov(end+1).c   = job.des.mreg.mcov(i).c;
            job.cov(end).cname = job.des.mreg.mcov(i).cname;
            job.cov(end).iCC   = job.des.mreg.mcov(i).iCC;
            job.cov(end).iCFI  = 1;
        end

    case 'fd',
        % Full Factorial Design
        DesName='Full factorial';

        [I,P,H,Hnames] = spm_set_factorial_design (job);

        Nfactors=length(job.des.fd.fact);
        for i=1:Nfactors,
            % Names and levels
            SPM.factor(i).name=job.des.fd.fact(i).name;
            SPM.factor(i).levels=job.des.fd.fact(i).levels;

            % Ancova options
            SPM.factor(i).gmsca=job.des.fd.fact(i).gmsca;
            SPM.factor(i).ancova=job.des.fd.fact(i).ancova;

            % Nonsphericity options
            SPM.factor(i).variance=job.des.fd.fact(i).variance;
            SPM.factor(i).dept=job.des.fd.fact(i).dept;

        end

    case 'fblock',
        % Flexible factorial design
        DesName='Flexible factorial';

        if isfield(job.des.fblock.fsuball,'fsubject')
            nsub=length(job.des.fblock.fsuball.fsubject);
            % Specify design subject-by-subject
            P=[];I=[];
            subj=[];
            for s=1:nsub,
                P  = [P; job.des.fblock.fsuball.fsubject(s).scans];
                ns = length(job.des.fblock.fsuball.fsubject(s).scans);
                cc = job.des.fblock.fsuball.fsubject(s).conds;

                [ccr,ccc] = size(cc);
                if ~(ccr==ns) && ~(ccc==ns)
                    disp(sprintf('Error for subject %d: conditions not specified for each scan',s));
                    return
                elseif ~(ccr==ccc) && (ccc==ns)
                    warning('spm:transposingConditions',['Condition matrix ',...
                        'appears to be transposed. Transposing back to fix.\n',...
                        'Alert developers if it is not actually transposed.'])
                    cc=cc';
                end
                subj=[subj;s*ones(ns,1)];
                % get real replications within each subject cell
                [unused cci  ccj] = unique(cc,'rows');
                repl = zeros(ns, 1);
                for k=1:max(ccj)
                    repl(ccj==k) = 1:sum(ccj==k);
                end;
                I = [I; [repl cc]];
            end

            nf=length(job.des.fblock.fac);
            subject_factor=0;
            for i=1:nf,
                if strcmpi(job.des.fblock.fac(i).name,'repl')
                    % Copy `replications' column to create explicit `replications' factor
                    nI=I(:,1:i);
                    nI=[nI,I(:,1)];
                    nI=[nI,I(:,i+1:end)];
                    I=nI;
                end
                if strcmpi(job.des.fblock.fac(i).name,'subject')
                    % Create explicit `subject' factor
                    nI=I(:,1:i);
                    nI=[nI,subj];
                    nI=[nI,I(:,i+1:end)];
                    I=nI;
                    subject_factor=1;
                end

            end

            % Re-order scans conditions and covariates into standard format
            % This is to ensure compatibility with how variance components are created
            if subject_factor
                U=unique(I(:,2:nf+1),'rows');
                Un=length(U);
                Uc=zeros(Un,1);
                r=1;rj=[];
                for k=1:Un,
                    for j=1:size(I,1),
                        match=sum(I(j,2:nf+1)==U(k,:))==nf;
                        if match
                            Uc(k)=Uc(k)+1;
                            Ir(r,:)=[Uc(k),I(j,2:end)];
                            r=r+1;
                            rj=[rj;j];
                        end
                    end
                end
                P=P(rj); % -scans
                I=Ir;    % -conditions
                for k=1:numel(job.cov) % -covariates
                    job.cov(k).c = job.cov(k).c(rj);
                end;
            end

        else % specify all scans and factor matrix
            [ns,nc]=size(job.des.fblock.fsuball.specall.imatrix);
            if ~(nc==4)
                disp('Error: factor matrix must have four columns');
                return
            end
            I=job.des.fblock.fsuball.specall.imatrix;

            % Get number of factors
            nf=length(job.des.fblock.fac);
            %        nf=0;
            %        for i=1:4,
            %            if length(unique(I(:,i)))>1
            %                nf=nf+1;
            %            end
            %        end

            P=job.des.fblock.fsuball.specall.scans;
        end

        % Pad out factorial matrix to cover the four canonical factors
        [ns,nI]=size(I);
        if nI < 4
            I = [I, ones(ns,4-nI)];
        end

        % Sort main effects and interactions
        fmain = struct('fnum',{});
        inter = struct('fnums',{});
        for k=1:numel(job.des.fblock.maininters)
            if isfield(job.des.fblock.maininters{k},'fmain')
                fmain(end+1)=job.des.fblock.maininters{k}.fmain;
            elseif isfield(job.des.fblock.maininters{k},'inter')
                inter(end+1)=job.des.fblock.maininters{k}.inter;
            end;
        end;

        % Create main effects
        H=[];Hnames=[];
        nmain=length(fmain);
        for f=1:nmain,
            fcol=fmain(f).fnum;
            fname=job.des.fblock.fac(fcol).name;

            % Augment H partition - explicit factor numbers are 1 lower than in I matrix
            [Hf,Hfnames]=spm_DesMtx(I(:,fcol+1),'-',fname);
            H=[H,Hf];
            Hnames=[Hnames;Hfnames];
        end

        % Create interactions
        ni=length(inter);
        for i=1:ni,
            % Get the two factors for this interaction
            fnums=inter(i).fnums;
            f1=fnums(1);f2=fnums(2);

            % Names
            iname{1}=job.des.fblock.fac(f1).name;
            iname{2}=job.des.fblock.fac(f2).name;

            % Augment H partition - explicit factor numbers are 1 lower than in I matrix
            Isub=[I(:,f1+1),I(:,f2+1)];
            [Hf,Hfnames]=spm_DesMtx(Isub,'-',iname);
            H=[H,Hf];
            Hnames=[Hnames;Hfnames];

        end

        if nmain==0 && ni==0
            disp('Error in design specification: You have not specified any main effects or interactions');
            return
        end

        for i=1:nf,
            % Names and levels
            SPM.factor(i).name=job.des.fblock.fac(i).name;
            SPM.factor(i).levels=length(unique(I(:,i+1)));

            % Ancova options
            SPM.factor(i).gmsca=job.des.fblock.fac(i).gmsca;
            SPM.factor(i).ancova=job.des.fblock.fac(i).ancova;

            % Nonsphericity options
            SPM.factor(i).variance=job.des.fblock.fac(i).variance;
            SPM.factor(i).dept=job.des.fblock.fac(i).dept;

        end


end
nScan=size(I,1); %-#obs

% Set up data structures for non-sphericity routine
SPM.xVi.I=I;
SPM = spm_get_vc(SPM);

%-Covariate partition(s): interest (C) & nuisance (G) excluding global
%===================================================================
dstr   = {'covariate','nuisance variable'};
C  = []; Cnames = [];  %-Covariate DesMtx partitions & names
G  = []; Gnames = [];

xC = [];			             %-Struct array to hold raw covariates

% Covariate options:
nc=length(job.cov); % number of covariates
for i=1:nc,

    c      = job.cov(i).c;
    cname  = job.cov(i).cname;
    rc     = c;                         %-Save covariate value
    rcname = cname;                     %-Save covariate name
    if job.cov(i).iCFI==1,
        iCFI=1;
    else
        % SPMs internal factor numbers are 1 higher than specified in user
        % interface as, internally, the first factor is always `replication'
        iCFI=job.cov(i).iCFI+1;
    end
    switch job.cov(i).iCC,
        case 1
            iCC=1;
        case {2,3,4}
            iCC=job.cov(i).iCC+1;
        otherwise
            iCC=job.cov(i).iCC+3;
    end

    %-Centre within factor levels as appropriate
    if any(iCC == [1:7]),
        c = c - spm_meanby(c,eval(CCforms{iCC}));
    end

    %-Do any interaction (only for single covariate vectors)
    %-----------------------------------------------------------
    if iCFI > 1				%-(NB:iCFI=1 if size(c,2)>1)
        tI        = [eval(CFIforms{iCFI,1}),c];
        tConst    = CFIforms{iCFI,2};
        tFnames   = [eval(CFIforms{iCFI,3}),{cname}];
        [c,cname] = spm_DesMtx(tI,tConst,tFnames);
    elseif size(c,2)>1			%-Design matrix block
        [null,cname] = spm_DesMtx(c,'X',cname);
    else
        cname = {cname};
    end

    %-Store raw covariate details in xC struct for reference
    %-Pack c into appropriate DesMtx partition
    %-----------------------------------------------------------
    %-Construct description string for covariate
    str = {sprintf('%s',rcname)};
    if size(rc,2)>1, str = {sprintf('%s (block of %d covariates)',...
            str{:},size(rc,2))}; end
    if iCC < 8, str=[str;{['used centered ',sCC{iCC}]}]; end
    if iCFI> 1, str=[str;{['fitted as interaction ',sCFI{iCFI}]}]; end

    typ = 1;
    tmp       = struct(	'rc',rc,	'rcname',rcname,...
        'c',c,		'cname',{cname},...
        'iCC',iCC,	'iCFI',iCFI,...
        'type',typ,...
        'cols',[1:size(c,2)] + ...
        size([H,C],2) +  ...
        size([B,G],2)*min(typ-1,1),...
        'descrip',{str}				);
    if isempty(xC), xC = tmp; else, xC = [xC,tmp]; end
    C     = [C,c];
    Cnames = [Cnames; cname];

end
clear c tI tConst tFnames

xGX=[];
xM=[];



%===================================================================
% - C O N F I G U R E   D E S I G N -
%===================================================================

%-Images & image info: Map Y image files and check consistency of
% dimensions and orientation / voxel size
%===================================================================
fprintf('%-40s: ','Mapping files')                               %-#
VY    = spm_vol(char(P));

%-Check compatability of images (Bombs for single image)
%-------------------------------------------------------------------
spm_check_orientations(VY);

fprintf('%30s\n','...done')                                      %-#

%-Global values, scaling and global normalisation
%===================================================================
%-Compute global values
%-------------------------------------------------------------------
switch strvcat(fieldnames(job.globalc))
    case 'g_omit',
        iGXcalc=1;
    case 'g_user',
        iGXcalc=2;
    case 'g_mean',
        iGXcalc=3;
end

switch job.globalm.glonorm
    case 1,
        iGloNorm=9;
    case 2,
        iGloNorm=8;
    case 3,
        iGloNorm=1;
end
if SPM.factor(1).levels > 1
    % Over-ride if factor-specific ANCOVA has been specified
    for i=1:length(SPM.factor),
        if SPM.factor(i).ancova
            iGloNorm=i+2;
        end
    end
end

%-Analysis threshold mask
%-------------------------------------------------------------------
%-Work out available options:
% -Inf=>None, real=>absolute, complex=>proportional, (i.e. times global)
M_T = -Inf;
switch strvcat(fieldnames(job.masking.tm)),
    case 'tma',
        % Absolute
        M_T = job.masking.tm.tma.athresh;
    case 'tmr',
        % Relative
        M_T = job.masking.tm.tmr.rthresh*sqrt(-1);
        % Need to force calculation of globals
        if iGXcalc~=2, iGXcalc=3; end
    case 'tm_none'
        % None
        M_T = -Inf;
end

if (any(iGloNorm == [1:5]) || iGloNorm==8) && iGXcalc==1
    % Over-ride omission of global calculation if we need it
    disp(' ');
    disp(sprintf('For %s, SPM needs estimates of global activity.',sGloNorm{iGloNorm}));
    disp('But you have specified to omit this computation.');
    disp('SPM has overridden this omission and will automatically compute ');
    disp('globals as the mean value of within brain voxels');
    disp(' ');
    iGXcalc=3;
end
sGXcalc = sGXcalc{iGXcalc};

switch iGXcalc,
    case 1
        %-Don't compute => no GMsca (iGMsca==9) or GloNorm (iGloNorm==9)
        g = [];
    case 2
        %-User specified globals
        g = job.globalc.g_user.global_uval;
    case 3
        %-Compute as mean voxel value (within per image fullmean/8 mask)
        g = zeros(nScan,1 );
        fprintf('%-40s: %30s','Calculating globals',' ')             %-#
        for i = 1:nScan
            str = sprintf('%3d/%-3d',i,nScan);
            fprintf('%s%30s',repmat(sprintf('\b'),1,30),str)%-#
            g(i) = spm_global(VY(i));
        end
        fprintf('%s%30s\n',repmat(sprintf('\b'),1,30),'...done')       %-#
    otherwise
        error('illegal iGXcalc')
end
rg = g;

fprintf('%-40s: ','Design configuration')                        %-#

%-Grand mean scaling options                                 (GMsca)
%-------------------------------------------------------------------
if iGloNorm==8
    iGMsca=8;	%-grand mean scaling implicit in PropSca GloNorm
else
    switch strvcat(fieldnames(job.globalm.gmsca))
        case 'gmsca_yes',
            iGMsca=1;
        case 'gmsca_no',
            iGMsca=9;
    end
    if SPM.factor(1).levels > 1
        % Over-ride if factor-specific scaling has been specified
        for i=1:length(SPM.factor),
            if SPM.factor(i).gmsca
                iGMsca=i+2;
            end
        end
    end
end

%-Value for PropSca / GMsca                                     (GM)
%-------------------------------------------------------------------
switch iGMsca,
    case 9                      %-Not scaling (GMsca or PropSca)
        GM = 0;                         %-Set GM to zero when not scaling
    case 1                                %-Ask user value of GM
        GM = job.globalm.gmsca.gmsca_yes.gmscv;
    otherwise
        if iGloNorm==8
            switch strvcat(fieldnames(job.globalm.gmsca))
                case 'gmsca_yes',
                    % Proportionally scale to this value
                    GM = job.globalm.gmsca.gmsca_yes.gmscv;
                case 'gmsca_no',
                    GM = 50;
            end
        else
            % Grand mean scaling by factor eg. scans are scaled so that the
            % mean global value over each level of the factor is set to GM
            GM=50;
        end
end

%-If GM is zero then don't GMsca! or PropSca GloNorm
if GM==0,
    iGMsca=9;
    if iGloNorm==8,
        iGloNorm=9;
    end
end

%-Sort out description strings for GloNorm and GMsca
%-------------------------------------------------------------------
sGloNorm = sGloNorm{iGloNorm};
sGMsca   = sGMsca{iGMsca};
if iGloNorm==8
    sGloNorm = sprintf('%s to %-4g',sGloNorm,GM);
elseif iGMsca<8
    sGMsca   = sprintf('%s to %-4g',sGMsca,GM);
end

%-Scaling: compute global scaling factors gSF required to implement
% proportional scaling global normalisation (PropSca) or grand mean
% scaling (GMsca), as specified by iGMsca (& iGloNorm)
%-------------------------------------------------------------------
switch iGMsca,
    case 8
        %-Proportional scaling global normalisation
        if iGloNorm~=8, error('iGloNorm-iGMsca(8) mismatch for PropSca'), end
        gSF    = GM./g;
        g      = GM*ones(nScan,1);
    case {1,2,3,4,5,6,7}
        %-Grand mean scaling according to iGMsca
        gSF    = GM./spm_meanby(g,eval(CCforms{iGMsca}));
        g      = g.*gSF;
    case 9
        %-No grand mean scaling
        gSF    = ones(nScan,1);
    otherwise
        error('illegal iGMsca')
end


%-Apply gSF to memory-mapped scalefactors to implement scaling
%-------------------------------------------------------------------
for i = 1:nScan
    VY(i).pinfo(1:2,:) = VY(i).pinfo(1:2,:)*gSF(i);
end

%-Global centering (for AnCova GloNorm)                         (GC)
%-If not doing AnCova then GC is irrelevant
if ~any(iGloNorm == [1:7])
    iGC = 12;
    gc  = [];
else
    iGC = 10;
    gc = 0;
end

%-AnCova: Construct global nuisance covariates partition (if AnCova)
%-------------------------------------------------------------------
if any(iGloNorm == [1:7])

    %-Centre global covariate as requested
    %---------------------------------------------------------------
    switch iGC, case {1,2,3,4,5,6,7}	%-Standard sCC options
        gc = spm_meanby(g,eval(CCforms{iGC}));
        case 8					%-No centering
            gc = 0;
        case 9					%-User specified centre
            %-gc set above
        case 10					%-As implied by AnCova option
            gc = spm_meanby(g,eval(CCforms{iGloNorm}));
        case 11					%-Around GM
            gc = GM;
        otherwise				%-unknown iGC
            error('unexpected iGC value')
    end

    %-AnCova - add scaled centred global to DesMtx `G' partition
    %---------------------------------------------------------------
    rcname     = 'global';
    tI         = [eval(CFIforms{iGloNorm,1}),g - gc];
    tConst     = CFIforms{iGloNorm,2};
    tFnames    = [eval(CFIforms{iGloNorm,3}),{rcname}];
    [f,gnames]  = spm_DesMtx(tI,tConst,tFnames);
    clear tI tConst tFnames

    %-Save GX info in xC struct for reference
    %---------------------------------------------------------------
    str     = {sprintf('%s: %s',dstr{2},rcname)};
    if any(iGMsca==[1:7]), str=[str;{['(after ',sGMsca,')']}]; end
    if iGC ~= 8, str=[str;{['used centered ',sCC{iGC}]}]; end
    if iGloNorm > 1
        str=[str;{['fitted as interaction ',sCFI{iGloNorm}]}];
    end
    tmp  = struct(	'rc',rg.*gSF,		'rcname',rcname,...
        'c',f,			'cname'	,{gnames},...
        'iCC',iGC,		'iCFI'	,iGloNorm,...
        'type',			3,...
        'cols',[1:size(f,2)] + size([H C B G],2),...
        'descrip',		{str}		);

    G = [G,f]; Gnames = [Gnames; gnames];
    if isempty(xC), xC = tmp; else, xC = [xC,tmp]; end


elseif iGloNorm==8 || iGXcalc>1

    %-Globals calculated, but not AnCova: Make a note of globals
    %---------------------------------------------------------------
    if iGloNorm==8
        str = { 'global values: (used for proportional scaling)';...
            '("raw" unscaled globals shown)'};
    elseif isfinite(M_T) && ~isreal(M_T)
        str = { 'global values: (used to compute analysis threshold)'};
    else
        str = { 'global values: (computed but not used)'};
    end

    rcname ='global';
    tmp     = struct(	'rc',rg,	'rcname',rcname,...
        'c',{[]},	'cname'	,{{}},...
        'iCC',0,	'iCFI'	,0,...
        'type',		3,...
        'cols',		{[]},...
        'descrip',	{str}			);

    if isempty(xC), xC = tmp; else, xC = [xC,tmp]; end
end


%-Save info on global calculation in xGX structure
%-------------------------------------------------------------------
xGX = struct(...
    'iGXcalc',iGXcalc,	'sGXcalc',sGXcalc,	'rg',rg,...
    'iGMsca',iGMsca,	'sGMsca',sGMsca,	'GM',GM,'gSF',gSF,...
    'iGC',	iGC,		'sGC',	sCC{iGC},	'gc',	gc,...
    'iGloNorm',iGloNorm,	'sGloNorm',sGloNorm);

%-Make a description string
%-------------------------------------------------------------------
if isinf(M_T)
    xsM.Analysis_threshold = 'None (-Inf)';
elseif isreal(M_T)
    xsM.Analysis_threshold = sprintf('images thresholded at %6g',M_T);
else
    xsM.Analysis_threshold = sprintf(['images thresholded at %6g ',...
        'times global'],imag(M_T));
end

%-Construct masking information structure and compute actual analysis
% threshold using scaled globals (rg.*gSF)
%-------------------------------------------------------------------
if isreal(M_T),
    M_TH = M_T  * ones(nScan,1);	%-NB: -Inf is real
else
    M_TH = imag(M_T) * (rg.*gSF);
end

%-Implicit masking: Ignore zero voxels in low data-types?
%-------------------------------------------------------------------
% (Implicit mask is NaN in higher data-types.)
type = getfield(spm_vol(P{1,1}),'dt')*[1,0]';
if ~spm_type(type,'nanrep')
    M_I = job.masking.im;  % Implicit mask ?
    if M_I,
        xsM.Implicit_masking = 'Yes: zero''s treated as missing';
    else,
        xsM.Implicit_masking = 'No';
    end
else
    M_I = 1;
    xsM.Implicit_masking = 'Yes: NaN''s treated as missing';
end

%-Explicit masking
%-------------------------------------------------------------------
if isempty(job.masking.em{:})
    VM = [];
    xsM.Explicit_masking = 'No';
else
    VM = spm_vol(char(job.masking.em));
    xsM.Explicit_masking = 'Yes';
end

xM     = struct('T',M_T, 'TH',M_TH, 'I',M_I, 'VM',{VM}, 'xs',xsM);

%-Construct full design matrix (X), parameter names and structure (xX)
%===================================================================
X      = [H C B G];
tmp    = cumsum([size(H,2), size(C,2), size(B,2), size(G,2)]);
xX     = struct(	'X',		X,...
    'iH',		[1:size(H,2)],...
    'iC',		[1:size(C,2)] + tmp(1),...
    'iB',		[1:size(B,2)] + tmp(2),...
    'iG',		[1:size(G,2)] + tmp(3),...
    'name',		{[Hnames; Cnames; Bnames; Gnames]},...
    'I',		I,...
    'sF',		{sF});


%-Design description (an nx2 cellstr) - for saving and display
%===================================================================
tmp = {	sprintf('%d condition, +%d covariate, +%d block, +%d nuisance',...
    size(H,2),size(C,2),size(B,2),size(G,2));...
    sprintf('%d total, having %d degrees of freedom',...
    size(X,2),rank(X));...
    sprintf('leaving %d degrees of freedom from %d images',...
    size(X,1)-rank(X),size(X,1))				};
xsDes = struct(	'Design',			{DesName},...
    'Global_calculation',		{sGXcalc},...
    'Grand_mean_scaling',		{sGMsca},...
    'Global_normalisation',		{sGloNorm},...
    'Parameters',			{tmp}			);


fprintf('%30s\n','...done')                                      %-#

%-Assemble SPM structure
%===================================================================
SPM.xY.P	= P;			% filenames
SPM.xY.VY	= VY;			% mapped data
SPM.nscan	= size(xX.X,1); % scan number
SPM.xX		= xX;			% design structure
SPM.xC		= xC;			% covariate structure
SPM.xGX		= xGX;			% global structure
SPM.xM		= xM;			% mask structure
SPM.xsDes	= xsDes;		% description

% Automatic contrast generation only works for 'Full factorials'
if ~strcmp(DesName,'Full factorial')
    % Remove the .factor field to prevent attempted automatic contrast generation
    SPM=rmfield(SPM,'factor');
end

%-Save SPM.mat and set output argument
%-------------------------------------------------------------------
fprintf('%-40s: ','Saving SPM configuration')                    %-#

if spm_matlab_version_chk('7') >= 0
    save('SPM', 'SPM', '-V6');
else
    save('SPM', 'SPM');
end;
fprintf('%30s\n','...SPM.mat saved')                             %-#
varargout = {SPM};

%-Display Design report
%===================================================================
fprintf('%-40s: ','Design reporting')                            %-#
fname     = cat(1,{SPM.xY.VY.fname}');
spm_DesRep('DesMtx',SPM.xX,fname,SPM.xsDes)
fprintf('%30s\n','...done')

cd(original_dir); % Change back dir
fprintf('Done\n')
