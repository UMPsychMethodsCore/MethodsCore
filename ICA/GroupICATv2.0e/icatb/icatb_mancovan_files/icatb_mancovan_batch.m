function icatb_mancovan_batch(file_name)
%% Batch for mancovan analysis
%

file_name = deblank(file_name);

addpath(fileparts(which(file_name)));

%% Read input parameters
mancovanInfo = readFile(file_name);

%% Create design matrix
mancovanInfo = create_design(mancovanInfo);

%% Run mancovan
icatb_run_mancovan(mancovanInfo, 1);


function mancovanInfo = create_design(mancovanInfo)
%% Create Design

fprintf('Creating design matrix ...\n');

mancovanInfo = icatb_mancovan_full_design(mancovanInfo, mancovanInfo.userInput.interactions);
fileN = fullfile(mancovanInfo.outputDir, [mancovanInfo.prefix, '.mat']);
icatb_save(fileN, 'mancovanInfo');

fprintf('Done\n\n');

function mancovanInfo = readFile(file_name)
%% Read file
%

fprintf('Reading input parameters for mancovan analysis \n');

inputData = icatb_eval_script(file_name);

%% Store some information
features = {'spatial maps', 'timecourses spectra', 'fnc correlations'};
inputData.features = lower(cellstr(inputData.features));
[dd, ia] = intersect(inputData.features, lower(features));
if (isempty(dd))
    error('Please check features variable');
end

ia = sort(ia);
inputData.features = inputData.features(ia);

mancovanInfo.userInput.features = inputData.features;

mancovanInfo.userInput.outputDir = inputData.outputDir;

if (exist(mancovanInfo.userInput.outputDir, 'dir') ~= 7)
    mkdir(mancovanInfo.userInput.outputDir);
end

mancovanInfo.userInput.ica_param_file = inputData.ica_param_file;
load( mancovanInfo.userInput.ica_param_file);

mancovanInfo.userInput.numOfSub = sesInfo.numOfSub;
mancovanInfo.userInput.prefix = [sesInfo.userInput.prefix, '_mancovan'];
compFiles = sesInfo.icaOutputFiles(1).ses(1).name;
mancovanInfo.userInput.compFiles = icatb_rename_4d_file(icatb_fullFile('directory', fileparts(mancovanInfo.userInput.ica_param_file), 'files', compFiles));
mancovanInfo.userInput.numICs = sesInfo.numComp;
mancovanInfo.userInput.HInfo = sesInfo.HInfo.V(1);

%% Covariates
covariates = inputData.covariates;
cov = repmat(struct('name', '', 'value', [], 'type', 'continuous', 'transformation', ''), 1, size(covariates, 1));

for n = 1:size(covariates, 1)
    cov(n).name = covariates{n, 1};
    if (~strcmpi(covariates{n, 2}, 'continuous'))
        cov(n).type = 'categorical';
    end

    val = covariates{n, 3};

    if (isnumeric(val))
        val = num2str(val(:));
    else
        if (ischar(val) && (size(val, 1) == 1))
            val = icatb_mancovan_load_covariates(val, cov(n).type);
        end
    end

    val = strtrim(cellstr(val));

    if (length(val) ~=  mancovanInfo.userInput.numOfSub)
        error(['Covariate vector must match the no. of subjects in the analysis. Please check ', cov(n).name, ' covariates']);
    end

    cov(n).value = val(:)';
    clear val;

    try
        cov(n).transformation = covariates{n, 4};
    catch
    end

    if (strcmpi(cov(n).type, 'categorical'))
        cov(n).transformation = '';
    end
end

mancovanInfo.userInput.cov = cov;

interactions = [];
try
    interactions = inputData.interactions;
catch
end

mancovanInfo.userInput.interactions = interactions;

%% Component network names
comp_network_names = inputData.comp_network_names;
comp = repmat(struct('name', '', 'value', []), 1, size(comp_network_names, 1));

for n = 1:size(comp_network_names, 1)
    comp(n).name = comp_network_names{n, 1};
    val = comp_network_names{n, 2};
    if (ischar(val))
        val = load(val, '-ascii');
    end
    val = val(:)';
    comp(n).value = val;
end

value = [comp.value];

if (length(value) ~= length(unique(value)))
    error('There are duplicate entries of component/components. Please check variable comp_network_names');
end

if (max(value) > sesInfo.numComp)
    error('Max value of components is greater than the no. of components present');
end

mancovanInfo.userInput.comp = comp;

%% P threshold
p_threshold = 0.01;
try
    p_threshold = inputData.p_threshold;
catch
end
mancovanInfo.userInput.p_threshold = p_threshold;


%% TR
mancovanInfo.userInput.TR = inputData.TR;

%% Number of PCs
numOfPCs = inputData.numOfPCs;

if (length(numOfPCs) == 1)
    numOfPCs = ones(1, length(mancovanInfo.userInput.features))*numOfPCs(1);
end

if (length(numOfPCs) > length(mancovanInfo.userInput.features))
    numOfPCs = numOfPCs(1:length(mancovanInfo.userInput.features));
end

if (length(numOfPCs) ~= length(mancovanInfo.userInput.features))
    error('Please check variable numOfPCs. The length of numOfPCs must match the no. of features');
end

mancovanInfo.userInput.numOfPCs = numOfPCs;

if (any(mancovanInfo.userInput.numOfPCs > mancovanInfo.userInput.numOfSub))
    error(['One/more PCs exceed the no. of subjects (', num2str(mancovanInfo.userInput.numOfSub), ')']);
end

% Set estimation to none
mancovanInfo.userInput.doEstimation = 0;

fprintf('Done\n\n');