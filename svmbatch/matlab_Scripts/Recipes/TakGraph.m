%% Get paths loaded up

mcRoot = '~/users/kesslerd/repos/MethodsCore/';

addpath(genpath([mcRoot 'matlabScripts']));
addpath(genpath([mcRoot 'svmbatch/matlab_Scripts/']));

%% Load dataset


% data - nExample x nFeat matrix of features

SubjDir = {
'5001',[1 2];
'5002',[1 2];
'5003',[1 2];
'5004',[1 2];
'5005',[1 2];
'5010',[1 2];
'5012',[1 2];
'5014',[1 2];
'5015',[1 2];
'5016',[1 2];
'5017',[1 2];
'5018',[1 2];
'5019',[1 2];
'5020',[1 2];
'5021',[1 2];
'5023',[1 2];
'5024',[1 2];
'5025',[1 2];
'5026',[1 2];
'5028',[1 2];
'5029',[1 2];
'5031',[1 2];
'5032',[1 2];
'5034',[1 2];
'5035',[1 2];
'5036',[1 2];
'5037',[1 2];
'5038',[1 2];
'5039',[1 2];
'5040',[1 2];
'5041',[1 2];
'5042',[1 2];
       };

FileTemplate = '/net/data4/MAS_Resting/Firstlevel/[Subject]/[Run]/12mmGrid_19_corr.mat';

ParamFile='/net/data4/MAS_Resting/Firstlevel/5001/Tx1/12mmGrid_19_parameters.mat';

RunDir= {
    'Tx1'
    'Tx2'
} ;

[data,SubjAvail]=mc_load_connectomes_paired(SubjDir,FileTemplate,RunDir);


%% Clean dataset

[data_clean, censor]=mc_connectome_clean(data);

%% Calculate deltas

[data_delta, label, SubjIDs,ContrastAvail] = mc_calc_deltas_paired(data_clean,SubjAvail,[1 -1]);


%% Calculate aggregate discriminative power of edges

discrim=mc_calc_discrim_power_paired(data_delta,label,'fracfit');

% subset matrix on discrim power

[discrim_subset  keepID] = mc_bigsmall(discrim,5000,3);

%% Array in square matrix

discrim_subset_square = mc_unflatten_upper_triangle(discrim_subset);

discrim_square = mc_unflatten_upper_triangle(discrim);

% Make symmetric, but leave diagonal alone

discrim_subset_square = discrim_subset_square + discrim_subset_square';
discrim_square = discrim_square + discrim_square';

% add diagonal

for idiag=1:size(discrim_subset_square,1)
    discrim_subset_square(idiag,idiag)=1;
    discrim_square(idiag,idiag)=1;
end


%% Permute edges to follow labels

% Load ROI file

parameters=load(ParamFile);

roiMNI=parameters.parameters.rois.mni.coordinates;

% Retrieve labels

roiMNI_labels = mc_network_lookup('/net/data4/MAS/ROIS/Yeo/YeoPlus.hdr',roiMNI);

% round labels
roiMNI_labels(:,4)=round(roiMNI_labels(:,4));

% Sort ROIs on labels, return idx

[B, sortIDX]= sort(roiMNI_labels(:,4));


% Sort square matrix on idx
discrim_subset_square_networksort = discrim_subset_square(sortIDX,sortIDX);
discrim_square_networksort=discrim_square(sortIDX,sortIDX);


%% Make heatmap

% make support

discrim__subset_square_networksort_support = discrim_subset_square_networksort~=0;

imagesc(discrim__subset_square_networksort_support==0);colormap(gray)

%% Make heatmap of all discrim power


%% Add overlay to heatmap

hold on

% figure out jump points in labels

jumps=diff(B);

jumps=[jumps];

starts=[1 ;find(jumps)];
stops=[find(jumps) - 1; size(B,1)];


for iBox=1:size(starts)
    mc_draw_box(starts(iBox),starts(iBox),stops(iBox),stops(iBox));
end
