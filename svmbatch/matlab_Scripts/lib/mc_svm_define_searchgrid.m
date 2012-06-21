function [ searchgrid ] = mc_svm_define_searchgrid( gridstruct )
%MC_SVM_SEARCHGRID_FLATTEN A function to find all combations, suitable for
%passing as searchgrid object to mc_svm_gridsearch
%   
% FORMAT [ searchgrid ] = mc_svm_define_searchgrid(gridstruct)
%   gridstruct  -   A STRUCT array containing arguments for various parameters,
%                   and values they should take
% 
%                   Expected fields are arg (string) and value (vector)
% 
% EXAMPLE USAGE
% gridstruct(1).arg=' -c ';
% gridstruct(1).value=logspace(1,10,10);
% gridstruct(2).arg=' -r ';
% gridstruct(2).value=logspace(1,5,5);
% result=mc_svm_define_searchgrid(gridstruct);


combo=num2cell(allcomb(gridstruct.value)');

names={gridstruct.arg}';

searchgrid=[names combo];