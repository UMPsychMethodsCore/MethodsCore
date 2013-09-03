function [ permresults ] = mc_graphtheory_meandiff( network,input,nNet,nMetric )
%MC_GRAPHTHEORY_MEANDIFF Summary of this function goes here
%   Detailed explanation goes here
covtype=network.covtype;
netinclude=network.netinclude;
unitype    =input.unitype;
data   =input.subdata;
Label  = input.types;
netcol = input.netcol;

permresults.meandiff  = zeros(nNet,nMetric);
permresults.meancl    = zeros(nNet,nMetric);
permresults.meanep = zeros(nNet,nMetric);
permresults.secl   = zeros(nNet,nMetric);
permresults.seep   = zeros(nNet,nMetric);
for iNet = 1:nNet
    for jMetric = 1:nMetric
        testdata = data(data(:,netcol)==netinclude(iNet),:); % certain network
        testmetric = testdata(:,jMetric+netcol); % certain metric
        if covtype % like 'A' and 'H'
            testcl = testmetric(Label==unitype(2));
            testep = testmetric(Label==unitype(1));
        else
            testcl = testmetric(Label==unitype(1));
            testep = testmetric(Label==unitype(2));
        end
        permresults.meancl(iNet,jMetric) = mean(testcl);
        permresults.meanep(iNet,jMetric) = mean(testep);
        permresults.secl(iNet,jMetric)   = std(testcl)/(sqrt(length(testcl)));
        permresults.seep(iNet,jMetric)   = std(testep)/(sqrt(length(testep)));
        permresults.meandiff(iNet,jMetric) = mean(testep)-mean(testcl);
    end
end


end

