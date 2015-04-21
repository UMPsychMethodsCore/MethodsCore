GroupICAT v3.0a Updates (Feb 21, 2015):

Undefined function or variable "desCriteria" is fixed in icatb/icatb_helper_functions/icatb_dfnc_stats.m file.


GroupICAT v3.0a Updates (Feb 13, 2015):

1. Internet connection is not required to generate talairach labels and MNI coordinates are also reported. The following files are modified:

	a. icatb/icatb_talairach_scripts/icatb_generate_tal.m
	b. icatb/icatb_talairach_scripts/icatb_talairach.m
	c. icatb/icatb_talairach_scripts/talairach/talairach.jar

2. Option is provided to enter threshold in windows when computing dfnc stats. Bugs are fixed when displaying HTML results using two sample t-test. The following files are modified:
	a. icatb/icatb_helper_functions/icatb_dfnc_results.m
	b. icatb/icatb_helper_functions/icatb_dfnc_stats.m
	c. icatb/icatb_helper_functions/icatb_post_process_dfnc.m
	d. icatb/icatb_helper_functions/icatb_dfnc_cluster_stats.m

3. Option is now provided to plot means of categorical covariates. Context menu is provided in axes window of significant univariate results figure. 

GroupICAT v3.0a Updates (Jan 16, 2015):

1. The following files are fixed to make GIFT toolbox compatible with MATLAB R2014b:
	1. icatb/icatb_defaults.m
	2. icatb/icatb_display_functions/icatb_compositeViewer.m
	3. icatb/icatb_display_functions/icatb_drawMComponents.m
	4. icatb/icatb_display_functions/icatb_orth_views.m
	5. icatb/icatb_display_functions/icatb_orthoViewer.m
	6. icatb/icatb_helper_functions/icatb_dfnc_results.m
	7. icatb/icatb_helper_functions/icatb_plot_FNC.m
	8. icatb/icatb_helper_functions/icatb_single_trial_amplitude.m
	9. icatb/icatb_mancovan_files/icatb_display_mancovan.m
	10. icatb/icatb_mancovan_files/icatb_plot_mult_mancovan.m
	11. icatb/icatb_mancovan_files/icatb_plot_univariate_results.m
	12. icatb/toolbox/eegiftv1.0c/icatb_plotImage.m
	13. icatb/toolbox/icasso122/icassoGraph.m
	
2. Option is available in dFNC toolbox to enter different TRs across subjects and sessions. Timecourses will be interpolated using the least TR and truncated to match subjects and sessions. 
The following files are modified:
	1. icatb/icatb_helper_functions/icatb_dfnc_results.m
	2. icatb/icatb_helper_functions/icatb_post_process_dfnc.m
	3. icatb/icatb_helper_functions/icatb_run_dfnc.m
	
GroupICAT v3.0a Updates (Dec 15, 2014):

1. Added an option to use time covariate in mancova. The following files are modified:
	a. icatb/icatb_mancovan_files/icatb_display_mancovan.m
	b. icatb/icatb_mancovan_files/icatb_plot_univariate_results.m
	c. icatb/icatb_mancovan_files/icatb_plot_mult_mancovan.m
	d. icatb/icatb_mancovan_files/icatb_run_mancovan.m
	e. icatb/icatb_mancovan_files/icatb_setup_mancovan_design.m
	
2. Added options to do t-tests on dFNC correlations. Results are displayed in a HTML page. The following files are added or modified:
	a. icatb/icatb_helper_functions/icatb_dfnc_results.m
	b. icatb/icatb_helper_functions/icatb_dfnc_stats.m
	c. icatb/icatb_helper_functions/icatb_dfnc_cluster_stats.m

3. Added an option to select best ICA/IVA run using Minimum Spanning Tree (MST) approach. MST approach is based on paper 
by W. Du, S. Ma, G-S. Fu, V. Calhoun, and T. Adali, "A novel approach for assessing reliability of ICA for fMRI analysis," in Acoustics, Speech and Signal Processing  (ICASSP), 2014 IEEE International
Conference on, Florence, Italy, 2014. The following files are modified or added:
	a. icatb/icatb_helper_functions/icatb_bestRunSelection.m
	b. icatb/icatb_helper_functions/icatb_mst.m
	c. icatb/icatb_helper_functions/icatb_comp*mex*
	d. icatb/icatb_helper_functions/icatb_mst*mex*
	e. icatb/icatb_helper_functions/icatb_icasso.m
	f. icatb/icatb_analysis_functions/icatb_calculateICA.m
	
4. FBSS algorithm name is now changed to ERBM. Function icatb/icatb_analysis_functions/icatb_icaAlgorithm.m is changed.

5. Function icatb/icatb_helper_functions/icatb_postprocess_timecourses.m is fixed to handle different time points across subjects.

6. Displaying ICASSO results is turned off on MATLAB R2014b. icatb_defaults.m file is modified.


GroupICAT v3.0a Updates (Dec 04, 2014):

1. Option is specified in mancova to enter subject specific TRs for computing FNC correlations. Mean of TRs across subjects is used when computing spectra. The following files are modified:
	a. icatb/icatb_mancovan_files/icatb_mancovan_feature_options.m
	b. icatb/icatb_mancovan_files/icatb_run_mancovan.m	

GroupICAT v3.0a Updates (Oct 21, 2014):

Problem reading large nifti files is fixed now. SPM MEX binaries are modified.

GroupICAT v3.0a Updates (Sep 15, 2014):

1. Function icatb/icatb_display_functions/icatb_orth_views.m file is fixed to handle the error message "To RESHAPE the number of elements must not change".

