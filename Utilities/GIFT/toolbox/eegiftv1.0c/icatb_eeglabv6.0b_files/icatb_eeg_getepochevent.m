% eeg_getepochevent() - Return dataset event field values for all events 
%                                of one or more specified types
% Usage:
%       >> epochval = eeg_getepochevent( EEG, types);
%       >> epochval = eeg_getepochevent( EEG, types, timewin, fieldname);
%
% Inputs:
%   EEG       - Input dataset
%
% Optional inputs:
%   types     - String containing an event type. Cell array of string
%               may be used to select several event types; 
%               {} is all types of events. Note: Requires that 
%               a field named 'type' is defined in 'EEG.event'.
%   timewin   - Event time window [start, end] in milliseconds
%               (default []=whole epoch).
%   fieldname - Name of the field to return the values for. 
%               Default field is 'EEG.event.latency' in milliseconds
%               (though internally this information is stored in 
%               real frames).
% Outputs:
%   epochval    - A value of the selected field for each epoch. This is
%                 NaN if no selected event occurred during the epoch. If
%                 several vales are available for each epoch, only the
%                 first one is taken into consideration.
%                 Latencies are measured in msec relative to epoch onset.
%   allepochval - cell array with same length as the number of epoch 
%                 containing all values for all epochs. This output is
%                 usefull when several value are found within each epoch.
%
% Notes: 1) Each epoch structure refers to the events that occurred
%        during its time window. This function allows the user to return 
%        specified field values for a subset of the defined events. 
%
%        2) If several of the selected events occur during a single epoch, 
%        a warning is issued, and value of ONLY THE FIRST event in the epoch 
%        is returned. 
%
%        If NO EVENT is selected in a given epoch, the value returned 
%        is NaN.
%
%        3) If the user elects to return the latency field, eeg_getepochevent()
%        recomputes the latency of each event relative to the epoch time
%        limits.
%
% Example: 
%  >> latencies = eeg_getepochevent(EEG, 'rt');
%  % Return the latencies (by default) in milliseconds of events having 
%  % type 'rt' (reaction time)
%
%  >> latencies = eeg_getepochevent(EEG, {'target','rare'}, [0 300], 'position');
%  % Return the position (field 'position') of 'target' or 'rare' type
%  % events occurring between 0 and 300 milliseconds of each epoch.
%  % Returns NaN for epochs with no such events. (See Notes above).
%
% Author: Arnaud Delorme & Scott Makeig, CNL / Salk Institute, 15 Feb 2002
%
% See also: eeglab(), epoch() 

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 15 Feb 2002 Arnaud Delorme, Salk Institute, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: eeg_getepochevent.m,v $
% Revision 1.24  2007/05/03 21:20:50  toby
% test variable removed
%
% Revision 1.23  2007/05/03 20:55:02  toby
% made strmatch 'exact' for selecting events.
% this way '38' is not selected when searching for type '3'
%
% Revision 1.22  2005/05/24 17:45:37  arno
% remove cell2mat
%
% Revision 1.21  2005/04/20 21:49:04  arno
% duration field special cas
%
% Revision 1.20  2004/11/11 00:07:42  arno
% can now process strings
%
% Revision 1.19  2004/11/10 23:56:45  arno
% version 1.16
%
% Revision 1.16  2004/06/03 18:32:59  arno
% msg
%
% Revision 1.15  2004/06/03 14:53:44  arno
% remove count
%
% Revision 1.14  2004/06/03 14:51:12  arno
% debug allepochvals
%
% Revision 1.13  2004/06/02 18:21:45  arno
% adding extra output
%
% Revision 1.12  2004/06/02 16:49:00  arno
% allowing to process continuous data
%
% Revision 1.11  2004/06/01 21:43:06  arno
% adding more examples in header
%
% Revision 1.10  2003/01/03 20:46:38  scott
% header edits -sm
%
% Revision 1.9  2002/08/15 16:29:35  arno
% update message
%
% Revision 1.8  2002/07/27 00:24:26  arno
% updating header
%
% Revision 1.7  2002/05/03 01:53:54  arno
% using eeg_point2lat
%
% Revision 1.6  2002/04/22 22:05:53  arno
% debuggig last change
%
% Revision 1.5  2002/04/22 22:01:07  arno
% corrected time limits
%
% Revision 1.4  2002/04/22 21:51:49  arno
% removing error message for latency
%
% Revision 1.3  2002/04/18 18:22:27  arno
% typo can not
%
% Revision 1.2  2002/04/10 03:08:57  arno
% reprogrammed event selection
%
% Revision 1.1  2002/04/05 17:32:13  jorn
% Initial revision
%

% 02/15/02 modified function according to new event structure -ad

function [epochval, allepochval] = icatb_eeg_getepochevent(EEG, type, timewin, fieldname, timeformat);

if nargin <2
    help eeg_getepochevent;
    return;
end;    
if nargin <3
    timewin = [-Inf Inf];
