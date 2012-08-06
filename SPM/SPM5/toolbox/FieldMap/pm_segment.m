function dat = pm_segment(fname)
% Segment an MR image into Gray, White & CSF.
%
% FORMAT dat = pm_segment(fname)
% fname - name of image to segment.
% dat   - matrix of size MxNxPx3 containing the resulting tissue probabilities
%_______________________________________________________________________
% Refs:
%
% Ashburner J & Friston KJ (1997) Multimodal Image Coregistration and
% Partitioning - a Unified Framework. NeuroImage 6:209-217
%_______________________________________________________________________
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience
% John Ashburner
% $Id: pm_segment.m 1914 2008-07-14 14:40:34Z chloe $

if nargin<1, fname = spm_select(1,'image'); end
opts.tpm      = strvcat(fullfile(spm('dir'),'apriori','grey.nii'),...
                        fullfile(spm('dir'),'apriori','white.nii'),...
                        fullfile(spm('dir'),'apriori','csf.nii'));
opts.ngaus    = [1 1 1 4];
opts.regtype  = 'mni';
opts.warpreg  = 1;
opts.warpco   = 40;
opts.biasreg  = 1.0000e-04;
opts.biasfwhm = 80;
opts.samp     = 6;
opts.msk      = '';

p    = spm_preproc(fname,opts); % RUN THE SEGMENTATION

T    = p.Twarp;
bsol = p.Tbias;
d2   = [size(T) 1];
d    = p.image.dim(1:3);

[x1,x2,o] = ndgrid(1:d(1),1:d(2),1);
x3  = 1:d(3);
d3  = [size(bsol) 1];
B1  = spm_dctmtx(d(1),d2(1));
B2  = spm_dctmtx(d(2),d2(2));
B3  = spm_dctmtx(d(3),d2(3));
bB3 = spm_dctmtx(d(3),d3(3),x3);
bB2 = spm_dctmtx(d(2),d3(2),x2(1,:)');
bB1 = spm_dctmtx(d(1),d3(1),x1(:,1));

mg  = p.mg;
mn  = p.mn;
vr  = p.vr;
K   = length(mg);
Kb  = length(p.ngaus);
lkp = []; for k=1:Kb, lkp = [lkp ones(1,p.ngaus(k))*k]; end;
M   = p.tpm(1).mat\p.Affine*p.image.mat;
b0  = spm_load_priors(p.tpm);
for z=1:length(x3),
    f          = spm_sample_vol(p.image,x1,x2,o*x3(z),0);
    cr         = exp(transf(bB1,bB2,bB3(z,:),bsol)).*f;
    [t1,t2,t3] = defs(T,z,B1,B2,B3,x1,x2,x3,M);
    q          = zeros([d(1:2) Kb]);
    bt         = zeros([d(1:2) Kb]);
    b          = zeros([d(1:2) K ]);
    for k1=1:Kb, bt(:,:,k1) = spm_sample_priors(b0{k1},t1,t2,t3,k1==Kb); end;
    for  k=1:K,   b(:,:,k ) = bt(:,:,lkp(k))*mg(k); end;
    s = sum(b,3)+eps;
    for k=1:K,
        p1            = exp((cr-mn(k)).^2/(-2*vr(k)))/sqrt(2*pi*vr(k)+eps);
        q(:,:,lkp(k)) = q(:,:,lkp(k)) + p1.*b(:,:,k)./s;
    end;
    s = sum(q,3)+eps;
    for k1=1:3,
        dat(:,:,z,k1) = uint8(round(255 * q(:,:,k1)./s));
    end;
end;

%=======================================================================

%=======================================================================
function [x1,y1,z1] = defs(sol,z,B1,B2,B3,x0,y0,z0,M)
x1a = x0    + transf(B1,B2,B3(z,:),sol(:,:,:,1));
y1a = y0    + transf(B1,B2,B3(z,:),sol(:,:,:,2));
z1a = z0(z) + transf(B1,B2,B3(z,:),sol(:,:,:,3));
x1  = M(1,1)*x1a + M(1,2)*y1a + M(1,3)*z1a + M(1,4);
y1  = M(2,1)*x1a + M(2,2)*y1a + M(2,3)*z1a + M(2,4);
z1  = M(3,1)*x1a + M(3,2)*y1a + M(3,3)*z1a + M(3,4);
return;
%=======================================================================

%=======================================================================
function t = transf(B1,B2,B3,T)
if ~isempty(T)
    d2 = [size(T) 1];
    t1 = reshape(reshape(T, d2(1)*d2(2),d2(3))*B3', d2(1), d2(2));
    t  = B1*t1*B2';
else
    t = zeros(size(B1,1),size(B2,1),size(B3,1));
end;
return;
%=======================================================================