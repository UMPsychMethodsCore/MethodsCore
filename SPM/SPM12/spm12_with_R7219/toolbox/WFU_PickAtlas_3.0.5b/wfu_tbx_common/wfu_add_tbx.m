function sts = wfu_add_tbx(tbx_name,forcePath)
% sts = wfu_add_tbx(tbx_name,forcePath)
%
% Add a toolbox to the matlab path.  Based off the the location of this 
% fuction.  The base path may be forced by the 'forcePath' arugment.
%
% if sts is not returned, then this function will error if the toolbox 
% cannot be found.  
% 
% Status codes are:
% 0 - Not found
% 1 - Already Found in Path
% 2 - Added to Path

if nargin < 1
  error('Toolbox name required');
end

if nargin < 2
  basePath=fileparts(fileparts(mfilename('fullpath')));
else
  if exist(forcePath,'dir')==7
    basePath=forcePath;
  else
    error('%s is not a valid directory\n',forcePath');
  end
end

% correct common "names" to actual toolbox names
switch lower(tbx_name)
  case 'pickatlas'
    tbx_name='wfu_pickatlas';
  otherwise
    %nothing to do
end

tbxPath=fullfile(basePath,tbx_name);
if exist(tbx_name,'file')==2
  sts=1;
elseif exist(tbxPath,'dir')==7
  addpath(tbxPath);
  sts=2;
else
  if nargout == 0
    error('Toolbox %s not found.\n',tbx_name);
  else
    sts = 0;
  end
end