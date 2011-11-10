*PAN_MasterData Processor

Written 2011 by Daniel Kessler, kesslerd@umich.edu
for the Psychiatric Affective Neuroscience Laboratory

*Prerequisites
This code was written to use R 2.13.0, available (for free!) at cran.r-project.org

At present it does not require any packages beyond the R base

The R scripts in this suite should not require any modification by you. Instead, you customize it by editing Options.csv file that comes with it and by placing your data and any support files in the same working directory.

*The Options File

The options file is a csv which describes features at various levels. Below is a full list of documentation of currently implemented features for all levels.

The order in which the options appear in the file do not matter. Some options can be entered multiple times, and these will be indicated in the descriptions below.

You can quickly toggle whether an option is on or off by setting a 1 (on) in the third column, or a 0 (off).



**Level: Master
***Filename
This specifies the filename of your input file from ePrime. This can be a full path, or a relative path starting from the "input" directory.
***SupplementFile
If there is additional information you would like to operate on that is not contained in your ePrime file (e.g. treatment conditions from a double-blind study not known during the session, and thus undocumented in the ePrime file), you can supply another csv file. This file will simply be merged with your ePrime file, so it needs to contain some common columns to your ePrime file, and some new columns. In the example discussed above, say you have 
***RunField
***TrialField
***RunMap
***Filetype
***SkipRows
***TaskType
***TimeField
***TimeOffset
***RunMaxFile
***SubjectCatFields
***SubjectField
***RunMaxDefault
***TrialByTrial
***TR
***FIRposttrial
***FIRpretrial
***Masterdatafilename
***TrialTypeField
***TrialTypeMap
***ParametricTrialDecaySlope


**Level: MSIT
***StimRespField
***JitterRespField
***CorrectResponseField
***StimRTfield
***JitterRTfield
***StimDurFIeld
