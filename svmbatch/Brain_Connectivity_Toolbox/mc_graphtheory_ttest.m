function [ p,stats,meanhc,meands,sehc,seds] = mc_graphtheory_ttest( Label,unitype,covtype,data,netinclude,netcol,nNet,nMetric)
%MC_GRAPHTHEORY_TTEST Summary of this function goes here
%   Detailed explanation goes here

stats  = zeros(nNet,nMetric);
p      = zeros(nNet,nMetric);
meanhc = zeros(nNet,nMetric);
meands = zeros(nNet,nMetric);
sehc   = zeros(nNet,nMetric);
seds   = zeros(nNet,nMetric);
for iNet = 1:nNet
    for jMetric = 1:nMetric
        testdata = data(data(:,netcol)==netinclude(iNet),:); % certain network
        testmetric = testdata(:,jMetric+netcol); % certain metric
        if covtype % like 'A' and 'H'
            testhc = testmetric(Label==unitype(2));
            testds = testmetric(Label==unitype(1));
        else
            testhc = testmetric(Label==unitype(1));
            testds = testmetric(Label==unitype(2));
        end
        meanhc(iNet,jMetric) = mean(testhc);
        meands(iNet,jMetric) = mean(testds);
                         nhc = length(testhc);
                         nds = length(testds);
                        sdhc = std(testhc);
                        sdds = std(testds);                        
          sehc(iNet,jMetric) = sdhc/(sqrt(nhc));
          seds(iNet,jMetric) = sdds/(sqrt(nds));
%         [~,p(iNet,jMetric),~,tval]=ttest2(testhc,testds,[],[],'unequal');
        [~,p(iNet,jMetric),~,tval]=ttest2(testhc,testds);
        stats(iNet,jMetric)=tval.tstat;
    end
end


end

