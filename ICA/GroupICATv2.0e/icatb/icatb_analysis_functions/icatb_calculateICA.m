function [sesInfo] = icatb_calculateICA(sesInfo, statusHandle)

% ICA is performed on the reduced data set
% Input: sesInfo - structure containing all parameters necessary for group
% ica analysis


if ~exist('sesInfo','var')
    %P=icatb_spm_get(1,'*.mat','Select Parameter File');
    [P] = icatb_selectEntry('typeEntity', 'file', 'title', 'Select Parameter File', 'filter', '*param*.mat');
    if isempty(P)
        error('Parameter file is not selected for analysis');
    end
    [pathstr,fileName]=fileparts(P);
    outputDir = pathstr;
    sesInfo.outputDir = outputDir;
    % Make sure parameter file exists
    load(P);
    if(~exist('sesInfo','var'))
        %         infoCell{1} = P;
        %         icatb_error('The selected file does not contain sesInfo variable', infoCell);
        error(['The selected file ', P, ' does not contain the sesInfo variable']);
    end
else
    outputDir = sesInfo.outputDir;
end

if ~exist('statusHandle', 'var')
    statusHandle = [];
end

if sesInfo.isInitialized == 0
    error('Parameter file has not been initialized');
end


icatb_defaults;
global INDIVIDUAL_ICA_INDEX;
global GROUP_ICA_INDEX;
global WRITE_COMPLEX_IMAGES;
global NUM_RUNS_GICA;
global OPEN_DISPLAY_GUI;


which_analysis = 1;
if (isfield(sesInfo, 'which_analysis'))
    which_analysis = sesInfo.which_analysis;
end

if (which_analysis == 2)
    icasso_opts = struct('sel_mode', 'randinit', 'num_ica_runs', max([2, NUM_RUNS_GICA]));
    if isfield(sesInfo, 'icasso_opts')
        icasso_opts = sesInfo.icasso_opts;
    end
end

disp(' ');
disp('---------------------------------------------------------------------');

if (which_analysis == 1)
    disp('STARTING GROUP ICA STEP ');
else
    disp('STARTING GROUP ICA STEP USING ICASSO');
end
disp('---------------------------------------------------------------------');


% Modality type
[modalityType, dataTitle] = icatb_get_modality;

if isempty(NUM_RUNS_GICA)
    NUM_RUNS_GICA = 1;
end

if NUM_RUNS_GICA < 1
    numRuns = 1;
else
    numRuns = ceil(NUM_RUNS_GICA);
end

sesInfo.num_runs_gica = numRuns;

if ~isfield(sesInfo.userInput, 'dataType')
    dataType = 'real';
else
    dataType = sesInfo.userInput.dataType;
end

sesInfo.dataType = dataType;

pcain = [sesInfo.data_reduction_mat_file,num2str(sesInfo.numReductionSteps),'-',num2str(1), '.mat'];

load(fullfile(outputDir, pcain));

%contains concatenated PC's
data = pcasig;

%number of components to extract
numOfIC = sesInfo.numComp;

%get dimensions of data
xdim = sesInfo.HInfo.DIM(1);ydim = sesInfo.HInfo.DIM(2);zdim = sesInfo.HInfo.DIM(3);

% data = reshape(data,xdim*ydim*zdim,size(data,2));
mask_ind = sesInfo.mask_ind;

if size(data, 1) == prod(sesInfo.HInfo.DIM(1:3))
    data = data(mask_ind, :);
end

icaAlgo = icatb_icaAlgorithm; % available ICA algorithms

algoVal = sesInfo.algorithm; % algorithm index

% selected ICA algorithm
algorithmName = deblank(icaAlgo(algoVal, :));

ICA_Options = {};
% get ica options
if (isfield(sesInfo, 'ICA_Options'))
    ICA_Options = sesInfo.ICA_Options;
else
    if (isfield(sesInfo.userInput, 'ICA_Options'))
        ICA_Options = sesInfo.userInput.ICA_Options;
    end
end

% convert to cell
if isempty(ICA_Options)
    if ~iscell(ICA_Options)
        ICA_Options = {};
    end
