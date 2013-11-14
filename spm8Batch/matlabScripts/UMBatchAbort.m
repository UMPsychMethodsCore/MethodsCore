% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Robert C. Welsh
% Ann Arbor Michigan, USA
%
% March 2005-2012
% Copyright.
%
% UMBatchAbort
%
% This will write an abort message the passed file.
%
% Input 
% 
%    UMAbortFileName   -- this should include a full path
%
%                         typically this is based on the BASH 
%                         environmental variable UMSTREAM_STATUS_FILE
% 
% Output
%
%    results           -- 1 - success
%                         0 - failure, can't open the file.
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

function results = UMBatchAbort

global UMBatchJobName
global UMBatchProcessName
global UMBatchStatusFile

% The name UMBatchStatusFile should contain the full path.
% Only write it out if the name is there.

DBTRACE = dbstack;

if length(UMBatchStatusFile) > 0
  try
    theFID = fopen(UMBatchStatusFile,'a');
    theDATE=date;
    theHOUR=round(clock);
    theTIME=sprintf('%02d:%02d:%02d',theHOUR(4:6));
    fprintf(theFID,'%s aborted in %s at %s on %s at %s\n',UMBatchProcessName,UMBatchJobName,DBTRACE(min([3 length(DBTRACE)])).name,theDATE,theTIME);
    fclose(theFID);
    results = 1;
  catch
    fprintf('\n* * * * * * * * * * * *\n');
    fprintf('Error trying to right log file %s\n',UMBatchStatusFile);
    fprintf('\n* * * * * * * * * * * *\n');
    results = 0;
  end
end

return

%
% All done.
%