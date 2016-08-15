[status,output] = submitJSON(JSONFile,DBTarget)

global mcRoot

cmd = sprintf('%s/bash_curl/curl_json.sh %s %s',mcRoot,JSONFile,DBTarget);

[status, output] = system(cmd);

%error handling for bad database call
%ideally this shouldn't just fail here, but we should have some trap system to catch unsubmitted jsons so they can be bulk submitted later
%maybe put them in a submitted/unsubmitted folders or something
if (status ~= 0)
    UMCheckFailure(-1);
end
