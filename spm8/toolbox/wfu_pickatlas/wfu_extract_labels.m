function wfu_extract_labels(imagename, listname, outname)
%
% function wfu_extract_labels(imagename, listname, outname)
%
%    report labels for input list of MNI coordinates
% where
%    imagename = input Atlas image file
%    listname = input text file of MNI coordinates
%    outname = output text file of MNI coordinates with labels
%
% The input MNI coordinate file list may contain comments preceded by a
% percent sign.  The first 3 entries on a non-comment line will be treated
% as x-y-z MNI integer coordinates.  The delimiter may be a space or a TAB.
% Additional input following the coordinates on the same line will be ignored.

%
%---------------------
%Load MNI coordinates
%---------------------
if nargin < 2 | ~exist(listname, 'file')
    listname = wfu_pickfile('*.txt', 'Select file of coordinates');
end
lines = textread(listname, '%s', 'delimiter', '\n', 'commentstyle', 'matlab');
n = length(lines);
xyz = zeros(3,1);
x = [];
y = [];
z = [];
j = 0;
for i = 1:n
    if ~isempty(lines{i})
        xyz = sscanf(lines{i}, '%d%d%d');
        j = j + 1;
        x(j,1) = xyz(1);
        y(j,1) = xyz(2);
        z(j,1) = xyz(3);
    end
end
if (j < 1)
  error('No input coordinates');
end
  
mni_coords = [x y z];

%----------------------------
%Get atlas name and ROI file
%----------------------------
if ~exist('imagename'), imagename=wfu_pickfile('*.img','Choose an atlas for  label extraction'); end
[pathstr,nam,ext]=fileparts(imagename);
basefname=[pathstr '/' nam];
txtname=[basefname '.txt'];
roimat=[basefname '_List.mat'];
if ~exist(roimat,'file'),
	ROI=wfu_txt2roi(txtname);
else
    load(roimat);
end

%---------------------
%Construct ID vector
%---------------------
label=[];
ID = [];
for i=1:length(ROI), ID(end + 1) = ROI(i).ID; end;

%------------
%Load atlas 
%------------
v = spm_vol(imagename);
cube=spm_read_vols(v);
xdim = v.dim(1);
ydim = v.dim(2);

%------------------------------
%Convert MNI space to cube space
%------------------------------
mni_coords = [mni_coords'; ones(1,length(mni_coords(:,1)))];
cube_coords = inv(v.mat) * mni_coords;

%-------------------------------
%extract values
%-------------------------------
indices = xdim*ydim*(cube_coords(3,:)-1) + xdim*(cube_coords(2,:)-1) + cube_coords(1,:);
values = cube(indices);

%-------------------------------
%extract labels
%-------------------------------
for i=1:length(values)
	label_index = find(ID==values(i));
	if label_index, 
		labelname = ROI(label_index).Nom_C;
	else
		labelname = 'NA';
	end
	label = strvcat(label,labelname);
end


%-------------------------------
%write labels
%-------------------------------
if nargin < 3
     [path,file,ext,ver] = fileparts(listname);
     outname = fullfile(path,[file '_labels.txt']);	
end
[fid, message] = fopen(outname, 'wt');
if fid == -1
    error(message);
    return;
end
disp(['writing labels to ' outname]);
n = size(x);
for i = 1:n
     fprintf(fid, '%d\t%d\t%d\t%s\n', x(i), y(i), z(i), label(i,:));
end
fclose(fid);

