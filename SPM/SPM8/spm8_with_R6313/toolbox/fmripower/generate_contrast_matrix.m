function [ contrast ] = generate_contrast_matrix( type, number_subjects, old_contrast )
%GENERATE_CONTRAST_MATRIX Summary of this function goes here
%   Detailed explanation goes here
if number_subjects < 1
    err = MException(['FMRIPower:BadArgument', 'Argument ''number_subjects''' ...
        ' must be greater than or equal to 1']);
    throw(err);
end

if(type == 3 )
	contrast = 1;
else
	contrast = old_contrast;
end


function [contrast] = paired_t_contrast(number_subjects)

contrast = [1, zeros(1,number_subjects)];


