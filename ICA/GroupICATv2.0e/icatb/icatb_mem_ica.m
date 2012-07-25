function varargout = icatb_mem_ica(sesInfo)
%% Calculate memory required for computing ICA.
%

precisionType = 'single';

%% Input parameters
voxels = 70000;
% Time points
time_points = 300;
% Number of subjects
numOfSub = 100;
% Number of sessions
numOfSess = 1;
% Data reduction steps
numDataReductionSteps = 2;
% Data reduction step numbers
numOfPC1 = 50;
numOfPC2 = 30;
numOfPC3 = 25;

%% End for input parameters



dispInfo = 1;
if (nargout > 0)
    dispInfo = 0;
end

%% Get info from session info
if (exist('sesInfo', 'var'))
    
    
    try
        voxels = length(sesInfo.userInput.mask_ind);
    catch
        dat = icatb_loadData(deblank(sesInfo.userInput.files(1).name(1, :)));
        voxels = size(dat, 1)*size(dat, 2)*size(dat, 3);
        clear dat;
    end
    
    modalityType = icatb_get_modality;
    
    if (~isfield(sesInfo.userInput, 'diffTimePoints'))
        if strcmpi(modalityType, 'fmri')
            % get the count for time points
            sesInfo.userInput.diffTimePoints = icatb_get_countTimePoints(sesInfo.userInput.files);
        else
            sesInfo.userInput.diffTimePoints = icatb_get_num_electrodes(sesInfo.userInput.files);
        end
    end
    
    time_points = max(sesInfo.userInput.diffTimePoints);
    numOfSub = sesInfo.userInput.numOfSub;
    numOfSess = sesInfo.userInput.numOfSess;
    numDataReductionSteps = sesInfo.userInput.numReductionSteps;
    numOfPC1 = sesInfo.userInput.numOfPC1;
    numOfPC2 = sesInfo.userInput.numOfPC2;
    numOfPC3 = sesInfo.userInput.numOfPC3;
    
    try
        precisionType = sesInfo.userInput.pca_opts.precision;
    catch
        try
            precisionType = sesInfo.userInput.covariance_opts.precision;
        catch
        end
    end
    
end


% Check for data reduction steps
if (numOfSub*numOfSess > 1 && numOfSub*numOfSess < 4)
    numDataReductionSteps = 2;
end

if (numOfSub*numOfSess == 1)
    numDataReductionSteps = 1;
end

if (numDataReductionSteps > 3)
    numDataReductionSteps = 3;
end
% End for checking

if (dispInfo)
    
    disp(['Number of voxels: ', num2str(voxels)]);
    disp(['Number of timepoints: ', num2str(time_points)]);
    disp(['Number of subjects: ', num2str(numOfSub)]);
    disp(['Number of sessions: ', num2str(numOfSess)]);
    disp(['Number of data reduction steps: ', num2str(numDataReductionSteps)]);
    
end

% Matlab version
matlab_version = icatb_get_matlab_version;
OSBIT = mexext;

precisionType = icatb_checkPrecision(precisionType, dispInfo);

minNumBytesVar = 8;
if strcmpi(precisionType, 'single')
    minNumBytesVar = 4;
end

if (dispInfo)
    
    disp(['Number of PC1: ', num2str(numOfPC1)]);
    if (numDataReductionSteps == 2)
        disp(['Number of PC2: ', num2str(numOfPC2)]);
    elseif (numDataReductionSteps == 3)
        disp(['Number of PC2: ', num2str(numOfPC2)]);
        disp(['Number of PC3: ', num2str(numOfPC3)]);
    end
    
end

analysisTypes = {'Standard', 'Expectation Maximization'};
stack_data = {'yes', 'no'};
storages = {'full', 'packed'};

countA = 0;

initial_num_bytes = [(voxels*time_points*2 + time_points^2), (voxels*time_points + voxels*numOfPC1 + numOfPC1*numOfPC1 + numOfPC1*time_points)];


if (numDataReductionSteps == 2)
    
    tmp_datasets = numOfSub*numOfSess*numOfPC1;
    % Covariance storage (full)
    cov_bytes = tmp_datasets^2;
    cov_bytes_packed = tmp_datasets*(tmp_datasets + 1)/2;
    % Stacked data
    stacked_data_bytes = tmp_datasets*voxels*2;
    
    em_pca_unstacked = voxels*numOfPC1 + voxels*numOfPC2 + numOfPC2*numOfPC2 + numOfPC2*tmp_datasets;
    
elseif (numDataReductionSteps == 3)
    
    numGroups2 = ceil(numOfSub*numOfSess/4);
    
    tmp_datasets = 4*numOfPC1;
    
    % PC2
    % Covariance storage
    cov_bytes = tmp_datasets^2;
    cov_bytes_packed = tmp_datasets*(tmp_datasets + 1)/2;
    % Stacked data
    stacked_data_bytes = tmp_datasets*voxels*2;
    
    em_pca_unstacked = voxels*numOfPC1 + voxels*numOfPC2 + numOfPC2*numOfPC2 + numOfPC2*tmp_datasets;
    
    % PC3
    tmp_datasets = numGroups2*numOfPC2;
    % Covariance storage
    cov_bytes = max([cov_bytes, (tmp_datasets^2)]);
    cov_bytes_packed = max([cov_bytes_packed, (tmp_datasets*(tmp_datasets + 1)/2)]);
    % Stacked data
    stacked_data_bytes = max([stacked_data_bytes, tmp_datasets*voxels*2]);
    
    em_pca_unstacked = max([em_pca_unstacked, voxels*numOfPC2 + voxels*numOfPC3 + numOfPC3*numOfPC3 + numOfPC3*tmp_datasets]);
    
