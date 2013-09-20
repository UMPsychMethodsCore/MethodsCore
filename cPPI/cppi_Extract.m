function [cppi_grid result] = cppi_Extract(cppiregressors,model,parameters,cppi_grid,iROI,roiTC)
%cppi_grid - {B}[N x N]
%            B = # of beta images
%            N = # of ROIs

%read beta images that were output by model
%save beta values into cell array grid
%need to skip/exclude betas from motion and run effects
result = 0;

P = spm_select('FPList',model,'beta.*img');
numimages = size(P,1);
Pt = spm_select('FPList',model,'spmT.*img');
numt = size(Pt,1);

load(fullfile(model,'SPM.mat'));
reg = [];
maxTP = 0;
for iRun = 1:size(SPM.Sess,2)
    if (size(SPM.Sess(iRun).C.C,1) > maxTP)
        maxTP = size(SPM.Sess(iRun).C.C,1);
    end
end

for iRun = 1:size(SPM.Sess,2)
    add = [];
    if (size(SPM.Sess(iRun).C.C,1) < maxTP)
        add = NaN*zeros(maxTP-size(SPM.Sess(iRun).C.C,1),size(SPM.Sess(iRun).C.C,2));
    end
    reg = [reg [SPM.Sess(iRun).C.C;add]];
end

%nummotion = size(parameters.data.run(1).MotionParameters,2);
nummotion = size([parameters.data.run(:).MotionParameters],2);
domotion = parameters.cppi.domotion;
numrun = size(parameters.data.run,2);
numregressors = size(cppiregressors,2);
%domotion = 1;
if (numimages ~= (numrun + (numrun*numregressors) + (domotion*nummotion)))
    mc_Error('There are an inconsistent number of beta images and regressors.');
end
if (numimages ~= numt)
    mc_Error('There are an unequal number of beta images and T images');
end

goodbeta = [];
for iRun = 1:size(SPM.Sess,2)
    goodbeta = [goodbeta ones(1,numregressors) zeros(1,domotion*size(parameters.data.run(iRun).MotionParameters,2))];
end

%goodbeta = repmat([ones(1,numregressors) zeros(1,domotion*nummotion)],1,numrun);
index = 1;
for iB = 1:size(goodbeta,2)
    %extract beta iB and place in grid
    %goodbeta(iB) = 1;
    if (~goodbeta(iB))
        continue;
    end
    V = spm_vol(P(iB,:));
    Vt = spm_vol(Pt(iB,:));
    data = spm_read_vols(V);
    datat = spm_read_vols(Vt);
    cppi_grid{2,index}(iROI,:) = data';
    cppi_grid{3,index}(iROI,:) = datat';
    
    if (parameters.cppi.StandardizeBetas)
        temp = reg(:,iB);
        sx = std(temp(~isnan(temp)));
        sy = std(roiTC);
        cppi_grid{4,index}(iROI,:) = data' .* (sx./sy);
    end
    index = index + 1;
end
result = 1;
