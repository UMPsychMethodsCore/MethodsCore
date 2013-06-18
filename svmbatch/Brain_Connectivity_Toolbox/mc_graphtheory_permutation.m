function [ output ] = mc_graphtheory_permutation( types,unitype,covtype,data,netinclude,nNet,nMetric)
%MC_GRAPHTHEORY_PERMUTATION Summary of this function goes here
%   Detailed explanation goes here
%% Create random labels with fixed group sizes
ind = randperm(length(types));
permLabel = types(ind)';

%% 2 sample t-test  ---> move the whole part to ttest function!!!!!
output = mc_graphtheory_ttest(permLabel,covtype,data,netinclude,
for iNet = 1:nNet
    for jMetric = 1:nMetric
        testdata = data(data(:,1)==netinclude(iNet),:); % certain network
        testmetric = testdata(:,jMetric+1); % certain metric
        if covtype % like 'A' and 'H'
            testhc = testmetric(permLabel==unitype(2));
            testds = testmetric(permLabel==unitype(1));
        else
            testhc = testmetric(permLabel==unitype(1));
            testds = testmetric(permLabel==unitype(2));
        end
        [~,output(iNet,jMetric)]=mc_graphtheory_ttest(testhc,testds);
    end
end


end

