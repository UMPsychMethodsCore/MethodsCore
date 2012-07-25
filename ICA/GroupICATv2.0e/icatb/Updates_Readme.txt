GroupICAT v2.0e Updates (April 06, 2012):

1. Color defaults are changed for MAC OS. File icatb/icatb_defaults.m is modified.

2. Voxels with constant timeseries in the data are excluded while computing spatial-temporal regression. File 
icatb/icatb_helper_functions/icatb_spatial_temp_regress.m is modified.

GroupICAT v2.0e Updates (Mar 22, 2012):

Error check to test the no. of eigen values closer to machine precision is added in icatb/icatb_analysis_functions/icatb_dataReduction.m file.

GroupICAT v2.0e Updates (Feb 09, 2012):

icatb/icatb_helper_functions/icatb_loadComp.m file is fixed to load component images in zip format.

GroupICAT v2.0e Updates (Feb 04, 2012):

Added code to compute leverage and variance inflation factor of the design matrix in mancova. File 
icatb/icatb_mancovan_files/icatb_mancovan_full_design.m is modified.

GroupICAT v2.0e Updates (Jan 30, 2012):

1. Fixed orthviews colorbar tick marks. File icatb/icatb_display_functions/icatb_orth_views.m is modified.

2. Relative directory paths are used when plotting mancova results. icatb/icatb_mancovan_files/icatb_display_mancovan.m file is modified.

GroupICAT v2.0e Updates (Jan 27, 2012):

1. Added an option to select the default mask based on z-statistic in mancova. The following files are modified:
	a. icatb/icatb_io_data_functions/icatb_OptionsWindow.m
	b. icatb/icatb_mancovan_files/icatb_mancovan_feature_options.m
	c. icatb/icatb_mancovan_files/icatb_setup_mancovan.m

2. Added an option to check the conditioning of the mancova design matrix. The following files are modified:
	a. icatb/icatb_mancovan_files/icatb_mancovan_full_design.m
	b. icatb/icatb_mancovan_files/icatb_setup_mancovan_design.m

3. Added code to handle the error message "??? Error using ==> betainc.  X must be in the interval [0,1]". This error message occurs when computing
Lawley-Hotelling trace. Lawley-Hotelling trace is computed using the the reduced data, reduced model (mstepwise) and full model. To handle the error, 
number of principal components is determined using trial and error procedure. File icatb/icatb_mancovan_files/icatb_run_mancovan.m is modified.


GroupICAT v2.0e Updates (Jan 17, 2012):

The following are the changes in icatb/icatb_mancovan_files/icatb_run_mancovan.m file:

1. Preprocessing (despiking, filtering) is done on each individual subject session timecourses separately before computing FNC correlations instead of 
pre-processing on average timecourses. FNC correlations (z values) are stored in variable fnc_corrs_all in FNC MAT file (*_results_fnc.mat). 

2. Spectra is computed on each individual subject session timecourses and then averaged across sessions instead of computing spectra on average 
timecourses.

GroupICAT v2.0e Updates (Jan 06, 2012):

When maximum and minimum values are specified in the threshold parameter in ortho views, intensity values above the maximum value are set to the maximum threshold. File 
icatb/icatb_display_functions/icatb_orth_views.m is modified.

GroupICAT v2.0e Updates (Dec 23, 2011):

In mancova toolbox, spectra of timecourses is initialized using the length of the vector returned by icatb_mtspectrumc function. File 
icatb/icatb_mancova_files/icatb_get_spectra.m is modified.

GroupICAT v2.0e Updates (Dec 16, 2011):

1. Fixed spatial sorting to include mean components in the listbox when 3 numbers are used in the prefix. File icatb/icatb_sortComponentsGUI.m 
is modified.

2. Power spectra results are saved to the disk when component viewer is used. File icatb/icatb_display_functions/icatb_component_viewer.m 
is modified.

GroupICAT v2.0e Updates (Nov 30, 2011):

Modified file icatb/icatb_helper_functions/icatb_compare_frequency_bins.m to use the output directory based on the location of the parameter file.

GroupICAT v2.0e Updates (Nov 23, 2011):

Added an option to enter dummy scans in spatial temporal regression utility. File icatb/icatb_helper_functions/icatb_spatial_temp_regress.m 
is modified.

GroupICAT v2.0e Updates (Nov 18, 2011):

