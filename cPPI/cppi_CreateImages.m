function model = cppi_CreateImages(roiTC,parameters)
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
