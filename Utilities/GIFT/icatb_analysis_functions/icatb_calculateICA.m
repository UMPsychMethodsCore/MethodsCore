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


icaAlgo = icatb_icaAlgorithm; % available ICA algorithms

algoVal = sesInfo.algorithm; % algorithm index

% selected ICA algorithm
algorithmName = deblank(icaAlgo(algoVal, :));

disp(' ');
disp('---------------------------------------------------------------------');


if (~strcmpi(algorithmName, 'iva-gl') && ~strcmpi(algorithmName, 'moo-icar') && ~strcmpi(algorithmName, 'constrained ica (spatial)'))
    if (which_analysis == 1)
        disp('STARTING GROUP ICA STEP ');
    else
        disp('STARTING GROUP ICA STEP USING ICASSO');
    end
elseif strcmpi(algorithmName, 'iva-gl')
    disp('STARTING GROUP IVA STEP');
else
    disp(['STARTING ', upper(algorithmName)]);
end
disp('---------------------------------------------------------------------');


% Modality type
[modalityType, dataTitle, compSetFields] = icatb_get_modality;

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

%number of components to extract
numOfIC = sesInfo.numComp;
% data = reshape(data,xdim*ydim*zdim,size(data,2));
mask_ind = sesInfo.mask_ind;

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


if (~strcmpi(algorithmName, 'iva-gl') && ~strcmpi(algorithmName, 'moo-icar') && ~strcmpi(algorithmName, 'constrained ica (spatial)'))
    
    pcain = [sesInfo.data_reduction_mat_file,num2str(sesInfo.numReductionSteps),'-',num2str(1), '.mat'];
    
    load(fullfile(outputDir, pcain));
    
    %contains concatenated PC's
    data = pcasig;
    
    if size(data, 1) == prod(sesInfo.HInfo.DIM(1:3))
        data = data(mask_ind, :);
    end
    
    % Changed this code to allow the users add their own ICA algorithm
    % transpose data to equal components by volume
    data = data';
    
elseif strcmpi(algorithmName, 'iva-gl')
    
    fS = whos('-file', fullfile(outputDir, [sesInfo.data_reduction_mat_file, '1-1.mat']));
    fNames = cellstr(char(fS.name));
    chkPcasig = isempty(strmatch('pcasig', fNames, 'exact'));
    
    disp('Stacking data across subjects ...');
    
    if (chkPcasig)
        
        pcain = [sesInfo.data_reduction_mat_file, '1-1.mat'];
        info = load(fullfile(outputDir, pcain));
        VStacked = info.V;
        LambdaStacked = info.Lambda;
        
        for nD = 1:sesInfo.numOfSub*sesInfo.numOfSess
            if (nD == 1)
                startT = 1;
            else
                startT = sum(sesInfo.diffTimePoints(1:nD-1)) + 1;
            end
            endT = sum(sesInfo.diffTimePoints(1:nD));
            [whiteM, dewhiteM] = get_pca_info(VStacked(startT:endT, :), diag(LambdaStacked(nD, :)));
            dat = icatb_read_data(sesInfo.inputFiles(nD).name, [], mask_ind);
            % Call pre-processing function
            dat = icatb_preproc_data(dat, sesInfo.preproc_type, 0);
            % Remove mean per timepoint
            dat = icatb_remove_mean(dat, 0);
            pcasig = dat*whiteM';
            
            if (nD == 1)
                data = zeros(sesInfo.numComp, length(mask_ind), sesInfo.numOfSub*sesInfo.numOfSess);
            end
            
            data(:, :, nD) = pcasig';
            
            clear wM dat pcasig;
            
        end
        
    else
        
        % stack data of all subjects for doing IVA
        for nD = 1:sesInfo.numOfSub*sesInfo.numOfSess
            
            pcain = [sesInfo.data_reduction_mat_file,num2str(sesInfo.numReductionSteps),'-',num2str(nD), '.mat'];
            load(fullfile(outputDir, pcain), 'pcasig');
            
            if (nD == 1)
                data = zeros(sesInfo.numComp, length(mask_ind), sesInfo.numOfSub*sesInfo.numOfSess);
            end
            
            data(:, :, nD) = pcasig';
            
            clear pcasig;
            
            if ~isempty(statusHandle)
                
                % get the status handles
                statusData = getappdata(statusHandle, appDataName);
                statusData.perCompleted = statusData.perCompleted + (statusData.unitPerCompleted / (sesInfo.numOfSub*sesInfo.numOfSess));
                setappdata(statusHandle, appDataName, statusData);
                set(statusHandle, 'name', [num2str(round(statusData.perCompleted*100)), '% analysis done']); waitbar(statusData.perCompleted, statusHandle);
                
            end
        end
        
        %         if (~isempty(statusHandle))
        %
        %             % get the status handles
        %             statusData = getappdata(statusHandle, appDataName);
        %             statusData.perCompleted = statusData.perCompleted + statusData.unitPerCompleted;
        %             setappdata(statusHandle, appDataName, statusData);
        %             set(statusHandle, 'name', [num2str(round(statusData.perCompleted*100)), '% analysis done']); waitbar(statusData.perCompleted, statusHandle);
        %
        %         end
        
    end
    
    
