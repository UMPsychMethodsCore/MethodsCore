function cg_spm8_batch(batchname)
% wrapper for using spm8 batch mode (see cg_vbm8_batch.sh)
%_______________________________________________________________________
% $Id: cg_spm8_batch.m 285 2010-02-18 08:27:29Z gaser $

if nargin < 1
	fprintf('Syntax: cg_spm8_batch(batchname)\n');
	exit
end

spm_defaults
global defaults

if ~exist(batchname,'file')
	fprintf('Batchfile %s not found\n',batchname);
	exit
end

eval(batchname)

if ~exist('matlabbatch','var')
	fprintf('Batchfile %s did not returned variable matlabbatch.\n', batchname);
	exit
end

spm_jobman('initcfg');
spm_jobman('run_nogui',matlabbatch)

exit