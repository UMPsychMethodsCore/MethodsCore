function sesInfo = icatb_dataReduction(sesInfo, statusHandle)
%% Reduces each subject's data using pca. If more than one reduction
% step is specified by parameters then a concatenation step is done along
% with another pca step.

% Input: sesInfo - structure containing all parameters necessary for group
% ica analysis.

if (~exist('sesInfo', 'var'))
    P = icatb_selectEntry('typeEntity', 'file', 'title', 'Select Parameter File', 'filter', '*param*.mat');
    if (isempty(P))
        error('Parameter file is not selected for analysis');
    end
    outputDir = fileparts(P);
    % Make sure parameter file exists
    load(P);
    if (~exist('sesInfo', 'var'))
        error(['The selected file ', P, ' does not contain the sesInfo variable']);
    end
else
    outputDir = sesInfo.outputDir;
end

sesInfo.outputDir = outputDir;

drawnow;

if (~exist('statusHandle', 'var'))
    statusHandle = [];
end

if (sesInfo.isInitialized == 0)
    icatb_error('Parameter file has not been initialized');
end

modalityType = icatb_get_modality;

appDataName = 'gica_waitbar_app_data';

if ~isempty(statusHandle)
    % get the status handles
    statusData = getappdata(statusHandle, appDataName);
    statusData.perCompleted = statusData.perCompleted + statusData.unitPerCompleted;
    setappdata(statusHandle, appDataName, statusData);
    set(statusHandle, 'name', [num2str(round(statusData.perCompleted*100)), '% analysis done']); waitbar(statusData.perCompleted, statusHandle);
end

%% Mask Indices
mask_ind = sesInfo.mask_ind;
numVoxels = length(mask_ind);

preproc_type = 'remove mean per timepoint';

if (isfield(sesInfo, 'preproc_type'))
    preproc_type = sesInfo.preproc_type;
end

groupPCAOpts = char('Subject Specific', 'Grand Mean');

group_pca_type = 'subject specific';
if isfield(sesInfo, 'group_pca_type')
    group_pca_type = sesInfo.group_pca_type;
end

if (isnumeric(group_pca_type))
    group_pca_type = lower(deblank(groupPCAOpts(group_pca_type, :)));
    sesInfo.group_pca_type = group_pca_type;
end

doGrandMeanPCA = (strcmpi(group_pca_type, 'grand mean') && (sesInfo.numOfSub*sesInfo.numOfSess > 1));

disp(' ');
disp('------------------------------------------------------------------------------------');
disp('STARTING DATA REDUCTION (PRINCIPAL COMPONENTS ANALYSIS)');
disp('------------------------------------------------------------------------------------');

if (~isfield(sesInfo, 'dataType'))
    sesInfo.dataType = 'real';
end

[sesInfo, complexInfo] = icatb_name_complex_images(sesInfo, 'read');
numReductionSteps = sesInfo.numReductionSteps;

%% Group PCA Options
gpca_opts = getPCAOpts(sesInfo);

%% Reduction Steps To Run
reductionStepsToRun = (1:numReductionSteps);
if (isfield(sesInfo, 'reductionStepsToRun'))
    reductionStepsToRun = sesInfo.reductionStepsToRun;
    sesInfo = rmfield(sesInfo, 'reductionStepsToRun');
end

reductionStepsToRun(reductionStepsToRun > numReductionSteps) = [];

conserve_disk_space = getConserveDiskSpaceInfo(sesInfo, gpca_opts);

