function [connectome, ROIcoordinates] = mc_network_conjunction(ROIA, ROIB, squareA, squareB)
%find common ROIs
[ROIcoordinates, coA, coB] = intersect(ROIA, ROIB, 'rows');

%# of common ROI
ncommonROI = size(coA,1);

%commonA, commonB: flattened vectors of the values where squareA and squareB are in common
commonA = [];
commonB = [];

for i = 1:ncommonROI
    for j = i+1:ncommonROI
        commonA(end+1) = squareA(min(coA(i),coA(j)), max(coA(i),coA(j)));
        commonB(end+1) = squareB(min(coB(i),coB(j)), max(coB(i),coB(j)));   
    end
end

%unflatten commonA and commonB
square_commonA = unflatten(commonA, ncommonROI);
square_commonB = unflatten(commonB, ncommonROI);

connectome = (square_commonA & square_commonB);

end