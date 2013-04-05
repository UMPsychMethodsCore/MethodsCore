function out = qc_CalcFrameMetrics(fname)
%
% Input:
%   fname - string file name
%
% Output
%   out
%       out{1} - mean of masked frames
%       out{2} - z score of mean frames
%       out{3} - z score of difference between mean frames
%       out{4} - mse between frames

out = cell(4,1);

% Do some file checking
if exist(fname,'file') ~= 2
    fprintf(1,'FATAL ERROR: Invalid file name: %s\n',fname);
    fprintf(1,' * * * A B O R T I N G * * *\n');
    return;
end

fname_nii = nifti(fname);
Data      = fname_nii.dat(:,:,:,:);
clear fname_nii;

[dx dy dz dt] = size(Data);
Data = reshape(Data,dx*dy*dz,dt);

if  dz < 1
    fprintf(1,'FATAL ERROR: z dimensions must be greater than 1.\n');
    fprintf(1,' * * * A B O R T I N G * * *\n');
    return;
end

if dt < 2
    fprintf(1,'FATAL ERROR: Expected a 4 dimensional nifti.\n');
    fprintf(1,' * * * A B O R T I N G * * *\n');
    return;
end

% Create implicit mask
mask = true(dx*dy*dz,1);
for i = 1:dt
    tm = Data(:,i) < (mean(Data(:,i))/8);
    mask(tm) = 0;
end

if sum(mask(:)) < 1000
    fprintf(1,'WARNING: Mask may be not that great.\n');
    return;
end

out{1} = zeros(dt,1);
for i = 1:dt
    out{1}(i) = mean(Data(mask,i));
end

meanMean = mean(out{1}(:));
stdMean = std(out{1}(:));
out{2} = (out{1} - meanMean)/stdMean;

temp = diff(out{1});
meanTemp = mean(temp(:));
stdTemp = std(temp(:));
out{3} = [0; (temp - meanTemp)/stdTemp];

out{4} = [0 mean(diff(Data,1,2).^2,1)];

