% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2010
%
% Loop on the components passed and calculate the in/out ratio
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_CalcInOutComp(DataBySOM,pVal,TheTemplate)

global SOMMem

results = [];

if isfield(SOMMem{1},'maskInfo') == 0
    return
end

maskDim = size(TheTemplate);

if sum(any(size(TheTemplate) - SOMMem{1}.maskInfo.size)) ~= 0
    fprintf('Masking template doesn''t match the size of the original data.\n');
    return
end

BrainMask = zeros(SOMMem{1}.maskInfo.size);

BrainMask(SOMMem{1}.maskInfo.iMask) = 1;

NTheTemplate = TheTemplate .* BrainMask;

ROIRemoved = sum(TheTemplate(:)-NTheTemplate(:));

NotTemplate = BrainMask.*(1 - NTheTemplate);

rCutOff = SOM_CalcRCutoff(DataBySOM,pVal);

results = [];

BinConnMap = 0*BrainMask;

for iEXP = 1:size(DataBySOM,2)
    BinConnMap = SOM_BuildMap(DataBySOM,iEXP)>=rCutOff(iEXP,2);
    results = [results ; SOM_InOutComponent(BinConnMap,TheTemplate)];
end

return

%
% All done.
%
    