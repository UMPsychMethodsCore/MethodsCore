*OMNI_MasterData Processor

Written in 2011 by Daniel Kessler, kesslerd@umich.edu, Department of Psychiatry, University of Michigan.

*Prerequisites
This code was written to use R 2.13.0, available (for free!) at cran.r-project.org

At present it does not require any packages beyond the R base.

The R scripts in this suite should not require any modification by you. Instead, you customize it by editing the Options.csv file that comes with it as described below and placing your data and any support files in the appropriate directories.

*Building your ePrime File
Generally the easiest way is to gather all of your edat files. Next, run e-Merge, and use it to merge all of your edat files into one emrg file. Then, open the emrg file with eDataAid, and export it. You can use most of settings, but make sure you pay attention to what it says your delimter is, as you will need to specify this in the Options file (discussed below).

*Folder Structure
This program consists of several folders, each discussed below.

**Input
This is where you will put your ePrime file, as well as any other files required by the program (e.g. supplemental file, RunMaxes, etc) being sure that you have set some option so the program knows to look for them )and what they are called).

**Config
This is where your Options should live. It needs to be named "Options.csv" as this is hardcoded into the script for now. No other config files are currently supported, but this may change in future releases of the project.

**rsrc
This is where the source code of the project lives. For now it's all just a bunch of .r files (these are scripts for R). You should not need to edit any of these, but if you're curious, feel free to have a look. If you make a change that you think should be adopted in the main line of development, please contain the project maintained (kesslerd@umich.edu) ideally with a patch of your changes, but if not we can work something out to integrate your work into the trunk.

**logs
When you run your program, it will generate a log file that will look as if you had run the entire session interactively. If you don't know R very well, these logs may not look like much to you, but if you encounter a problem and want to contain the project's maintainer, including these logs will go a long way towards helping she or he to track down your problem.

*Running the Program
Once you've got everything placed in the correct directory and your Options file written up (see below), it's time to run the program. Simply execute the shell script named omnimasterdata.sh that lives at the top level of the repository, and it will do the rest for you.

*The Options File

The options file is a csv which describes features at various levels. Below is a full list of documentation of currently implemented features for all levels.

The order in which the options appear in the file do not matter. Some options can be entered multiple times; the usage of these options will be further described below.

You can quickly toggle whether an option is on or off by setting a 1 (on) in the third column, or a 0 (off).



