function write_viz(edgemat,roimat,net1,net2, netName)

nets = roimat(:,4);
nROI = size(roimat,1);
mask = zeros(nROI);

% Assign edges 
for iNet=1:length(net1)
    for i1=1:length(net2)
        mask(nets==net1(iNet),nets==net2(i1)) = 1;
        mask(nets==net2(i1), nets==net1(iNet)) = 1;
    end
end

edgemat_temp = edgemat .* mask;
roimat(:,5) = sum([sum(edgemat_temp,1) ; sum(edgemat_temp,2)']);

% Write node file
nodefile = fopen([sprintf(netName),'.node'],'w');
fprintf(nodefile,'%d\t%d\t%d\t%d\t%d\t-\n',roimat'); %Transpose is necessary b/c it will use elements in a row-major order

% Write edge file
dlmwrite([sprintf(netName),'.edge'],edgemat_temp,'\t');