% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2005
% Ann Arbor MI.
%
% function results = SOM_Weighted_SUM(SOMResults)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function [results, AWT] = SOM_Weighted_SUM(SOMResults)

WTS = [];
NUM = [];

for iSOM = 1:size(SOMResults.SOM,2)
    ii = find(SOMResults.IDX==iSOM);
    NUM = [NUM length(ii)];
    if length(ii) > 0
        theWTS = SOMResults.WTS(ii);
    else
        theWTS = 0;
    end
    WTS = [WTS sum(theWTS)];
end

wtMASK = (NUM>0);

AWT = wtMASK.*(WTS./(NUM.*wtMASK+(1-wtMASK)));

results = WTS;

return

%
% All done.
%