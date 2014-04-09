function mc_Error(errorString,varargin)
% A utility function to make error handling and logging more compact
% A single call to mc_Error will log the error to the global mcLog, 
% bring up an error dialog box with your error message, and actually throw
% an exception with the Matlab error function.
%
% FORMAT mc_Error(errorString,other variable arguments)
%
% errorString             This is a string message that will be displayed
%                         to the user.  This can either be a simple string,
%                         or it can take the format of an sprintf
%                         formatting string using % format specifiers (see
%                         sprintf documentation for more information about
%                         these format strings).  
%
% other variables         If you are using the sprintf format string, you
%                         need to pass in the other variables that need to
%                         appear in the formatted string.
%
% EXAMPLES
%    mc_Error('File does not exist.');
%    mc_Error('File %s does not exist.',filename);
%    mc_Error('File %s does not exist at path %s.',filename, folder);
%    mc_Error('You specified %d images but I found %d.\nPlease double 
%              check subject %s folder %s for images.',NumScan(iRun),
%              size(P,1),subjDir,RunDir{iRun});

    if (~isempty(varargin))
        formatcount = size(strfind(errorString,'%'),2);
        if (formatcount == size(varargin,2))
            errormsg = sprintf(errorString,varargin{:});
        else
            mc_Error('Found %d format specifiers but %d other variables were provided.\n\nError String: %s\n',formatcount,size(varargin,2),errorString);
            
        end
    else
        errormsg = errorString;
    end
    
    global mcLog
    if (~isempty(mcLog))
        %call logging function
        mc_Logger('log',errormsg,1);
    end
    errordlg(errormsg);
    error(errormsg);
    
    