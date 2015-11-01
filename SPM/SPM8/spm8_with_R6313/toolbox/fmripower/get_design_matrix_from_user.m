%Throws unset design matrix error
function [ design contrast range_start range_end custom ] = get_design_matrix_from_user(design_type, original_design)
	custom = 0;
    if design_type == 1 
		   [design range_start range_end custom] = ...
			   one_sample_t_prompt(original_design,0);
			contrast = NaN;
    %it looks like a 2 sample t test
    elseif design_type == 2 
			[design range_start range_end custom] = ...
				two_sample_t_prompt(original_design);
			contrast = NaN;
    %we don't know what design matrix type it is
    %Matrix design is a paired t test
    elseif design_type == 3
        [ design range_start range_end custom] = one_sample_t_prompt(original_design, 1);
		contrast = NaN;
    else
		exception = MException('DesignType:UnsupportedDesign', ...
			'Your design type was not recognized. FMRIPower only supports 1 sample t, 2 sample t, and paired t test designs');
		throw(exception);
    end
    
    if(~exist('design'))
        design = [];
    end
