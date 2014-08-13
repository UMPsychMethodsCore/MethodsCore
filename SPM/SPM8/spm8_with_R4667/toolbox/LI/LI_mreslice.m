function res = LI_mreslice(out,in,hold,bin,wo);
%
% Little function to reslice images in memory, based upon functionality
% provided by spm_slice_vol as also used by ImCalc;
% part of the LI_toolbox distribution;
% out  - target image, defining the space to write input image to
% in   - image to be resliced
% hold - interpolation method; do not use >1 if image contains NaN
% bin  - binarize images to res > bin if provided; not done if missing or empty
% wo   - additionally write out resliced image? If yes, pass filename (or 1 to use variable 'post' set below)
% 
% implementation by Marko Wilke, USE AT YOUR OWN RISK!
%

% check inputs
  if nargin < 1 | isempty(out),   out = spm_vol(spm_select([1],'image',['Select reference image'],[],pwd,'.*'));  end;
  if nargin < 2 | isempty(in), 	  in = spm_vol(spm_select([Inf],'image',['Select image(s) to match to reference image'],[],pwd,'.*'));   end;
  if nargin < 3 | isempty(hold),  hold = 7;   end;
  if nargin < 4,  bin = [];   end;
  if nargin < 5,  wo = 1;     end;


% check input
  if ~isstruct(out),  out = spm_vol(out);  end;
  if ~isstruct(in),   in  = spm_vol(in);   end;


% settings
  post = '_r';


% initiate storage
  res = zeros([out.dim size(in,1)]);


% loop over input images to reslice
  for j = 1:size(in,1)


	% get current image
	  curr = in(j);


	% inform only for larger collections
	  if size(in,1) > 10

		disp(['   ... working on image ' num2str(j) '/' num2str(size(in,1)) ', please be patient...']);
	  end;


	% loop over slices
	  for i = 1:out.dim(3)

		B = spm_matrix([0 0 -i 0 0 0 1 1 1]);
		M = inv(B*inv(out.mat)*curr.mat);
		res(:,:,i,j) = spm_slice_vol(curr,M,out.dim(1:2),[hold,NaN]);
	  end;


	% threshold results?
	  if ~isempty(bin)

		res(:,:,:,j) = double(res(:,:,:,j) > bin);
	  end;


	% write out results?
	  if  ~isempty(wo)

		V = out;
		if isempty(bin),  V.dt = curr.dt;        else,  V.dt = [2 0];        end;
		if isempty(bin),  V.pinfo = curr.pinfo;  else,  V.pinfo = [1 0 0]';  end;
		V.descrip = [curr.descrip '; resliced'];
		[p nm e v] = spm_fileparts(curr.fname);
		if isnumeric(wo)

			if wo == 1,  V.fname = [p filesep nm post e];  end;

		elseif isstr(wo)

			V.fname = [pwd filesep wo];
		else

			error(['Sorry, I cannot interpret your filename input! Please use numbers [0|1] or pass a complete filename (no path!)']);
		end;
		spm_write_vol(V,res(:,:,:,j));
	  end;
  end;


% get back
  if nargout == 0,  res = 'Done!';  end;
  return;