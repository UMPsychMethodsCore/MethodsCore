%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/net/data4/slab_OCD/';
SubFolder = '0626';
Network = '-1';
Metric = 'degree';

plevel = 0.05;
permlevel = 0.05;
nRep = 10000;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subject type order
% 0 -- alphabetically, control group name in the front, like 'H' and 'O'
% 1 -- alphabetically, disease group name in the front, like 'A' and 'H'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

covtype = 0;



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FLTemplate = '[Exp]/GraphTheory/[SubFolder]/FirstLevel/network[Network]/[Metric].mat';
FLPath     = mc_GenPath(struct('Template',FLTemplate,...
    'suffix','.mat',...
    'mode','check'));
Flfile     = load(FLPath);
Fldata     = Flfile.SaveData;

nROI = size(Fldata,2);
nSub = size(Fldata,1);

TypeTemplate = '[Exp]/GraphTheory/[SubFolder]/FirstLevel/type.mat';
TypePath     = mc_GenPath(struct('Template',TypeTemplate,...
    'suffix','.mat',...
    'mode','check'));
Typefile     = load(TypePath);
Type         = Typefile.types;

unitype = unique(Type);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% t-test for each ROI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmark    = zeros(1,nROI);
meandiff = zeros(1,nROI);
p        = zeros(1,nROI);
t        = zeros(1,nROI);
for iCol = 1:nROI
    testmetric = Fldata(:,iCol);
    if covtype % like 'A' and 'H'
        testhc = testmetric(Type==unitype(2));
        testds = testmetric(Type==unitype(1));
    else % like 'O' and 'H'
        testhc = testmetric(Type==unitype(1));
        testds = testmetric(Type==unitype(2));
    end 
    meanhc = mean(testhc);
    meands = mean(testds);
    meandiff(iCol) = meanhc - meands;
    [~,pval,~,tval]=ttest2(testds,testhc);  % Direction is Disease vs. Control
    if pval<plevel
        tmark(iCol)=1;
    end
    p(iCol) = pval;
    t(iCol) = tval.tstat;
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% permutation test for each ROI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
perm = zeros(nRep,nROI);
permmark = zeros(1,nROI);

for n = 1:nRep
    fprintf(1,'%g\n',n);
    ind = randperm(length(Type));
    permLabel = Type(ind);
    for iCol = 1:nROI
        testmetric = Fldata(:,iCol);
        if covtype % like 'A' and 'H'
            testhc = testmetric(permLabel==unitype(2));
            testds = testmetric(permLabel==unitype(1));
        else
            testhc = testmetric(permLabel==unitype(1));
            testds = testmetric(permLabel==unitype(2));
        end
        meanhc = mean(testhc);
        meands = mean(testds);
        perm(n,iCol) = meanhc - meands;
        
    end
end

for iCol = 1:nROI
    vector = sort(perm(:,iCol),'descend');
    N      = length(vector);
    pos    = floor(permlevel*N)+1;
    if abs(meandiff(iCol))>abs(vector(pos))
        permmark(iCol)=1;
    end
end


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get mni coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NetworkParameter = '[Exp]/FirstLevel/SiteCatLinks/1018959/1166rois_Censor/1166rois_Censor_parameters.mat';  % ADHD
NetworkParameter = '[Exp]/FirstLevel/080222rt/Grid_Censor/Grid_Censor_parameters.mat'; % OCD
ParamPathCheck = struct('Template',NetworkParameter,'mode','check');
ParamPath = mc_GenPath(ParamPathCheck);
param = load(ParamPath);

%%% Look up ROI Networks
roiMNI = param.parameters.rois.mni.coordinates;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3D visualization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% V = spm_vol('/net/data4/ADHD/Subjects/Peking_3/1050345/session_1/rest_1/run_01/s8w3rarest.nii');
V = spm_vol('/net/data4/slab_OCD/Subjects_yanni_20120508/080222rt/func/run_01/swrarun_01.nii');
Vnew = V(1);

VnewTemp = '[Exp]/GraphTheory/[SubFolder]/3dmap/[Metric].nii';
VnewPath = mc_GenPath(struct('Template',VnewTemp,'mode','makeparentdir'));

Vnew.fname =  VnewPath;
% Vnew.descrip = 'SPM{T_[419.0]} - T-test';  % ADHD
Vnew.descrip = 'SPM{T_[88.0]} - T-test';

mtx = zeros(Vnew.dim + [2 2 2]);   % Expand the area to leave space for sphere padding

roiVoxels = inv(Vnew.mat)*[roiMNI ones(size(roiMNI,1),1)]';

roiVoxels = round(roiVoxels(1:3,:)+1)';    % Because of the expanding, need to shift the voxel coords by 1

mysphere = SOM_MakeSphereROI(1.45);


for iVox = 1:size(roiVoxels,1)
    mtx(roiVoxels(iVox,1),roiVoxels(iVox,2),roiVoxels(iVox,3)) = t(iVox);
    offsets = repmat(roiVoxels(iVox,:)',1,19) + mysphere;
    for jVox = 1:19
        mtx(offsets(1,jVox),offsets(2,jVox),offsets(3,jVox)) = t(iVox);
    end   
end

mtx = mtx(2:end-1,2:end-1,2:end-1);

% Vmask = spm_vol('/net/data4/ADHD/Subjects/Peking_1/ROIS/rs_rEPI_MASK_NOEYES.img'); % ADHD
Vmask = spm_vol('/net/data4/slab_OCD/ROIS/rEPI_MASK_NOEYES_restspace.img'); % OCD
mask = spm_read_vols(Vmask);

mtx = mtx .* mask;

spm_write_vol(Vnew,mtx);

    