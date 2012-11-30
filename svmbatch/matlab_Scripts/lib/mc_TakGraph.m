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
            TakGraph=varargin{1};
            TakGraph = struct_Parse(TakGraph);
            struct_TakGraph(TakGraph)
        end
        
        if ischar(varargin{1})
            TakGraph=path_TakGraph(varargin{1});
            struct_TakGraph(TakGraph)
        end
        
    otherwise
        
        
        
end

function out = struct_Parse(in)
out=in;
if isfield(in,'SVMSetup');
    clear out
    out.SVM_ConnectomeResults = in;
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

% Recover otherwise zero networks

if isfield(in.SVM_ConnectomeResults.SVMSetup,'NearestNetworkNodeRad') && in.SVM_ConnectomeResults.SVMSetup.NearestNetworkNodeRad ~= 0
    networks = mc_NearestNetworkNode(roiMNI,in.SVM_ConnectomeResults.SVMSetup.NearestNetworkNodeRad)';
end

% Figure out square consensus connectome
prune = all(in.SVM_ConnectomeResults.LOOCV_pruning{1});
if isfield(in.SVM_ConnectomeResults.SVMSetup,'ColorizeTakGraph') && in.SVM_ConnectomeResults.SVMSetup.ColorizeTakGraph==1;
    mean_delta = mean_delta_C2_minus_C1(in);

    prune_pos = prune & mean_delta > 0;
    prune_neg = prune & mean_delta < 0;

    [prune_pos_square sorted] = generate_square_mat(in,prune_pos,networks);
    prune_neg_square = generate_square_mat(in,prune_neg,networks);
    
    prune_square = prune_neg_square ; % final prune square will have 1s for negative edges
    
    prune_square(find(prune_pos_square)) = 2; % set some of the points to be two
else
    [prune_square sorted] = generate_square_mat(in,prune,networks);
end


% Make heatmap

customcolor = [1 1 1;  %0 is white
               0 0 0;  %1 is black
               1 0 0;] %2 is red;

imagesc(prune_square);colormap(customcolor);

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

function out=enlarge_dots(in,mat)
%Enlarge the dots in your heatmat. You will need to supply
%your original square matrix (typically prune_square)
%
% mat will be a n*2 matrix of offsets that you wish to expand
% For example, to enlarge the dots by adding dots 
% above, below, and to either side, use:
% mat = [1 0; -1 0; 0 1; 0 -1];

[hotx hoty] = find(in);

[maxx maxy] = size(in);

for ioff = 1:size(mat,1);
    newx = hotx + mat(ioff,1);
    newy = hoty + mat(ioff,2);
    logicx = newx <= maxx & newx >=1;
    logicy = newy <= maxy & newy >=1;
    logicall = logicx & logicy ; 
    
    newx = newx(logicall);
    newy = newy(logicall);
    
    for j = 1:size(newx,1)
            in(newx(j),newy(j)) = 1;
    end

end

out = in;

function out = connectome_load(in)
% Just pass it the SVM object, and it will load the data in whatever manner is appropriate, and even do your delta

% Extract SVMSetup, cuz that's all your really need

a = in.SVM_ConnectomeResults.SVMSetup;

switch a.svmtype
  case 'paired'
    [data SubjAvail] = mc_load_connectomes_paired(a.SubjDir,a.ConnTemplate,a.RunDir,a.matrixtype);
    data = mc_connectome_clean(data);
    data=mc_connectome_clean(data);

  case 'unpaired'
    [data] = mc_load_connectomes_unpaired(a.SubjDir,a.ConnTemplate);
end

out=data;

function out = mean_delta_C2_minus_C1(in)
% Provide your SVM object and it will do the rest and return
% out - 1 * nEdges, where each value represents the mean delta from C2 - C1

% At present this only works paired data

a = in.SVM_ConnectomeResults.SVMSetup;

a.ConnTemplate = pathclean(a.ConnTemplate,'\[Exp\]',a.Exp); % Clean path to avoid Exp

switch a.svmtype
  case 'paired'
    [data SubjAvail] = mc_load_connectomes_paired(a.SubjDir,a.ConnTemplate,a.RunDir,a.matrixtype);
    data = mc_connectome_clean(data);
    data=mc_connectome_clean(data);

    [data_baseline label]=mc_calc_deltas_paired(data,SubjAvail,[1 0]);
    data_baseline=mean(data_baseline(label==1,:));
    [data_delta label]=mc_calc_deltas_paired(data,SubjAvail,[-1 1]);
    data_delta=mean(data_delta(label==1,:));

    out = data_delta;
end


function [prune_square sorted] = generate_square_mat(in,prune,networks)
% Provide SVM, prune, and networks, and it will do everything including making square, resorting, and dilation

prune_square = mc_unflatten_upper_triangle(prune);

% Permute edges to follow labels

[sorted, sortIDX] = sort(networks);

prune_square = prune_square(sortIDX,sortIDX);

% Dilate Edges if requested
if isfield(in.SVM_ConnectomeResults.SVMSetup,'DilateMat')
    prune_square = enlarge_dots(prune_square,in.SVM_ConnectomeResults.SVMSetup.DilateMat);
end

prune_square = triu(prune_square + prune_square');

function out = pathclean(oldpath,pattern,newpattern);
out=regexprep(oldpath,pattern,newpattern);
