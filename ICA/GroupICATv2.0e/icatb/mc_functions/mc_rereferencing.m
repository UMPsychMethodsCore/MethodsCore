%% re-referencing for image 
% img1: image for referencing
% img2: image to be changed

% imgout: output image(referenced img2)

function mc_rereferencing(inimg1, inimg2, outimg)

P = strvcat(inimg1, inimg2);
Expression = '(i2)';
flags = {[],[],[],[]};
Q = spm_imcalc_ui(P,outimg,Expression,flags);