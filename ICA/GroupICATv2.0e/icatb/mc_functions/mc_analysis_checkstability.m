%% read img from 4 random perms
vol1 = spm_read_vols(spm_vol('driving_mean_component_ica_s_all_001.img'));
vol2 = spm_read_vols(spm_vol('driving_mean_component_ica_s_all_005.img'));
vol3 = spm_read_vols(spm_vol('driving_mean_component_ica_s_all_006.img'));
vol4 = spm_read_vols(spm_vol('driving_mean_component_ica_s_all_010.img'));

%% stretch to vector
vol1vec = reshape(vol1, [1,numel(vol1)]);
vol2vec = reshape(vol2, [1,numel(vol2)]);
vol3vec = reshape(vol3, [1,numel(vol3)]);
vol4vec = reshape(vol4, [1,numel(vol4)]);

%% pull out significant voxels and make bitmask thresholding by median of voxel image
vol1vec_signi = abs(vol1vec); vol1vec_signi(vol1vec_signi<median(vol1vec_signi(vol1vec_signi>0))) = 0; vol1vec_signi(vol1vec_signi ~= 0) = 1;
vol2vec_signi = abs(vol2vec); vol2vec_signi(vol2vec_signi<median(vol2vec_signi(vol2vec_signi>0))) = 0; vol2vec_signi(vol2vec_signi ~= 0) = 1;
vol3vec_signi = abs(vol3vec); vol3vec_signi(vol3vec_signi<median(vol3vec_signi(vol3vec_signi>0))) = 0; vol3vec_signi(vol3vec_signi ~= 0) = 1;
vol4vec_signi = abs(vol4vec); vol4vec_signi(vol4vec_signi<median(vol4vec_signi(vol4vec_signi>0))) = 0; vol4vec_signi(vol4vec_signi ~= 0) = 1;


%% pull out significant voxels and make bitmask thresholding by a certain value
vol1vec_signi = abs(vol1vec); vol1vec_signi(vol1vec_signi<6) = 0; vol1vec_signi(vol1vec_signi ~= 0) = 1;
vol2vec_signi = abs(vol2vec); vol2vec_signi(vol2vec_signi<6) = 0; vol2vec_signi(vol2vec_signi ~= 0) = 1;
vol3vec_signi = abs(vol3vec); vol3vec_signi(vol3vec_signi<6) = 0; vol3vec_signi(vol3vec_signi ~= 0) = 1;
vol4vec_signi = abs(vol4vec); vol4vec_signi(vol4vec_signi<6) = 0; vol4vec_signi(vol4vec_signi ~= 0) = 1;

%% figure of reshaped 2d image (meaningless, just better vizi)
figure
subplot(1,2,1)
imagesc(reshape(vol1vec_signi,[360,403]));
subplot(1,2,2)
imagesc(reshape(vol2vec_signi,[360,403]));

figure
subplot(1,2,1)
imagesc(reshape(vol3vec_signi,[360,403]));
subplot(1,2,2)
imagesc(reshape(vol4vec_signi,[360,403]));

%% reshape back into original space
vol1bit = reshape(vol1vec_signi,[52,62,45]);
vol2bit = reshape(vol2vec_signi,[52,62,45]);
vol3bit = reshape(vol3vec_signi,[52,62,45]);
vol4bit = reshape(vol4vec_signi,[52,62,45]);


%% compare with template
voltemplate = spm_read_vols(spm_vol('visual.img'));
voltemplatevec = reshape(voltemplate, [1,numel(voltemplate)]);

sum(vol1vec_signi == vol4vec_signi)