
function corrMAP = SOM_corr4D(vol1,vol2)

if any(size(vol1) - size(vol2))
    fprintf('No identical\n');
    corrMAP = [];
    return
end

corrMAP = zeros(size(squeeze(vol1(:,:,:,1))));

idx = find(diag(ones(prod(size(squeeze(vol1(:,:,1,1)))),1)));

nX    = size(vol1,1);
nY    = size(vol1,2);
nZ    = size(vol1,3);
nXY   = nX*nY;
nTIME = size(vol1,4);

for iZ = 1:size(vol1,3)
    data1 = vol1(:,:,iZ,:);
    data2 = vol2(:,:,iZ,:);
    data1 = reshape(data1,[nXY nTIME])';
    data2 = reshape(data2,[nXY nTIME])';
    cmap = corr(data1,data2);
    corrMAP(:,:,iZ) = reshape(cmap(idx),[nX nY]);
end