else 
	if isempty(timewin)
        timewin = [-Inf Inf];
	end;
end;
if nargin <4
    fieldname = 'latency';
end;
if nargin <5
    timeformat = 'points';
end;

if isempty(EEG.event)
    disp('Getepochevent: no event structure, aborting.'); return;
end;
    
% check if EEG.epoch contain references to events
% -----------------------------------------------
if ~isfield( EEG.event, 'epoch' )
    disp('Getepochevent: no epoch indices in events, considering continuous values.');
end;
    
% check if EEG.epoch and EEG.event contains 'latency' field
% ------------------------------------------
if ~isfield( EEG.event, fieldname)
    disp(['Getepochevent: no ''' fieldname ''' field in events, aborting.']); return;
end;

% deal with empty types
% ---------------------
if ~isempty(type) & ~iscell(type)
	type = { type };
end;

% convert types
% -------------
for indextype=1:length(type)
     if isstr(type{indextype}) & isnumeric(EEG.event(1).type)
         if ~isempty(str2num(type{indextype}))   
			 type{indextype} = str2num(type{indextype}); 
		 else
			 error('eeg_getepochevent: string type cannot be found in numeric event type array');
		 end;		 
	 elseif isnumeric(type{indextype}) & isstr(EEG.event(1).type)
		  type{indextype} = num2str(type{indextype});
	 end;
end;

% select epochs
% -------------
if ~isempty(type)
	Ieventtmp = [];
	for indextype=1:length(type)
		typeval = type{indextype};
		if isstr(typeval)
			Ieventtmp = [Ieventtmp strmatch(typeval, { EEG.event.type }, 'exact')' ];
		else
			Ieventtmp = [Ieventtmp find(typeval == [ EEG.event.type ] ) ];
		end;
	end;
else
	Ieventtmp = [1:length(EEG.event)];
end;

% select latencies
% ----------------
if isfield(EEG.event, 'latency') & (timewin(1) ~= -Inf | timewin(2) ~= Inf)
	selected = ones(size(Ieventtmp));
	for index=1:length(Ieventtmp)
        if ~isfield(EEG.event, 'epoch'), epoch = 1;
        else                             epoch = EEG.event(Ieventtmp(index)).epoch;
        end;
		reallat = icatb_eeg_point2lat(EEG.event(Ieventtmp(index)).latency, epoch, ...
								EEG.srate, [EEG.xmin EEG.xmax]*1000, 1E-3); 
		if reallat < timewin(1) | reallat > timewin(2)
			selected(index) = 0;
		end;
	end;
	Ieventtmp = Ieventtmp( find(selected == 1) );
end;

% select events
% -------------
epochval       = cell(1,EEG.trials);  epochval(:) = { nan };
allepochval    = cell(1, EEG.trials); allepochval(:) = { {} };
if strcmp(fieldname, 'latency')
	for index = 1:length(Ieventtmp)
        if ~isfield(EEG.event, 'epoch'), epoch = 1;
        else                             epoch = EEG.event(Ieventtmp(index)).epoch;
        end;
        allepochval{epoch}{end+1} = icatb_eeg_point2lat(EEG.event(Ieventtmp(index)).latency, epoch, ...
                                            EEG.srate, [EEG.xmin EEG.xmax]*1000, 1E-3);
		if length(allepochval{epoch}) == 1
			epochval{epoch} = allepochval{epoch}{end};
		else
            if length(allepochval{epoch}) == 2 & nargout < 2
                disp(['Warning: multiple event latencies found in epoch ' int2str(epoch) ]); 
                %, ignoring event ' int2str(Ieventtmp(index)) ' (''' num2str(EEG.event(Ieventtmp(index)).type) ''' type)' ]);
            end;
		end;
	end;
elseif strcmp(fieldname, 'duration')
	for index = 1:length(Ieventtmp)
		eval( [ 'val = EEG.event(Ieventtmp(index)).' fieldname ';']);
		if ~isempty(val)
            if ~isfield(EEG.event, 'epoch'), epoch = 1;
            else                             epoch = EEG.event(Ieventtmp(index)).epoch;
            end;
            epochval{epoch}           = val/EEG.srate*1000;
            allepochval{epoch}{end+1} = val/EEG.srate*1000;
		end;
	end;
else
	for index = 1:length(Ieventtmp)
		eval( [ 'val = EEG.event(Ieventtmp(index)).' fieldname ';']);
		if ~isempty(val)
            if ~isfield(EEG.event, 'epoch'), epoch = 1;
            else                             epoch = EEG.event(Ieventtmp(index)).epoch;
            end;
            epochval{epoch}           = val;
            allepochval{epoch}{end+1} = val;
		end;
	end;
end;    

if isnumeric(epochval{1})
    try, 
        epochval = [ epochval{:} ];
        for index = 1:length(allepochval)
            allepochval{index} = [ allepochval{index}{:} ];
        end;
    catch, end;
end;