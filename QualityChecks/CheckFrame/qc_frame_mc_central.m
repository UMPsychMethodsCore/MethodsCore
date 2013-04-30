function Results = qc_frame_mc_central(Opt)
%
% Input: 
%   Opt.
%       Exp  -  Experiment top dir
%       List.
%           Subjects {Subjects,IncludedRuns}
%           Runs     - list of run name folders
%       Postpend.
%           Exp      - what goes after Exp
%           Subjects - what goes after .List.Subjects{:,1}
%           Runs     - what goes after Runs
%       FileExp      - Regexp for file names
%       OutlierText  - full path to output text file
%       Thresh       - mean diff z-score threshold value
%
Results = -1;

% Check everything first
checkedFiles = qc_CheckFrameOpt(Opt);
if isempty(checkedFiles)
    return;
end

Exp = Opt.Exp;
OutlierText.Template = Opt.OutlierText;
fid = fopen(mc_GenPath(OutlierText),'w');
fprintf(fid,'FRAME WALL OF SHAME\n');

% Perform calculations
fprintf(1,'Calculating outliers...\n');
for i = 1:size(checkedFiles,1)
    fprintf(1,'Subject: %s Run: %s\n',checkedFiles{i,2},checkedFiles{i,3});
    out = qc_CalcFrameMetrics(checkedFiles{i,1});
    if ~isempty(out)
        [pathstr file ext] = fileparts(checkedFiles{i,1});
        qc_FrameReport(out,fullfile(pathstr,'frameReport.ps'),Opt.Thresh);
        
        % wriate out csv file for the run
        t = find(abs(out{3}) > Opt.Thresh);
        qc_WriteFrameCsv(fullfile(pathstr,'frameOutliers.csv'),t,length(out{3}));
        
        % append to FRAME WALL OF SHAME file
        if ~isempty(t)
            fprintf(fid,'Image:\n');
            fprintf(fid,'%s\n',checkedFiles{i,1});
            fprintf(fid,'{\n');
            for k = 1:length(t)
                fprintf(fid,'\ttimepoint: %3d MeanIntensity: %4.3f z-score: %2.3f DiffZScore: %2.3f mse: %4.3f\n',t(k)-1,out{1}(t(k)-1),out{2}(t(k)-1),out{3}(t(k)-1),out{4}(t(k)-1));
                fprintf(fid,'\ttimepoint: %3d MeanIntensity: %4.3f z-score: %2.3f DiffZScore: %2.3f mse: %4.3f\n',t(k),out{1}(t(k)),out{2}(t(k)),out{3}(t(k)),out{4}(t(k)));
            end
            fprintf(fid,'}\n');
        end
    end
end
        
fclose('all');
fprintf(1,'All done!\n');
Results = 1;

str = sprintf('%d runs checked\n',size(checkedFiles,1));
mc_Usage(str,'CheckFrames');