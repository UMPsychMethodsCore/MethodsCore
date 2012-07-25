function icatb_component_viewer(paramFile, varargin)
%% Spectral viewer tool
%


icatb_defaults;
global DETRENDNUMBER;
global PARAMETER_INFO_MAT_FILE;

filterP = ['*', PARAMETER_INFO_MAT_FILE, '*.mat'];

if (~exist('paramFile', 'var'))
    paramFile = icatb_selectEntry('typeEntity', 'file', 'title', 'Select ICA parameter file', 'filter', filterP, 'typeselection', 'single');
end

load(paramFile);

if (~exist('sesInfo', 'var'))
    error('Selected file is not a valid parameter file');
end

for i = 1:2:length(varargin)
    if (strcmpi(varargin{i}, 'tr'))
        TR = varargin{i + 1};
    elseif (strcmpi(varargin{i}, 'comps'))
        compNumbers = varargin{i + 1};
    elseif (strcmpi(varargin{i}, 'detrend_no'))
        detrendNumber = varargin{i + 1};
    elseif (strcmpi(varargin{i}, 'image_values'))
        image_values = varargin{i + 1};
    elseif (strcmpi(varargin{i}, 'convert_to_zscores'))
        convert_to_zscores = varargin{i + 1};
    elseif (strcmpi(varargin{i}, 'threshold'))
        threshold = varargin{i + 1};
    elseif (strcmpi(varargin{i}, 'anatomical_file'))
        anatomical_file = varargin{i + 1};
    end
end

outputDir = fileparts(paramFile);
if (isempty(outputDir))
    outputDir = pwd;
end

if (~exist('detrendNumber', 'var'))
    detrendNumber = DETRENDNUMBER;
end

%% Select anatomical file
if (~exist('anatomical_file', 'var'))
    anatomical_file = icatb_selectEntry('typeEntity', 'file', 'title', 'Select Structural Image', 'filter', '*.img;*.nii', ...
        'typeselection', 'single', 'fileType', 'image', 'filenumbers', 1);
end

[startPath, f_name, extn] = fileparts(icatb_parseExtn(anatomical_file));

% check the image extension
if ~strcmpi(extn, '.nii') & ~strcmpi(extn, '.img')
    error('Structural image should be in NIFTI or Analyze format');
end

