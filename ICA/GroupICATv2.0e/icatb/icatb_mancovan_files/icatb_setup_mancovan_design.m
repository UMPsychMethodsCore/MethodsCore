function icatb_setup_mancovan_design(param_file)
%% Create mancovan design
%
% Inputs:
% 1. param_file - ICA Parameter file or Mancovan parameter file
%

icatb_defaults;
global UI_FS;
global PARAMETER_INFO_MAT_FILE;

if (~exist('param_file', 'var'))
    param_file = icatb_selectEntry('title', 'Select ICA/Mancovan Parameter File', 'typeEntity', 'file', 'typeSelection', 'single', 'filter', ['*', PARAMETER_INFO_MAT_FILE, '.mat;*mancovan.mat']);
    drawnow;
    if (isempty(param_file))
        error('ICA parameter file is not selected');
    end
end


[inDir, paramF, extn] = fileparts(param_file);
if (isempty(inDir))
    inDir = pwd;
end

param_file = fullfile(inDir, [paramF, extn]);


load(param_file);

if (exist('sesInfo', 'var'))
    outputDir = icatb_selectEntry('typeEntity', 'directory', 'title', 'Select output directory to place mancovan results ...');
    drawnow;
    if (isempty(outputDir))
        error('Output directory is not selected');
    end
    mancovanInfo.userInput.ica_param_file = param_file;
    mancovanInfo.userInput.outputDir = outputDir;
    mancovanInfo.userInput.numOfSub = sesInfo.numOfSub;
    mancovanInfo.userInput.prefix = [sesInfo.userInput.prefix, '_mancovan'];
    compFiles = sesInfo.icaOutputFiles(1).ses(1).name;
    mancovanInfo.userInput.compFiles = icatb_rename_4d_file(icatb_fullFile('directory', inDir, 'files', compFiles));
    mancovanInfo.userInput.numICs = sesInfo.numComp;
    mancovanInfo.userInput.HInfo = sesInfo.HInfo.V(1);
elseif (exist('mancovanInfo', 'var'))
    outputDir = inDir;
    mancovanInfo.userInput.outputDir = outputDir;
else
    error('Selected file is neither ICA parameter file nor Mancovan parameter file');
end

drawnow;

if (exist(outputDir, 'dir') ~= 7)
    mkdir(outputDir);
end

cd(outputDir);

msg = 'Opening Setup Mancovan Design GUI ...';

disp(msg);

msgH = helpdlg(msg, 'Setup Mancovan Design');

drawnow;

if (mancovanInfo.userInput.numOfSub < 2)
    error('Cannot do stats for one subject');
end

clear sesInfo;

covNames = '';

if (~isfield(mancovanInfo.userInput, 'cov'))
    mancovanInfo.userInput.cov = [];
end

try
    covNames = (cellstr(char(mancovanInfo.userInput.cov.name)));
catch
end

%% Draw graphics
figureTag = 'setup_mancovan_gui';
figHandle = findobj('tag', figureTag);
if (~isempty(figHandle))
    delete(figHandle);
end

% Setup figure for GUI
InputHandle = icatb_getGraphics('Setup Mancovan Design', 'normal', figureTag, 'off');
set(InputHandle, 'menubar', 'none');
set(InputHandle, 'userdata', mancovanInfo);

controlWidth = 0.6;
promptHeight = 0.05;
promptWidth = controlWidth;
listboxHeight = controlWidth; listboxWidth = controlWidth;
xOffset = 0.02; yOffset = promptHeight; yPos = 0.9;
okWidth = 0.12; okHeight = promptHeight;

%% Features text and listbox
promptPos = [0.5 - 0.5*controlWidth, yPos - 0.5*yOffset, promptWidth, promptHeight];

textH = icatb_uicontrol('parent', InputHandle, 'units', 'normalized', 'style', 'text', 'position', promptPos, 'string', 'Add Covariates', 'tag', ...
    'prompt_covariates', 'fontsize', UI_FS - 1);
