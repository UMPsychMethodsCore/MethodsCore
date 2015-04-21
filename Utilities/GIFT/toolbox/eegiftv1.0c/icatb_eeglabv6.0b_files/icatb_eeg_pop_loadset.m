% icatb_eeg_pop_loadset() - load an EEG dataset. If no arguments, pop up an input window.
%
% Usage:
%   >> EEGOUT = icatb_eeg_pop_loadset; % pop up window to input arguments
%   >> EEGOUT = icatb_eeg_pop_loadset( 'key1', 'val1', 'key2', 'val2', ...);
%   >> EEGOUT = icatb_eeg_pop_loadset( filename, filepath); % old calling format
%
% Optional inputs:
%   'filename'  - [string] dataset filename. Default pops up a graphical
%                 interface to browse for a data file.
%   'filepath'  - [string] dataset filepath. Default is current folder. 
%   'loadmode'  - ['all', 'info', integer] 'all' -> load the data and
%                 the dataset structure. 'info' -> load only the dataset 
%                 structure but not the actual data. [integer] ->  load only 
%                 a specific channel. This is efficient when data is stored 
%                 in a separate '.dat' file in which individual channels 
%                 may be loaded independently of each other. {default: 'all'}
%   'eeg'       - [EEG structure] reload current dataset
% Note:
%       Multiple filenames and filepaths may be specified. If more than one,
%       the output EEG variable will be an array of EEG structures.
% Output
%   EEGOUT - EEG dataset structure or array of structures
%
% Author: Arnaud Delorme, CNL / Salk Institute, 2001; SCCN/INC/UCSD, 2002-
%
% See also: eeglab(), pop_saveset()

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2001 Arnaud Delorme, Salk Institute, arno@salk.edu
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

% $Log: icatb_eeg_pop_loadset.m,v $
% Revision 1.54  2007/04/06 17:48:02  arno
% saved to no
%
% Revision 1.53  2006/04/19 14:17:57  arno
% multiple datasets
%
% Revision 1.51  2006/02/16 19:29:41  arno
% checking dataset consitency
%
% Revision 1.50  2006/02/16 19:23:52  arno
% checking dataset
%
% Revision 1.49  2006/01/31 22:28:25  arno
% EEG.saved = 'justloaded'
%
% Revision 1.48  2006/01/25 01:35:29  toby
% minor change to make it more Mac friendly, shouldn't affect behavior on other OSs.
%
% Revision 1.47  2005/11/04 23:20:27  arno
% set file name and file path
%
% Revision 1.46  2005/10/01 22:29:38  arno
% header
%
% Revision 1.45  2005/09/08 16:34:48  arno
% fixing problem with changes_not_saved and saved'
%
% Revision 1.44  2005/09/01 15:33:52  scott
% edited text msgs
%
% Revision 1.43  2005/08/16 17:47:02  scott
% edited help message. EEG.changes_not_saved -> EEG.saved  -sm
%
% Revision 1.42  2005/08/08 18:17:53  arno
% fixing call
%
% Revision 1.41  2005/08/08 18:12:56  arno
% fix call
%
% Revision 1.40  2005/08/04 17:19:03  arno
% set changes not saved
%
% Revision 1.39  2005/08/04 15:00:56  arno
% fixing old format detection
%
% Revision 1.38  2005/08/03 17:37:36  arno
% reprogramming the function
%
% Revision 1.37  2005/08/03 15:00:11  arno
% fix filepart
%
% Revision 1.36  2005/08/03 14:54:10  arno
% filename, filepath
%
% Revision 1.35  2005/07/30 01:52:32  arno
% typo
%
% Revision 1.34  2005/07/30 01:49:59  arno
% load data
%
% Revision 1.33  2005/04/12 21:43:59  arno
% same
%
% Revision 1.32  2005/04/12 21:42:58  arno
% fixed error while checking dataset (wrong section of code)
%
% Revision 1.31  2005/04/12 17:41:23  hilit
% fixing the 'mode' option
%
% Revision 1.30  2005/04/12 17:27:07  arno
% check dataset if mode is all
%
% Revision 1.29  2004/11/15 22:50:25  arno
% .dat -> .fdt
%
% Revision 1.28  2004/11/05 19:27:05  arno
% uigetfile -> uigetfile2
%
% Revision 1.27  2004/09/21 16:48:37  hilit
% changed from && -> &
%
% Revision 1.26  2004/09/14 17:36:31  arno
% debug new reading mode
%
% Revision 1.25  2004/09/14 17:21:36  arno
% debug last
%
% Revision 1.24  2004/09/14 17:14:54  arno
% new file format
%
% Revision 1.23  2004/08/23 20:25:07  arno
% better eerror msg
%
% Revision 1.22  2004/02/10 21:31:55  arno
% path debug
%
% Revision 1.21  2004/02/09 01:31:43  arno
% input path, head edit...
%
% Revision 1.20  2003/07/16 18:26:19  arno
% automatically updating filename
%
% Revision 1.19  2003/05/20 23:30:57  arno
% still debuging october 2002 problem
%
% Revision 1.18  2003/04/10 17:57:44  arno
% filter for file read
%
% Revision 1.17  2003/02/26 02:34:34  arno
% debug if file changed on disk
%
% Revision 1.16  2002/11/05 18:27:47  luca
% load fix for reading bug October 2002
%
% Revision 1.15  2002/10/15 16:58:47  arno
% drawnow for windows
%
% Revision 1.14  2002/10/14 23:04:02  arno
% default output
%
% Revision 1.13  2002/10/08 15:58:51  arno
% debugging .fdt files
%
% Revision 1.12  2002/08/22 01:41:31  arno
% further checks
%
% Revision 1.11  2002/08/22 00:44:59  arno
% compatibility with previous eeglab version
%
% Revision 1.10  2002/08/22 00:04:44  arno
% old format compatibility
%
% Revision 1.9  2002/08/11 19:20:36  arno
% removing eeg_consts
%
% Revision 1.8  2002/04/23 18:00:17  arno
% modifying help message
%
% Revision 1.7  2002/04/23 17:58:40  arno
% standalone function
%
% Revision 1.6  2002/04/12 00:52:53  arno
% smart load for non-identical structures
%
% Revision 1.5  2002/04/11 23:26:27  arno
% changing structure check
%
% Revision 1.4  2002/04/11 03:34:26  arno
% fully synthesis between icatb_eeg_pop_loadset and pop_loadwks, pop_loadwks removed
%
% Revision 1.3  2002/04/09 20:58:47  arno
% adding check of event consistency
%
% Revision 1.2  2002/04/08 23:33:26  arno
% format conversion for events
%
% Revision 1.1  2002/04/05 17:32:13  jorn
% Initial revision
%

