function [ permresults ] = mc_graphtheory_meandiff( network,input,nNet,nMetric )
% MC_GRAPHTHEORY_MEANDIFF 
% Calculating group mean difference for permutation test use
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
%       permresults
%             permresults.meandiff -   nNet x nMetrix matrix of group mean
%                                      difference
%             permresults.meancl   -   nNet x nMetric matrix of control
%                                      group mean
%             permresults.meanep   -   nNet x nMetric matrix of experiment
%                                      group mean
%             permresults.secl     -   nNet x nMetric matrix of control
%                                      group standard error
%             permresults.seep     -   nNet x nMetric matrix of experiment
%                                      group standard error
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% Initialization %%%%%%%%%%%%%%%
covtype=network.covtype;
netinclude=network.netinclude;
unitype    =input.unitype;
data   =input.subdata;
Label  = input.types;
col = input.col;
netcol = input.netcol;

permresults.meandiff  = zeros(nNet,nMetric);
permresults.meancl    = zeros(nNet,nMetric);
permresults.meanep = zeros(nNet,nMetric);
permresults.secl   = zeros(nNet,nMetric);
permresults.seep   = zeros(nNet,nMetric);

%%%%%%%%% Calculation %%%%%%%%%%%%%%%%%%
for iNet = 1:nNet
    for jMetric = 1:nMetric
        testdata = data(data(:,netcol)==netinclude(iNet),:); % certain network
        testmetric = testdata(:,jMetric+col); % certain metric
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

