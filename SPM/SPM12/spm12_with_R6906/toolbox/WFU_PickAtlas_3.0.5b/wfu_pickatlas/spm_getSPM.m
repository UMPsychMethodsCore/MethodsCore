function [SPM,xSPM] = spm_getSPM(varargin)
% wrapper to wfu_spm_getSPM
  spmVer=wfu_get_ver();
  if strcmpi(spmVer,'SPM8')
    [SPM xSPM] = wfu_spm_getSPM8(varargin{:});
  elseif strcmpi(spmVer,'SPM12')
    [SPM xSPM] = wfu_spm_getSPM12(varargin{:});
  else
    error('Unknown SPM version: %s',spmVer);
  end
return