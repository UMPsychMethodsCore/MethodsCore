% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
%
% See SOM_MakeSphereROI if you want sizes other than those below.
%
% Check the ROI parameters.
%
% INPUT
%
%   parameters -- see SOM_PreProcesData
%
%      .rois
%          [ specify one or the other: "mni" or "files"]
%         .mni
%              .coordinates   - table of n coordinates (x,y,z)
%              .size          - which size, 1, 7, 19, 27 voxels
%                               (default is 19)
%                  .XROI      - optional array of user specficied size.
%                  .YROI        see below on how to build it.
%                  .ZROI
%         .files              - table of ROI files
%
%         .mask
%               .File         - full directory path and name to file.
%               .MaskFLAG     - 0 no mask, 1 mask
%
% OUTPUT
% 
%     rois
%   
%        .OK = 1 all okay, other wise not.
%
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


function rois = SOM_CheckROIParameters(parameters);

%save SOM_CheckROIParameters_01 parameters

% Some initialization of tables we need.

% Single voxel

XROI{1} = [ +0 ];
YROI{1} = [ +0 ];
ZROI{1} = [ +0 ];

% Intersectiong plus signs.

XROI{2} = [ +0   +0  -1 +0 +1  +0   +0];
YROI{2} = [ +0   -1  +0 +0 +0  +1   +0];
ZROI{2} = [ -1   +0  +0 +0 +0  +0   +1];

% Neighbors in a cube, but don't include the corners.

XROI{3} = [ +0 -1 +0 +1 +0   -1 +0 +1 -1 +0 +1 -1 +0 +1   +0 -1 +0 +1 +0];
YROI{3} = [ -1 +0 +0 +0 +1   -1 -1 -1 +0 +0 +0 +1 +1 +1   -1 +0 +0 +0 +1];
ZROI{3} = [ -1 -1 -1 -1 -1   +0 +0 +0 +0 +0 +0 +0 +0 +0   +1 +1 +1 +1 +1];

% Neighbors in a cube, but include the corners.

XROI{4} = [-1 +0 +1 -1 +0 +1 -1 +0 +1   -1 +0 +1 -1 +0 +1 -1 +0 +1   -1 +0 +1 -1 +0 +1 -1 +0 +1   ];
YROI{4} = [-1 -1 -1 +0 +0 +0 +1 +1 +1   -1 -1 -1 +0 +0 +0 +1 +1 +1   -1 -1 -1 +0 +0 +0 +1 +1 +1   ];
ZROI{4} = [-1 -1 -1 -1 -1 -1 -1 -1 -1   +0 +0 +0 +0 +0 +0 +0 +0 +0   +1 +1 +1 +1 +1 +1 +1 +1 +1   ];

SIZENAMES = ['XROI';'YROI';'ZROI'];

SIZEOPTIONS = [1 7 19 27];

% Default is error

rois.OK = -1;

% check for the "rois" field;

if isfield(parameters,'rois') == 0
    SOM_LOG('FATAL ERROR : You need to specify ROI definitions');
    return
end

rois = parameters.rois;

rois.OK = -1;

% Okay, let's determine if specifying mni coordinates or images.

if isfield(rois,'mni') == 0
    if isfield(rois,'files') == 0
        SOM_LOG('FATAL ERROR : You need to specify at least ".mni" or ".files"');
        return
    else
        rois.type = 1;
    end
else
    rois.type = 0;
end

% Now see if they specified a mask to constrain the ROI's
% The rois will ALSO be constrained by the mask as defined in
% parameters.epi

if isfield(rois,'mask') == 0
    rois.mask = [];
end

rois.mask = SOM_ParseFileParam(rois.mask);

if rois.mask.OK == -1
    SOM_LOG('FATAL ERROR : You specified a mask that does not exist');
    return
end

%
% If the mask wasn't specified we will use the first image of the time series
% data as a mask as we need to make sure that the ROIS are in the brain.
%

if isempty(rois.mask.File)
    try
        PMask = parameters.data.run(1).P(1,:);
        SOM_LOG(sprintf('STATUS : Using %s as a masking image',parameters.data.run(1).P(1,:)));
    catch
        SOM_LOG('FATAL ERROR : No time series data specified yet.');
        return
    end
else
    PMask = rois.mask.File;
end

%
% Now make sure that the mask specified matchs our data.
%

PMaskHDR = spm_vol(PMask);

if SOM_SpaceVerify(parameters.data.run(1).hdr,PMaskHDR) ~= 1
  SOM_LOG('FATAL ERROR : Error with consistent image space (ROI Mask) definition.');
  return
end

% Now work through the configuration of the ROIs

