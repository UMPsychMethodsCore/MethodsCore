function out = mc_EdgeOverlap(stat,netmask,thresh,AVar,BVar);
% Expected inputs
% stat.p = p values
% netmask
% thresh
% AVar
% BVar
stat.p = stat.p([AVar BVar],:);


out.A = zeros([size(netmask),numel(thresh)]);
out.B = zeros([size(netmask),numel(thresh)]);
out.AB = zeros([size(netmask),numel(thresh)]);

for i = 1:numel(thresh)
    supra = stat.p<thresh(i);
    for x = 1:numel(netmask)
        A = sum(supra(1,netmask{x}));
        B = sum(supra(2,netmask{x}));
        AB = sum(all(supra(:,netmask{x}),1));
        
        out.A(x + (i-1)*numel(netmask)) = A;
        out.B(x + (i-1)*numel(netmask)) = B;
        out.AB(x + (i-1)*numel(netmask)) = AB ;
    end
end

%% Calculate an odds ratio
celltot = cellfun(@nnz,netmask);

celltot = repmat(celltot,[1,1,numel(thresh)]);

Odds.pa = out.AB ./ out.B;
Odds.pn = (out.A - out.AB) ./ (celltot - out.B);
Odds.qa = 1 - Odds.pa;
Odds.qn = 1 - Odds.pn;

Odds.Ratio = (Odds.pa .* Odds.qn) ./ (Odds.pn .* Odds.qa);

out.OddsRatio = Odds.Ratio;
