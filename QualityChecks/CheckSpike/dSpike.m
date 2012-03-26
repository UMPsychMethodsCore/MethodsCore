function results = dSpike(inputData,detOpt)

results = -1;

if exist(inputData,'file') ~= 2
    fprintf('Invalid file.\n');
    return
end

% Read in data
P    = nifti(inputData);
data = P.dat(:,:,:,:);

[X Y Z T] = size(data);

% Remove whole mean
mu_whole = mean( data(:) );
data     = data - mu_whole;

% Remove temporal trend, then compute temporal Z-score for each voxel
for z=1:Z
    % detrend
    slice = squeeze(data(:,:,z,:));
    reSlice = reshape(slice,X*Y,T)';
    detrendSlice = spm_detrend(reSlice,detOpt);    
    %get z score
    zScoreSlice = zscore(detrendSlice);    
    data(:,:,z,:) = abs( reshape(zScoreSlice',X,Y,1,T) );   
end

AAZ  = zeros(Z,T);
% Average the Z-scores across slices and time
for t=1:T
    for z=1:Z
        AAZ(z,t) = sum(sum(data(:,:,z,t)))/(X*Y);
    end
end    

AJKZ    = zeros(Z,T);
indexes = [1:Z]';
% Calculate AJKZ
for z=1:Z
    loc = (indexes ~= z);
    included = AAZ(loc,:);
    mu_i = mean(included,1);
    std_i = std(included,1);
    std_i(std_i==0) = 1;
    AJKZ(z,:) = (AAZ(z,:) - mu_i)./(std_i);
end
    
results = abs(AJKZ);    
    
return