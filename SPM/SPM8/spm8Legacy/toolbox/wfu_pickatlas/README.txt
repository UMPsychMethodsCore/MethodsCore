WFU Pickatlas version 2.4 
Joseph Maldjian, MD

Description
     This software provides a method for generating ROI masks based on the Talairach Daemon database [1, 2].  The atlases include Brodmann area, Lobar, Hemisphere, Anatomic Label and Tissue Type.  The atlases have been extended to the vertex in MNI space (see Atlas Modifications under Technical Notes), and corrected for the precentral gyrus anomaly (see reference 7 below). Additional atlases can be added without much difficulty.  The toolbox was developed in the Functional MRI Laboratory at the Wake Forest University School of Medicine. Questions can be referred to maldjian@wfubmc.edu .

Downloading the Software
     The wfu_pickatlas toolbox and user manual can be obtained from:
        www.fmri.wfubmc.edu 

Program Installation
     Untar the tar file into the toolbox directory of your SPM installation:
	tar -xvf WFU_PickAtlas.tar  
This will create a subdirectory called wfu_pickatlas in your SPM toolbox directory.  If access is from the SPM Toolboxes drop-down menu, the wfu_pickatlas path with be automatically prepended to the current matlab path.  Otherwise, you will need to set your matlab path to directly access the wfu_pickatlas directory:
	path(SPMpath/toolbox/wfu_pickatlas,path); 
For command line execution, the wfu_pickatlas toolbox path must be above the SPM path.  If the software is installed properly, you should be able to either run it from the SPM Toolboxes drop-down list or call the wfu_pickatlas GUI from the matlab command prompt with:
        wfu_pickatlas;

Compatibility
     The wfu_pickatlas tool requires at least Matlab 6.0, and  is compatible with SPM99, SPM2 and SPM5 [3-5] (from the Wellcome Dept. of Cognitive Neurology, London, UK). The toolbox has been evaluated on both Sun Solaris and Linux platforms.  It has not been tested for Windows.

Referencing the software
     When using this tool for a paper please reference:
Maldjian, JA, Laurienti, PJ, Burdette, JB, Kraft RA.  An Automated Method for Neuroanatomic and Cytoarchitectonic Atlas-based Interrogation of fMRI Data Sets.  NeuroImage.  19(3):1233-1239.

Maldjian JA, Laurienti PJ, Burdette JH.  Precentral Gyrus Discrepancy in Electronic Versions of the Talairach Atlas.  Neuroimage 2004; 21(1) 450-455.  
     The manuscripts provide a complete description of how the atlas volumes were generated and validated.

If using the Talairach Daemon database atlases, please also reference:

Lancaster, JL, Summerln, JL, Rainey, L, et al. The talairach daemon, a database server for talairach atlas labels. NeuroImage 1997; 5:S633.
Lancaster, JL, Woldorff, MG, Parsons, LM, et al. Automated talairach atlas labels for functional brain mapping. Hum Brain Mapp 2000; 10:120-131.



If using the included aal atlas, please also reference [8]:

Tzourio-Mazoyer N, Landeau B, Papathanassiou D, Crivello F, Etard O, Delcroix N, Mazoyer B, Joliot M. Automated anatomical labeling of activations in SPM using a macroscopic anatomical parcellation of the MNI MRI single-subject brain. Neuroimage. 2002; 15(1):273-89.

For compatibility with the pickatlas software, the aal atlas segmented regions were remapped into the range of 1-116.  The segmentations however were not altered.



References
1.  Lancaster, JL, Summerln, JL, Rainey, L, et al. The talairach daemon, a database server for talairach atlas labels. NeuroImage 1997; 5:S633.
2.  Lancaster, JL, Woldorff, MG, Parsons, LM, et al. Automated talairach atlas labels for functional brain mapping. Hum Brain Mapp 2000; 10:120-131.
3.  Friston, K, Holmes, A, Worsley, K, et al. Statistical parametric maps in functional imaging: A general linear approach. Human Brain Mapping 1995; 2:189-210.
4.  Friston, KJ, Ashburner, J, Poline, J, et al. Spatial registration and normalization of images. Human Brain Mapping 1995; 2:165-189.
5.  Holmes, A, Friston, K. Generalizability, random effects and population inference. Neuroimage 1998; 7:s754.
6.  Maldjian, JA, Laurienti, PJ, Burdette, JH, et al. An automated method for neuroanatomic and cytoarchitectonic atlas-based interrogation of fmri data sets. Neuroimage 2003; 19(3):1233-1239.
7.  Maldjian JA, Laurienti PJ, Burdette JH.  Precentral Gyrus Discrepancy in Electronic Versions of the Talairach Atlas.  Neuroimage 2004; 21(1) 450-455.  
8.  Tzourio-Mazoyer N, Landeau B, Papathanassiou D, Crivello F, Etard O, Delcroix N, Mazoyer B, Joliot M. Automated anatomical labeling of activations in SPM using a macroscopic anatomical parcellation of the MNI MRI single-subject brain. Neuroimage. 2002; 15(1):273-89.

