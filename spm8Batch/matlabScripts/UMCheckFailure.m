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
% Input:
% 
%    results < 0 then error, else not.
% 
% Output (using logical output essentially)
% 
%    errorresults  = 0, success
%                  = 1, failure 
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

function errorresults = UMCheckFailure(results)

global UMBatchProcessName

% All error code will return negative numbers.

[dbStruct] = dbstack;

if results < 0
  fprintf('* * * * * FAILURE * * * *\n')
  fprintf('     %s failed in %s.\n',UMBatchProcessName,dbStruct(min([2 length(dbStruct)])).name);
  fprintf('* * * * * FAILURE * * * *\n')
  errorresults = 1;
  UMBatchAbort;
  exit(abs(results));
end

% no error

errorresults = 0;

return

%
% all done.
%
