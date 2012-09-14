function [ output_args ] = mc_TakGraph( varargin )
%MC_TAKGRAPH Make a "TakGraph"
%
%
% Usage 1
%   Provide the results of an SVM run as a struct
%
% Usage 2
%   Provide a path to a file that was the result of an SVM run
%
% Usage 3
%   Provide all of the pieces necessary to create a TakGraph (in progress)
%
%   Inputs
% 
%       Feature Weights
%       Path to Network Map
%       




%% Parse arguments

switch nargin
    case 1
        if isstruct(varargin{1})
            TakGraph=varargin;
            struct_TakGraph(TakGraph)
        end
        
        if ischar(varargin{1})
            TakGraph=path_TakGraph(varargin{1});
            struct_TakGraph(TakGraph)
        end
        
    otherwise
        
        
        
end



function out = path_TakGraph(in)
out = load(in);

function struct_TakGraph(in)

% 

% Figure out parameter path file
param_path=build_first_path(in.SVM_ConnectomeResults.SVMSetup.ROITemplate,...
    in.SVM_ConnectomeResults.SVMSetup.SubjDir,...
    in.SVM_ConnectomeResults.SVMSetup.RunDir,...
    in.SVM_ConnectomeResults.SVMSetup.Exp);

% Get labels 

parameters=load(param_path);
roiMNI=parameters.parameters.rois.mni.coordinates;
roi_MNI_labels = mc_network_lookup('/net/data4/MAS/ROIS/Yeo/YeoPlus.hdr',roiMNI);
networks=roi_MNI_labels(:,4);

% Figure out square consensus connectome
prune = all(in.SVM_ConnectomeResults.LOOCV_pruning{1});
prune_square = mc_unflatten_upper_triangle(prune);
prune_square = prune_square + prune_square'; %  make symmetric
prune_square = prune_square + eye(size(prune_square,1)); % add diagonal

% Permute edges to follow labels

[sorted, sortIDX] = sort(networks);

prune_square = prune_square(sortIDX,sortIDX);

% Make heatmap

imagesc(prune_square==0);colormap(gray);

% Add overlay to heatmap

network_overlay(sorted);


function abspath = build_first_path(template,SubjDir,RunDir,Exp)


Subject=SubjDir{1,1};
Run=RunDir{1};

abspath=mc_GenPath(template);

function network_overlay(sorted)
hold on

% figure out jump points in labels

jumps=diff(sorted);

jumps=[jumps];

starts=[1 ;find(jumps)];
stops=[find(jumps) - 1; size(sorted,1)];


for iBox=1:size(starts)
    mc_draw_box(starts(iBox),starts(iBox),stops(iBox),stops(iBox));
end

hold off