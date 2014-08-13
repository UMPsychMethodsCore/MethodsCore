function [ AUC ] = mc_graphtheory_AUC( CombinedOutput,graph )
%MC_GRAPHTHEORY_AUC 
% This function calculates the area under curve for each metric, to
% provide a threshold-independent result.
% INPUT
%          CombinedOutput      -    First level graph theory results
%          graph
%             graph.netinclude -   Which networks to include
%                                    -1 -- Whole Brain;
%                                    Array of intergers ranging from 1 to
%                                    13 -- SubNetworks.
%             graph.threshmode -   'value'      - threshold numbers are within [0,1];
%                                  'sparsity'   - threshold numbers are
%                                                 within [0 100].
%             graph.thresh     -    Unsorted threshold array
% OUTPUT
%           AUC                -    nSubject x nNetwork cell
%                                   array saving AUC results, fields
%                                   structure similar to CombinedOutput
%    

if length(graph.thresh)<2
    warning('Single threshold is not enough for AUC calculation, so skip this step');
    AUC = {};
    return
end

sample = CombinedOutput{1,1,1};
r = structfun(@numel,sample); % To see how many elements does each field have, to determine which ones are global measres
Metrics = fieldnames(sample); % names of the metrics, it is a cell array
nGMetric = sum(r==1);  % number of global measures
lGMetric = find(r==1); % locations of global measures in the structure
mSub = size(CombinedOutput,2); % numberer of subjects
lNet = length(graph.netinclude); % number of networks
kThresh = length(graph.thresh); % number of thresholds

switch graph.threshmode
    case 'value'
        thresh = graph.thresh;
    case 'sparsity'
        thresh = graph.thresh./100;
    otherwise
        warning('cannot recognize the threshold mode, so skip AUC calculation')
        AUC = {};
        return            
end

[sthresh,ithresh] = sort(thresh);  % sort threshold in ascending order

AUC = cell(mSub,lNet);


for m = 1:mSub     % loop over subjects
    for l = 1:lNet   % loop over networks
        for n = 1:nGMetric  % loop over metrics
            curve = zeros(1,kThresh); % to save values from different thresholds
            name  = num2str(cell2mat(Metrics(lGMetric(n))));  % the name of the nth metric
            for k = 1:kThresh    % grab value from each threshold
                curve(k) = CombinedOutput{ithresh(k),m,l}.(name);  
                if k>1                    
                    Incre = (curve(k) + curve(k-1))*(sthresh(k)-sthresh(k-1))/2;
                    AUC{m,l}.(name) = AUC{m,l}.(name)+Incre;
                else
                    AUC{m,l}.(name) = 0;
                end    % Calculating AUC
            end
        end
    end
end





end

