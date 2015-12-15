function LI_make_mask
% script to generate maks based on the Hammersmith_n30r83 atlas for us 
% in the LI-toolbox; settings may be adapted but then results will not
% be comparable anymore with results obtained with standard masks!
%
% While this may only work "as is" with the Hammersmith atlas (obtainable from
% Alexander Hammers), it may serve as a template script should you want
% to try other reference brains (one reason why it is very repetitive).
% Note that it will OVERWRITE existing files in ...\LI\data,
% so it is advised to back those up before running this script.
%
% Implementation by Marko Wilke, use at your own risk!


% ==========================================================================================================
%                                          Settings
% ==========================================================================================================


% settings (defaults: 6, 0.25, and 1)
  sym = 1;                  % make each mask symmetrical
  smo = 6;                  % smooth data by smo mm
  thr = 0.25;               % threshold data at thr
  nmasks = 8;               % number of masks to generate
  atlas = 'Hammersmith';    % allow for customization, but remember to then also update all definitions below!
  store = cell(nmasks,3);


% check installation
  clc;
  if ~exist([spm('dir') filesep 'toolbox' filesep 'LI' filesep 'LI_mreslice.m']) == 2

	uiwait(msgbox(['Sorry, you seem to be using an old version of this toolbox, or did not add the standard directory to the path; please mend...'], 'Warning'));
	error('... LI toolbox not found, please reinstall...');
  end;


% get data; the atlas the default masks are based on is the Hammersmith atlas as distributed by 
% Alexander Hammers, whom you will need to contact for it if you want this script to run properly
  atl = spm_select(1,'image',['Select ' atlas ' atlas to create masks from']);


% summarize settings
  disp(' ');
  disp(' ');
  disp(['   ... Beginning to creates masks from the ' atlas ' atlas;']);

  if smo ~= 0
	  disp(['   ... data will initially be smoothed at FWHM = ' num2str(smo) ' mm;']);
  else
	  disp(['   ... data will not be smoothed;']);
  end;

  disp(['   ... data will be then thresholded at ' num2str(thr,'%0.2f') ';']);
 
  if sym ~= 0
	  disp(['   ... masks will be symmetrical;']);
  else
	  disp(['   ... masks will not be symmetrical;']);
  end;

  disp('   ... please wait...');


% region definitions (all based on  Hammersmith atlas n30r83): frontal lobe
  targ = [28 29];        % Middlle frontal gyrus 
  targ = [targ 20 21];   % Insula 
  targ = [targ 50 51];   % Precentral gyrus 
  targ = [targ 52 53];   % Straight gyrus 
  targ = [targ 54 55];   % Anterior orbital gyrus 
  targ = [targ 56 57];   % Inferior frontal gyrus 
  targ = [targ 58 59];   % Superior frontal gyrus 
  targ = [targ 68 69];   % Medial orbital gyrus 
  targ = [targ 70 71];   % Lateral orbital gyrus 
  targ = [targ 72 73];   % Posterior orbital gyrus 
  targ = [targ 76 77];   % Subgenual frontal cortex 
  targ = [targ 78 79];   % Subcallosal area 
  targ = [targ 80 81];   % Pre-subgenual frontal cortex
  store{1,1} = targ;
  store{1,2} = ['LI-toolbox frontal lobe mask, based on the ' atlas  ' atlas'];
  store{1,3} = [spm('dir') filesep 'toolbox' filesep 'LI' filesep 'data' filesep 'LI-frontal-mask.img'];


% region definitions: temporal lobe 
  targ = [1 2];          % Hippocampus 
  targ = [targ 3 4];     % Amygdala 
  targ = [targ 5 6];     % Anterior temporal lobe, medial part 
  targ = [targ 7 8];     % Anterior temporal lobe, lateral part 
  targ = [targ 9 10];    % Parahippocampal and ambient gyri 
  targ = [targ 11 12];   % Superior temporal gyrus, posterior part 
  targ = [targ 13 14];   % Middle and inferior temporal gyrus 
  targ = [targ 15 16];   % Fusiform gyrus 
  targ = [targ 30 31];   % Posterior temporal lobe 
  targ = [targ 82 83];   % Superior temporal gyrus, anterior part
  store{2,1} = targ;
  store{2,2} = ['LI-toolbox temporal lobe mask, based on the ' atlas  ' atlas'];
  store{2,3} = [spm('dir') filesep 'toolbox' filesep 'LI' filesep 'data' filesep 'LI-temporal-mask.img'];


