function results = rmReg_nii (niftiNameIn, niftiNameOut, allDesMat, xclude)

% rmReg (file_root, allslices_Desmats. ,[xclude])
%
% removes known trends in time series of images.  Aimed at Physio correction
%
%   (c) 2006 Luis Hernandez-Garcia
%   University of Michigan
%   report bugs to:  hernan@umich.edu
%
% The program solves the linear model specified in DesMat for the
% parameters by ordinary least squares. It returns the residuals to a 4D image file
% called residuals.img
%
% important note.  we estimate the intercept regressor, but we do not remove it from
% the data.  The program assumes the intercept is the FIRST column in the
% input (allDesMat).
%
% xclude lets you estimate, but not remove regressors in the
% design matrix.  If ommited we default to 1 (not removing the first
% regressor, which is assumed to be the baseline)

%
% Modifed by Robert C. Welsh 
% October 13, 2011
% 
% This users NIFTI i/o as written by John Ashburner/SPM8
%

fprintf('   Entering rmReg_nii\n');

startCPU = cputime;

if nargin==3
    xclude=1;
end

% A little trick that this will point to the first regressor to use when
% removing the variance due to physio.

if xclude > 0
    xclude = 2;
else
    xclude = 1;
end

results = -1;

% Add the nifti extension to the file name.

if findstr(niftiNameIn,'.nii') ~= length(niftiNameIn)-3
    niftiNameIn = [niftiNameIn '.nii'];
end

if findstr(niftiNameOut,'.nii') ~= length(niftiNameOut)-3
    niftiNameOut = [niftiNameOut '.nii'];
end

% Now read in the nifti data using the nifti object as part of SPM8.

niftiIn = nifti(niftiNameIn);

% Now check to see if dimensions line up?

Nframes = niftiIn.dat.dim(4);

Ntime   = size(allDesMat,2);

if Ntime > Nframes
    fprintf('    Trimming design matrix from %d to fit data,%d\n',Ntime,Nframes);
    allDesMat = allDesMat(:,1:Nframes,:);
end

Ntime   = size(allDesMat,2);

if Ntime < Nframes
    fprintf('    Error, design matrix is not of sufficient length to regress out physio\n');
    return
end

% ----------------- variance -----------------

% Initialize the variance before and after.

fprintf('       Input run file   : %s\n',niftiNameIn);
fprintf('       Output run file  : %s\n',niftiNameOut);

fprintf('         Variance before')
% data area.
niftiVarOutData          = file_array;

niftiVarOutData.fname    = 'varianceBeforePhysio.nii';
niftiVarOutData.dim      = [niftiIn.dat.dim(1:3) 1];
niftiVarOutData.dtype    = niftiIn.dat.dtype;
niftiVarOutData.offset   = niftiIn.dat.offset;

% header area
niftiVarOut              = nifti;
niftiVarOut.mat          = niftiIn.mat;
niftiVarOut.mat_intent   = niftiIn.mat_intent;
niftiVarOut.mat0         = niftiIn.mat0;
niftiVarOut.mat0_intent  = niftiIn.mat0_intent;
niftiVarOut.descrip      = [niftiIn.descrip ', variance before physio corrected']; 
niftiVarOut.timing       = niftiIn.timing; 

niftiVarOut.dat          = niftiVarOutData;

create(niftiVarOut);

niftiVarOut.dat(:,:,:,:) = zeros(niftiVarOutData.dim);

% Now calculate the variance before.

fprintf('.');
SpaceByTimeData = reshape(double(niftiIn.dat),[prod(niftiIn.dat.dim(1:3)) niftiIn.dat.dim(4)]);
VarBefore       = reshape((std(SpaceByTimeData,[],2)).^2,[niftiVarOutData.dim(1:3)]);
fprintf('.');
niftiVarOut.dat(:,:,:,:) = VarBefore;

% Now free up memory.

