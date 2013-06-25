function RunContrastAddOn(Subjects, opt)
%   RunContrastAddOn(Subjects, opt)

    NumSubjects = size(Subjects, 2);
    SubjSpmMatFiles = cell(NumSubjects, 1);

    % Check to make sure spm mat files exist
    for i = 1:NumSubjects
        SpmCheck.Template = fullfile(Subjects(i).OutputDir, 'SPM.mat');
        SpmCheck.mode = 'check';
        SubjSpmMatFiles = mc_GenPath(SpmCheck);
    end

    % Run contrast add-on now
    for i = 1:NumSubjects
        matlabbatch{1}.spm.stats.con.spmmat = { spmMatFile{i} };
        for k = 1:size(AllSubjects(i).contrasts, 1)

            % check to make sure we have a valid contrast
            if all( AllSubjects(i).contrasts(k, :) == 0 )

                % enter in dummy contrast and log it
                msg = sprintf(['SUBJECT : %s' ...
                               ' INVALID CONTRAST NUMBER %d.  Inserting dummy contrast.\n'], ...
                               AllSubjects(i).name, k);
                fprintf(1, msg);
                mc_Logger(msg);

                matlabbatch{1}.spm.stats.con.consess{k}.tcon.name = 'DummyDoNotUseThisContrast';
                matlabbatch{1}.spm.stats.con.consess{k}.tcon.convec = 1;
                matlabbatch{1}.spm.stats.con.consess{k}.tcon.sessrep = 'none';
            else
                                 
                matlabbatch{1}.spm.stats.con.consess{k}.tcon.name = opt.ContrastList{k, 1};
                matlabbatch{1}.spm.stats.con.consess{k}.tcon.convec = AllSubjects(i).contrasts(k, :);
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

        spm_jobman('initcfg');
        spm('defaults', 'FMRI');
        spm_jobman('run_nogui', matlabbatch);
        clear matlabbatch;
    end
end