% region definitions: cerebellum
  targ = [17 18];        % Cerebellum 
  store{3,1} = targ;
  store{3,2} = ['LI-toolbox cerebellar mask, based on the ' atlas  ' atlas'];
  store{3,3} = [spm('dir') filesep 'toolbox' filesep 'LI' filesep 'data' filesep 'LI-cerebellar-mask.img'];


% region definitions: cingulum
  targ = [24 25];        % cingulate gyrus, anterior part 
  targ = [targ 26 27];   % cingulate gyrus, posterior part 
  store{4,1} = targ;
  store{4,2} = ['LI-toolbox cingulate mask, based on the ' atlas  ' atlas'];
  store{4,3} = [spm('dir') filesep 'toolbox' filesep 'LI' filesep 'data' filesep 'LI-cingulate-mask.img'];


% region definitions: occipital lobe 
  targ =  [64 65];       % Lingual gyrus 
  targ =  [targ 66 67];  % Cuneus 
  targ =  [targ 22 23];  % Lateral remainder of occipital lobe
  store{5,1} = targ;
  store{5,2} = ['LI-toolbox occipital lobe mask, based on the ' atlas  ' atlas'];
  store{5,3} = [spm('dir') filesep 'toolbox' filesep 'LI' filesep 'data' filesep 'LI-occipital-mask.img'];


% region definitions: parietal lobe 
  targ = [60 61];        % Postcentral gyrus 
  targ = [targ 62 63];   % Superior parietal gyrus 
  targ = [targ 32 33];   % Inferiolateral remainder of parietal lobe 
  store{6,1} = targ;
  store{6,2} = ['LI-toolbox parietal lobe mask, based on the ' atlas  ' atlas'];
  store{6,3} = [spm('dir') filesep 'toolbox' filesep 'LI' filesep 'data' filesep 'LI-parietal-mask.img'];


% region definitions: central gray matter 
  targ = [34 35];        % Caudate nucleus 
  targ = [targ 36 37];   % Nucleus accumbens 
  targ = [targ 38 39];   % Putamen 
  targ = [targ 40 41];   % Thalamus 
  targ = [targ 42 43];   % Pallidum 
  store{7,1} = targ;
  store{7,2} = ['LI-toolbox central gray matter mask, based on the ' atlas  ' atlas'];
  store{7,3} = [spm('dir') filesep 'toolbox' filesep 'LI' filesep 'data' filesep 'LI-central-mask.img'];


% region definitions: global gray matter 
  targ = [];
  for i = 1:nmasks-1

	targ = [targ store{i,1}];
  end;
  store{8,1} = targ;
  store{8,2} = ['LI-toolbox global gray matter mask, based on the ' atlas  ' atlas'];
  store{8,3} = [spm('dir') filesep 'toolbox' filesep 'LI' filesep 'data' filesep 'LI-gray-matter-mask.img'];


% not assigned: 45 & 46 (Lateral ventricle, excluding temporal horn);
%               47 & 48 (Lateral ventricle, temporal horn); 
%               49      (Third ventricle)
%               44      (Corpus callosum)
%               19      (Brainstem)
%               74 % 75 (Substantia nigra)


% ==========================================================================================================
%                                          Processing
% ==========================================================================================================


% get going: reslice atlas to desired dimension
  atl = LI_mreslice([spm('dir') filesep 'toolbox' filesep 'LI' filesep 'data' filesep 'randbrain.img'],atl,7,[],[]);


% get information for writing masks
  V = spm_vol([spm('dir') filesep 'toolbox' filesep 'LI' filesep 'data' filesep 'randbrain.img']);


% loop over mask information
  for i = 1:nmasks


	% get data
	  targ = store{i,1};
	  temp = zeros(size(atl));


	% loop over values
	  for ii = 1:length(targ)

		temp = temp + (round(atl) == targ(ii));
	  end;


	% ...make symmetrical (this assumes data to be as expected)...
	  targ = double((temp + flipdim(temp,1)) > 0);


	% ... potentially smooth...
	  if smo ~= 0

		temp = zeros(size(targ));
		spm_smooth(targ,temp,[smo smo smo]);
	  end;


	% ... and threshold...
	  targ = temp > thr;


	% ... and write out
	  nV         = V;
	  nV.dt      = [2 0];
	  nV.pinfo   = [1 0 0]';
	  nV.descrip = store{i,2};
	  nV.fname   = store{i,3};
	  spm_write_vol(nV,targ);

  end;


% this seems to be it
  disp(' ');
  disp(' ');
  disp('   ... thank you for running this script, your new masks were saved in');
  disp(['   ... the LI-toolbox data directory (' spm('dir') filesep 'toolbox' filesep 'LI' filesep 'data);']);
  disp('   ... Have a nice day :)');
  disp(' ');
  disp(' ');
  return;
