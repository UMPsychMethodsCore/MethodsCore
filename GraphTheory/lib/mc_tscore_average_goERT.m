Exp = '/net/data4/MAS/';
SessionDir = {
    'Tx1/';
    'Tx2/';
    };
RunDir = {
    'run05';
    'run06';
    };
NetworkTemplate  = '[Exp]/FirstLevel/[Subject]/[Session]/MSIT/HRF/FixDur/Congruency_NORT_new_cppi_norm/Congruency_NORT_new_cppi_norm_cppi_grid.mat';
OutputPathTemplate = '[Exp]/FirstLevel/[Subject]/[Session]/MSIT/HRF/FixDur/Congruency_NORT_new_cppi_norm/Congruency_NORT_new_cppi_norm_tscore_[Run]';

SubjDir = {
    '5001',[1 2],[1 2]
    '5002',[1 2],[1 2]
    '5003',[1 2],[1 2]
    '5004',[1 2],[1 2]
    '5005',[1 2],[1 2]
    '5010',[1 2],[1 2]
    '5012',[1 2],[1 2]
    '5014',[1 2],[1 2]
    '5015',[1 2],[1 2]
    '5016',[1 2],[1 2]
    '5017',[1 2],[1 2]
    '5018',[1 2],[1 2]
    '5019',[1 2],[1 2]
    '5020',[1 2],[1 2]
    '5021',[1 2],[1 2]
    '5023',[1 2],[1 2]
    '5024',[1 2],[1 2]
    '5025',[1 2],[1 2]
    '5026',[1 2],[1 2]
    '5028',[1 2],[1 2]
    '5029',[1 2],[1 2]
    '5031',[1 2],[1 2]
    '5032',[1 2],[1 2]
    '5034',[1 2],[1 2]
    '5035',[1 2],[1 2]
    '5036',[1 2],[1 2]
    '5037',[1 2],[1 2]
    '5038',[1 2],[1 2]
    '5039',[1 2],[1 2]
    '5040',[1 2],[1 2]
    '5041',[1 2],[1 2]
    '5042',[1 2],[1 2]
    };

for iSubject = 1:size(SubjDir,1)
    Subject = SubjDir{iSubject,1};
    for jSession = 1:2
        SessionNum = SubjDir{iSubject,3}(jSession);
        Session    = SessionDir{SessionNum};
        
        NetworkPathCheck  = struct('Template',NetworkTemplate,'mode','check');
        NetworkPath       = mc_GenPath(NetworkPathCheck);
        NetworkParameters = load(NetworkPath,'cppi_grid');
        
        for kRun = 1:2
            Run    = RunDir{kRun};
            
            display(sprintf('Now computing %s',Run));
            display(sprintf('in %s',Session));
            display(sprintf('of %s',Subject));
            loc = 5*(kRun-1)+3;
            NetworkAverage = (NetworkParameters.cppi_grid{3,loc} + NetworkParameters.cppi_grid{3,loc+1})./2;
            OutputNetwork  = mc_GenPath(struct('Template',OutputPathTemplate,...
                'suffix','.mat',...
                'mode','makeparentdir'));
            save(OutputNetwork,'NetworkAverage');
            
        end
        
    end
end

