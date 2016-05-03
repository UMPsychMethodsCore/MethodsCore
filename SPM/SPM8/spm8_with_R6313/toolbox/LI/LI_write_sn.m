function VO = spm_write_sn(V,prm,flags,extras)
% Write Out Warped Images.
% Another stripped spm-file, to be used within the LI-toolbox;
% it is based on spm_write_sn.m	(2.17 by John Ashburner 03/03/04)
% and was modified to prepend LI_w_ instead of w to allow for
% the safe deletion of generated files; modifications
% by Marko Wilke, USE AT YOUR OWN RISK!

if ischar(prm), prm = load(prm);  end;
if ischar(V),   V   = spm_vol(V); end;

def_flags = struct('interp',1,'vox',[2 2 2],'bb',NaN,'wrap',[0 0 0],'preserve',0);
[def_flags.bb, def_flags.vox] = bbvox_from_V(prm.VG(1));

flags = def_flags;

if ~all(isfinite(flags.vox(:))), flags.vox = def_flags.vox; end;
if ~all(isfinite(flags.bb(:))),  flags.bb  = def_flags.bb;  end;

[x,y,z,mat] = get_xyzmat(prm,flags.bb,flags.vox);

if nargin==4,
	if ischar(extras) & strcmp(lower(extras),'mask'),
		VO = get_snmask(V,prm,x,y,z,flags.wrap);
		return;
	end;
	if iscell(extras),
		msk = extras;
	end;
end;

if nargout>0 & length(V)>1,
	error('Too many images to save in memory');
end;

if ~exist('msk','var')
	msk         = get_snmask(V,prm,x,y,z,flags.wrap);
end;

if nargout==0,
	if isempty(prm.Tr),
		affine_transform(V,prm,x,y,z,mat,flags,msk);
	else,
		nonlin_transform(V,prm,x,y,z,mat,flags,msk);
	end;
else,
	if isempty(prm.Tr),
		VO = affine_transform(V,prm,x,y,z,mat,flags,msk);
	else,
		VO = nonlin_transform(V,prm,x,y,z,mat,flags,msk);
	end;
end;

return;
%_______________________________________________________________________

%_______________________________________________________________________
function VO = affine_transform(V,prm,x,y,z,mat,flags,msk)

