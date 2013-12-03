function [ permresults ] = mc_graphtheory_meandiff( graph,input,nNet,nMetric )
% MC_GRAPHTHEORY_MEANDIFF 
% Calculating group mean difference for permutation test use
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
%                                    info, the rest column is measured value.
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
%       permresults
%             permresults.meandiff -   nNet x nMetric x nROI matrix of group mean
%                                      difference
%             permresults.meancl   -   nNet x nMetric x nROI matrix of control
%                                      group mean
%             permresults.meanep   -   nNet x nMetric x nROI matrix of experiment
%                                      group mean
%             permresults.secl     -   nNet x nMetric x nROI matrix of control
%                                      group standard error
%             permresults.seep     -   nNet x nMetric x nROI matrix of experiment
%                                      group standard error
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% Initialization %%%%%%%%%%%%%%%
covtype=graph.covtype;
netinclude=graph.netinclude;

unitype    =input.unitype;
data   =input.subdata;
Label  = input.types;
col = input.col;
netcol = input.netcol;
metcol = input.metcol;

nROI = size(data,2)-col;

permresults.meandiff  = zeros(nNet,nMetric,nROI);
permresults.meancl    = zeros(nNet,nMetric,nROI);
permresults.meanep = zeros(nNet,nMetric,nROI);
permresults.secl   = zeros(nNet,nMetric,nROI);
permresults.seep   = zeros(nNet,nMetric,nROI);

%%%%%%%%% Calculation %%%%%%%%%%%%%%%%%%
for iNet = 1:nNet
    for jMetric = 1:nMetric
        % extract measured values of certain network and metric
        testdata = data(data(:,netcol)==netinclude(iNet) && data(:,metcol)==jMetric,col+1:end); 
        if covtype % like 'A' and 'H'
            testcl = testdata(Label==unitype(2));
            testep = testdata(Label==unitype(1));
            ncontrol = sum(Label==unitype(2));
            nexp = sum(Label==unitype(1));
        else
            testcl = testdata(Label==unitype(1));
            testep = testdata(Label==unitype(2));
            ncontrol = sum(Label==unitype(2));
            nexp = sum(Label==unitype(1));
        end
        permresults.meancl(iNet,jMetric,:) = mean(testcl);
        permresults.meanep(iNet,jMetric,:) = mean(testep);
        permresults.secl(iNet,jMetric,:)   = std(testcl)/(sqrt(ncontrol));
        permresults.seep(iNet,jMetric,:)   = std(testep)/(sqrt(nexp));
        permresults.meandiff(iNet,jMetric,:) = mean(testep)-mean(testcl);
    end
end


end

