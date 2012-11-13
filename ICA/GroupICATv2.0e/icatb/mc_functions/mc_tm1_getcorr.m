%% calculate fit index
% img1: template
% img2: component from ICA output

function score = mc_tm1_getcorr(img1, img2)

vols1 = spm_read_vols(spm_vol(img1));
vols2 = spm_read_vols(spm_vol(img2));

vols1 = reshape(vols1,[numel(vols1),1]);
vols2 = reshape(vols2,[numel(vols2),1]);


score = corr2(vols1,vols2);
