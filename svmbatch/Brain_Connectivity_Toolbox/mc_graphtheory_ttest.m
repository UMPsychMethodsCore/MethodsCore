function [ p,stats,meanhc,meands,sdhc,sdds] = mc_graphtheory_ttest( Label,unitype,covtype,data,netinclude,nNet,nMetric)
%MC_GRAPHTHEORY_TTEST Summary of this function goes here
%   Detailed explanation goes here

stats  = zeros(nNet,nMetric);
p      = zeros(nNet,nMetric);
meanhc = zeros(nNet,nMetric);
meands = zeros(nNet,nMetric);
sdhc   = zeros(nNet,nMetric);
sdds   = zeros(nNet,nMetric);
for iNet = 1:nNet
    for jMetric = 1:nMetric
        testdata = data(data(:,1)==netinclude(iNet),:); % certain network
        testmetric = testdata(:,jMetric+1); % certain metric
        if covtype % like 'A' and 'H'
            testhc = testmetric(Label==unitype(2));
            testds = testmetric(Label==unitype(1));
        else
            testhc = testmetric(Label==unitype(1));
            testds = testmetric(Label==unitype(2));
        end
        meanhc(iNet,jMetric) = mean(testhc);
        meands(iNet,jMetric) = mean(testds);
        sdhc(iNet,jMetric)   = std(testhc);
        sdds(iNet,jMetric)   = std(testds);
        [~,p(iNet,jMetric),~,tval]=ttest2(testhc,testds);
        stats(iNet,jMetric)=tval.tstat;
    end
end


end

