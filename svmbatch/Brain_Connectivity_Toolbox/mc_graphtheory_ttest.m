function [ p,stats] = mc_graphtheory_ttest( testhc,testds )
%MC_GRAPHTHEORY_TTEST Summary of this function goes here
%   Detailed explanation goes here

[~,p,~,stats]=ttest2(testhc,testds);


end

