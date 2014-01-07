% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2005
%
% Take a coordinate and expand an ROI.
%
% function results = SOM_MakeROI(xyz,theSize,theLimits)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_MakeROI(xyz,theSize,theLimits)

%
% 
%

results = [];

xmin = floor((theSize(1)-1)/2);
xmax = floor((theSize(1))/2);
ymin = floor((theSize(2)-1)/2);
ymax = floor((theSize(2))/2);
zmin = floor((theSize(3)-1)/2);
zmax = floor((theSize(3))/2);

fprintf('Expanding : %d %d %d\n',xyz);
fprintf(' to ROI defined by %d:%d, %d:%d, %d:%d\n',...
	max([1 xyz(1)-xmin]),min([xyz(1)+xmax theLimits(1)]),...
	max([1 xyz(2)-ymin]),min([xyz(2)+ymax theLimits(2)]),...
	max([1 xyz(3)-zmin]),min([xyz(3)+zmax theLimits(3)]));
				 
for ix = max([1 xyz(1)-xmin]):min([xyz(1)+xmax theLimits(1)])
  for iy = max([1 xyz(2)-ymin]):min([xyz(2)+ymax theLimits(2)])
    for iz = max([1 xyz(3)-zmin]):min([xyz(3)+zmax theLimits(3)])
      results = [results; ix iy iz];
    end
  end
end

%
% All done.
%