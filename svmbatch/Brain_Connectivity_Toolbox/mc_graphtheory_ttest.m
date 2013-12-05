function [tresults] = mc_graphtheory_ttest( graph,input,nNet,nMetric)
% MC_GRAPHTHEORY_TTEST 
% Doing t-test on graph theory measure results
%
% INPUT
%       nNet                     -   Number of networks
%       nMetric                  -   Number of metrics
%       input 
%             input.col          -   Number of columns with info including
%                                    network, threshold and metric
%             input.netcol       -   Indicate which column contains the
%                                    network info
%             input.metcol       -   Indicate which column contains the metric info
%             input.subdata      -   (nSub x nNet x nMetric) x (input.col + 1) matrix,
%                                    first input.col columns contains extra 
%                                    info, the rest column is measured value.                                   one kind of metric.
%             input.types        -   nSub x 1 vector with info of subject type
%             input.unitype      -   number of subject types
%
%       graph
%             graph.covtype    -   0 -- alphabetically, control group name 
%                                         in the front, like 'H' and 'O'
%                                    1 -- alphabetically, experiment group 
%                                         name in the front, like 'A' and 'H'
%             graph.netinclude -   Which networks to include
%                                    -1 -- Whole Brain;
%                                    Array of intergers ranging from 1 to 13 -- SubNetworks
%   
%
% OUTPUT
%
%       tresults
%             tresults.t           -   nNet x nMetric x nROI matrix of t stats
%             tresults.p           -   nNet x nMetric x nROI matrix of p value
%             tresults.meancontrol -   nNet x nMetric x nROI matrix of control
%                                      group mean
%             tresults.meanexp     -   nNet x nMetric x nROI matrix of experiment
%                                      group mean
%             tresults.secontrol   -   nNet x nMetric x nROI matrix of control
%                                      group standard error
%             tresults.seexp       -   nNet x nMetric x nROI matrix of experiment
%                                      group standard error
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%%%%%%%%% Initialization %%%%%%%%%%%%%%%
covtype=graph.covtype;
netinclude=graph.netinclude;

col = input.col;
netcol = input.netcol;
metcol = input.metcol;
data   =input.subdata;
Label  = input.types;
unitype    =input.unitype;

nROI = size(data,2)-col;

tresults.t  = zeros(nNet,nMetric,nROI);
tresults.p  = zeros(nNet,nMetric,nROI);
tresults.meancontrol = zeros(nNet,nMetric,nROI);
tresults.meanexp = zeros(nNet,nMetric,nROI);
tresults.secontrol   = zeros(nNet,nMetric,nROI);
tresults.seexp  = zeros(nNet,nMetric,nROI);

%%%%%%%%% t-test %%%%%%%%%%%%%%%%%%
for iNet = 1:nNet
    for jMetric = 1:nMetric
        % extract measured values of certain network and metric
        testdata = data(data(:,netcol)==netinclude(iNet) & data(:,metcol)==jMetric,col+1:end); 
        if covtype % like 'A' and 'H'
            testcontrol = testdata(Label==unitype(2),:);
            testexp = testdata(Label==unitype(1),:);
            ncontrol = sum(Label==unitype(2));
            nexp = sum(Label==unitype(1));
        else
            testcontrol = testdata(Label==unitype(1),:);
            testexp = testdata(Label==unitype(2),:);
            ncontrol = sum(Label==unitype(1));
            nexp = sum(Label==unitype(2));
        end
        % calculate mean and standard error
        
        tresults.meancontrol(iNet,jMetric,:) = mean(testcontrol);
        tresults.meanexp(iNet,jMetric,:) = mean(testexp);
        sdcontrol = std(testcontrol);
        sdexp = std(testexp);
        tresults.secontrol(iNet,jMetric,:) = sdcontrol/(sqrt(ncontrol));
        tresults.seexp(iNet,jMetric,:) = sdexp/(sqrt(nexp));
        % t-test
        switch input.ttype
            case '2-sample'
                [~,tresults.p(iNet,jMetric,:),~,tval]=ttest2(testexp,testcontrol);
            case 'paired'
                [~,tresults.p(iNet,jMetric,:),~,tval]=ttest(testexp,testcontrol);
        end
        tresults.t(iNet,jMetric,:)=tval.tstat;
        
    end
end
end

