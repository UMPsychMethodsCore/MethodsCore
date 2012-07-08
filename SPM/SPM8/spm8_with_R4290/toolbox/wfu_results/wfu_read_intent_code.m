function [intentCode varargout] = wfu_read_intent_code(inFile)
% [intentCode intentParameters] = wfu_read_intent_code(inFile)
%
% reads the intent code (byte 68, short[int16]) and additionally the
% intent parameters (byte 56, float[float32] x 3)

%default output
intentCode = [];
varargout{1} = null(1);



if (wfu_check_nifti(inFile))
  intentCode = [];
  varargout{1} = null(1);
 
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
  
  fseek(fid,68,'bof');
  intentCode = fread(fid,1,'int16');
  
  fseek(fid,56,'bof');
  ip = fread(fid,3,'float32');
  if ~isequal(ip,zeros(3,1))
    varargout{1} = ip;
  end

end

return