
Opt.Exp  = '/zubdata/oracle7/Researchers/heffjos/TestSubject';

Opt.List.Subjects = {
                     'CM2001NTX',[1 2 3 4 5 6 7];
                     'CM2002NTX',[1 2 3 4 5 6 7];
                    };

Opt.List.Runs = {
                  'run_01';
                  'run_02';
                  'run_03';
                  'run_04';
                  'run_05';
                  'run_06';
                  'run_07';
                };

Opt.Postpend.Exp = '';
Opt.Postpend.Subjects = 'day4/func';
Opt.Postpend.Runs = '';

Opt.FileExp = 'rarun';

Opt.OutlierText = '/zubdata/oracle7/Researchers/heffjos/TestSubject/rarun_detected.txt';

Opt.Thresh = 4;

mcRoot = '/zubdata/apps/Tools/MethodsCore';

addpath(fullfile(mcRoot,'matlabScripts'));
addpath(fullfile(mcRoot,'QualityChecks/CheckMetrics'));
addpath(fullfile(mcRoot,'SPM','SPM8','spm8_with_R4667'));

qc_mc_central(Opt);
