function Results = qc_slice_mc_central(Opt)
%
% Input: 
%   Opt.
%       Exp  -  Experiment top dir
%       List.
%           Subjects {Subjects,IncludedRuns}
%           Runs      - list of run name folders
%       ImageTemplate - path template to image locations
%       FileExp       - prefix of scan images to use
%       OutlierText   - full path to output text file
%       Thresh        - z-score threshold value
%
Results = -1;

% Check everything first
Exp = Opt.Exp;
checkedFiles = qc_CheckSliceOpt(Opt);
if isempty(checkedFiles)
    return;
end

fid = fopen(mc_GenPath(Opt.OutlierText),'w');
fprintf(fid,'SLICE WALL OF SHAME\n');

% Perform calculations
fprintf(1,'Calculating metrics...\n');
for i = 1:size(checkedFiles,1)
    fprintf(1,'Subject: %s Run: %s\n',checkedFiles{i,2},checkedFiles{i,3});
    metrics = qc_CalcSliceMetrics(checkedFiles{i,1});
    if ~isempty(metrics)
        [pathstr file ext] = fileparts(checkedFiles{i,1});
        save(fullfile(pathstr,'sliceMetrics.mat'),'metrics');
        qc_SliceReport(metrics,fullfile(pathstr,'sliceMetrics.ps'));
        
        [z t] = find(metrics.SliceZScore > Opt.Thresh);
        if ~isempty(z)
            fprintf(fid,'Image:\n');
            fprintf(fid,'%s\n',metrics.Fname);
            fprintf(fid,'{\n');
            for l = 1:length(z)
                fprintf(fid,'\tslice: %3d timepoint: %3d z-score: %2.3f mse: %3.3f\n',z(l)-1,t(l)-1,metrics.SliceZScore(z(l),t(l)),metrics.SliceTmse(z(l),t(l)));
            end
            fprintf(fid,'}\n');
        end
    end
end
        
fclose('all');
fprintf(1,'All done!\n');
Results = 1;

% Log usage
str = sprintf('%d runs processed.\n',size(checkedFiles,1));
mc_Usage(str,'CheckSlice');

