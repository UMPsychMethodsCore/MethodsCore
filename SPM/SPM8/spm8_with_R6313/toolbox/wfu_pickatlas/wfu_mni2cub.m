function outCub = wfu_cub2mni(inMNI, inMat)
% function outCub = wfu_cub2mni(inMNI, inMat)
% converts from MNI space from Cubic Space based on the affine matrix
%
% do not round output

    cubecoords = inv(inMat)*[inMNI(1) inMNI(2) inMNI(3) 1]';
%    cubecoords = round(cubecoords(1:3)');
    outCub = cubecoords;
return
