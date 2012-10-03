function Results = qc_mc_central(Opt)
% Opt.
%   Exp
%   Postpend.
%     Subjects  {Subjects,IncludedRuns}
%     Runs
%   Lists.
%     Subjects
%     Runs
%   File
%     Func
%   Detected
%   Thresh
nsubjects = size(Opt.List.Subjects,1);
ImageExp  = ['^' Opt.File.Func '.*nii'];

% Check everything first
Exp = Opt.Exp;
for i = 1:nsubjects
    Subject = Opt.List.Subjects{i,1};
    for k = Opt.List.Subjects{i,2}
        Run      = Opt.List.Runs{k};
        ImageDir.Template = Opt.ImageDir;
        ImageDir.mode = 'Check';
        funcDir = mc_GenPath(ImageDir);
            
        funcFile = spm_select('FPList',funcDir,ImageExp);
        if isempty(funcFile)
            fprintf(1,'FATAL ERROR: No function file in directory: %s\n',funcDir);
            fprintf(1,' * * * A B O R T I N G * * *\n');
            return;
        end
        
        if size(funcFile,1) > 1
            fprintf(1,'FATAL ERROR: Expected only one 4D functional image in directory: %s\n',funcDir);
            fprintf(1,'Please check Opt.File.Func filter\n');
            fprintf(1,' * * * A B O R T I N G * * *\n');
            return;
        end
    end
end

fid = fopen(Opt.Detected,'w');
if fid == -1
    fprintf(1,'Cannot write to %s\n',Opt.Detected);
    fprintf(1,' * * * A B O R T I N G * * *\n');
    return;
end

% Perform calculations
fprintf(1,'Calculating diagnostics...\n');
for i = 1:nsubjects
    Subject = Opt.List.Subjects{i,1};
    for k = Opt.List.Subjects{i,2}
        Run      = Opt.List.Runs{k};
        funcDir  = mc_GenPath(Opt.ImageDir);
        funcFile = spm_select('FPList',funcDir,ImageExp);

        fprintf(1,'Subject: %s Run: %s\n',Subject,Run);
        QC_metrics = qc_metrics(funcFile);
        if ~isempty(QC_metrics)
            save('results.mat','QC_metrics');
            % save in subject directory later
        
            %options.format     = 'pdf';
            %options.outputDir  = funcDir;
            %options.showCode   = false;
            %options.catchError = false;
            %publish('qc_publish.m',options);
            qc_report(QC_metrics,fullfile(funcDir,'qc_report'));
            close('all');
            
            [z t] = find(QC_metrics.SliceZScore > Opt.Thresh);
            if ~isempty(z)
                fprintf(fid,'%s\n',QC_metrics.Fname);
                for l = 1:length(z)
                    fprintf(fid,'slice: %d timepoint: %d z-score: %f mse: %f\n',z(l),t(l),QC_metrics.SliceZScore(z(l),t(l)),QC_metrics.SliceTmse(z(l),t(l)));
                end
            end
        end
    end
end
fclose('all');
fprintf(1,'All done!\n');
Results = 1;