2. Added an option to regress covariates from the timecourses before computing FNC correlations in Mancovan toolbox. This tool could be accessed in FNC correlations under Mancovan defaults. 
The following files are modified:

	a. icatb/icatb_mancovan_files/icatb_mancovan_feature_options.m
	b. icatb/icatb_mancovan_files/icatb_setup_mancovan.m
	c. icatb/icatb_mancovan_files/icatb_run_mancovan.m

GroupICAT v3.0a Updates (August 04, 2014):

1. Added an option to do back-reconstruct subject ICA components using MOO-ICAR approach. The following files are modified:

	a. icatb/icatb_analysis_functions/icatb_backReconstruct.m
	b. icatb/icatb_helper_functions/icatb_backReconOptions.m

2. Fixed select mask option in SBM toolbox.

GroupICAT v3.0a Updates (July 28, 2014):

1. Added options to compute FNC correlations and spectra of timecourses automatically after doing group stats. Results are saved in *postprocess_results.mat. 
Please variable TIMECOURSE_POSTPROCESS in icatb_defaults.m to change the settings. The following files are modified:

	a. icatb/icatb_defaults.m
	b. icatb/icatb_analysis_functions/icatb_groupStats.m
	c. icatb/icatb_helper_functions/icatb_postprocess_timecourses.m


GroupICAT v3.0a Updates (July 16, 2014):

1. Options to do t-test (one sample, two sample and paired) is now added in mancova toolbox.

2. Fixed the code to apply log transform of spectra when using run mancova step from GUI.


The following files are modified:

	a. icatb/icatb_mancovan_files/icatb_setup_mancovan_design.m
	b. icatb/icatb_mancovan_files/icatb_setup_mancovan.m
	c. icatb/icatb_mancovan_files/icatb_run_mancovan.m
	d. icatb/icatb_mancovan_files/icatb_display_mancovan.m
	e. icatb/icatb_mancovan_files/icatb_mancovan_full_design.m
	f. icatb/icatb_helper_functions/icatb_select_groups_gui.m

GroupICAT v3.0a Updates (April 24, 2014):

1. Read data is updated to load specified file numbers of Nifti file.
2. Remove components utility is modified to automatically back-reconstruct components if the back-reconstructed results are missing in disk. 

The following files are modified:

	a. icatb/icatb_io_data_functions/icatb_read_data.m
	b. icatb/icatb_helper_functions/icatb_removeArtifact.m

GroupICAT v3.0a Updates (Feb 12, 2014):

1. Function icatb/icatb_mem_ica.m is fixed to select appropriate PCA when the number of timepoints exceeds the voxel dimensions.

2. Anatomical file to overlay default directory is set to icatb/icatb_templates in icatb/icatb_display_functions/icatb_component_viewer.m.

GroupICAT v3.0a Updates (Jan 03, 2014):

1. Function icatb/icatb_mancovan_files/icatb_fitggmix.m now works without optimization toolbox.

GroupICAT v3.0a Updates (October 1, 2013):

1. File icatb/icatb_helper_functions/icatb_run_dfnc.m is fixed to avoid averaging of session timecourses when computing dFNC correlations. 

GroupICAT v3.0a Updates (Sep 12, 2013):

1. Feature specific defaults are added in mancova batch file.

2. Added batch script to do dFNC.

3. Option is provided to use low frequency and high frequency values to compute fALFF.

4. Sliding window computation using tukey window is disabled.

5. Added an option to use component network names in plotting FNC correlation matrix in mancova. 

The following files are modified or added:

	1. icatb/icatb_batch_files/input_mancovan.m
	2. icatb/icatb_batch_files/input_dfnc.m
	3. icatb/icatb_display_functions/icatb_component_viewer.m
	4. icatb/icatb_helper_functions/icatb_loadComp.m
	5. icatb/icatb_helper_functions/icatb_dfnc_batch.m
	6. icatb/icatb_helper_functions/icatb_plot_FNC.m
	7. icatb/icatb_helper_functions/icatb_dfnc_options.m
	8. icatb/icatb_helper_functions/icatb_setup_dfnc.m
	9. icatb/icatb_helper_functions/icatb_run_dfnc.m
	10. icatb/icatb_mancovan_files/icatb_mancovan_batch.m
	11. icatb/icatb_mancovan_files/icatb_setup_mancovan.m
	12. icatb/icatb_mancovan_files/icatb_mancovan_feature_options.m
	13. icatb/icatb_mancovan_files/icatb_run_mancovan.m
	14. icatb/icatb_mancovan_files/icatb_get_spec_stats.m
	15. icatb/icatb_mancovan_files/icatb_ggmix.m
	16. icatb/icatb_mancovan_files/icatb_display_mancovan.m

GroupICAT v3.0a Updates (July 05, 2013):

1. IVA code is fixed to work on older versions of MATLAB. The following files are modified:
	a. icatb/icatb_analysis_functions/icatb_algorithms/icatb_iva_laplace.m
	b. icatb/icatb_analysis_functions/icatb_algorithms/icatb_iva_second_order.m

GroupICAT v3.0a Updates (June 18, 2013):

1. Copyright information is added in file icatb/icatb_analysis_functions/icatb_algorithms/icatb_gigicar.m.

GroupICAT v3.0a Updates (June 13, 2013):

1. Orthogonal viewer button outside of display GUI in SBM is modified to not use functional data files.

GroupICAT v3.0a Updates (June 11, 2013):

1. Spatial-temporal regression utility is now added in SBM -> Utilities.

GroupICAT v3.0a Updates (June 02, 2013):

1. File icatb/icatb_helper_functions/icatb_rename_4d_file.m is modified to generate spaces at the end of the nifti file numbers. 
