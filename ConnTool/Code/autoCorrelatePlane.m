%
% a function to calculate the autocorrelation of a grey matter
% voxel with its neighbors
%
% function results = autoCorrelateVol(theSlice,option)
%
%    option = 'FULL' if you want to examine the
%             full cube about the middle.
%

function results = autoCorrelatePlane(theSlice,varargin)

theDIM = size(theSlice);

tmpVol = zeros(theDIM+[6 6]);

tmpVol(4:end-3,4:end-3) = theSlice;

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
        for ix = -1:1
            for iy = -1:1
                    theShifts = [theShifts; ix iy];
            end
        end
    elseif strcmp(upper(varargin{1}),'FULL5')
        
        theShifts = [];
        for ix = -2:2
            for iy = -2:2
                    theShifts = [theShifts; ix iy];
            end
        end
    elseif strcmp(upper(varargin{1}),'FULL7')
        
        theShifts = [];
        for ix = -3:3
            for iy = -3:3
                    theShifts = [theShifts; ix iy];
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
    results = results + theSlice.*tmpVol(theCorner(1):theEnd(1),theCorner(2):theEnd(2));
end

%
% all done.
%
