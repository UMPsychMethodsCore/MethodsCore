function wfu_write_analyze_header(volumein, aheader, outfilename,mat,M)

%---------------------------------------------------------------------------
%Writes analyze file and header
%This will always write in big-endian format
%if datatype is not sent, data will be written in the datatype of volumein
%---------------------------------------------------------------------------


hdrfilename=[outfilename,'.hdr'];
imgfilename=[outfilename,'.img'];

%[pth,nm,xt,vr] = fileparts(deblank(PI));
%xdim = size(volumein,1); 
%ydim = size(volumein,2); 
%zdim = size(volumein,3);
%tdim = 1;

if ndims(volumein) == 4 
   tdim =  size(volumein, 4);
end


%--------------------------------------------------------
%adjust datatype and bit-depth for volume to be written
%--------------------------------------------------------
if nargin < 6
    [datatype,dataname,bitdepth] = wfu_datatype(volumein);
end


aheader.datatype.value = datatype;
aheader.bits.value = wfu_spm_type(datatype,'bits');
maxval=wfu_spm_type(datatype,'maxval');
minval=wfu_spm_type(datatype,'minval');

aheader.glmax.value = maxval;
aheader.glmin.value = minval;

%------------------------------------------
%write analyze header in big-endian format
%------------------------------------------
mf = 'ieee-be';
fid = fopen(hdrfilename,'w',mf);
wfu_structwrite(fid, aheader);		
fclose(fid);

fid = fopen(imgfilename,'w',mf);
wfu_volumewrite(fid ,volumein, wfu_spm_type(datatype));
fclose(fid);

%*********************************************************
%write a .mat file with magnet_transform and landmark info
%*********************************************************
landmark = 1;
if exist('mat')
	matFilename = [outfilename,'.mat'];
	if ~exist('M'), M = mat; end
	save(matFilename,'M','mat','landmark');
end

return;