else
    
    
    %% ICA with reference (Write back-reconstructed files directly)
    for nD = 1:sesInfo.numOfSub*sesInfo.numOfSess
        
        disp(['Calculating ICA on data-set ', num2str(nD)]);
        data = icatb_remove_mean(icatb_preproc_data(icatb_read_data(sesInfo.inputFiles(nD).name, [], mask_ind), sesInfo.preproc_type));
        
        if (strcmpi(algorithmName, 'constrained ica (spatial)'))
            num_comps = rank(data);
            [tmpW, tmpDw] = icatb_calculate_pca(data, num_comps, 'remove_mean', 0, 'whiten', 1);
            [dd, ddW, tmpA, tmpS] = icatb_icaAlgorithm(algorithmName, tmpW', ICA_Options);
            tmpA = tmpDw*tmpA;
        else
            [dd, ddW, tmpA, tmpS] = icatb_icaAlgorithm(algorithmName, data', ICA_Options);
        end
        
        if (sesInfo.numOfSub*sesInfo.numOfSess == 1)
            % to maintain consistency with the dimensions of timecourses
            % when number of subjects is 1.
            tmpA = tmpA';
        end
        
        if (nD == 1)
            icasig = zeros(size(tmpS));
        end
        
        icasig = icasig + tmpS;
        
        compSet = struct(compSetFields{1}, tmpS, compSetFields{2}, tmpA);
        
        % Save subject components
        subFile = [sesInfo.back_reconstruction_mat_file, num2str(nD), '.mat'];
        msgString = ['-saving back reconstructed ica data for set ', num2str(nD),' -> ',subFile];
        disp(msgString);
        drawnow;
        icatb_save(fullfile(outputDir, subFile), 'compSet');
        clear compSet data tmpDw tmpW tmpA tmpS;
        
        
        if ~isempty(statusHandle)
            
            % get the status handles
            statusData = getappdata(statusHandle, appDataName);
            statusData.perCompleted = statusData.perCompleted + (statusData.unitPerCompleted / sesInfo.numOfSub*sesInfo.numOfSess);
            setappdata(statusHandle, appDataName, statusData);
            set(statusHandle, 'name', [num2str(round(statusData.perCompleted*100)), '% analysis done']); waitbar(statusData.perCompleted, statusHandle);
            
        end
        
        fprintf('Done\n');
        
    end
    
    icasig = icasig./(sesInfo.numOfSub*sesInfo.numOfSess);
    
    icatb_save(fullfile(outputDir, [sesInfo.ica_mat_file, '.mat']), 'icasig');
    
    msgStr = ['DONE CALCULATING ', upper(algorithmName)];
    
    disp('---------------------------------------------------------------------');
    disp(msgStr);
    disp('---------------------------------------------------------------------');
    disp('');
    
    if (~isempty(statusHandle))
        
        % get the status handles
        statusData = getappdata(statusHandle, appDataName);
        statusData.perCompleted = statusData.perCompleted + statusData.unitPerCompleted;
        setappdata(statusHandle, appDataName, statusData);
        set(statusHandle, 'name', [num2str(round(statusData.perCompleted*100)), '% analysis done']); waitbar(statusData.perCompleted, statusHandle);
        
    end
    
    return;
    
    %icasig = icasig / sesInfo.numOfSub*sesInfo.numOfSess;
    
end



if strcmpi(algorithmName, 'semi-blind infomax')
    ICA_Options = icatb_sbica_options(ICA_Options, dewhiteM);
    sesInfo.userInput.ICA_Options = ICA_Options;
end

% if (strcmpi(algorithmName, 'constrained ica (spatial)'))
%     if (which_analysis == 2)
%         disp('ICASSO plots don''t work with constrained ICA. Running ICA in regular mode.');
%         fprintf('\n');
%         which_analysis = 1;
%     end
% end

% calculate ICA
%[icaAlgo, W, A, icasig_tmp] = icatb_icaAlgorithm(selected_ica_algorithm, data, ICA_Options);


if (~strcmpi(algorithmName, 'iva-gl'))
    
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
        
        
    elseif (which_analysis == 2)
        % ICASSO
        
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
        
    else
        % MST
        icasigR = cell(1, sesInfo.mst_opts.num_ica_runs);
        fprintf('\n');
        disp(['Number of times ICA will run is ', num2str(sesInfo.mst_opts.num_ica_runs)]);
        for nRun = 1:length(icasigR)
            fprintf('\n');
            disp(['Run ', num2str(nRun), ' / ', num2str(sesInfo.mst_opts.num_ica_runs)]);
            fprintf('\n');
            [dd1, dd2, dd3, icasigR{nRun}]  = icatb_icaAlgorithm(algorithmName, data, ICA_Options);
        end
        clear dd1 dd2 dd3;
        [corrMetric, W, A, icasig, bestRun] = icatb_bestRunSelection(icasigR, data);               
        
        mstResultsFile = fullfile(outputDir, [sesInfo.userInput.prefix, '_mst_results.mat']);
        try
            if (sesInfo.write_analysis_steps_in_dirs)
                mstResultsFile = fullfile(outputDir, [sesInfo.userInput.prefix, '_ica_files', filesep, 'mst_results.mat']);
            end
        catch
        end
        
        icatb_save(mstResultsFile, 'A', 'W', 'icasig', 'icasigR', 'algorithmName', 'corrMetric', 'bestRun');
        
        clear icasigR;
        
    end
    
else
    
    if (which_analysis == 1)
        % IVA
        [i, W] = icatb_icaAlgorithm(algorithmName, data, ICA_Options);
        
        icasig = zeros(sesInfo.numComp, length(mask_ind));
        for n = 1:size(W, 3)
            tmp = squeeze(W(:, :, n)*data(:, :, n));
            icasig = icasig + tmp;
        end
        
        icasig = icasig / size(W, 3);
        
    else
        
        if (which_analysis == 2)
            numRuns = icasso_opts.num_ica_runs;
            disp('ICASSO is not implemented when using IVA algorithm. Using MST instead ...');
        else
            % MST
            numRuns =  sesInfo.mst_opts.num_ica_runs;
        end
        
        % Run IVA several times using MST
        icasigR = cell(1, numRuns);
        fprintf('\n');
        disp(['Number of times ICA will run is ', num2str(numRuns)]);
        for nRun = 1:length(icasigR)
            fprintf('\n');
            disp(['Run ', num2str(nRun), ' / ', num2str(numRuns)]);
            fprintf('\n');
            [dd1, dd2, dd3, icasigR{nRun}]  = icatb_icaAlgorithm(algorithmName, data, ICA_Options);
        end
        clear dd1 dd2 dd3;
        [corrMetric, W, A, icasig, bestRun] = icatb_bestRunSelection(icasigR, data);        
        icasig = squeeze(mean(icasig, 3));
        
        mstResultsFile = fullfile(outputDir, [sesInfo.userInput.prefix, '_mst_results.mat']);
        try
            if (sesInfo.write_analysis_steps_in_dirs)
                mstResultsFile = fullfile(outputDir, [sesInfo.userInput.prefix, '_ica_files', filesep, 'mst_results.mat']);
            end
        catch
        end
        
        icatb_save(mstResultsFile, 'A', 'W', 'icasig', 'icasigR', 'algorithmName', 'corrMetric', 'bestRun');
        
        clear icasigR;
        
    end
    
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
    
    skew = zeros(1, numOfIC);
    
    if (~strcmpi(algorithmName, 'iva-gl'))
        disp('Using skewness of the distribution to determine the sign of the components ...');
        %force group images to be positive
        for compNum = 1:numOfIC
            v = icatb_recenter_image(icasig(compNum, :));
            skew(compNum) = icatb_skewness(v) + eps;
            clear v;
            if (sign(skew(compNum)) == -1)
                disp(['Changing sign of component ',num2str(compNum)]);
                icasig(compNum, :) = icasig(compNum, :)*-1;
                A(:, compNum) = A(:, compNum)*-1;
            end
            
        end
        
        W = pinv(A);
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


if (exist('skew', 'var'))
    icatb_save(icaout, 'W', 'icasig', 'mask_ind', 'skew');
else
    icatb_save(icaout, 'W', 'icasig', 'mask_ind');
end

msgStr = 'DONE CALCULATING GROUP IVA';

if (~strcmpi(algorithmName, 'iva-gl'))
    msgStr = 'DONE CALCULATING GROUP ICA';
    icatb_save(icaout, 'A', '-append');
    
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
    
end

[pp, fileName] = fileparts(sesInfo.userInput.param_file);
drawnow;

icatb_save(fullfile(outputDir, [fileName, '.mat']), 'sesInfo');

disp('---------------------------------------------------------------------');
disp(msgStr);
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


function [metric_Q, A, W, icasig, stableRun] = getStableRunEstimates(sR, minClusterSize, maxClusterSize)
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


function [whiteningMatrix, dewhiteningMatrix] = get_pca_info(V, Lambda)
%% Get Whitening and de-whitening matrix
%
% Inputs:
% 1. V - Eigen vectors
% 2. Lambda - Eigen values diagonal matrix
%
% Outputs:
% 1. whiteningMatrix - Whitening matrix
% 2. dewhiteningMatrix - Dewhitening matrix
%


whiteningMatrix = sqrtm(Lambda) \ V';
dewhiteningMatrix = V * sqrtm(Lambda);