icatb_wrapStaticText(textH);
listboxXOrigin = promptPos(1);
listboxYOrigin = promptPos(2) - yOffset - listboxHeight;
listboxPos = [listboxXOrigin, listboxYOrigin, listboxWidth, listboxHeight];
icatb_uicontrol('parent', InputHandle, 'units', 'normalized', 'style', 'listbox', 'position', listboxPos, 'string', covNames, 'tag', ...
    'cov', 'fontsize', UI_FS - 1, 'min', 0, 'max', 1, 'value', 1,  'callback', {@addCov, InputHandle});

addButtonPos = [listboxPos(1) + listboxPos(3) + xOffset, listboxPos(2) + 0.5*listboxPos(4) + 0.5*promptHeight, promptHeight + 0.01, promptHeight - 0.01];
removeButtonPos = [listboxPos(1) + listboxPos(3) + xOffset, listboxPos(2) + 0.5*listboxPos(4) - 0.5*promptHeight, promptHeight + 0.01, promptHeight - 0.01];
icatb_uicontrol('parent', InputHandle, 'units', 'normalized', 'style', 'pushbutton', 'position', addButtonPos, 'string', '+', 'tag', 'add_cov_button', 'fontsize',...
    UI_FS - 1, 'callback', {@addCov, InputHandle});
icatb_uicontrol('parent', InputHandle, 'units', 'normalized', 'style', 'pushbutton', 'position', removeButtonPos, 'string', '-', 'tag', 'remove_cov_button', 'fontsize',...
    UI_FS - 1, 'callback', {@removeCov, InputHandle});


promptPos = listboxPos;

%% Add cancel, save and run buttons
cancelPos = [0.25 - 0.5*okWidth, promptPos(2) - yOffset - 0.5*okHeight, okWidth, okHeight];
cancelPos(2) = cancelPos(2) - 0.5*cancelPos(4);
icatb_uicontrol('parent', InputHandle, 'units', 'normalized', 'style', 'pushbutton', 'position', cancelPos, 'string', 'Cancel', 'tag', 'cancel_button', 'fontsize',...
    UI_FS - 1, 'callback', 'delete(gcbf);');

okPos = [0.75 - 0.5*okWidth, promptPos(2) - yOffset - 0.5*okHeight, okWidth, okHeight];
okPos(2) = okPos(2) - 0.5*okPos(4);
icatb_uicontrol('parent', InputHandle, 'units', 'normalized', 'style', 'pushbutton', 'position', okPos, 'string', 'Create', 'tag', 'create_button', 'fontsize',...
    UI_FS - 1, 'callback', {@create_design_matrix, InputHandle});

savePos = [0.5 - 0.5*okWidth, promptPos(2) - yOffset - 0.5*okHeight, okWidth, okHeight];
savePos(2) = savePos(2) - 0.5*savePos(4);
icatb_uicontrol('parent', InputHandle, 'units', 'normalized', 'style', 'pushbutton', 'position', savePos, 'string', 'Save', 'tag', 'save_button', 'fontsize',...
    UI_FS - 1, 'callback', {@saveCallback, InputHandle});

try
    delete(msgH);
catch
end

set(InputHandle, 'visible', 'on');
drawnow;


function addCov(hObject, event_data, figH)
%% Add Covariates
%

icatb_defaults;
global UI_FS;

figureTag = 'add_cov_mancovan';
covFigHandle = findobj('tag', figureTag);
if (~isempty(covFigHandle))
    delete(covFigHandle);
end

mancovanInfo = get(figH, 'userdata');

listH = findobj(figH, 'tag', 'cov');

covName = '';
transformationName = '';
covVals = '';
cov_type = 'continuous';
covTypes = {'Continuous', 'Categorical'};
covTypeVal = 1;

if (listH == hObject)
    if (~strcmpi(get(figH, 'selectionType'), 'open'))
        return;
    end
    val = get(listH, 'value');
    try
        covName = mancovanInfo.userInput.cov(val).name;
        covVals = mancovanInfo.userInput.cov(val).value;
        if (isnumeric(covVals))
            covVals = covVals(:);
            covVals = num2str(covVals);
        end
        covVals = cellstr(covVals);
        covVals = covVals(:)';
        transformationName = mancovanInfo.userInput.cov(val).transformation;
        cov_type = mancovanInfo.userInput.cov(val).type;
        covTypeVal = strmatch(lower(cov_type), lower(covTypes), 'exact');
    catch
    end
