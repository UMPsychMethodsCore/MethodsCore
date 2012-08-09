function mc_FixSPM(spmpath,oldpath,newpath)
% A utility function to correct the absolute paths in an SPM.mat structure
% FORMAT [result] = mc_FixSPM(spmpath,oldpath,newpath);
% 
% spmpath           The path to the directory containing the SPM.mat file
%                   to fix
%
% oldpath           The path to image files that is currently used in the
%                   SPM.mat file.
%
% newpath           The updated path to the image files.
%

[fd fn fe] = fileparts(spmpath);
if (strcmp(fe,'.mat'))
    spmpath = fd;
end

mc_GenPath(struct('Template',spmpath,'mode','check'));
mc_GenPath(struct('Template',newpath,'mode','check'));

load(fullfile(spmpath,'SPM.mat'));

if (iscell(SPM.xY.P))
    SPM.xY.P = strrep(SPM.xY.P,oldpath,newpath);
else
    tempcell = mat2cell(SPM.xY.P,ones(1,size(SPM.xY.P,1)),size(SPM.xY.P,2));
    tempcell = strrep(tempcell,oldpath,newpath);
    SPM.xY.P = cell2mat(tempcell);
end

SPM.xY.VY = spm_vol(SPM.xY.P);
SPM.swd = spmpath;

save(fullfile(spmpath,'SPM.mat'),'SPM');

return;


