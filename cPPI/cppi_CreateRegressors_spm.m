function [regressors betanames] = cppi_CreateRegressors_spm(coords,parameters,roiTC)

% clear jobs
% jobs{1}.stats{1}.results.spmmat = cellstr(parameters.cppi.SPM);
% jobs{1}.stats{1}.results.conspec(1).titlestr = 'EOI';
% jobs{1}.stats{1}.results.conspec(1).contrasts = 1;
% jobs{1}.stats{1}.results.conspec(1).threshdesc = 'none';
% jobs{1}.stats{1}.results.conspec(1).thresh = 1;
% jobs{1}.stats{1}.results.conspec(1).extent = 0;
% jobs{1}.stats{1}.results.print = 0;
% spm_jobman('run',jobs);
[a b c d] = fileparts(parameters.cppi.SPM);

xSPM.swd = a;
xSPM.title = 'EOI';
xSPM.Ic = 1;
xSPM.u = 0.99;
xSPM.k = 0;
xSPM.thresDesc = 'none';
xSPM.Im = [];
[hReg,xSPM,SPM] = spm_results_ui('Setup',xSPM);

xY.xyz  = spm_mip_ui('SetCoords',coords);
xY.name = 'test';
xY.Ic   = 0;
xY.Sess = 1;
xY.def  = 'sphere';
xY.spec = 0;
%xSPM = evalin('base',xSPM);
%SPM = evalin('base',SPM);
%hReg = evalin('base',hReg);
[Y,xY]  = spm_regions(xSPM,SPM,hReg,xY);

PPI1 = spm_peb_ppi(parameters.cppi.SPM,'ppi',xY,[1 1 1],'task1',0);
PPI2 = spm_peb_ppi(parameters.cppi.SPM,'ppi',xY,[2 1 1],'task2',0);

betanames = {'task1','task2','ppi1','ppi2','y'};
regressors = [PPI1.P PPI2.P PPI1.ppi PPI2.ppi PPI1.Y];