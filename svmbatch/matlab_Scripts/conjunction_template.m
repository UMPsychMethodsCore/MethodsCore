%% load data
%load ROIs
parametersA = load ('/net/dysthymia/slab/users/guosj/repos/MethodsCore/svmbatch/FirstLevel/5001/Tx1/MSIT/HRF/FixDur/TBTGrid/TBTGrid_parameters.mat');

ROIA = parametersA.parameters.rois.mni.coordinates(1:100,:);
ROIB = parametersA.parameters.rois.mni.coordinates(51:110,:);

nROIA = 100;
nROIB = 60;
%load consensus
consensusA = round(rand(1,(nROIA^2-nROIA)/2));
consensusB = round(rand(1,(nROIB^2-nROIB)/2));

squareA = unflatten (consensusA, nROIA);
squareB = unflatten (consensusB, nROIB);




