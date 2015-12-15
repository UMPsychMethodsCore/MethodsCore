function [thrs, lis] = LI_iter(A,B,C,out,sm,vw,pre,B1,B2,outfile,L,R);
% function [lis, thrs, voxl, voxr] = LI_iter(A,B,C,out,sm,vw,pre,L,R);
% Function to iteratively calculate lateralization indices;
% part of the LI-toolbox: can be used as a standalone function
% and is used via li.m to calculate li-curves. 
% Written by Marko Wilke; USE AT YOUR OWN RISK!


% ==========================================================================================================
%                                          	Inputs, settings etc.
% ==========================================================================================================


% ===== change stdpth if your masks reside elsewhere  =====
  stdpth = [spm('Dir') filesep 'toolbox' filesep 'LI' filesep 'data'];
  global script ni


% get version; abort if minimum version not found
  ver = spm('ver');
  if str2num(ver(4:end)) < 8

	uiwait(msgbox(['Sorry, you seem to be using an old version of spm (' ver '); this toolbox expects spm8 or later. We apologize for the inconvenience...'], 'Warning'));
	return;
  end;


% set critical number of voxels (ncr), minimum cluster size (k), minimum number of voxels (nabort), and number of iterations
  ncr = 10;
  k = 5;
  nabort = 5;
  iter = 20;

% ===== Get images, check if passed; else ask  ===== 
  if nargin < 2
	manual = 1;
	graphs = 1;

	% if not called via li.m, clear the deck
	  clc
	  fg = spm_figure('Findwin','Graphics');
	  fi = spm_figure('Findwin','Interactive');
	  spm_figure('Clear',fg);
	  spm_figure('Clear',fi);
	  B2 = 0;

	% get data
	  A = spm_select([1 Inf],'image','Select input Image(s)',[],pwd,'spm[TF]_.*$');

	  B1 = spm_input('Select INclusive mask','!+1','m', ...
                [' Frontal Lobe| Parietal Lobe| Temporal Lobe|'...
		 ' Occipital Lobe| Cingulate| Central Gray matter (BG, Thalamus)|'...
		 ' Cerebellum| Gray Matter...| All Lobes| None| Custom...'], ...
		 [1 2 3 4 5 6 7 8 9 10 11],1);
	  if B1 == 1
		B = fullfile(stdpth,'LI-frontal-mask.img');
	  elseif B1 == 2
		B = fullfile(stdpth,'LI-parietal-mask.img');
	  elseif B1 == 3
		B = fullfile(stdpth,'LI-temporal-mask.img');
	  elseif B1 == 4
		B = fullfile(stdpth,'LI-occipital-mask.img');
	  elseif B1 == 5
		B = fullfile(stdpth,'LI-cingulate-mask.img');
	  elseif B1 == 6
		B = fullfile(stdpth,'LI-central-mask.img');
	  elseif B1 == 7
		B = fullfile(stdpth,'LI-cerebellar-mask.img');
	  elseif B1 == 8
		B2 = spm_input('Standard or individual gray matter?','!+1','m', ...
                	' Standard gray matter mask (provided)| Individual gray matter mask (select now)', ...
			[1 2],1);
		if B2 == 1
			B = fullfile(stdpth,'LI-gray-matter-mask.img');
		else
			B3 = spm_select(1,'image','Select coregistered gray matter image',[],pwd,'c1.*');
			pre = 1;
			B = B3;
		end;
	  elseif B1 == 9
		m1 = fullfile(stdpth,'LI-frontal-mask.img');
		m2 = fullfile(stdpth,'LI-parietal-mask.img');
		m3 = fullfile(stdpth,'LI-temporal-mask.img');
		m4 = fullfile(stdpth,'LI-occipital-mask.img');
		m5 = fullfile(stdpth,'LI-cingulate-mask.img');
		m6 = fullfile(stdpth,'LI-central-mask.img');
		m7 = fullfile(stdpth,'LI-cerebellar-mask.img');
		B  = char({m1, m2, m3, m4, m5, m6, m7});
	  elseif B1 == 10
		B = 'none';
	  elseif B1 == 11
		  B = spm_select([0 1],'image','INclusive Mask - Done for None',[],stdpth,'LI.*');
		  if isempty(B)
			B = 'none';
		  else
			pre = spm_input('Pre-process masks ?','+1','b',['Yes| No'],[1 0],0);
		  end;
	  end;
  else
	manual = 0;
  end;

  if nargin < 3
	C1 = spm_input('Select EXclusive mask','!+1','m', ...
                      ' Midline (+/- 5mm)| Midline (+/- 11mm)| None| Custom...', ...
		      [1 2 3 4],1);
	if C1 == 1
		C = fullfile(stdpth,'LI-midline_5_ex.img');
	elseif C1 == 2
		C = fullfile(stdpth,'LI-midline_11_ex.img');
	elseif C1 == 3
		C = 'none';
	elseif C1 == 4
		C = spm_select(1,'image','EXclusive Mask - Done for None',[],stdpth,'_ex.*');
		if isempty(C)
			C = 'none';
		end;
	end;
  end;
	if isempty(C)
		C = 'none';
	end;


