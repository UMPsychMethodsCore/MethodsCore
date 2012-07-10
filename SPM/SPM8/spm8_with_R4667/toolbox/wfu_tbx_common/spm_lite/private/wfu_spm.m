function varargout = spm(varargin)
% Commands from spm.m needed in internal SPM function that are either copied or
% rewritten for use in spm_lite.
%
% See the original spm.m help for details.

% FORMAT [Modality,ModNum]=spm('CheckModality',Modality)
% Checks the specified modality against those supported, returns
% upper(Modality) and the Modality number, it's position in the list of
% supported Modalities.



%-Parameters
%-----------------------------------------------------------------------
Modalities = {'PET','FMRI','EEG'};

%-Format arguments
%-----------------------------------------------------------------------
Action='';
if nargin == 0, Action='Welcome'; else, Action = varargin{1}; end

if iscell(Action), Action=Action{1}; end;

%=======================================================================
switch lower(Action)												        %-Start command list
%=======================================================================

%=======================================================================
case 'welcome'                                   %-Set default variables
%=======================================================================
%check_installation
spm_defaults;
global defaults
if isfield(defaults,'modality'), spm(defaults.modality); return; end;

%=======================================================================
case 'checkmodality'              %-Check & canonicalise modality string
%=======================================================================
% [Modality,ModNum] = spm('CheckModality',Modality)
%-----------------------------------------------------------------------
if nargin<2, Modality=''; else, Modality=upper(varargin{2}); end
if isempty(Modality)
	global defaults
	if isfield(defaults,'modality'), Modality = defaults.modality;
	else, Modality = 'UNKNOWN'; end
end
if ischar(Modality)
	ModNum = find(ismember(Modalities,Modality));
else
	if ~any(Modality == [1:length(Modalities)])
		Modality = 'ERROR';
		ModNum   = [];
	else
		ModNum   = Modality;
		Modality = Modalities{ModNum};
	end
end

if isempty(ModNum), error('Unknown Modality'), end
varargout = {upper(Modality),ModNum};

%=======================================================================
case 'ver'                                                 %-SPM version
%=======================================================================
varargout ={'SPM8custom'};

%=======================================================================
case {'alert','alert"','alert*','alert!'}                %-Alert dialogs
%=======================================================================
if nargin<5, wait    = 0;  else, wait    = varargin{5}; end
if nargin<4, CmdLine = []; else, CmdLine = varargin{4}; end
if nargin<3, Title   = ''; else, Title   = varargin{3}; end
if nargin<2, Message = ''; else, Message = varargin{2}; end
Message = cellstr(Message);

switch(lower(Action))
case 'alert',	icon = 'none';	str = '--- ';
case 'alert"',	icon = 'help';	str = '~ - ';
case 'alert*',	icon = 'error'; str = '* - ';
case 'alert!',	icon = 'warn';	str = '! - ';
end

disp([str Message]);


varargout ={''};
%=======================================================================
case 'dir'                           %-Identify specific (SPM) directory
%=======================================================================
% spm('Dir',Mfile)
%-----------------------------------------------------------------------
if nargin<2, Mfile='spm'; else, Mfile=varargin{2}; end
SPMdir = which(Mfile);
if isempty(SPMdir)			%-Not found or full pathname given
	if exist(Mfile,'file')==2	%-Full pathname
		SPMdir = Mfile;
	else
		error(['Can''t find ',Mfile,' on MATLABPATH']);
	end
end
[SPMdir,junk] = fileparts(SPMdir);
%do this again because we (WFU) place this file in the private directory
[SPMdir,junk] = fileparts(SPMdir);

if exist('isdeployed') && isdeployed,
    ind = findstr(SPMdir,'_mcr')-1;
    [SPMdir,junk] = fileparts(SPMdir(1:ind(1)));
end;
varargout = {SPMdir};

%=======================================================================
case 'pointer'                 %-Set mouse pointer in all MatLab windows
%=======================================================================
% spm('Pointer',Pointer)
%-----------------------------------------------------------------------
if nargin<2, Pointer='Arrow'; else, Pointer=varargin{2}; end
set(get(0,'Children'),'Pointer',Pointer)
varargout ={null(1)};

%=======================================================================
case 'getglobal'                           %-Get global variable cleanly
%=======================================================================
% varargout = spm('GetGlobal',varargin)
%-----------------------------------------------------------------------
wg = who('global');
for i=1:nargin-1
    if any(strcmp(wg,varargin{i+1}))
        eval(['global ',varargin{i+1},', tmp=',varargin{i+1},';'])
        varargout{i} = tmp;
    else
        varargout{i} = [];
    end
end
if isempty(i), varargout = {null(1)}; end;

%=======================================================================
case 'defaults'                  %-Set SPM defaults (as global variable)
%=======================================================================
% spm('defaults',Modality)
%-----------------------------------------------------------------------
if nargin<2, Modality=''; else Modality=varargin{2}; end
Modality = spm('CheckModality',Modality);

%-Re-initialise, load defaults (from spm_defaults.m) and store modality
%-----------------------------------------------------------------------
clear global defaults
spm_get_defaults('modality',Modality);

%-Return defaults variable if asked
%-----------------------------------------------------------------------
if nargout, varargout = {spm_get_defaults}; end

%=======================================================================
case 'cmdline'                                  %-SPM command line mode?
%=======================================================================
% CmdLine = spm('CmdLine',CmdLine)
%-----------------------------------------------------------------------
%-Return defaults variable if asked
%-----------------------------------------------------------------------
if nargout, varargout = {true}; end


%=======================================================================
otherwise                                        %-Unknown action string
%=======================================================================
x = which('spm');
[l_path file ext junk] = fileparts(x);
error(sprintf('Unknown action string (`%s`).  It possible that %s is incorrectory listed in your path and should be removed.',Action,l_path));

%=======================================================================
end
