% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Robert C. Welsh
% Ann Arbor Michigan, USA
%
% March 2005-2011
% Copyright.
%
% function to move any log files out of the sandbox and put them 
% into the appropriate source directory
%
% function results = moveLogOutOfSandBox(sourceDir,SandBoxPID)
%
% souceDir is the directory where the log should be, while
% SandBoxPID is the directory where the work took place.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

function results = moveLogOutOfSandBox(sourceDir,SandBoxPID)

global UMBatchJobName
global UMBatchProcessName

try
  theSandFID = fopen(fullfile(SandBoxPID,sprintf('.%s',UMBatchProcessName)),'r');
catch
  results = -1;
  fprintf('Can not seem to open the logging file ".%s" in the sandbox %s\n',UMBatchProcessName,SandBoxPID);
  return
end

try 
  theFID = fopen(fullfile(sourceDir,sprintf('.%s',UMBatchProcessName)),'a');
catch
  fclose(theSandFID);
  results = -1
  fprintf('Can not seem to open the logging file ".%s" in the sourceDir %s\n',UMBatchProcessName,sourceDir);
  return
end

% Now move the stuff

READING = 1;

while READING
  theLine = fgetl(theSandFID);
  if theLine == -1
    READING=0;
  else
    fprintf(theFID,'%s\n',theLine);
  end
end

fclose(theFID);
fclose(theSandFID);

delete(fullfile(SandBoxPID,sprintf('.%s',UMBatchProcessName)));

results = 1;

return

%
% all done.
%