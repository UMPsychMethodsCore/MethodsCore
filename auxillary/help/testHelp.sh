#!/bin/bash

thisDir=/Users/rcwelsh/Software/spm8Batch

allowedOptions="ADdfFiMnpPtUv#"

nOptions=${#allowedOptions}

echo
echo "   Number of allowed options : $nOptions"
echo

let jOptions=( $nOptions - 1 )

for iOPT in `seq 0 ${jOptions}`
do
    case ${allowedOptions:$iOPT:1} in 
	"A") 
	    . ${thisDir}/auxillary/help/help_case_all_runs
	    ;;
	"a") 
	    . ${thisDir}/auxillary/help/help_case_anatomy_path
	    ;;
	"b") 
	    . ${thisDir}/auxillary/help/help_case_bet_best_flag
	    ;;
	"D") 
	    . ${thisDir}/auxillary/help/help_case_super_debug_flag
	    ;;
	"d") 
	    . ${thisDir}/auxillary/help/help_case_debug_flag
	    ;;
	"F") 
	    . ${thisDir}/auxillary/help/help_case_fmri_tr
	    ;;
	"f") 
	    . ${thisDir}/auxillary/help/help_case_functional_path
	    ;;
	"g") 
	    . ${thisDir}/auxillary/help/help_case_BET_gradient
	    ;;
	"h") 
	    . ${thisDir}/auxillary/help/help_case_hires_name
	    ;;
	"i") 
	    . ${thisDir}/auxillary/help/help_case_set_run
	    ;;
	"M") 
	    . ${thisDir}/auxillary/help/help_case_subject_dir
	    ;;
	"m") 
	    . ${thisDir}/auxillary/help/help_case_flirt_options
	    ;;
	"N") 
	    . ${thisDir}/auxillary/help/help_case_output_name
	    ;;
	"n") 
	    . ${thisDir}/auxillary/help/help_case_output_name
	    ;;
	"O") 
	    . ${thisDir}/auxillary/help/help_case_other_names
	    ;;
	"o") 
	    . ${thisDir}/auxillary/help/help_case_overlay_name
	    ;;
	"P") 
	    . ${thisDir}/auxillary/help/help_case_physiooptions
	    ;;
	"p") 
	    . ${thisDir}/auxillary/help/help_case_physioname
	    ;;
	"R") 
	    . ${thisDir}/auxillary/help/help_case_reslice_2
	    ;;
	"r") 
	    . ${thisDir}/auxillary/help/help_case_reslice_1
	    ;;
	"S") 
	    . ${thisDir}/auxillary/help/help_case_standard_volume
	    ;;
	"s") 
	    . ${thisDir}/auxillary/help/help_case_sub_path
	    ;;
	"T") 
	    . ${thisDir}/auxillary/help/help_case_template_name
	    ;;
	"t") 
	    . ${thisDir}/auxillary/help/help_case_test_flag
	    ;;
	"U") 
	    . ${thisDir}/auxillary/help/help_case_user_email
	    ;;
	"u") 
	    . ${thisDir}/auxillary/help/help_case_best_bet
	    ;;
	"V") 
	    . ${thisDir}/auxillary/help/help_case_verify_flag
	    ;;
	"v") 
	    . ${thisDir}/auxillary/help/help_case_volume_name
	    ;;
	"w") 
	    . ${thisDir}/auxillary/help/help_case_coreg_path
	    ;;
	"z") 
	    . ${thisDir}/auxillary/help/help_case_voxel_size
	    ;;
	"#") 
	    . ${thisDir}/auxillary/help/help_case_run_number
	    ;;
	"*") 
	    echo
	    echo "     Unrecognized option : ${allowedOptions:$iOPT:1}"
	    echo
    esac
done
