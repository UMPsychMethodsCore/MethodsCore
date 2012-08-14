%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
spm_jobman('initcfg'); % hopefully load marsbar

for iJob = 1: size(JobList,1)
     
filename = JobList{iJob,1}; 
coordinates = JobList{iJob,2};

r=JobList{iJob,3};
OutputROIDirStruct = sturct('Template',JobList{ijob,4},...
                            'mode','makedir');

OutputROIDir       = mc_GenPath(OutputROIDirStruct);

c = coordinates;
roitype='sphere';
d = [];

display('***********************************************')
display('I am going to build an ROI in the .mat format');
display(sprintf('The ROI is is named: %s, it is located at: %s, it has radius: %s', filename, mat2str(coordinates), num2str(r)));
display(sprintf('The output will be stored here: %s', OutputROIDir));
display('***********************************************')
   

 % c = spm_input('Centre of sphere (mm)', '+1', 'e', [], 3); 
 % r = spm_input('Sphere radius (mm)', '+1', 'r', 10, 1);
d = sprintf('%0.1fmm radius sphere at [%0.1f %0.1f %0.1f]',r,c);
l = sprintf('sphere_%0.0f-%0.0f_%0.0f_%0.0f',r,c);
o = maroi_sphere(struct('centre',c,'radius',r));
  
  
roi_fname=[OutputROIDir filename '_roi']; 

%  case 'box_cw'
%   c = spm_input('Centre of box (mm)', '+1', 'e', [], 3); 
%   w = spm_input('Widths in XYZ (mm)', '+1', 'e', [], 3);
%   d = sprintf('[%0.1f %0.1f %0.1f] box at [%0.1f %0.1f %0.1f]',w,c);
%   l = sprintf('box_w-%0.0f_%0.0f_%0.0f-%0.0f_%0.0f_%0.0f',w,c);
%   o = maroi_box(struct('centre',c,'widths',w));
%  case 'box_lims'
%   X = sort(spm_input('Range in X (mm)', '+1', 'e', [], 2)); 
%   Y = sort(spm_input('Range in Y (mm)', '+1', 'e', [], 2)); 
%   Z = sort(spm_input('Range in Z (mm)', '+1', 'e', [], 2));
%   A = [X Y Z];
%   c = mean(A);
%   w = diff(A);
%   d = sprintf('box at %0.1f>X<%0.1f %0.1f>Y<%0.1f %0.1f>Z<%0.1f',A);
%   l = sprintf('box_x_%0.0f:%0.0f_y_%0.0f:%0.0f_z_%0.0f:%0.0f',A);
%   o = maroi_box(struct('centre',c,'widths',w));
%  case 'quit'
%   o = [];
% %  return
%  otherwise
%   error(['Strange ROI type: ' roitype]);
% end
% % o = descrip(o,d);
% o = label(o,l);


% %%%% maroi_sphere
%   params = [];
% myclass = 'maroi_sphere';
% defstruct = struct('centre', [0 0 0],'radius', 0);
% 
% % fill with defaults
% pparams = mars_struct('ffillmerge', defstruct, params);
% 
% % umbrella object, parse out fields for (this object and children)
% [uo, pparams] = maroi_shape(pparams);
% 
% % reparse parameters into those for this object, children
% [pparams, others] = mars_struct('split', pparams, defstruct);
% 
% % check resulting input
% if size(pparams.centre, 2) == 1
%   pparams.centre = pparams.centre';
% end
% 
% o = class(pparams, myclass, uo);


%%%% saveroi
% Label, description
%if ~any(flags=='n')
  d = descrip(o);
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
%   catch
%     warning([lasterr ' Error saving ROI to file ' roi_fname])
 end %loop over jobs

display('Done!!');
