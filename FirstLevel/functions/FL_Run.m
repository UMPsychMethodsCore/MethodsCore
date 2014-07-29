function FL_Run(AllSubjects, opt)
%   FL_Run(AllSubjects, opt)

    for i = 1:size(AllSubjects, 2)

        % Make output directory here
        OutputDir = HandleDirectory(AllSubjects(i).outputDir, opt);

        matlabbatch{1}.spm.stats.fmri_spec.dir = { OutputDir };
        matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
        matlabbatch{1}.spm.stats.fmri_spec.timing.RT = opt.TR;
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = opt.fMRI_T0;

        for k = 1:size(AllSubjects(i).sess, 2)

            % Copy images to sandbox here
            if opt.UseSandbox == 1
                AllSubjects(i).sess(k).images = CopyToSandbox(opt, AllSubjects(i).sess(k).images, AllSubjects(i).name, AllSubjects(i).sess(k).name);
            end

            matlabbatch{1}.spm.stats.fmri_spec.sess(k).scans = AllSubjects(i).sess(k).images;

            % handle conditions
            condIndex = 1;
            matlabbatch{1}.spm.stats.fmri_spec.sess(k).cond = [];
            for m = 1:size(AllSubjects(i).sess(k).cond, 2)

                if AllSubjects(i).sess(k).cond(m).use == 1

                    matlabbatch{1}.spm.stats.fmri_spec.sess(k).cond(condIndex).name = AllSubjects(i).sess(k).cond(m).name;
                    matlabbatch{1}.spm.stats.fmri_spec.sess(k).cond(condIndex).onset = AllSubjects(i).sess(k).cond(m).onset;
                    matlabbatch{1}.spm.stats.fmri_spec.sess(k).cond(condIndex).duration = AllSubjects(i).sess(k).cond(m).duration;
                    matlabbatch{1}.spm.stats.fmri_spec.sess(k).cond(condIndex).tmod = 0;

                    % handle parametric regressors of conditons
                    pmodIndex = 1;
                    matlabbatch{1}.spm.stats.fmri_spec.sess(k).cond(condIndex).pmod = struct('name', {}, 'param', {}, 'poly', {});

                    for iPar = 1:AllSubjects(i).sess(k).cond(m).usePMod
                        if ~isempty(AllSubjects(i).sess(k).cond(m).pmod(iPar).param) == 1
                            matlabbatch{1}.spm.stats.fmri_spec.sess(k).cond(condIndex).pmod(pmodIndex).name = AllSubjects(i).sess(k).cond(m).pmod(iPar).name;
                            matlabbatch{1}.spm.stats.fmri_spec.sess(k).cond(condIndex).pmod(pmodIndex).param = AllSubjects(i).sess(k).cond(m).pmod(iPar).param;
                            matlabbatch{1}.spm.stats.fmri_spec.sess(k).cond(condIndex).pmod(pmodIndex).poly = AllSubjects(i).sess(k).cond(m).pmod(iPar).poly;

                            pmodIndex = pmodIndex + 1;
                        end
                    end
                    
                    condIndex = condIndex + 1;
                end
            end

            % handle regressors for session
            matlabbatch{1}.spm.stats.fmri_spec.sess(k).multi = {''};
            matlabbatch{1}.spm.stats.fmri_spec.sess(k).multi_reg = {''};

            % regressors from RegFileTemplate
            matlabbatch{1}.spm.stats.fmri_spec.sess(k).regress = struct('name', {}, 'val', {});
            for m = 1:size(AllSubjects(i).sess(k).regress, 2)
                matlabbatch{1}.spm.stats.fmri_spec.sess(k).regress(m).name = AllSubjects(i).sess(k).regress(m).name;
                matlabbatch{1}.spm.stats.fmri_spec.sess(k).regress(m).val = AllSubjects(i).sess(k).regress(m).val;
            end

            matlabbatch{1}.spm.stats.fmri_spec.sess(k).hpf = 128;
        end

        matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});

        % handle bases function
        if strcmp(opt.Basis, 'hrf') == 1
            if opt.HrfDerivative == 0
                matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
            elseif opt.HrfDerivative == 1
                matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [1 0];
            elseif opt.HrfDerivative == 2
                matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [1 1];
            else
                error('How did you get here? Invalid HrfDerivative value.');
            end
        elseif strcmp(opt.Basis, 'fir') == 1
            matlabbatch{1}.spm.stats.fmri_spec.bases.fir.length = opt.FirDuration;
            matlabbatch{1}.spm.stats.fmri_spec.bases.fir.order = opt.FirBins;
        else
            error('How did you get here? Invalid first level basis.');
        end
            
        matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
        matlabbatch{1}.spm.stats.fmri_spec.global = opt.ScaleOp;
        matlabbatch{1}.spm.stats.fmri_spec.mask = { opt.ExplicitMask };
        
        if opt.usear1 == 1
            matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
        else
            matlabbatch{1}.spm.stats.fmri_spec.cvi = 'none';
        end

        % estimate model
        spmMatFile = fullfile(AllSubjects(i).outputDir, 'SPM.mat');
        matlabbatch{2}.spm.stats.fmri_est.spmmat = { spmMatFile };
        matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

        % create contrasts
        matlabbatch{3}.spm.stats.con.spmmat = { spmMatFile };
        for k = 1:size(AllSubjects(i).contrasts, 1)

            % check to make sure we have a valid contrast
            if all( AllSubjects(i).contrasts(k, :) == 0 )

                % enter in dummy contrast and log it
                msg = sprintf(['SUBJECT : %s' ...
                               ' INVALID CONTRAST NUMBER %d.  Inserting dummy contrast.\n'], ...
                               AllSubjects(i).name, k);
                fprintf(1, msg);
                mc_Logger(msg);

                matlabbatch{3}.spm.stats.con.consess{k}.tcon.name = 'DummyDoNotUseThisContrast';
                matlabbatch{3}.spm.stats.con.consess{k}.tcon.convec = 1;
                matlabbatch{3}.spm.stats.con.consess{k}.tcon.sessrep = 'none';
            else

                matlabbatch{3}.spm.stats.con.consess{k}.tcon.name = opt.ContrastList{k, 1};
                matlabbatch{3}.spm.stats.con.consess{k}.tcon.convec = AllSubjects(i).contrasts(k, :);
                matlabbatch{3}.spm.stats.con.consess{k}.tcon.sessrep = 'none';
            end
        end
        matlabbatch{3}.spm.stats.con.delete = 0;

        % save matlabbatch job
        save(fullfile(OutputDir, 'JobFile.mat'), 'matlabbatch');

        spm_jobman('initcfg');
        spm('defaults', 'FMRI');
        spm_jobman('run_nogui', matlabbatch);
        clear matlabbatch;

        % log usage
        str = sprintf('Subject:%s FirstLevel complete\n', AllSubjects(i).name);
        mcUsageReturn = mc_Usage(str,'FirstLevel');
        if ~mcUsageReturn
            mc_Logger('log','Unable to write some usage information',2);
        end

        % move from sandbox to correct output directory
        if opt.UseSandbox == 1
            MoveSandboxOutput(OutputDir, AllSubjects(i).OutputDir);           
        end
    end

    % remove sandbox directory if necessary
    if opt.UseSandbox == 1
        RemoveSandbox(opt.Sandbox);
    end
