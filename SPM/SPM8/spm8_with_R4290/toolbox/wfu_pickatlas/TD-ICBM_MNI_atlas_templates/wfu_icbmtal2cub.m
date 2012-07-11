function outCub = wfu_icbmtal2cub(inTal, inMat)
% function outpoints = wfu_tal2icbm_spm(inTal, inMat)
% modification of the origina wfu_tal2mni so that it returns cubic coorindates as
% opposed to MNI


if exist('tal2icbm_spm')
		MNI = tal2icbm_spm(inTal);
    cubecoords = inv(inMat)*[MNI(1) MNI(2) MNI(3) 1]';
    outCub = cubecoords;
else
	beep();
	disp('Please visit http://brainmap.org/icbm2tal/ and download');
	disp('tal2icbm_spm.m and place in your PickAtlas directory.');
	outCub = [NaN NaN NaN];
end
