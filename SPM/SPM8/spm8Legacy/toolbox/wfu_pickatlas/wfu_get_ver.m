function spmversion = wfu_get_ver
spmversion = spm('Ver', [], 1);
if ~strcmp(spmversion, 'SPM99') && ~strcmp(spmversion, 'SPM2') && ~strcmp(spmversion, 'SPM5') && ~strcmp(spmversion, 'SPM8')
    if ~isempty(strfind(which('spm'), 'spm99')) || ~isempty(strfind(which('spm'), 'SPM99'))
        spmversion = 'SPM99';
    end
    if ~isempty(strfind(which('spm'), 'spm2')) || ~isempty(strfind(which('spm'), 'SPM2'))
        spmversion = 'SPM2';
    end
    if ~isempty(strfind(which('spm'), 'spm5')) || ~isempty(strfind(which('spm'), 'SPM5'))
        spmversion = 'SPM5';
    end
    if ~isempty(strfind(which('spm'), 'spm8')) || ~isempty(strfind(which('spm'), 'SPM8'))
        spmversion = 'SPM8';
    end
end
if ~strcmp(spmversion, 'SPM99') && ~strcmp(spmversion, 'SPM2') && ~strcmp(spmversion, 'SPM5') && ~strcmp(spmversion, 'SPM8')
    error(['Returned SPM version **' spmversion '** is not one of {SPM99, SPM2, SPM5, SPM8b}']);
end