% 01-25-02 reformated help & license -ad 

function [EEG, command] = icatb_eeg_pop_loadset( inputname, inputpath, varargin);

command = '';
EEG  = [];

if nargin < 1
    % pop up window
    % -------------
	[inputname, inputpath] = uigetfile2('*.SET*;*.set', 'Load dataset(s) -- icatb_eeg_pop_loadset()');
    drawnow;
	if inputname == 0 return; end;
    options = { 'filename' inputname 'filepath' inputpath };
else
    % account for old calling format
    % ------------------------------
    if ~strcmpi(inputname, 'filename'), 
        options = { 'filename' inputname }; 
        if nargin > 1
            options = { options{:} 'filepath' inputpath }; 
        end;
        if nargin > 2
            options = { options{:} 'loadmode' varargin{1} }; 
        end;
    else
        options = { inputname inputpath varargin{:} };
    end;
end;

% decode input parameters
% -----------------------
g = icatb_eeg_finputcheck( options, ...
                 { 'filename'   'string' []   '';
                   'filepath'   'string' []   '';
                   'loadmode'   { 'string' 'integer' } { { 'info' 'all' } [] }  'all';
                   'eeg'        'struct' []   struct('data',{}) }, 'icatb_eeg_pop_loadset');
if isstr(g), error(g); end;

% reloading EEG structure from disk
% ---------------------------------
if ~isempty(g.eeg)

    EEG = icatb_eeg_pop_loadset( 'filepath', EEG.filepath, 'filename', EEG.filename);

