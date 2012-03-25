function results = dSpike(inputData,detOpt)

results = -1;

if exist(inputData,'file') ~= 2
    fprintf('Invalid file.\n');
    return
end

% Read in data
P    = nifti(inputData);
data = P.dat(:,:,:,:);

X = size(data,1);
Y = size(data,2);
Z = size(data,3);
T = size(data,4);

% Remove whole mean
mu_whole = mean( data(:) );
data     = data - mu_whole;

series = zeros(T,1);
% Remove temporal trend, then compute temporal Z-score for each voxel
for z=1:Z
    for y=1:Y
        for x=1:X
            % detrend
            series(:) = data(x,y,z,:);
            d_series  = spm_detrend(series,detOpt);
            
            % compute Z-score
            s_mu     = mean(d_series);
            s_std    = std(d_series);
            z_series = (d_series - s_mu)./(s_std + eps);
            
            % reassign values
            data(x,y,z,:) = abs( z_series(:) );
        end
    end
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
    
    AJKZ(z,:) = (AAZ(z,:) - mu_i)./(std_i + eps);
end
    
results = abs(AJKZ);    
    
return