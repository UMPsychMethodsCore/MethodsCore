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

tmpVol = zeros(theDIM+[6 6 6]);

tmpVol(4:end-3,4:end-3,4:end-3) = theVol;

results = zeros(theDIM);

theShifts = [
    +0 +0 +0 ;...
    -1 +0 +0 ; ...
    +1 +0 +0 ; ...
    +0 -1  0 ; ...
    +0 +1  0 ; ...
    +0  0 -1 ; ...
    +0  0 +1 ; ...
    -1 -1  0 ; ...
    +1 -1  0 ; ...
    -1 +1  0 ; ...
    +1 +1  0 ; ...
    -1  0 -1 ; ...
    +1  0 -1 ; ...
    -1  0 +1 ; ...
    +1  0 +1 ; ...
    +0 -1 -1 ; ...
    +0 +1 -1 ; ...
    +0 -1 +1 ; ...
    +0 +1 +1 ];

if nargin > 1
    if strcmp(upper(varargin{1}),'FULL')
        
        theShifts = [];
        for iz = -1:1
            for iy = -1:1
                for ix = -1:1
                    theShifts = [theShifts; ix iy iz];
                end
            end
        end
    elseif strcmp(upper(varargin{1}),'FULL5')
        
        theShifts = [];
        for iz = -2:2
            for iy = -2:2
                for ix = -2:2
                    theShifts = [theShifts; ix iy iz];
                end
            end
        end
    elseif strcmp(upper(varargin{1}),'FULL7')
        
        theShifts = [];
        for iz = -3:3
            for iy = -3:3
                for ix = -3:3
                    theShifts = [theShifts; ix iy iz];
                end
            end
        end
    end
end


for iShift = 1:size(theShifts,1)
    if strcmp(upper(varargin{1}),'FULL5')
        theCorner = theShifts(iShift,:) + 3;
    elseif strcmp(upper(varargin{1}),'FULL7')
        theCorner = theShifts(iShift,:) + 4;
    else
        theCorner = theShifts(iShift,:) + 2;
    end
    theEnd    = theCorner + theDIM - 1;
    results = results + theVol.*tmpVol(theCorner(1):theEnd(1),theCorner(2):theEnd(2),theCorner(3):theEnd(3));
end

%
% all done.
%
