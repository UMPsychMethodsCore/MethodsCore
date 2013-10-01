function Results = qc_slice_mc_central(Opt)
%
% Input: 
%   Opt.
%       Exp  -  Experiment top dir
%       List.
%           Subjects {Subjects, subjectNumber, IncludedRuns}
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

outlierTextFile.Template = Opt.OutlierText;
outlierTextFile = mc_GenPath(outlierTextFile);

metricsList = cell(size(checkedFiles, 1), 1);

% Perform calculations
fprintf(1,'Calculating metrics...\n');
for i = 1:size(checkedFiles,1)
    fprintf(1,'Subject: %s Run: %s\n',checkedFiles{i,2},checkedFiles{i,3});
    metricsList{i} = qc_CalcSliceMetrics(checkedFiles{i,1});

    % Now log each subject
    RunsChecked = size(checkedFiles{i, 3}, 1);
    str = sprintf('Subject:%s Runs:%d CheckSlice complete\n', checkedFiles{i, 2}, RunsChecked);
    mc_Usage(str, 'CheckSlice');
     
    if ~isempty(metricsList{i})
        [pathstr file ext] = fileparts(metricsList{i}.Fname);
        metrics = metricsList{i};
        save(fullfile(pathstr,'sliceMetrics.mat'),'metrics');
        qc_SliceReport(metrics,fullfile(pathstr,'sliceMetrics.ps'));
    end
end

% Now write wall of shame and csv files
wosFid = fopen(outlierTextFile, 'w');
fprintf(wosFid, 'SLICE WALL OF SHAME\n');
for i = 1:size(metricsList, 1)
    [pathstr file ext] = fileparts(metricsList{i}.Fname);
    sliceFid = fopen(fullfile(pathstr,'sliceOutliers.csv'), 'w');

    if isempty(metricsList{i}) == 0
        [z t] = find(metricsList{i}.SliceZScore > Opt.Thresh);

        if ~isempty(z)
            % append to wall of shame
            fprintf(wosFid,'Image:\n');
            fprintf(wosFid,'%s\n',metricsList{i}.Fname);
            fprintf(wosFid,'{\n');
            for l = 1:length(z)
                fprintf(wosFid,'\tslice: %3d timepoint: %3d z-score: %2.3f mse: %3.3f\n',z(l)-1,t(l)-1, metricsList{i}.SliceZScore(z(l),t(l)), metricsList{i}.SliceTmse(z(l),t(l)));
            end
            fprintf(wosFid,'}\n');

            % write csv file
            if sliceFid ~= -1
                frames = unique(t);
                censorMatrix = zeros(metricsList{i}.Dimensions(4), length(frames));
                censorIndex = sub2ind(size(censorMatrix), frames, [1:length(frames)]');
                censorMatrix(censorIndex) = 1;
                for k = 1:size(censorMatrix, 1)
                    for l = 1:(size(censorMatrix, 2) - 1)
                        fprintf(sliceFid, '%f,', censorMatrix(k, l));
                    end
                    fprintf(sliceFid, '%f\n', censorMatrix(k, end));
                end
            else
                fprintf(1, 'WARNING: Cannot write csv file for %s\n', metricsList{i}.Fname);
            end
        end
    end
    fclose(sliceFid);
end
   
        
fclose('all');
fprintf(1,'All done!\n');
Results = 1;
