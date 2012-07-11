function varargout = spm_figure(varargin)
	%command needed from spm, but serves no use in "lite" code
	%created to preserve native spm function calls without errors

  for i=1:nargout
    varargout{i} = null(1);
  end
return
