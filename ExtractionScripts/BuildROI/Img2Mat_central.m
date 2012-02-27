%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath /net/dysthymia/spm8/
 addpath('/net/data4/MAS/marsbar-0.42/')
addpath /net/dysthymia/slab/users/sripada/repos/matlabScripts %%%% this is for generate_path_CSS
%addpath('/net/dysthymia/matlabScripts/') %%% for generate path

 


 for iJob = 1: size(JobList,1)
     
     JobType = JobList{iJob,1}


InputROIDir = eval(generate_PathCommand(JobList{iJob,1}))
OutputROIDir = eval(generate_PathCommand(JobList{iJob,2}))
imgname = [InputROIDir JobList{iJob,3}];  
roitype='image';


o = [];  



display('***********************************************')
display('I am going to convert a .img ROI to the .mat format');
display(sprintf('The .img ROI is is named: %s, it is located here: %s', imgname, InputROIDir));
display(sprintf('The output will be stored here: %s', OutputROIDir));
display('***********************************************')



     
     
     
  
  [p f e] = fileparts(imgname);
%  binf = spm_input('Maintain as binary image', '+1','b',...
%				      ['Yes|No'], [1 0],1);
binf=1;
  func = '';
%   if spm_input('Apply function to image', '+1','b',...
% 				      ['Yes|No'], [1 0],1);
%     spm_input('img < 30',1,'d','Example function:');
%     func = spm_input('Function to apply to image', '+1', 's', 'img');
%   end
  d = f; l = f;
  if ~isempty(func)
    d = [d ' func: ' func];
    l = [l '_f_' func];
  end
  if binf
    d = [d ' - binarized'];
    l = [l '_bin'];
  end
  o = maroi_image(struct('vol', spm_vol(imgname), 'binarize',binf,...
			 'func', func));
  
  % convert to matrix format to avoid delicacies of image format
  o = maroi_matrix(o);
  
  roi_fname=[OutputROIDir f '_roi'];
  o = descrip(o,d);
  l = label(o);
  o = label(o,l);
%end

%fn = source(o);
%fn='037';
% if isempty(fn) | any(flags=='l')
%   fn = maroi('filename', mars_utils('str2fname', label(o)));
% end

% f_f = ['*' maroi('classdata', 'fileend')];
% [f p] = mars_uifile('put', ...
% 		    {f_f, ['ROI files (' f_f ')']},...
% 		    'File name for ROI', fn);
% if any(f~=0)
%   roi_fname = maroi('filename', fullfile(p, f));
%   try

%roi_fname=[OutputROIDir filename '_roi'];
    varargout = {saveroi(o, roi_fname)};
 end
 
 display('Done!!!');
 