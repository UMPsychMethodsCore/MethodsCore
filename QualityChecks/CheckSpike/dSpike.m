function results = dSpike(inputData,detOpt)

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
    detOpt = [];
end

% Read in data
inputData = P.dat(:,:,:,:);

[xDim yDim nSlice nTime] = size(inputData);

% Remove whole mean
mu_whole  = mean( inputData(:) );
inputData = inputData - mu_whole;

% Remove temporal trend, then compute temporal Z-score for each voxel
for z=1:nSlice
    slice = squeeze(inputData(:,:,z,:));
    reSlice = reshape(slice,xDim*yDim,nTime)';
    % detrend
    if ~isempty(detOpt)
        reSlice = spm_detrend(reSlice,detOpt);    
    end
    %get z score
    zScoreSlice = zscore(reSlice);    
    inputData(:,:,z,:) = abs( reshape(zScoreSlice',xDim,yDim,1,nTime) );   
end

AAZ  = zeros(nSlice,nTime);
% Average the Z-scores across slices and time
for t=1:nTime
    for z=1:nSlice
        AAZ(z,t) = sum(sum(inputData(:,:,z,t)))/(xDim*yDim);
    end
end    

AJKZ    = zeros(nSlice,nTime);
indexes = [1:nSlice]';
% Calculate AJKZ
for z=1:nSlice
    loc = (indexes ~= z);
    included = AAZ(loc,:);
    mu_i = mean(included,1);
    std_i = std(included,1);
    std_i(std_i==0) = 1;
    AJKZ(z,:) = (AAZ(z,:) - mu_i)./(std_i);
end
    
results = abs(AJKZ);    
    
return