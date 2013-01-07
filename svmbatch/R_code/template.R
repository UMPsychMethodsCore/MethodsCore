
############################################
## Where is your master datafile located? ##
############################################

masterpath = '/net/data4/Schiz_COBRE/MasterData_COBRE.csv' 

###########################################################################
## Does your master datafile contain a "factor" column with 1's and 0's  ##
## indicating which subjects to include in the present analysis? If so,  ##
## give the name of that column as a string here. If not, pass an emptry ##
## string as includefactor = ''                                          ##
###########################################################################

includefactor = 'Include'

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

numeric.columns = c('AGE','VIQ','PIQ','F2IQ','F4IQ','meanSPACE','meanFD','TOTAL_RUNS','TOTAL_TP')

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

connTemplate.prefix = '/net/data4/Schiz_COBRE/Subjects/FirstLevel_12s19vr_adjusted/'

connTemplate.SubjField = 'SUB_ID'

connTemplate.suffix = '/Grid/Grid_corr.mat'



############################################################################
## Where should the results be written? This should be a fully qualified  ##
## path. It will write out a single .mat file that will contain a         ##
## variable holding a matrix of your t-values. Rows index the betas in    ##
## the fit model, and columns correspond to features. It is important the ##
## the folder containing your target file already exists or this will     ##
## result in an error.                                                    ##
############################################################################

outputTemplate = '/net/data4/Schiz_COBRE/UnivariateConnectomics/Results/Grid1080WMotion.mat'


##########################################################################
## How do you want to model your data? You'll need to create a formula  ##
## object in the way that R likes it. This means it will look something ##
## like this: "R ~ dx + motion". The left hand term will always be R,   ##
## this is hardcoded into the central script to be the Pearson R        ##
## correlation for the current feature of interest. All of the terms    ##
## on the right hand side need to be the same as column names in your   ##
## master datafile.                                                     ##
##########################################################################
model.formula = R ~ TYPE + meanFD


#############################
## Call the Central Script ##
#############################

source('central.R')
