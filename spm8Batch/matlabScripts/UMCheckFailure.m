% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Robert C. Welsh
% Ann Arbor Michigan, USA
%
% March 2012
% Copyright.
%
% Simple code to check the error status.
%
% If results == -1 then error.
%
% function UMCheckFailure(results)
%
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

function UMCheckFailure(results)

global UMBatchProcessName

if results == -1
  fprintf('* * * * * FAILURE * * * *\n')
  fprintf('     %s failed.\n',UMBatchProcessName);
  fprintf('* * * * * FAILURE * * * *\n')
end

return

%
% all done.
%
