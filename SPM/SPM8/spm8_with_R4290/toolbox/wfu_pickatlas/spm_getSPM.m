function [SPM,xSPM] = spm_getSPM(varargin)
% wrapper to wfu_spm_getSPM
  [SPM xSPM] = wfu_spm_getSPM(varargin{:});
return