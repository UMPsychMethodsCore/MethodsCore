function [ftdata] = spm2ft(D)

% SPM2FT converts an SPM8 meeg object into a FieldTrip raw data structure
%
% Use as
%   data = spm2ft(D)
% where D is the SPM8 meeg object which you can load in with SPM_EEG_LOAD
% and where data is a FieldTrip raw data structure as if it were returned
% by FT_PREPROCESSING.
%
% See also FT_PREPROCESSING, SPM_EEG_LOAD

ft_defaults

% record start time and total processing time
ftFuncTimer = tic();
ftFuncClock = clock();

if ~ft_hastoolbox('spm8')
  error('this requires a full version of SPM8 on your MATLAB path');
end

if ~isa(D, 'meeg')
  error('this requires an SPM8 "meeg" object as input')
end

% this is how SPM8 represents it
spmdata = D.ftraw;

% convert it into a normal MATLAB structure, i.e. get rid of all the SPM8 objects
ftdata = [];
ftdata.fsample = spmdata.fsample;
ftdata.label   = spmdata.label(:);
ftdata.time    = spmdata.time;

ntrials = numel(spmdata.trial);
for i=1:ntrials
  % this converts it from a file_array (on disk) into a normal array (in memory)
  ftdata.trial{i} = spmdata.trial{i}(:,:);
end

clist      = D.condlist;
conditions = D.conditions;

ftdata.trialinfo = zeros(ntrials,1);
for k = 1:numel(clist)
  fprintf('mapping condition label "%s" to condition code %d\n', clist{k}, k);
  sel=strcmp(clist{k}, conditions);
  ftdata.trialinfo(sel) = k;
end

% FIXME the following is not correct
%
% ftdata.sampleinfo = zeros(ntrials,2);
% for i=1:ntrials
%   ftdata.sampleinfo(i,1) = D.indsample(i);
%   ftdata.sampleinfo(i,2) = D.indsample(i) + D.nsamples;
% end

% add the version details of this function call to the configuration
cfg.version.name = mfilename('fullpath');
cfg.version.id   = '$Id: spm2ft.m 3823 2011-07-11 12:41:09Z roboos $';

% add information about the Matlab version used to the configuration
cfg.callinfo.matlab = version();

% add information about the function call to the configuration
cfg.callinfo.proctime = toc(ftFuncTimer);
cfg.callinfo.calltime = ftFuncClock;
cfg.callinfo.user = getusername();

ftdata.cfg = cfg;