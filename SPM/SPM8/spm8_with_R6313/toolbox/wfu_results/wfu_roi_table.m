function wfu_roi_table

%   Generates table based on user-selected mask and img list
%   rather than a pickatlas-selected atlas mask. 
%
%   User is prompted to select a .flist file of image names (or
%   individual .img files) and an .img file to be used as a ROI 
%   mask
%
%   FORMAT wfu_roi_table
%______________________________________________________________

%----- Select images and mask -----%
% flist = spm_get(inf,{'*'},'Select flist or images');
% mask = spm_get(1,{'*.img'},'Select ROI mask');
if (exist('spm_select'))
    flist = spm_select(inf,'IMAGE','Select flist or images');
    mask = spm_select(1,'IMAGE','Select ROI mask');
    mask = strtok(mask,',');  % remove pesky ,1 that comes after SPM5 file selections
else
    flist = spm_get(inf,{'*'},'Select flist or images');
    mask = spm_get(1,{'*.img'},'Select ROI mask');
end

PA = mask; %need dummy matrix the size of mask in place of MNI_T1.img

%----- Read .flist if necessary -----%
try
	[path,name,ext,v] = fileparts(flist(1,:));
catch 
	[path,name,ext,v] = fileparts(flist(1,:));
end 
if strcmp(ext,'.flist')
    P_list = wfu_read_flist(flist(1,:));
elseif (strcmp(strtok(ext,','),'.img') || strcmp(strtok(ext,','),'.nii')) % The strtok is used to remove the ,1 that SPM5 puts at the end of image file names
    P_list = flist; 
else
    error('Must select .flist or .img files\nFile not allowed: %s', ...
        flist(1,:));
end

%----- If the flist contains .hdr files, rename them .img -----%
for i = 1:size(P_list,1)
    ext = [];
		try 
	    [path,name,ext,v] = fileparts(deblank(P_list(i,:)));
		catch 
	    [path,name,ext,v] = fileparts(deblank(P_list(i,:)));
		end 
    if strcmp(strtok(ext,','),'.img')
        new_list{i} = fullfile(path,[name,'.img']);
    elseif strcmp(strtok(ext,','),'.nii')
        new_list{i} = fullfile(path,[name,'.nii']);
    end
end
P_list = char(new_list);

%----- Give the table a filename -----% 
default_name =  strcat('ROI_Table_',datestr(now,30));
ofile_name =    spm_input('Give a file name for the output: ', ...
                    '1','s',default_name);                 
spm_figure('Clear','Interactive');


%----- Open file to write table -----%
ofid = fopen( strcat( ofile_name, '.tbl'), 'w' );
fprintf(ofid,'    Size\tAverage \tStd.Dev.\tT      \tRegion\tROI name\tL/R/B\tStudy     \tImage\tMax Value\tMax Loc\tMin Value\tMin Loc\n');
disp(sprintf('Reading files, please wait...'));

%----- Gather stats and write table -----%
[hdr,map] = wfu_read_header(mask);
Regn.names{1}	= '---';  
Regn.groups{1}	= '---';
Side = 'B';       %handles.MaskSide = '3'; [R L B]
List = find(map~=0);
print_ROI(ofid,List,Regn,Side,PA,P_list);
fprintf(ofid,'----------------------------------------------------------------------------------------------'); 
fclose(ofid);

%-- subfunction --%
function print_ROI(ofid,reg_idx, Regn, Side, PA, P_list)
VA = spm_vol(PA);
dim     =   VA.dim;  
plane   =   dim(1)*dim(2);
reg_x   =   mod(reg_idx,dim(1));  % + 1 --> debugging found this off by one
reg_y   =   fix(mod(reg_idx,plane)/dim(1))+1;
reg_z   =   fix(reg_idx/plane)+1;

atlas_pix   =   [reg_x,reg_y,reg_z,ones(length(reg_idx),1)]';
atlas_mm    =   VA.mat*atlas_pix; % VA.mat = pix2mm  

nFiles  =   size(P_list,1);
for ip = 1:nFiles
    disp(sprintf('processing file %d of %d...',ip,nFiles));
    drawnow; 
	PF = strtok(P_list(ip,:),' ');%strip trailing blanks
	VF = spm_vol(PF);
    %Get study ID from the pathname:
    try
	    [fpath fname fext fver ] = fileparts(PF);
	    [fstem fdir  fext fver ] = fileparts(fpath);%back up one
	  catch
	    [fpath fname fext fver ] = fileparts(PF);
	    [fstem fdir  fext fver ] = fileparts(fpath);%back up one
		end  
	mm2pix      =   inv(VF.mat);
	fmri_pix    =   mm2pix*atlas_mm;
    
	% hold = 1 --> trilinear interp; hold = 0 --> nearest neighbor
	% use 0 to debug when sampling original atlas, use 1 otherwise
	fmri_I      =   spm_sample_vol(VF,fmri_pix(1,:),fmri_pix(2,:),fmri_pix(3,:),1); 

	finite_idx  =   find(isfinite(fmri_I));
	if length(finite_idx) > 0,
		    fmri_I_orig = fmri_I; %atlas locations are based on the indexs of original fmri_I.
        fmri_I  =   fmri_I(find(isfinite(fmri_I)));

		    n_reg   =   size(fmri_I,2); 
        sum_reg =   sum(fmri_I); 
        ssq_reg =   sum(fmri_I .* fmri_I);
        avg_reg =   sum_reg/n_reg;
        min_reg =   min(fmri_I);
        min_loc =   find(fmri_I_orig==min_reg); %need to base index on oringal fmri_I index to sync with atlas_mm
        if numel(min_loc) > 1
          min_loc = sprintf('%i vox with min',numel(min_loc));
        else
          min_mm = round(fmri_pix(1:3,min_loc));
          min_loc = sprintf('(%i,%i,%i)',min_mm(1),min_mm(2),min_mm(3));
        end
        max_reg =   max(fmri_I);
        max_loc =   find(fmri_I_orig==max_reg); %need to base index on oringal fmri_I index to sync with atlas_mm
        if numel(max_loc) > 1
          max_loc = sprintf('%i vox with max',numel(max_loc));
        else
          max_mm = round(fmri_pix(1:3,max_loc));
          max_loc = sprintf('(%i,%i,%i)',max_mm(1),max_mm(2),max_mm(3));
        end
        std_reg =   sqrt(ssq_reg/n_reg - (avg_reg)^2);
		if std_reg > 0         
            T_reg   =   avg_reg/std_reg;
        else
            T_reg   =   sign(avg_reg)*Inf;      
        end;
        
		for ir = 1:length(Regn.groups)
			gRoups = union(Regn.groups(1),Regn.groups(ir));
		end
        
		Region    = sprintf('%s ',gRoups{:});
		Subregion = sprintf('%s ',Regn.names{:});
	
		fprintf( ofid, ...
		      '%8g\t%8g\t%8g\t%8g\t%s\t%s\t%s\t%s\t%s\t%8g\t%s\t%8g\t%s\n',...
		       n_reg,avg_reg,std_reg,T_reg,Region,Subregion,Side,fdir,fname,max_reg,max_loc,min_reg,min_loc);
         
	end % fMRI_idx not empty
end % P_list
return; 
