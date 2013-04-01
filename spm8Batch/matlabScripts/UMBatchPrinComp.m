% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2013
%
% Ann Arbor, MI
%
% Calculate the Principle components from some confound time-series data
%
% function results = UMBatchPrinComp(UMWMMask,UMCSFMask,Images2Read,detrendFlag,NComponents,dataFraction,TestFlag)
%
%     theData = space x time
%
% the data is detrended with SPM.
%
%  e.g. theData = spm_detrend(theData',1)';
%
% The default is to take all voxels equally, howver, you can
% also specify that top X% of those with variance should be used
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

%
% 2011.11.18 - RCWelsh - Fixed error on subscript to line below to
%                        reflect change:
%                        size(PCScore,1) -> size(PCScore,2);
%

%function results = UMBatchPrinComp(theData,dataFraction)

function results = UMBatchPrinComp(UMWMMask,UMCSFMask,Images2Read,detrendFlag,NComponents,dataFraction,TestFlag)

global UMBatch
global defaults

% Start the timer

results = cputime;

% Make sure we have access to stats toolbox

prinCompDir = which('princomp');

if isempty(prinCompDir)
    fprintf('\n\n* * * * * * * * * * * * * * * * * * *\n');
    fprintf('* * * * * * * * * * * * * * * * * * *\n');
    fprintf('* * * * *  princomp.m missing * * * *\n');
    fprintf('* * * * * * * * * * * * * * * * * * *\n');
    fprintf('* * * * * * * * * * * * * * * * * * *\n');
    results = -1;
    return
end

OutputNames = {'WM_PCA_','CSF_PCA_','BOTH_PCA_'};

% Make the call to prepare the system for batch processing.

UMBatchPrep;

if UMBatch == 0
    fprintf('UMBatchPrep failed.')
    results = -70;
    UMCheckFailure(results);
    return
end

% Only proceed if successful.

fprintf('Entering UMBatchPrinComp V1.0 SPM8 Compatible\n');

if TestFlag~=0
    fprintf('\nTesting only, no work to be done\n\n');
end

% Read in the White Matter Mask

UMWMMaskIDX = [];
if exist(UMWMMask,'file')
    UMWMMaskVol = spm_read_vols(spm_vol(UMWMMask));
    UMWMMaskIDX = find(UMWMMaskVol);
end

% Read in the CSF Mask

UMCSFMaskIDX = [];
if exist(UMCSFMask,'file')
    UMCSFMaskVol = spm_read_vols(spm_vol(UMCSFMask));
    UMCSFMaskIDX = find(UMCSFMaskVol);
end

UMMaskIDX = {UMWMMaskIDX,UMCSFMaskIDX,unique([UMWMMaskIDX;UMCSFMaskIDX])};

% Now point to the time-series data.

timeSeriesData = nifti(Images2Read);

timeSeriesDataVol = timeSeriesData.dat(:,:,:,:);

% Now turn into a space x time array.

timesSeriesDataLinear = reshape(timeSeriesDataVol,[prod(size(timeSeriesDataVol(:,:,:,1))) size(timeSeriesDataVol,4)]);

% Now get the different sets of time courses

dataFraction = min([1.0 max([dataFraction .01])]);

for iIDX = 1:3
    nSpace = length(UMMaskIDX{iIDX});
    if nSpace > 0
        fprintf('  Working on mask %d, extracting %d time-courses\n',iIDX,nSpace);
        theData = timesSeriesDataLinear(UMMaskIDX{iIDX},:);
        if detrendFlag > -1
            fprintf('  Detrending the data with an %dth order polynomial\n',detrendFlag);
            theData = spm_detrend(theData',detrendFlag)';
        end
        TVAR     = var(theData,[],2);
        TOTALVAR = sum(var(theData,[],2));
        VARIDX   = sortrows([TVAR [1:length(TVAR)]'],-1);
        NIDX     = max([2 round(dataFraction*length(TVAR))]);
        VOXIDX   = VARIDX(1:NIDX,2);
        fprintf('  Using a fraction %f with %d voxels\n',dataFraction,NIDX);
        try
            [PCCoeff PCScore PCLatent PCT2] = princomp(theData(VOXIDX,:)');
        catch
            fprintf('\n\n* * * * * * * * * * * * * * * * * * *\n');
            fprintf('* * * * * * * * * * * * * * * * * * *\n');
            fprintf('* * * * * * * PCA FAILURE * * * * * *\n');
            fprintf('* * * * * * * * * * * * * * * * * * *\n');
            fprintf('* * * * * * * * * * * * * * * * * * *\n');
            results = -1;
            return
        end
        [TimeSeriesDir TimeSeriesName] = fileparts(Images2Read);
        OutputFile = fullfile(TimeSeriesDir,[OutputNames{iIDX} TimeSeriesName,'.csv']);
        MeanTS = mean(theData,1);
        if ~ TestFlag
            csvwrite(OutputFile,[MeanTS' PCScore(:,1:min(NComponents,size(PCScore,2)))]);
            fprintf('  Wrote to the file %s\n',OutputFile);
        else
            fprintf('  Would have written to the file %s\n',OutputFile);
        end
        % Log that we finished this portion.
        
        UMBatchLogProcess(TimeSeriesDir,sprintf('UMBatchPrinComp : Calculated %s PCA (%d) for %s',OutputNames{iIDX},NIDX,Images2Read));
    end
end

results  = cputime - results;

fprintf('  PCA Analysis all completed in %f seconds\n\n',results);

return
