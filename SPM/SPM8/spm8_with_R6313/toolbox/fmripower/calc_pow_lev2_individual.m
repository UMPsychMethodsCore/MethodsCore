function power_results=calc_pow_lev2_individual(cope, vars, design, cont, mask_roi, mask_brain,alpha,path, design_type)
%%This function calculates power for different ROI's.  The output is a
%structure that contains the design name (des_name), roi number(roi_num),
%mean effect size for each roi (mn), mean standard deviation (sd), mean
%in standard deviation units (mn_sd_units) and power estimate (pow).
%
%des_name is 1x1 and all other parts of the structure are vectors with
%length equal to the number of ROI's
%
%Function input includes paths to copes from FSL analysis, the variance
%associated with this copes, design matrix (in ascii format), contrast
%vector (in ascii format), and masks for the roi's and brain region.
%alpha is the false positive rate and is entered as a number between 0
%and 1.
%
%Note that vars must be the variance associated with the residual
%variance, not the variance of the cope, or varcope.  The varcope cannot
%be used since it contains information about the original design.


if exist([path,'/pow_results.mat'])==0
  first=1;
else
  first=0;
end

try
   des_mat=load(design, '-ascii');
 catch 
   des_mat = load(design);
end

   

dim_des=size(des_mat);
t_df=dim_des(1)-dim_des(2);


mask_brain_vol=load_data(mask_brain);
mask_brain_dat=mask_brain_vol(:);

cope_dat=load_data(cope);
cope_dat=cope_dat(:);
cope_dat=cope_dat(mask_brain_dat>0);

vars_dat=load_data(vars);
vars_dat=vars_dat(:);
vars_dat=vars_dat(mask_brain_dat>0);

if(design_type == 3   )
	vars_dat = vars_dat ./ 2; 
end

if(design_type == 4   )
	vars_dat = vars_dat .* 2; 
end

[mask_roi_vol, template]=load_data(mask_roi);
mask_roi_dat=mask_roi_vol(:);
mask_roi_dat=mask_roi_dat(mask_brain_dat>0);
mask_roi_vol(mask_brain_vol<=0)=0;


unique_mask_roi=unique(mask_roi_dat);
unique_mask_roi=unique_mask_roi(isnan(unique_mask_roi)==0 & unique_mask_roi~=0);

power_results.roi_num=unique_mask_roi;
[pth,name, ext]=fileparts(design);
power_results.des_name={name};
power_results.alpha=alpha;

power_results.mn=repmat(NaN, size(unique_mask_roi));
power_results.sd=repmat(NaN, size(unique_mask_roi));
power_results.mn_sd_units=repmat(NaN, size(unique_mask_roi));
power_results.power=repmat(NaN, size(unique_mask_roi));


len_unique=length(unique_mask_roi);

%create volumes for mn, mn_sd, sd  (if first time running
%power analysis) and power image is always created as temp_power

mask_roi_vol(mask_roi_vol==0)=NaN;
mn_sd_img=mask_roi_vol;
pow_img=mask_roi_vol;
mn_img=mask_roi_vol;
sd_img=mask_roi_vol;

prog=figure('IntegerHandle','off','Tag','Interactive',...
          'Position',[400,200,200, 400],'MenuBar', 'none',...
         'NumberTitle', 'off', 'color', [.7, .7, .7]);
spm_progress_bar('Init',len_unique,'','regions completed');

cope_dat(isnan(cope_dat)==1) = 0;
mask_roi_dat(isnan(mask_roi_dat)==1) = 0;
vars_dat(isnan(vars_dat)==1) = 0;

for m=1:len_unique
    k=unique_mask_roi(m);
    mn=mean(cope_dat(isnan(cope_dat)==0 & mask_roi_dat==k));
    sd=mean(sqrt(vars_dat(isnan(vars_dat)==0 & mask_roi_dat==k)));
    ncp=mn/(sd*sqrt(cont*inv(des_mat'*des_mat)*cont'));
    %recovers a NaN result from the ncp to prevent failure
    if(isnan(ncp))
    	ncp = 0;
    end
    power_results.power(k)=100*(1-nctcdf(-1*tinv(alpha, t_df), t_df, ncp));
    power_results.mn(k)=mn;
    power_results.sd(k)=sd;
    power_results.mn_sd_units(k)=mn/sd;
    
    pow_img(mask_roi_vol==k)=power_results.power(k);
    
    if first==1
      mn_sd_img(mask_roi_vol==k)=mn/sd;
      mn_img(mask_roi_vol==k)=mn;
      sd_img(mask_roi_vol==k)=sd;
    end    
    spm_progress_bar('Set',m);
end

%-----make pow_tmp image------------%



pow_struc=make_image(template, [path,'/pow_tmp.nii'], 'Most recent power estimates');
spm_write_vol(pow_struc, pow_img);
fprintf('Power data is located in %s \n', [path,'/pow_tmp.nii'])
%----If it is the first time through, also save the other images---
  if first==1
    mn_sd_struc=make_image(template, [path, '/mn_sd.nii'], 'Mean in SD units');
    mn_struc=make_image(template, [path, '/mn.nii'], 'Mean image');
    sd_struc=make_image(template, [path, '/sd.nii'], 'SD imgae');
    
    spm_write_vol(mn_sd_struc, mn_sd_img);
    spm_write_vol(mn_struc, mn_img);
    spm_write_vol(sd_struc, sd_img);
  end
  

function [file_out, struct_out]=load_data(file_in)
%gunzips file if has .gz extension and reads in data

[pth,name, ext]=fileparts(file_in);
     if strcmp(ext, '.gz')
      gunzip(file_in);
      delete(file_in);
      file_in=[pth,'/',name];
      struct_out=spm_vol(file_in);
      file_out=spm_read_vols(struct_out);
      gzip(file_in);
      delete(file_in);
     else;
     struct_out=spm_vol(file_in);
     file_out=spm_read_vols(struct_out);     
     end
end



function V=make_image(Vtemplate, fname,descrip)
%Creates an file that data can be written to

V = Vtemplate;
V.private.dat.dtype='FLOAT32-LE';
V.dt=[16 0];

V.fname   = fname;
V.private.dat.fname=fname;
V.descrip =descrip;
spm_create_vol(V);
end

spm_progress_bar('clear');
close(prog);

end

function nanchecker(element)
if ~isnan(element)
    display 'valid '
end
end