%% Loop through each reduction step
for j = reductionStepsToRun
    
    disp(['--Extracting principal components for data reduction( time #', num2str(j), ' )']);
    
    pcaType = gpca_opts{j}.pcaType;
    pca_opts = gpca_opts{j}.pca_opts;
    
    stackData = 'yes';
    
    if (sesInfo.numOfSub*sesInfo.numOfSess > 1)
        try
            stackData = pca_opts.stack_data;
        catch
        end
    end
    
    tol = 1e-4;
    max_iter = 1000;
    if (strcmpi(pcaType, 'standard'))
        if strcmpi(stackData, 'yes')
            pca_opts.storage = 'full';
            %pca_opts.eig_solver = 'all';
        end
    elseif strcmpi(pcaType, 'svd')
        stackData = 'yes';
    else
        try
            tol = pca_opts.tolerance;
            max_iter = pca_opts.max_iter;
        catch
        end
    end
    
    pca_opts.stack_data = stackData;
    
    fprintf('\n');
    disp(['PCA type selected is ', upper(pcaType(1)), lower(pcaType(2:end))]);
    fprintf('\n');
    
    fprintf('\n');
    disp('PCA options are: ');
    
    pca_field_names = fieldnames(pca_opts);
    for nOpts = 1:length(pca_field_names)
        
        msgStr = getfield(pca_opts, pca_field_names{nOpts});
        if (isnumeric(msgStr))
            msgStr = num2str(msgStr);
        end
        
        disp(['pca_opts.',  pca_field_names{nOpts}, ' = ', msgStr]);
        
    end
    fprintf('\n');
    
    numOfGroupsAfter = sesInfo.reduction(j).numOfGroupsAfterCAT;
    
    dataSetNo = 1;
    if (isfield(sesInfo, 'dataSetNo'))
        dataSetNo = sesInfo.dataSetNo;
        sesInfo = rmfield(sesInfo, 'dataSetNo');
    end
    
    dataSetsToRun = (1:numOfGroupsAfter);
    dataSetsToRun(dataSetsToRun < dataSetNo) = [];
    
    %% Compute covariance matrix and apply PCA
    if(j > 1)
        
        if (conserve_disk_space == 1)
            pcain = [sesInfo.data_reduction_mat_file, num2str(j - 1), '-1.mat'];
            load(fullfile(outputDir, pcain), 'V', 'Lambda');
            VStacked = V;
            LambdaStacked = Lambda;
            clear V Lambda;
        end
        
        %count = dataSetNo;
        numOfPC = sesInfo.reduction(j).numOfPCBeforeCAT;
        
        %% PCA Type
        if strcmpi(pcaType, 'standard')
            
            if (~strcmpi(pca_opts.storage, 'full'))
                clear temp_numpcs temp_inds;
                %% Number of PC's per column
                temp_numpcs = (numOfPC:-1:1);
                temp_numpcs = repmat(temp_numpcs, numOfPC, 1);
                
                %% Temp component indices
                temp_inds = repmat((1:numOfPC)', 1, numOfPC);
            end
            
            %% Loop over groups after concatenation
            for i = dataSetsToRun %1:sesInfo.reduction(j).numOfGroupsAfterCAT
                
                if (i ~= 1)
                    count = sum(sesInfo.reduction(j).numOfPrevGroupsInEachNewGroupAfterCAT(1:i-1)) + 1;
                else
                    count = 1;
                end
                
                %% Data reduction parameters
                numInNewGroup = sesInfo.reduction(j).numOfPrevGroupsInEachNewGroupAfterCAT(i);
                
                %% Covariance matrix rows
                covSize = numInNewGroup*numOfPC;
                
                if (conserve_disk_space ~= 1)
                    disp(['Calculating covariance matrix for reduction # ', num2str(j), ' group #', num2str(i)]);
                else
                    disp(['--Doing pca reduction #', num2str(j), ' on group #', num2str(i)]);
                end
                
                %% Check stacking of data
                if strcmpi(stackData, 'yes')
                    
                    %% Loop over groups
                    for nRows = 1:numInNewGroup
                        
                        if (nRows == 1)
                            
                            if (strcmpi(pca_opts.precision, 'double'))
                                % Double precision
                                data = zeros(numVoxels, covSize);
                            else
                                % Single precision
                                data = zeros(numVoxels, covSize, 'single');
                            end
                            
                        end
                        
                        
                        if (conserve_disk_space ~= 1)
                            pcain = [sesInfo.data_reduction_mat_file, num2str(j - 1), '-', num2str(count + (nRows - 1)), '.mat'];
                            load(fullfile(outputDir, pcain), 'pcasig');
                        else
                            
                            if (nRows == 1)
                                startT = 1;
                            else
                                startT = sum(sesInfo.diffTimePoints(1:nRows-1)) + 1;
                            end
                            
                            subNum = ceil(nRows/sesInfo.numOfSess);
                            ses = mod(nRows-1, sesInfo.numOfSess) + 1;
                            endT = sum(sesInfo.diffTimePoints(1:nRows));
                            wM = get_pca_info(VStacked(startT:endT, :), diag(LambdaStacked(nRows, :)));
                            disp(['Loading subject #', num2str(subNum), ' session #', num2str(ses), ' ...']);
                            dat = icatb_read_data(sesInfo.inputFiles(count + (nRows - 1)).name, [], mask_ind, pca_opts.precision);
                            % Call pre-processing function
                            dat = icatb_preproc_data(dat, preproc_type);
                            % Remove mean per timepoint
                            dat = icatb_remove_mean(dat, 0);
                            pcasig = dat*wM';
                            clear wM dat;
                        end
                        
                        %% Stack data
                        if (isa(data, 'single'))
                            pcasig = single(pcasig);
                        end
                        
                        data(:, (nRows - 1)*numOfPC + 1 : nRows*numOfPC) = pcasig;
                        clear pcasig;
                        
                    end
                    %% End of loop over groups
                    
                    if (conserve_disk_space ~= 1)
                        %% Calculate covariance matrix
                        cov_m = icatb_cov(data, 0);
                        clear data;
                    else
                        fprintf('\n');
                        [V, Lambda] = icatb_v_pca(data, 1, sesInfo.reduction(j).numOfPCAfterReduction, 0, 'untranspose', 'no');
                        checkEig(Lambda);
                        wM = get_pca_info(V, Lambda);
                        Lambda = diag(Lambda);
                        Lambda = Lambda(:)';
                        pcasig = data*wM';
                        clear data wM;
                        pcaout = [sesInfo.data_reduction_mat_file, num2str(j), '-1.mat'];
                        pcaout = fullfile(outputDir, pcaout);
                        icatb_save(pcaout, 'V', 'Lambda', 'pcasig');
                        clear V Lambda pcasig;
                        break;
                    end
                    
                else
                    
                    if (strcmpi(pca_opts.storage, 'full'))
                        
                        %% Full storage
                        if (strcmpi(pca_opts.precision, 'double'))
                            % Double precision
                            cov_m = eye(covSize, covSize);
                        else
                            % Single precision
                            cov_m = eye(covSize, covSize, 'single');
                        end
                        
                    else
                        
                        %% Packed storage
                        if (strcmpi(pca_opts.precision, 'double'))
                            % Double precision
                            cov_m = zeros(covSize*(covSize + 1)/2, 1);
                        else
                            % Single precision
                            cov_m = zeros(covSize*(covSize + 1)/2, 1, 'single');
                        end
                        
                        %% Number of elements per column for lower triangle
                        numElem = covSize:-1:1;
                        
                        %% Diagonal elements
                        diags = [1, numElem(1:end-1)];
                        diags = cumsum(diags);
                        
                        if (isa(cov_m, 'double'))
                            cov_m(diags) = 1;
                        else
                            cov_m(diags) = single(1);
                        end
                        
                    end
                    
                    
                    %% Loop over rows
                    for nRows = 1:numInNewGroup - 1
                        
                        %% Dataset 1
                        pcain = [sesInfo.data_reduction_mat_file, num2str(j - 1), '-', num2str(count + (nRows - 1)), '.mat'];
                        load(fullfile(outputDir, pcain), 'pcasig');
                        data1 = pcasig;
                        clear pcasig;
                        
                        rows = (nRows - 1)*numOfPC + 1:nRows*numOfPC;
                        
                        %% Diagonal elements for packed storage
                        if (~strcmpi(pca_opts.storage, 'full'))
                            temp_diags = repmat(diags(rows), numOfPC, 1);
                        end
                        
                        countRow = 0;
                        
                        %% Loop over columns
                        for nCols = nRows + 1:numInNewGroup
                            
                            countRow = countRow + 1;
                            
                            cols = (nCols - 1)*numOfPC + 1:nCols*numOfPC;
                            
                            %% Dataset 2
                            pcain = [sesInfo.data_reduction_mat_file, num2str(j - 1), '-', num2str(count + (nCols - 1)), '.mat'];
                            load(fullfile(outputDir, pcain), 'pcasig');
                            data2 = pcasig;
                            clear pcasig;
                            
                            tmp =(data2'*data1)/(size(data1, 1) - 1);
                            
                            if (isa(cov_m, 'single'))
                                tmp = single(tmp);
                            end
                            
                            if (strcmpi(pca_opts.storage, 'full'))
                                %% Full storage
                                cov_m(cols, rows) = tmp;
                                cov_m(rows, cols) = tmp';
                                
                            else
                                %% Packed storage
                                inds = temp_inds + temp_diags + temp_numpcs - 1;
                                inds = inds + (countRow - 1)*numOfPC;
                                % Fill covariance matrix
                                cov_m(inds(:)) = tmp;
                                clear inds;
                            end
                            
                        end
                        %% End of loop over columns
                        
                    end
                    %% End of loop over rows
                    
                    clear data1 data2;
                    
                end
                %% End for checking stacking of data
                
                %% Update count
                %count = count + numInNewGroup;
                
                fprintf('\n');
                
                disp(['--Doing pca reduction #', num2str(j), ' on group #', num2str(i)]);
                
                %% Call symmetric matrix eigen solver
                [V, Lambda] = icatb_eig_symm(cov_m, covSize, 'num_eigs', sesInfo.reduction(j).numOfPCAfterReduction, ...
                    'eig_solver', pca_opts.eig_solver, 'create_copy', 0);
                
                clear cov_m;
                
                checkEig(Lambda);
                
                %% Whitening and de-whitening matrix
                [whiteM, dewhiteM] = get_pca_info(V, Lambda);
                
                %% Save PCA information
                pcaout = [sesInfo.data_reduction_mat_file, num2str(j), '-', num2str(i), '.mat'];
                pcaout = fullfile(outputDir, pcaout);
                
                drawnow;
                
                icatb_save(pcaout, 'V', 'Lambda', 'whiteM', 'dewhiteM');
                
                clear V Lambda whiteM dewhiteM;
                
            end
            %% End of loop over groups after concatenation
            
            
        else
            
            %% Expectation Maximization
            numOfPCAfter = sesInfo.reduction(j).numOfPCAfterReduction;
            
            %% Loop over groups after concatenation
            for i = dataSetsToRun %1:sesInfo.reduction(j).numOfGroupsAfterCAT
                
                if (i ~= 1)
                    count = sum(sesInfo.reduction(j).numOfPrevGroupsInEachNewGroupAfterCAT(1:i-1)) + 1;
                else
                    count = 1;
                end
                
                pcaout = [sesInfo.data_reduction_mat_file, num2str(j), '-', num2str(i), '.mat'];
                pcaout = fullfile(outputDir, pcaout);
                
                %% Data reduction parameters
                numInNewGroup = sesInfo.reduction(j).numOfPrevGroupsInEachNewGroupAfterCAT(i);
                
                tp = numInNewGroup*numOfPC;
                
                if ~(strcmpi(pcaType, 'svd'))
                    
                    
                    C = rand(numOfPCAfter, tp);
                    
                    iterCount = 0;
                    
                    residual_err = 1;
                    
                    C = norm2(C);
                    
                end
                
                %% Check stacking of data
                if strcmpi(stackData, 'yes')
                    
                    disp(['--Doing pca reduction #', num2str(j), ' on group #', num2str(i)]);
                    fprintf('\n');
                    
                    %% Loop over groups
                    for nRows = 1:numInNewGroup
                        
                        if (conserve_disk_space ~= 1)
                            pcain = [sesInfo.data_reduction_mat_file, num2str(j - 1), '-', num2str(count + (nRows - 1)), '.mat'];
                            load(fullfile(outputDir, pcain), 'pcasig');
                        else
                            if (nRows == 1)
                                startT = 1;
                            else
                                startT = sum(sesInfo.diffTimePoints(1:nRows-1)) + 1;
                            end
                            subNum = ceil(nRows/sesInfo.numOfSess);
                            ses = mod(nRows-1, sesInfo.numOfSess) + 1;
                            endT = sum(sesInfo.diffTimePoints(1:nRows));
                            wM = get_pca_info(VStacked(startT:endT, :), diag(LambdaStacked(nRows, :)));
                            disp(['Loading subject #', num2str(subNum), ' session #', num2str(ses), ' ...']);
                            dat = icatb_read_data(sesInfo.inputFiles(count + (nRows - 1)).name, [], mask_ind, pca_opts.precision);
                            % Call pre-processing function
                            dat = icatb_preproc_data(dat, preproc_type);
                            % Remove mean per timepoint
                            dat = icatb_remove_mean(dat, 0);
                            pcasig = dat*wM';
                            clear wM dat;
                        end
                        
                        if (nRows == 1)
                            
                            if (strcmpi(pca_opts.precision, 'double'))
                                % Double precision
                                data = zeros(numVoxels, numInNewGroup*numOfPC);
                            else
                                % Single precision
                                data = zeros(numVoxels, numInNewGroup*numOfPC, 'single');
                            end
                            
                        end
                        
                        %% Stack data
                        if (isa(data, 'single'))
                            pcasig = single(pcasig);
                        end
                        
                        data(:, (nRows - 1)*numOfPC + 1 : nRows*numOfPC) = pcasig;
                        clear pcasig;
                        
                    end
                    %% End of loop over groups
                    
                    
                    if (strcmpi(pcaType, 'svd'))
                        [V, Lambda] = icatb_svd(data, numOfPCAfter, 'solver', pca_opts.solver);
                        varsToSave = {'V', 'Lambda', 'whiteM', 'dewhiteM'};
                    else
                        [V, Lambda, C] = icatb_calculate_em_pca(data, C, 'max_iter', max_iter, 'tolerance', tol, 'verbose', 1);
                        varsToSave = {'V', 'Lambda', 'whiteM', 'dewhiteM', 'C'};
                    end
                    
                    checkEig(Lambda);
                    
                    fprintf('\n');
                    
                    %% Whitening and de-whitening matrix
                    [whiteM, dewhiteM] = get_pca_info(V, Lambda);
                    
                    if (conserve_disk_space == 1)
                        pcasig = data*whiteM';
                        Lambda = diag(Lambda);
                        Lambda = Lambda(:)';
                        clear data;
                        icatb_save(pcaout, 'V', 'Lambda', 'pcasig');
                    else
                        clear data;
                        icatb_save(pcaout, varsToSave{:});
                    end
                    
                else
                    
                    disp(['-- Computing Transformation Matrix for Reduction Step #', num2str(j), ' Group #', num2str(i)]);
                    disp('This part may take a lot of time. Please wait ...');
                    
                    fprintf('\n');
                    usePinv = 0;
                    %% Start iterations
                    while ((residual_err > tol) && (iterCount <= max_iter))
                        
                        C_old = C;
                        
                        iterCount = iterCount + 1;
                        
                        C = C'*pinv(C*C');
                        endTp = 0;
                        
                        %% Loop over groups
                        for nRows = 1:numInNewGroup
                            startTp = endTp + 1;
                            pcain = [sesInfo.data_reduction_mat_file, num2str(j - 1), '-', num2str(count + (nRows - 1)), '.mat'];
                            load(fullfile(outputDir, pcain), 'pcasig');
                            if (strcmpi(pca_opts.precision, 'single'))
                                pcasig = single(pcasig);
                            end
                            endTp = endTp + size(pcasig, 2);
                            if (nRows == 1)
                                if (strcmpi(pca_opts.precision, 'double'))
                                    X = zeros(numVoxels, numOfPCAfter);
                                else
                                    X = zeros(numVoxels, numOfPCAfter, 'single');
                                end
                            end
                            X = X + pcasig*C(startTp:endTp, :);
                            
                        end
                        %% End of loop over groups
                        
                        clear pcasig C;
                        
                        
                        %% Convert reduced data to double as mldivide might not handle single
                        % precision well in some cases.
                        X = double(X);
                        
                        if (iterCount == 1)
                            rank_initial = rank(X);
                            if (rank_initial < size(X, 2))
                                usePinv = 1;
                                disp('Initial projection of transformation matrix on to the data is found to be rank deficient.');
                                disp('Using pseudo-inverse to solve linear equations for rank deficient systems ...');
                            end
                        end
                        
                        endTp = 0;
                        for nRows = 1:numInNewGroup
                            startTp = endTp + 1;
                            pcain = [sesInfo.data_reduction_mat_file, num2str(j - 1), '-', num2str(count + (nRows - 1)), '.mat'];
                            load(fullfile(outputDir, pcain), 'pcasig');
                            if (strcmpi(pca_opts.precision, 'single'))
                                pcasig = single(pcasig);
                            end
                            endTp = endTp + size(pcasig, 2);
                            if (nRows == 1)
                                C = zeros(numOfPCAfter, tp);
                            end
                            
                            if (~usePinv)
                                C(:, startTp:endTp) = (X'*X) \ (double(X'*pcasig));
                            else
                                C(:, startTp:endTp) = pinv(X)*pcasig;
                            end
                            
                        end
                        
                        clear pcasig X;
                        
                        C = norm2(C);
                        
                        residual_err = norm_resid(C, C_old);
                        
                        if (mod(iterCount, 5) == 0)
                            disp(['Step No: ', num2str(iterCount), ' Norm of residual error: ', num2str(residual_err, '%0.6f')]);
                        end
                        
                    end
                    %% End of iterations
                    
                    fprintf('\n');
                    if (residual_err <= tol)
                        disp(['No of iterations required to converge is ', num2str(iterCount)]);
                    else
                        disp(['Reached max iterations (', num2str(iterCount), ')']);
                        disp(['Residual error is ', num2str(residual_err)]);
                    end
                    
                    %% Save PCA information
                    icatb_save(pcaout, 'C');
                    
                    C = C';
                    
                    %% Compute eigen vectors and values
                    [C, ddd] = svd(C, 0);
                    clear ddd;
                    
                    if (strcmpi(pca_opts.precision, 'double'))
                        cov_m = zeros(numVoxels, numOfPCAfter);
                    else
                        cov_m = zeros(numVoxels, numOfPCAfter, 'single');
                    end
                    
                    endTp = 0;
                    for nRows = 1:numInNewGroup
                        startTp = endTp + 1;
                        pcain = [sesInfo.data_reduction_mat_file, num2str(j - 1), '-', num2str(count + (nRows - 1)), '.mat'];
                        load(fullfile(outputDir, pcain), 'pcasig');
                        if (strcmpi(pca_opts.precision, 'single'))
                            pcasig = single(pcasig);
                        end
                        endTp = endTp + size(pcasig, 2);
                        cov_m = cov_m + pcasig*C(startTp:endTp, :);
                    end
                    
                    clear pcasig;
                    
                    
                    fprintf('\n');
                    disp(['--Doing pca reduction #', num2str(j), ' on group #', num2str(i)]);
                    
                    cov_m = (cov_m'*cov_m)/(size(cov_m, 1) - 1 );
                    
                    [V, Lambda] = eig(cov_m, 'nobalance');
                    
                    checkEig(Lambda);
                    
                    V = C*V;
                    
                    clear C;
                    
                    drawnow;
                    
                    %% Whitening and de-whitening matrix
                    [whiteM, dewhiteM] = get_pca_info(V, Lambda);
                    
                    icatb_save(pcaout, 'V', 'Lambda', 'whiteM', 'dewhiteM', '-append');
                    
                end
                
                clear V Lambda whiteM dewhiteM;
                
                %% Update count
                %count = count + numInNewGroup;
                
                fprintf('\n');
                
            end
            %% End of loop over groups after concatenation
            
        end
        %% End for PCA Type
        
        disp(['Done extracting principal components for data reduction( time #', num2str(j), ' )']);
        fprintf('\n');
        
    end
    %% End for computing covariance matrix and applying PCA
    
    
    %numOfGroupsAfter = sesInfo.reduction(j).numOfGroupsAfterCAT;
    
    %count = dataSetNo;
    
    
    if ((conserve_disk_space ~= 1) || (j == 1))
        
        %% Loop over groups after concatenation
        for i = dataSetsToRun %1:numOfGroupsAfter
            
            if (conserve_disk_space ~= 1)
                pcaout = [sesInfo.data_reduction_mat_file, num2str(j), '-', num2str(i), '.mat'];
            else
                pcaout = [sesInfo.data_reduction_mat_file, num2str(j), '-1.mat'];
            end
            
            pcaout = fullfile(outputDir, pcaout);
            
            %% Use old code to do PCA for the first reduction
            if(j == 1)
                
                %Calculate pca
                numOfPC = sesInfo.reduction(j).numOfPCAfterReduction;
                
                %% Compute mean of data-sets and get the tranformation vector
                if (doGrandMeanPCA)
                    if (i == 1)
                        VM = grandMeanPCA(sesInfo, preproc_type, pca_opts.precision);
                    else
                        load(fullfile(sesInfo.outputDir, [sesInfo.data_reduction_mat_file, 'mean.mat']), 'VM');
                    end
                end
                
                fprintf('\n');
                
                subNum = ceil(i/sesInfo.numOfSess);
                ses = mod(i-1, sesInfo.numOfSess) + 1;
                if (~strcmpi(modalityType, 'smri'))
                    if (~doGrandMeanPCA)
                        msg_string = ['--Doing pca on Subject #', num2str(subNum), ' Session #', num2str(ses)];
                    else
                        msg_string = ['-- Projecting Subject #', num2str(subNum), ' Session #', num2str(ses), ' to the eigen space of the mean of data-sets'];
                    end
                else
                    msg_string = 'Doing pca';
                end
                clear subNum ses;
                
                disp(msg_string);
                
                %% Load data
                data = preprocData(sesInfo.inputFiles(i).name, mask_ind, preproc_type, pca_opts.precision);
                
                %% Project data on to the eigen space of the mean data
                if (doGrandMeanPCA)
                    data = data*VM;
                end
                
                if (conserve_disk_space ~= 1)
                    varsToSave = {'pcasig', 'dewhiteM', 'whiteM', 'Lambda', 'V'};
                else
                    varsToSave = {'V', 'Lambda'};
                end
                
                if (strcmpi(pcaType, 'standard'))
                    
                    if (conserve_disk_space ~= 1)
                        % Calculate pca step
                        [pcasig, dewhiteM, Lambda, V, whiteM] = icatb_calculate_pca(data, numOfPC, 'remove_mean', 0);
                    else
                        [V, Lambda] = icatb_v_pca(data, 1, numOfPC, 0, 'untranspose', 'no');
                    end
                    
                else
                    if (strcmpi(pcaType, 'svd'))
                        [V, Lambda] = icatb_svd(data, numOfPC, 'solver', 'all');
                    else
                        [V, Lambda, C] = icatb_calculate_em_pca(data, rand(numOfPC, size(data, 2)), 'max_iter', max_iter, 'tolerance', tol, 'verbose', 1);
                        if (conserve_disk_space ~= 1)
                            varsToSave{end + 1} = 'C';
                        end
                    end
                    
                    if (conserve_disk_space ~= 1)
                        [whiteM, dewhiteM] = get_pca_info(V, Lambda);
                        pcasig = data*whiteM';
                    end
                end
                
                checkEig(Lambda);
                
                %% Apply the transformations to Eigen vectors, dewhitening
                % and whitening matrices
                if (doGrandMeanPCA)
                    V = VM*V;
                    if (exist('dewhiteM', 'var'))
                        dewhiteM = VM*dewhiteM;
                        whiteM = pinv(dewhiteM);
                    end
                end
                
                %% Save PCA vars
                clear data;
                drawnow;
                
                if (conserve_disk_space == 1)
                    Lambda = diag(Lambda);
                    Lambda = Lambda(:)';
                    if (i > 1)
                        info = load(pcaout, 'V', 'Lambda');
                        info.V = info.V(1:sum(sesInfo.diffTimePoints(1:i-1)), :);
                        info.Lambda = info.Lambda(1:i-1, :);
                        V = [info.V; V];
                        Lambda = [info.Lambda; Lambda];
                        clear info;
                    end
                end
                
                icatb_save(pcaout, varsToSave{:});
                clear pcasig dewhiteM whiteM Lambda V C;
                
            else
                
                if (i ~= 1)
                    count = sum(sesInfo.reduction(j).numOfPrevGroupsInEachNewGroupAfterCAT(1:i-1)) + 1;
                else
                    count = 1;
                end
                
                numInNewGroup = sesInfo.reduction(j).numOfPrevGroupsInEachNewGroupAfterCAT(i);
                
                % Load whitening matrix
                load(pcaout, 'whiteM');
                whiteM = whiteM';
                
                if (strcmpi(pca_opts.precision, 'double'))
                    % Initialise PCA
                    pcasig = zeros(numVoxels, sesInfo.reduction(j).numOfPCAfterReduction);
                else
                    pcasig = zeros(numVoxels, sesInfo.reduction(j).numOfPCAfterReduction, 'single');
                end
                
                endTp = 0;
                %% Loop over files
                for nRows = 1:numInNewGroup
                    
                    % PCA information
                    pcain = [sesInfo.data_reduction_mat_file, num2str(j - 1), '-', num2str(count + (nRows - 1)), '.mat'];
                    pcinfo = load(fullfile(outputDir, pcain), 'pcasig');
                    
                    startTp = endTp + 1;
                    endTp = endTp + sesInfo.reduction(j).numOfPCBeforeCAT;
                    
                    pcasig = pcasig + (pcinfo.pcasig*whiteM(startTp:endTp, :));
                    
                    clear pcinfo;
                    
                    %count = count + 1;
                    
                end
                %% End of loop over files
                
                %% Save PCA vars
                drawnow;
                icatb_save(pcaout, 'pcasig', '-append');
                
            end
            
            drawnow;
            
        end
        %% End of loop over groups after concatenation
        
    end
    
    if ~isempty(statusHandle)
        % get the status handles
        statusData = getappdata(statusHandle, appDataName);
        statusData.perCompleted = statusData.perCompleted + (statusData.unitPerCompleted / length(reductionStepsToRun));
        setappdata(statusHandle, appDataName, statusData);
        set(statusHandle, 'name', [num2str(round(statusData.perCompleted*100)), '% analysis done']);
        waitbar(statusData.perCompleted, statusHandle);
        
    end
    
    
    disp(['Done with data reduction( time # ', num2str(j),')' ]);
    disp(' ');
    
end
%% End of loop over data reductions

%% Save parameter file
[pp, fileName] = fileparts(sesInfo.userInput.param_file);
drawnow;
icatb_save(fullfile(outputDir, [fileName, '.mat']), 'sesInfo');

disp('------------------------------------------------------------------------------------');
disp('ENDING DATA REDUCTION (PRINCIPAL COMPONENTS ANALYSIS)');
disp('------------------------------------------------------------------------------------');

if ~isempty(statusHandle)
    % get the status handles
    statusData = getappdata(statusHandle, appDataName);
    statusData.perCompleted = statusData.perCompleted + statusData.unitPerCompleted;
    setappdata(statusHandle, appDataName, statusData);
    set(statusHandle, 'name', [num2str(round(statusData.perCompleted*100)), '% analysis done']); waitbar(statusData.perCompleted, statusHandle);
    
end

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


function C = norm2(C)
%% Normalize transformation matrix using slower way
%

for nC = 1:size(C, 1)
    C(nC, :) =  C(nC, :) ./ norm(C(nC, :), 2);
end

function residual_err = norm_resid(C, C_old)
%% Use norm2 of residual error
%

residual_err = 0;
for nC = 1:size(C, 1)
    res = C(nC, :) - C_old(nC, :);
    residual_err = residual_err + sum(res.^2);
end

residual_err = sqrt(residual_err);



function pca_opts = getPCAOpts(sesInfo)
%% Get PCA opts
%

isOptsCell = 0;
try
    isOptsCell = iscell(sesInfo.pca_opts);
catch
end

if (~isOptsCell)
    
    if (isfield(sesInfo, 'pca_opts'))
        tmp_pca_opts = sesInfo.pca_opts;
    end
    
    %% Group PCA Options
    pcaType = 'standard';
    if (isfield(sesInfo, 'pcaType'))
        pcaType = sesInfo.pcaType;
    end
    
    sesInfo.pcaType = pcaType;
    sesInfo = icatb_check_pca_opts(sesInfo);
    pcaType = sesInfo.pcaType;
    tmp_pca_opts = sesInfo.pca_opts;
    
    pca_opts{1} = struct('pcaType', pcaType, 'pca_opts', tmp_pca_opts);
    
else
    
    pca_opts = sesInfo.pca_opts;
    for nP = 1:length(pca_opts)
        pca_opts{nP} = icatb_check_pca_opts(pca_opts{nP});
    end
    
end

if (length(pca_opts) ~= sesInfo.numReductionSteps)
    pca_opts = repmat(pca_opts(1), 1, sesInfo.numReductionSteps);
end


function conserve_disk_space = getConserveDiskSpaceInfo(sesInfo, gpca_opts)

conserve_disk_space = 0;

% Write eigen vectors for 2 data reductions with stack data set to on
if (sesInfo.numReductionSteps == 2)
    stackData = 'yes';
    try
        stackData = gpca_opts{2}.pca_opts.stack_data;
    catch
    end
    
    if (strcmpi(gpca_opts{2}.pcaType, 'svd'))
        stackData = 'yes';
    end
    
    if (isfield(sesInfo, 'conserve_disk_space') && strcmpi(stackData, 'yes'))
        conserve_disk_space = sesInfo.conserve_disk_space;
    end
end


function data = preprocData(fileN, mask_ind, preProcType, precisionType)

% Load data
data = icatb_read_data(fileN, [], mask_ind, precisionType);

% Call pre-processing function
data = icatb_preproc_data(data, preProcType);

if (~strcmpi(preProcType, 'remove mean per timepoint'))
    % Remove mean per timepoint
    data = icatb_remove_mean(data, 1);
end

function VM = grandMeanPCA(sesInfo, preProcType, precisionType)
%% Compute grand mean
%

disp('Computing mean of data-sets ...');

meanData = zeros(length(sesInfo.mask_ind), min(sesInfo.diffTimePoints));

for nD = 1:length(sesInfo.inputFiles)
    subNum = ceil(nD/sesInfo.numOfSess);
    ses = mod(nD-1, sesInfo.numOfSess) + 1;
    disp(['Loading Subject #', num2str(subNum), ' Session #', num2str(ses)]);
    tmp = preprocData(sesInfo.inputFiles(nD).name, sesInfo.mask_ind, preProcType, precisionType);
    meanData = meanData + tmp(:, 1:size(meanData, 2));
    clear tmp;
end

meanData = meanData/length(sesInfo.inputFiles);

disp('Done');

fprintf('\n');

disp('Calculating PCA on mean of data-sets ...');

[VM, LambdaM] = icatb_v_pca(meanData, 1, sesInfo.reduction(1).numOfPCAfterReduction, 0, 'untranspose', 'no');

checkEig(LambdaM);

pcaFile = fullfile(sesInfo.outputDir, [sesInfo.data_reduction_mat_file, 'mean.mat']);

icatb_save(pcaFile, 'LambdaM', 'VM');

fprintf('Done\n');


function checkEig(Lambda)

if (numel(Lambda) ~= length(Lambda))
    Lambda = diag(Lambda);
end

L = length(find(Lambda <= eps));

if (L > 1)
    error([num2str(L), ' eigen values are less than or equal to machine precision']);
elseif (L == 1)
    error('One of the eigen values is less than or equal to machine precision');
end