Fixed svd error when there are Nan's in the covariates while running mancova. Files
 icatb/icatb_mancovan_files/icatb_mancovan_full_design.m and icatb/icatb_mancovan_files/icatb_run_mancovan.m are modified.


GroupICAT v2.0e Updates (Nov 14, 2011):

1. Added an option in ICASSO plugin to enter minimum and maximum no. of clusters when selecting the most stable ICA run estimate. The following
files are modified:
	a. icatb/icatb_helper_functions/icatb_get_icasso_opts.m
	b. icatb/icatb_batch_files/Input_data_subjects_1.m
	c. icatb/icatb_batch_files/Input_data_subjects_2.m
	d. icatb/icatb_batch_files/Input_spatial_ica.m
	e. icatb/toolbox/eegiftv1.0c/icatb_eeg_batch_files/Input_eeg_data_subjects_1.m
	f. icatb/toolbox/eegiftv1.0c/icatb_eeg_batch_files/Input_eeg_data_subjects_2.m

2. Modified file icatb/icatb_analysis/icatb_calibrateComponents.m to use full file path of the parameter file while saving the parameter file.

3. Added an option to label the component maps using the template maps. Best network for each component is selected based on the correlation value
 between the spatial map and the template maps. The following files are modified or added:
	a. icatb/component_labeller.fig
	b. icatb/component_labeller.m
	c. icatb/gift.fig
	d. icatb/icatb_helper_functions/icatb_compLabeller.m
	e. icatb/icatb_helper_functions/icatb_utilities.m

4. Editbox is set to inactive instead of setting enable off in icatb/icatb_mancovan_files/icatb_display_mancovan.m

5. Added options to do dimensionality estimation in the Mancova toobox. icatb/icatb_mancovan_files/icatb_run_mancovan.m is modified.

