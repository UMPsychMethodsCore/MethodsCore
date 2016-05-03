%% calculate fit index
% img1: template
% img2: component from ICA output

function score = mc_tm1_getfitindex(img1, img2)

vols1 = spm_read_vols(spm_vol(img1));
vols2 = spm_read_vols(spm_vol(img2));

matching_vol = vols1.*vols2;
unmatching_vol = (1-vols1).*vols2;

% matching_ind = find (matching_vol);
% unmatching_ind = find (unmatching_vol);
% 
% valid_matching_vol = matching_vol(matching_ind);
% valid_unmatching_vol = unmatching_vol(unmatching_ind);
% 
% score = (mean(zscore(valid_matching_vol)))/(mean(zscore(valid_unmatching_vol)));

score = (mean(mean(mean(matching_vol))))-(mean(mean(mean(unmatching_vol))));