[X,Y] = ndgrid(x,y);
d     = [flags.interp*[1 1 1]' flags.wrap(:)];

spm_progress_bar('Init',prod(size(V)),'Resampling','volumes completed');
for i=1:prod(size(V)),
	VO     = make_hdr_struct(V(i),x,y,z,mat);
	detAff = det(prm.VF.mat*prm.Affine/prm.VG(1).mat);
	if flags.preserve, VO.pinfo(1:2,:) = VO.pinfo(1:2,:)/detAff; end;

	if nargout>0,
		%Dat= zeros(VO.dim(1:3));
		Dat = single(0);
		Dat(VO.dim(1),VO.dim(2),VO.dim(3)) = 0;
	else,
		VO  = spm_create_vol(VO);
	end;

	C = spm_bsplinc(V(i),d);

	for j=1:length(z),   % Cycle over planes
		[X2,Y2,Z2]  = mmult(X,Y,z(j),V(i).mat\prm.VF.mat*prm.Affine);
		dat         = spm_bsplins(C,X2,Y2,Z2,d);
		if flags.preserve, dat = dat*detAff; end;
		dat(msk{j}) = NaN;

		if nargout>0,
			Dat(:,:,j) = single(dat);
		else,
			VO = spm_write_plane(VO,dat,j);
		end;
		if prod(size(V))<5, spm_progress_bar('Set',i-1+j/length(z)); end;
	end;
	if nargout==0,
		if flags.preserve,
			VO = spm_write_vol(VO,Dat);
		else,
			VO = LI_close_vol(VO);
		end;
	else,
		VO.fname  = 'normalized.img';
		VO.pinfo  = [1 0]';
		VO.dim(4) = spm_type('float');
		VO.dat    = Dat;
	end;
	spm_progress_bar('Set',i);
end;
spm_progress_bar('Clear');
return;
 
%_______________________________________________________________________
function VO = nonlin_transform(V,prm,x,y,z,mat,flags,msk)

[X,Y] = ndgrid(x,y);
Tr = prm.Tr;
BX = spm_dctmtx(prm.VG(1).dim(1),size(Tr,1),x-1);
BY = spm_dctmtx(prm.VG(1).dim(2),size(Tr,2),y-1);
BZ = spm_dctmtx(prm.VG(1).dim(3),size(Tr,3),z-1);
if flags.preserve,
    DX = spm_dctmtx(prm.VG(1).dim(1),size(Tr,1),x-1,'diff');
    DY = spm_dctmtx(prm.VG(1).dim(2),size(Tr,2),y-1,'diff');
    DZ = spm_dctmtx(prm.VG(1).dim(3),size(Tr,3),z-1,'diff');
end;
d  = [flags.interp*[1 1 1]' flags.wrap(:)];

spm_progress_bar('Init',numel(V),'Resampling','volumes completed');
for i=1:numel(V),
    VO     = make_hdr_struct(V(i),x,y,z,mat);
    if flags.preserve
        VO.fname = prepend(VO.fname,'m');
    end
    detAff = det(prm.VF.mat*prm.Affine/prm.VG(1).mat);

    % Accumulate data
    %Dat= zeros(VO.dim(1:3));
    Dat = single(0);
    Dat(VO.dim(1),VO.dim(2),VO.dim(3)) = 0;

    C = spm_bsplinc(V(i),d);

    for j=1:length(z),   % Cycle over planes
        % Nonlinear deformations
        %----------------------------------------------------------------------------
        tx = get_2Dtrans(Tr(:,:,:,1),BZ,j);
        ty = get_2Dtrans(Tr(:,:,:,2),BZ,j);
        tz = get_2Dtrans(Tr(:,:,:,3),BZ,j);
        X1 = X    + BX*tx*BY';
        Y1 = Y    + BX*ty*BY';
        Z1 = z(j) + BX*tz*BY';

        [X2,Y2,Z2]  = mmult(X1,Y1,Z1,V(i).mat\prm.VF.mat*prm.Affine);
        dat         = spm_bsplins(C,X2,Y2,Z2,d);
        dat(msk{j}) = NaN;

        if ~flags.preserve,
            Dat(:,:,j) = single(dat);
        else
            j11 = DX*tx*BY' + 1; j12 = BX*tx*DY';     j13 = BX*get_2Dtrans(Tr(:,:,:,1),DZ,j)*BY';
            j21 = DX*ty*BY';     j22 = BX*ty*DY' + 1; j23 = BX*get_2Dtrans(Tr(:,:,:,2),DZ,j)*BY';
            j31 = DX*tz*BY';     j32 = BX*tz*DY';     j33 = BX*get_2Dtrans(Tr(:,:,:,3),DZ,j)*BY' + 1;

            % The determinant of the Jacobian reflects relative volume changes.
            %------------------------------------------------------------------
            dat       = dat .* (j11.*(j22.*j33-j23.*j32) - j21.*(j12.*j33-j13.*j32) + j31.*(j12.*j23-j13.*j22)) * detAff;
            Dat(:,:,j) = single(dat);
        end;
        if numel(V)<5, spm_progress_bar('Set',i-1+j/length(z)); end;
    end;
    if nargout==0,
        if flags.preserve, VO = rmfield(VO,'pinfo'); end
        VO = spm_write_vol(VO,Dat);
    else
        VO.pinfo  = [1 0]';
        VO.dt     = [spm_type('float32') spm_platform('bigend')];
        VO.dat    = Dat;
    end;
    spm_progress_bar('Set',i);
end;
spm_progress_bar('Clear');
return;
%_______________________________________________________________________

%_______________________________________________________________________
function VO = make_hdr_struct(V,x,y,z,mat)
VO          = V;
VO.fname    = prepend(V.fname,'LI_w_');
VO.mat      = mat;
VO.dim(1:3) = [length(x) length(y) length(z)];
VO.descrip  = ['spm - 3D normalized'];
return;
%_______________________________________________________________________

%_______________________________________________________________________
function [bb,vx] = bbvox_from_V(V)
vx = sqrt(sum(V.mat(1:3,1:3).^2));
if det(V.mat(1:3,1:3))<0, vx(1) = -vx(1); end;

o  = V.mat\[0 0 0 1]';
o  = o(1:3)';
bb = [-vx.*(o-1) ; vx.*(V.dim(1:3)-o)]; 
return;
%_______________________________________________________________________

%_______________________________________________________________________
function T2 = get_2Dtrans(T3,B,j)
d   = [size(T3) 1 1 1];
tmp = reshape(T3,d(1)*d(2),d(3));
T2  = reshape(tmp*B(j,:)',d(1),d(2));
return;
%_______________________________________________________________________

%_______________________________________________________________________
function PO = prepend(PI,pre)
[pth,nm,xt,vr] = spm_fileparts(deblank(PI));
PO             = fullfile(pwd,[pre nm xt vr]);
return;
%_______________________________________________________________________

%_______________________________________________________________________
function [X2,Y2,Z2] = mmult(X1,Y1,Z1,Mult);
if length(Z1) == 1,
	X2= Mult(1,1)*X1 + Mult(1,2)*Y1 + (Mult(1,3)*Z1 + Mult(1,4));
	Y2= Mult(2,1)*X1 + Mult(2,2)*Y1 + (Mult(2,3)*Z1 + Mult(2,4));
	Z2= Mult(3,1)*X1 + Mult(3,2)*Y1 + (Mult(3,3)*Z1 + Mult(3,4));
else,
	X2= Mult(1,1)*X1 + Mult(1,2)*Y1 + Mult(1,3)*Z1 + Mult(1,4);
	Y2= Mult(2,1)*X1 + Mult(2,2)*Y1 + Mult(2,3)*Z1 + Mult(2,4);
	Z2= Mult(3,1)*X1 + Mult(3,2)*Y1 + Mult(3,3)*Z1 + Mult(3,4);
end;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function msk = get_snmask(V,prm,x,y,z,wrap)
% Generate a mask for where there is data for all images
%-----------------------------------------------------------------------
msk = cell(length(z),1);
t1 = cat(3,V.mat);
t2 = cat(1,V.dim);
t  = [reshape(t1,[16 length(V)])' t2(:,1:3)];
Tr = prm.Tr;
[X,Y] = ndgrid(x,y);

BX = spm_dctmtx(prm.VG(1).dim(1),size(Tr,1),x-1);
BY = spm_dctmtx(prm.VG(1).dim(2),size(Tr,2),y-1);
BZ = spm_dctmtx(prm.VG(1).dim(3),size(Tr,3),z-1);

if prod(size(V))>1 & any(any(diff(t,1,1))),
	spm_progress_bar('Init',length(z),'Computing available voxels','planes completed');
	for j=1:length(z),   % Cycle over planes
		Count = zeros(length(x),length(y));
		if isempty(Tr),
			% Generate a mask for where there is data for all images
			%----------------------------------------------------------------------------
			for i=1:prod(size(V)),
				[X2,Y2,Z2] = mmult(X,Y,z(j),V(i).mat\prm.VF.mat*prm.Affine);
				Count      = Count + getmask(X2,Y2,Z2,V(i).dim(1:3),wrap);
			end;
		else,
			% Nonlinear deformations
			%----------------------------------------------------------------------------
			X1 = X    + BX*get_2Dtrans(Tr(:,:,:,1),BZ,j)*BY';
			Y1 = Y    + BX*get_2Dtrans(Tr(:,:,:,2),BZ,j)*BY';
			Z1 = z(j) + BX*get_2Dtrans(Tr(:,:,:,3),BZ,j)*BY';

			% Generate a mask for where there is data for all images
			%----------------------------------------------------------------------------
			for i=1:prod(size(V)),
				[X2,Y2,Z2] = mmult(X1,Y1,Z1,V(i).mat\prm.VF.mat*prm.Affine);
				Count      = Count + getmask(X2,Y2,Z2,V(i).dim(1:3),wrap);
			end;
		end;
		msk{j} = uint32(find(Count ~= prod(size(V))));
		spm_progress_bar('Set',j);
	end;
	 spm_progress_bar('Clear');
else,
	for j=1:length(z), msk{j} = uint32([]); end;
end;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function [x,y,z,mat] = get_xyzmat(prm,bb,vox)
% The old voxel size and origin notation is used here.
% This requires that the position and orientation
% of the template is transverse.  It would not be
% straitforward to account for templates that are
% in different orientations because the basis functions
% would no longer be seperable.  The seperable basis
% functions mean that computing the deformation field
% from the parameters is much faster.

% bb  = sort(bb);
% vox = abs(vox);

msk       = find(vox<0);
bb        = sort(bb);
bb(:,msk) = flipud(bb(:,msk));

% Adjust bounding box slightly - so it rounds to closest voxel.
bb(:,1) = round(bb(:,1)/vox(1))*vox(1);
bb(:,2) = round(bb(:,2)/vox(2))*vox(2);
bb(:,3) = round(bb(:,3)/vox(3))*vox(3);

M   = prm.VG(1).mat;
vxg = sqrt(sum(M(1:3,1:3).^2));
if det(M(1:3,1:3))<0, vxg(1) = -vxg(1); end;
ogn = M\[0 0 0 1]';
ogn = ogn(1:3)';

% Convert range into range of voxels within template image
x   = (bb(1,1):vox(1):bb(2,1))/vxg(1) + ogn(1);
y   = (bb(1,2):vox(2):bb(2,2))/vxg(2) + ogn(2);
z   = (bb(1,3):vox(3):bb(2,3))/vxg(3) + ogn(3);

og  = -vxg.*ogn;
of  = -vox.*(round(-bb(1,:)./vox)+1);
M1  = [vxg(1) 0 0 og(1) ; 0 vxg(2) 0 og(2) ; 0 0 vxg(3) og(3) ; 0 0 0 1];
M2  = [vox(1) 0 0 of(1) ; 0 vox(2) 0 of(2) ; 0 0 vox(3) of(3) ; 0 0 0 1];
mat = prm.VG(1).mat*inv(M1)*M2;

if (spm_flip_analyze_images & det(mat(1:3,1:3))>0) | (~spm_flip_analyze_images & det(mat(1:3,1:3))<0),
	Flp = [-1 0 0 (length(x)+1); 0 1 0 0; 0 0 1 0; 0 0 0 1];
	mat = mat*Flp;
	x   = flipud(x(:))';
end;
return;