end

appDataName = 'gica_waitbar_app_data';

if ~isempty(statusHandle)
    % get the status handles
    statusData = getappdata(statusHandle, appDataName);
    statusData.perCompleted = statusData.perCompleted + statusData.unitPerCompleted;
    setappdata(statusHandle, appDataName, statusData);
    set(statusHandle, 'name', [num2str(round(statusData.perCompleted*100)), '% analysis done']); waitbar(statusData.perCompleted, statusHandle);
end


% Changed this code to allow the users add their own ICA algorithm
% transpose data to equal components by volume
data = data';
if strcmpi(algorithmName, 'semi-blind infomax')
    ICA_Options = icatb_sbica_options(ICA_Options, dewhiteM);
    sesInfo.userInput.ICA_Options = ICA_Options;
end

if (strcmpi(algorithmName, 'constrained ica (spatial)'))
    if (which_analysis == 2)
        disp('ICASSO plots don''t work with constrained ICA. Running ICA in regular mode.');
        fprintf('\n');
        which_analysis = 1;
    end
end

% calculate ICA
%[icaAlgo, W, A, icasig_tmp] = icatb_icaAlgorithm(selected_ica_algorithm, data, ICA_Options);


if (which_analysis == 1)
    
    fprintf('\n');
    disp(['Number of times ICA will run is ', num2str(numRuns)]);
    
    % Loop over number of runs
    for nRun = 1:numRuns
        
        fprintf('\n');
        
        disp(['Run ', num2str(nRun), ' / ', num2str(numRuns)]);
        
        fprintf('\n');
        
        % Run ICA
        [icaAlgo, W, A, icasig] = icatb_icaAlgorithm(algorithmName, data, ICA_Options);
        
        %A = dewhiteM*pinv(W);
        
        if (nRun == 1)
            icasig2 = zeros(numRuns, size(icasig, 1), size(icasig, 2));
        end
        
        if (nRun > 1),
            
            rho = zeros(size(icasig, 1), size(icasig, 1));
            for k1 = 1:size(icasig, 1)
                for k2 = 1:size(icasig, 1)
                    rho(k1, k2) = icatb_corr2(flatrow(icasig(k1, :)), flatrow(icasig2(1, k2, :)));
                end
            end
            % rho = (rho1+rho2)/2;
            
            Y = zeros(1, size(icasig, 1));
            I = Y;
            Ys = Y;
            
            for k = 1:size(icasig,1)
                [Y(k) I(k)] = max(abs(rho(:,k)));
                Ys(k) = rho(I(k),k);%get signed correlation
                rho(I(k), k) = 0;
            end;
            
            %reorder and force to be positively correlated
            icasig = sign(repmat(Ys', 1, size(icasig,2))).*icasig(I,:);
            A = sign(repmat(Ys, size(A,1),1)).*A(:,I);
            
        end
        
        % store icasig and A
        icasig2(nRun, :, :) = icasig;
        A2(nRun, :, :) = A;
        
    end
    % end loop over number of runs
    
    if numRuns > 1
        icasig = squeeze(mean(icasig2));
        A = squeeze(mean(A2));
        clear W;
        W = pinv(A);
    end
    
    clear icasig2;
    clear A2;
    
    
else
    
    %%%%% Calculate PCA and Whitening matrix %%%%%
    % PCA
    [V, Lambda] = icatb_v_pca(data, 1, numOfIC, 0, 'transpose', 'yes');
    
    % Whiten matrix
    [w, White, deWhite] = icatb_v_whiten(data, V, Lambda, 'transpose');
    
    clear V Lambda;
    
    sR = icatb_icassoEst(icasso_opts.sel_mode, data, icasso_opts.num_ica_runs, 'numOfPC', numOfIC, 'algoIndex', sesInfo.algorithm, ...
        'dewhiteM', deWhite, 'whiteM', White, 'whitesig', w, 'icaOptions', ICA_Options);
    
    clear data w deWhite White;
    
    %%%% Visualization %%%%%%
    
    sR = icassoExp(sR);
    
    %%% Visualization & returning results
    %%% Allow to disable visualization
    if OPEN_DISPLAY_GUI
        disp(['Launch Icasso visualization supposing ', num2str(numOfIC), ' estimate-clusters.']);
        disp('Show demixing matrix rows.');
        icassoShow(sR, 'L', numOfIC, 'estimate', 'demixing');
        
        disp(['Launch Icasso visualization supposing ', num2str(numOfIC), ' estimate-clusters.']);
        disp('Show IC source estimates (default), reduce number of lines');
        disp('Collect results.');
        iq = icassoShow(sR, 'L', numOfIC, 'colorlimit', [.8 .9]);
    else
        iq = icassoResult(sR, numOfIC);
    end
    
    try
        minClusterSize = icasso_opts.min_cluster_size;
    catch
        minClusterSize = 2;
    end
    
    try
        maxClusterSize = icasso_opts.max_cluster_size;
    catch
        maxClusterSize = icasso_opts.num_ica_runs;
    end
    
    if (minClusterSize <= 1)
        minClusterSize = 2;
    end
    
    if (minClusterSize > icasso_opts.num_ica_runs)
        minClusterSize = icasso_opts.num_ica_runs;
    end
    
    [metric_Q, A, W, icasig] = getStableRunEstimates(sR, minClusterSize, maxClusterSize);
    
    icassoResultsFile = fullfile(outputDir, [sesInfo.userInput.prefix, '_icasso_results.mat']);
    try
        if (sesInfo.write_analysis_steps_in_dirs)
            icassoResultsFile = fullfile(outputDir, [sesInfo.userInput.prefix, '_ica_files', filesep, 'icasso_results.mat']);
        end
    catch
    end
    
    icatb_save(icassoResultsFile, 'iq', 'A', 'W', 'icasig', 'sR', 'algorithmName', 'metric_Q');
    
    clear sR;
    
end

clear data;

fprintf('\n');

if ~isempty(statusHandle)
    
    % get the status handles
    statusData = getappdata(statusHandle, appDataName);
    statusData.perCompleted = statusData.perCompleted + statusData.unitPerCompleted;
    setappdata(statusHandle, appDataName, statusData);
    set(statusHandle, 'name', [num2str(round(statusData.perCompleted*100)), '% analysis done']); waitbar(statusData.perCompleted, statusHandle);
end

clear data;clear sphere;clear signs;clear bias;clear lrates;

sesInfo.numComp = size(icasig, 1);
numOfIC = sesInfo.numComp;

if strcmpi(modalityType, 'fmri')
    
    disp('Using skewness of the distribution to determine the sign of the components ...');
    
    %force group images to be positive
    for compNum = 1:numOfIC
        v = icatb_recenter_image(icasig(compNum, :));
        skew = icatb_skewness(v);
        clear v;
        if (sign(skew) == -1)
            disp(['Changing sign of component ',num2str(compNum)]);
            icasig(compNum, :) = icasig(compNum, :)*-1;
        end
        
    end
    
end

% enforce dimensions to save in analyze format
if(size(icasig,1)>size(icasig,2))
    icasig = icasig';
end

% save in matlab format
icaout = [sesInfo.ica_mat_file, '.mat'];
icaout = fullfile(outputDir, icaout);

drawnow;

icatb_save(icaout, 'A', 'W', 'icasig', 'mask_ind');

% naming of complex images
[sesInfo, complexInfo] = icatb_name_complex_images(sesInfo, 'write');

% global variable necessary for defining the real&imag or magnitude&phase
WRITE_COMPLEX_IMAGES = sesInfo.userInput.write_complex_images;


if strcmpi(modalityType, 'fmri')
    
    if isfield(sesInfo, 'zipContents')
        sesInfo = rmfield(sesInfo, 'zipContents');
    end
    
    sesInfo.zipContents.zipFiles = {};
    sesInfo.zipContents.files_in_zip.name = {};
    
    if(sesInfo.numOfSub ==1 & sesInfo.numOfSess==1)
        % complex data
        if ~isreal(icasig)
            % convert to complex data structure
            icasig = complex_data(icasig);
            A = complex_data(A);
        end
        
        outfile = sesInfo.icaOutputFiles(1).ses(1).name(1,:);
        [fileNames, zipfilename, files_in_zip] = icatb_saveICAData(outfile, icasig, A, mask_ind, numOfIC, sesInfo.HInfo, ...
            sesInfo.dataType, complexInfo, outputDir);
    else
        outfile = sesInfo.aggregate_components_an3_file;
        % complex data
        if ~isreal(icasig)
            % convert to complex data
            icasig = complex_data(icasig);
            A = complex_data(A);
        end
        [aggFileNames, zipfilename, files_in_zip] = icatb_saveICAData(outfile, icasig, A, mask_ind, numOfIC, sesInfo.HInfo, ...
            sesInfo.dataType, complexInfo, outputDir);
        drawnow;
    end
    
    %[pp, fileName] = fileparts(sesInfo.userInput.param_file);
    %save(fullfile(outputDir, [fileName, '.mat']), 'sesInfo');
    
    % store the zip filenames to a structure
    sesInfo.zipContents.zipFiles{1} = zipfilename;
    sesInfo.zipContents.files_in_zip(1).name = files_in_zip;
    
end

[pp, fileName] = fileparts(sesInfo.userInput.param_file);
drawnow;

icatb_save(fullfile(outputDir, [fileName, '.mat']), 'sesInfo');

disp('---------------------------------------------------------------------');
disp('DONE CALCULATING GROUP ICA');
disp('---------------------------------------------------------------------');
disp('');

if ~isempty(statusHandle)
    
    % get the status handles
    statusData = getappdata(statusHandle, appDataName);
    statusData.perCompleted = statusData.perCompleted + statusData.unitPerCompleted;
    setappdata(statusHandle, appDataName, statusData);
    set(statusHandle, 'name', [num2str(round(statusData.perCompleted*100)), '% analysis done']); waitbar(statusData.perCompleted, statusHandle);
end


function [data] = flatrow(data)

data = data(:);


function [metric_Q, A, W, icasig] = getStableRunEstimates(sR, minClusterSize, maxClusterSize)
%% Get stable run based on code by Sai Ma. Stable run estimates will be used instead of centrotype
%

% number of runs and ICs
numOfRun = length(sR.W);
numOfIC = size(sR.W{1},1);

% Get the centrotype for each cluster and Iq
index2centrotypes = icassoIdx2Centrotype(sR,'partition', sR.cluster.partition(numOfIC,:));
Iq = icassoStability(sR, numOfIC, 'none');

% Find IC index  within each cluster
partition = sR.cluster.partition(numOfIC, :);
clusterindex = cell(1, numOfIC);
for i = 1:numOfIC
    temp = (partition == i);
    clusterindex{i} = sR.index(temp, :);
    clear temp;
end

% Compute stability metric for each run within each cluster
eachRun = zeros(numOfRun, numOfIC);
qc = 0; % num of qualified clusters
for i = 1:numOfIC
    thisCluster = (clusterindex{i}(:,1))';
    clusterSize = length(clusterindex{i});
    if ((clusterSize >= minClusterSize) && (clusterSize <= maxClusterSize) && (Iq(i)>=0.7))
        qc = qc + 1;
        for k = 1:numOfRun
            thisRun = find(thisCluster == k);
            ICindex = (clusterindex{i}(thisRun,1)-1)*numOfIC + clusterindex{i}(thisRun,2);
            if ~isempty(thisRun)
                eachRun(k,i) = max(sR.cluster.similarity(index2centrotypes(i),ICindex'));
            end
            clear thisRun ICindex;
        end
    end
    clear thisCluster clusterSize;
end

%% Find stable run
metric_Q = sum(eachRun,2)/qc;
[dd, stableRun] = max(metric_Q);

%% Get stable run estimates
W = sR.W{stableRun};
clusters_stablerun = partition((stableRun - 1)*numOfIC + 1 : stableRun*numOfIC);
[dd, inds] = sort(clusters_stablerun);
W = W(inds, :);
A = pinv(W);
icasig = W*sR.signal;
