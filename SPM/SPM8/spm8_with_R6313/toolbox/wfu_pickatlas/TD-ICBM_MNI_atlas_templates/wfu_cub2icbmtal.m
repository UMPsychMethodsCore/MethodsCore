function outpoints = wfu_cub2icbmtal(inCub, inMat)
% function outpoints = wfu_cub2icbmtal(inCub, inMat)
% allows the use of ICBM tal conversions.  You must download them seperately.

%    mnicoords = iheader.mat*[xpos ypos zpos 1]';
inpoints = inMat*[inCub 1]';
inpoints = inpoints(1:3);

if exist('icbm_spm2tal')
	outpoints = icbm_spm2tal(inpoints);
else
	beep();
	disp('Please visit http://brainmap.org/icbm2tal/ and download');
	disp('icbm_spm2tal.m and place in your PickAtlas directory.');
	outpoints = [NaN NaN NaN];
end