% ===== ask how the output is supposed to be; defined via command line, check if in manual ===== 
  if nargin < 4
	out = spm_input('Output format?','+1','m',[' Screen| Screen & File| File only'],[1 2 3],1);
		if out == 3
			graphs = 0;
			out = 2;
		end;
  else
	% if passed via li.m, show graphics only for smaller collection;
	% note that results will always be saved to li_curves.ps
	  out = out;
	  manual = 1;
	  if (size(A,1)+size(B,1)) > 10 | script == 1
		graphs = 0;
		fprintf(['  Processing ' num2str(size(A,1)) ' images and ' num2str(size(B,1)) ' masks- bypassing graphics (direct save to file LI_curves.ps).' '\n']);
	  else
		graphs = 1;
	  end
  end;


% ===== check optional steps (clustering, variance weighting, or both  ===== 
  if nargin < 6
	op = spm_input('Select Optional Steps','!+1','m', ...
                      'Clustering| Variance weighting| Both| None', ...
		      [1 2 3 4],4);
	  if op == 1
		sm = 1;	vw = 0;	wi = 0;
		fprintf(['  Applying data clustering.' '\n']);
	  elseif op == 2
		sm = 0;	vw = 1;	wi = 1;
		fprintf(['  Applying variance weighting.' '\n']);
	  elseif op == 3
		sm = 1;	vw = 1;	wi = 1;
		fprintf(['  Applying combined clustering and variance weighting.' '\n']);
	  elseif op == 4
		sm = 0;	vw = 0;	wi = 0;
		fprintf(['  Applying no optional steps.' '\n']);
	  end;
  end;


% ===== check if masks need top be pre-processed  ===== 
  if nargin < 8
	if B1 == 11 & strcmp(B,'none')~= 1
		pre = spm_input('Pre-process masks ?','+1','b',['Yes| No'],[1 0],0);
	else
		pre = 0;
	end;
  end;


%  ===== set name for output file ===== 
  if nargin < 10
	outfile = 'li.txt';
  else
	outfile = outfile;
  end;


% ===== if arguments pertaining to L/R images are passed, double-check ===== 
  if nargin <= 12
	L = fullfile(stdpth,'LI-left.img');
	R = fullfile(stdpth,'LI-right.img');
  else
	L = spm_select(1,'image','Select custom left Mask',[],stdpth,'.*');
	R = spm_select(1,'image','Select custom right Mask',[],stdpth,'.*');
  end;


% =====  check handedness of L/R images  =====
  M_L = spm_get_space(L);
  M_R = spm_get_space(R);
  if det(M_R(1:3,1:3)) * det(M_L(1:3,1:3))  < 0

	error(['  Caution: images for left (' L ') and right (' R ') are of different handedness, aborting!']);
  end;
  ori_R = R;
  ori_L = L;


% ===== switch off Matlab warning ===== 
  warning off MATLAB:divideByZero


% ==========================================================================================================
%                                          	Calculations
% ==========================================================================================================


% ===== start looping through all supplied input images ===== 
  ninputs = size(A,1);
  for i = 1:ninputs
	file = A(i,:);
	file_ns = file;
	file_vol_ns = spm_vol(file);
	check_dims = spm_get_space(A(i,:));
	check_dims = sqrt(sum(check_dims(1:3,1:3).^2));


	% =====  assume correct, but double-check handedness of image under scrutiny  =====
	  R = ori_R;
	  L = ori_L;
	  M_C = spm_get_space(A(i,:));
	  if det(M_C(1:3,1:3)) * det(M_L(1:3,1:3))  < 0

		[p nm e v] = spm_fileparts(file_ns);
		fprintf(['  Handedness of image ' nm ' differs from standard assumption, adjusting L/R images...' '\n']);
		L = ori_R;
		R = ori_L;

	  end;


	% ===== checking and implementing options prior to threshold looping ===== 
	% Note that the smoothing factor sf will apply for both
	% smoothing and variance weighting (so combined use is possible)
	% Get voxel dimensions to allow for anisotropic smoothing;
	  if sm == 1 | vw == 1
		sf = 3;
		dim1 = sf*check_dims(1);
		dim2 = sf*check_dims(2);
		dim3 = sf*check_dims(3);
	  end;

	% if variance weighting should be done, derive file name and check it
	% (before smooth changes it :); Else, proceed (allow automation)
	  if vw == 1
		  PP = 'Processing weighting image';
		  spm('FigName', PP);
		[p nm e v] = spm_fileparts(file);
		wi = [p filesep 'ResMS' e];
		if exist(wi, 'file') == 0
			msgbox(['The corresponding variance weighting image for the input image ' (file) ' was not found; proceeding without variance weighting!'], 'Variance weighting image not found!');
			vw = 0;
			wi = 'none';
		end;
		if vw == 1
			spm_smooth(wi, 'LI_weight.img', [dim1 dim2 dim3]);
			wi = 'LI_weight.img';
		end;
	  end;


	% if smoothing was chosen, implement here
	  if sm == 1
		  PP = ['Smoothing input image (sf:' num2str(sf) ')'];
		  spm('FigName', PP);
		smfile = file;
		spm_smooth(file, 'LI_s_input.img', [dim1 dim2 dim3]);
		file = 'LI_s_input.img';
	  end;


	% ===== Check all options and set files prior to looping (saves time) =====
	    PP = 'Checking options';
	    spm('FigName', PP);

	  if vw == 0
	      if strcmp(B,'none')~=1
		  if strcmp(C,'none')~=1;    my_case = 1;    else    my_case = 2;    end;
	      else
		  if strcmp(C,'none')~=1;    my_case = 3;    else    my_case = 4;    end;
	      end;
  	  else
	      if strcmp(B,'none')~=1
		  if strcmp(C,'none')~=1;    my_case = 5;    else    my_case = 6;    end;
	      else
		  if strcmp(C,'none')~=1     my_case = 7;    else    my_case = 8;    end;
	      end;
	  end;

	% ===== check if images are in the right format (template bb, 2x2x2) =====
	% if not normalized, proceed to do an affine transformation; use random-to-random
	% transformation and masking to avoid intensity/NaN problems ; if normalized, but
	% not to template space/our resolution, reslice only (rigid body)
	  check = spm_read_vols(file_vol_ns);
	  if check_dims./[2 2 2] ~= [1 1 1]
		check_dims = 0;
	  end;

	  if size(check,1) ~= 91 | size(check,2) ~= 109 | size(check,3) ~= 91 | check_dims == 0

		% ok, not in template space or not in our resolution; check once if all are normalized
		  if ni == 2
			if ninputs > 1
				ask = 'Are all input images normalized?';
			else
				ask = 'Is this input image normalized?';
			end;
			ni = spm_input(ask,'+1','m',[' Yes| No'],[1 0],1);
		  end;


		% initialize variables
		  [p nm e v] = spm_fileparts(file_ns);
		  p2 = spm_str_manip(p, 'a20');
		  VG = fullfile(stdpth,'randbrain.img');
		  VWG = fullfile(stdpth,'randmask.img');


		% this asks for each input individually; disabled since all constrasts should be either normalized or not
		% ni = spm_input(['Is the input from ' (p2) ' normalized?'],'+1','m',[' Yes| No'],[1 0],1);

 		  if ni == 0
			  PP = ['Normalizing input image'];
			  spm('FigName', PP);
			VF = check;    VF(isnan(VF)) = 0;    VF(abs(VF)>0) = 1;
			VR = rand(size(VF,1),size(VF,2),size(VF,3)).*VF;
			Vn = file_vol_ns;
			Vn.fname = 'LI_rand.img';
			spm_write_vol(Vn,VR);

			LI_normalise(VG,'LI_rand.img','LI_normalize.mat',VWG,[]);
		        LI_write_sn(file,'LI_normalize.mat');

			if vw == 1
				LI_write_sn(wi,'LI_normalize.mat');
				[pwi nmwi ewi vwi] = spm_fileparts(wi);
				wi = fullfile(pwd,['LI_w_' nmwi ewi]);
		                wi_vol = spm_read_vols(spm_vol(wi));
		                wi_vol(isnan(wi_vol)) = 0;
			end;
			[p nm e v] = spm_fileparts(file);
			file = fullfile(pwd,['LI_w_' nm e]);
			file_vol = spm_read_vols(spm_vol(file));
			file_vol(isnan(file_vol)) = 0;

		  elseif ni == 1
			  PP = ['Matching input image'];
			  spm('FigName', PP);
			  [p nm e v] = spm_fileparts(file);

			if vw == 1
				file_vol = LI_mreslice(VG,file,1,[],['LI_r_' nm e]);
				wi_vol   = LI_mreslice(VG,wi,1,[],0);
				wi_vol(isnan(wi_vol)) = 0;

			else
				file_vol = LI_mreslice(VG,file,1,[],['LI_r_' nm e]);
			end;
			file = fullfile(pwd,['LI_r_' nm e]);
			file_vol(isnan(file_vol)) = 0;
		  end;
	  else

		file_vol = spm_read_vols(spm_vol(file));
		file_vol(isnan(file_vol)) = 0;
	  end;


	% ===== start looping through all supplied mask images ===== 
	  nmasks = size(B,1);
	  for ii = 1:nmasks
        	mask = B(ii,:);


		% ===== only need to recalculate if masks not in standard format =====
		% also need to check if masks need to be normalized (must be in-register with functionals)
		  if pre == 1
			  PP = 'Preprocessing custom mask';
			  spm('FigName', PP);

			LI_imcalc({mask},'LI_complete_mask.img','i1>0.5',{[],[],['uint8'],0});

			if ni == 0
				  LI_write_sn('LI_complete_mask.img','LI_normalize.mat');
				  mask_c = 'LI_w_LI_complete_mask.img';
			elseif ni == 1
				  mask_c = 'LI_r_LI_complete_mask.img';
				  LI_mreslice(VG,'LI_complete_mask.img',1,0.1,mask_c);
			end;

			if B1 == 8 & B2 ==2
				% if a subject's own gm-segment is chosen, need to double-preprocess (smooth, flip, binarize)
				  spm_smooth(mask_c,'LI_s_ind_GM.img',[12]);
				  LI_imcalc({'LI_s_ind_GM.img'},'LI_complete_mask.img','(i1+flipud(i1))>0.5',{[],[],[],0});
				  mask_c = 'LI_complete_mask.img';
			else
				% if another mask is chosen, just flip and binarize
				  LI_imcalc({mask_c},'LI_complete_mask.img','(i1+(flipud(i1)))>0.1',{[],[],['uint8'],0});
				  mask_c = 'LI_complete_mask.img';
			end;
		  else
			mask_c = mask;
		  end;


		% ===== set necessary variables here prior to looping; make sure to exclude NaN's ===== 
		  R_vol = spm_read_vols(spm_vol(R));          R_vol(isnan(R_vol)) = 0;
		  L_vol = spm_read_vols(spm_vol(L));          L_vol(isnan(L_vol)) = 0;
		  if strcmp(B,'none')~=1;    mask_vol = spm_read_vols(spm_vol(mask_c));    mask_vol(isnan(mask_vol)) = 0;
			else                 mask_vol = ones(size(L_vol));                 end;
		  if strcmp(C,'none')~=1;    C_vol = spm_read_vols(spm_vol(C));            C_vol(isnan(C_vol)) = 0;       end;		


		% Prior to looping, compute mask weighting factor to rule 
		% out any possible influence due to different masking volumes
		  if strcmp(B,'none')~=1
			mwf = sum(sum(sum((L_vol>0.1).*(mask_vol>0.1))))/sum(sum(sum((R_vol>0.1).*(mask_vol>0.1))));

			% issue a warning and abort if mask is very asymmetrical
			  if mwf > 2 | mwf < 0.5
				uiwait(msgbox(['The mask you chose is VERY asymetrical (Vol [L] / Vol [R] = ' num2str(mwf) ') - are you REALLY sure you want to continue?'], 'Mask asymmetry warning', 'warn'));
				maw = spm_input('Continue with this mask?','+1','b',[' Yes| No'],[1 0],0);
				if maw == 0
					return;
				end;
			  end;
		  else
			mwf = 1;
		  end;


		% ===== here comes the loop to generate (iter) thresholds; default is 20 ===== 
		  thrs = zeros(iter,1);
		  lis = zeros(iter,1);
		  warning off MATLAB:divideByZero           % create lis as a NaN-array to avoid later display of empty values
		    lis = zeros(iter,1)./zeros(iter,1);
		  warning on MATLAB:divideByZero
		  voxl = zeros(iter,1);
		  voxr = zeros(iter,1);
		  clusl = zeros(iter,1);
		  clusr = zeros(iter,1);

		  for j=1:iter;

			% generate 'iter' thresholds as fractions of maximum image value; use
			% (j-1) here since the maximum will always lead to a divide by zero
			    PP = ['Getting LIs - Iteration ' num2str(j) ' of ' num2str(iter)];
			    spm('FigName', PP);

			  if j == 1
				thr3 = 0;
			  else
				thr3 = (j-1)*mx/iter;
			  end;

			% mask image with current threshold; need to account for variance weighting
			  if vw == 0
				con_vol = file_vol.*(file_vol>thr3);
			  else
				con_vol = file_vol.*((file_vol./(wi_vol+eps))>thr3);
			  end;

			% ===== Need to check all options (again) and calculate ===== 
			  if my_case == 1
			  	res_l = con_vol.*(mask_vol>0.1).*C_vol.*(L_vol>0.1);
			  	res_r = con_vol.*(mask_vol>0.1).*C_vol.*(R_vol>0.1);
			  elseif my_case == 2
			  	res_l = con_vol.*(mask_vol>0.1).*(L_vol>0.1);
			  	res_r = con_vol.*(mask_vol>0.1).*(R_vol>0.1);
			  elseif my_case == 3
			  	res_l = con_vol.*C_vol.*(L_vol>0.1);
			  	res_r = con_vol.*C_vol.*(R_vol>0.1);
			  elseif my_case == 4
			  	res_l = con_vol.*(L_vol>0.1);
			  	res_r = con_vol.*(R_vol>0.1);
			  elseif my_case == 5
			  	res_l = (con_vol./(wi_vol+eps)).*(mask_vol>0.1).*C_vol.*(L_vol>0.1);
			  	res_r = (con_vol./(wi_vol+eps)).*(mask_vol>0.1).*C_vol.*(R_vol>0.1);
			  elseif my_case == 6
			  	res_l = (con_vol./(wi_vol+eps)).*(mask_vol>0.1).*(L_vol>0.1);
			  	res_r = (con_vol./(wi_vol+eps)).*(mask_vol>0.1).*(R_vol>0.1);
			  elseif my_case == 7
			  	res_l = (con_vol./(wi_vol+eps)).*C_vol.*(L_vol>0.1);
			  	res_r = (con_vol./(wi_vol+eps)).*C_vol.*(R_vol>0.1);
			  elseif my_case == 8
			  	res_l = (con_vol./(wi_vol+eps)).*(L_vol>0.1);
			  	res_r = (con_vol./(wi_vol+eps)).*(R_vol>0.1);
			  end;

			% ===== get maximum voxel value in masked input image ===== 
			  if j == 1
				mx = max(max(max(res_l+res_r)));
			  end;


			% ===== convert to binary if voxel count is of interest ===== 
			% not normally used; if desperately wanted, change here (will adjust cm below)
			  vc = 0;
			  if vc == 1
				res_l = double(res_l > 0);
				res_r = double(res_r > 0);
				% fprintf('Using voxel count...');
			  end;


			% ===== now check for voxel numbers and minimum cluster size; set to 5 by default  ===== 
			    PP = 'Checking clusters (left & right)';
			    spm('FigName', PP);

			% prepare and pass for labelling
			  [c_r,numr] = spm_bwlabel(res_r,18);
			  [c_l,numl] = spm_bwlabel(res_l,18);
			  c_r = sort(reshape(c_r,1,[]));
			  c_r(find(c_r==0)) = [];
			  c_l = sort(reshape(c_l,1,[]));
			  c_l(find(c_l==0)) = [];

			% get number of voxels decision is based on
			  nvoxr = size((c_r),2);
			  nvoxl = size((c_l),2);

			% warn if voxel number is below critical (set to 10 by default) and abort iterations if below minimum (set to 5 by default) 
			  if nvoxr < ncr & nvoxr > nabort
				fprintf(['\n' '\t' 'Warning: Number of voxels on the RIGHT is only ' num2str(nvoxr) ' !' '\n' '\n']);
			  elseif nvoxr < nabort
				fprintf(['\n' '\t' 'Warning: Number of voxels on the RIGHT (iteration = ' num2str(j) '/' num2str(iter) ', threshold = ' num2str(thr3) ') is below required minimum (' num2str(nabort) ') - aborting iterations!' '\n' '\n']);
				break
			  end;

			  if nvoxl < ncr & nvoxl > nabort
				fprintf(['\n' '\t' 'Warning: Number of voxels on the LEFT is only ' num2str(nvoxl) ' !' '\n' '\n']);
			  elseif nvoxl < nabort
				fprintf(['\n' '\t' 'Warning: Number of voxels on the LEFT (iteration = ' num2str(j) '/' num2str(iter) ', threshold = ' num2str(thr3) ') is below required minimum (' num2str(nabort) ') - aborting iterations!' '\n' '\n']);
				break
			  end;


			% now check if at least one cluster on the left or right is above k
			  QR = 0;
			  for kk = 1:numr
				ll = find(c_r == kk);
				if length(ll) >= k
					QR = 1;
				end;
				% only need one cluster, so if found, break out
				  if QR == 1; break; end;
			  end;

			  QL = 0;
			  for kk = 1:numl
      				ll = find(c_l == kk);
				if length(ll) >= k
					QL = 1;
				end;
				% only need one cluster, so if found, break out
				  if QL == 1; break; end;
			  end;

			% generate warning if no cluster above k is found
			  if QR == 0
				fprintf(['\n' '\t' 'Warning: No cluster on the RIGHT is > ' num2str(k) ' voxels!' '\n']);
				% lis(j) = NaN;		% re-enable if you want to use cluster 
				% break			% size as a killer criterion
			  end;

			  if QL == 0
				fprintf(['\n' '\t' 'Warning: No cluster on the LEFT is > ' num2str(k) ' voxels!' '\n']);
				% lis(j) = NaN;		% re-enable if you want to use cluster 
				% break			% size as a killer criterion
			  end;


			% ===== Finally, calculate lateralization index  =====
			%	 +1 is all LEFT	   -1 is all RIGHT
			% also avoid Divide by Zeros error message
			% and take into account mask weighting factor
			    PP = 'Calculating LI... complete';
			    spm('FigName', PP);

			  CL = sum(res_l(find(res_l.*(res_l>0))));
			  CR = sum(res_r(find(res_r.*(res_r>0))));

			  LI1 = (CL/mwf-CR)/((CL/mwf+CR)+eps);


			% ===== store results for later use ===== 
			  lis(j) = LI1;
			  thrs(j) = thr3;
			  voxl(j) = nvoxl;
			  voxr(j) = nvoxr;
			  clusr(j) = numr;
			  clusl(j) = numl;

			% ===== convert for display =====

			  files = spm_str_manip(file_ns, ['t' 's']);
			  files_p = spm_str_manip(file_ns, ['h' 's']);
			  files_p = strrep(files_p, '\', '/');
			  if findstr(file_vol_ns.descrip,'contrast') ~= 0
				[l, f] = strtok(file_vol_ns.descrip,'contrast');
				files = [files ' (' deblank(f) ')'];
			  end;
		 	  if strcmp(mask, 'none') ~= 1;
				masks = spm_str_manip(mask, ['t' 's']);    masks = strrep(masks, '\', '/');
			  else
				masks = 'none';
			  end;
			  if strcmp(C,'none')~= 1
				cs = spm_str_manip(C, ['t' 's']);    cs = strrep(cs, '\', '/');
			  else
				cs = 'none';
			  end;
			  if vw == 1;    vwd = 'yes';    else   vwd = 'no';    end;
			  if sm == 1;    smd = 'yes';    else   smd = 'no';    end; 
			  meth = '(iterative)';
			  if vc == 1
				cm = 'total voxel count';
			  else
				cm = 'total voxel values';
			  end;
			  LI = sprintf('%0.3g', LI1);
			  thrd = sprintf('%0.3g', thr3);
			  nvoxrd = sprintf('%0g', nvoxr);
			  nvoxld = sprintf('%0g', nvoxl);
			  numrd = sprintf('%0g', numr);
			  numld = sprintf('%0g', numl);


% ==========================================================================================================
%                                          	Outputs
% ==========================================================================================================


			% shut up if in auto-mode :)
			  if manual == 1
				for rep=1:out
					fid = rep;
					if rep == 2
						fid = fopen(outfile,'At+');
					end;	

					% write tab-delimited results to screen or file (spreadsheet-friendly); always show in command window
					  if rep == 1 & j == 1
						  fprintf(['\t' 'Input image' '\t' 'Inclusive mask' '\t' 'Exclusive mask' '\t' 'Threshold' '\t' 'LI' '\t' 'Method' '\t' 'VC/VV' '\t' 'Variance Weighting' '\t' 'Clustering' '\t' 'Voxels (right)' '\t' 'Voxels (left)' '\t' 'Clusters (right)' '\t' 'Clusters (left)' '\n']);
					  end;

					% only write header to file if not there yet
					  new = exist([pwd filesep outfile],'file');
					  if new == 0 & rep == 2
						fprintf(fid, ['\t' 'Input image' '\t' 'Inclusive mask' '\t' 'Exclusive mask' '\t' 'Threshold' '\t' 'LI' '\t' 'Method' '\t' 'VC/VV' '\t' 'Variance Weighting' '\t' 'Clustering' '\t' 'Source path' '\t' 'Voxels (right)' '\t' 'Voxels (left)' '\t' 'Clusters (right)' '\t' 'Clusters (left)' '\n']);
					  end;
						fprintf(fid, ['\t' (files) '\t' (masks) '\t' (cs) '\t' (thrd) '\t' (LI) '\t' (meth) '\t' (cm) '\t' (vwd) '\t' (smd) '\t' (files_p) '\t' (nvoxrd) '\t' (nvoxld) '\t' (numrd) '\t' (numld) '\n']);
					  if rep == 2
						fclose(fid);
					end;
				end;
			  end;
		  end;

		% compute graphical results...
		  if graphs == 1
			  a = figure;
		  else
			  a = figure('visible', 'off');
 		  end;
		  plot(thrs,lis);
		  axis([0,max(thrs),-1,1]);
		  title(['LI vs. threshold for ' (files)], 'interpreter', 'none', 'Fontweight', 'bold');
		  set(a, 'Name', 'Lateralization curve');
		  for t=1:max(find(thrs>0))
			if voxl(t)>10
				t1 = text(thrs(t),1-1/iter*t,num2str(voxl(t)));
				set(t1,'color','b','FontSize',8);
			else
				t2 = text(thrs(t),1-1/iter*t,num2str(voxl(t)));
				set(t2,'color','r','FontSize',8);
			end;
			if voxr(t)>10
				t3 = text(thrs(t),-1+1/iter*t,num2str(voxr(t)));
				set(t3,'color','b','FontSize',8);
			else
				t4 = text(thrs(t),-1+1/iter*t,num2str(voxr(t)));
				set(t4,'color','r','FontSize',8);
			end;
		  end;
		  t5 = text(0.8*max(thrs),0.85,'#of voxels (L)');
		  t6 = text(0.8*max(thrs),-0.85,'#of voxels (R)');
		  set([t5, t6],'color','b','FontSize',10,'BackgroundColor','w');
		  l = findobj(a, 'Type', 'line');
		  set(l,'color','b');
		  % set(l,'LineStyle','-.'); % allow for alternative visualization
		  refresh;
		  grid on;
		  zoom on;

		% ... save to file LI_curves.ps
		  fg = spm_figure('Findwin',a);
		  fnote = sprintf('%s%s%s',['Incl: ' (masks)],[';   Excl.: ' (cs)], [';   Clust.: ' (smd) ';   VarWeight.: ' (vwd)]);
		  set(0,'CurrentFigure',fg);
		  axes('Position',[0.005,0.005,0.1,0.1], 'Visible','off');
		  text(0,0,fnote,'FontSize',8,'interpreter','none');


		% sanity check
		  try
			  if exist([pwd filesep 'LI_curves.ps'],'file') == 2
				  print(fg,'LI_curves.ps','-dpsc2', '-painters', '-append', '-noui');
			  else
				  print(fg,'LI_curves.ps','-dpsc2', '-painters', '-noui');
			  end;
			  fprintf(['  The lateralization curves have been generated and saved to LI_curves.ps.' '\n']);
		  catch
			  fprintf(['  There was an error saving the lateralization curves to LI_curves.ps - continuing...' '\n']);
		  end;
                  
		  % print([files '.png'], '-dpng'); % re-enable if you want output to png-file

		% ... and delete if no graphics was chosen
		  if graphs == 0
			close(a)
		  end;
	  end;
  end;


% ==========================================================================================================
%                                          	Housekeeping
% ==========================================================================================================


% Allow for clean up
  if script == 0
	RA = spm_input('Delete temporary files ?','+1','b',[' Yes| No'],[1 0],1);
  else
	RA = 1;
  end;

  if RA == 1
	fprintf(['\n' '\n' '  Deleting Files...done' '\n' '\n']);
	delete LI_*.hdr
	delete LI_*.img
	delete LI_*.mat
  else
	fprintf(['\n' '\n' '  Files were -not- deleted!' '\n' '\n']);
  end;


% inform user about the good news
  PP = 'Getting LIs - done';
  spm('FigName', PP);


% re-enable warning
  warning on MATLAB:divideByZero;


% suppress output; could be re-enabled if further processing is wished
  thrs = [];
  lis = [];
  return;
