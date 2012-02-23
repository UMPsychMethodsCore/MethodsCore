%This function uses inputs: 1.data_path: where your DCM matrix is
%2. name: what is the name of your DCM matrix
%output: it gives you dcm_estimation matrix which is the estimation of this
%dcm matrix

function dcm_estimation=dcm_do_job(data_path,name)
    dcm_estimation = spm_dcm_estimate(fullfile(data_path,name));
end