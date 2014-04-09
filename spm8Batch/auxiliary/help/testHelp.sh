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
	    . ${thisDir}/auxiliary/help/help_case_all_runs
	    ;;
	"a") 
	    . ${thisDir}/auxiliary/help/help_case_anatomy_path
	    ;;
	"b") 
	    . ${thisDir}/auxiliary/help/help_case_bet_best_flag
	    ;;
	"D") 
	    . ${thisDir}/auxiliary/help/help_case_super_debug_flag
	    ;;
	"d") 
	    . ${thisDir}/auxiliary/help/help_case_debug_flag
	    ;;
	"F") 
	    . ${thisDir}/auxiliary/help/help_case_fmri_tr
	    ;;
	"f") 
	    . ${thisDir}/auxiliary/help/help_case_functional_path
	    ;;
	"g") 
	    . ${thisDir}/auxiliary/help/help_case_BET_gradient
	    ;;
	"h") 
	    . ${thisDir}/auxiliary/help/help_case_hires_name
	    ;;
	"i") 
	    . ${thisDir}/auxiliary/help/help_case_set_run
	    ;;
	"M") 
	    . ${thisDir}/auxiliary/help/help_case_subject_dir
	    ;;
	"m") 
	    . ${thisDir}/auxiliary/help/help_case_flirt_options
	    ;;
	"N") 
	    . ${thisDir}/auxiliary/help/help_case_output_name
	    ;;
	"n") 
	    . ${thisDir}/auxiliary/help/help_case_output_name
	    ;;
	"O") 
	    . ${thisDir}/auxiliary/help/help_case_other_names
	    ;;
	"o") 
	    . ${thisDir}/auxiliary/help/help_case_overlay_name
	    ;;
	"P") 
	    . ${thisDir}/auxiliary/help/help_case_physiooptions
	    ;;
	"p") 
	    . ${thisDir}/auxiliary/help/help_case_physioname
	    ;;
	"R") 
	    . ${thisDir}/auxiliary/help/help_case_reslice_2
	    ;;
	"r") 
	    . ${thisDir}/auxiliary/help/help_case_reslice_1
	    ;;
	"S") 
	    . ${thisDir}/auxiliary/help/help_case_standard_volume
	    ;;
	"s") 
	    . ${thisDir}/auxiliary/help/help_case_sub_path
	    ;;
	"T") 
	    . ${thisDir}/auxiliary/help/help_case_template_name
	    ;;
	"t") 
	    . ${thisDir}/auxiliary/help/help_case_test_flag
	    ;;
	"U") 
	    . ${thisDir}/auxiliary/help/help_case_user_email
	    ;;
	"u") 
	    . ${thisDir}/auxiliary/help/help_case_best_bet
	    ;;
	"V") 
	    . ${thisDir}/auxiliary/help/help_case_verify_flag
	    ;;
	"v") 
	    . ${thisDir}/auxiliary/help/help_case_volume_name
	    ;;
	"w") 
	    . ${thisDir}/auxiliary/help/help_case_coreg_path
	    ;;
	"z") 
	    . ${thisDir}/auxiliary/help/help_case_voxel_size
	    ;;
	"#") 
	    . ${thisDir}/auxiliary/help/help_case_run_number
	    ;;
	"*") 
	    echo
	    echo "     Unrecognized option : ${allowedOptions:$iOPT:1}"
	    echo
    esac
done
