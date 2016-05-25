function params = LI_normalise(VG,VF,matname,VWG,VWF,NL)
% Spatial (stereotactic) normalization
% This is a stripped version to match contrast images
% to the normalized masks. In order not to mess with the global defaults,
% this file was modified to do an affine-only transform, using my
% parameters instead of the global ones. It then saves the mat-file
% and returns instead of writing the file. If specifically asked for,
% it will also do a non-linear transformation. It is based on 
% spm_normalise.m (2.8 John Ashburner 03/03/04), and
% is intended to be used within the LI-toolbox;
% modifications by Marko Wilke, no guarantees! 

if ischar(VF), VF = spm_vol(VF); end;
if ischar(VG), VG = spm_vol(VG); end;
if ischar(VWG), VWG=spm_vol(VWG); end;
if ischar(VWF), VWF=spm_vol(VWF); end;
if nargin <6, NL = 0; end;

flags = struct('smosrc',8,'smoref',0,'regtype','mni','cutoff',30,'nits',16,'sep',2,'reg',0.1,'graphics',0);

VF1 = spm_smoothto8bit(VF,flags.smosrc);

% Rescale images so that globals are better conditioned
VF1.pinfo(1:2,:) = VF1.pinfo(1:2,:)/spm_global(VF1);
for i=1:prod(size(VG)),
        VG1(i) = spm_smoothto8bit(VG(i),flags.smoref);
	VG1(i).pinfo(1:2,:) = VG1(i).pinfo(1:2,:)/spm_global(VG(i));
end;

