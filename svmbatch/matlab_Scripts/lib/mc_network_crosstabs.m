function [ crosstabs, networks ] = mc_network_crosstabs ( edge_bin, path_param, path_networkmap )
%MC_NETWORK_CROSSTABS Crosstabulate your edge support by networks
% 
% 
% 
% NOTE - Because some network maps include 0 as a region, the first
% row/column are dedicated to network 0.

%% Figure out networks

nets=mc_connectome_get_edge_attribute(path_param,4,path_networkmap);

%% Other work

nets=nets(logical(edge_bin); % subset to only include those requested

maxNet=max(nets(:));


%% Built up your table

table=zeros(maxNet+1);

for iNet=0:maxNet
    for jNet=iNet:maxNet
        
        net_in = all(repmat([iNet;jNet],1,size(mininets,2)) == nets); % ID those that are in cur network group
        
        net_in = all(repmat([jNet;iNet],1,size(mininets,2)) == nets); % ID those in converse of cur network group
        
        net_in = net_in ~= 0 ; % ID all those hit at least once
        
        table(iNet+1, jNet+1) = sum(net_in,2);
        table(jNet+1,iNet+1) = sum(net_in,2);


end

