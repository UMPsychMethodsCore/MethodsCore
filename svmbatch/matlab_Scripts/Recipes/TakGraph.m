%% Get paths loaded up

mcRoot = '~/users/kesslerd/repos/MethodsCore/';

addpath(genpath([mcRoot 'matlabScripts']));
addpath(genpath([mcRoot 'svmbatch/matlab_Scripts/']));

%% Load dataset


% data - nExample x nFeat matrix of features

SubjDir = {
'HC01',[1 2];
'HC02',[1 2];
'HC03',[1 2];
'HC05',[1 2];
'HC06',[1 2];
'HC07',[1 2];
'HC08',[1 2];
'HC09',[1 2];
'HC10',[1 2];
'HC11',[1 2];
'HC12',[1 2];
'HC13',[1 2];
'HC14',[1 2];
       };

FileTemplate = '/net/data4/slab_SchizBDZ09/FirstLevel/[Subject]/func/[Run]/Grid/Grid_corr.mat';

ParamFile='/net/data4/slab_SchizBDZ09/FirstLevel/HC01/func/Lrz/Grid/Grid_parameters.mat';

RunDir= {
    'Lrz'
    'Sal'
} ;

[data,SubjAvail]=mc_load_connectomes_paired(SubjDir,FileTemplate,RunDir);


%% Clean dataset

[data_clean, censor]=mc_connectome_clean(data);

%% Calculate deltas

[data_delta, label, SubjIDs,ContrastAvail] = mc_calc_deltas_paired(data_clean,SubjAvail,[1 -1]);


%% Calculate aggregate discriminative power of edges

discrim=mc_calc_discrim_power_paired(data_delta,label,'fracfit');

% subset matrix on discrim power

[discrim_subset  keepID] = mc_bigsmall(discrim,500,3);

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


%% Visualize Support of Subsetted Matrix


discrim_subset_square_networksort_support = discrim_subset_square_networksort~=0;

imagesc(discrim_subset_square_networksort_support==0);colormap(gray)

%% Make heatmap of all discrim power

imagesc(discrim_square_networksort);colormap(hot)

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

hold off