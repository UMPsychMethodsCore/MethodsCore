function [lo] = LI_rank(a);
% This function is used for ranking t-values in order
% to compute a lateralization index. Procedure is as follows:
%
% - load volume, exclude negative and NaN-voxels
%
% - throw out the values that have a less than
%   even chance to be associated with the task,
%   as defined by a corrected FDR of 0.5 (sic!)
%
% - rank all voxels into centiles according to their
%   number distribution (ie, each centile = n voxels)
%
% - assign intensities to each voxel according to its rank
%
% - above a defined significant threshold (FDR=0.05),
%   give extra weight according to the distance from the
%   threshold
%
% It can be called via the li-toolbox, but also directly
% from the command line. It *only* works on spmT_*images.
%
% As usual, bits of code were taken from various functions
% within spm, from Tom Nichols and others. Kudos to all of you!
%
% Idea and implementation by Marko Wilke, USE AT YOUR OWN RISK!


% ==========================================================================================================
%                                          	Inputs, settings, etc.
% ==========================================================================================================

% get version; abort if minimum version not found
  ver = spm('ver');
  if str2num(ver(4:end)) < 8

	uiwait(msgbox(['Sorry, you seem to be using an old version of spm (' ver '); this toolbox expects spm8 or later. We apologize for the inconvenience...'], 'Warning'));
	return;
  end;


% get and load data if not supplied;
  if nargin == 0
	a = spm_select(1,'image','Select file to process',[],pwd,'spmT_.*$');
  end;
  V = spm_vol(a);
  OB = spm_read_vols(V);


% ==========================================================================================================
%                                          	Prepare and analyze data
% ==========================================================================================================


% get maximum t-value
  mx2  = max([max(OB)]);
  mx  = max([mx2]);


% go ahead and find FDR-thresholds, need degrees of freedom first
  n = 20;
  df = spm_str_manip(V.descrip, ['f' num2str(n)]);
  tmp = find(df>='0' & df<='9' | df=='.');
  df = str2num(df(tmp));


% pass to FDR-function for computation; note that this will
% bail out if no supra-threshold voxels are found!
  lo = LI_FDR(a,df,0.5);
  hi = LI_FDR(a,df,0.05);

  if isnan(hi) == 1 | isnan(lo) == 1
	disp('  Warning: no voxels survive FDR-correction - aborting!!');
	msgbox(['No voxels survive FDR-correction in ' (a) ' - please check your data (ranking only works on spmT-images) or try a different thresholding option!'],'Warning');
	lo = NaN;
	return;
  end;


% in OB, set to 0 all below lo
  OB(find(OB<lo)) = 0;
  Ts = OB;
  Ts = min(Ts,spm_read_vols(V));


% clean and sort vector
  Ts(find(Ts<=0)) = 0;
  Ts(isnan(Ts)) = 0;
  Ts = flipud(sort(Ts(:)));
  Ts(find(Ts==0)) = [];


% generate vector to work with: positive values only
  l = size(Ts);
  l = l(1);


% rank remaining values into centiles; smallest value = t(1)
% also fill new vector with real-image thresholds
  iter = 100;
  int = zeros(iter,1);
  t = zeros(iter,1);
  for i=1:iter
	int(i) = l - ((i-1)*l/iter);
	t(i) = Ts(round(int(i)));
  end;


% ==========================================================================================================
%                                          	Apply & Save; generate outputs
% ==========================================================================================================


% to write out intermediate file, re-enable
%  [p nm e v] = spm_fileparts(a);
%  V.fname = fullfile(pwd,['LI_rank_int' e]);
%  spm_write_vol(V, OB);


% find how many centiles in t exceed hi
  hi2 = sum(t>hi);


% get data (again), prepare for output
  OP = spm_read_vols(V);
  OP = (OP.*(OP>0));
  OP(isnan(OP)) = 0;
  OP(find(OP<lo)) = 0;
  TEMP = isfinite(OP).*0;


% now define thresholds for imcalc: give extra weight if above hi2 (centile distance to hi2)
  for i=1:iter
	if i == 1

		thr = [];

	elseif i < (iter-hi2)

		TEMP(find(OP>t(i-1) & OP<t(i))) = (i-1);

	elseif i > (iter-hi2)

		j = abs(hi2-(iter-i))+1;
		TEMP(find(OP>t(i-1) & OP<t(i))) = ((i-1)*j);

	end	

	if i == iter

		j = abs(hi2-(iter-i))+1;
		TEMP(find(OP>t(i) & OP<mx)) = ((i-1)*(j+1));

	end;
  end;


% write output file
  [p nm e v] = spm_fileparts(a);
  V.fname = fullfile(pwd,['LI_rank' e]);
  spm_write_vol(V, TEMP);


% get back to where we once belonged
  return;