end


if (nargout > 0)
    pca_opts = repmat(struct('pca_type', 'standard', 'stack_data', 'yes', 'storage', 'full', 'precision', precisionType, 'max_mem', []), 1, ...
        length(analysisTypes)*length(stack_data)*2);
end

if (dispInfo)
    fprintf('\n');
end

if (numDataReductionSteps >= 2)
    
    % Loop over analysis types
    for nA = 1:length(analysisTypes)
        
        % Loop over data-sets storage
        for nT = 1:length(stack_data)
            
            if (strcmpi(analysisTypes{nA}, 'standard'))
                % Standard
                if (strcmpi(stack_data{nT}, 'yes'))
                    tmp_storages = {'full'};
                else
                    tmp_storages = storages;
                end
                
                % Loop over storages
                for nF = 1:length(tmp_storages)
                    
                    countA = countA + 1;
                    
                    num_bytes = initial_num_bytes(nA);
                    
                    if (dispInfo)
                        disp(['Analysis Type ', num2str(countA), ':']);
                        fprintf('\n');
                    end
                    
                    if strcmpi(tmp_storages{nF}, 'full') && strcmpi(stack_data{nT}, 'yes')
                        % Full storage
                        num_bytes = max([num_bytes, stacked_data_bytes + cov_bytes]);
                        
                    else
                        if strcmpi(tmp_storages{nF}, 'full')
                            % Full storage
                            num_bytes = max([num_bytes, cov_bytes]);
                        else
                            % Packed storage
                            num_bytes = max([num_bytes, cov_bytes_packed]);
                        end
                        
                    end
                    
                    memory_GB = (num_bytes*minNumBytesVar)/1024/1024/1024;
                    
                    if (dispInfo)
                        disp(['PCA Type: ', analysisTypes{nA}, ', Stack datasets: ', stack_data{nT}, ', Precision: ', precisionType, ', Covariance Storage: ', storages{nF}]);
                        disp(['Approximate memory required for the analysis is ', num2str(memory_GB), ' GB']);
                        if (strcmpi(stack_data{nT}, 'no'))
                            disp('Slower method to compute PCA. May take days to solve the problem depending on subjects, sessions and components.');
                        end
                        fprintf('\n');
                    else
                        pca_opts(countA).pca_type = analysisTypes{nA};
                        pca_opts(countA).stack_data = stack_data{nT};
                        pca_opts(countA).storage = storages{nF};
                        pca_opts(countA).max_mem = memory_GB;
                    end
                    
                end
                % End of loop over storages
                
            else
                % EM PCA
                num_bytes = initial_num_bytes(nA);
                countA = countA + 1;
                
                if (dispInfo)
                    disp(['Analysis Type ', num2str(countA),  ':']);
                    fprintf('\n');
                end
                
                if strcmpi(stack_data{nT}, 'yes')
                    % Stacked
                    num_bytes = max([num_bytes, stacked_data_bytes/2]);
                    
                else
                    % Unstacked
                    num_bytes = max([num_bytes, em_pca_unstacked]);
                    
                end
                
                memory_GB = (num_bytes * minNumBytesVar) /1024/1024/1024;
                
                if (dispInfo)
                    disp(['PCA Type: ', analysisTypes{nA}, ', Stack datasets: ', stack_data{nT}, ', Precision: ', precisionType]);
                    disp(['Approximate memory required for the analysis is ', num2str(memory_GB), ' GB']);
                    if (strcmpi(stack_data{nT}, 'no'))
                        disp('Slower method to compute PCA. May take days to solve the problem depending on subjects, sessions and components.');
                    end
                    fprintf('\n');
                else
                    pca_opts(countA).pca_type = analysisTypes{nA};
                    pca_opts(countA).stack_data = stack_data{nT};
                    pca_opts(countA).max_mem = memory_GB;
                end
                
            end
            
        end
        % End of loop over data-sets storage
    end
    % End of loop over analysis types
    
else
    
    countA = 0;
    % Loop over analysis types
    for nA = 1:length(analysisTypes)
        
        countA = countA + 1;
        
        if (dispInfo)
            disp(['Analysis Type ', num2str(nA),  ':']);
            fprintf('\n');
        end
        
        num_bytes = initial_num_bytes(nA);
        memory_GB = (num_bytes * minNumBytesVar) /1024/1024/1024;
        
        if (dispInfo)
            disp(['PCA Type: ', analysisTypes{nA}, ', Precision: ', precisionType]);
            disp(['Approximate memory required for the analysis is ', num2str(memory_GB), ' GB']);
            fprintf('\n');
        else
            pca_opts(countA).pca_type = analysisTypes{nA};
            pca_opts(countA).max_mem = memory_GB;
        end
        
    end
    % End of loop over analysis types
    
    
end

if (nargout > 0)
    pca_opts = pca_opts(1:countA);
    varargout{1} = pca_opts;
end