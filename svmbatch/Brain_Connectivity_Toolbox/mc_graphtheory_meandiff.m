function [ meandiff,meanhc,meands,sehc,seds ] = mc_graphtheory_meandiff( Label,unitype,covtype,data,netinclude,netcol,nNet,nMetric )
%MC_GRAPHTHEORY_MEANDIFF Summary of this function goes here
%   Detailed explanation goes here

meandiff  = zeros(nNet,nMetric);
meanhc    = zeros(nNet,nMetric);
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
        sehc(iNet,jMetric)   = std(testhc)/(sqrt(length(testhc)));
        seds(iNet,jMetric)   = std(testds)/(sqrt(length(testds)));

        meandiff(iNet,jMetric) = mean(testhc)-mean(testds);

    end
end


end

