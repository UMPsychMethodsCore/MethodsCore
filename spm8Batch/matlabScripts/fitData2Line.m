%
% Fit X,Y to a straight line.
%

function fitBeg = fitData2Line(xVals,yVals)


fitBeg.p2 = 0;
fitBeg.p1 = 0;
fitBeg.OK = -1;

% Do we have the same length data?

if length(xVals) ~= length(yVals)
    return
end

% Under-constrained problem?

if length(xVals) < 2
    fitBeg.p2 = yVals(1);
    fitBeg.p1 = 0;
    fitBeg.OK = 1;
    return
end

% Just two points, fits perfectly.

if length(xVals) == 2
    fitBeg.p2 = (yVals(2) - yVals(1))/(xVals(2) - xVals(1));
    fitBeg.p1 = yVals(1) - fitBeg.p2*xVals(1);
    fitBeg.OK = 1;
    return
end

% Okay, now we can do LS.

SX = std(xVals);
SY = std(yVals);

RXY = corr(xVals,yVals);

fitBeg.p2 = RXY * SY / SX;
fitBeg.p1 = mean(yVals) - fitBeg.p2*mean(xVals);
fitBeg.OK = 1;

return

