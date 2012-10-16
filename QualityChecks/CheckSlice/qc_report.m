function qc_report(Out,Rname)
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

scrsz = get(0,'ScreenSize');
                 
h = figure('Position',[1 scrsz(4)/2 1280 720],'visible','off');
plot(abs(Out.SliceZScore));
title('Slice Z Score','FontSize',16);
xlabel('Slice','FontSize',16); ylabel('Z score','FontSize',16);
set(gca,'fontsize',16)
print('-dpsc','-loose',Rname,h);
close(h);

h = figure('Position',[1 scrsz(4)/2 1280 720],'visible','off');
plot(abs(Out.SliceTmse));
title('MSE between Slices','FontSize',16);
xlabel('Slice','FontSize',16); ylabel('Normalized MSE','FontSize',16);
set(gca,'fontsize',16)
print('-dpsc','-loose','-append',Rname,h);
close(h);


h = figure('position',[1 scrsz(4)/2 1280 720],'visible','off');
hist(Out.VoxelSnr,100);
title('Voxel SNR','FontSize',16);
xlabel('SNR','FontSize',16);ylabel('Bins','FontSize',16);
set(gca,'fontsize',16)
print('-dpsc','-loose','-append',Rname,h);
close(h);

h = figure('position',[1 scrsz(4)/2 1280 720],'visible','off');
plot(Out.WholeVolumeMean,Out.WholeVolumeStd,'x');
title('Whole Volume Mean vs Whole Volume STD','FontSize',16);
xlabel('Whole Volume Mean','FontSize',16);ylabel('Whole Volume STD','FontSize',16);
set(gca,'fontsize',16)
print('-dpsc','-loose','-append',Rname,h);
close(h);

h = figure('position',[1 scrsz(4)/2 1280 720],'visible','off');
plot(Out.Wvtmse,'x');
title('Whole Volume MSE','FontSize',16);
xlabel('Scan','FontSize',16);ylabel('MSE','FontSize',16);
set(gca,'fontsize',16)
print('-dpsc','-loose','-append',Rname,h);
close(h);
