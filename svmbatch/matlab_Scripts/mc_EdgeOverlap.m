function out = mc_EdgeOverlap(stat,netmask,thresh,AVar,BVar);
% Expected input
% stat.p = p values
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

