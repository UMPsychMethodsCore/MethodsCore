function [thrs] = LI_boot(A,B,B1,B2,C,out,sm,vw,pre,outfile,L,R);
% Function to iteratively calculate lateralization indices,
% employing a bootstrap algorithm. The output is both graphics
% (optional) and via the Matlab command window. This 
% is part of the LI-toolbox and is called from li.m. 
% Written by Marko Wilke; USE AT YOUR OWN RISK!


% ==========================================================================================================
%                                          	Inputs, settings etc.
% ==========================================================================================================


% ===== change stdpth if your masks reside elsewhere  =====
  stdpth = [spm('Dir') filesep 'toolbox' filesep 'LI' filesep 'data'];
  global script ni


% set critical number of voxels (ncr), minimum cluster size (k), and minimum number of voxels (nabort)
  ncr = 10;     % default: 10
  k = 5;        % default: 5
  nabort = 5;   % default: 5


% set iterations and, linked, number of bootstraps at each step
  iter = 20;
  its = iter * 5;


% ===== check how the output is supposed to be, defined via command line; set short to 1 for minimalistic output ===== 
  short = 1;
  if out == 3
	graphs = 0;
	out = 2;
  else
	% show graphics only for smaller collection of files;
	% note that results will always be saved to li_boot.ps
	  if (size(A,1)+size(B,1)) > 10 | script == 1
		graphs = 0;
		fprintf(['  Processing ' num2str(size(A,1)) ' images and ' num2str(size(B,1)) ' masks- bypassing graphics (direct save to file LI_boot.ps).' '\n']);
	  else
		graphs = 1;
	  end
  end;


% ===== Allow for adapting defaults - or for skipping ===== 
  if script == 0
	use_def = spm_input(['Use bootstrap defaults ?'],'+1','b',[' Yes| No'],[1 0],1);
  else
	use_def = 1;
  end;
  if use_def == 0
	% Allow for input of lower threshold (eg, to only explore "significant" voxels) 
	  ilt = spm_input(['Use lower thresholds ?'],'+1','b',[' Yes| No'],[1 0],0);
	  lows = zeros(size(A,1),1);
	  if ilt == 1
		fprintf(['  Please enter lower threshold for bootstrapping for ...' '\n']);
		for jj = 1:size(lows)
			disp(['    - input image # ' num2str(jj) ': ' A(jj,:)]);
			fprintf('\n');
			it = spm_input(['Bootstrap threshold (' num2str(jj) '/' num2str(size(lows,1)) ')'],'!+1','e',0);
			lows(jj) = it;
		end;
	  end;
	
	% The following parameters determine the characteristics of the bootstrap
	% perc		: output size in percentage of input vector size
	  fprintf(['  Please enter bootstrap sample size (in percent of input size)' '\n']);
	  perc = spm_input(['Bootstrap sample size (%)'],'!+1','e',25);
	  perc = perc/100;
	
	% bailout	: stop if ceil(perc * nvox) < bailout
	  fprintf(['  Please enter minimum bootstrap sample size (in voxels)' '\n']);
	  bailout = spm_input(['Minimum sample size'],'!+1','e',5);
	
	% breakpoint	: restricts maximum sample size
	  fprintf(['  Please enter maximum bootstrap sample size (in voxels)' '\n']);
	  breakpoint = spm_input(['Maximum sample size'],'!+1','e',10000);
  else
	% use defaults for thresholds, sample size, minimum/maximum sample size
	  lows = zeros(size(A,1),1);
	  perc = 25/100;
	  bailout = 5;
	  breakpoint = 10000;
  end;


