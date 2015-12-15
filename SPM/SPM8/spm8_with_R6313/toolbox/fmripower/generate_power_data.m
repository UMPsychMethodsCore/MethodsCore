function generate_power_data(data_directory, gfeat_dir, chosen_cope_lower, fsl_dir)
%Builds and outputs a Power/ directory that contains the calculated power
%data in the data_directory


if(~isdir(data_directory))
    exception = MException('VerifyDirectory:NotValidDirectory', ...
        'The directory to generate power data in is invalid');
    throw(exception);
end
    
if exist([data_directory '/Power/var_avg.nii.gz'])==0

	 %check the high level analysis design 
	 design_fsf_file = [ gfeat_dir, '/design.fsf' ];
	 design_grp_file = [ data_directory , '/design.grp' ];

	 if exist( design_grp_file ) == 0 
	 	exception = MException('VerifyGroup:FileNotFound', ...
			'Unable to locate design.grp file');
		throw(exception);
	 end

	 if exist( design_fsf_file ) == 0 
	 	exception = MException('VerifyGroup:FileNotFound', ...
			'Unable to locate design.fsf file');
		throw(exception);
	 end

	 %@TODO - this section looks like it may not be necessary
	 %as in practice there are only mean_random_effects files for
	 %variance groups if they exist.
	 %therefore we might be able to just detect multiple rand effects files
	 %and process them if need be.
	 grp_text = fileread(design_grp_file);
	 %find the size of the matrix
	 grp_offset = strfind(grp_text, '/NumPoints');
	 grp_offset = grp_offset + 10;
	 grp_points = textscan(grp_text(grp_offset:end),'%d');
	 grp_points = grp_points{1};
	 %find the matrix
	 grp_offset = strfind(grp_text, '/Matrix');
	 grp_offset = grp_offset + 7;
	 grp_matrix = textscan(grp_text(grp_offset:end), '%d',grp_points);
	 grp_matrix = cell2mat(grp_matrix);

	 if sum(grp_matrix) ~= grp_points
	 	%if the group matrix isn't a column of ones, there is more than 1 variance group
		effects_means = dir( [data_directory '/stats/mean_random_effects_var*']);
		num_files = size(effects_means);
		num_files = num_files(1);

		first_rnd_var = [ data_directory, '/stats/mean_random_effects_var1'];
		first_rnd_var = find_image_file_name(first_rnd_var);
		first_rnd_var = create_unzipped_tempfile_in_directory(first_rnd_var, data_directory);
		first_vol = spm_read_vols(spm_vol(first_rnd_var));
		delete(first_rnd_var);

		[x y z] = size(first_vol);

		all_mean_effects = zeros(x,y,z,num_files);
		all_mean_effects(:,:,:,1) = first_vol;

		for i = 2:num_files
			temp_rnd_var = [ data_directory , '/stats/', effects_means(i).name];
			temp_rnd_var = find_image_file_name(temp_rnd_var);
			temp_rnd_var = create_unzipped_tempfile_in_directory(temp_rnd_var, data_directory);
			temp_vol = spm_read_vols(spm_vol(temp_rnd_var));
			delete(temp_rnd_var);
			all_mean_effects(:,:,:,i) = temp_vol;
		end

		all_mean_effects = all_mean_effects.^(1/2);
		all_mean_effects = sum(all_mean_effects,4);
		all_mean_effects = all_mean_effects.^2;
		rnd_var_matrix = all_mean_effects;
	 else
		pth_rnd_var=[gfeat_dir, '/', chosen_cope_lower,...
			'/stats/mean_random_effects_var1'];
		pth_rnd_var = find_image_file_name(pth_rnd_var);
		pth_rnd_var = create_unzipped_tempfile_in_directory(pth_rnd_var, [gfeat_dir, '/', chosen_cope_lower]);
		rnd_var_matrix = spm_read_vols(spm_vol(pth_rnd_var));
	 	delete(pth_rnd_var);
	 end


	 pth_var=[ gfeat_dir,'/',  chosen_cope_lower, ...
			 '/var_filtered_func_data'];
	 pth_var_link=[gfeat_dir,'/var',...
		chosen_cope_lower(1:(findstr(chosen_cope_lower, ...
					'.')))];
     
     pth_var = find_image_file_name(pth_var);
     
     pth_var = create_unzipped_tempfile_in_directory(pth_var, [gfeat_dir, '/', chosen_cope_lower]);

	 var_matrix = spm_read_vols(spm_vol(pth_var));

     
     v = spm_vol(pth_var);
     v = v(1);
	 delete(pth_var);

	 fsf_text = fileread(design_fsf_file);
	 fsf_offset = strfind(fsf_text,'set fmri(mixed_yn)');
	 fsf_offset = fsf_offset + 18;%string above is 18 chars long
	 analysis_type = textscan(fsf_text(fsf_offset:end), '%d');
	 %analysis type is a cell, grab the data inside
	 analysis_type = analysis_type{1};
	 
	 switch analysis_type 
	 	case 3
			exception = MException('VerifyDesign:DesignNotSupported', ...
				'This tool does not support power calculations for fixed effects analysis');
			throw(exception);
		case 0
			%OLS analysis
			fsf_offset = strfind(fsf_text, 'set fmri(npts)');
			fsf_offset = fsf_offset + 15;
			number_subjects = textscan(fsf_text(fsf_offset:end),'%d');
			number_subjects = number_subjects{1};
			
			dof_file = [ data_directory '/stats/dof' ];
			if exist(dof_file) == 0
				exception = MException('VerifyDesign:FileNotFound', ...
					'Cannot find dof file');
				throw(exception);
			end
			dof_handle = fopen(dof_file);
			degrees_of_freedom = textscan(dof_handle,'%d');
			degrees_of_freedom = degrees_of_freedom{1};
			fclose(dof_handle);

			res_file = [ data_directory '/stats/res4d' ];
			res_file = find_image_file_name(res_file);
			
			[pathstr, name, ext] = fileparts(res_file);
			if strcmp(ext, '.gz') == 1
				res_file = gunzip(res_file);
				res_file = [data_directory '/stats/res4d.nii'];
			end

			var_avg  = create_OLS_variance(res_file,number_subjects, degrees_of_freedom);
			gzip(res_file); %gzip outputs a new file without changing the original
			delete(res_file);
			
		case 1
			%Flame
			var_avg = create_var_avg(rnd_var_matrix, var_matrix);
		case 2
			%Flame
			var_avg = create_var_avg(rnd_var_matrix, var_matrix);
	 end

	 v.fname = [gfeat_dir '/' chosen_cope_lower '/Power/var_avg.img'];

	 v.dim = size(var_avg);

	 
	 spm_write_vol(v, var_avg);

     

	if exist([gfeat_dir,'/',chosen_cope_lower, ...
	   '/Power/var_avg.nii.gz'])+ ...
	 exist([gfeat_dir,'/',chosen_cope_lower, ...
	   '/Power/var_avg.img'])==0
		errordlg(['Error: Cannot find var_filtered_func_data! in cope.feat' ...
		 ' directory']);
		exception = MException('VerifyGeneration:NoFilteredData', ...
			'Unable to generate Power directory');
		throw(exception);
	end
	
