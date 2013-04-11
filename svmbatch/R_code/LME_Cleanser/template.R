
############################################
## Where is your master datafile located? ##
############################################

masterpath = '/net/data4/ADHD/Scripts/slab/MasterData_ADHD_rePreprocess_Cleansed.csv'

###########################################################################
## Does your master datafile contain a "factor" column with 1's and 0's  ##
## indicating which subjects to include in the present analysis? If so,  ##
## give the name of that column as a string here. If not, pass an emptry ##
## string as includefactor = ''                                          ##
###########################################################################

includefactor = 'Include.Overall.Censor'

###########################################################################
## I will assume that all of the columns of your masterdatafile are      ##
## factors unless you tell me otherwise. I accomplish this by coercing   ##
## your whole masterdatafile to be characters, and then my modeling      ##
## routines will treat anything that is a character as a factor. This is ##
## certainly appropriate for variables like Subject ID, Diagnosis,       ##
## etc. However, some of your variables probably she be treated          ##
## numerically. These are variables like age, scale measures,            ##
## etc. Indicate the names (as they appear in your masterdatafile) of    ##
## these numeric measures here, and I will make sure they get treated as ##
## numeric covariates. If there are no such columns, put in a single     ##
## empty string                                                          ##
###########################################################################

numeric.columns = c('meanFD','meanFDquad','IQMeasure','AGE')

#####################################################################################
## Unfortunately, all the friendliness of mc_GenPath has not yet been              ##
## ported to R, so your capacity to flexibly specify path names is bit             ##
## more limited. Here, you'll specify the path to your connectome                  ##
## files. These files should be square matrices that will be flattened             ##
## internally by the R script. Your path will be built up by concatening           ##
## the following                                                                   ##
## 1) connTemplate.prefix                                                          ##
## 2) the current value of Subject. You'll need to specify which column            ##
## of your masterdata file has your subject folder names in connTemplate.SubjField ##
## 3) connTemplate.suffix                                                          ##
##                                                                                 ##
## NOTE - Depending on you application, it may be ok to set either                 ##
## connTemplate.prefix or connTemplate.suffix to an empty string                   ##
## (e.g. '')                                                                       ##
#####################################################################################

connTemplate.prefix = '/net/data4/ADHD/FirstLevel/SiteCatLinks/'

connTemplate.SubjField = 'Subject'

connTemplate.suffix = '/347rois_Censor/347rois_Censor_corr.mat'

#######################################################################################
## If you're modeling data that came from SOM, it's most likely encoded              ##
## as Pearson R's.  It'd be better if it were z-transformed using                    ##
## Fisher's Z. If that's the case, set the following option to 1.                    ##
## However, if you have cPPI data or some other sort of data that                    ##
## doesn't need to be transformed, set it to 0 and it will model the features as is. ##
#######################################################################################

FisherZ = 1


############################################################################
## Where should the results be written? This should be a fully qualified  ##
## path to a directory where all of your results will go. I will make the ##
## directory for you if it doesn't exist                                  ##
############################################################################

outputPath = '/net/data4/ADHD/UnivariateConnectomics/Results/Cleansing_MLE_347_Censor_Z'


################################################################################
## Model Options                                                              ##
##                                                                            ##
## First off, do you want to fit a standard linear model or will you be       ##
## using a fancier multilevel modeling approach? Set model.approach to        ##
## the appropriate value                                                      ##
## 'lm'    -       standard linear modeling, done with call to lm             ##
## 'lme'   -       Multilevel modeling done with call to lmer                 ##
##                                                                            ##
##                                                                            ##
## For lm mode, you'll need to create a formula object in the way that R      ##
## likes it. This means it will look something like this: "R ~ dx +           ##
## motion". The left hand term will always be R, this is hardcoded into       ##
## the central script to be the Pearson R correlation for the current         ##
## feature of interest. All of the terms on the right hand side need to       ##
## be the same as column names in your master datafile.                       ##
##                                                                            ##
## For lme mode it's a bit more complicated. Better to look at the help       ##
## for lme and fill in the fixed and random components based on the           ##
## documentation there. In most cases, random will just be ~1|grouping factor ##
##                                                                            ##
## IMPORTANT NOTE - If you're only interested in the intercept term (e.g. you ##
## are using the GLM to do a one sample or paired t-test of some form) you    ##
## need to be really careful. The interpretation of the intercept when        ##
## covariates and factors are present is really tricky.                       ##
################################################################################


model.approach = 'lme'

# Options for lm
model.formula = R ~ TYPE + meanFD + F4IQ + AGE + GENDER

# Options for lme (we will only save results for the first fixed term!)
model.fixed = R ~ TYPE + meanFD + meanFDquad + IQMeasure + AGE + GENDER 
model.random = ~1|SITE_ID


###################################################################################################################
## Should we use multiple processing cores wherever possible?  If so, set                                        ##
## multicore.cores to something other than 1. If you don't want to use multiple cores, set multicore.cores to 1. ##
###################################################################################################################

multicore.cores = 1


############################################
## Where is your methods core repository? ##
############################################

mcPath = '~/users/kesslerd/repos/MethodsCore'


#############################
## Do not edit below here  ##
#############################

rpath = file.path(mcPath,'svmbatch','R_code','LME_Cleanser')
setwd(rpath)

source('central.R')
