function [ design contrast custom ] = paired_t_prompt(original_design)

	button = questdlg('It appears that you previously modeled a paired t-test, is this correct?');
	if strcmp(button,'Yes')
		
		dlg_name = 'Input for design matrix';
		%hook into the latex interpreter so we can change the font 
		%in the string
		options.Interpreter = 'tex';
		
		number_sets = inputdlg('\fontsize{13}How many sets of paired data for power calculation?', ...
			dlg_name, 1, {'0'}, options);
		number_sets = str2double(char(number_sets));

		design= ones(number_sets,1);
		contrast=[1];
		custom = 0;
		
	else
	
		line1 = 'FMRIPower only supports 1 sample, two sample, and paired t-tests';
		
		
		h = warndlg([line1], 'Warning','modal');
		uiwait(h);

		throw(MException('DesignMatrix:Unknown',...
			'Cannot determine design matrix.'));

		design = NaN;
		contrast = NaN;
		custom = 1;
	end
