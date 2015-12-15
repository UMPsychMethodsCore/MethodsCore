function [filename] = wfu_pickfile(filter,title,refDir,initialValues)
% [filename] = wfu_pickfile(filter,title,refDir,initialValues)
%
% Filters availible (any what they get):
%  image        *img|*nii
%  imageAndSpm  *img|*nii|SPM.mat
%  mat          *mat
%
% if wfu_uncompress_nifti is found, the nii.gz will be added as appropriate
%
%
%
% refDir is the directory the file picker should start at.

	if ~exist('filter','var'), filter = '*'; end
	if ~exist('title','var'), title = 'Choose a file'; end
  if ~exist('refDir','var'), refDir = pwd; end;
  if ~exist('initialValues','var'), initialValues=[]; end;
	filename=[];

  %adding custum filters here
  switch lower(filter)
    case 'image'
      if exist('wfu_uncompress_nifti.m','file')
        l_filter='^(.*\.(img|nii|nii.gz))$';
      else
        l_filter=filter;
      end
    case 'imageandspm'
      if exist('wfu_uncompress_nifti.m','file')
        l_filter='^((.*\.(img|nii|nii.gz))|SPM.mat)$';
      else
        l_filter='^((.*\.(img|nii))|SPM.mat)$';
      end
    case 'mat'
      l_filter='^.*.mat$';
    otherwise
      l_filter=filter;
  end
  if ~iscell(initialValues), initialValues={initialValues}; end;
  
  [file sts] = spm_select(1,l_filter,title,initialValues,refDir);
  if ~sts, return; end;
  filename=strtok(file,',');
	return