else
    % read file
    % ---------
    filename = fullfile(g.filepath, g.filename);
    fprintf('icatb_eeg_pop_loadset(): loading file %s ...\n', filename);
    try
        TMPVAR = load(filename, '-mat');
    catch,
        error([ filename ': file is protected or does not exist' ]);
    end;

    % variable not found
    % ------------------
    if isempty(TMPVAR)
        error('No dataset info is associated with this file');
    end;

    if isfield(TMPVAR, 'EEG')
        
        % load individual dataset
        % -----------------------
        EEG = checkoldformat(TMPVAR.EEG);
        [ EEG.filepath EEG.filename ext ] = fileparts( filename );
        EEG.filename = [ EEG.filename ext ];
        
        % account for name changes etc...
        % -------------------------------
        if isstr(EEG.data) & ~strcmpi(EEG.data, 'EEGDATA')

            [tmp EEG.data ext] = fileparts( EEG.data ); EEG.data = [ EEG.data ext];
            if ~isempty(tmp) & ~strcmpi(tmp, EEG.filepath)
                disp('Warning: updating folder name for .dat|.fdt file');
            end;
            if ~strcmp(EEG.filename(1:end-3), EEG.data(1:end-3))
                disp('Warning: the name of the dataset has changed on disk, updating .dat & .fdt data file to the new name');
                EEG.data = [ EEG.filename(1:end-3) EEG.data(end-2:end) ];
                EEG.saved = 'no';
            end;
            
        end;
        
        % copy data to output variable if necessary (deprecated)
        % -----------------------------------------
        if ~strcmpi(g.loadmode, 'info') & isfield(TMPVAR, 'EEGDATA')
            EEG.data = TMPVAR.EEGDATA;
        end;
        
    elseif isfield(TMPVAR, 'ALLEEG')
        
        eeg_optionsbackup;
        eeg_options;
        if option_storedisk
            error('Cannot load multiple dataset file. Change memory option to allow multiple datasets in memory, then try again. Remember that this file type is OBSOLETE.');
        end;
                  
        % this part is deprecated as of EEGLAB 5.00
        % since all dataset data have to be saved in separate files
        % -----------------------------------------------------
        disp('icatb_eeg_pop_loadset(): appending datasets');
        EEG = TMPVAR.ALLEEG;
        for index=1:length(EEG)
            EEG(index).filename = '';
            EEG(index).filepath = '';        
            if isstr(EEG(index).data), 
                EEG(index).filepath = g.filepath; 
                if length(g.filename) > 4 & ~strcmp(g.filename(1:end-4), EEG(index).data(1:end-4)) & strcmpi(g.filename(end-3:end), 'sets')
                    disp('Warning: the name of the dataset has changed on disk, updating .dat data file to the new name');
                    EEG(index).data = [ g.filename(1:end-4) 'fdt' int2str(index) ];
                end;
            end;
        end;
    else
        EEG = checkoldformat(TMPVAR);
        if ~isfield( EEG, 'data')
            error('icatb_eeg_pop_loadset(): not an EEG dataset file');
        end;
        if isstr(EEG.data), EEG.filepath = g.filepath; end;
    end;
end;

% load all data or specific data channel
% --------------------------------------
EEG = icatb_eeg_eeg_checkset(EEG);
if isstr(g.loadmode)
    if strcmpi(g.loadmode, 'all')
        EEG = icatb_eeg_eeg_checkset(EEG, 'loaddata');
    end;
else
    % load/select specific channel
    % ----------------------------
    EEG.datachannel = g.loadmode;
    if isstr(EEG.data)
        EEG.datfile = EEG.data;
        fid = fopen(fullfile(EEG.filepath, EEG.data), 'r', 'ieee-le');
        fseek(fid, EEG.pnts*EEG.trials*( g.loadmode - 1), 0 );
        EEG.data    = fread(fid, EEG.pnts*EEG.trials, 'float32');
        fclose(fid);
    else
        EEG.data        = EEG.data(g.loadmode,:,:);
    end;
end;

% set file name and path
% ----------------------
if length(EEG) == 1
    if isempty(g.filepath)
        [g.filepath g.filename ext] = fileparts(g.filename);
        g.filename = [ g.filename ext ];
    end;
    EEG.filename = g.filename;
    EEG.filepath = g.filepath;
end;

% set field indicating that the data has not been modified
% --------------------------------------------------------
if isfield(EEG, 'changes_not_saved')
    EEG = rmfield(EEG, 'changes_not_saved');
end;
for index=1:length(EEG)
    EEG(index).saved = 'justloaded';
end;

command = sprintf('EEG = icatb_eeg_pop_loadset(%s);', icatb_eeg_vararg2str(options));
return;

