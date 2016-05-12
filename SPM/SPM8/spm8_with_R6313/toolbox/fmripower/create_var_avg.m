function var_average = create_var_avg(pth_rnd_var, pth_var)

	%read in the raw image data
	image_vols = pth_var;
	%square root of all data in the volume
	image_vols = image_vols.^(1/2);
	
	var_average = average_image_over_time(image_vols);
	
	var_average = var_average.^2;
	
	random_var_vol = pth_rnd_var;
	
	merged_average(:,:,:,1) = var_average;
	merged_average(:,:,:,2) = random_var_vol;
	
	var_average = average_image_over_time(merged_average);
	
	var_average = var_average.*2;
	
function average = average_image_over_time(image_volume)
	
	[x y z time] = size(image_volume);
	
	average = zeros(x,y,z);
	% This is a very slow point of execution
	% It works, but it needs to be vectorized to improve performance
	
	
	average = sum(image_volume,4);
	
	
	average = average./time;