end

function create_var_avg_fsl(fsl_installation_location, pth_rnd_var,pth_var)
	[status, result] = fsl_env_call(sprintf(['%sfslmaths %s -sqrt -Tmean' ...
					' -sqr Power/var_avg'], fsl_installation_location, pth_var ), fsl_installation_location);
	[status, result] = fsl_env_call(sprintf(['%sfslmerge -t Power/var_avg Power/var_avg %s'],...
		fsl_installation_location, pth_rnd_var), fsl_installation_location);
	[status, result] = fsl_env_call(sprintf(['%sfslmaths Power/var_avg -Tmean -mul 2 Power/var_avg'],...
		fsl_installation_location), fsl_installation_location);

function proper_name = find_image_file_name(image_file_name)
    if(exist(image_file_name))
        proper_name = image_file_name;
        return;
    end
    
    extensions = {'.img','.hdr','.nii','.img.gz','.hdr.gz','.nii.gz'};
    
    for i = 1:length(extensions)
        if(exist([image_file_name extensions{i}]))
            proper_name = [image_file_name extensions{i}];
        end
    end
    
    if(~exist(proper_name))
        exception = MException('VerifyFile:NoFileFound', ...
			['No file with name ' image_file_name ' exists']);
        throw(exception);
    end

		
    
    
