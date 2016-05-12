function out = mc_CountByCell(stat)

t = stat.t(permcol,:);
p = stat.p(permcol,:);
b = stat.b(permcol,:);


out.count = zeros([size(netmask),numel(thresh)]);
out.meanB = zeros([size(netmask),numel(thresh)]);
out.meanT = zeros([size(netmask),numel(thresh)]);

for i = 1:numel(thresh)
    supra = p<thresh(i);
    for x = 1:numel(netmask)
        tempCount = supra(netmask{x});
        tempCount(isnan(tempCount)) = []; % remove any NaN elements
        out.count(x + (i-1)*numel(netmask)) = sum(tempCount); %do assignment, jumping over the first dimensions for thresh
        
        tempT = t(netmask{x}); % remove any NaN t's
        tempT(isnan(tempT)) = [];
        out.meanT(x + (i-1)*numel(netmask)) = mean(tempT); %do assignment, jumping over the first dimensions for thresh
        
        tempB = b(netmask{x}); % remove any Nan beta's
        tempB(isnan(tempB)) = [];
        out.meanB(x + (i-1)*numel(netmask)) = mean(tempB); %do assignment, jumping over the first dimensions for thresh
    end
end
