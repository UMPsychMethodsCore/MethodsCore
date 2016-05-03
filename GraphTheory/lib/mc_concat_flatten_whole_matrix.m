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

Exp = '/net/data4/MAS/';
SessionDir = {
    'Tx1/';
    'Tx2/';
    };
RunDir = {
    'run05';
    'run06';
    };

TscoreTemplate = '[Exp]/FirstLevel/[Subject]/[Session]/MSIT/HRF/FixDur/Congruency_NORT_new_cppi_norm/Congruency_NORT_new_cppi_norm_tscore_[Run].mat';
OutputPathTemplate = '[Exp]/FirstLevel/Concatenated_Tscore';

Output = [];

for iSubject = 1:size(SubjDir,1)
    Subject = SubjDir{iSubject,1};
    for jSession = 1:2
        SessionNum = SubjDir{iSubject,3}(jSession);
        Session    = SessionDir{SessionNum};
        
        for kRun = 1:2
            Run    = RunDir{kRun};
            
            display(sprintf('Now flatting %s',Run));
            display(sprintf('in %s',Session));
            display(sprintf('of %s',Subject));
            
            TscorePathCheck  = struct('Template',TscoreTemplate,'mode','check');
            TscorePath       = mc_GenPath(TscorePathCheck);            
            Tscore = load(TscorePath);
            squaremat = Tscore.NetworkAverage;            
            squaremat = +squaremat; % Coerce away from logical            
            if any(isnan(squaremat(:)))
                error('problematic matrix');
            end            
            flatmat = squaremat(1:end);       
            Output = [Output;flatmat];
                        
        end
        
    end
end

OutputTscore  = mc_GenPath(struct('Template',OutputPathTemplate,...
    'suffix','.mat',...
    'mode','makeparentdir'));
save(OutputTscore,'Output');







