function result = mc_Logger(cmd,cmdstring,loglevel)
% A utility function to setup script copies and log messages to a log file
% FORMAT [result] = mc_Logger(cmd,cmdstring[,loglevel]);
% 
% cmd               this command tells mc_Logger what mode to run in.
%                   Current options are:
%                           'setup' - create a timestamped copy of the 
%                                     original calling script (usually the 
%                                     _mc_template script) and create a log
%                                     file in the given directory.  In this
%                                     mode cmdstring should contain the log
%                                     directory and loglevel is not needed.
%                           'log'   - write cmdstring to the log file.
%
% cmdstring         in 'setup' mode this should be the log file directory
%                   to use. In 'log' mode this should be the string that 
%                   will be written to the log file.
%
% loglevel          This optional argument should only be used in 'log'
%                   mode. If given, it sets the level of importance for the
%                   current cmdstring.  Current possible values are:
%                            1      - ERROR
%                            2      - WARNING
%                            3      - STATUS
%                   If not given, it defaults to 1 (ERROR).
%

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
            scriptcopy = fullfile(cmdstring,[f '_' datestr(rightnow,'yyyy-mm-dd_HHMMSSFFF') e]);
            scriptlog = fullfile(cmdstring,[f '_' datestr(rightnow,'yyyy-mm-dd_HHMMSSFFF') '.log']);
            
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
            macsedfix = '';
            if (ismac())
                macsedfix = ' ""';
            end
            shellcommand = sprintf('sed -i %s ''%s,%s s/^/%%/'' %s',macsedfix,num2str(1),num2str(lines),scriptcopy);
            [status r] = system(shellcommand);
            if (status ~= 0)
                mc_Error(r);
            end
            
            mcLog = scriptlog;
            result = 1;
        case 'log'
            if (~exist('loglevel','var') || isempty(loglevel))
                loglevel = 1;
            end
            switch(loglevel)
                case 1
                    loglevelstr = 'ERROR: ';
                case 2
                    loglevelstr = 'WARNING: ';
                case 3
                    loglevelstr = 'STATUS: ';
                otherwise
                    loglevelstr = 'UNKNOWN: ';
            end
            %log cmdstring to log file
            if (isempty(mcLog))
                %no log file defined
                %just return so that scripts using mc_Error but not mcLog global
                %can still function without errors
                return;
            end
            if (exist('cmdstring')~=1 || isempty(cmdstring))
                %function called but we didn't get anything to log
                return;
            end
            fid = fopen(mcLog,'a');
            if (fid == -1)
                %could not open file for some reason
                mc_Error('Could not open logfile %s for writing.',mcLog);
            end
            fprintf(fid,'%s\t%s\n',loglevelstr,cmdstring);
            fclose(fid);
            result = 1;
    end
    
return;
