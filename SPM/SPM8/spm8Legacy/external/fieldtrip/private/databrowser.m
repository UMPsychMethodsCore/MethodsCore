function [cfg] = databrowser(cfg, data)

% DATABROWSER can be used for visual inspection of data. Artifacts detected
% by FieldTrip artifact functions are marked. Data pieces can be marked as
% artifact by manual selection as well.
%
% Use as
%   cfg = databrowser(cfg)
% with the cfg as obtained from DEFINETRIAL, or as
%   cfg = databrowser(cfg, data)
% with the data as obtained from PREPROCESSING
%
% The following configuration options are supported:
%   cfg.dataset                 =
%   cfg.trl                     =
%   cfg.continuous              = 'yes' or 'no'
%   cfg.channel                 = cell-array with channel labels, see CHANNELSELECTION
%   cfg.zscale                  = [zmin zmax] or 'auto' (default = 'auto')
%   cfg.blocksize               = number (in seconds), only aplicable if data contains only 1 (long) trial
%   cfg.artfctdef.xxx.artifact  = Nx2 matrix with artifact segments
%   cfg.viewmode                = string, 'butterfly', 'vertical', 'component' (default = 'butterfly')
%   cfg.selectfeature           = string, name of feature to be selected/added (default = 'visual')
%   cfg.selectmode              = string, what to do with a selection, can be 'joint', 'individual', 'mutiplot', 'topoplot-avg', 'topoplot-pow' (default = 'joint' 
%
% See also PREPROCESSING

% Copyright (C) 2009, Robert Oostenveld, Ingrid Niewenhuis
%
% $Log: databrowser.m,v $
% Revision 1.12  2009/08/05 14:16:53  roboos
% added various options for selectmode
%
% Revision 1.11  2009/08/05 09:14:58  roboos
% fixed problem with zscale=auto when all data was negative
%
% Revision 1.10  2009/08/05 08:58:54  roboos
% changed the order of the input arguments to plot_topo from (val, x, y) into (x, y, val)
%
% Revision 1.9  2009/08/05 08:26:41  roboos
% if not continuous, keep the original data segments and don't display the horizontal zoom
% if continuous, use the label 'segment', other 'trial'
% give more information in figure title
% implemented preprocessing of data, use cfg.preproc
% added cfg.viewmode for external specification of visualisation method
% various bug fixes ans speed improvements
%
% Revision 1.8  2009/08/04 16:15:35  roboos
% removed settings uicontrol elements and button
% converted trial/channel/horizontal/vertical from text label into pushbutton with input dialog
%
% Revision 1.7  2009/08/04 13:37:00  ingnie
% renamed cfg.selectbehaviour into selectmode (consistent with viewmode)
% fixed bug in displaying of multiple artifacts in a single trial for viewmode=vertical
%
% Revision 1.6  2009/08/04 11:59:06  roboos
% first attempt to add some buttons to the figure and to toggle between the setting and the normal display
%
% Revision 1.5  2009/08/03 20:49:28  roboos
% some improvements for channelselection when reading data fromk disk
%
% Revision 1.4  2009/08/03 18:28:44  roboos
% started with implementation viewmode=component/layout/vertical/butterfly
% many small changes
%
% Revision 1.3  2009/08/03 10:55:43  roboos
% restructured the main function (order in which figure and opt are constructed), added multiplotER feature
%
% Revision 1.2  2009/08/03 08:30:17  ingnie
% replaced the initial version of Giovanni with another databrowser that Ingrid and Robert implemented. The newer one already has more functionality, like adding/removing artifacts and horizontal and vertical zooming
%

fieldtripdefs

if nargin>1
  data = checkdata(data, 'datatype', {'raw', 'comp'}, 'feedback', 'yes');
else
  % check if the input cfg is valid for this function
  cfg = checkconfig(cfg, 'dataset2files', {'yes'});
  cfg = checkconfig(cfg, 'required', {'headerfile', 'datafile'});
  cfg = checkconfig(cfg, 'renamed',    {'datatype', 'continuous'});
  cfg = checkconfig(cfg, 'renamedval', {'continuous', 'continuous', 'yes'});
end

% set the defaults
if ~isfield(cfg, 'channel'),         cfg.channel = 'all';             end
if ~isfield(cfg, 'continuous'),      cfg.continuous = 'no';           end % only for reading from file
if ~isfield(cfg, 'zscale'),          cfg.zscale = 'auto';             end
if ~isfield(cfg, 'artfctdef'),       cfg.artfctdef = struct;          end
if ~isfield(cfg, 'selectfeature'),   cfg.selectfeature = 'visual';    end % string or cell-array
if ~isfield(cfg, 'selectmode'),      cfg.selectmode = 'joint';        end % joint or individual
if ~isfield(cfg, 'viewmode'),        cfg.viewmode = 'butterfly';      end % butterfly, vertical, component, settings
if ~isfield(cfg, 'blocksize'),       cfg.blocksize = 1;               end % only for segmenting continuous data, i.e. one long trial
if ~isfield(cfg, 'preproc'),         cfg.preproc = [];                end % see preproc for options

if ischar(cfg.selectfeature)
  % ensure that it is a cell array
  cfg.selectfeature = {cfg.selectfeature};
end

if nargin>1
  % read or create the layout that will be used for plotting
  cfg.layout = prepare_layout(cfg, data);
else
  % read or create the layout that will be used for plotting
  cfg.layout = prepare_layout(cfg);
end

% get some initial parameters from the data
if nargin>1
  % fetch the header
  hdr = fetch_header(data);
  
  cfg.channel = channelselection(cfg.channel, data.label);
  chansel = match_str(data.label, cfg.channel);
  fsample = 1/(data.time{1}(2)-data.time{1}(1));
  Nchans  = length(chansel);
  
  % this is how the input data is segmented
  trlorg = findcfg(data.cfg, 'trl');
  Ntrials = size(trlorg, 1);
  
else
  % read the header
  hdr = read_header(cfg.headerfile, 'headerformat', cfg.headerformat);
  
  % this option relates to reading over trial boundaries in a pseudo-continuous dataset
  if ~isfield(cfg, 'continuous')
    if hdr.nTrials==1
      cfg.continuous = 'yes';
    else
      cfg.continuous = 'no';
    end
  end
  
  if ~isfield(cfg, 'trl')
    % treat the data as continuous if possible, otherwise define all trials as indicated in the header
    if strcmp(cfg.continuous, 'yes')
      trl = zeros(1, 3);
      trl(1,1) = 1;
      trl(1,2) = hdr.nSamples*hdr.nTrials;
      trl(1,3) = 0;
    else
      trl = zeros(hdr.nTrials, 3);
      for i=1:hdr.nTrials
        trl(i,1) = (i-1)*hdr.nSamples + 1;
        trl(i,2) = (i  )*hdr.nSamples    ;
        trl(i,3) = -hdr.nSamplesPre;
      end
    end
    cfg.trl = trl;
  end
  
  cfg.channel = channelselection(cfg.channel, hdr.label);
  chansel = match_str(hdr.label, cfg.channel);
  fsample = hdr.Fs;
  Nchans  = length(chansel);
  
  % this is how the data from file should be segmented
  trlorg = cfg.trl;
  Ntrials = size(trlorg, 1);
end

if Nchans == 0
  error('no channels to display');
end

if Ntrials == 0
  error('no trials to display');
end

% collect the artifacts that have been detected from cfg.artfctdef.xxx.artifact
artlabel = fieldnames(cfg.artfctdef);
sel      = zeros(size(artlabel));
artifact = cell(size(artlabel));
for i=1:length(artlabel)
  sel(i) = issubfield(cfg.artfctdef, [artlabel{i} '.artifact']);
  if sel(i)
    artifact{i} = getsubfield(cfg.artfctdef, [artlabel{i} '.artifact']);
    num         = size(artifact{i}, 1);
    if isempty(num)
      num = 0;
    end
    fprintf('detected %3d %s artifacts\n', num, artlabel{i});
  end
end
artifact = artifact(sel==1);
artlabel = artlabel(sel==1);

for i=1:length(cfg.selectfeature)
  if ~any(strcmp(cfg.selectfeature{i}, artlabel))
    artifact = {[],                   artifact{:}};
    artlabel = {cfg.selectfeature{i}, artlabel{:}};
  end
end

% FIXME ensure nice sorting of artifact labels

% make a single vector representing all artifacts
datbegsample = min(trlorg(:,1));
datendsample = max(trlorg(:,2));
artdat = zeros(length(artifact), datendsample);
for i=1:length(artifact)
  for j=1:size(artifact{i},1)
    artbegsample = artifact{i}(j,1);
    artendsample = artifact{i}(j,2);
    artendsample = min(artendsample, datendsample);
    artdat(i, artbegsample:artendsample) = 1;
  end
end

artdata = [];
artdata.trial{1}       = artdat;
artdata.time{1}        = offset2time(0, fsample, datendsample);
artdata.label          = artlabel;
artdata.fsample        = fsample;
artdata.cfg.trl        = [1 datendsample 0];

if ischar(cfg.zscale) && strcmp(cfg.zscale, 'auto')
  if nargin>1
    dat = data.trial{1}(chansel,:);
    minval = min(dat(:));
    maxval = max(dat(:));
    cfg.zscale = max(abs(minval), abs(maxval));
  else
    cfg.zscale = 1; % FIXME
  end
end

h = figure;
set(h, 'KeyPressFcn',           @keyboard_cb);
set(h, 'WindowButtonDownFcn',   {@select_range, 'multiple', false, 'xrange', true, 'yrange', false, 'clear', true, 'callback', {@select_range_cb, h}, 'event', 'WindowButtonDownFcn'});
set(h, 'WindowButtonUpFcn',     {@select_range, 'multiple', false, 'xrange', true, 'yrange', false, 'clear', true, 'callback', {@select_range_cb, h}, 'event', 'WindowButtonUpFcn'});
set(h, 'WindowButtonMotionFcn', {@select_range, 'multiple', false, 'xrange', true, 'yrange', false, 'clear', true, 'callback', {@select_range_cb, h}, 'event', 'WindowButtonMotionFcn'});

% opt represents the global data/settings, it should contain
% - the original data, epoched or continuous
% - the artifacts represented as continuous data
% - the redraw_cb settings
% - the preproc   settings
% - the select_range_cb settings (also used in keyboard_cb)

% these elements are stored inside the figure so that the callback routines can modify them
opt = [];
if nargin<2
  opt.orgdata   = [];      % this means that it will look in opt.cfg.dataset
else
  opt.orgdata   = data;
end
opt.artdata  = artdata;
opt.cfg      = cfg;        % the configuration of this function, not of the preprocessing
opt.hdr      = hdr;
opt.trlop    = 1;          % active trial being displayed
opt.ftsel    = 1;          % current artifact/feature being selected
opt.trlorg   = trlorg;
opt.fsample  = fsample;
opt.cleanup  = false;      % this is needed for a corrent handling if the figure is closed (either in the corner or by "q")
if strcmp(cfg.continuous, 'yes')
  opt.trialname = 'segment';
else
  opt.trialname = 'trial';
end
guidata(h, opt);

% make the user interface elements for the data view
uicontrol('tag', 'group1', 'parent', h, 'units', 'normalized', 'style', 'pushbutton', 'string', opt.trialname, 'userdata', 't')
uicontrol('tag', 'group2', 'parent', h, 'units', 'normalized', 'style', 'pushbutton', 'string', '<', 'userdata', 'leftarrow')
uicontrol('tag', 'group2', 'parent', h, 'units', 'normalized', 'style', 'pushbutton', 'string', '>', 'userdata', 'rightarrow')

uicontrol('tag', 'group1', 'parent', h, 'units', 'normalized', 'style', 'pushbutton', 'string', 'channel','userdata', 'c')
uicontrol('tag', 'group2', 'parent', h, 'units', 'normalized', 'style', 'pushbutton', 'string', '<', 'userdata', 'uparrow')
uicontrol('tag', 'group2', 'parent', h, 'units', 'normalized', 'style', 'pushbutton', 'string', '>', 'userdata', 'downarrow')

uicontrol('tag', 'group1a', 'parent', h, 'units', 'normalized', 'style', 'pushbutton', 'string', 'horizontal', 'userdata', 'h')
uicontrol('tag', 'group2a', 'parent', h, 'units', 'normalized', 'style', 'pushbutton', 'string', '-', 'userdata', 'shift+leftarrow')
uicontrol('tag', 'group2a', 'parent', h, 'units', 'normalized', 'style', 'pushbutton', 'string', '+', 'userdata', 'shift+rightarrow')
if strcmp(cfg.continuous, 'no')
  uilayout(h, 'tag', 'group1a', 'visible', 'off', 'retag', 'group1');
  uilayout(h, 'tag', 'group2a', 'visible', 'off', 'retag', 'group2');
else
  uilayout(h, 'tag', 'group1a', 'visible', 'on', 'retag', 'group1');
  uilayout(h, 'tag', 'group2a', 'visible', 'on', 'retag', 'group2');
end

uicontrol('tag', 'group1', 'parent', h, 'units', 'normalized', 'style', 'pushbutton', 'string', 'vertical', 'userdata', 'v')
uicontrol('tag', 'group2', 'parent', h, 'units', 'normalized', 'style', 'pushbutton', 'string', '-', 'userdata', 'shift+downarrow')
uicontrol('tag', 'group2', 'parent', h, 'units', 'normalized', 'style', 'pushbutton', 'string', '+', 'userdata', 'shift+uparrow')

uilayout(h, 'tag', 'group1', 'width', 0.10, 'height', 0.05);
uilayout(h, 'tag', 'group2', 'width', 0.05, 'height', 0.05);
uilayout(h, 'tag', 'group1', 'style', 'pushbutton', 'callback', @keyboard_cb);
uilayout(h, 'tag', 'group2', 'style', 'pushbutton', 'callback', @keyboard_cb);

uilayout(h, 'tag', 'group1', 'retag', 'viewui');
uilayout(h, 'tag', 'group2', 'retag', 'viewui');
uilayout(h, 'tag', 'viewui', 'BackgroundColor', [0.8 0.8 0.8], 'hpos', 'auto', 'vpos', 0.01);

definetrial_cb(h);
redraw_cb(h);

if nargout
  % wait until the user interface is closed, get the user data with the updated artifact details
  set(h, 'CloseRequestFcn', @cleanup_cb);
  
  while ishandle(h)
    uiwait(h);
    opt = guidata(h);
    if opt.cleanup
      delete(h);
    end
  end
  
  % add the updated artifact definitions to the output cfg
  for i=1:length(opt.artdata.label)
    tmp = diff([0 opt.artdata.trial{1}(i,:) 0]);
    artbeg = find(tmp==+1);
    artend = find(tmp==-1) - 1;
    cfg.artfctdef.(opt.artdata.label{i}).artifact = [artbeg' artend'];
  end
end % if nargout

% add version information to the configuration
try
  % get the full name of the function
  cfg.version.name = mfilename('fullpath');
catch
  % required for compatibility with Matlab versions prior to release 13 (6.5)
  [st, i] = dbstack;
  cfg.version.name = st(i);
end
cfg.version.id = '$Id: databrowser.m,v 1.12 2009/08/05 14:16:53 roboos Exp $';
% remember the configuration details of the input data
try cfg.previous = data.cfg; end

end % main function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cleanup_cb(h, eventdata)
opt = guidata(h);
opt.cleanup = true;
guidata(h, opt);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function definetrial_cb(h, eventdata)
opt = guidata(h);
if strcmp(opt.cfg.continuous, 'no')
  % keep the original trial definition for visualisation
  opt.trlvis = opt.trlorg;
else
  % construct a trial definition for visualisation
  if isfield(opt, 'trlvis')
    thistrlbeg = opt.trlvis(opt.trlop,1);
    thistrlend = opt.trlvis(opt.trlop,2);
    % remember a representative sample of the current trial
    % thissample = round((thistrlbeg+thistrlend)/2);
    thissample = thistrlbeg;
  end
  % look at opt.cfg.blocksize and make opt.trl accordingly
  % if original data contains more than one trial, it will fail in fetc_data
  datbegsample = min(opt.trlorg(:,1));
  datendsample = max(opt.trlorg(:,2));
  smppertrl  = round(opt.fsample * opt.cfg.blocksize);
  begsamples = datbegsample:smppertrl:datendsample;
  endsamples = datbegsample+smppertrl-1:smppertrl:datendsample;
  if numel(endsamples)<numel(begsamples)
    endsamples(end+1) = datendsample;
  end
  trlvis = [];
  trlvis(:,1) = begsamples';
  trlvis(:,2) = endsamples';
  trlvis(:,3) = begsamples-1;
  if isfield(opt, 'trlvis')
    % update the current trial counter and try to keep the current sample the same
    % opt.trlop   = nearest(round((begsamples+endsamples)/2), thissample);
    opt.trlop   = nearest(begsamples, thissample);
  end
  opt.trlvis  = trlvis;
end % if continuous
guidata(h, opt);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function help_cb(h, eventdata)
fprintf('------------------------------------------------------------------------------------\n')
fprintf('You can use the following buttons in the data viewer\n')
fprintf('1-9                : select artifact number 1-9\n');
fprintf('arrow-left         : previous trial\n');
fprintf('arrow-right        : next trial\n');
fprintf('shift arrow-up     : increase vertical scaling\n');
fprintf('shift arrow-down   : decrease vertical scaling\n');
fprintf('shift arrow-left   : increase cfg.blocksize\n');
fprintf('shift arrow-down   : decrease cfg.blocksize\n');
fprintf('q            : quit\n');
fprintf('------------------------------------------------------------------------------------\n')
fprintf('\n')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function select_range_cb(range, h) %range 1X4 in sec relative to current trial
opt = guidata(h);

switch opt.cfg.viewmode
  case 'butterfly'
    begsample = opt.trlvis(opt.trlop,1);
    endsample = opt.trlvis(opt.trlop,2);
    offset    = opt.trlvis(opt.trlop,3);
    % determine the selection
    begsel = round(range(1)*opt.fsample+1);
    endsel = round(range(2)*opt.fsample+1);
    % the selection should always be confined to the current trial
    begsel = max(begsample, begsel);
    endsel = min(endsample, endsel);
    
  case {'vertical', 'component'}
    % the range should be in the displayed box
    range(1) = max(opt.hpos(1), range(1));
    range(2) = max(opt.hpos(1), range(2));
    range(1) = min(opt.hpos(2), range(1));
    range(2) = min(opt.hpos(2), range(2));
    range = (range - opt.hpos(1)) / (opt.hpos(2) - opt.hpos(1)); % left side of the box becomes 0, right side becomes 1
    range = range * (opt.hlim(2) - opt.hlim(1)) + opt.hlim(1);   % 0 becomes hlim(1), 1 becomes hlim(2)
    
    begsample = opt.trlvis(opt.trlop,1);
    endsample = opt.trlvis(opt.trlop,2);
    offset    = opt.trlvis(opt.trlop,3);
    % determine the selection
    begsel = round(range(1)*opt.fsample+1);
    endsel = round(range(2)*opt.fsample+1);
    % the selection should always be confined to the current trial
    begsel = max(begsample, begsel);
    endsel = min(endsample, endsel);
    
  otherwise
    error('unknown opt.cfg.viewmode "%s"', opt.cfg.viewmode);
end % switch

if strcmp(opt.cfg.selectmode, 'disp')
  % FIXME this is only for debugging
  disp([begsel endsel])
  
elseif strcmp(opt.cfg.selectmode, 'joint')
  % consider all artifact channels
  artval = opt.artdata.trial{1}(:, begsel:endsel);
  artval = any(artval,1);
  if any(artval)
    fprintf('there is overlap with another artifact, disable all other artifacts\n');
    opt.artdata.trial{1}(:, begsel:endsel) = 0;
  else
    fprintf('there is no overlap with another artifact, mark this as an artifact\n');
    opt.artdata.trial{1}(opt.ftsel, begsel:endsel) = 1;
  end
  
elseif strcmp(opt.cfg.selectmode, 'individual')
  % ignore the other artifact channels
  artval = opt.artdata.trial{1}(opt.ftsel, begsel:endsel);
  artval = any(artval,1);
  if any(artval)
    fprintf('there is overlap with this particular artifact, disable this artifact\n');
    opt.artdata.trial{1}(opt.ftsel, begsel:endsel) = 0;
  else
    fprintf('there is no overlap with this particular artifact, mark this as a new artifact\n');
    opt.artdata.trial{1}(opt.ftsel, begsel:endsel) = 1;
  end
  
elseif strcmp(opt.cfg.selectmode, 'multiplot')
  % cut out the requested data segment
  if isempty(opt.orgdata)
    tmpcfg = opt.cfg; % FIXME: some options should be passed, but not all
    tmpcfg.trl = [begsample endsample begsample];
    rawdata = preprocessing(tmpcfg);
  else
    tmpcfg = [];
    tmpcfg.trl = [begsample endsample begsample];
    rawdata = redefinetrial(tmpcfg, opt.orgdata);
    % FIXME: also apply filters to the data in memory?
  end
  % convert the raw data into an average
  tmpcfg = [];
  timelock = timelockanalysis(tmpcfg, rawdata);
  % open a new window with multiplotER
  tmpcfg = [];
  tmpcfg.layout = opt.cfg.layout;
  tmpcfg.electrodes = 'on';
  tmpcfg.showlabels = 'markers'; % FIXME
  tmpcfg.interactive = 'yes';
  figure; multiplotER(tmpcfg, timelock);

elseif strcmp(opt.cfg.selectmode, 'topoplot-avg')
  % cut out the requested data segment
  if isempty(opt.orgdata)
    tmpcfg = opt.cfg; % FIXME: some options should be passed, but not all
    tmpcfg.trl = [begsample endsample begsample];
    rawdata = preprocessing(tmpcfg);
  else
    tmpcfg = [];
    tmpcfg.trl = [begsample endsample begsample];
    rawdata = redefinetrial(tmpcfg, opt.orgdata);
    % FIXME: also apply filters to the data in memory?
  end
  % convert the raw data into an average
  tmpcfg = [];
  timelock = timelockanalysis(tmpcfg, rawdata);
  % open a new window with topoplotER, average over the whole interval
  tmpcfg = [];
  tmpcfg.xlim = [min(timelock.time) max(timelock.time)];
  tmpcfg.layout = opt.cfg.layout;
  tmpcfg.electrodes = 'on';
  tmpcfg.showlabels = 'markers'; % FIXME
  tmpcfg.interactive = 'no';
  figure; topoplotER(tmpcfg, timelock);
  
  elseif strcmp(opt.cfg.selectmode, 'topoplot-pow')
  % cut out the requested data segment
  if isempty(opt.orgdata)
    tmpcfg = opt.cfg; % FIXME: some options should be passed, but not all
    tmpcfg.trl = [begsample endsample begsample];
    rawdata = preprocessing(tmpcfg);
  else
    tmpcfg = [];
    tmpcfg.trl = [begsample endsample begsample];
    rawdata = redefinetrial(tmpcfg, opt.orgdata);
    % FIXME: also apply filters to the data in memory?
  end
  % convert the raw data into an average
  tmpcfg = [];
  timelock = timelockanalysis(tmpcfg, rawdata);
  % replace the ERF with the average broad-band power
  pow = mean(timelock.avg.^2, 2);
  timelock.avg = repmat(pow, 1, length(timelock.time));
  % open a new window with topoplotER, average over the whole interval
  tmpcfg = [];
  tmpcfg.xlim = [min(timelock.time) max(timelock.time)];
  tmpcfg.layout = opt.cfg.layout;
  tmpcfg.electrodes = 'on';
  tmpcfg.showlabels = 'markers'; % FIXME
  tmpcfg.interactive = 'no';
  figure; topoplotER(tmpcfg, timelock);
  
else
  error('unknown value for cfg.selectmode');
end

guidata(h, opt);
redraw_cb(h);
end % function


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function keyboard_cb(h, eventdata)
opt = guidata(h);

if isempty(eventdata)
  % determine the key that corresponds to the uicontrol element that was activated
  key = get(h, 'userdata');
  h = getparent(h);
else
  % determine the key that was pressed on the keyboard
  key = eventdata.Key;
  if ~isempty(eventdata.Modifier)
    key = [eventdata.Modifier{1} '+' key];
  end
end

switch key
  case {'1' '2' '3' '4' '5' '6' '7' '8' '9'}
    % switch to another artifact type
    opt.ftsel = str2double(key);
    fprintf('switching to the "%s" artifact\n', opt.artdata.label{opt.ftsel});
  case 'leftarrow'
    opt.trlop = max(opt.trlop - 1, 1); % should not be smaller than 1
    guidata(h, opt);
    redraw_cb(h, eventdata);
  case 'rightarrow'
    opt.trlop = min(opt.trlop + 1, size(opt.trlvis,1)); % should not be larger than the number of trials
    guidata(h, opt);
    redraw_cb(h, eventdata);
  case 'uparrow'
    chansel = match_str(opt.hdr.label, opt.cfg.channel);
    minchan = min(chansel);
    maxchan = max(chansel);
    numchan = length(chansel);
    chansel = (minchan:maxchan) - numchan;
    if min(chansel)<1
      chansel = chansel  - min(chansel) + 1;
    end
    % convert numeric array into cell-array with channel labels
    opt.cfg.channel = opt.hdr.label(chansel);
    disp(opt.cfg.channel);
    guidata(h, opt);
    redraw_cb(h, eventdata);
  case 'downarrow'
    chansel = match_str(opt.hdr.label, opt.cfg.channel);
    minchan = min(chansel);
    maxchan = max(chansel);
    numchan = length(chansel);
    chansel = (minchan:maxchan) + numchan;
    if max(chansel)>length(opt.hdr.label)
      chansel = chansel - (max(chansel)-length(opt.hdr.label));
    end
    % convert numeric array into cell-array with channel labels
    opt.cfg.channel = opt.hdr.label(chansel);
    disp(opt.cfg.channel);
    guidata(h, opt);
    redraw_cb(h, eventdata);
  case 'shift+leftarrow'
    opt.cfg.blocksize = opt.cfg.blocksize*sqrt(2);
    disp(opt.cfg.blocksize);
    guidata(h, opt);
    definetrial_cb(h, eventdata);
    redraw_cb(h, eventdata);
  case 'shift+rightarrow'
    opt.cfg.blocksize = opt.cfg.blocksize/sqrt(2);
    disp(opt.cfg.blocksize);
    guidata(h, opt);
    definetrial_cb(h, eventdata);
    redraw_cb(h, eventdata);
  case 'shift+uparrow'
    opt.cfg.zscale = opt.cfg.zscale/sqrt(2);
    guidata(h, opt);
    redraw_cb(h, eventdata);
  case 'shift+downarrow'
    opt.cfg.zscale = opt.cfg.zscale*sqrt(2);
    guidata(h, opt);
    redraw_cb(h, eventdata);
  case 'q'
    guidata(h, opt);
    cleanup_cb(h);
  case 't'
    % select the trial to display
    response = inputdlg(sprintf('%s to display', opt.trialname), 'specify', 1, {num2str(opt.trlop)});
    if ~isempty(response)
      opt.trlop = str2double(response);
      opt.trlop = min(opt.trlop, size(opt.trlvis,1)); % should not be larger than the number of trials
      opt.trlop = max(opt.trlop, 1); % should not be smaller than 1
    end
    guidata(h, opt);
    redraw_cb(h, eventdata);
  case 'h'
    % select the horizontal scaling
    response = inputdlg('horizontal scale', 'specify', 1, {num2str(opt.cfg.blocksize)});
    if ~isempty(response)
      opt.cfg.blocksize = str2double(response);
    end
    guidata(h, opt);
    definetrial_cb(h, eventdata);
    redraw_cb(h, eventdata);
  case 'v'
    % select the vertical scaling
    response = inputdlg('vertical scale', 'specify', 1, {num2str(opt.cfg.zscale)});
    if ~isempty(response)
      opt.cfg.zscale = str2double(response);
    end
    guidata(h, opt);
    redraw_cb(h, eventdata);
  case 'c'
    % select channels
    select = match_str(opt.hdr.label, opt.cfg.channel);
    select = select_channel_list(opt.hdr.label, select);
    opt.cfg.channel = opt.hdr.label(select);
    guidata(h, opt);
    redraw_cb(h, eventdata);
  case 'control+control'
    % do nothing
  case 'shift+shift'
    % do nothing
  otherwise
    guidata(h, opt);
    help_cb(h);
end
uiresume(h);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function toggle_viewmode_cb(h, eventdata, varargin)
opt = guidata(getparent(h));
if ~isempty(varargin) && ischar(varargin{1})
  opt.cfg.viewmode = varargin{1};
end
guidata(getparent(h), opt);
redraw_cb(h);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = getparent(h)
p = h;
while p~=0
  h = p;
  p = get(h, 'parent');
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function redraw_cb(h, eventdata)
h = getparent(h);
opt = guidata(h);
figure(h); % ensure that the calling figure is in the front
cla;       % clear the content in the current axis

fprintf('redrawing with viewmode %s\n', opt.cfg.viewmode);


artcol = [0.9686 0.7608 0.7686; 0.7529 0.7098 0.9647; 0.7373 0.9725 0.6824;0.8118 0.8118 0.8118; 0.9725 0.6745 0.4784; 0.9765 0.9176 0.5686];

begsample = opt.trlvis(opt.trlop, 1);
endsample = opt.trlvis(opt.trlop, 2);
offset    = opt.trlvis(opt.trlop, 3);
chanindx  = match_str(opt.hdr.label, opt.cfg.channel);

if isempty(opt.orgdata)
  fprintf('reading data... ');
  dat = read_data(opt.cfg.datafile, 'header', opt.hdr, 'begsample', begsample, 'endsample', endsample, 'chanindx', chanindx, 'checkboundary', strcmp(opt.cfg.continuous, 'no'), 'dataformat', opt.cfg.dataformat, 'headerformat', opt.cfg.headerformat);
else
  fprintf('fetching data... ');
  dat = fetch_data(opt.orgdata, 'header', opt.hdr, 'begsample', begsample, 'endsample', endsample, 'chanindx', chanindx);
end
fprintf('done\n');

fprintf('fetching artifacts... ');
art = fetch_data(opt.artdata, 'begsample', begsample, 'endsample', endsample);
fprintf('done\n');

% apply preprocessing and determine the time axis
fprintf('preprocessing data... ');
[dat, lab, tim] = preproc(dat, opt.hdr.label(chanindx), opt.fsample, opt.cfg.preproc, offset);
fprintf('done\n');

fprintf('plotting data... ');
switch opt.cfg.viewmode
  case 'butterfly'
    for i=1:length(opt.artdata.label)
      tmp = diff([0 art(i,:) 0]);
      artbeg = find(tmp==+1);
      artend = find(tmp==-1) - 1;
      for j=1:numel(artbeg)
        plot_box([tim(artbeg(j)) tim(artend(j)) -opt.cfg.zscale opt.cfg.zscale], 'facecolor', artcol(i,:), 'edgecolor', 'none');
      end
    end
    
    % plot the data on top of the box
    plot_vector(tim, dat)
    ax(1) = tim(1);
    ax(2) = tim(end);
    ax(3) = -opt.cfg.zscale;
    ax(4) =  opt.cfg.zscale;
    axis(ax);
    title(sprintf('%s %d, time from %g to %g s', opt.trialname, opt.trlop, tim(1), tim(end)));
    xlabel('time');
    
  case 'vertical'
    tmpcfg = [];
    tmpcfg.layout = 'vertical';
    tmpcfg.channel = opt.cfg.channel;
    tmpcfg.skipcomnt = 'yes';
    tmpcfg.skipscale = 'yes';
    laytime = prepare_layout(tmpcfg, opt.orgdata);
    
    hlim = [tim(1) tim(end)];
    vlim = [-opt.cfg.zscale +opt.cfg.zscale];
    
    % determine the position of each of the labels
    labelx = laytime.pos(:,1) - laytime.width/2 - 0.01;
    labely = laytime.pos(:,2);
    
    ax(1) = min(laytime.pos(:,1) - laytime.width/2);
    ax(2) = max(laytime.pos(:,1) + laytime.width/2);
    ax(3) = min(laytime.pos(:,2) - laytime.height/2);
    ax(4) = max(laytime.pos(:,2) + laytime.height/2);
    axis(ax)
    
    % remember the scaling of the horizontal axis, this is needed for mouse input
    hpos(1) = laytime.pos(1,1) - laytime.width(1)/2; % the position of the left  side of the timecourse box
    hpos(2) = laytime.pos(1,1) + laytime.width(1)/2; % the position of the right side of the timecourse box
    opt.hlim = hlim;
    opt.hpos = hpos;
    
    for j=1:length(opt.artdata.label)
      tmp = diff([0 art(j,:) 0]);
      artbeg = find(tmp==+1);
      artend = find(tmp==-1) - 1;
      arttim = [tim(artbeg)' tim(artend)'];                              % convert the artifact sample number to time
      arttim = (arttim - opt.hlim(1)) / (opt.hlim(2) - opt.hlim(1));   % convert to value relative to box, i.e. from 0 to 1
      arttim = arttim * (opt.hpos(2) - opt.hpos(1)) + opt.hpos(1);     % convert from relative to actual value along the horizontal figure axis
      
      for k=1:numel(artbeg)
        plot_box([arttim(k,1) arttim(k,2) ax(3) ax(4)], 'facecolor', artcol(j,:), 'edgecolor', 'none');
      end
    end % for each of the artifact channels
    
    for i=1:length(chanindx)
      datsel = i;
      laysel = match_str(laytime.label, opt.hdr.label(chanindx(i)));
      if ~isempty(datsel)
        plot_text(labelx(laysel), labely(laysel), opt.hdr.label(chanindx(i)), 'HorizontalAlignment', 'right');
        plot_vector(tim, dat(datsel, :), 'hpos', laytime.pos(laysel,1), 'vpos', laytime.pos(laysel,2), 'width', laytime.width(laysel), 'height', laytime.height(laysel), 'hlim', hlim, 'vlim', vlim, 'box', false);
      end
    end
    
    set(gca, 'xTick', [])
    set(gca, 'yTick', [])
    title(sprintf('%s %d, time from %g to %g s', opt.trialname, opt.trlop, tim(1), tim(end)));
    
  case 'component'
    compindx = chanindx;
    clear chanindx
    
    tmpcfg = [];
    tmpcfg.layout = 'vertical';
    tmpcfg.channel = opt.cfg.channel;
    tmpcfg.skipcomnt = 'yes';
    tmpcfg.skipscale = 'yes';
    laytime = prepare_layout(tmpcfg, opt.orgdata);
    
    tmpcfg = [];
    tmpcfg.layout = opt.cfg.layout;
    laychan = prepare_layout(tmpcfg, opt.orgdata);
    
    % determine the position of each of the topographies
    laytopo.pos(:,1)  = laytime.pos(:,1) - laytime.width/2 - laytime.height*2;
    laytopo.pos(:,2)  = laytime.pos(:,2);
    laytopo.width     = laytime.height;
    laytopo.height    = laytime.height;
    laytopo.label     = laytime.label;
    
    % determine the position of each of the labels
    labelx = laytopo.pos(:,1) + laytopo.width;
    labely = laytopo.pos(:,2);
    
    hlim = [tim(1) tim(end)];
    vlim = [-opt.cfg.zscale +opt.cfg.zscale];
    
    [sel1, sel2] = match_str(opt.orgdata.topolabel, laychan.label);
    chanx = laychan.pos(sel2,1);
    chany = laychan.pos(sel2,2);
    
    for i=1:length(compindx)
      datsel = i;
      laysel = match_str(laytime.label,opt.hdr.label(compindx(i)));
      if ~isempty(datsel)
        plot_text(labelx(laysel), labely(laysel), opt.hdr.label(compindx(i)));
        % plot the timecourse of this component
        plot_vector(tim, dat(datsel, :), 'hpos', laytime.pos(laysel,1), 'vpos', laytime.pos(laysel,2), 'width', laytime.width(laysel), 'height', laytime.height(laysel), 'hlim', hlim, 'vlim', vlim);
        % plot the topography of this component
        chanz = opt.orgdata.topo(sel1,compindx(i));
        plot_topo(chanx, chany, chanz, 'mask', laychan.mask, 'outline', laychan.outline, 'hpos', laytopo.pos(laysel,1), 'vpos', laytopo.pos(laysel,2), 'width', laytopo.width(laysel), 'height', laytopo.height(laysel))
        axis equal
        drawnow
      end
    end
    set(gca, 'xTick', [])
    set(gca, 'yTick', [])
    title(sprintf('%s %d, time from %g to %g s', opt.trialname, opt.trlop, tim(1), tim(end)));
    
    ax(1) = min(laytopo.pos(:,1) - laytopo.width/2);
    ax(2) = max(laytime.pos(:,1) + laytime.width/2);
    ax(3) = min(laytime.pos(:,2) - laytime.height/2);
    ax(4) = max(laytime.pos(:,2) + laytime.height/2);
    axis(ax)
    
    % remember the scaling of the horizontal axis, this is needed for mouse input
    hpos(1) = laytime.pos(1,1) - laytime.width(1)/2; % the position of the left  side of the timecourse box
    hpos(2) = laytime.pos(1,1) + laytime.width(1)/2; % the position of the right side of the timecourse box
    opt.hlim = hlim;
    opt.hpos = hpos;
    
  case 'settings'
    % FIXME implement further details
    
  otherwise
    error('unknown viewmode "%s"', opt.cfg.viewmode);
end % switch viewmode
fprintf('done\n');

guidata(h, opt);
end
