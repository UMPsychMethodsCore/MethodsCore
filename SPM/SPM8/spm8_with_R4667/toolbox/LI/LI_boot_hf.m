function [jn_li, jn_mn, jn_min, jn_max, xx, yy] = LI_boot_hf(res_l,res_r,nvoxl,nvoxr,its,mwf,perc,bailout,breakpoint,j);
% This bootstrap helper function employs a bootstrapping approach
% to calculating a lateralization index for MR-imaging data.
% It works by generating iter random samples from two input
% vectors of size x and y. As n random samples with
% size = input*perc are sampled, a mean and the
% minimum/maximum resulting LI are reported. 
%
% Required input is
% res_l, res_r	: input data (l,r), in 3D (image volume) or as a vector
% nvoxl, nvoxr	: number of voxels on the left and righ side
% mwf		: mask weighting factor, for unequally sized masks
% its		: number of iterations to perform
% perc		: output size in percentage of input vector size
% bailout	: stop if ceil(perc * nvox) < bailout
% breakpoint	: restricts maximum sample size
%
% This functon is part of the LI-toolbox and comes with now warranty
% whatsoever; see the readme for more details.
% Written by Marko Wilke; USE AT YOUR OWN RISK!


% ==========================================================================================================
%                                          	Inputs, settings etc.
% ==========================================================================================================

% condition input, if necessary
  if size(res_l,2) ~= 1
	x = reshape(res_l,1,[]);
	y = reshape(res_r,1,[]);
  else
	x = res_l;
	y = res_r;
  end;

  x(find(x < 0.0001)) = [];
  y(find(y < 0.0001)) = [];


% optional: introduce outliers, if wanted for test reasons
%  fprintf(['      Introducing outliers...' '\n' ]);
%  y(1) = max(y)*10;
%  y(2) = max(y)*10;


% figure out sample size: left first...
  if (nvoxl * perc) > breakpoint

	% set maximum sample size to 'breakpoint'
	  bins_l = breakpoint;

  elseif bailout < (nvoxl * perc) < breakpoint

	% else, sample 'perc' % of input data points
 	  bins_l = ceil(size(x,2) * perc);

  elseif (nvoxl * perc) < bailout

	% with datasets < bailout, don't even get started
	  jn_li = 0;
	  jn_mn = 0;
	  jn_sd = 0;
	  return;
  end;


% ... now right:
  if (nvoxr * perc) > breakpoint

	% set maximum sample size to breakpoint
	  bins_r = breakpoint;

  elseif bailout < (nvoxr * perc) < breakpoint

	% else, sample 20% of data points
 	  bins_r = ceil(size(y,2) * perc);

  elseif (nvoxr * perc) < bailout

	% with datasets < bailout, don't even get started
	  jn_li = 0;
	  jn_mn = 0;
	  jn_sd = 0;
	  return;
  end;


% prepare storage
  xxx    = zeros(1,bins_l);
  xx     = zeros(1,its);

  yyy    = zeros(1,bins_r);
  yy     = zeros(1,its);

  jn_li = zeros(its,its);


% generate samples: left...
  for k = 1:its
	b = ceil(rand(1,bins_l).*size(x,2));

	for kk = 1:bins_l
		xxx(kk) = x(b(kk));
	end;
	xx(k) = nvoxl*mean(xxx);
  end;


% ... and right
  for k = 1:its
	b = ceil(rand(1,bins_r).*size(y,2));

	for kk = 1:bins_r
		yyy(kk) = y(b(kk));
	end;
	yy(k) = nvoxr*mean(yyy);
  end;


% generate LI-matrix from bootstrapped data
% loop over iterations: left first...
  for k = 1:its
	l = xx(:,k);

	% ... then right
	  for kk = 1:its
		r = yy(:,kk);

		% calculate li, store away
		  jn_li(k,kk) = (l/mwf-r)/(l/mwf+r+eps);

	  end;
 end;


% reformat
  jn_li = sort(reshape(jn_li,1,[]));


% generate output, use trimmed mean (25) for more robust mean and
% overall minimum/maximum value for more sensitive outlier detection
  p = 0.25;
  jn_mn = mean(jn_li(round(size(jn_li,2)*p):round(size(jn_li,2)-size(jn_li,2)*p)));
  jn_min = min(jn_li);
  jn_max = max(jn_li);
  %  fprintf(['    ' num2str(jn_mn) ', Min: ' num2str(jn_min) ', Max: ' num2str(jn_max) '\n' ]);

