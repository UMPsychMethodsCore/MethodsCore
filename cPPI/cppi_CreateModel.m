function model = cppi_CreateModel(cppiregressors,roiTC,parameters)
model = -1;
curpath = pwd;

mc_GenPath(struct('Template',parameters.cppi.sandbox,'mode','makedir'));
cd(parameters.cppi.sandbox);

Vtemplate.fname = fullfile(parameters.cppi.sandbox,'roiTC');
Vtemplate.mat = spm_matrix([0 0 0 0 0 0 1 1 1 0 0 0]);
Vtemplate.dim = [parameters.rois.nroisRequested 1 1];
Vtemplate.dt = [4 0];
Vtemplate.descrip = '';
%create dummy images consisting of roiTC

FDTC = zeros(size(roiTC,2),1,1,size(roiTC,1));
FDTC(:,1,1,:) = roiTC';

V(1:size(roiTC,1)) = Vtemplate;
for iV = 1:size(V,2)
    V(iV).fname = sprintf('%s_%04d.img',V(iV).fname,iV);
    spm_write_vol(V(iV),FDTC(:,:,:,iV));
end

Vmask = Vtemplate;
Vmask.fname = sprintf('%s_mask.img',Vtemplate.fname);
spm_write_vol(Vmask,ones(size(roiTC,2),1,1));

%enter these dummy images into an SPM model with the cppi regressors
offset = 0;
for iRun = 1:size(parameters.data.run,2)
    SPM.Sess(iRun).U = [];
    if (parameters.cppi.domotion)
        SPM.Sess(iRun).C.C = [cppiregressors(offset+1:offset+parameters.data.run(iRun).nTimeAnalyzed,:) parameters.data.run(iRun).MotionParameters];
    else
        SPM.Sess(iRun).C.C = [cppiregressors(offset+1:offset+parameters.data.run(iRun).nTimeAnalyzed,:)];
    end
    SPM.Sess(iRun).C.name = repmat({'reg'},1,size(cppiregressors,2) + (parameters.cppi.domotion * size(parameters.data.run(iRun).MotionParameters,2)));
    offset = offset + parameters.data.run(iRun).nTimeAnalyzed;
end
SPM.xY.P = spm_select('ExtFPList',parameters.cppi.sandbox,'roiTC_0.*',[1:size(roiTC,1)]);
SPM.nscan = parameters.cppi.NumScan;
SPM.xBF.name       	= 'hrf';
SPM.xBF.length     	= 32;   
SPM.xBF.order      	= 1;   
SPM.xBF.T          	= 16;   
SPM.xBF.T0         	= 1;    
SPM.xBF.UNITS      	= 'secs';         
SPM.xBF.Volterra   	= 1;              
SPM.xGX.iGXcalc    = 'None';
SPM.xX.K.HParam  = 128; 
SPM.xVi.form = 'AR(0.2)';
SPM.xY.RT = parameters.TIME.run(1).TR;
SPM.xM.VM = Vmask;
global defaults
defaults.mask.thresh = -Inf;
SPM = spm_fmri_spm_ui(SPM);
SPM = spm_spm(SPM); 

%return path to model when finished
model = pwd;
cd(curpath);

return;
