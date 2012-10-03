loadSPM8r4667

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

Opt.ImageDir  = '[Exp]/[Subject]/day4/func/[Run]';
Opt.File.Func = 'rarun';

Opt.Detected = fullfile(Opt.Exp,'rarun_detected.txt');
Opt.Thresh   = 4;

addpath('../../matlabScripts/');

qc_mc_central(Opt);
