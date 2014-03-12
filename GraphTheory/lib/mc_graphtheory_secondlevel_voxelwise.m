%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/net/data4/ADHD/';
SubFolder = '0729_voxel_eigenvector';
Network = '-1';
Metricname = 'eigenvector';

plevel = 0.05;
permlevel = 0.05;
nRep = 10000;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subject type order
% 0 -- alphabetically, control group name in the front, like 'H' and 'O'
% 1 -- alphabetically, disease group name in the front, like 'A' and 'H'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

covtype = 1;



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
NetworkParameter = '/freewill/data/ADHD/FirstLevel/SiteLinks/1018959/4mmVoxel_Censor/4mmVoxel_Censor_parameters.mat';

% NetworkParameter = '[Exp]/FirstLevel/080222rt/Grid_Censor/Grid_Censor_parameters.mat'; % OCD
ParamPathCheck = struct('Template',NetworkParameter,'mode','check');
ParamPath = mc_GenPath(ParamPathCheck);
param = load(ParamPath);

%%% Look up ROI Networks
roiMNI = param.parameters.rois.mni.coordinates;


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3D visualization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

V = spm_vol('/net/data4/ADHD/Subjects/Peking_3/1050345/session_1/rest_1/run_01/4mms8w3rarest.nii');
roiVoxels = inv(V(1).mat)*[roiMNI ones(size(roiMNI,1),1)]';
roiVoxels = round(roiVoxels(1:3,:))';
lidx = sub2ind(V(1).dim,roiVoxels(:,1),roiVoxels(:,2),roiVoxels(:,3));
Vmask = spm_vol('/net/data4/ADHD/ROIS/4mmrs_rEPI_MASK_NOEYES.img'); % ADHD
mask = spm_read_vols(Vmask);


VnewTemp = '[Exp]/GraphTheory/[SubFolder]/FirstLevel/nifti/[subjectid]/[group]_[subjectid]_[Metricname].nii';

zscoreTemp = '[Exp]/GraphTheory/[SubFolder]/FirstLevel/network-1/[Metricname]_[subjnum].mat';

ModelTemp = '/freewill/data/ADHD/UnivariateConnectomics/VoxelWise_CensorZ_ConnectomeCleaning/FixedFX.mat';
ModelCheck = struct('Template',ModelTemp,'mode','check');
ModelPath  = mc_GenPath(ModelCheck);
ModelFile  = load(ModelPath);
Names = ModelFile.master.Subject;
Types = ModelFile.master.TYPE;

namelength = 7;

    
for iSubject = 1:length(Names)
    
    group = Types{iSubject};
    id    = Names{iSubject};
    subjectid = id(1:namelength);
    
    subjnum = num2str(iSubject);
    zscorePath = mc_GenPath(struct('Template',zscoreTemp,'mode','check'));
    zscores = load(zscorePath);
    
    Vnew = V(1);
    VnewPath = mc_GenPath(struct('Template',VnewTemp,'mode','makeparentdir'));
    Vnew.fname =  VnewPath;
    Vnew.descrip = 'voxelwise eigenvector';  
   
    mtx = zeros(Vnew.dim);   
    mtx(lidx) = zscores.OutSave;
    mtx = mtx .* mask;
    spm_write_vol(Vnew,mtx);

end %subject

