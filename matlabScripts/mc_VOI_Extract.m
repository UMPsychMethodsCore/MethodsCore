function mb = mc_VOI_Extract(spmmat,ROI,varargin)
%A utility function to setup an SPM8 matlabbatch structure to perform VOI
%extraction -- and optionally run the created job.
%
% FORMAT [job] = mc_VOI_Extract(SPMmat,ROI,[outputname],[radius],[contrast],[threshold],[adjust])
%
% OUTPUT VARIABLES
%   job         - Optional output argument.  If used, the output job will
%                 contain the matlabbatch structure for all the runs in the
%                 input SPM.mat.  If excluded, this function will directly
%                 run the extraction and no output will be returned.
%
% INPUT PARAMETERS
%   SPMmat      - Full path to SPM.mat file to use for extraction.
%                 Extraction will be performed for each run present in that
%                 file.
%   ROI         - ROI specification.  If using an ROI image, this should be
%                 a string path to a binary mask image.  If using a 
%                 spherical ROI, this should be a 1x3 vector with the MNI 
%                 coordinates of the center of the sphere.
%   outputname  - String setting output name of VOI file.  File will always
%                 have a VOI_ prefix and _N suffix where N is the run
%                 number. Defaults to ROI file name or X_Y_Z_radius.
%   radius      - If using a spherical ROI you need to provide the radius
%                 of the ROI in mm.  If using an ROI image you can leave
%                 this blank ([]) or exclude it if you are using defaults
%                 for the next two options. It defaults to 5mm.
%   contrast    - The contrast number (from the SPM.mat) that will be used
%                 for the ROI extraction.  If you want to extract
%                 unthresholded data, this contrast doesn't matter so can
%                 be left blank ([]) or excluded if using defaults for the
%                 next options. It defaults to 1.
%   threshold   - Should be either a scalar value defining an uncorrected
%                 P-value threshold for the extraction contrast (defaults 
%                 to 1), or a structure as described below:
%                 threshold.p           - P-value threshold
%                 threshold.extent      - Minimum cluster size in voxels
%                 threshold.correction  - correction type 'none' or 'fwe'
%   adjust      - Contrast number of F-contrast to adjust for from the
%                 original SPM.  Defaults to 0 (no adjustment).
%

clear job;
	    
bRunJob = 1;
if (nargout > 0)
    bRunJob = 0;
end

radius = 5;
contrast = 1;
threshold = 1;
adjust = 0;
outputname = [];

if (nargin > 2)
    outputname = varargin{1};
end
if (nargin > 3)
    radius = varargin{2};
end
if (nargin > 4)
    contrast = varargin{3};
end
if (nargin > 5)
    threshold = varargin{4};
end
if (nargin > 6)
    adjust = varargin{5};
end
if (nargin > 7)
    mc_Error(sprintf('You have provided more than 7 inputs (%d).  Please check the function help.',nargin));
end

if (~strcmp(spmmat(end-6:end),'SPM.mat'))
    spmmat = fullfile(spmmat,'SPM.mat');
end

if (~exist(spmmat,'file'))
    mc_Error(sprintf('SPM file %s does not exist. Please check your paths.',spmmat));
end

if (ischar(ROI))
    if (~exist(ROI,'file'))
        mc_Error(sprintf('ROI file %s does not exist. Please check your paths.',ROI));
    end
    roi.mask.image = ROI;
    roi.mask.threshold = 0.5;
    [p f e] = fileparts(ROI);
    if (isempty(outputname))
        outputname = f;
    end
elseif (isnumeric(ROI))
    if (size(ROI,1)>1)
        ROI = ROI';
    end
    if (size(ROI,2) ~= 3)
        mc_Error('Input variable ROI should be either a string or a 1x3 numeric vector.');
    end
    roi.sphere.centre = ROI;
    roi.sphere.radius = radius;
    roi.sphere.move.fixed = 1;
    roistring = sprintf('%d_%d_%d',round(ROI));
    if (isempty(outputname))
        outputname = sprintf('%s_%d',roistring,round(radius));
    end
else
    mc_Error('Input variable ROI should be either a string or a 1x3 numeric vector.'); 
end

if (isnumeric(threshold))
    threshold.p = threshold;
    threshold.extent = 0;
    threshold.correction = 'none';
else
    if (strcmpi(threshold.correction,'fwe'))
        threshold.correction = 'FWE';
    elseif (strcmpi(threshold.correction,'none'))
        threshold.correction = 'none';
    else
        mc_Error(sprintf('Correction must be either none or FWE, but is set to %s.',threshold.correction));
    end
end

job.spm.util.voi.spmmat = {spmmat};
job.spm.util.voi.adjust = adjust;
job.spm.util.voi.session = 1;
job.spm.util.voi.name = outputname;
job.spm.util.voi.roi{1}.spm.spmmat = {spmmat};
job.spm.util.voi.roi{1}.spm.contrast = contrast;
job.spm.util.voi.roi{1}.spm.conjunction = 1;
job.spm.util.voi.roi{1}.spm.threshdesc = threshold.correction;
job.spm.util.voi.roi{1}.spm.thresh = threshold.p;
job.spm.util.voi.roi{1}.spm.extent = threshold.extent;
job.spm.util.voi.roi{2} = roi;
job.spm.util.voi.expression = 'i1&i2';

SPM = load(spmmat);
NumRun = size(SPM.SPM.Sess,2);

clear mb;
for iRun = 1:NumRun
    mb{iRun} = job;
    mb{iRun}.spm.util.voi.session = iRun;
end

if (bRunJob)
    spm_jobman('run',mb);
end
