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
%
% We scan for the word in the first part of the passed string and make a
% guess. This is a bit loose, but good enough.
%
% Modify to use a binary mask as to when to write out messages.
%
%  1st bit is for INFO
%  2nd bit is for STATUS
%  3rd bit is for WARNING
%
% We always write out FATAL messages.
%
% Val  Bits
% ---  ------
%  0   0 0 0   -- all messages out
%  1   0 0 1   -- no info messages out
%  2   0 1 0   -- no status messages out
%  3   0 1 1   -- no info or status messages out
%  4   1 0 0   -- no warning messages out
%  5   1 0 1   -- no info or warning messages out
%  6   1 1 0   -- no status or warning messages out
%  7   1 1 1   -- only fatal messages out.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function logStr = SOM_LOG(inputLog)

global SOM

LOGLEVELS = {'INFO','STATUS','WARN','FATAL'};

inputLog = strrep(inputLog,'INFO :'   ,'INFO    :');
inputLog = strrep(inputLog,'STATUS :' ,'STATUS  :');
inputLog = strrep(inputLog,'WARNING :','WARNING :');
inputLog = strrep(inputLog,'FATAL :'  ,'FATAL   :');
inputLog = strrep(inputLog,'OUTPUT :' ,'OUTPUT  :');

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

% Make sure an integer

SOM.silent = round(SOM.silent);

if SOM.silent < 0
    SOM.silent = 0
end

if SOM.silent > 7
    SOM.silent = 7;
end

% Get the character/bit pattern.

SOM.silentBit = dec2bin(SOM.silent);

% Now these are indexed backwards with least significant bit being at the end so let's reverse
% so that least significant is at index = 1;

SOM.silentiBit = [0 0 0 0];

iBit = 0;
for jBit = length(SOM.silentBit):-1:1
    iBit = iBit + 1;
    SOM.silentiBit(iBit) = str2num(SOM.silentBit(jBit));
end

% Always at the beginning of the log we write out that we are beginning the
% log.

if isfield(SOM,'LOG') == 0
    SOM.LOG = [];
    tmp = SOM.silent;
    SOM.silent = 0;
    SOM_LOG('INFO -- Starting LOGGING');
    SOM.silent = tmp;
end

% Find out what error level.

THISLEVEL = 1;

for iLEVEL = 1:4
    if length(findstr(LOGLEVELS{iLEVEL},upper(inputLog))) > 0
        THISLEVEL = iLEVEL;
    end
end

inputLogFATAL = sprintf('%d:%02d:%02d:%02d:%02d:%02d : %30s/%04d : %s\n',fix(clock),ST(min([2 length(ST)])).name,ST(min([2 length(ST)])).line,'* * * * * FATAL * * * *');

if THISLEVEL == 4
    fprintf(inputLogFATAL);
end

nReturn = strfind(inputLog,'\n');

if ~isempty(nReturn) && length(inputLog) == nReturn(end)+1
    inputLog = inputLog(1:nReturn(end)-1);
    nReturn(end) = [];
end

if length(nReturn) == 0
    inputLogT = inputLog;
else
    inputLogT = inputLog(1:nReturn(1)-1);
end
inputLogT = sprintf('%d:%02d:%02d:%02d:%02d:%02d : %30s/%04d : %s\n',fix(clock),ST(min([2 length(ST)])).name,ST(min([2 length(ST)])).line,inputLogT);
if ~SOM.silentiBit(THISLEVEL)
    fprintf(inputLogT);
end

SOM.LOG = strvcat(SOM.LOG,inputLog);

for iReturn = 2:length(nReturn)-1
    inputLogT = inputLog(nReturn(iReturn-1)+1:nReturn(iReturn));
    inputLogT      = sprintf('%d:%02d:%02d:%02d:%02d:%02d : %30s/%04d : %s\n',fix(clock),ST(min([2 length(ST)])).name,ST(min([2 length(ST)])).line,inputLogT);
    SOM.LOG = strvcat(SOM.LOG,inputLog);
    if ~SOM.silentiBit(THISLEVEL)
        fprintf(inputLogT);
    end
end

if length(nReturn) > 0
    inputLogT = inputLog(nReturn(end)+2:end);
    inputLogT = sprintf('%d:%02d:%02d:%02d:%02d:%02d : %30s/%04d : %s\n',fix(clock),ST(min([2 length(ST)])).name,ST(min([2 length(ST)])).line,inputLogT);
    if ~SOM.silentiBit(THISLEVEL)
        fprintf(inputLogT);
    end
    
    SOM.LOG = strvcat(SOM.LOG,inputLog);
end

% If the combination indicates writting out then we do.

if THISLEVEL == 4
    fprintf(inputLogFATAL);
end

logStr = SOM.LOG;

return
