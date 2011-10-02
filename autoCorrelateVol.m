%
% a function to calculate the autocorrelation of a grey matter
% voxel with its neighbors
%
% function results = autoCorrelateVol(theVol,option)
%
%    option = 'FULL' if you want to examine the 
%             full cube about the middle.
%

function results = autoCorrelateVol(theVol,varargin)

theDIM = size(theVol);

tmpVol = zeros(theDIM+[2 2 2]);

tmpVol(2:end-1,2:end-1,2:end-1) = theVol;

results = zeros(theDIM);

theShifts = [ 0 0 0 ;...
	      -1  0  0 ; ...
	      +1  0  0 ; ...
	      0 -1  0 ; ...
	      0 +1  0 ; ...
	      0  0 -1 ; ...
	      0  0 +1 ; ...
	      -1 -1  0 ; ...
	      +1 -1  0 ; ...
	      -1 +1  0 ; ...
	      +1 +1  0 ; ...
	      -1  0 -1 ; ...
	      +1  0 -1 ; ...
	      -1  0 +1 ; ...
	      +1  0 +1 ; ...
	      0 -1 -1 ; ...
	      0 +1 -1 ; ...
	      0 -1 +1 ; ...
	      0 +1 +1 ];

if nargin > 1
  if varargin{1} == 'FULL'
    
    theShifts = [];
    for iz = -1:1
      for iy = -1:1
	for ix = -1:1
	  theShifts = [theShifts; ix iy iz];
	end
      end
    end
  end
end

for iShift = 1:size(theShifts,1)
    theCorner = theShifts(iShift,:) + 2;
    theEnd    = theCorner + theDIM - 1;
    results = results + theVol.*tmpVol(theCorner(1):theEnd(1),theCorner(2):theEnd(2),theCorner(3):theEnd(3));
end

%
% all done.
%
