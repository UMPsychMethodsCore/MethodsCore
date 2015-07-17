function FL_RunContrastAddOn(Subjects, opt)
%   FL_RunContrastAddOn(Subjects, opt)

    NumSubjects = size(Subjects, 2);
    SubjSpmMatFiles = cell(NumSubjects, 1);

    % Check to make sure spm mat files exist
    for i = 1:NumSubjects
        SpmCheck.Template = fullfile(Subjects(i).outputDir, 'SPM.mat');
        SpmCheck.mode = 'check';
        SubjSpmMatFiles{i} = mc_GenPath(SpmCheck);
    end

    % set spm defaults before running anything
    fprintf(1, 'Setting SPM defaults...');
    spm('defaults', 'FMRI');
    spm_jobman('initcfg');
    mc_SetSPMDefaults(opt.SpmDefaults);
    fprintf(1, 'Done!\n');

    % Run contrast add-on now
    for i = 1:NumSubjects
        matlabbatch{1}.spm.stats.con.spmmat = { SubjSpmMatFiles{i} };
        for k = 1:size(Subjects(i).contrasts, 1)

            % check to make sure we have a valid contrast
            if all( Subjects(i).contrasts(k, :) == 0 )

                % enter in dummy contrast and log it
                msg = sprintf(['SUBJECT : %s\n' ...
                               ' INVALID CONTRAST NUMBER %d.  Inserting dummy contrast.\n'], ...
                               Subjects(i).name, k);
                fprintf(1, msg);
                mc_Logger(msg);

                matlabbatch{1}.spm.stats.con.consess{k}.tcon.name = 'DummyDoNotUseThisContrast';
                matlabbatch{1}.spm.stats.con.consess{k}.tcon.convec = 1;
                matlabbatch{1}.spm.stats.con.consess{k}.tcon.sessrep = 'none';
            else
                
                if opt.VarianceWeighting == 0                 
                    matlabbatch{1}.spm.stats.con.consess{k}.tcon.name = opt.ContrastList{k, 1};
                else
                    matlabbatch{1}.spm.stats.con.consess{k}.tcon.name = opt.ContrastList{1}{k, 1};
                end
                matlabbatch{1}.spm.stats.con.consess{k}.tcon.convec = Subjects(i).contrasts(k, :);
                matlabbatch{1}.spm.stats.con.consess{k}.tcon.sessrep = 'none';
            end
        end

        if opt.StartOp == 2
            matlabbatch{1}.spm.stats.con.delete = 0;
        elseif opt.StartOp == 1
            matlabbatch{1}.spm.stats.con.delete = 1;
        else
            error('Invalid StartOp value.  You should not be here');
        end

        spm_jobman('run_nogui', matlabbatch);
        clear matlabbatch;

        % log usage
        str = sprintf('Subject:%s FirstLevel complete\n', Subjects(i).name);
        mcUsageReturn = mc_Usage(str,'FirstLevelContrast');
        if ~mcUsageReturn
            mc_Logger('log','Unable to write some usage information',2);
        end
    end
end
