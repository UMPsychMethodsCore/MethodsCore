function mc_SetSPMDefaults(spmdefaults)
% A utility function to set SPM8 default values
% FORMAT mc_SetSPMDefaults(spmdefaults);
%
% spmdefaults        A cell array containing SPM default fields to set.
%                    For example: 
%                        spmdefaults = {
%                           'mask.thresh'  0.5;
%                           'stats.fmri.ufp'  0.05;
%                        };
%
% NOTE: At the moment this function only supports the setting of SPM
% defaults (as contained in the defaults global variable).  It does not yet
% allow setting of defaults for VBM (contained in the vbm8 global
% variable).

global defaults;

if (isempty(spmdefaults))
    return;
end

if (~iscell(spmdefaults))
    mc_Error('mc_SetSPMDefaults requires a cell array but was passed something else.  Check your spmdefaults variable.');
    return;
end

for iDefault = 1:size(spmdefaults,1)
    spm_get_defaults(spmdefaults{iDefault,1},spmdefaults{iDefault,2});
end


