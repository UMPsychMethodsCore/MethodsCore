function [voxelOffset varargout] = wfu_read_nifti_voxel_offset(inFile, byteType)
% [voxelOffset offsetSize additionalHeader] = wfu_read_nifti_voxel_offset(inFile, byteType)
%
% byteType is optional and defaults to 'char'.  Value should be one
% recogized by fread.
%
% 2nd and 3rd output argument are optional
%
% voxelOffset will report 0 if the the file is not a nifti file or if there
% is no offest (and no additional header).
%
% offsetSize (in bytes) of the offset header data.  Reports 0 if
% the file is not nifti.  A report of 352 indicates no additial header
% data.
%
% additional header is the value of the additional header in 'byteType'.
% It might still need cast as the appropriate type once returned, for
% example:  char(additionalHeader) to change from numerals to afnanumeric.

  voxelOffset = 0;
  offsetSize = 0;
  additionalHeader = [];
  
  if (wfu_check_nifti(inFile) > 0)
    if exist('byteType','var') ~= 1, byteType = 'char'; end;

    fid = fopen(inFile,'r','native');
    if (fid > 0)
      fseek(fid,0,'bof');
      otherendian = 0;
      sizeof_hdr 	= fread(fid,1,'int32');
      if sizeof_hdr==1543569408, % Appears to be other-endian
        % Re-open other-endian
        fclose(fid);
        if wfu_spm_platform('bigend'),
          fid = fopen(inFile,'r','ieee-le');
        else,
          fid = fopen(inFile,'r','ieee-be');
        end
      end
    end

    fseek(fid,108,'bof');
    voxelOffset = fread(fid,1,'float32');

    if voxelOffset >= 352
      offsetSize = voxelOffset - 352;
      if nargout > 2 % only read if need to
        fseek(fid,352,'bof');
        additionalHeader = fread(fid,offsetSize,byteType);
      end
    end
  end
  
  if nargout > 1
    varargout{1} = offsetSize;
  end
  if nargout > 2
    varargout{2} = additionalHeader;
  end
  