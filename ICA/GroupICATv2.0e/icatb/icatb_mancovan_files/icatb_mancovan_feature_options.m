function input_parameters = icatb_mancovan_feature_options(varargin)
%% Feature selection options
%

icatb_defaults;
global DETRENDNUMBER;

TR = 1;
dims = [];

for i = 1:2:length(varargin)
    if (strcmpi(varargin{i}, 'tr'))
        TR = varargin{i + 1};
    elseif (strcmpi(varargin{i}, 'mask_dims'))
        dims = varargin{i + 1};
    end
end


% List includes Spatial Maps, Timecourses spectra,

%%%%%%%%% Input Parameters Structure
numParameters = 1;
inputParameters(numParameters).listString = 'Spatial Maps';
optionNumber = 1;
% Option 1 of parameter 1
options(optionNumber).promptString = 'Type Of Mask?';
options(optionNumber).answerString = char('Default', 'User specified');
options(optionNumber).uiType = 'popup'; options(optionNumber).value = 1;
options(optionNumber).tag = 'sm_mask'; options(optionNumber).answerType = 'string';
options(optionNumber).flag = 'delete';
options(optionNumber).callback = {@selectMaskCallback, struct('type', 'mask', 'dims', dims)};
options(optionNumber).uiPos = [];
options(optionNumber).enable = [];

optionNumber = optionNumber + 1;
% Option 2 of parameter 1
options(optionNumber).promptString = 'Center spatial maps?';
options(optionNumber).answerString = char('Yes', 'No');
options(optionNumber).uiType = 'popup'; options(optionNumber).value = 1;
options(optionNumber).tag = 'sm_center'; options(optionNumber).answerType = 'string';
options(optionNumber).flag = 'delete';
options(optionNumber).uiPos = [0.12 0.045];
inputParameters(numParameters).options = options; % will be used in plotting the controls in a frame

optionNumber = optionNumber + 1;
% Option 3 of parameter 1
options(optionNumber).promptString = 'Statistic for thresholding';
options(optionNumber).answerString = char('T', 'Z');
options(optionNumber).uiType = 'popup'; options(optionNumber).value = 1;
options(optionNumber).tag = 'stat_threshold_maps'; options(optionNumber).answerType = 'string';
options(optionNumber).flag = 'delete';
options(optionNumber).uiPos = [0.12 0.045];
options(optionNumber).callback = @selectStatCallback;
inputParameters(numParameters).options = options; % will be used in plotting the controls in a frame

optionNumber = optionNumber + 1;
% Option 4 of parameter 1
options(optionNumber).promptString = 'Select Z Threshold';
options(optionNumber).answerString = '1.0';
options(optionNumber).uiType = 'edit'; options(optionNumber).value = 1;
options(optionNumber).tag = 'z_threshold_maps'; options(optionNumber).answerType = 'numeric';
options(optionNumber).flag = 'delete';
options(optionNumber).uiPos = [0.12 0.045];
options(optionNumber).enable = 'inactive';
inputParameters(numParameters).options = options; % will be used in plotting the controls in a frame
clear options;

numParameters = numParameters + 1; % second parameter
inputParameters(numParameters).listString = 'Timecourses Spectra';
optionNumber = 1;
% Option 1 of parameter 2
options(optionNumber).promptString = 'TC Detrend number';
options(optionNumber).answerString = str2mat('0', '1', '2', '3');
matchedIndex = strmatch(num2str(DETRENDNUMBER), options(optionNumber).answerString, 'exact');
options(optionNumber).uiType = 'popup'; options(optionNumber).value = matchedIndex;
options(optionNumber).tag = 'spectra_detrend'; options(optionNumber).answerType = 'numeric';
options(optionNumber).flag = 'delete';
options(optionNumber).uiPos = [0.12 0.045];

optionNumber = optionNumber + 1;
% Option 2 of parameter 2
options(optionNumber).promptString = 'Tapers from dpss';
options(optionNumber).answerString = '3, 5';
options(optionNumber).uiType = 'edit'; options(optionNumber).value = 0;
options(optionNumber).tag = 'spectra_tapers'; options(optionNumber).answerType = 'numeric';
options(optionNumber).flag = 'delete';
options(optionNumber).uiPos = [0.16 0.045];

optionNumber = optionNumber + 1;
% Option 2 of parameter 2
options(optionNumber).promptString = 'Sampling Frequency';
options(optionNumber).answerString = num2str(1/TR);
options(optionNumber).uiType = 'edit'; options(optionNumber).value = 1;
options(optionNumber).tag = 'spectra_sampling_freq'; options(optionNumber).answerType = 'numeric';
options(optionNumber).flag = 'delete';
options(optionNumber).uiPos = [0.16 0.045];

optionNumber = optionNumber + 1;
% Option 3 of parameter 2
options(optionNumber).promptString = 'Frequency band';
options(optionNumber).answerString = num2str([0.0, 1/(2*TR)]);
options(optionNumber).uiType = 'edit'; options(optionNumber).value = 0;
options(optionNumber).tag = 'spectra_freq_band'; options(optionNumber).answerType = 'numeric';
options(optionNumber).flag = 'delete';
options(optionNumber).uiPos = [0.16 0.045];

optionNumber = optionNumber + 1;

