function convertToNii
gospm(5)
f=spm_select

for i=1:size(f,1)
	gospm(2)
	[path file ext junk] = fileparts(f(i,:));
	filename=[path filesep file '.nii']
	h=spm_vol(f(i,:))
	v=spm_read_vols(h);
	h.fname=filename
	if h.dim(4)==1024
		h.dt=[4 0]
	else
		h.dt=[h.dim(4) 0]
	end
	h.dim=h.dim(1:3)
	gospm(5)
	spm_write_vol(h,v)
	disp('===============================');
end

