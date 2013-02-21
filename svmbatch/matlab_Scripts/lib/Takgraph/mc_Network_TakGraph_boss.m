function [ h,a,out ] = mc_Network_TakGraph_boss( a )
%MC_NETWORK_TAKGRAPH_BOSS Summary of this function goes here
%   Detailed explanation goes here

a = mc_Network_mediator(a);

a = mc_Network_Cellcount(a);

a = mc_Network_Cellstats(a);

if isfield(a,'DotDilateMat')
    a = mc_TakGraph_enlarge(a);
end

[h,a] = mc_TakGraph_plot(a);

if isfield(a,'shading') && isfield(a.shading,'enable') && a.shading.enable==1
    
    a = mc_TakGraph_shadingtrans(a);
    
    mc_TakGraph_addshading(a);
    
end




end

