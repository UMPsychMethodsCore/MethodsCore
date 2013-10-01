% - - - - - - - - - - - - - - - - - - - - - - - - - - 
% 
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
%
% A function to make a three-d sphere of radius R
% in voxel coordinates.
%
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - 

function results = SOM_MakeSpereROI(R)

Rbox = round(R);

% Default is a single VOXEL.
if R < 1
    results = [0; 0; 0];
    return
end

Xs = [-Rbox:Rbox];
Ys = [-Rbox:Rbox];
Zs = [-Rbox:Rbox];

XGrid = repmat(Xs,[length(Ys) 1]);
YGrid = repmat(Ys',[1 length(Xs)]);

results = [];

% Now loop on the Z's and find out if in the radius.

for iZ = 1:length(Zs)
    rDist = sqrt(XGrid(:).^2 + YGrid(:).^2 + Zs(iZ)^2);
    RIDX = find(R>=rDist);
    results = [results; XGrid(RIDX) YGrid(RIDX) Zs(iZ)*ones(length(RIDX),1)];
end

%Return as 
%            X
%            Y
%            Z

results = results';

return
