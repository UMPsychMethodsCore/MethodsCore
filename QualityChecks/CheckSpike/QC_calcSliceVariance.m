%- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
%  QC_calcSlicerVariance
% 
%  A routine for calculating some statistical properties for slices in a
%  time series
% 
%   Call as :
% 
%   function results = QC_calcSliceVariance(inputData,options)
% 
%   To Make this work you need to provide the following input:
% 
%      inputData = Either a 4D matrix or file name% 
%      options   = polynomial order used in spm_detrend (OPTIONAL)
% 
%   Output
%   
%      results   
%        = -1 if failure
%               OR
%        = struct {
%            globalMean    - scalar mean of whole volume
%            sliceMean     - nSlice x 1 array mean of each slice over time
%            sliceSTD      - nSlice x 1 array std of each slice over time
%            sliceVariance - nSlice x nTime array mean slice intensity at 
%                            given timepoint / std (slice)
%          }
% 
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function results = QC_calcSliceVariance(inputData,options)

results = -1;

if ischar(inputData)
    inputData = strtrim(inputData);
    % Check if file exists
    if exist(inputData,'file') ~= 2
        fprintf('Input data "%s"\n does not exist.\n',inputData);
        fprintf('  * * * A B O R T I N G * * *\n\n');
        return
    end
    P = nifti(inputData);
    inputData = P.dat(:,:,:,:);
end

% support only 4D arrays for now
if ndims(inputData) ~= 4
    fprintf('Expected 4D time series\n');
    fprintf('  * * * A B O R T I N G * * *\n\n');
    return
end

if nargin < 2
    options = [];
end

[xDim yDim nSlice scans] = size(inputData);

% Remove whole mean
globalMean = mean(inputData(:));
inputData  = inputData - globalMean;

% detrend time series
if ~isempty(options)
    voxelsPerPlane = xDim*yDim;
    for z=1:nSlice
        slice = squeeze(inputData(:,:,z,:));
        optSlice = reshape(slice,voxelsPerPlane,scans)';
        if options ~= 0
            detrendSlice = spm_detrend(optSlice,options);
        else
            for t=1:scans
                optSlice(:,t) = optSlice(:,t) - mean(optSlice(:,t));
            end
            detrendSlice = optSlice;
        end
        inputData(:,:,z,:) = reshape(detrendSlice',xDim,yDim,1,scans);        
    end
end

% calculate mean of slice and std of slice over time
sliceMean = zeros(nSlice,1);
sliceSTD  = zeros(nSlice,1);
for z=1:nSlice
    slice = inputData(:,:,z,:);
    
    sliceMean(z) = mean(slice(:));
    sliceSTD(z)  = std(slice(:));
end

sliceSTD(sliceSTD==0) = 1;

% calculate array of the mean slice intensity at a given time point/std
sliceVariance = zeros(nSlice,scans);
for t=1:scans
    for z=1:nSlice
        slice = inputData(:,:,z,t);
        sliceVariance(z,t) = (mean(slice(:)) - sliceMean(z))/sliceSTD(z);
    end
end

results = struct('sliceMean',sliceMean,...
                 'sliceSTD',sliceSTD,...
                 'globalMean',globalMean,...
                 'sliceVariance',sliceVariance);
return