6. Added templates to do component labelling (http://findlab.stanford.edu/functional_ROIs.html). The following file are added:
	a. icatb/icatb_templates/RSN.zip
	b. icatb/icatb_templates/RSN.txt

7. icatb_orth_views code is fixed to handle out of memory error when there are large dimensions.

8. Added variable "icaOptions" to specify ICA options for the selected algorithm. The following files are added:
	a. icatb/icatb_batch_files/Input_data_subjects_1.m
	b. icatb/icatb_batch_files/Input_data_subjects_2.m
	c. icatb/icatb_batch_files/Input_spatial_ica.m
	d. icatb/toolbox/eegiftv1.0c/icatb_eeg_batch_files/Input_eeg_data_subjects_1.m
	e. icatb/toolbox/eegiftv1.0c/icatb_eeg_batch_files/Input_eeg_data_subjects_2.m

9. Changed broadman label to brodmann in talairach script.

10. Constrained ICA (Spatial) M file is now added. Please see icatb/icatb_analysis_functions/icatb_algorithms/icatb_multi_fixed_ICA_R_Cor.m.

11. Added icatb_spm8_files/icatb_spm_platform.m

12. Added an option to do intensity normalization on the data prior to doing spatial temporal regression in GIFT utilities. 
File icatb/icatb_helper_functions/icatb_spatial_temp_regress.m is modified.


GroupICAT v2.0e Updates (Aug 31, 2011):

Timecourses generated using ICASSO centrotypes can be noisy when using higher model order. To fix the problem, most stable ICA run estimates are used instead of centrotype estimates. 
File icatb/icatb_analysis_functions/icatb_calculateICA.m is modified.


GroupICAT v2.0e Updates (Aug 24, 2011):

1. Mancova toolbox is fixed to handle the categorical covariates having more than or equal to 3 levels. Option is now provided to use threshold criteria for plotting univariate results. 
The following files are changed:
	a. icatb/icatb_mancovan_files/icatb_display_mancovan.m
	b. icatb/icatb_mancovan_files/icatb_mancovan_interactions.m
	c. icatb/icatb_mancovan_files/icatb_plot_mult_mancovan.m
	d. icatb/icatb_mancovan_files/icatb_plot_univariate_results.m
	e. icatb/icatb_mancovan_files/icatb_run_mancovan.m
	f. icatb/toolbox/mancovan/mT.m

2. T-maps displayed previously are un-thresholded t-maps in the features drop down box. Option is provided to change the T-threshold.



GroupICAT v2.0e Updates (Aug 12, 2011):

Fixed opening display GUI error when prefixes contain underscores. 

GroupICAT v2.0e Updates (Aug 10, 2011):

icatb/icatb_talairach_scripts/icatb_talairach.m file is modified to include the flip sign in computing real world coordinates before sending to talairach server. R/L is removed as the 
coordinates are already in neurological format.


GroupICAT v2.0e Updates (Aug 05, 2011):

Fixed icatb/icatb_helper_functions/icatb_spm_avg_runs.m file to check the spm version properly.


GroupICAT v2.0e Updates (Aug 02, 2011):

1. icatb/icatb_defaults_gui.m is modified to refresh the path after changing the defaults.

2. Error check is added to check the "outputFiles" field in icatb/icatb_mancovan_files/icatb_run_mancovan.m.

3. Edit control enable property is set to "inactive" instead of "off" to handle bug in MATLAB R2011a. The following files are modified:
	a. icatb/icatb_define_parameters.m
	b. icatb/icatb_setup_analysis.m
	c. icatb/icatb_io_data_functions/icatb_OptionsWindow.m
	d. icatb/icatb_mancovan_files/icatb_setup_mancovan.m

4. Error check is added in icatb/icatb_mancovan_files/icatb_display_mancovan.m file to check if the mancova analysis is done or not.


GroupICAT v2.0e Updates (July 31, 2011):

Fixed icatb/icatb_setup_analysis.m to handle missing user interface control "Group PCA Type" in Source Based Morphometry.

GroupICAT v2.0e Updates (July 29, 2011):

1. Added "Grand Mean" option under group PCA type as implemented in FSL's melodic. PCA is done on the mean of the data-sets and each subject's data is
projected on to the eigen space of the mean before doing temporal concatenation. The following files are modified:
	a. icatb/icatb_define_parameters.m
	b. icatb/icatb_setup_analysis.m
	c. icatb/icatb_analysis_functions/icatb_dataReduction.m
	d. icatb/icatb_analysis_functions/icatb_parameterInitialization.m
	e. icatb/icatb_batch_files/icatb_read_batch_file.m
	f. icatb/icatb_batch_files/Input_data_subjects_1.m
	g. icatb/icatb_batch_files/Input_data_subjects_2.m
	h. icatb/icatb_batch_files/Input_spatial_ica.m	
	i. icatb/icatb_display_functions/icatb_displaySesInfo.m
	j. icatb/icatb_helper_functions/icatb_get_resume_info.m	
	k. icatb/toolbox/eegiftv1.0c/icatb_eeg_batch_files/Input_eeg_data_subjects_1.m
	l. icatb/toolbox/eegiftv1.0c/icatb_eeg_batch_files/Input_eeg_data_subjects_2.m

2. Added an option to change defaults from the GUI. You could invoke defaults GUI using groupica defaults or click on defaults
button in groupica figure window. The following files are modified or added:
	a. icatb/icatb_defaults_gui.m
	b. icatb/groupica.fig
	c. icatb/groupica.m
	d. icatb/icatb_io_data_functions/icatb_OptionsWindow.m

3. Error check is added in icatb/mancovan_toolbox.m file to check the MATLAB version and required toolboxes to run mancova.

4. Title of the figures is changed when no significant covariates are found. Please see icatb/icatb_mancovan_files/icatb_plot_univariate_results.m


GroupICAT v2.0e Updates (July 19, 2011):

1. icatb/icatb_analysis_functions/icatb_groupStats.m step is fixed to handle "Undefined function or variable subjectICAFiles".
2. icatb/icatb_io_data_functions/icatb_read_data.m is fixed to handle the "subscript assignment mismatch" error when percent signal change scaling step is selected in GIFT. 
3. icatb/icatb_mancovan_files/icatb_display_mancovan.m file is modified to select covariates only when there are multiple covariates. 
4. icatb/icatb_mancovan_files/icatb_mancovan_interactions.m file is modified to handle single covariate.
5. By default, despiking and filtering of timecourses is done when computing FNC correlations. icatb/icatb_mancovan_files/icatb_run_mancovan.m file is modified to accept 
the user input to avoid despiking or filtering of timecourses.
6. Added userdata property to icatb/icatb_io_data_functions/icatb_OptionsWindow.m to store the information related to the user interface controls.