end

covFigHandle = icatb_getGraphics('Select Covariates', 'normal', figureTag);
set(covFigHandle, 'menubar', 'none');

promptWidth = 0.52; controlWidth = 0.32; promptHeight = 0.05;
xOffset = 0.02; yOffset = promptHeight; yPos = 0.9;
okWidth = 0.12; okHeight = promptHeight;

%% Covariate name and value
promptPos = [xOffset, yPos - 0.5*yOffset, promptWidth, promptHeight];
textH = icatb_uicontrol('parent', covFigHandle, 'units', 'normalized', 'style', 'text', 'position', promptPos, 'string', 'Enter Covariate Name', 'fontsize', UI_FS - 1);
icatb_wrapStaticText(textH);

promptPos = get(textH, 'position');

editPos = promptPos;
editPos(1) = editPos(1) + editPos(3) + xOffset;
editPos(3) = controlWidth;
editH = icatb_uicontrol('parent', covFigHandle, 'units', 'normalized', 'style', 'edit', 'position', editPos, 'string', covName, 'tag', 'cov_name', 'fontsize', UI_FS - 1);

%% Type of covariate (Continuous or categorical)
promptPos = [xOffset, editPos(2) - 0.5*promptHeight - yOffset, promptWidth, promptHeight];
textH = icatb_uicontrol('parent', covFigHandle, 'units', 'normalized', 'style', 'text', 'position', promptPos, 'string', 'Select Type Of Covariate', 'fontsize', UI_FS - 1);
icatb_wrapStaticText(textH);

promptPos = get(textH, 'position');

editPos = promptPos;
editPos(1) = editPos(1) + editPos(3) + xOffset;
editPos(3) = controlWidth;
covH = icatb_uicontrol('parent', covFigHandle, 'units', 'normalized', 'style', 'popup', 'position', editPos, 'string', {'Continuous', 'Categorical'}, 'tag', 'cov_type', 'fontsize', UI_FS - 1, 'value', covTypeVal);

promptPos(2) = promptPos(2) - 0.5*promptHeight - yOffset;
promptPos(1) = 0.5 - 0.5*promptWidth;
promptPos(3) = promptWidth;

textH = icatb_uicontrol('parent', covFigHandle, 'units', 'normalized', 'style', 'text', 'position', promptPos, 'string', 'Add Covariate', 'fontsize', UI_FS - 1);
icatb_wrapStaticText(textH);
promptPos = get(textH, 'position');

editWidth = promptWidth;
editHeight = 0.3;
editPos = [0.5 - 0.5*editWidth, promptPos(2) - yOffset - editHeight, editWidth, editHeight];
editH = icatb_uicontrol('parent', covFigHandle, 'units', 'normalized', 'style', 'edit', 'position', editPos, 'string', covVals, 'fontsize', UI_FS - 1, 'tag', 'cov_value', 'min', 0, 'max', 2, 'callback', {@covValueCallback, figH});

cmenu = uicontextmenu;

set(editH, 'uicontextmenu', cmenu);

uimenu(cmenu, 'Label', 'Load File', 'callback', {@editContextMenuCallback, covFigHandle, figH});


%% Transformation name and value
promptPos(2) = editPos(2) - promptHeight - yOffset;
promptPos(1) = xOffset;
editPos = promptPos;
textH = icatb_uicontrol('parent', covFigHandle, 'units', 'normalized', 'style', 'text', 'position', promptPos, 'string', 'Enter transformation function (like log, atanh). Leave it as empty if you don''t want to apply transformation.', 'fontsize', UI_FS - 1, ...
    'tag', 'prompt_cov_transformation');