% store original state of perc; link bailout, perc and nabort
  operc = perc;
  nabort = round(bailout/perc);


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
	low = lows(i);
	check_dims = spm_get_space(A(i,:));
	check_dims = sqrt(sum(check_dims(1:3,1:3).^2));


	% adapt names for display (before first iteration in case this crashes out
	  files = spm_str_manip(file_ns, ['t' 's']);
	  if ~isempty(strfind(files,'.img,1'))
		files = spm_str_manip(files,['f' num2str(size(files,2)-6)]);
	  end;
	  if findstr(file_vol_ns.descrip,'contrast') ~= 0
		[l, f] = strtok(file_vol_ns.descrip,'contrast');
		files = [files ' (' deblank(f) ')'];
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
		  PP = 'Smoothing input image';
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
	% NOTE: all constrasts should be either normalized or not, don't mix here!
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
	 	if strcmp(mask, 'none') ~= 1;
			masks = spm_str_manip(mask, ['t' 's']);    masks = strrep(masks, '\', '/');
		else
			masks = 'none';
		end;


		% reset error state, perc
		  perc = operc;
		  li_error = 0;

		% ===== only need to recalculate if masks not in standard format =====
		% also need to check if masks need to be normalized (must be in-register with functionals)
		  if pre == 1
			  PP = 'Preprocessing custom mask';
			  spm('FigName', PP);

			LI_imcalc({mask},'LI_complete_mask.img','i1.*isfinite(i1)',{[],[],['uint8'],0});

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

			% include preprocessing if custom mask
		          if B1 == 11
		          	LI_imcalc({mask_c},'LI_complete_mask.img','(i1+(flipud(i1)))>0.1',{[],[],['uint8'],0});
				mask_c = 'LI_complete_mask.img';
		          end;
		  else
			mask_c = mask;
		  end;


		% ===== set necessary variables here prior to looping; make sure to exclude NaN's ===== 
		  R_vol = spm_read_vols(spm_vol(R));          R_vol(isnan(R_vol)) = 0;
		  L_vol = spm_read_vols(spm_vol(L));          L_vol(isnan(L_vol)) = 0;
		  if strcmp(B,'none')~=1;    mask_vol = spm_read_vols(spm_vol(mask_c));    mask_vol(isnan(mask_vol)) = 0; end;
		  if strcmp(C,'none')~=1;    C_vol = spm_read_vols(spm_vol(C));            C_vol(isnan(C_vol)) = 0;       end;		


		% Prior to looping, compute mask weighting factor to rule 
		% out any possible influence due to different masking volumes
		  if strcmp(B,'none')~=1
			mwf = sum(sum(sum((L_vol>0.1).*(mask_vol>0.1))))/sum(sum(sum((R_vol>0.1).*(mask_vol>0.1))));

			% issue a warning and abort if mask is very asymmetrical (only if not scripted)
			  if (mwf > 2 | mwf < 0.5) && script ~= 1
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
		% link iter and its (number of bootstrapping iterations),
		% also create various storage spaces 
		  thrs = zeros(iter,1);
		  voxl = zeros(iter,1);
		  voxr = zeros(iter,1);
		  clusl = zeros(iter,1);
		  clusr = zeros(iter,1);
		  jn = zeros(iter,3);
		  jn_all = zeros(iter,its^2);
		  x = zeros(iter,its);
		  y = zeros(iter,its);

		  for j = 1:iter;

			% generate 'iter' thresholds as fractions of maximum image value; use
			% (iter-1) here since the maximum will always lead to a divide by zero
			% Also only explore values above the lower threshold (default:0)
			    PP = ['Getting LIs - Iteration ' num2str(j) ' of ' num2str(iter)];
			    spm('FigName', PP);

			  if j == 1
				thr3 = low;
			  else
				thr3 = (j-1)*(mx-low)/iter+low;
			  end;

			% mask image with current threshold
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


			% make sure maximum value > threshold
			  if mx < low
				fprintf(['\n' '\t' 'Warning: lower threshold (' num2str(low) ') exceeds maximum voxel value - aborting !' '\n' '\n']);
				return
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


			% dynamically adapt resample rate if data size decreases
			% (allows to use low k and still explore high thresholds)
			  if (nvoxl * perc) < bailout | (nvoxr * perc) < bailout 
				perc_n = perc * (bailout/(perc*min(nvoxl,nvoxr)));
				if perc_n <= 1
					perc = perc_n;
					fprintf(['    Low voxel count: adjusting sampling rate to k = ' num2str(perc) '\n' ]);
				end;
			  end;


			% adjust lower bound (may have changed)
			  nabort = round(bailout/perc);


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


			% now check if at least one cluster on the left or right is above k (set to 5 by default) 
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
				% fprintf(['\t' 'aborting iterations!' '\n']);
				% break			% disable to not use cluster size as a killer criterion
			  end;

			  if QL == 0
				fprintf(['\n' '\t' 'Warning: No cluster on the LEFT is > ' num2str(k) ' voxels!' '\n']);
				% fprintf(['\t' 'aborting iterations!' '\n']);
				% break			% disable to not use cluster size as a killer criterion
			  end;


			% ===== Pass data to the bootstrapping function  =====
			  [jn_li, jn_mn, jn_min, jn_max, xx, yy] = LI_boot_hf(res_l,res_r,nvoxl,nvoxr,its,mwf,perc,bailout,breakpoint,j);


			% ===== store results for later use ===== 
			  thrs(j) = thr3;
			  voxl(j) = nvoxl;
			  voxr(j) = nvoxr;
			  clusr(j) = numr;
			  clusl(j) = numl;

			  jn_all(j,1:(size(jn_li,2))) = jn_li;
			  jn(j,1) = jn_mn;
			  jn(j,2) = jn_min;
			  jn(j,3) = jn_max;
			  x(j,:) = xx;
			  y(j,:) = yy;


			% ===== convert for display =====
			  files_p = spm_str_manip(file_ns, ['h' 's']);
			  files_p = strrep(files_p, '\', '/');
			  if strcmp(C,'none')~= 1
				cs = spm_str_manip(C, ['t' 's']);    cs = strrep(cs, '\', '/');
			  else
				cs = 'none';
			  end;
			  if vw == 1;    vwd = 'yes';    else   vwd = 'no';    end;
			  if sm == 1;    smd = 'yes';    else   smd = 'no';    end; 
			  meth = '(bootstrap)';
			  LI = sprintf('%0.3g', jn_mn);
			  LI_min = sprintf('%0.3g', jn_min);
			  LI_max = sprintf('%0.3g', jn_max);
			  thrd = sprintf('%0.3g', thr3);
			  nvoxrd = sprintf('%0g', nvoxr);
			  nvoxld = sprintf('%0g', nvoxl);
			  numrd = sprintf('%0g', numr);
			  numld = sprintf('%0g', numl);


% ==========================================================================================================
%                                          	Outputs
% ==========================================================================================================


			% shut up if in auto-mode :)
			  for rep=1:out
				  fid = rep;
				  new = exist([pwd filesep outfile],'file');
				  if rep == 2 & short == 0
					fid = fopen(outfile,'At+');
				  end;	

				% write tab-delimited results to screen or file (spreadsheet-friendly); always show in command window
				  if j == 1 & rep == 1 & short == 0
					fprintf(['\t' 'Input image' '\t' 'Inclusive mask' '\t' 'Exclusive mask' '\t' 'Threshold' '\t' 'LI' '\t'  'LI (min)' '\t'  'LI (max)' '\t' 'Method' '\t' 'Variance Weighting' '\t' 'Clustering' '\t' 'Voxels (right)' '\t' 'Voxels (left)' '\t' 'Clusters (right)' '\t' 'Clusters (left)' '\t' 'Lower threshold' '\t' 'Bootstrap sample (percent)' '\t' 'Sample size: Minimum' '\t' 'Sample size: Maximum' '\n']);
				  end;

				% only write header to file if not there yet
				  if short == 0
					  if new == 0 & rep == 2
						fprintf(fid, ['\t' 'Input image' '\t' 'Inclusive mask' '\t' 'Exclusive mask' '\t' 'Threshold' '\t' 'LI' '\t'  'LI (min)' '\t'  'LI (max)' '\t' 'Method' '\t' 'Variance Weighting' '\t' 'Clustering' '\t' 'Source path' '\t' 'Voxels (right)' '\t' 'Voxels (left)' '\t' 'Clusters (right)' '\t' 'Clusters (left)' '\t' 'Lower threshold' '\t' 'Bootstrap sample (percent)' '\t' 'Sample size: Minimum' '\t' 'Sample size: Maximum' '\n']);
					  end;

					  fprintf(fid, ['\t' (files) '\t' (masks) '\t' (cs) '\t' (thrd) '\t' (LI) '\t' (LI_min) '\t' (LI_max) '\t' (meth) '\t' (vwd) '\t' (smd) '\t' (files_p) '\t' (nvoxrd) '\t' (nvoxld) '\t' (numrd) '\t' (numld)  '\t' num2str(low)  '\t' num2str(perc*100)  '\t' num2str(bailout)  '\t' num2str(breakpoint) '\n']);
				  end;
				  if rep == 2 & short == 0
					fclose(fid);
				  end;
			  end;
		  end;


		%  ===== compute overall bootstrap result for this dataset/mask combination  ===== 
		% separate output since we can only compute this after all iterations
		  b = reshape(jn_all,1,[]);
		  b = sort(b);
		  b(find(b==0)) = [];
		  b(isnan(b)) = [];
		  a_m   = sprintf('%0.2g',mean(b));
		  a_sd  = sprintf('%0.2g',std(b));
		  a_min = sprintf('%0.2g',min(b));
		  a_max = sprintf('%0.2g',max(b));

		% now compute trimmed mean (ignores upper/lower 'p*100' % of datapoints)
		  p = 0.25;
		  try

			  t_m   = sprintf('%0.2g',mean(b(round(size(b,2))*p:round(size(b,2))-round(size(b,2))*p)));
			  t_sd  = sprintf('%0.2g',std(b(round(size(b,2))*p:round(size(b,2))-round(size(b,2))*p)));
			  t_min = sprintf('%0.2g',min(b(round(size(b,2))*p:round(size(b,2))-round(size(b,2))*p)));
			  t_max = sprintf('%0.2g',max(b(round(size(b,2))*p:round(size(b,2))-round(size(b,2))*p)));


			% now compute weighted mean (using thresholds as weights)
			  wm = sprintf('%0.2g',(thrs'*jn(:,1))/sum(thrs));


			% check explicitly whether all results are usable
			  if any(isinf([t_m t_sd t_min t_max wm])) | any(isnan([t_m t_sd t_min t_max wm]))

				error;
			  end;

		  catch

			% if there was an error above, it was most likely due to missing data on one side, so inform user
			  disp(['   ... sorry, there was an error analyzing ' file_ns ', returning...']);

			  a_m   = 'NaN';  a_sd  = 'NaN';  a_min = 'NaN';  a_max = 'NaN';  
			  t_m   = 'NaN';  t_sd  = 'NaN';  t_min = 'NaN';  t_max = 'NaN';  wm = 'NaN';
			  li_error = 1;
		  end;
			

		% output
		  for rep=1:out
			fid = rep;
			new = exist([pwd filesep outfile],'file');
			if rep == 2

				fid = fopen(outfile,'At+');
			end;

			if short == 1 & rep == 2
				
				if new == 0 
					fprintf(fid, ['\t' 'Input image' '\t' 'Inclusive mask' '\t' 'Exclusive mask' '\t' 'LI (overall)' '\t' 'LI (SD)' '\t'  'LI (min)' '\t'  'LI (max)' '\t' 'LI_T25 (overall)' '\t' 'LI_T25 (SD)' '\t'  'LI_T25 (min)' '\t'  'LI_T25 (max)' '\t' 'LI (wm)' '\t' 'Variance Weighting' '\t' 'Clustering' '\t' 'Source path' '\t' 'Lower threshold' '\t' 'Bootstrap sample (percent)' '\t' 'Sample size: Minimum' '\t' 'Sample size: Maximum' '\n']);
				end;

				try

					fprintf(fid, ['\t' (files) '\t' (masks) '\t' (cs) '\t' (a_m) '\t' (a_sd) '\t' (a_min) '\t' (a_max) '\t' (t_m) '\t' (t_sd) '\t' (t_min) '\t' (t_max) '\t' (wm) '\t' (vwd) '\t' (smd) '\t' (files_p) '\t' num2str(low)  '\t' num2str(perc*100)  '\t' num2str(bailout)  '\t' num2str(breakpoint) '\n']);
				catch

					fprintf(fid, ['\t' 'An error occurred when processing ' files ' in combination with ' masks ' - skipping...' '\n']);
				end;


				% already written to file, so don't need to again 
				fclose(fid);
                                fid = NaN;
			end;


			try

			  	fprintf(fid, ['    Overall Bootstrap-Result: ' '\t' (a_m) '\t' ' +/- ' '\t' (a_sd) '\t' ', Min: ' '\t' (a_min) '\t' ', Max: ' '\t' (a_max) '\n' ]);
			  	fprintf(fid, ['    Trimmed (T25)           : ' '\t' (t_m) '\t' ' +/- ' '\t' (t_sd) '\t' ', Min: ' '\t' (t_min) '\t' ', Max: ' '\t' (t_max) '\n' ]);
			  	fprintf(fid, ['    Weighted Mean           : ' '\t' (wm) '\n' ]);
			end;
			if rep == 2 && short == 0
				fclose(fid);
			end;
		  end;



		%  ===== prepare data for graphics: remove empty lines, NaNs, generate z-score etc. ===== 
		  a = size(x,1);
		  for l = 1:a
			b = a+1-l;
			if std(x(b,:)) == 0 | isnan(std(x(b,:))) 
				x(b,:) = [];
			end;
		  end;
		
		  aa = zeros(size(x));
		  for l = 1:size(x,1)
			for ll = 1:size(x,2)
				aa(l,ll) = (x(l,ll) - mean(x(l,:)))/std(x(l,:));
			end;
		  end;
		
		  clear a b l 
		
		  a = size(y,1);
		  for l = 1:a
			b = a+1-l;
			if std(y(b,:)) == 0 | isnan(std(y(b,:))) 
				y(b,:) = [];
			end;
		  end;
		
		
		  bb = zeros(size(y));
		  for l = 1:size(y,1)
			for ll = 1:size(y,2)
				bb(l,ll) = (y(l,ll) - mean(y(l,:)))/std(y(l,:));
			end;
		  end;

		  clear a b l 

		%  ===== compute graphical output: left figure first ===== 
		% set position and size depending on screen resolution, settings can be adapted
		  if li_error == 0

			  if graphs == 1
				gcf1 = figure;
			  else
				gcf1 = figure('visible', 'off');
			  end;
			  set(0,'Units','pixels');
			  scnsize = get(0,'ScreenSize');
			  pos1 = [round(scnsize(3)/20), round(scnsize(4)/20), round(scnsize(3)/10*4.5), round(scnsize(4)/10*8.5)];
			  set(gcf1, 'Position', pos1);  
			  set(gcf1, 'Name', 'Bootstrap results (p1/2)');
                  
		
			% plot li-curves and min/max-boundaries
			  subplot(2,1,1,'replace')
			  plot(thrs(1:j-1,:),jn(1:j-1,1),'-b',thrs(1:j-1,:),jn(1:j-1,2),':r',thrs(1:j-1,:),jn(1:j-1,3),':r');
			  axis([low,max(thrs(1:j)),-1,1])
			  title({['LI vs. threshold for ' (files)], ['(data from ' spm_str_manip(files_p,['k' num2str(57)]) ')']}, 'interpreter', 'none', 'Fontweight', 'bold');
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
			  xlabel('Threshold', 'Fontangle', 'italic', 'Color','w');
			  ylabel('Lateralization Index', 'Fontangle', 'italic', 'Color','w');
			  refresh;
			  grid on;
			  zoom on;
				

			% now plot histogram of all bootstrapped li's
			  subplot(2,1,2,'replace')
			  li_all = reshape(jn_all,1,[]);
			  li_all = sort(li_all);
			  li_all(find(li_all==0)) = [];
			  li_all(isnan(li_all)) = [];
			  hist(li_all,200);
			  xlim([-1 1]);
			  title(['Histogram of bootstrapped LIs (n = ' num2str(size(li_all,2)) ')'], 'interpreter', 'none', 'Fontweight', 'bold');
			  up = ylim;
			  lp = xlim;
			  t7 = text(lp(1)+0.1*diff(lp),0.9*diff(up),['Mean: ',(a_m) ' +/- ' (a_sd) ' (' (a_min) ' - ' (a_max) ')']);
			  t8 = text(lp(1)+0.1*diff(lp),0.825*diff(up),['Mean (T25): ',(t_m)  ' +/- ' (t_sd) ' (' (t_min) ' - ' (t_max) ')']);
			  t9 = text(lp(1)+0.1*diff(lp),0.75*diff(up),['Weighted mean: ',(wm)]);
			  set([t7, t8, t9],'color','b','FontSize',10,'BackgroundColor','w');
			  xlabel('Lateralization Index', 'Fontangle', 'italic', 'Color','w');
			  ylabel('# of observations', 'Fontangle', 'italic', 'Color','w');
			  grid on;
			  zoom on;

		
			% now right figure
			  if graphs == 1
				gcf2 = figure;
			  else
				gcf2 = figure('visible', 'off');
			  end;
			  pos2 = [round(scnsize(3)*0.525), round(scnsize(4)/20), round(scnsize(3)/10*4.5), round(scnsize(4)/10*8.5)];
	                  set(gcf2, 'Position', pos2);
			  set(gcf2, 'Name', 'Bootstrap results (p2/2)');
			
			  subplot(3,2,[1 2],'replace')
			  surf(aa);
			  title({'Z-Score distribution of bootstrapped voxel data (LEFT) for ', (files)}, 'interpreter', 'none', 'Fontweight', 'bold');
			  set(gca,'YDir','reverse')
			  view([-70 10]);
			  shading interp
			  axis([0 size(bb,2) 1 size(bb,1) -10 10]);
			  ylabel('Iterations', 'Fontangle', 'italic', 'Color','w');
			  xlabel('Sampled data', 'Fontangle', 'italic', 'Color','w');
			  zlabel('Normalized z-scores', 'Fontangle', 'italic', 'Color','w');


			% some versions of Matlab have aproblem here when using OpenGL rendering
			% to also get a whit background here one could switch to zbuffer or painters
			% rendering, as in set(gcf,'Renderer','Zbuffer'); results are not as nice, though ;)
			  subplot(3,2,[3 3],'replace')
			  hist(aa);
			  h = findobj(gca,'Type','patch');
			  set(h,'FaceColor','b','EdgeColor','b');
			  title(['Z-Score histogram (LEFT)'], 'interpreter', 'none', 'Fontweight', 'bold');
			  axis([-5 5 0 max(max(max(hist(aa),hist(bb))))]);
			  grid on;
			  xlabel('Z-Scores', 'Fontangle', 'italic', 'Color','w');

			  subplot(3,2,[4 4],'replace')
			  hist(bb);
			  h = findobj(gca,'Type','patch');
			  set(h,'FaceColor','b','EdgeColor','b');
			  title(['Z-Score histogram (RIGHT)'], 'interpreter', 'none', 'Fontweight', 'bold');
			  axis([-5 5 0 max(max(max(hist(aa),hist(bb))))]);
			  grid on;
			  xlabel('Z-Scores', 'Fontangle', 'italic', 'Color','w');
		
			  subplot(3,2,[5 6],'replace')
			  surf(bb);
			  title('Z-Score distribution of bootstrapped voxel data (RIGHT)', 'interpreter', 'none', 'Fontweight', 'bold');
			  set(gca,'YDir','reverse')
			  view([-70 10]);
			  shading interp
			  axis([0 size(bb,2) 1 size(bb,1) -10 10]);
			  ylabel('Iterations', 'Fontangle', 'italic', 'Color','w');
			  xlabel('Sampled data', 'Fontangle', 'italic', 'Color','w');
			  zlabel('Normalized z-scores', 'Fontangle', 'italic', 'Color','w');


			%  ===== ... save to file LI_boot.ps ... ===== 
			  fnote = sprintf('%s%s%s',['Incl: ' (masks)],[';   Excl.: ' (cs)], [';   Clust.: ' (smd) ';   VarWeight.: ' (vwd)]);
			  fg1 = spm_figure('Findwin',gcf1);
			  set(0,'CurrentFigure',fg1);
			  axes('Position',[0.005,0.005,0.1,0.1], 'Visible','off');
			  text(0,0,fnote,'FontSize',8,'interpreter','none');


			% with larger collections, LI_boot.ps becomes prohibitively huge (>2GB), so be careful
			  try
				if exist([pwd filesep 'LI_boot.ps'],'file') == 2
					print(gcf1,'LI_boot.ps','-dpsc2', '-painters', '-append', '-noui');
				else
					print(gcf1,'LI_boot.ps','-dpsc2', '-painters', '-noui');
				end;
				
				fg2 = spm_figure('Findwin',gcf2);
				set(0,'CurrentFigure',fg2);
				axes('Position',[0.005,0.005,0.1,0.1], 'Visible','off');
				text(0,0,fnote,'FontSize',8,'interpreter','none');
				print(gcf2,'LI_boot.ps','-dpsc2', '-painters', '-append', '-noui');  % now need to append in any case
				fprintf(['  The bootstrapped lateralization curves have been generated and saved to LI_boot.ps.' '\n']);

			  catch

				fprintf(['  There was an error printing the bootstrapped lateralization curves to LI_boot.ps - continuing...' '\n']);
			  end;

                  
			  % figure(gcf1); print(['LI_boot_' num2str(i) '_' num2str(ii) '_1.png'], '-dpng'); % re-enable if you also want output to png-file
			  % figure(gcf2); print(['LI_boot_' num2str(i) '_' num2str(ii) '_2.png'], '-dpng');


			% ... and delete if no graphics was chosen
			  if graphs == 0
				close(gcf1);
				close(gcf2);
			  end;
		  end;
	  end;
  end;

% ==========================================================================================================
%                                          	Housekeeping
% ==========================================================================================================


%  ===== Allow for clean up ===== 
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
  return;

