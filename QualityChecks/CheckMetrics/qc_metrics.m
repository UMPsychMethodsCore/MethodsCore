function [Out] = qc_metrics(fname,fmask)
%
% Input
%  fname - 4D nifti file
%  fmask - optional brain mask
%
% Out.
%  Fname - file name
%  Dimensions - image dimensions
%  MaskVoxels - number of voxels in mask
%  VoxelSnr - vector of SNR as defined by Tor Wager
%  MeanVoxelSnr - mean SNR value
%  InMean - mean value of slices in mask, 1 x z
%  OutMean - mean value of slices out mask, 1 x z
%  WholeSliceMean - mean value of whole slices, z x t
%  WholeSliceStd - standard deviation of whole slices, z x t
%  SliceTmse - mean squared error between scans for a run, z x t
%  SliceZScore - z score between slice means, z x t
%  WholeVolumeMean - whole volume means, 1 x t
%  WholeVolumeStd - whole volume standard deviation, 1 x t
%  Wvtmse - mean squared error between whole scans
%

Out = [];

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

% Create implicit mask or use already defined one
if exist('fmask','var') ~= 1
    mask   = mean(Data,4) > mean(Data(:));
else
    fmask_nii = nifti(fmask);
    mask      = logical(fmask_nii.dat(:,:,:,:));
    clear fmask_nii;
end

if sum(mask(:)) < 1000
    fprintf(1,'WARNING: Mask may be not that great.\n');
    return;
end

Data       = reshape(Data,dx*dy,dz,dt);
mask       = reshape(mask,dx*dy,dz);
bgmask     = ~mask;
GlobalMean = mean(Data(:));

% Calclulate TorWager stats
InData  = zeros(sum(mask(:)),dt);
OutData = zeros(sum(bgmask(:)),dt);
for i = 1:dt
    Scans        = Data(:,:,i);
    InData(:,i)  = Scans(mask);
    OutData(:,i) = Scans(bgmask);
end
meants           = mean(InData,2);
stdts            = std(InData,[],2);
Out.VoxelSnr     = meants./stdts;
Out.MeanVoxelSnr = mean(Out.VoxelSnr);
Out.InMean       = mean(InData(:));
Out.OutMean      = mean(OutData(:));

% Calculate slice metrics
SliceMean   = zeros(dz,dt);
SliceStd    = zeros(dz,dt);
SliceZScore = zeros(dz,dt);
Tmse        = zeros(dz,dt);
for i = 1:dz
    Slices           = squeeze(Data(:,i,:));
    SliceMean(i,:)   = mean(Slices,1);
    stdMean          = std(SliceMean(i,:));
    if stdMean == 0; stdMean = 1; end;
    SliceZScore(i,:) = (SliceMean(i,:)-mean(SliceMean(i,:)))/stdMean;
    SliceStd(i,:)    = std(Slices,[],1);
    Tmse(i,:)        = [0 mean(diff(Slices,1,2).^2,1)/GlobalMean];
end
Out.WholeSliceMean = SliceMean;
Out.WholeSliceStd  = SliceStd;
Out.SliceTmse      = Tmse;
Out.SliceZScore    = SliceZScore;


% Calculate whole scan metrics
VolumeMean    = zeros(1,dt);
VolumeStd     = zeros(1,dt);
Wvtmse        = zeros(1,dt);
RefVol        = Data(:,:,1);
VolumeMean(1) = mean(RefVol(:));
VolumeStd(1)  = std(RefVol(:));
for i = 2:dt
    CurVol        = Data(:,:,i);
    VolumeMean(i) = mean(CurVol(:));
    VolumeStd(i)  = std(CurVol(:));
    DiffVolume    = RefVol - CurVol;
    Wvtmse(i)     = mean( DiffVolume(:).^2 )/GlobalMean;
end

Out.Fname           = fname;
Out.Dimensions      = [dx dy dz dt];
Out.MaskVoxels      = sum(mask(:));
Out.WholeVolumeMean = VolumeMean;
Out.WholeVolumeStd  = VolumeStd;
Out.Wvtmse          = Wvtmse;
