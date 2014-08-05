function [ table ] = mc_network_crosstabs ( edge_bin, path_param, path_networkmap, NetNborRad )
%MC_NETWORK_CROSSTABS Crosstabulate your edge support by networks
% 
%   INPUT
%       edge_bin        -   1 * nEdges matrix. 0's indicate don't count, 1's
%                           indicate do count for cross-tabulation
% 
%       path_param      -   A fully qualified path to your parameters file.
%                           Used to read-in MNI coordinates of nodes for
%                           network mapping
% 
%       path_networkmap -   A fully qualified path to your network map HDR.
%                           Used to look up values for network mapping.

%       NetNborRad      -   OPTIONAL | If specified, the function will attempt to identify
%                           any nodes that would have carried a label of zero otherwise.
%                           It does this with a call to mc_NearestNetworkNode. This argument
%                           specifies the 'radius' argument for mc_NearestNetworkNode, see
%                           that function's help for full details.
%                           WARNING - mc_NearestNetworkNode is not very fast, so if you have
%                           a large consensus this will add a LOT of time. 
% 
% NOTE - Because some network maps include 0 as a region, the first
% row/column are dedicated to network 0.

%% Figure out networks

nets=mc_connectome_get_edge_attribute(path_param,4,path_networkmap);

%% Other work

maxNet=max(nets(:));

nets=nets(:,logical(edge_bin)); % subset to only include those requested

%% Lookup Nearest Network Neighbor
if exist('NetNborRad','var')
    xs = mc_connectome_get_edge_attribute(path_param,1,path_networkmap);
    ys = mc_connectome_get_edge_attribute(path_param,2,path_networkmap);
    zs = mc_connectome_get_edge_attribute(path_param,3,path_networkmap);
    
    node1 = [xs(1,:)' ys(1,:)' zs(1,:)'];
    node2 = [xs(2,:)' ys(2,:)' zs(2,:)'];
    
    node1 = node1(logical(edge_bin),:);
    node2 = node2(logical(edge_bin),:);
    
    node1net = mc_NearestNetworkNode(node1,NetNborRad);
    node2net = mc_NearestNetworkNode(node2,NetNborRad);
    
    nets = [node1net ; node2net;];
end


%% Built up your table

table=zeros(maxNet+1);

for iNet=0:maxNet
    for jNet=iNet:maxNet
        
        net_in = all(repmat([iNet;jNet],1,size(nets,2)) == nets); % ID those that are in cur network group
        
        net_in = all(repmat([jNet;iNet],1,size(nets,2)) == nets); % ID those in converse of cur network group
        
        net_in = net_in ~= 0 ; % ID all those hit at least once
        
        table(iNet+1, jNet+1) = sum(net_in,2);
        table(jNet+1,iNet+1) = sum(net_in,2);
        
    end
end


end

