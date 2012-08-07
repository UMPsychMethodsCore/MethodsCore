% Voxel Based Morphometry Toolbox
% Version  340  (VBM8)  2010-05-31
% __________________________________________________________________________
% Copyright (C) 2009 Christian Gaser christian.gaser@uni-jena.de
%
% $Id: Contents_info.txt 334 2010-05-19 10:56:16Z gaser $
% ==========================================================================
% Description
% ==========================================================================
% This toolbox is a collection of extensions to the segmentation algorithm 
% of SPM8 (Wellcome Department of Cognitive Neurology) to provide voxel-
% based morphometry (VBM). It is developed by Christian Gaser (University of 
% Jena, Department of Psychiatry) and is available to the scientific 
% community under the terms of the GNU General Public License.
%
% General files
%   INSTALL.txt                 - installation instructions
%   vbm8.man                    - notes on VBM8 toolbox
%   CHANGES.txt                 - changes in revisions
%
% VBM8 functions
%   spm_vbm8.m                  - toolbox wrapper to call functions
%   tbx_cfg_vbm8.m              - configure VBM8
%   cg_vbm8_write.m             - write out VBM8 results
%   cg_vbm8_run.m               - runtime funtion for VBM8
%   cg_morph_vol.m              - morphological operations to 3D data
%   cg_vbm8_longitudinal.m      - VBM8 for longitudinal data
%   cg_vbm8_defaults.m          - sets the defaults for VBM8
%   cg_vbm8_get_defaults.m      - defaults for VBM8
%
% Utility functions
%   cg_vbm8_tools.m             - wrapper for calling VBM8 utilities
%   cg_showslice_all.m          - show 1 slice of all images
%   cg_check_cov.m              - check sample homogeneity across sample
%   cg_spmT2x.m                 - transformation of t-maps to P, -log(P), r or d-maps
%   cg_lat_index.m              - calculate lateralization index
%   cg_vbm8_debug.m             - print debug information for SPM8 and VBM8
%   cg_ornlm.m                  - Optimized Blockwise Non Local Means Denoising Filter
%   cg_slice_overlay.m          - Wrapper for overlay tool slice_overlay
%   cg_slice_overlay_ui.m       - Example for user interface for overlay wrapper cg_slice_overlay.m
%   slice_overlay.m             - overlay tool
%   cg_noise_estimation.m       - local estimation of Rician noise
%   kmeans3D.m                  - Kmeans clustering
%
% Wavelet functions from http://taco.poly.edu/WaveletSoftware
%   farras.m                    - Farras nearly symmetric orthogonal wavelet bases
%   dwt3D.m                     - 3-D Discrete Wavelet Transform
%   afb3D.m                     - 3D Analysis Filter Bank
%   cshift3D.m                  - 3D Circular Shift
%
% Mex- and c-functions
%   Amap.c                      - Adaptive Maximum A Posteriori segmentation
%   AmapMex.c                   - Mex-wrapper for Amap 
%   MrfPrior.c                  - estimation of MRF weighting
%   Pve.c                       - partial volume estimaion (PVE)
%   KmeansProper.c              - Kmeans
%   ornlm.c                     - Optimized Blockwise Non Local Means Denoising Filter (core functions)
%   ornlmMex.c                  - Mex-wrapper for ornlm.c
%   upfirdn2dMex.c              - 2D replacement for the function upfirdn.m from the Matlab Signal 
%                                 Processing Toolbox of Matlab
%
% Batch functions
%   cg_vbm8_batch.m             - batch mode wrapper for spm_jobman for VBM8
%   cg_vbm8_batch.sh            - shell script to use vbm from unix without gui
%   cg_spm8_batch.m             - batch mode wrapper for spm_jobman for SPM8
%   cg_spm8_batch.sh            - shell script to call matlab batch files from unix
%                                 without gui
% Templates
%   Template_?_IXI550_MNI152.nii - Dartel template of 550 subjects from IXI database
%                                  in MNI152 space provided for 6 different iteration steps