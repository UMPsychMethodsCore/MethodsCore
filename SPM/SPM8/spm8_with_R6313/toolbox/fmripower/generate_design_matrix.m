function [ design_matrix ] = generate_design_matrix(type, number_subjects )
%GENERATE_DESIGN_MATRIX Summary of this function goes here
%   Detailed explanation goes here

if number_subjects < 1
    err = MException(['FMRIPower:BadArgument', 'Argument ''number_subjects''' ...
        ' must be greater than or equal to 1']);
    throw(err);
end

if type == 1 || type == 3 || type==4
    design_matrix = one_sample_t_matrix(number_subjects);
    return;
end

if type == 2
    design_matrix = two_sample_t_matrix(number_subjects);
    return;
end


err = MException('FMRIPower:BadArgument', 'Argument ''type'' set incorrectly');
throw(err);


function [matrix] = paired_t_matrix(number_subjects)

matrix = [kron(ones(number_subjects,1),[1; -1]),kron(eye(number_subjects), [1; 1])];


function [matrix] = two_sample_t_matrix(number_subjects)

matrix = kron(eye(2), ones(number_subjects,1));

function [matrix] = one_sample_t_matrix(number_subjects)

matrix = ones(number_subjects,1);