**Level: Master
***Filename
REQUIRED | This specifies the filename of your input file from ePrime. This can be a full path, or a relative path starting from the "input" directory.
***SubjectField
REQUIRED | This identifies the column in your ePrime file that contains your subject identifiers.
***TrialField
REQUIRED | Indicate the name of the column in your ePrime file that counts trials. It may count them sequentially, resetting for each run, or it may count continuously across runs. This is used for sorting and adjustment of timing parameters.
***Filetype
REQUIRED | Here you specify the delimiter style of your ePrime file. It can be set to either "csv" for a comma-delimeted file or "tab" for a tab-delimeted file. In our experience, the default delimiter from edat export is tab.
***SkipRows
REQUIRED | Sometimes the exported edat file will have some unnecessary header information (e.g. "This file contains modified info"). It's best to skip that. On the other hand, column headers (e.g. "Subject","Run",etc) should NOT be skipped.
***TaskType
REQUIRED | Specify which type of task your ePrime file represents. Currently supported options are MSIT, but more will be added soon.
***TimeField
REQUIRED | Indicate the name of the column in your ePrime file that holds the onsets (in msec) of your trials. 
***SupplementFile
If there is additional information you would like to operate on that is not contained in your ePrime file (e.g. treatment conditions from a double-blind study not known during the session, and thus undocumented in the ePrime file), you can supply another csv file. This file will simply be merged with your ePrime file, so it needs to contain some common columns to your ePrime file, and some new columns. In the example discussed above, you might have a "Subject" and a "Session" column in your ePrime file. You'd like to add a "Tx" column. Build a supplement file that has columns named "Subject","Session", and "Tx" and specify it here. The program will merge your supplemental file with the ePrime file, thus adding the new columns based on the mappings you have specified.
***RunField
Many fMRI studies will repeat a task in multiple runs. The program needs to know about this runs for timing purposes (each run has its timing properties calculated independently). If you already have a column in your ePrime file that identifies your Runs, name it here.
***RunMap
This is an option you may need to specify multiple times. If you do NOT have a RunField, this option will enable you to map sequences of trials to runs. For example, you do not have a RunField, but you know your study consists of two runs. Trials 1 through 100 belong to Run1, and trials 101 through 200 belong to Run2. To specify this kind of mapping, set the option to (without quotes) "1_1:100". You would then start another row in the Options file, and set the RunMap option to "2_101:200". Repeat and add as many rows as necessary for the number of runs that you have.
***TimeOffset
By default, the program will adjust all of the onsets so that trial #1 of each run is 0, and all other trials are zeroed out relative to that start point (e.g. a sequence of 5, 7, 10 would become 0, 2, 5). If there should be some offset so that the starting point is not 0, enter it here (in seconds).
***RunMaxDefault
This is an option you may need to specify multple times, once for each run. This program will purge any trials that occur outside of the scanning window. Specify the length of each run's scanning time (in seconds), as follows. If run 1 has a max time of 440 seconds, set the option to "1_440". Repeat for each run.
***RunMaxFile
This program will purge any trials that occur outside of the scanning window. If you have any irregular pattern of scan times (e.g. subject 1 run 1 had a max of 300 seconds, subject 2 run 1 had a max of 480 seconds, etc), you can create a csv file. A template is already in the "Input" directory. This file needs to contain enough columns to uniquely identify runs, and then a colum named "MaxTime" which specifies, in seconds, the max time for the run. Note: If you specify both a RunMaxFile and RunMaxDefault above, the program will opt to first use the values defined in RunMaxFile, but will fall back to RunMaxDefault wherever they are not defined. In this way, if you have a study that is mostly regular, but has a few abberant subjects, you can use RunMaxDefault to set the typical behavior, and specify exception cases using RunMaxFile
***SubjectCatFields
For studies with some degree of nesting, it may be necessary for your "Subject" field to actually be the result of concatenating several fields (e.g. "Subject + Tx" where Subject is 5001 and Tx is A will give 5001A as a Subject id). This is helpful for interfacing with existing PANLAB firstlevel scripts.
***TrialByTrial
Set to 1 if you want a condition column added for trial by trial betas. This will skip over any trials that are marked as undefined due to being outside of the RunMaxes or where the TrialType is undefined. Set it to 2 if you are processing an MSIT file and want the trial-by-trial betas to only count accurate trials. Set to 0 to not do TrialByTrial condition column at all
***TR
What is your TR? This may be used for some conversions?
***FIRposttrial
How many TR's after stimulus onset do you want FIR's to encompass?
***FIRpretrial
How many TR's before stimulus onset do you want your FIR's to go?
***Masterdatafilename
REQUIRED | What name should the program use for the masterdatafile that it constructs?
***TrialTypeField
The name of the field that has your trial type information
***TrialTypeMap
This variable may need to be defined multiple times. If your TrialTypeField contains strings, you will need a numeric mapping. Delimit your pairs with underscores, so if trialtype "fix" should be 1, specifcy "fix_1". Define this option again for each level of your TrialType
***ParametricTrialDecaySlope
If on, will introduce parameter with positive or negative slope depending on sign of value you provide. 0 will not work.


**Level: MSIT
These options only need to be included if your task type is MSIT. Most MSIT task setups that we have seen have both a "stimulus" or "trial" object which occurs when the stim is actually being shown. There will then either be a "rest" or "jitterfix" or some similar object which is the mask. Most subjects are not fast enough to respond during the actual stim, though occasionally it does happen. The program will evaluate the responses and RTs for both of these objects, and use whichever one came first. If the RT comes from the second object, the calculated RT will be the duration of the stim + the RT during the fixation.
***StimRespField
Define which field shows the response (buttonpress) that occurred during actual stimulus presentation.
***JitterRespField
Define which field shows the response (buttonpress) that occurred during fixation/rest/whatever happened right after stimulus presentation.
***CorrectResponseField
Which field contains the correct response? Be sure to carefully visually inspect it. Many MSIT programs that I've seen define a "CRESP" or correct response for both the stim and the jitterfix objects, but often CRESP is not fully filled in for one or the other. The program will use only the column you specify to calculate accuracy.
***StimRTfield
Which field contains the RT if a response occurred during stim presentation?
***JitterRTfield
Which field contains the RT if a response occurred during jitter/fixation/rest?
***StimDurFIeld
Which field contains the duration of the stim event?
