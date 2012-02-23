%This function uses only one input: DCM_name: what is the name of your DCM
%matrix (including the path in the front)
%output: it gives you dcm_estimation matrix which is the estimation of this
%dcm matrix

function dcm_estimation=dcm_do_job(DCM_name)
    dcm_estimation = spm_dcm_estimate(fullfile(DCM_name));
end