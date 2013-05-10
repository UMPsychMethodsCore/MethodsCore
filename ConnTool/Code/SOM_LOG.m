% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% SOM_LOG
%
% Log output to the screen and to a text heap
%
% logStr = SOM_LOG('literal string');
%
% If you want to access the log put the following code into your 
% own function
%
%    global SOM
% 
% the log is then accessible via
%
%    SOM.LOG
%
% We have multiple logging levels
% 
%    FATAL     -- always written
%    WARNING   -- only if SOM.silent = 2
%    STATUS    -- only if SOM.silent = 1
%    INFO      -- really boring stuff only if SOM.silent == 0
%    [unknown] -- if we don't find one of the words above then we always
%                 write.
%
%             unknown   INFO   STATUS  WARNING  FATAL
% SOM.silent  
% 
%     0          yes     yes    yes     yes     yes
%     1          yes     no     yes     yes     yes
%     2          yes     no     no      yes     yes
%     3          yes     no     no      no      yes
%
% We scan for the word in the first part of the passed string and make a
% guess. This is a bit loose, but good enough.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function logStr = SOM_LOG(inputLog)

global SOM

LOGLEVELS = {'INFO','STATUS','WARNING','FATAL'};

[ST STI] = dbstack;

% The logic of the combination of log type and logging level.

LOGOUTMATRIX = [ 
    1 1 1 1 1;
    1 0 1 1 1;
    1 0 0 1 1;
    1 0 0 0 1];

% Initialize the logging level if necessary.

if ~isfield(SOM,'silent')
    SOM.silent = 0;
end

if SOM.silent < 0
    SOM.silent = 0 
end

if SOM.silent > 3
    SOM.silent = 3;
end

% Always at the beginning of the log we write out that we are beginning the
% log.

if isfield(SOM,'LOG') == 0
    SOM.LOG = [];
    tmp = SOM.silent;
    SOM.silent = 0;
    SOM_LOG('INFO -- Starting LOGGING');
    SOM.silent = tmp
end

inputLog = sprintf('%d:%02d:%02d:%02d:%02d:%02d : %30s/%04d : %s\n',fix(clock),ST(min([2 length(ST)])).name,ST(min([2 length(ST)])).line,inputLog);

THISLEVEL = 1;

for iLEVEL = 1:4
    if length(findstr(LOGLEVELS{iLEVEL},upper(inputLog))) > 0
        THISLEVEL = iLEVEL+1;
    end
end

SOM.LOG = strvcat(SOM.LOG,inputLog);

% If the combination indicates writting out then we do.

if LOGOUTMATRIX(SOM.silent+1,THISLEVEL)
    fprintf(inputLog)
end

logStr = SOM.LOG;

return
