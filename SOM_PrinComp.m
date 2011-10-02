% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% Calculate the Principle components from some confound time-series
% data
%
% function results = SOM_PrincipleComponents(theData,dataFraction)
%
%     theData = space x time
%
% you should linear detrend the data first.
%
%  e.g. theData = spm_detrend(theData',1)';
%
% The default is to take all voxels equally, howver, you can 
% also specify that top X% of those with variance should be used
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_PrinComp(theData,dataFraction)

global SOM

results.startCPU = cputime;

if isfield(SOM,'NumberPrincipleComponents') == 0
    SOM.NumberPrincipleComponents = 50;
end

if exist('dataFraction') == 0
    dataFraction = 1.0;
else
    dataFraction = min([1.0 max([dataFraction .01])]);
end

TVAR = var(theData,[],2);

TOTALVAR = sum(var(theData,[],2));

VARIDX = sortrows([TVAR [1:length(TVAR)]'],-1);

NIDX = max([2 round(dataFraction*length(TVAR))]);

VOXIDX = VARIDX(1:NIDX,2);

[PCCoeff PCScore PCLatent PCT2] = princomp(theData(VOXIDX,:)');

%
% Calculate the percent variance explained in the data.
%

VARCOMP = [];

SOM_LOG(sprintf('STATUS : Calculating variance explained by regressors, looking at first %d components',...
		min(SOM.NumberPrincipleComponents,size(PCScore,2))));

for iC = 1:min(SOM.NumberPrincipleComponents,size(PCScore,2))
    tmpData = SOM_RemoveMotion(theData,PCScore(:,1:iC));
    VARCOMP = [VARCOMP sum(var(tmpData,[],2))];
end

results.VARCOMP  = VARCOMP;
results.PCScore  = PCScore(:,1:min(SOM.NumberPrincipleComponents,size(PCScore,1)));
results.TOTALVAR = TOTALVAR;

results.stopCPU  = cputime;

return
