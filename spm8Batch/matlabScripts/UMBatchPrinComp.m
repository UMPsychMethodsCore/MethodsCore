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

UMMaskIDX   = {UMWMMaskIDX,UMCSFMaskIDX,unique([UMWMMaskIDX;UMCSFMaskIDX])};
UMMaskNames = {UMWMMask,UMCSFMask,'Both Mask'};

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
            PCAResults = UMBatchPCA(theData(VOXIDX,:)');
            %[PCCoeff PCScore PCLatent PCT2] = princomp(theData(VOXIDX,:)');
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
            csvwrite(OutputFile,[MeanTS' PCAResults.TC(:,1:min(NComponents,size(PCAResults.TC,2)))]);
            fprintf('  Wrote to the file %s\n',OutputFile);
        else
            fprintf('  Would have written to the file %s\n',OutputFile);
        end
        PCALogFile = fullfile(TimeSeriesDir,[OutputNames{iIDX} TimeSeriesName,'.log']);
        PCAFID     = fopen(PCALogFile,'a');
        THECLOCK   = clock;
        THEDATE    = sprintf('%4d-%02d-%02d %02d:%02d:%02d',round(THECLOCK(1:6)));
        if PCAFID > 0
            fprintf(PCAFID,'* * * * * * * PCA Analysis of %s * * * * * * * \n\n',OutputNames{iIDX});
            fprintf(PCAFID,'  Report on %s\n\n',THEDATE);
            fprintf(PCAFID,'  Total number of components found : %d\n\n',size(PCAResults.TC,2));
            fprintf(PCAFID,'  Total Variance in time series    : %e\n\n',PCAResults.totalVar);
            fprintf(PCAFID,'  Total Variance after global mean : %e %1.3f\n\n',PCAResults.varMean,1-PCAResults.varMean/PCAResults.totalVar);
            fprintf(PCAFID,'  Variance Report\n');
            fprintf(PCAFID,'  Variance Remaining   Fraction Explained   Cumulative Fraction\n');
            fprintf(PCAFID,'  ------------------   ------------------   ------------------\n');
            for IC = 1:length(PCAResults.varComp)
                fprintf(PCAFID,'      %6.2f               %1.3f                %1.3f\n',...
                    PCAResults.varComp(IC),1-PCAResults.varComp(IC)/PCAResults.totalVar,...
                    sum(PCAResults.totalVar-PCAResults.varComp(1:IC))/PCAResults.totalVar);
            end
            fprintf(PCAFID,'\n\n* * * * * REPORT FINISHED * * * * *\n');
            fclose(PCAFID);
        end
       
        % Log that we finished this portion.
        
        UMBatchLogProcess(TimeSeriesDir,sprintf('UMBatchPrinComp : Calculated %s PCA (%d) for %s',OutputNames{iIDX},NIDX,Images2Read));
        UMBatchLogProcess(TimeSeriesDir,sprintf('UMBatchPrinComp : Mask : %s',UMMaskNames{iIDX}));
        UMBatchLogProcess(TimeSeriesDir,sprintf('UMBatchPrinComp : Output in : %s',OutputFile));
        UMBatchLogProcess(TimeSeriesDir,sprintf('UMBatchPrinComp : Report in : %s',PCALogFile));
    
    end
end

results  = cputime - results;

fprintf('  PCA Analysis all completed in %f seconds\n\n',results);

return
