% Script to make AAL ROIs for MarsBaR
% You will need SPM(99 or 2), and MarsBaR, on the matlab path

aal_path = spm_get(-1, '', 'Select path containing AAL files');
roi_path = spm_get(-1, '', 'Select path for MarsBaR ROI files');
aal_root = 'ROI_MNI_V4';

% ROI names
load(fullfile(aal_path, [aal_root '_List']));
% ROI image
img = fullfile(aal_path, [aal_root '.img']);

% Make ROIs
vol = spm_vol(img);
for r = 1:length(ROI)
  nom = ROI(r).Nom_L;
  func = sprintf('img == %d', ROI(r).ID); 
  o = maroi_image(struct('vol', vol, 'binarize',1,...
			 'func', func, 'descrip', nom, ...
			 'label', nom));
  saveroi(maroi_matrix(o), fullfile(roi_path,['MNI_' nom '_roi.mat']));
end