icatb_wrapStaticText(textH);
promptPos = get(textH, 'position');
promptPos(2) = promptPos(2) + (editPos(4) - promptPos(4));
set(textH, 'position', promptPos);
editPos(1) = editPos(1) + editPos(3) + xOffset;
editPos(2) = promptPos(2) + 0.5*promptPos(4) - 0.5*editPos(4);
editPos(3) = controlWidth;
transformH = icatb_uicontrol('parent', covFigHandle, 'units', 'normalized', 'style', 'edit', 'position', editPos, 'string', transformationName, 'tag', 'cov_transformation', 'fontsize', UI_FS - 1);

okPos = [0.5 - 0.5*okWidth, yOffset + 0.5*okHeight, okWidth, okHeight];
icatb_uicontrol('parent', covFigHandle, 'units', 'normalized', 'style', 'pushbutton', 'position', okPos, 'string', 'Done', 'tag', 'cov_done', 'fontsize', UI_FS - 1, 'callback', {@setCovCallback, covFigHandle, figH});


set(findobj(covFigHandle, 'tag', 'cov_type'), 'callback', {@covTypeCallback, covFigHandle, transformH, textH});

covTypeCallback(findobj(covFigHandle, 'tag', 'cov_type'), [], covFigHandle, transformH, textH);


function editContextMenuCallback(hObject, event_data, handles, figH)
%% Context menu callback

mancovanInfo = get(figH, 'userdata');

txtFile = icatb_selectEntry('title', 'Select covariate file' , 'filter', '*.txt;*.asc', 'typeEntity', 'file', 'typeSelection', 'single');
drawnow;
covTypeH = findobj(handles, 'tag', 'cov_type');
opts = cellstr(get(covTypeH, 'string'));
covVal = get(covTypeH, 'value');

try
    val = icatb_mancovan_load_covariates(txtFile, opts{covVal}, mancovanInfo.userInput.numOfSub);
    covValueH = findobj(handles, 'tag', 'cov_value');
    set(covValueH, 'string', val);
catch
    icatb_errorDialog(lasterr, 'Covariate Selection');
end


function setCovCallback(hObject, event_data, covFigH, handles)
%% Set covariate name, value and type

mancovanInfo = get(handles, 'userdata');

covNameH = findobj(covFigH, 'tag', 'cov_name');
covValueH = findobj(covFigH, 'tag', 'cov_value');
covTypeH = findobj(covFigH, 'tag', 'cov_type');
covTransformationH = findobj(covFigH, 'tag', 'cov_transformation');

% Covariate name, value and type
cov_name = get(covNameH, 'string');
cov_value = get(covValueH, 'string');
opts = cellstr(get(covTypeH, 'string'));
val = get(covTypeH, 'value');
covType = lower(opts{val});
cov_transformation = get(covTransformationH, 'string');

