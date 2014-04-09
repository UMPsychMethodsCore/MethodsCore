# # # # # # # # # # # # # # # # # #
#
# This is a modified version of the spm8Batch processing system written by Robert C. Welsh, Ann Arbor MI
#
# Copyright 2002-2012
#
# No warranties or guarantees are made. 
#
# Though every effort is made to make this error free, that in itself is an impossiblility and thus this is a:
#
#         "Use at your own risk software package."
#
# -------------
#
# This code was developed on a MacBook Pro using the BASH language. It relies upon spm8 and FSL
#
# If need be you may get these from:
#
#     spm : http://www.fil.ion.ucl.ac.uk/spm/
#
#     fsl : http://www.fmrib.ox.ac.uk/fsl/ 
#
#
#
#
#
# -----------------------------------------------------------------
# -----------------------------------------------------------------
#
# INSTALLATION INSTRUCTIONS:
#
#
# You will need to adjust your PATH environmental variable to include
# the spm8Batch distribution
#
# You can do this on the fly by running "source spm8Setup" while in this directory.
# You can also edit your .bashrc, .bash_profile, or /etc/bashrc startup scripts to source this automatically
# for all or just some users.
#
# 
# Remember the native language of the spm8Batch system is bash. An
# excellent site for BASH help is:
# 
#     http://tldp.org/LDP/abs/html/
#
# You will need to have spm8 distribution (Included in this distribution)
# 
# You will need to have fsl, at least 4.1.7, it's known to work with 4.1.7 and 4.1.8
#
# FILE FORMATS
# 
# The code can only use NIFTI images (.nii), and not NIFTI_GZ.
#
# If you are still using analyze img/hdr it's time to enter the 21st century!
#
# HELP
# 
# Look at SPM8BATCH.pdf for a keynote description of the processing.
#
#
#
#
#
#
# -----------------------------------------------------------------
# -----------------------------------------------------------------
#
# LOCALIZATION (No longer needs to be edited. This section retained for developer documentation)
#
# The only file that has to be modified for local distrubution is the scripts "spm8Batch_Global"
# 
# The distribution relies on the integrity of the directory structure of the code, DO NOT MOVE ANYTHING
# from the distrubuted organization else you will BREAK the code.
#  
# -------------
#
# (The other script spm8Setup is if you don't have spm8Batch as the default and you want to add it.)
#
# You will need to go through the spm8Batch_Global and change the following definitions:
# 
# (each section is marked by "*")
#
# *I)
#
# topDIR - this should be the parent directory, typically it's your directory where 
#          all local software scripts reside.
#
# SPM8B1 - should point to the matlab code for SPM8, current version is Revision 4290
# SPM8B2 - should point to the directory where the spm8Batch resides
# SPM8B3 - needs to point to the matlabScripts directory in spm8Batch
#
# AUXPATH - any local patches you want to invoke
#
# The localisation script makes an assumption that the paths are as follows:
# 
#             topDIR/
#
#                 SPM8B1/
#                 SPM8B2/
#                 SPM8B3/
#                 AUXPATH/
#  
# If you have something other than above you will need to make the appropriate adjustments to
# the spm8Batch_Global script. There is not actually need to define everything based on 
# topDIR, just makes it neater if you do.
#
# *II)
#
# If you experience slow access to your data because it may reside on a NAS device, than you 
# may want to consider the use of a sandbox. The sandbox is a local directory that everybody can 
# read and write to that the code will pull certain files into to operate locally and then move
# the results back to the originating directory.
#
# See : http://en.wikipedia.org/wiki/Sandbox_(software_development)
#
# SANDBOXUSE
#
# *III)
#
# The user name of the local owner of the code needs to be defined.
#
# LOCALOWNER
#
# You need to specify the name of the mail ip address. The code will send email when certain processes are 
# finished, the email address used is typically the user name for the current login at the MAILRECPT address.
#
# *IV) 
#
# MAILRECPT
#
# *V) 
#
# This is typically set to "${USER}"
#
# DEFAULTUSER
#
# *VI)
#
# These are what default MNI space you want to use for normalization processes etc.
#
# TemplateImageDir
# TemplateImageFile
#
# *VII)
#
# You need to define the location of MATLAB
#
# MATLAB
#
#
#
# # # # # # # # # # # # # # # # # #
