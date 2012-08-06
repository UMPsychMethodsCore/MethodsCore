% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2005-2011
%
% Routine to read time-series data.
%
% function [results, maskInfo, analyzeFMT] = SOM_PrepData(P,PMask,otherVoxels)
%
%     P is array of file names (like that returned from spm_get)
%     PMask is a file name for a binary mask. 
%     If PMask if empty then there is no mask and all of the data is returned.
%     otherVoxels is an array of explicitly desired voxels.
% 
% You have two options for input
%  
% If the PMask has the ending of ".img" then use analyze, if ".nii"
% or ".nii.gz" then it's NIFTI, else assume .mat files.
%
%     1) Use of analyze img/hdr pairs, .nii, or .nii.gz such as in SPM2/SPM5/SPM8
%
%        P is an array of img file names
%        PMask is a name of binary mask volume
%
%     2) Use of matlab ".mat" files. 
%        
%        If you use this option then the mask file "PMask"
%        must contain a variable called "som_mask", which 
%        has the dimensionality of your data, but is a binary
%        image (1=use, 0=don't use).
%
%        The time-series data should only have a single variable
%        contained in the time-point ".mat" file. The reading 
%        code will use whatever variable is available, regardless 
%        of name.
%
% Only those voxels that are included in the mask are read.
%
% "otherVoxels" 
%
% This is a nVoxels x 3 array of indices. The indices must lie on
% the axis of your image. A scalar index is calculated from the
% indices into your image.
%
% You would use this array to guarantee inclusion of voxels not
% present in the mask.
%
%
% NOTE : Presently the code can only read a series of 3D files. 
%        There is NO support for 4D files yet.
%
%        However, you can just read your own data and reshape
%        appropriately for calling SOM_CalculateMap.
%
%        You should look at "SOM_MaskData" for 4D.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function [results, maskInfo, analyzeFMT] = SOM_PrepData(P,PMask,otherVoxels)

% We will store the mask information here for
% cruising the elements. This is a kludge at the moment.

global SOMMem

slot = 1;

SOM_LOG('STATUS : Reading data');

results = [];
maskInfo = [];

% If there is no mask then we will use the first image of the data.

if isempty(PMask) == 1
    [mfPath mfName mfExt] = fileparts(P(1,:));
else
    [mfPath mfName mfExt] = fileparts(PMask);
end

[fPath fName fExt] = fileparts(P(1,:));

% Modify to read in either 3d images in img or 4d in nii

switch (lower(fExt))
 case '.img'
  analyzeFMT = 1;
 case '.nii'
  analyzeFMT = 2;
 case '.nii.gz'
  analyzeFMT = 3;
 otherwise
  analyzeFMT = 0;
end

% If we are NOT using mat files.

PHDR = spm_vol(P);

if analyzeFMT > 0
    if isempty(PMask) == 1
        maskInfo.header = PHDR(1);
    else
        maskInfo.header = spm_vol(PMask);
    end
    maskInfo.analyzeFMT = 1;
    som_mask = spm_read_vols(maskInfo.header);
    % Use everything if no mask is specified.
    som_mask = som_mask>0;
else
  maskInfo.analyzeFMT = 0;
  maskInfo.fPath = fPath;  
  load(PMask);
  % 
  % hopefully this results in the loading of a variable called
  % "som_mask"
  %
  if exist('som_mask') ~= 1
    fprintf('\nError in loading the ''som_mask.mat'', the variable');
    fprintf('som_mask is missing.\n');
    results = [];
    return
  end
end

% Did they pass any requests for 
% specific voxels to be extracted?

if exist('otherVoxels') ~= 1
  otherVoxels = [];
end

[xd yd zd] = size(som_mask);
indices = [];

maskInfo.size = [xd yd zd];

if size(otherVoxels,1) > 0
  indices = xd*yd*(otherVoxels(:,3)-1)+...
	    xd*(otherVoxels(:,2)-1)+...
	    otherVoxels(:,1);
end

% Find the indices of all voxels
% to be included in analysis.


%if isempty(PMask) == 1
%    som_mask = ones(size(som_mask));
%end

maskInfo.iMask = find(som_mask);

% How many to remove from the end.

maskInfo.remove  = 0;
maskInfo.indices = indices;   % index of other data.

% Are the requested voxels already included, 
% if not add to the list but mark for removal 
% before actual SOM calculation.

% Build a list of pointers to the data in the reduced set
% to where the voxels now live.

indexOfIndex = [];

for ii = 1:size(indices)
  if length(find(maskInfo.iMask == indices(ii))) == 0
    maskInfo.iMask = [maskInfo.iMask ;indices(ii)];
    maskInfo.remove = maskInfo.remove+1;
    indexOfIndex = [indexOfIndex length(maskInfo.iMask)];
  end
    indexOfIndex = [indexOfIndex find(maskInfo.iMask==indices(ii))];
end

maskInfo.indexOfIndex = indexOfIndex;

% Initialize matrix for time-series data.

results = zeros(length(maskInfo.iMask),length(PHDR));

% Now extract it all.

% If we have Luis Hernandez's "read_nii_img, read_nii_hdr,
% img_endian", then we will read from that as it's a lot faster.

FASTCODEPRESENT=1;

FASTCODE={'nifti','SOM_read_nii_img','SOM_read_nii_hdr','SOM_img_endian'};

for iCODE = 1:length(FASTCODE)
  if exist(FASTCODE{iCODE}) ~= 2
    FASTCODEPRESENT = 0
  end
end

if FASTCODEPRESENT & analyzeFMT == 2
  tic;
  %theVols = SOM_read_nii_img(P);   % Depreceated on 2012-03-23 - RCWelsh and replaced with SOM_ReadNII which uses 'nifti'
  theVols = SOM_ReadNII(P);
  results = (theVols(:,maskInfo.iMask))';
  toctime = toc;
  SOM_LOG(sprintf('STATUS : Fast read code implemented, %s',toctime));
else
  fprintf('Reading Data\n\n');
  for iP = 1:length(PHDR)
    fprintf('\b\b\b%03d',iP);
    if analyzeFMT > 0
      %
      % Analyze file
      %
      theVol = spm_read_vols(PHDR(iP,:));
    else
      % 
      % Using a ".mat" file, pick the first variable found.
      % Be careful, could result in big error!
      % Better to use img/hdr pairs for now.
      % 
      tmpVol = load(P(iP,:));
      fldNM = fieldnames(tmpVol);
      theVol = getfield(tmpVol,fldNM{1});
    end
    %
    % Now do sanity check of the volume size.
    %
    if any(maskInfo.size - size(theVol))
      SOM_LOG('FATAL ERROR : reading time-series data, size doesn''t match');
      SOM_LOG(sprintf('FATAL ERROR : Size of mask %d %d %d, size of current volume #%d : %d %d %d',maskInfo.size,iP,size(theVol)));
      results = [];
      return
    end
    results(:,iP) = theVol(maskInfo.iMask);
    clear theVol;
  end
  fprintf('\nDone\n');
end


SOM_LOG('STATUS : Prepdata Done');

clear theVol;

SOMMem{slot}.maskInfo = maskInfo;

return

%
% All done.
%
