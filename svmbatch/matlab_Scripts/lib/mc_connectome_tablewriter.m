function [ table ] = mc_connectome_tablewriter( prune,ROI_mni,fitness,subprune,NetworkMap )
%MC_CONNECTOME_TABLEWRITER Create a summary table of your relevant edges
% NOTES
%   If you have multiple summary statistics that you woul dlike to report
%   in one table, you should be able to run this command multiple times
%   and concatenate the relevant output fields. However, be wary of using
%   subprune as it may use different indices to prune each of your summary
%   statistics.
%
%   Input Arguments
%       Required
%           prune               -   Logical matrix of features to retain [1 * nFeat]
%           ROI_mni             -   List of MNI coordinators of ROIs. Should be
%                           nROI * 3. Any additional collumns will be ignored.
%       Optional
%           fitness             -   Aggregate feature fitness [1 * nFeat].
%                                   Set to 0 to disable
%           subprune            -   Max number of edges to list. Requires
%                                   definition of fitness. Will subset pruned set
%                                   based on max absolute values of fitness.
%                                   [Integer]. Set to 0 to disable.
%           NetworkMap          -   Path to img/hdr file. Ideally sliced resolution
%                                   such that each ROI_mni can be uniquely indexed
%                                   into one voxel. This is used to label the nodes
%                                   in the table
%   Output
%       table                   -   cell array summarizing your relevant edges.
%                                   Will be (nEdges + 1) * 6, as first row
%                                   will contain strings that label the
%                                   columns.
%           columns
%               Node1           -   MNI coordinats (x,y,z) of one node
%               Node2           -   MNI coordinates (x,y,z) of second node
%               edgeval         -   If you supplied fitness, this will show that value.
%                                   Otherwise it will be 1
%               Node1Network    -   If you supplied a Network Map, this
%                                   will hold the value of the network
%                                   afffiliation of Node1
%               Node2Network    -   Similar to Node1Network, but for Node2




% Count ROIs
nROI = size(ROI_mni,1);

% Convert prune to logical in case it isn't already
prune=logical(prune);

% If fitness wasn't provided, make it a binary version of prune
if ~exist('fitness','var') || (size(fitness,2)==1 && fitness==0)
    fitness=zeros(size(prune,2));
    fitness(prune)=1;
end

% Do initial pruning on fitness
fitness(~prune)=0;

% If subprune was provided prune fitness down further
if exist('subprune','var') && subprune~=0
    fitness=mc_bigsmall(fitness,subprune,3);
end

% Convert fitness back to a square matrix
fitness_square=mc_unflatten_upper_triangle(fitness,nROI);

% Identify the indices of the nonzero elements. These index into the ROI
% list
[Node1idx,Node2idx]=find(fitness_square);

% Grab the nonzero values
fitness_values=fitness_square(find(fitness_square));

% Look up the MNI coordinates

mat2cell
Node1MNI=ROI_mni(Node1idx,:);
Node2MNI=ROI_mni(Node2idx,:);

table{:,1}=num2cell(Node1MNI,2);
table{:,2}=num2cell(Node2MNI,2);
table{:,3}=num2cell(fitness_values,2);

table_labels={'Node1_MNI' 'Node2_MNI' 'Edge_Value'};

% Look up network identities if available
if exist('NetworkMap','var')
    Node1NetworkLookup=mc_network_lookup(NetworkMap,Node1MNI);
    Node2NetworkLookup=mc_network_lookup(NetworkMap,Node2MNI);
    table{:,4}=num2cell(Node1NetworkLookup(:,4),2);
    table{:,5}=num2cell(Node2NetworkLookup(:,4),2);
    table_labels={table_labels{:} 'Node1_Network' 'Node2_Network'};
end

table=vertcat(table,table_labels);
