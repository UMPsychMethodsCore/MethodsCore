function var_average = create_OLS_variance(res_file, number_of_subjects, degrees_of_freedom)

	%read in the raw image data
	image_vols = spm_read_vols(spm_vol(res_file));
	%square root of all data in the volume
	image_vols = image_vols.^2;
	
	var_average = average_image_over_time(image_vols);

	var_average = var_average.* double(number_of_subjects);

	var_average = var_average./ double(degrees_of_freedom);
	
function average = average_image_over_time(image_volume)
	
	[x y z time] = size(image_volume);
	
	average = zeros(x,y,z);
	average = sum(image_volume,4);
	
	
	average = average./time;
