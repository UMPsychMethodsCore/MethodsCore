% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2010
%
% Calculate the cutoff value for r (lower and upper) based
% on the CDF of the r-values observed
%
% function results = SOM_CalcRCutoff(dataBySOM)
% 
% results   = [lower, upper]
%
% dataBySOM = can be any distribution of r-values.
%             if 2-d, then dataBySOM = Space x R
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_CalcRCutoff(dataBySOM,pVal)

if exist('pVal') == 0
    pVal = .05;
end

if pVal > .5 | pVal < 0
    pVal = .05;
end

dataBySOM = squeeze(dataBySOM);

if size(dataBySOM,1) == 1
    dataBySOM = dataBySOM';
end

nEXP = size(dataBySOM,2);

results = [];

xBase = [-1:.01:1];

for iEXP = 1:nEXP
    hR  = hist(dataBySOM(:,iEXP),xBase);
    cHR = cumsum(hR);
    cHR = cHR/max(cHR);
    i1  = find(cHR<=pVal);
    i1  = max([1 max(i1)]);
    i2  = find(cHR>=(1-pVal));
    i2  = min([max([min(i2) 1]) length(cHR)]);
    results = [results ; xBase(i1) xBase(i2)];
end

    
    
    