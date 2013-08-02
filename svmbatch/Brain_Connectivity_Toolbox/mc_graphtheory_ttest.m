function [tresults] = mc_graphtheory_ttest( network,input,nNet,nMetric)
%MC_GRAPHTHEORY_TTEST Summary of this function goes here
%   Detailed explanation goes here
covtype=network.covtype;
netinclude=network.netinclude;
unitype    =input.unitype;
data   =input.subdata;
Label  = input.types;
netcol = input.netcol;
tresults.t  = zeros(nNet,nMetric);
tresults.p  = zeros(nNet,nMetric);
tresults.meancontrol = zeros(nNet,nMetric);
tresults.meanexp = zeros(nNet,nMetric);
tresults.secontrol   = zeros(nNet,nMetric);
tresults.seexp  = zeros(nNet,nMetric);
for iNet = 1:nNet
    for jMetric = 1:nMetric
        testdata = data(data(:,netcol)==netinclude(iNet),:); % certain network
        testmetric = testdata(:,jMetric+netcol); % certain metric
        if covtype % like 'A' and 'H'
            testcontrol = testmetric(Label==unitype(2));
            testexp = testmetric(Label==unitype(1));
        else
            testcontrol = testmetric(Label==unitype(1));
            testexp = testmetric(Label==unitype(2));
        end
        tresults.meancontrol(iNet,jMetric) = mean(testcontrol);
        tresults.meanexp(iNet,jMetric) = mean(testexp);
                         ncontrol = length(testcontrol);
                         nexp = length(testexp);
                        sdcontrol = std(testcontrol);
                        sdexp = std(testexp);                        
          tresults.secontrol(iNet,jMetric) = sdcontrol/(sqrt(ncontrol));
          tresults.seexp(iNet,jMetric) = sdexp/(sqrt(nexp));
%         [~,p(iNet,jMetric),~,tval]=ttest2(testhc,testds,[],[],'unequal');
        switch input.ttype
            case '2-sample'
        [~,tresults.p(iNet,jMetric),~,tval]=ttest2(testcontrol,testexp);
            case 'paired'
                =ttest(testcontrol,testexp);
        end
        tresults.t(iNet,jMetric)=tval.tstat;
    end
end


end