options(optionNumber).promptString = 'Use Fractional Amplitude?';
options(optionNumber).answerString = char('Yes', 'No');
options(optionNumber).uiType = 'popup'; options(optionNumber).value = 1;
options(optionNumber).tag = 'spectra_normalize_subs'; options(optionNumber).answerType = 'string';
options(optionNumber).flag = 'delete';
options(optionNumber).uiPos = [0.12 0.045];

optionNumber = optionNumber + 1;

options(optionNumber).promptString = 'Log transform spectra?';
options(optionNumber).answerString = char('Yes', 'No');
options(optionNumber).uiType = 'popup'; options(optionNumber).value = 1;
options(optionNumber).tag = 'spectra_transform'; options(optionNumber).answerType = 'string';
options(optionNumber).flag = 'delete';
options(optionNumber).uiPos = [0.12 0.045];


inputParameters(numParameters).options = options; % will be used in plotting the controls in a frame
clear options;

numParameters = numParameters + 1; % Third parameter
inputParameters(numParameters).listString = 'FNC Correlations';
optionNumber = 1;
% Option 1 of parameter 3
options(optionNumber).promptString = 'Detrend number';
options(optionNumber).answerString = str2mat('0', '1', '2', '3');
matchedIndex = strmatch(num2str(DETRENDNUMBER), options(optionNumber).answerString, 'exact');
options(optionNumber).uiType = 'popup'; options(optionNumber).value = matchedIndex;
options(optionNumber).tag = 'fnc_tc_detrend'; options(optionNumber).answerType = 'numeric';
options(optionNumber).flag = 'delete';
options(optionNumber).uiPos = [0.12 0.045];

optionNumber = optionNumber + 1;
% Option 2 of parameter 3
options(optionNumber).promptString = 'Despike Timecourses?';
options(optionNumber).answerString = char('Yes', 'No');
options(optionNumber).uiType = 'popup'; options(optionNumber).value = 1;
options(optionNumber).tag = 'fnc_tc_despike'; options(optionNumber).answerType = 'string';
options(optionNumber).flag = 'delete';
options(optionNumber).uiPos = [0.12 0.045];

optionNumber = optionNumber + 1;
% Option 2 of parameter 3
options(optionNumber).promptString = 'Filter Timecourses?';
options(optionNumber).answerString = char('Yes', 'No');
options(optionNumber).uiType = 'popup'; options(optionNumber).value = 1;
options(optionNumber).tag = 'fnc_tc_filter'; options(optionNumber).answerType = 'string';
options(optionNumber).flag = 'delete';
options(optionNumber).uiPos = [0.12 0.045];

inputParameters(numParameters).options = options; % will be used in plotting the controls in a frame
clear options;

% store the input parameters in two fields
input_parameters.inputParameters = inputParameters;
input_parameters.defaults = inputParameters;

function selectMaskCallback(hObject, event_data, info)
% Select mask callback

gVal = get(hObject, 'value');
gStr = cellstr(get(hObject, 'string'));

hh = gcbf;
ho = findobj(hh, 'tag', ['answer', 'stat_threshold_maps']);
threshH = findobj(hh, 'tag', ['answer', 'z_threshold_maps']);

selectedval = get(ho, 'value');
strs = cellstr(get(ho, 'string'));
selectedStr = deblank(strs{selectedval});

if (strcmpi(gStr{gVal}, 'default'))
    set(threshH, 'enable', 'on');
    if (strcmpi(selectedStr, 't'))
        set(threshH, 'enable', 'inactive');
    end
    set(ho, 'enable', 'on');
    return;
end

set(threshH, 'enable', 'inactive');
set(ho, 'enable', 'off');

dims = info.dims;
mask = icatb_selectEntry('typeEntity', 'file', 'typeSelection', 'multiple', 'filter', '*.img;*.nii', 'filetype', 'image', 'title', ...
    ['Select mask of dimensions (', num2str(dims), ')']);
drawnow;

if (isempty(mask))
    set(hObject, 'value', 1);
    set(threshH, 'enable', 'on');
    if (strcmpi(selectedStr, 't'))
        set(threshH, 'enable', 'inactive');
    end
    set(ho, 'enable', 'on');
    return;
end

data = icatb_loadData(mask); % Mask data
size_data = size(data);
if length(size_data) == 2
    size_data(3) = 1;
end

%% Check the dimensions of the mask w.r.t data
if length(find(size_data == dims)) ~= length(dims)
    msg = sprintf('Mask dimensions ([%s]) doesn''t match that of data dimensions ([%s])', num2str(size_data), num2str(dims));
    disp(msg);
    disp('');
    icatb_errorDialog(msg, 'Mask Error', 'Modal');
    set(hObject, 'value', 1);
    set(threshH, 'enable', 'on');
    set(ho, 'enable', 'on');
    return;
end

set(hObject, 'userdata', deblank(mask));

function selectStatCallback(hObject, event_data, handles)
% Select Stat
%

hh = gcbf;
ho = findobj(hh, 'tag', ['answer', 'stat_threshold_maps']);
val = get(ho, 'value');
strs = cellstr(get(ho, 'string'));
selectedStr = deblank(strs{val});
threshH = findobj(hh, 'tag', ['answer', 'z_threshold_maps']);
set(threshH, 'enable', 'inactive');
if (strcmpi(selectedStr, 'z'))
    set(threshH, 'enable', 'on');
end
