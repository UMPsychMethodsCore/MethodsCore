function Network_Viz(edgemat,nets,roimat,net1,net2, netName)

nROI = size(roimat,1);
mask = zeros(nROI);

for iNet=1:length(net1)
    for i1=1:length(net2)
        mask(nets==net1(iNet), nets==net2(i1)) = 1;
        mask(nets==net2(i1), nets==net1(iNet)) = 1;
    end
end

edgemat = edgemat .* mask;

roimat(:,5) = sum([sum(edgemat_intravisual,1) ; sum(edgemat_intravisual,2)']);

nodefile = fopen([sprintf(netName),'.node'],'w');

fprintf(nodefile,'%d\t%d\t%d\t%d\t%d\t-\n',roimat'); %Transpose is necessary b/c it will use elements in a row-major order

dlmwrite([sprintf(netName),'.edge'],edgemat,'\t');
