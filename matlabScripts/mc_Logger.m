function result = mc_Logger(cmd,argument)
    result = 0;
    global mcLog;
    global mcRoot;
    switch(lower(cmd))
        case 'setup'
            %create copy of template script and create log file
            [st i] = dbstack('-completenames');
            callingscript = st(end).file;
            [p f e ans] = fileparts(callingscript);
            rightnow = now;
            scriptcopy = fullfile(argument,[f '_' datestr(rightnow,'yyyy-mm-dd_HHMMSSFFF') e]);
            scriptlog = fullfile(argument,[f '_' datestr(rightnow,'yyyy-mm-dd_HHMMSSFFF') '.log']);
            
            headertxt = '';
            lines = 0;
            if (exist(fullfile(mcRoot,'.local/mc_releasetag')))
                if (exist(fullfile(mcRoot,'.local/CurrentVersionSHA')))
                    %prepend both release and SHA to template copy
                    headertxt = sprintf('''This script was run on %s using the Methods Core release and SHA listed below''',datestr(rightnow,'mm/dd/yyyy HH:MM:SS'));
                    shellcommand = sprintf('echo %s | cat - %s %s %s > %s',headertxt,fullfile(mcRoot,'.local/mc_releasetag'),fullfile(mcRoot,'.local/CurrentVersionSHA'),callingscript,scriptcopy);
                    lines = 3;
                else
                    %prepend just release to template copy
                    headertxt = sprintf('''This script was run on %s using the Methods Core release listed below''',datestr(rightnow,'mm/dd/yyyy HH:MM:SS'));
                    shellcommand = sprintf('echo %s | cat - %s %s > %s',headertxt,fullfile(mcRoot,'.local/mc_releasetag'),callingscript,scriptcopy);
                    lines = 2;
                end
            else
                if (exist(fullfile(mcRoot,'.local/CurrentVersionSHA')))
                    %prepend just SHA to template copy
                    headertxt = sprintf('''This script was run on %s using the Methods Core SHA listed below''',datestr(rightnow,'mm/dd/yyyy HH:MM:SS'));
                    shellcommand = sprintf('echo %s | cat - %s %s > %s',headertxt,fullfile(mcRoot,'.local/CurrentVersionSHA'),callingscript,scriptcopy);
                    lines = 2;
                else
                    %neither release nor SHA exist, just make template copy
                    headertxt = sprintf('''This script was run on %s''',datestr(rightnow,'mm/dd/yyyy HH:MM:SS'));
                    shellcommand = sprintf('echo %s | cat - %s > %s',headertxt,callingscript,scriptcopy);
                    lines = 1;
                end
            end  
            [status r] = system(shellcommand);
            if (status ~= 0)
                mc_Error(r);
            end
            shellcommand = sprintf('sed -i ''%s,%s s/^/%%/'' %s',num2str(1),num2str(lines),scriptcopy);
            [status r] = system(shellcommand);
            if (status ~= 0)
                mc_Error(r);
            end
            
            mcLog = scriptlog;
            result = 1;
        case 'log'
            %log argument to log file
            if (isempty(mcLog))
                %no log file defined
                %just return so that scripts using mc_Error but not mcLog global
                %can still function without errors
                return;
            end
            if (exist('argument')~=1 || isempty(argument))
                %function called but we didn't get anything to log
                return;
            end
            fid = fopen(mcLog,'a');
            if (fid == -1)
                %could not open file for some reason
                mc_Error('Could not open logfile %s for writing.',mcLog);
            end
            fprintf(fid,'%s\n',argument);
            result = 1;
    end
    
return;
