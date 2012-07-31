function [SPM beta Q] = lss_runSPM(SPM,jRun,iTrial)

spm_get_defaults('cmdline',true);
SPM = spm_fmri_spm_ui(SPM);

trick = 0;
modified = 1;
reg = [];
for iSess = 1:size(SPM.Sess,2)
    reg(iSess) = size(SPM.Sess(iSess).C.name,2);
end
adjust = cumsum(reg);

switch trick
    case 0
        %call modified spm_spm code
        if (modified)
            [SPM allbetas Q] = lss_spm_spm(SPM);
            beta = allbetas(jRun+adjust(jRun),:); %need to adjust this for possible regressor columns
            
        else
            SPM = spm_spm(SPM);
            %now read beta image for condition 1 (find it from SPM?)
            %and return as allbetas
        end

    case 1
        %use the beta trick described in Mumford/Poldrack's pybetaseries
        %code to build an artificial pseudoinverse matrix and calculate all
        %appropriate betas simultaneously without calculating any
        %unnecessary betas.

        %loop over design matrices and calculate pseudoinverse
        %save first row of pseudoinverse and but in matrix
        %when done multiply pseudomatrix by data to get betas
        SPM = lss_spm_spm(SPM);
        %piX = pinv(SPM.xX.xKXs.X);
        piX = SPM.xX.pKX;
        beta = piX(1,:);
        Q = [];
    otherwise

end