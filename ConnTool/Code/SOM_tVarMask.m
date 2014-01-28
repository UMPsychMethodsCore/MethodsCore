% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% Routine to take temporal variance map and a mask
% and create a mask of the top P% flucuating areas.
%
% function results = SOM_tVarMask(varianceMap,brainMask,P,outputName)
%
% Input --
%
%            varianceMap - a variance map usually made from SOM_tVar
%                          or from "fslmaths [input] -Tstd [output]
%
%            brainMask   - a mask to get only brain - good to remove
%                          the eyes
%
%            P           - take the top "P" percent of flucuating
%                          voxels
%                          
%
%            outputName  - name of filet to create, either with absolute
%                          path of relative path.
%
% Output --
%
%            results     - 
%               .outputName   - output name
%               .xBins        - bins of histogram
%               .hvarMap      - histogram of values
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_tVarMask(varianceMap,brainMask,P,outputName)

results = -1;

% Open the variance map

try
    varMap = nifti(varianceMap);
catch
    SOM_LOG(sprintf('WARNING : Variance map can not be opened %s',varianceMap));
    return
end

% Open the masking file

try
    maskImg = nifti(brainMask);
catch
    SOM_LOG(sprintf('WARNING : Masking image can not be opened %s',brainMask));
    return
end

% Check for any difference

if any(varMap.dat.dim(1:3) - maskImg.dat.dim(1:3))
    SOM_LOG('WARNING : Masking image and variance map do not match.');
    return
end

% Check to see if length of P is adequate.

if length(P) > 1
    SOM_LOG('P must be a scalar');
    return
end

maskVarMap = varMap.dat(:,:,:).*maskImg.dat(:,:,:);
% Write out the results.

% Get the path of the 4D file.

[fp fn fe] = fileparts(varianceMap);

if outputName(1) ~= '/'
    outputName = fullfile(fp,outputName);
end

% Calculate teh top P percent of the voxels.

iMaskNonZero = find(maskVarMap>0);

varVals = maskVarMap(iMaskNonZero);

xBins = [0:.001:1]*max(varVals);

hvarVals = hist(varVals,xBins);

chvarVals = cumsum(hvarVals);
chvarVals = chvarVals/max(chvarVals);

idxVals = find(chvarVals>=(1-P));

% Need some error checking?

if length(idxVals) < 1
    SOM_LOG('ERROR : Can find any voxels -- weird, call Robert and debug');
    return
end

ValThresh = xBins(idxVals(1));

% Now write it out.

maskVarMap = maskVarMap >=ValThresh;

SOM_WriteNII(varianceMap,outputName,maskVarMap,'FLOAT32-LE');

clear results

results.outputName  = outputName;
results.xBins       = xBins;
results.hvarMap     = hvarVals;
results.nVoxels     = length(find(maskVarMap));
results.nVoxelsPerZ = squeeze(sum(squeeze(sum(maskVarMap,1)),1));
results.P           = P;

return
