function [prob, mean] = AmapMex(src, label, n_classes, n_iters, sub, pve, init, mrf_weight, voxelsize, iters_icm, bias_fwhm)
% FORMAT [prob, mean] = AmapMex(src, label, n_classes, n_iters, sub, pve, init, mrf_weight, voxelsize, iters_icm, bias_fwhm)
%
% Christian Gaser
% $Id: AmapMex.m 290 2010-02-25 14:22:47Z gaser $

rev = '$Rev: 290 $';

disp('Compiling AmapMex.c')

pth = fileparts(which(mfilename));
p_path = pwd;
cd(pth);
mex -O AmapMex.c Kmeans.c Amap.c MrfPrior.c Pve.c vollib.c
cd(p_path);

[prob, mean] = AmapMex(src, label, n_classes, n_iters, sub, pve, init, mrf_weight, voxelsize, iters_icm, bias_fwhm);

return
