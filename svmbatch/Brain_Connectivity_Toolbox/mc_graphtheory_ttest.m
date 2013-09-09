function [tresults] = mc_graphtheory_ttest( network,input,nNet,nMetric)
% MC_GRAPHTHEORY_TTEST 
% Doing t-test on graph theory measure results
%
% INPUT
%       nNet                     -   Number of networks
%       nMetric                  -   Number of metrics
%       input 
%             input.col          -   Number of columns with extra info like
%                                    network and threshold
%             input.netcol       -   Indicate which column contains the
%                                    network info
%             input.subdata      -   nSub x (nMetric + input.col) matrix,
%                                    first input.col columns contains extra 
%                                    info, the rest each column is measures of
%                                    one kind of metric.
%             input.types        -   nSub x 1 vector with info of subject type
%             input.unitype      -   number of subject types
%
%       network
%             network.covtype    -   0 -- alphabetically, control group name 
%                                         in the front, like 'H' and 'O'
%                                    1 -- alphabetically, experiment group 
%                                         name in the front, like 'A' and 'H'
%             network.netinclude -   Which networks to include
%                                    -1 -- Whole Brain;
%                                    Array of intergers ranging from 1 to 13 -- SubNetworks
%   
%
% OUTPUT
%
%       tresults
%             tresults.t           -   nNet x nMetric matrix of t stats
%             tresults.p           -   nNet x nMetric matrix of p value
%             tresults.meancontrol -   nNet x nMetric matrix of control
%                                      group mean
%             tresults.meanexp     -   nNet x nMetric matrix of experiment
%                                      group mean
%             tresults.secontrol   -   nNet x nMetric matrix of control
%                                      group standard error
%             tresults.seexp       -   nNet x nMetric matrix of experiment
%                                      group standard error
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%%%%%%%%% Initialization %%%%%%%%%%%%%%%
covtype=network.covtype;
netinclude=network.netinclude;

col = input.col;
netcol = input.netcol;
data   =input.subdata;
Label  = input.types;
unitype    =input.unitype;

tresults.t  = zeros(nNet,nMetric);
tresults.p  = zeros(nNet,nMetric);
tresults.meancontrol = zeros(nNet,nMetric);
tresults.meanexp = zeros(nNet,nMetric);
tresults.secontrol   = zeros(nNet,nMetric);
tresults.seexp  = zeros(nNet,nMetric);

%%%%%%%%% t-test %%%%%%%%%%%%%%%%%%
for iNet = 1:nNet
    for jMetric = 1:nMetric
        % extract data
        testdata = data(data(:,netcol)==netinclude(iNet),:); % certain network
        testmetric = testdata(:,jMetric+col); % certain metric
        if covtype % like 'A' and 'H'
            testcontrol = testmetric(Label==unitype(2));
            testexp = testmetric(Label==unitype(1));
        else
            testcontrol = testmetric(Label==unitype(1));
            testexp = testmetric(Label==unitype(2));
        end
        % calculate mean and standard error
        tresults.meancontrol(iNet,jMetric) = mean(testcontrol);
        tresults.meanexp(iNet,jMetric) = mean(testexp);
        ncontrol = length(testcontrol);
        nexp = length(testexp);
        sdcontrol = std(testcontrol);
        sdexp = std(testexp);
        tresults.secontrol(iNet,jMetric) = sdcontrol/(sqrt(ncontrol));
        tresults.seexp(iNet,jMetric) = sdexp/(sqrt(nexp));
        % t-test
        switch input.ttype
            case '2-sample'
                [~,tresults.p(iNet,jMetric),~,tval]=ttest2(testcontrol,testexp);
            case 'paired'
                [~,tresults.p(iNet,jMetric),~,tval]=ttest(testcontrol,testexp);
        end
        tresults.t(iNet,jMetric)=tval.tstat;
    end
end
end

