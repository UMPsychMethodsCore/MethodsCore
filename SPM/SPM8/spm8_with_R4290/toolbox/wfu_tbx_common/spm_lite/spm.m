function varargout = spm(varargin)
% THIS IS A WRAPPER FUNCTION FOR private/wfu_spm.m
%
% private/wfu_spm.m is a HEAVILY MODIFIED version of spm.m
%

switch nargout
  case 0
    wfu_spm(varargin{:});
  case 1
    varargout{1} = wfu_spm(varargin{:});
  case 2
    [varargout{1} varargout{2}]= wfu_spm(varargin{:});
  case 3
    [varargout{1} varargout{2} varargout{3}]= wfu_spm(varargin{:});
  otherwise
    error('Need modified spm.m with %d outputs',nargout);
end
  