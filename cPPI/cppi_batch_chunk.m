function results = cppi_batch_chunk(chunkFile)
    spm_jobman('initcfg');
    spm_get_defaults('cmdline',true);
    results = -1;
    global mcLog;
    load(chunkFile);
    mc_Logger('log',sprintf('Current MATLAB PID: %d\n',feature('GetPID')),3);
    SubjDir = tempSubjDir;
    for iSubject = 1:size(SubjDir,1)
        clear D0 parameters results;
        Subject=SubjDir{iSubject,1};
        
        logstring = sprintf('%s: Now running subject %s\n',datestr(now),Subject);
        mc_Logger('log',logstring,3);
    
        %load existing parameter file
        OutputPath = mc_GenPath(OutputTemplate);
        load(fullfile(OutputPath,ParameterFilename));
        clear global SOM;
        global SOM;
        SOM.silent = 1;
        SOM_LOG('STATUS : 01');

        [D0 parameters] = SOM_PreProcessData(parameters);
        if D0 == -1
            SOM_LOG('FATAL ERROR : No data returned');
            mc_Error('There is something wrong with your template or your data. No data was returned from SOM_PreProcessData');
        else
            results = cppi_ConnectomicPPI(D0,parameters);
            if isnumeric(results)
                SOM_LOG('FATAL ERROR : ');
                mc_Error('There is something wrong with your template or your data. No results were returned from SOM_CalculateCorrelations');
            end
        end 
        
        logstring = sprintf('%s: Finished subject %s\n',datestr(now),Subject);
        mc_Logger('log',logstring,3);
    end
return;