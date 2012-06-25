function [ svm_grid_models ] = mc_svm_gridsearch( train, trainlabels, test, testlabels, kernel, searchgrid )
%MC_SVM_GRIDSEARCH A function to search SVM performance over a grid of tuning parameters
%   
% FORMAT [svm_grid_models] = mc_svm_gridsearch (train, trainlabels, test, testlabels, kernel, searchgrid)
%   train           -   nTrainExample x nFeat matrix of training data
%   trainlabels     -   nTrainExample x 1 matrix of labels for training data
%   test            -   nTestExample x nFeat matrix of test data
%   testlabels      -   nTestExample x 1 matrix of labels for test data
%   kernel          -   Numeric scalar. Call "svm_learn --help" for more info. Can be one of...
%                           0   -   linear kernel
%                           1   -   polynomial kernel
%                           2   -   radial basis function
%                           3   -   sigmoid tanh
%                           4   -   user defined from kernel.h
%   searchgrid      -   Cell array of size nParameters x ( ParameterCombinations + 1 )
%                       
%                       Each row of cell array defines the settings for one
%                       tuning parameter. Each column of searchgrid defines
%                       a combination of tuning parameters for one
%                       iteration of the grid search. The FIRST column of
%                       searchgrid should contain strings, which will serve
%                       as the arguments to set a given parameter. This
%                       will likely need to include spaces. 
% 
%                       SearchGrid Example
%                       
%                       searchgrid =   {' -d ', 1, 1, 2, 2;
%                                       ' -r ', 0, 1, 0, 1;};
% 
%                       This will effectively search the 2 x 2 grid of 
%                       parameters d (degree for a polynomial) and r (c for
%                       a polynomial). The first column indicates what
%                       arguments to use in constructing options to pass to
%                       svm_learn. For example, on the first iteration of
%                       this grid search, svm_learn will be called with
%                       option string ' -d 1 -r 0'.         
% 
%   RESULT
%       svm_grid_models     -   1 x (nParameterCombos + 1) cell array.
%                               First row contains the error rate when
%                               calling the learned model on the training
%                               data. Columns directly index into columns
%                               of searchgrid, so the first column of
%                               svm_grid_models will be empty, since the
%                               corresponding column in searchgrid sets
%                               parameter flags rather than values.



function [svm_learn_args] = svm_learn_parseargs (kernel, argsettings)
% A function to parse a series of argument flags and settings to construct options for svm_learn
% 
% Argsettings should be a nParameter x 2 cell array. 
% Column 1 should contain, as strings, the arguments for the parameter
% defined in that row. Column 2 should contain, as numeric, the settings
% for the associated parameter.

svm_learn_args='';

% Add the kernel call

svm_learn_args=['-t ' num2str(kernel)];

for iRow=1:size(argsettings,1)
    svm_learn_args = [svm_learn_args argsettings{iRow,1}];
    svm_learn_args = [svm_learn_args num2str(argsettings{iRow,2})];
    
end
end


% Preallocate a bit of space to shut up MLint
svm_grid_models=cell(1,size(searchgrid,2)-1);

for iGrid=2:size(searchgrid,2)
    svm_learn_args=svm_learn_parseargs (kernel, searchgrid(:,[1 iGrid]));
    svm_model_temp = svmlearn(train,trainlabels,svm_learn_args);
    svm_grid_models{1,iGrid} = svmclassify(test,testlabels,svm_model_temp);
end

end
