function returnValue = wfu_check_nifti(filename)
% returnValue = check_if_nifti(filename)
%
% Checks to see if a filename is NIFTI or ANALYZE
%	Returns:
% 1  - NIFTI
% 0  - ANALYZE
% -1 - NOT AN IMAGE FILE
%

	possibility = 0;
	returnValue = -1;
	try
		[filePath fileBase fileExt junk] = fileparts(filename);
	catch
		[filePath fileBase fileExt junk] = fileparts(filename);
	end
	switch lower(fileExt)
		case{'.nii'}
			possibility = 1;
		case{'.gz'}
			if (regexpi(fileBase,'.*nii$'))
			possibility = 1;
			end;
		case{'.img'}
			filename=fullfile(filePath,[fileBase '.hdr']);
			possibility = 1;
		case{'.hdr'}
			possibility = 1;
	end
	
%	disp(sprintf('Checking: %s',filename));

	if (possibility)
		fid = fopen(filename,'r','native');
		if (fid > 0)
			fseek(fid,0,'bof');
			otherendian = 0;
			sizeof_hdr 	= fread(fid,1,'int32');
			if sizeof_hdr==1543569408, % Appears to be other-endian
				% Re-open other-endian
				fclose(fid);
				if wfu_spm_platform('bigend'),
					fid = fopen(filename,'r','ieee-le');
				else,
					fid = fopen(filename,'r','ieee-be');
				end;
			end;
	
			fseek(fid,0,'bof');
			sizeof_hdr = fread(fid,1,'int32');
			
			if(sizeof_hdr==348)  %first check.  NIFTI and ANALYZE should start with the value of 348
				fseek(fid,344,'bof');
				a = fread(fid,4,'int8');
				b = char(a');
				
				% uint8 representation of ni1\0 or n+1\0
				if (isequal(a',[110 105 49 0]) || (isequal(a',[110 43 49 0])))  
					returnValue = 1;
				else
					returnValue = 0;
				end
			else
				returnValue = -1;
			end
		end
	end
end
