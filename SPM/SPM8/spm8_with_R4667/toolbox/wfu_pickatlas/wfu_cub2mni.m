function outMNI = wfu_cub2mni(inCub, inMat)
% function outMNI = wfu_cub2mni(inCub, inMat)
% converts from cubic space to MNI space based on the affine matrix

    mnicoords = inMat*[inCub(1) inCub(2) inCub(3) 1]';
    outMNI = mnicoords(1:3)';
return
