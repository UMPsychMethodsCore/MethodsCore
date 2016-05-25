function [Q,Vo] = spm_imcalc_ui(P,Q,f,flags,varargin)
% Perform algebraic functions on images
% hacked by Marko to exclude everything unnescessary
% and to !suppress warnings or graphical outputs!, based on
% spm_imcalc_ui 2.7 by John Ashburner, Andrew Holmes 02/09/05

% avoid display of Divide by Zero
warning off MATLAB:divideByZero

if nargin<4, flags={}; end
if nargin<3, f=''; end
if nargin<2, Q=''; end
if nargin<1, P={}; end

if isempty(P), P = spm_select(Inf,'image','Select images to work on'); end
if isempty(P), error('no input images specified'), end
if isempty(Q), Q = spm_input('Output filename',1,'s'); end
if isempty(f), f = spm_input('Evaluated Function',2,'s'); end

if length(flags)<4, hold=[]; else, hold=flags{4}; end
if isempty(hold), hold=0; end
if length(flags)<3, type=[]; else, type=flags{3}; end
if isempty(type), type=4; end, if ischar(type), type=spm_type(type); end
if length(flags)<2, mask=[]; else, mask=flags{2}; end
if isempty(mask), mask=0; end
if length(flags)<1, dmtx=[]; else, dmtx=flags{1}; end
if isempty(dmtx), dmtx=0; end

Vi = spm_vol(char(P));
if isempty(Vi), error('no input images specified'), end


if length(Vi)>1 & any(any(diff(cat(1,Vi.dim),1,1),1)&[1,1,1,0])
	disp('.'), end
if any(any(any(diff(cat(3,Vi.mat),1,3),3)))
	disp('.'), end


Qdir = spm_str_manip(Q,'Hv');
Qfil = [spm_str_manip(Q,'stv'),'.img'];
if ~exist(Qdir,'dir')
	warning('Invalid directory: writing to current directory')
	% Qdir = '.';
	Qdir = pwd;
end

% quick check where we are
  Q = spm_select('CPath',Qfil,Qdir);
  [p n e v] = spm_fileparts(Q);
  Vo = struct(	'fname',	fullfile(p, [n e]),...
		'dim',		Vi(1).dim(1:3),...
		'dt',		[type spm_platform('bigend')],...
		'mat',		Vi(1).mat,...
		'descrip',	'spm - algebra');
  args = {{dmtx,mask,hold},varargin{:}};
  Vo   = spm_imcalc(Vi,Vo,f,args{:});

% re-enable display of Divide by Zero
  warning on MATLAB:divideByZero
