function outFile = wfu_correct_afni_nifti(inFile)
%  modifies the outFile's header to correct DIMS like
% 45 54 45 1 10 to 45 54 45 10 1, which SPM will read as a 4D
%
  outFile = inFile;
  
  if (wfu_check_nifti(inFile) > 0)
    outFile = tempname;
    try
    	[fPath fName fExt fJunk] = fileparts(inFile);
    catch
    	[fPath fName fExt fJunk] = fileparts(inFile);
    end
    copyErrorMessage = 'Unable to copy %s to tempary file %s in wfu_correct_afni_nifti.m\n';

    if strcmpi('.img',fExt) || strcmpi('.hdr',fExt)
      [sts msg msgid] = copyfile(fullfile(fPath,[fName '.img']),[outFile '.img']);
      if sts~= 1, error(copyErrorMessage,inFile,outFile); end
      [sts msg msgid] = copyfile(fullfile(fPath,[fName '.hdr']),[outFile '.hdr']);
      if sts~= 1, error(copyErrorMessage,inFile,outFile); end
      outFile = [outFile '.hdr'];
    else
      outFile = [outFile '.nii'];
      [sts msg msgid] = copyfile(inFile,outFile);
      if sts~= 1, error(copyErrorMessage,inFile,outFile); end
    end
    
%    d = dir(outFile)
    
    byteSwapping = 0;

    fid = fopen(outFile,'r','native');
    if (fid > 0)
      fseek(fid,0,'bof');
      otherendian = 0;
      sizeof_hdr 	= fread(fid,1,'int32');
      if sizeof_hdr==1543569408, % Appears to be other-endian
        byteSwapping = 1;
      end
    end
    fclose(fid);
    
%    d = dir(outFile)
    
    %read, then correct bytes
    m = memmapfile( outFile,...
                    'Offset',40,...
                    'Format', 'int16',...
                    'Repeat', 8,...
                    'Writable',true);
    
    if byteSwapping
      dim = swapbytes(m.Data);
    else
      dim = m.Data;
    end
    
    if dim(1) == 5 && dim(5) == 1  && dim(6) > dim(5)
      disp('fixing 4th/5th dimension swap...');
      dim(1) = 4;
      dim(5) = dim(6);
      dim(6) = 1;
      if byteSwapping
        m.Data = swapbytes(dim);
      else
        m.Data = dim;
      end
    else
      outFile = inFile;  %reset to normalwf
    end
    
    clear m;

%    d = dir(outFile)

  end
  
  
return
  