% Affine Normalisation (not if forbidden)
%-----------------------------------------------------------------------
  if NL ~= 2
	fprintf('  Coarse affine matching to mask space...\n');
	aflags    = struct('sep',max(flags.smoref,flags.smosrc), 'regtype',flags.regtype,...
		'WG',[],'WF',[],'globnorm',0);
	M         = eye(4); %spm_matrix(prms');
	spm_plot_convergence('Init','Affine Registration','Mean squared difference','Iteration');
	[M,scal]  = spm_affreg(VG1, VF1, aflags, M);
	 
	fprintf('  Fine affine matching to mask space...\n');
	aflags.WF  = VWF;
	aflags.sep = max(flags.smoref,flags.smosrc)/2;
	[M,scal]   = spm_affreg(VG1, VF1, aflags, M,scal);

	aflags.WG  = VWG;
	% aflags.sep = max(flags.smoref,flags.smosrc)/4;
	fprintf('  Masked fine affine matching to mask space...\n');
	[M,scal]   = spm_affreg(VG1, VF1, aflags, M,scal);

	Affine     = inv(VG(1).mat\M*VF1(1).mat);

	spm_plot_convergence('Clear');
  else
	Affine     = eye(4);
  end;


% Basis function Normalisation, if specifically asked for
%-----------------------------------------------------------------------
  if NL ~= 0
	fprintf('  Non-linear matching to mask space...\n');
	fov = VF1(1).dim(1:3).*sqrt(sum(VF1(1).mat(1:3,1:3).^2));
	if any(fov<15*flags.smosrc/2 & VF1(1).dim(1:3)<15),
		fprintf('Field of view too small for nonlinear registration\n');
		Tr = [];
	elseif isfinite(flags.cutoff) && flags.nits && ~isinf(flags.reg),
	        % fprintf('3D CT Norm...\n');
		Tr = snbasis(VG1,VF1,VWG,VWF,Affine,...
			max(flags.smoref,flags.smosrc),flags.cutoff,flags.nits,flags.reg);
	else
		Tr = [];
	end;
	clear VF1 VG1 

  else
	Tr = [];

  end;

% Remove dat fields before saving
%-----------------------------------------------------------------------
if isfield(VF,'dat'), VF = rmfield(VF,'dat'); end;
if isfield(VG,'dat'), VG = rmfield(VG,'dat'); end;
if ~isempty(matname),
	save(matname,'Affine','Tr','VF','VG','flags');
end;
return;

%_______________________________________________________________________

%_______________________________________________________________________
function Tr = snbasis(VG,VF,VWG,VWF,Affine,fwhm,cutoff,nits,reg)
% 3D Basis Function Normalization
% FORMAT Tr = snbasis(VG,VF,VWG,VWF,Affine,fwhm,cutoff,nits,reg)
% VG        - Template volumes (see spm_vol).
% VF        - Volume to normalize.
% VWG       - weighting Volume - for template.
% VWF       - weighting Volume - for object.
% Affine    - A 4x4 transformation (in voxel space).
% fwhm      - smoothness of images.
% cutoff    - frequency cutoff of basis functions.
% nits      - number of iterations.
% reg       - regularisation.
% Tr - Discrete cosine transform of the warps in X, Y & Z.
%
% snbasis performs a spatial normalization based upon a 3D
% discrete cosine transform.
%
%______________________________________________________________________

fwhm    = [fwhm 30];

% Number of basis functions for x, y & z
%-----------------------------------------------------------------------
tmp  = sqrt(sum(VG(1).mat(1:3,1:3).^2));
k    = max(round((VG(1).dim(1:3).*tmp)/cutoff),[1 1 1]);

% Scaling is to improve stability.
%-----------------------------------------------------------------------
stabilise = 8;
basX = spm_dctmtx(VG(1).dim(1),k(1))*stabilise;
basY = spm_dctmtx(VG(1).dim(2),k(2))*stabilise;
basZ = spm_dctmtx(VG(1).dim(3),k(3))*stabilise;

dbasX = spm_dctmtx(VG(1).dim(1),k(1),'diff')*stabilise;
dbasY = spm_dctmtx(VG(1).dim(2),k(2),'diff')*stabilise;
dbasZ = spm_dctmtx(VG(1).dim(3),k(3),'diff')*stabilise;

vx1 = sqrt(sum(VG(1).mat(1:3,1:3).^2));
vx2 = vx1;
kx = (pi*((1:k(1))'-1)/VG(1).dim(1)/vx1(1)).^2; ox=ones(k(1),1);
ky = (pi*((1:k(2))'-1)/VG(1).dim(2)/vx1(2)).^2; oy=ones(k(2),1);
kz = (pi*((1:k(3))'-1)/VG(1).dim(3)/vx1(3)).^2; oz=ones(k(3),1);

if 1,
        % BENDING ENERGY REGULARIZATION
        % Estimate a suitable sparse diagonal inverse covariance matrix for
        % the parameters (IC0).
        %-----------------------------------------------------------------------
	IC0 = (1*kron(kz.^2,kron(ky.^0,kx.^0)) +...
	       1*kron(kz.^0,kron(ky.^2,kx.^0)) +...
	       1*kron(kz.^0,kron(ky.^0,kx.^2)) +...
	       2*kron(kz.^1,kron(ky.^1,kx.^0)) +...
	       2*kron(kz.^1,kron(ky.^0,kx.^1)) +...
	       2*kron(kz.^0,kron(ky.^1,kx.^1)) );
        IC0 = reg*IC0*stabilise^6;
        IC0 = [IC0*vx2(1)^4 ; IC0*vx2(2)^4 ; IC0*vx2(3)^4 ; zeros(prod(size(VG))*4,1)];
        IC0 = sparse(1:length(IC0),1:length(IC0),IC0,length(IC0),length(IC0));
else
        % MEMBRANE ENERGY (LAPLACIAN) REGULARIZATION
        %-----------------------------------------------------------------------
        IC0 = kron(kron(oz,oy),kx) + kron(kron(oz,ky),ox) + kron(kron(kz,oy),ox);
        IC0 = reg*IC0*stabilise^6;
        IC0 = [IC0*vx2(1)^2 ; IC0*vx2(2)^2 ; IC0*vx2(3)^2 ; zeros(prod(size(VG))*4,1)];
        IC0 = sparse(1:length(IC0),1:length(IC0),IC0,length(IC0),length(IC0));
end;

% Generate starting estimates.
%-----------------------------------------------------------------------
s1 = 3*prod(k);
s2 = s1 + numel(VG)*4;
T  = zeros(s2,1);
T(s1+(1:4:numel(VG)*4)) = 1;

pVar = Inf;
for iter=1:nits,
	% fprintf(' iteration %2d: ', iter);
	[Alpha,Beta,Var,fw] = spm_brainwarp(VG,VF,Affine,basX,basY,basZ,dbasX,dbasY,dbasZ,T,fwhm,VWG, VWF);
	if Var>pVar, scal = pVar/Var ; Var = pVar; else scal = 1; end;
	pVar = Var;
	T = (Alpha + IC0*scal)\(Alpha*T + Beta);
	fwhm(2) = min([fw fwhm(2)]);
	% fprintf(' FWHM = %6.4g Var = %g\n', fw,Var);
end;

% Values of the 3D-DCT - for some bizarre reason, this needs to be done
% as two seperate statements in Matlab 6.5...
%-----------------------------------------------------------------------
Tr = reshape(T(1:s1),[k 3]);
drawnow;
Tr = Tr*stabilise.^3;
return;