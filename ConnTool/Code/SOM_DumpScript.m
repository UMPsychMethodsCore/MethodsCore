% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
%
% Robert C. Welsh
% Copyright 2011
%
% Ann Arbor, MI
%
% function results = SOM_DumpScript(name)
%
% This will read in a text script file name and 
% return as one long string.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function results = SOM_DumpScript(scriptName)

try
    results = [];
    theFID = fopen(scriptName,'r');
    READING = 1;
    while READING
        theLine = fgetl(theFID);
        if isnumeric(theLine) && theLine == -1
            READING = 0;
            fclose(theFID);
            return
        else
            results = strvcat(results,theLine);
        end
    end
catch
    results = -1;
    SOM_LOG(sprintf('WARNING : Error trying to archive the script : %s',scriptName));
    return
end

return