function EEG = checkoldformat(EEG)
	if ~isfield( EEG, 'data')
		fprintf('icatb_eeg_pop_loadset(): Incompatible with new format, trying old format and converting...\n');
		eegset = EEG.cellArray;
		
		off_setname             = 1;  %= filename
		off_filename            = 2;  %= filename
		off_filepath            = 3;  %= fielpath
		off_type                    = 4;  %= type EEG AVG CNT
		off_chan_names          = 5;  %= chan_names
		off_chanlocs            = 21;  %= filename
		off_pnts                    = 6;  %= pnts
		off_sweeps                  = 7; %= sweeps
		off_rate                    = 8;  %= rate
		off_xmin                    = 9;  %= xmin
		off_xmax                    = 10;  %= xmax
		off_accept                  = 11; %= accept
		off_typeeeg                 = 12; %= typeeeg
		off_rt                      = 13; %= rt
		off_response            = 14; %= response
		off_signal                  = 15; %= signal
		off_variance            = 16; %= variance
		off_winv                    = 17; %= variance
		off_weights             = 18; %= variance
		off_sphere                  = 19; %= variance
		off_activations         = 20; %= variance
		off_entropytrial        = 22; %= variance
		off_entropycompo        = 23; %= variance
		off_threshold       = 24; %= variance
		off_comporeject     = 25; %= variance
		off_sigreject       = 26;
		off_kurtA                       = 29;
		off_kurtR                       = 30;
		off_kurtDST                 = 31;
		off_nbchan                  = 32;
		off_elecreject      = 33;
		off_comptrial       = 34;
		off_kurttrial       = 35; %= variance
		off_kurttrialglob   = 36; %= variance
		off_icareject       = 37; %= variance
		off_gcomporeject    = 38; %= variance
		off_eegentropy          = 27;
		off_eegkurt             = 28;
		off_eegkurtg            = 39;

		off_tmp1                        = 40;
		off_tmp2                        = 40;
		
		% must convert here into new format
		EEG.setname    = eegset{off_setname   };
		EEG.filename   = eegset{off_filename  };
		EEG.filepath   = eegset{off_filepath  };
		EEG.namechan   = eegset{off_chan_names};
		EEG.chanlocs    = eegset{off_chanlocs   };
		EEG.pnts       = eegset{off_pnts      };
		EEG.nbchan     = eegset{off_nbchan    };
		EEG.trials     = eegset{off_sweeps    };
		EEG.srate       = eegset{off_rate      };
		EEG.xmin       = eegset{off_xmin      };
		EEG.xmax       = eegset{off_xmax      };
		EEG.accept     = eegset{off_accept    };
		EEG.eegtype    = eegset{off_typeeeg   };
		EEG.rt         = eegset{off_rt        };
		EEG.eegresp    = eegset{off_response  };
		EEG.data     = eegset{off_signal    };
		EEG.icasphere  = eegset{off_sphere    };
		EEG.icaweights = eegset{off_weights   };
		EEG.icawinv       = eegset{off_winv      };
		EEG.icaact        = eegset{off_activations  };
		EEG.stats.entropy    = eegset{off_entropytrial };
		EEG.stats.kurtc      = eegset{off_kurttrial    };
		EEG.stats.kurtg      = eegset{off_kurttrialglob};
		EEG.stats.entropyc   = eegset{off_entropycompo };
		EEG.reject.threshold  = eegset{off_threshold    };
		EEG.reject.icareject  = eegset{off_icareject    };
		EEG.reject.compreject = eegset{off_comporeject  };
		EEG.reject.gcompreject= eegset{off_gcomporeject };
		EEG.reject.comptrial  = eegset{off_comptrial    };
		EEG.reject.sigreject  = eegset{off_sigreject    };
		EEG.reject.elecreject = eegset{off_elecreject   };
		EEG.stats.kurta      = eegset{off_kurtA        };
		EEG.stats.kurtr      = eegset{off_kurtR        };
		EEG.stats.kurtd      = eegset{off_kurtDST      };
		EEG.stats.eegentropy = eegset{off_eegentropy   };
		EEG.stats.eegkurt    = eegset{off_eegkurt      };
		EEG.stats.eegkurtg   = eegset{off_eegkurtg     };
		%catch
		%	disp('Warning: some variables may not have been assigned');
		%end;
		
		% modify the eegtype to match the new one
		
		try, 
			if EEG.trials > 1
				EEG.events  = [ EEG.rt(:) EEG.eegtype(:) EEG.eegresp(:) ];
			end;
		catch, end;
	end;
	% check modified fields
	% ---------------------
	if isfield(EEG,'icadata'), EEG.icaact = EEG.icadata; end;  
	if isfield(EEG,'poschan'), EEG.chanlocs = EEG.poschan; end;  
	if ~isfield(EEG, 'icaact'), EEG.icaact = []; end;
	if ~isfield(EEG, 'chanlocs'), EEG.chanlocs = []; end;
	
	if isfield(EEG, 'events') & ~isfield(EEG, 'event')
		try, 
			if EEG.trials > 1
				EEG.events  = [ EEG.rt(:) ];
				
				EEG = icatb_eeg_eeg_checkset(EEG);;
				EEG = icatb_eeg_pop_importepoch(EEG, EEG.events, { 'rt'}, {'rt'}, 1E-3);
			end;
			if isfield(EEG, 'trialsval')
				EEG = icatb_eeg_pop_importepoch(EEG, EEG.trialsval(:,2:3), { 'eegtype' 'response' }, {},1,0,0);
			end;
			EEG = icatb_eeg_eeg_checkset(EEG, 'eventconsistency');
		catch, disp('Warning: could not import events'); end;			
	end;
	rmfields = {'icadata' 'events' 'accept' 'eegtype' 'eegresp' 'trialsval' 'poschan' 'icadata' 'namechan' };
	for index = 1:length(rmfields)
		if isfield(EEG, rmfields{index}), 
			disp(['Warning: field ' rmfields{index} ' is deprecated']);
		end;
	end;
	