switch rois.type
    
    case 0
        
        %
        % this case is mni coordinates
        %
        
        % Must have specified the array of MNI coordinates in the
        % structure.
        if isfield(rois.mni,'coordinates') == 0
            SOM_LOG('FATAL ERROR : You need to specificy MNI coordinates, ".coordinates" array is missing');
            return
        end
        
        % And of course they need to be numeric.
        if isnumeric(rois.mni.coordinates) == 0
            SOM_LOG('FATAL ERROR :  You must specify numerical MNI coordinates');
            return
        end
        
        % And the array needs to be N x 3
        if size(rois.mni.coordinates,2) ~= 3
            SOM_LOG('FATAL ERROR : Incorrect size of MNI ".coordinates" array');
            SOM_LOG('FATAL ERROR : You need to specify 3 coordinates (x,y,z) for each entry');
            return
        end
        
        % Next, how big is each ROI, they will all be the same.
        if isfield(rois.mni,'size') == 0
            SOM_LOG(sprintf('STATUS : size of ROIS not specified, defaulting to %d voxels',SOM.defaults.roi.mni.size));
            rois.mni.size = SOM.defaults.roi.mni.size;
        end
        
        % You can either specify the size, or you can attach structure
        % indicating the size of the ROI with the ".XROI", ".YROI" and
        % ".ZROI" sizes.
        if isnumeric(rois.mni.size)
            whichSIZE = find(SIZEOPTIONS==rois.mni.size(1));
            if length(whichSIZE) < 1
                whichSIZE = 3;
                SOM_LOG('WARNING : roi ".size" is not recognized, defaulting to 19 voxels');
            end
            rois.mni.size = [];
            rois.mni.size.XROI = XROI{whichSIZE};
            rois.mni.size.YROI = YROI{whichSIZE};
            rois.mni.size.ZROI = ZROI{whichSIZE};
            rois.mni.size.size = length(rois.mni.size.XROI);
        else
            for iXYZ = 1:3
                if isfield(rois.mni.size,SIZENAMES(iXYZ,:)) == 0
                    SOM_LOG('FATAL ERROR : You need to specify either a size, or your own XROI, YROI, ZROI');
                end
            end
            rois.mni.size.size = length(rois.mni.size.XROI);
        end
        
        %
        % Now make sure that the sizes are all the same
        %
        
        if any(size(rois.mni.size.XROI)-size(rois.mni.size.YROI))
            SOM_LOG('FATAL ERROR : size of XROI, YROI do not match');
            return
        end
        if any(size(rois.mni.size.XROI)-size(rois.mni.size.ZROI))
            SOM_LOG('FATAL ERROR : size of XROI, ZROI do not match');
            return
        end
        
        %
        % Now see if any of the coordinates are inside the masking image.
        %
        
        % How many rois were passed?
        rois.nroisRequested = size(rois.mni.coordinates,1);

        rois.mni.inIDX = SOM_roiPointsInMask(PMask,rois.mni.coordinates);

        rois.ROIOK = zeros(rois.nroisRequested,1);
        
        % For now each ROI will contain the same number of voxels, however,
        % this will later get masked again so make sure that the ROI true
        % extent doesn't go beyond the time series masking image.
        rois.nvoxels = rois.mni.size.size*ones(rois.nroisRequested,1);
        
        % Mark which ROI's are good.
        rois.ROIOK(rois.mni.inIDX) = 1;

        % How many valid ROIS really?
        rois.nrois = length(rois.mni.inIDX);
                
    case 1
        
        %
        % this case is roi-files
        %
        
        % How many rois were passed?
        rois.nroisRequested = size(rois.files,1);
        rois.nvoxels = zeros(rois.nroisRequested,1);
        
        %
        % For now the voxel dimensionality of the ROI files must strictly
        % adhere to the size of the input data.
        %
        
        try
            MVol = spm_read_vols(spm_vol(PMask));
            MVol = MVol > 0;
        catch
            SOM_LOG('FATAL ERROR : Can not figure out the mask');
            return
        end
        
        %DATAHDR = spm_vol(parameters.data.run(1).P(1,:));
        
        for iFILE = 1:rois.nroisRequested
            thisFILE = strtrim(rois.files(iFILE,:));
            if exist(thisFILE,'file') == 0
                SOM_LOG(sprintf('FATAL ERROR : ROI file:%s does not exist.',thisFILE));
                return
            end
            %
            % If the file doesn't adhere to SPM standards this will produce
            % a fatal error.
            %
            try
	      rois.hdr(iFILE) = spm_vol(thisFILE);
	      
	      if SOM_SpaceVerify(parameters.data.run(1).hdr,rois.hdr(iFILE)) ~= 1
		SOM_LOG('FATAL ERROR : Error with consistent roi image space definition.');
		return
	      end
	      
	      %
	      % Count how many voxels in this ROI
	      %
	      SOM_LOG(sprintf('STATUS : read hdr for %s\n',thisFILE));
	      thisVOL = spm_read_vols(rois.hdr(iFILE));
	      rois.nvoxels(iFILE) = sum(sum(sum((thisVOL>0).*MVol)));
            catch
	      SOM_LOG(sprintf('FATAL ERROR : spm could not read file %s',thisFILE));
	      return
            end
        end
        
        rois.ROIOK = zeros(rois.nroisRequested,1);
        rois.ROIOK(find(rois.nvoxels)) = 1;

        % How many valid ROIS really?
        rois.nrois = length(find(rois.nvoxels));
end

%
% In either method, did any rois survive the masking?
%

if rois.nrois < 1
    SOM_LOG('FATAL WARNING : No rois survived masking.');
    return
end

SOM_LOG(sprintf('STATUS : %d rois survived masking',rois.nrois));

%
% If we got this far, then the ROI definitions are good.
% Other logic testing takes place in SOM_CalculateCorrelations.
%

rois.OK = 1;

return

%
% All done
%

