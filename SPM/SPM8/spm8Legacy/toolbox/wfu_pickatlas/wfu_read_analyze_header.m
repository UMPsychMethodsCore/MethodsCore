function [aheader , volumein] = wfu_read_analyze_header(filename)

%-------------------------
%WIll read analyze images
%-------------------------

%---------------------------------------------------
%Try using big-endian first, check headersize later
%---------------------------------------------------
mf = 'ieee-be';


%------------------------------------
%Check on filename
%------------------------------------

if ~exist('filename','var')
	[fname pathname] = uigetfile('*.img', 'choose an analyze type file');
	filename = [pathname,fname]
end

if isempty(filename) | filename(1) == 0
	volumein=[];
	aheader=[];	
	return
end

headerfile = [filename(1: end-4) '.hdr'];
imagefile = [filename(1:end-4) '.img'];

%----------------------------
%Construct the analyze header
%----------------------------
aheader = wfu_make_analyze_header;			
fid = fopen(headerfile, 'r', mf);
aheader = wfu_structread(fid,aheader);
fclose (fid);

%----------------------------------------------------------------------
%Check if endian is OK
%-----------------------------------------------------------------------
if aheader.sizeof_hdr.value ~= 348 
	mf = 'ieee-le';
	fid = fopen(headerfile, 'r', mf);
	aheader = wfu_structread(fid, aheader);
	fclose (fid);
end


xsize = aheader.x_dim.value;
ysize = aheader.y_dim.value;
zsize = aheader.z_dim.value;
tsize = aheader.t_dim.value;
datatype = aheader.datatype.value;
type=char(wfu_datatype2name(datatype));

fid = fopen(imagefile, 'r', mf);
volumein = wfu_volumeread(fid, type, xsize, ysize,zsize, tsize);
fclose(fid);
 
if aheader.scale.value < 1e-50
    aheader.scale.value = 0;
end

%aheader.scale.value = not(float(aheader.scale.value)) + aheader.scale.value
%----------------------------------------------------------------------
%If the image has a scale factor then we must convert the intensities
%and update the data field types appropriately so idl to matlab conversions
%are handled properly, and set the scale back to 1.0 since we
%have converted it to float
%-----------------------------------------------------------------------
if aheader.scale.value ~= 1
	scale = aheader.scale.value;
	factor = 1;
   
   if scale < 1e-5
		scale = double(scale);
		factor = 2;
   end
   
   volumein = volumein * scale;
	aheader.datatype.value = 16 * factor;
	aheader.bits.value = 32 * factor;
	aheader.scale.value = 1.0;
end
%-------------------------------------------------------------------------------
%Insert the talairach transform 
%correct the transform for matlab coordinate system if acquired in IDL
%For now we will not implement this and assume everything was written in matlab
%--------------------------------------------------------------------------------
idl_correct = 1;
idl_correct = 0;
if sum(findstr(upper(char(aheader.descrip.value)'),'SPM')) > 0
    idl_correct = 0.0;
end

mt = zeros(4,4);
mtb = eye(4);
mtb(1:3,4) = -1;
vox_sizes = [aheader.x_size.value aheader.y_size.value aheader.z_size.value];

for i = 1:3
    mt(i,i) = vox_sizes(i);
end

%-------------------------------------------
%Fill the origin field if not already there
%Correct for matlab coordinate system
%-------------------------------------------
if sum(aheader.orig.value) == 0
    aheader.orig.value = [aheader.x_dim.value aheader.y_dim.value aheader.z_dim.value 0]/2 + 1;
end

%-------------------------------------
%Compute talairach space origin
%-------------------------------------
for i = 1:3
    tal_orig(i) = -(aheader.orig.value(i) + idl_correct)*vox_sizes(i);
end

%--------------------------------------
%Generate talairach affine transform
%--------------------------------------
mt(1:3,4) = tal_orig';
mt(4,4) = 1;

%--------------------------------------------------
%To get tal coords from matlab coords and mt use
%talcoords=mt*coord'
%--------------------------------------------------

%----------------------------------------
%Insert transform if not already present
%----------------------------------------
if sum(sum(aheader.magnet_transform.value)) == 0
	aheader.magnet_transform.value = mt;
else 
	%------------------------------------
	%correct for idl coordinate system if there is a magnet_transform
	%------------------------------------
	if aheader.magnet_transform.value(1:3,4) == [-90 -126 -72]' 
		aheader.magnet_transform.value = aheader.magnet_transform.value * mtb;
	end
end

%---------------------------------------------------
%Set the landmark to indicate this is normalized
%---------------------------------------------------
if aheader.landmark.value == 0
    aheader.landmark.value = 1;
end

if (aheader.orient.value == 0 & aheader.landmark.value == 1)
    aheader.orient.value = 1;
end