clear niftiVarOut niftiVarOutData

% ----------------- removal of physio -----------------

% Initialize the residuals file (which is our new time-series with the physio removed).

% data area.
niftiResOutData          = file_array;

niftiResOutData.fname    = niftiNameOut;
niftiResOutData.dim      = niftiIn.dat.dim;
niftiResOutData.dtype    = niftiIn.dat.dtype;
niftiResOutData.offset   = niftiIn.dat.offset;

% header area
niftiResOut              = nifti;
niftiResOut.mat          = niftiIn.mat;
niftiResOut.mat_intent   = niftiIn.mat_intent;
niftiResOut.mat0         = niftiIn.mat0;
niftiResOut.mat0_intent  = niftiIn.mat0_intent;
niftiResOut.descrip      = [niftiIn.descrip ', physio corrected']; 
niftiResOut.timing       = niftiIn.timing; 

niftiResOut.dat          = niftiResOutData;

create(niftiResOut);

niftiResOut.dat(:,:,:,:) = zeros(niftiIn.dat.dim);


% We need to transpose the design matrix as we have our data organized as
% space x time not time x space. The GLM we solve is
% 
% Y = beta * X;
% 
% Y * X' (X X')^-1 = beta;
%

fprintf(' Physio correct');

tmp = zeros([niftiIn.dat.dim(1:2) 1 niftiIn.dat.dim(4)]);
for iSlice = 1:niftiIn.dat.dim(3)
    X  = squeeze(allDesMat(iSlice,:,:))';
    iX = pinv(X);
    xX = X(xclude:end,:);
    
    sliceData = reshape(double(squeeze(niftiIn.dat(:,:,iSlice,:))),[prod(niftiIn.dat.dim(1:2)) niftiIn.dat.dim(4)]);
    Betas = sliceData * iX;
    sliceData = sliceData - Betas(:,xclude:end) * xX;
    sliceData = reshape(sliceData,[ niftiIn.dat.dim(1:2) niftiIn.dat.dim(4)]);
    tmp(:,:,1,:) = sliceData;
    niftiResOut.dat(:,:,iSlice,:) = tmp;
    fprintf('.');
end

% ----------------- variance -----------------

% Initialize the variance before and after.

fprintf(' Variance after')

% data area.
niftiVarOutData          = file_array;

niftiVarOutData.fname    = 'varianceAfterPhysio.nii';
niftiVarOutData.dim      = [niftiIn.dat.dim(1:3) 1];
niftiVarOutData.dtype    = niftiIn.dat.dtype;
niftiVarOutData.offset   = niftiIn.dat.offset;

% header area
niftiVarOut              = nifti;
niftiVarOut.mat          = niftiIn.mat;
niftiVarOut.mat_intent   = niftiIn.mat_intent;
niftiVarOut.mat0         = niftiIn.mat0;
niftiVarOut.mat0_intent  = niftiIn.mat0_intent;
niftiVarOut.descrip      = [niftiIn.descrip ', variance after physio corrected']; 
niftiVarOut.timing       = niftiIn.timing; 

niftiVarOut.dat          = niftiVarOutData;

create(niftiVarOut);

niftiVarOut.dat(:,:,:,:) = zeros(niftiVarOutData.dim);

% Now calculate the variance after.

fprintf('.');
SpaceByTimeData = reshape(double(niftiResOut.dat),[prod(niftiResOut.dat.dim(1:3)) niftiResOut.dat.dim(4)]);
VarBefore       = reshape((std(SpaceByTimeData,[],2)).^2,[niftiVarOutData.dim(1:3)]);
fprintf('.');
niftiVarOut.dat(:,:,:,:) = VarBefore;
    
% Now free up memory.

clear niftiVarOut niftiVarOutData

% 

save regressors allDesMat

fprintf('Done\n');
fprintf('       CPU Usage : %f\n',cputime-startCPU);

results = 1;

return