end
        
function SandboxOutputDir = HandleDirectory(SubjOutputDir, opt)
% OutputDir = HandelDirectory(SubjOutputDir, opt)

    % check if output directory already exists and handle it
    if (exist(SubjOutputDir,'dir') && opt.Mode == 1) 

        % log removal of old dir
        msg = sprintf('Output directory %s already exists.  Directory is going to be removed and replaced with new output.\n\n', SubjOutputDir);
        fprintf(1, msg);
        mc_Logger('log', msg, 2);

        result = rmdir(SubjOutputDir,'s');
        if (result == 0)
            mc_Error('Output directory %s\nalready exists and cannot be removed. Please check you permissions.', SubjOutputDir);
        end

    end

    % handle sandbox and create output directory
    SandboxOutputDir = mc_GenPath(fullfile(opt.Sandbox, SubjOutputDir));
    fprintf(1, 'I am going to save the output here: %s\n\n', SubjOutputDir);
    if opt.Mode == 1 || opt.Mode == 2
        % create subject output directory
        OutputDirCheck.Template = SubjOutputDir;
        OutputDirCheck.mode = 'makeparentdir';
        mc_GenPath(OutputDirCheck);
        % create sandbox directory
        SandboxDirCheck.Template = SandboxOutputDir;
        SandboxDirCheck.mode = 'makedir';
        mc_GenPath(SandboxDirCheck);
    end

end

function SessionImages = CopyToSandbox(opt, SessionImages, Subject, Run)
% SesionImages = CopyToSandboax(opt, SessionImages, Subject, Run)

    Exp = opt.Exp;
    
    % image dir should have been checked already
    ImageDir = mc_GenPath(opt.ImageTemplate);
    
    % copy to sandox here    
    SandboxRunCheck.Template = fullfile(opt.Sandbox, opt.ImageTemplate);
    SandboxRunCheck.mode = 'makeparentdir';
    mc_GenPath(SandboxRunCheck);
    shellcommand = sprintf('cp -af %s %s',fullfile(ImageDir,'*'),fullfile(Sandbox,ImageDir));
    [status result] = system(shellcommand);
    if (status ~= 0)
        mc_Error('Image folder %s could not be copied to sandbox.\nPlease check your paths and permissions.',ImageDir);
    end
    
    % correct image file paths
    for i = 1:size(SessionImages, 1)
        SessionImages{i} = fullfile(opt.Sandbox, SessonImages{i});
    end
end

function MoveSandboxOutput(SandboxOutDir, NoSandboxOutDir)
%   MooveSandboxOutput(SandboxOutDir, NoSandboxOutDir)

    shellcommand = sprintf('cp -rf %s %s',SandboxOutDir, NoSandboxOutDir);
    [status result] = system(shellcommand);
    if (status ~= 0)
        mc_Error('Unable to copy sandbox directory (%s) back to output directory (%s).\nPlease check paths and permissions.', SandboxOutDir, NoSandboxOutDir);
    end
    
    mc_FixSPM(NoSandboxOutDir, opt.Sandbox, '');

end


function RemoveSandbox(Sandbox)
% function RemoveSandbox(Sandbox)

    shellcommand = sprintf('rm -rf %s',Sandbox);
    [status, ans, ans] = rmdir(Sandbox,'s'); %updated to use matlab command instead of system call
    if (status ~= 0)
        mcWarnings = mcWarnings + 1;
        mc_Logger('log','Unable to remove sandbox directory',2);
    end

end
