%
% Borrowed from Luis Hernandez
%
% Robert Welsh
% 2011
%


function [d, hdr]= SOM_read_nii_img(name)
%function [d [,hdr] ] = read_nii_img(name)
[path root suffix] = fileparts(name);

if strcmp(suffix,'.gz')
    fprintf('\n Unzipping ...%s', name);
    eval(['!gunzip ' name]);
    hdr = SOM_read_nii_hdr(name);
    
elseif strcmp(suffix,'.nii')
    name = name;
    hdr = SOM_read_nii_hdr(name);

elseif strcmp(suffix,'.img')
    [d hdr] = read_img(name);
    hdr = avw2nii_hdr(hdr);
    return
end

[pFile,messg] = fopen(name, 'r','native');
if pFile == -1
      fprintf('Error opening header file: %s',name); 
      fprintf('\n%s',messg); 
      return;
end

endian = SOM_img_endian(name);
[pFile,messg] = fopen(name, 'r',endian);

fseek(pFile, hdr.vox_offset, 'bof');

xdim = hdr.dim(2);
ydim = hdr.dim(3);
zdim = hdr.dim(4);
tdim = hdr.dim(5);


switch hdr.datatype     
    case 0
        fmt = 'uint8';
    case 2
        fmt = 'uint8';
    case 4
        fmt = 'short';
    case 8
        fmt = 'int';
    case 16
        fmt = 'float';
    case 32
        fmt = 'float';
        xdim = hdr.xdim * 2;
        ydim = hdr.ydim * 2;
    case 64
        fmt = 'int64';    
    otherwise
        errormesg(sprintf('Data Type %d Unsupported. Aborting',hdr.datatype));
        return
        
end



% Read in data.
d = (fread(pFile,[xdim*ydim*zdim*tdim], fmt))'; 	
if tdim >=2
    d = reshape(d, xdim*ydim*zdim, tdim);
    d=d';
else
    d = reshape(d, [xdim ydim zdim]); 
end
fclose(pFile);

if strcmp(suffix,'.gz')
    fprintf('\n Done reading file.  Re-zipping ...%s\n', name);
    eval(['!gzip ' root]);
end

if nargout == 2
	varargout(1) = {hdr};
end

return

