classdef wfu_LOG < handle
% wfu_LOG class
%
% reportLevel:  MINUTIA - VERY detailed.
%               INFO    - A message to be placed in the log
%               WARN    - A warning that an event happeded 
%            ** ERROR   - A non-fatal error (ex: in a try/catch) (default level)
%            ** FATAL   - A fatal, program ending error.  This will THROW
%                         AN ERROR on purpose with the message.
%
% ** These levels will write the message to screen no matter what.
%
% loc: SCREEN       - Write log to screen
%      a file name  - Write log to file
%
% logger =  wfu_LOG(reportLevel,loc)      Start the logger reporting LOG items 
%                                         of reportLevel or highter to loc.
%                                         loc is a cell of acceptable
%                                         locations.
%
% logger.level(reportLevel)               Change reporting level.
%
% logger.minutia(message,...)
% logger.info(message,...)
% logger.warn(message,...)
% logger.error(message,...)
% logger.fatal(message,...)               Write the message to the log.
%                                         Message may be a sprintf
%                                         formatted string with additional
%                                         arguments as needed.
%
%
% logger.warndlg(message,title)
% logger.errordlg(message,title)
% logger.fataldlg(message,title)          Same as non-dlg, but also pops up
%                                         a modal window with message.  Pop
%                                         up is irregardless of on/off or
%                                         level.  Title is optional name of
%                                         pop-up window.
% logger.infostack(ME)
% logger.warnstack(ME)
% logger.errorstack(ME)
% logger.fatalstack(ME)                   Takes an MException and prints a
%                                         reporting stack at specified
%                                         level.
%
% logger.report(lastN)                    List the information in the log.
%                                         If supplied with a lastN number,
%                                         only the last N items are shown.
% logger.on
% logger.off                              Turns logger on or off.  default
%                                         state is off.
%
% logger.brief                            One line log statements
% logger.long                             Multiline log statements
%
% logger.end(message)                     End logging (Really shouldn't be
%                                         called at the end of programs!!!)
%__________________________________________________________________________
% Created: Jul 13, 2010 by bwagner
% Copyright (C) 2010 ANSIR Laboratory, Wake Forest Univ. Health Sciences
% $Revision: 1.4 $

  properties (SetAccess = private, GetAccess = public)
    levels={'MINUTIA','INFO','WARN','ERROR','FATAL','wfu_LOG_ERROR'};
    infoLevel='ERROR';
    log=struct('time',now,'script',mfilename,'level','INFO','message','wfu_LOG started','funcName','','line','');;
    fids=[];
    recording=false;
    verbose=false;
  end
  
  methods
    function logger = wfu_LOG(reportLevel,location)
      if nargin < 1
        reportLevel='ERROR';
      end
      if nargin < 2
        location='SCREEN';
      end
      reportLevel=upper(reportLevel);
      location=cellstr(location);
      if ~any(strcmp(reportLevel,logger.levels))
        error('%s is any unknown reporting level\n',reportLevel);
      end
      logger.infoLevel=reportLevel;
      
      if any(strcmpi(location,'SCREEN'))
        logger.fids(end+1)=1; %Std Out
        location{find(strcmpi(location,'SCREEN'))}=[];
      end
      
      for i=1:length(location)
        if isempty(location{i}), continue; end
        try
          logger.fids(end+1)=fopen(location{i},'a');
        catch
          logger.wfuLogError(sprintf('Unable to open file %s to append log information.',location{i}));
        end
      end
    end
    function level(logger,reportLevel)
      reportLevel=upper(reportLevel);
      if ~any(strcmp(reportLevel,logger.levels))
        logger.error('%s is any unknown reporting level\n',reportLevel);
      end
      logger.infoLevel=reportLevel;
    end
    function minutia(logger,varargin)
      logger.logMessage('MINUTIA',varargin{:});
    end
    function info(logger,varargin)
      logger.logMessage('INFO',varargin{:});
    end
    function warn(logger,varargin)
      logger.logMessage('WARN',varargin{:});
    end
    function error(logger,varargin)
      logger.logMessage('ERROR',varargin{:});
      if ~any(logger.fids==1)
        logger.printLine(1,now,'ERROR',varargin{:});
      end
    end
    function fatal(logger,varargin)
      logger.logMessage('FATAL',varargin{:});
      if ~any(logger.fids==1)
        logger.printLine(1,now,'FATAL',varargin{:});
      end
      if nargin > 2
        error(varargin{1},varargin{2:end});
      else
        error(varargin{1});
      end
    end
    function warndlg(logger,msg,title)
      if nargin < 3
        uiwait(warndlg(msg,'Warning','modal'));
      else
        uiwait(warndlg(msg,title,'modal'));
      end
      logger.logMessage('WARN',msg);
    end
    function errordlg(logger,msg,title)
      if nargin < 3
        uiwait(errordlg(msg,'Error','modal'));
      else
        uiwait(errordlg(msg,title,'modal'));
      end
      logger.logMessage('ERROR',msg);
    end
    function fataldlg(logger,msg,title)
      if nargin < 3
        uiwait(errordlg(msg,'!!! FATAL ERROR !!!','modal'));
      else
        uiwait(errordlg(msg,title,'modal'));
      end
      logger.logMessage('FATAL',msg);
    end
    function infostack(logger,ME)
      logger.stackMessage('INFO',ME);
    end
    function warnstack(logger,ME)
      logger.stackMessage('WARN',ME);
    end
    function errorstack(logger,ME)
      logger.stackMessage('ERROR',ME);
    end
    function fatalstack(logger,ME)
      logger.stackMessage('FATAL',ME);
    end
    function report(logger,lastN)
      if nargin < 2
        lastN=length(logger.log);
      end
      if lastN > length(logger.log)
        lastN=length(logger.log);
      end
      for i=length(logger.log)-lastN+1:length(logger.log)
        logger.printLine(1,logger.log(i).time,logger.log(i).level,...
          logger.log(i).message,logger.log(i).script,...
          logger.log(i).funcName,logger.log(i).line);
      end
    end
    function on(logger)
      logger.recording=true;
    end
    function off(logger)
      logger.recording=false;
    end
    function brief(logger)
      logger.verbose=false;
    end
    function long(logger)
      logger.verbose=true;
    end
  end
  
  methods (Access = protected)
    function wfuLogError(logger,msg)
      logger.logMessage('wfu_LOG_ERROR',msg);
    end
    function logMessage(logger,level,varargin)
      if ~logger.recording, return; end
      if max(find(strcmp(level,logger.levels))) < max(find(strcmp(logger.infoLevel,logger.levels)))
        return;
      end
      [ST,I] = dbstack();
      if length(ST) > 2
        script=ST(3).file;
        funcName=ST(3).name;
        line=num2str(ST(3).line);
      else
        script='unknown';
        funcName='unkown';
        line='??';
      end
      if nargin > 3
        msg=sprintf(varargin{1},varargin{2:end});
      else
        msg=varargin{1};
      end
      logger.printToFids(now,level,msg,script,funcName,line);
    end
    function stackMessage(logger,level,ME)
      if ~isa(ME,'MException')
        logger.wfuLogError('Variable supplied to stackXXX function is not an MException');
        return;
      end
      [ST,I] = dbstack();
      if length(ST) > 2
        script=ST(3).file;
        funcName=ST(3).name;
        line=num2str(ST(3).line);
      else
        script='unknown';
        funcName='unkown';
        line='??';
      end
      tm=now;
      logger.printToFids(tm,level,'MException thrown. Stack follows:',script,funcName,line);
      for i=1:length(ME.stack)
        if i==1
          msg=sprintf('Line %04d: %s',ME.stack(i).line,ME.message);
        else
          msg=sprintf('Line %04d',ME.stack(i).line);
        end
        logger.printToFids(tm,level,msg,ME.stack(i).name,'',ME.stack(i).line);
      end
    end
    function printToFids(logger,tm,level,msg,script,funcName,line)
      lInx=length(logger.log)+1;
      logger.log(lInx).time=tm;
      logger.log(lInx).script=script;
      logger.log(lInx).level=level;
      logger.log(lInx).message=msg;
      logger.log(lInx).funcName=funcName;
      logger.log(lInx).line=line;
      if ~isempty(logger.fids)
        for i=length(logger.fids):-1:1
          try
            logger.printLine(logger.fids(i),tm,level,msg,script,funcName,line);
          catch
            logger.fids(logger.fids==fid)=[];
            logger.wfuLogError(sprintf('Unable to write to file: %s',fopen(fid)));
          end
        end
      else
        logger.printLine(1,now,'wfu_LOG_ERROR','No Loggers available','','');
        logger.printLine(1,now,level,msg,script,funcName,line);
      end
    end
      
    function printLine(logger,fid,tm,level,msg,script,funcName,line)
      if logger.verbose
        fprintf(fid,'Time:      %s\n',datestr(tm));
        fprintf(fid,'Log level: %s\n',level);
        fprintf(fid,'Script:    %s\n',script);
        fprintf(fid,'Function:  %s\n',funcName);
        fprintf(fid,'Line:      %s\n',line);
        fprintf(fid,'Message:   %s\n',msg);
        fprintf(fid,'\n');
      else
        fprintf(fid,'%s | %-10s | %-30s | %s\n',datestr(tm), level, script, msg);
      end
    end
  end
end

%% Revision Log at end

%{
$Log: wfu_LOG.m,v $
Revision 1.4  2010/07/22 15:40:40  bwagner
Fixed bug in error method.

Revision 1.3  2010/07/22 14:29:09  bwagner
Allow sprintf type strings in simple report functions (not stack or dlg)

Revision 1.2  2010/07/19 20:19:00  bwagner
Added stack printing.  Changed default level to ERROR. Other assorted changes

Revision 1.1  2010/07/13 12:13:38  bwagner
A Log generator. May log to screen and/or file or none.

%}