%% Select components
listStr = num2str((1:sesInfo.numComp)');

if ~exist('compNumbers', 'var')
    title_fig = 'Select component/components';
    compNumbers = icatb_listdlg('PromptString', title_fig, 'SelectionMode', 'multiple', 'ListString', listStr, ...
        'movegui', 'center', 'windowStyle', 'modal', 'title_fig', title_fig);
end

compNumbers = compNumbers(:)';

if (isempty(compNumbers))
    error('Component/Components are selected');
end

if (max(compNumbers) > sesInfo.numComp)
    error('Max value of component numbers selected exceed the no. of components');
end


%% Select component parameters
numParameters = 1;

if (~exist('image_values', 'var'))
    opts = char('Positive', 'Positive and Negative', 'Absolute Value', 'Negative');
    inputText(numParameters).promptString = 'Select image values';
    inputText(numParameters).uiType = 'popup';
    inputText(numParameters).answerString = opts;
    inputText(numParameters).dataType = 'string';
    inputText(numParameters).tag = 'image_values';
    inputText(numParameters).enable = 'on';
end

if (~exist('convert_to_zscores', 'var'))
    numParameters = numParameters + 1;
    inputText(numParameters).promptString = 'Do you want to convert to z-scores?';
    inputText(numParameters).uiType = 'popup';
    inputText(numParameters).answerString = char('Yes', 'No');
    inputText(numParameters).dataType = 'string';
    inputText(numParameters).tag = 'convert_to_zscores';
    inputText(numParameters).enable = 'on';
end

if (~exist('threshold', 'var'))
    numParameters = numParameters + 1;
    inputText(numParameters).promptString = 'Enter threshold';
    inputText(numParameters).uiType = 'edit';
    inputText(numParameters).answerString = '1';
    inputText(numParameters).dataType = 'numeric';
    inputText(numParameters).tag = 'threshold';
    inputText(numParameters).enable = 'on';
end

if (~exist('TR', 'var'))
    numParameters = numParameters + 1;
    inputText(numParameters).promptString = 'Enter TR in seconds';
    inputText(numParameters).uiType = 'edit';
    inputText(numParameters).answerString = '1';
    inputText(numParameters).dataType = 'numeric';
    inputText(numParameters).tag = 'TR';
    inputText(numParameters).enable = 'on';
end


if (exist('inputText', 'var'))
    answers = icatb_inputDialog('inputtext', inputText, 'Title', 'Component Parameters', 'handle_visibility',  'on', 'windowStyle', 'modal');
    if (isempty(answers))
        error('Component parameters are not selected');
    end
    for nA = 1:length(answers)
        val = answers{nA};
        eval([inputText(nA).tag, '=val;']);
    end
end

%% Compute spectra
disp('Loading subject timecourses ...');
timecourses = icatb_loadComp(sesInfo, compNumbers, 'vars_to_load', 'tc', 'average_runs', 1, 'detrend_no', detrendNumber);
timecourses = reshape(timecourses, sesInfo.numOfSub, min(sesInfo.diffTimePoints), length(compNumbers));

%% Uncompress component files
compFiles = sesInfo.icaOutputFiles(1).ses(1).name;

zipFileName = {};
currentFile = deblank(compFiles(1, :));
if ~exist(currentFile, 'file')
    [zipFileName, files_in_zip] = icatb_getViewingSet_zip(currentFile, [], 'real', sesInfo.zipContents);
    if (~isempty(zipFileName))
        icatb_unzip(regexprep(zipFileName, ['.*\', filesep], ''), fullfile(outputDir, fileparts(currentFile)));
    end
end

if (~exist('anatomical_file', 'var'))
    anatomical_file = fullfile(outputDir, currentFile);
end

compFiles = icatb_fullFile('files', compFiles, 'directory', outputDir);
compFiles = icatb_rename_4d_file(compFiles);

%% Plot results
graphicsH = [];
count = 0;
dynamicrange = zeros(1, length(compNumbers));
fALFF = zeros(1, length(compNumbers));
for ncomp = compNumbers
    disp(['Plotting Component ', num2str(ncomp), ' ...']);
    count = count + 1;
    [tc, dynamicrange(count), fALFF(count)] = compute_spectra(squeeze(timecourses(:, :, count)), TR);
    if (count == 1)
        power_spectra = zeros(size(tc.data, 1), size(tc.data, 2), length(compNumbers));
    end
    power_spectra(:, :, count) = tc.data;
    freq = tc.xAxis;
    H = icatb_orth_views(deblank(compFiles(ncomp, :)), 'structfile', anatomical_file, 'image_values', image_values, 'convert_to_zscores', convert_to_zscores, 'threshold', threshold, 'set_to_max_voxel', 1, 'tc', tc, 'labels', ...
        ['Mean Component ', icatb_returnFileIndex(ncomp)], 'fig_title', 'Mean map and Spectra');
    graphicsH(length(graphicsH) + 1).H = H;
    fprintf('\n');
end

icatb_plotNextPreviousExitButtons(graphicsH);

%% Cleanup files
if (~isempty(zipFileName))
    icatb_delete_file_pattern(files_in_zip, outputDir);
end
fprintf('Done\n\n');

spectra_file = fullfile(outputDir, [sesInfo.userInput.prefix, '_spectra_results.mat']);
icatb_save(spectra_file, 'power_spectra', 'freq', 'dynamicrange', 'fALFF', 'compNumbers');

disp(['Power spectra results are saved in ', spectra_file]);
disp('The variables are as follows:');
disp('a. power_spectra - Power spectra of dimensions subjects x spectral length x components');
disp('b. freq - Frequency in HZ');
disp('c. dynamicrange - Mean dynamic range over subjects ');
disp('d. fALFF - Mean ratio of low frequency power to the high frequency power over subjects');
disp('e. compNumbers - Component numbers');
fprintf('\n');

function [tc, dynamicrange, fALFF] = compute_spectra(timecourses, TR)
%% Compute spectra

disp('Doing multi-taper spectral estimation ...');
[spectra_tc, freq] = icatb_get_spectra(timecourses, TR);
disp('Using fractional amplitude ...');
spectra_tc = spectra_tc./repmat(sum(spectra_tc,2), 1,size(spectra_tc, 2));
tc.data = spectra_tc;
tc.xAxis = freq;
tc.isSpectra = 1;
tc.xlabelStr = 'Frequency (Hz)';
tc.ylabelStr = 'Power';
dynamicrange = zeros(1, size(tc.data, 1));
fALFF = dynamicrange;
for nS = 1:size(tc.data, 1)
    [dynamicrange(nS), fALFF(nS)] = icatb_get_spec_stats(tc.data(nS, :), tc.xAxis);
end
dynamicrange = mean(dynamicrange);
fALFF = mean(fALFF);
tc.titleStr = sprintf('Dynamic range: %0.3f, Power_L_F/Power_H_F: %0.3f', mean(dynamicrange), mean(fALFF));