try
    if (isempty(cov_name))
        error('Covariate name is not entered');
    end
    
    if (isempty(cov_value))
        error('Covariate vector is not entered');
    end
    
    if (length(mancovanInfo.userInput.cov) > 0)
        chk = strmatch(lower(cov_name), lower(cellstr(char(mancovanInfo.userInput.cov.name))), 'exact');
        if (~isempty(chk))
            ind = chk;
        end
    end
    
    if (~exist('ind', 'var'))
        ind = length(mancovanInfo.userInput.cov) + 1;
    end
    
    mancovanInfo.userInput.cov(ind).name = cov_name;
    mancovanInfo.userInput.cov(ind).value = deblank(cov_value(:)');
    mancovanInfo.userInput.cov(ind).transformation = lower(cov_transformation);
    mancovanInfo.userInput.cov(ind).type = covType;
    
    set(handles, 'userdata', mancovanInfo);
    
    covListH = findobj(handles, 'tag', 'cov');
    set(covListH, 'string', cellstr(char(mancovanInfo.userInput.cov.name)));
    delete(covFigH);
    
catch
    icatb_errorDialog(lasterr, 'Covariate Selection');
end


function removeCov(hObject, event_data, figH)
%% Remove Covariate
%

mancovanInfo = get(figH, 'userdata');
listH = findobj(figH, 'tag', 'cov');
val = get(listH, 'value');

if (~isempty(val))
    check = icatb_questionDialog('title', 'Remove Covariate', 'textbody', 'Do you want to remove the covariate from the list?');
    if (~check)
        return;
    end
end

try
    strs = cellstr(char(mancovanInfo.userInput.cov.name));
    mancovanInfo.userInput.cov(val) = [];
    strs(val) = [];
    set(listH, 'value', 1);
    set(listH, 'string', strs);
    set(figH, 'userdata', mancovanInfo);
catch
end

function covValueCallback(hObject, event_data, figH)
%% Covariate value callback
%

mancovanInfo = get(figH, 'userdata');
val = cellstr(get(hObject, 'string'));
inds = icatb_good_cells(val);
val = val(inds);

eval(['val2 = [', [val{:}], '];']);

if (length(val2) ~= numel(val2))
    error('Covariate must be entered in a  vector');
end

if (length(val2) ~= mancovanInfo.userInput.numOfSub)
    error(['Covariate vector length must equal the no. of subjects (', num2str(mancovanInfo.userInput.numOfSub), ')']);
end


if (isnumeric(val2))
    val2 = val2(:);
    val2 = num2str(val2);
end

val2 = deblank(cellstr(val2));

set(hObject, 'string', val2);

function saveCallback(hObject, event_data, handles)
%% Save the mancovanInfo

mancovanInfo = get(handles, 'userdata');
fileN = fullfile(mancovanInfo.userInput.outputDir, [mancovanInfo.userInput.prefix, '.mat']);
icatb_save(fileN, 'mancovanInfo');
wH = icatb_dialogBox('title', 'File Saved', 'textBody', ['Mancovan information is saved in file ', fileN], 'textType', 'large');
waitfor(wH);
delete(handles);


function covTypeCallback(hObject, ed, handles, transformH, promptH)
%% Covariates Type callback
%

str = cellstr(get(hObject, 'string'));
str = str{get(hObject, 'value')};
set(promptH, 'visible', 'on');
set(promptH, 'enable', 'on');
set(transformH, 'visible', 'on');
set(transformH, 'enable', 'on');
if (strcmpi(str, 'categorical'))
    set(promptH, 'visible', 'off');
    set(promptH, 'enable', 'off');
    set(transformH, 'visible', 'off');
    set(transformH, 'enable', 'off');
end


function create_design_matrix(hObject, event_data, handles)
%% Make design matrix
%

icatb_defaults;
global FONT_COLOR;
global AXES_COLOR;
global BG_COLOR;

set(handles, 'pointer', 'watch');

mancovanInfo = get(handles, 'userdata');

try
    %% full design matrix
    mancovanInfo = icatb_mancovan_full_design(mancovanInfo);
catch
    set(handles, 'pointer', 'arrow');
    rethrow(lasterror);
end

%% Save file
fileN = fullfile(mancovanInfo.outputDir, [mancovanInfo.prefix, '.mat']);
icatb_save(fileN, 'mancovanInfo');

set(handles, 'pointer', 'arrow');

disp(['Design information is stored in field X in file ', fileN]);
disp('Setup features for mancovan using the same file.');
fprintf('\n');
delete(handles);

drawnow;

InputH = figure('name', 'Mancovan Design Matrix', 'color', BG_COLOR);
set(InputH, 'resize', 'on');
sh = subplot(1, 1, 1);
set(sh, 'color', AXES_COLOR);
imagesc((1:size(mancovanInfo.X, 2)), (1:size(mancovanInfo.X, 1)), mancovanInfo.X);
colormap(gray);
axis(sh, 'square');
xlabel('Covariates', 'parent', sh);
ylabel('Subjects', 'parent', sh);
all_regress = [{'Constant'}, mancovanInfo.regressors];
set(sh, 'TickDir', 'out');
set(sh, 'XTiCk', 1:length(all_regress));
set(sh, 'XTickLabel', all_regress);
set(sh, 'YColor', FONT_COLOR, 'XColor', FONT_COLOR);

