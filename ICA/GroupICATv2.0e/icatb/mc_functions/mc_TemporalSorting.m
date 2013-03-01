function [sortParameters] = mc_TemporalSorting(paramFile)

%% copied from icab_displayGUI.m
% set up parameters and variables
[pathstr, fileName] = fileparts(paramFile);

cd(pathstr); % Cd to parameter file location
load(paramFile);

if ~exist('sesInfo', 'var')
    error('Please select the ICA parameter file');
end

if ~sesInfo.isInitialized
    error('Please run the analysis to display the results');
end


[modalityType, dataTitle, compSetFields] = icatb_get_modality;


if isfield(sesInfo, 'modality')
    if ~strcmpi(sesInfo.modality, modalityType)
        if strcmpi(sesInfo.modality, 'fmri')
            error('You have selected the fMRI parameter file. Use GIFT toolbox to display results.');
        elseif strcmpi(sesInfo.modality, 'smri')
            error('You have selected the sMRI parameter file. Use SBM toolbox to display results.');
        else
            error('You have selected the EEG parameter file. Use EEGIFT toolbox to display results.');
        end
    end
else
    sesInfo.modality = 'fmri';
end


    [sesInfo, complexInfoRead] = icatb_name_complex_images(sesInfo, 'read');
    [sesInfo, complexInfoWrite] = icatb_name_complex_images(sesInfo, 'write');
    
    
    zipContents.zipFiles = {};
    zipContents.files_in_zip(1).name = {};
    if isfield(sesInfo, 'zipContents')
        zipContents = sesInfo.zipContents;
    end
    
    %%%%%%%% Test if the data sets have different number of time points %%%
    % Count the number of files in each of the datasets
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    varCount = 0;
    countFiles = zeros(1, sesInfo.numOfSub*sesInfo.numOfSess);
    
    % check the time points information
    if isfield(sesInfo, 'diffTimePoints')
        
        for numSubjects = 1:sesInfo.numOfSub
            for numSessions = 1:sesInfo.numOfSess
                varCount = varCount + 1;
                % get the time points information
                countFiles(varCount) = sesInfo.diffTimePoints(varCount);
                % end for getting the count for time points
                countTimePoints.sub(numSubjects).sess(numSessions) = countFiles(varCount);
            end
        end
        
    else
        for numSubjects = 1:sesInfo.numOfSub
            for numSessions = 1:sesInfo.numOfSess
                varCount = varCount + 1;
                % get the time points information
                countFiles(varCount) = icatb_get_countTimePoints(sesInfo.userInput.files(varCount).name);
                % end for getting the count for time points
                countTimePoints.sub(numSubjects).sess(numSessions) = countFiles(varCount);
            end
        end
        % set the time points info to sesInfo
        sesInfo.userInput.diffTimePoints = countFiles;
        sesInfo.diffTimePoints = countFiles;
    end
    % end for checking time points information
    
    % check for same number of time points or different
    checkTimePoints = find(countFiles ~= countFiles(1));
    
    if ~isempty(checkTimePoints)
        flagTimePoints = 'different_time_points';
    else
        flagTimePoints = 'same_time_points';
    end
    
    modalityType = sesInfo.modality;
    
    %get results from sesInfo file
    dispParameters.icaOutputFiles = sesInfo.icaOutputFiles;
    dispParameters.numOfSess = sesInfo.numOfSess;
    dispParameters.numOfSub = sesInfo.numOfSub;
    dispParameters.numOfComp = sesInfo.numComp;
    dispParameters.inputFiles = sesInfo.inputFiles;
    dispParameters.spmMatrices = sesInfo.userInput.designMatrix;
    dispParameters.outputDir = pathstr; % save the output directory
    dispParameters.paramFile = paramFile; % parameter file
    dispParameters.inputPrefix = sesInfo.userInput.prefix;
    dispParameters.complexInfoRead = complexInfoRead;
    dispParameters.complexInfoWrite = complexInfoWrite;
    dispParameters.zipContents = zipContents;
    dispParameters.mask_ind = sesInfo.mask_ind;
%     dispParameters.button_original_font_color = BUTTON_FONT_COLOR;
%     dispParameters.button_new_font_color = [0 1 0];
    if (isfield(sesInfo, 'conserve_disk_space'))
        dispParameters.conserve_disk_space = sesInfo.conserve_disk_space;
    else
        dispParameters.conserve_disk_space = 0;
    end
    
    if isfield(sesInfo, 'flip_analyze_images')
        dispParameters.flip_analyze_images = sesInfo.flip_analyze_images;
    end
    
    
    maskImage = fullfile(dispParameters.outputDir, [dispParameters.inputPrefix, 'Mask.img']);
    % save mask image
    dispParameters.mask_file = maskImage;
    
    %%%%%%%%% Construct a mask Image for dealing with z scores%%%%%%%%%%%%%%%
    % get voxel dimensions
    voxelDim = sesInfo.HInfo.DIM;
    % Initialise mask data
    maskData = zeros(1, prod(voxelDim));
    % use indices in the mask as one
    maskData(sesInfo.mask_ind) = 1;
    % convert to 3D data
    maskData = reshape(maskData, voxelDim);
    
    % first scan of the functional data
    firstScan = deblank(sesInfo.inputFiles(1).name(1, :));
    
    [firstScan, fileNum] = icatb_parseExtn(firstScan);
    
    if ~exist(firstScan, 'file')
        disp(['file: ', firstScan, ' is missing.']);
        firstScan = icatb_selectEntry('typeEntity', 'file', 'typeSelection', 'single', 'filter', '*.img;*.nii', ...
            'title', 'Select first scan of functional data', 'fileType', 'image', 'fileNumbers', 1);
        if isempty(firstScan)
            error('file is not selected');
        end
        % update the files information
        sesInfo.inputFiles(1).name = str2mat(firstScan, sesInfo.inputFiles(1).name(2:end, :));
        sesInfo.userInput.files = sesInfo.inputFiles;
        dispParameters.inputFiles = sesInfo.inputFiles;
    end
    
    if (~isa(sesInfo.HInfo.V(1).private, 'icatb_nifti'))
        [dd, sesInfo.HInfo] = icatb_returnHInfo(deblank(dispParameters.inputFiles(1).name(1, :)));
    end
    
    dispParameters.HInfo = sesInfo.HInfo;
    % get the first image volume
    V = dispParameters.HInfo.V(1);
    V.fname = maskImage;
    V.n(1) = 1;
    icatb_write_vol(V, maskData);
    %%%%%%%%%%%%% end for creating mask %%%%%%%%%%%
    
    % include spm mat flag
    if isfield(sesInfo.userInput, 'spmMatFlag')
        dispParameters.spmMatFlag = sesInfo.userInput.spmMatFlag;
    else
        dispParameters.spmMatFlag = 'not_specified';
    end
    
    % include data type
    if isfield(sesInfo.userInput, 'dataType')
        dispParameters.dataType = lower(sesInfo.userInput.dataType);
    else
        dispParameters.dataType = 'real';
    end
    
    % include data type
    if isfield(sesInfo.userInput, 'write_complex_images')
        dispParameters.write_complex_images = lower(sesInfo.userInput.write_complex_images);
    else
        dispParameters.write_complex_images = 'real&imaginary';
    end
    
    % sorting text file (optional way to enter the regressors)
    if isfield(sesInfo.userInput, 'sortingTextFile')
        dispParameters.sortingTextFile = sesInfo.userInput.sortingTextFile;
    else
        dispParameters.sortingTextFile = [];
    end
    
    try
        icatb_save(paramFile, 'sesInfo');
    catch
    end
    
    clear sesInfo;
    
    % store the information about the structural file
    [dispParameters] = icatb_getStructuralFile(dispParameters);
    
    dispParameters.flagTimePoints = flagTimePoints;
    dispParameters.countTimePoints = countTimePoints;

    %% from displayButtonCallback from icab_displayGUI.m
    load(dispParameters.paramFile);
    % indices in the mask
    dispParameters.mask_ind = sesInfo.mask_ind;
    mask_ind = sesInfo.mask_ind;
    zipContents.zipFiles = {};
    zipContents.files_in_zip(1).name = {};
    if isfield(sesInfo, 'zipContents')
        zipContents = sesInfo.zipContents;
    end
    % zip contents
    dispParameters.zipContents = zipContents;
    [sesInfo, complexInfoRead] = icatb_name_complex_images(sesInfo, 'read');
    [sesInfo, complexInfoWrite] = icatb_name_complex_images(sesInfo, 'write');
    % complex information
    dispParameters.complexInfoRead = complexInfoRead;
    dispParameters.complexInfoWrite = complexInfoWrite;
    clear sesInfo;
    
    dispParameters.slicePlane = 'axial';
    dispParameters.compList = zeros(dispParameters.numOfComp, 1);
    dispParameters.displayType = 'component explorer';
    
    [dispParameters, inputText] = icatb_displayGUI_defaults('init', [], dispParameters, 'off');

    
    returnValue = dispParameters.returnValue;
    convertToZ = dispParameters.convertToZ;
    threshValue = dispParameters.thresholdvalue;
    
    if isfield(dispParameters, 'spmMatFlag')
        spmMatFlag = dispParameters.spmMatFlag;
    else
        spmMatFlag = 'not_specified';
    end

    
    handles =0;
    
    dispGUI_Parameters = struct('returnValue', returnValue, 'convertToZ', convertToZ, 'threshValue', ...
        threshValue, 'flagTimePoints', dispParameters.flagTimePoints, 'countTimePoints', ...
        dispParameters.countTimePoints, 'icaOutputFiles', dispParameters.icaOutputFiles, 'numOfSub', ...
        dispParameters.numOfSub, 'numOfSess', dispParameters.numOfSess, 'numOfComp', ...
        dispParameters.numOfComp, 'spmMatrices', dispParameters.spmMatrices, 'outputDir', ...
        dispParameters.outputDir, 'paramFile', dispParameters.paramFile, 'spmMatFlag', ...
        spmMatFlag, 'sortingTextFile', dispParameters.sortingTextFile, 'structFile', ...
        dispParameters.structFile, 'slicePlane', dispParameters.anatomicalplane, ...
        'sliceRange', dispParameters.slicerange, 'dataType', dispParameters.dataType, ...
        'complexInfo', complexInfoWrite, 'displayGUI', handles, 'inputPrefix', ...
        dispParameters.inputPrefix, 'zipContents', zipContents);
    % Output contains the sorted parameters information
    [sortParameters] = icatb_sortComponentsNOGUI(dispGUI_Parameters);

    
    [sortParameters] = icatb_sortComponents('sortingCriteria', sortingCriteria, 'sortingType', sortingType, ...
        'icaTimecourse', icaTimecourse, 'modelTimecourse', modelTimecourse, 'num_Regress', num_Regress, ...
        'num_DataSets', num_DataSets, 'refInfo', refInfo, 'diffTimePoints', figureData.diffTimePoints, ...
        'numcomp', numOfComp, 'spatialTemplate', spatialTemplate, 'icasig', icasig, 'structHInfo', ...
        HInfo, 'viewingSet', figureData.viewingSet, 'keywd', figureData.keywd, 'spatialImage', ...
        spatialImage, 'num_sort_subjects',  numSortSubjects, 'num_sort_sessions', numSortSessions, 'output_dir', ...
        outputDir, 'input_prefix', inputPrefix, 'real_world_coords', real_world_coords);

    %% commented out
%     % delete a previous figure of display GUI
%     checkDispGUI = findobj('tag', 'displaywindow');
%     
%     if ~isempty(checkDispGUI)
%         for ii = 1:length(checkDispGUI)
%             delete(checkDispGUI(ii));
%         end
%     end
%     
%     % display figure
%     graphicsHandle = icatb_getGraphics('Display GUI', 'displayGUI', 'displaywindow', 'off');
%     
%     set(graphicsHandle, 'CloseRequestFcn', @figCloseCallback);
%     
%     % set graphics handle menu none
%     set(graphicsHandle, 'menubar', 'none');
%     
%     dispParameters.diffTimePoints = countFiles; % store the count for the images
%     
%     % plot display defaults
%     display_defaultsMenu = uimenu('parent', graphicsHandle, 'label', 'Display Defaults', 'callback', ...
%         {@display_defaults_callback, graphicsHandle});
    
    if (strcmpi(modalityType, 'fmri'))
        
        % Display GUI Options Menu
        dispGUIOptionsMenu = uimenu('parent', graphicsHandle, 'label', 'Display GUI Options');
        designMatrixMenu = uimenu(dispGUIOptionsMenu, 'label', 'Design Matrix', 'callback', ...
            {@designMatrixOptionsCallback, graphicsHandle});
        
        
        % IC navigator
        %icNavigatorMenuH = uimenu(dispGUIOptionsMenu, 'label', 'IC Navigator', 'callback', @icNavigatorCallback);
        
        %     % save display parameters using save option in options menu
        %     saveDataMenu = uimenu(dispGUIOptionsMenu, 'label', 'Save Display Parameters', 'callback', ...
        %         {@saveDispParametersCallback, graphicsHandle});
        %
        %
        %     % load display parmeters
        %     loadDataMenu = uimenu(dispGUIOptionsMenu, 'label', 'Load Display Parameters', 'callback', ...
        %         {@loadDispParametersCallback, graphicsHandle});
        %
        %     % enter sorting text file
        sortingTextFileMenu = uimenu(dispGUIOptionsMenu, 'label', 'Load file for temporal sorting', 'callback', ...
            {@sortingTextFileCallback, graphicsHandle});
        
    end
    
    if strcmpi(modalityType, 'fmri')
        helpLabel = 'GIFT-Help';
    else
        helpLabel = 'SBM-Help';
    end
    
    % Help Menu
    helpMenu = uimenu('parent', graphicsHandle, 'label', helpLabel);
    htmlHelpMenu = uimenu(helpMenu, 'label', 'Display GUI', 'callback', 'icatb_openHTMLHelpFile(''icatb_displayGUI.htm'');');
    
    
    % parameters to plot in a menu
    
    % offsets
    xOffset = 0.02; yOffset = 0.02;
    
    %%%%%%%%%%%%% Draw Title here %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % title color
    titleColor = [0 0.9 0.9];
    % fonts
    titleFont = 13;
    axes('Parent', graphicsHandle, 'position', [0 0 1 1], 'visible', 'off');
    xPos = 0.5; yPos = 0.97;
    text(xPos, yPos, 'Visualization Methods', 'color', titleColor, 'FontAngle', 'italic', 'fontweight', 'bold', ...
        'fontsize', titleFont, 'HorizontalAlignment', 'center', 'FontName', UI_FONTNAME);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Plot controls in two frames
    % Upper frame: Images
    % Lower frame: UIcontrols
    
    % plot display button
    buttonWidth = 0.2; buttonHeight = 0.05;
    displayButtonPos = [0.75 yOffset buttonWidth buttonHeight];
    
    
    displayButtonH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'pushbutton', ...
        'position', displayButtonPos, 'string', 'Display', 'tag', 'display_button', 'callback', ...
        {@displayButtonCallback, graphicsHandle});
%     %     extentPos = get(displayButtonH, 'extent'); % get the extent of the load anatomical button
%     %     displayButtonPos(3) = extentPos(3) + 0.02; displayButtonPos(4) = extentPos(4) + 0.002;
%     %     % get the new position for load anatomical position
%     %     set(displayButtonH, 'position', displayButtonPos);
%     
%     % plot load anatomical
%     buttonWidth = 0.26; buttonHeight = 0.05;
%     loadAnatomicalPos = [0.05 yOffset buttonWidth buttonHeight];
%     loadAnatomicalH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'pushbutton', ...
%         'position', loadAnatomicalPos, 'string', 'Load Anatomical', 'tag', 'load_anatomical_button', ...
%         'callback', {@loadAnatomicalCallback, graphicsHandle});
%     %     extentPos = get(loadAnatomicalH, 'extent'); % get the extent of the load anatomical button
%     %     loadAnatomicalPos(3) = extentPos(3) + 0.01; loadAnatomicalPos(4) = extentPos(4) + 0.001;
%     %     % get the new position for load anatomical position
%     %     set(loadAnatomicalH, 'position', loadAnatomicalPos);
%     
%     paramFrameYOrigin = loadAnatomicalPos(2) + loadAnatomicalPos(4) + yOffset;
%     availableSpace = yPos - paramFrameYOrigin - yOffset;
%     
%     paramHeight = 0.65*availableSpace;
%     
%     % define frame positions
%     parameterFramePos = [xOffset paramFrameYOrigin 1 - 2*xOffset paramHeight];
%     
%     paramFrameYOrigin = parameterFramePos(2) + parameterFramePos(4) + yOffset;
%     paramFrameWidth = 1 - 2*xOffset;
%     paramFrameHeight = yPos - 2*yOffset - paramFrameYOrigin;
%     
%     buttonFramePos = [parameterFramePos(1) paramFrameYOrigin paramFrameWidth paramFrameHeight];
%     
%     parametersFrameH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'frame', 'position', ...
%         parameterFramePos, 'tag', 'parameters-frame', 'visible', 'off');
%     
%     buttonsFrameH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'frame', 'position', ...
%         buttonFramePos, 'tag', 'button-frame', 'visible', 'off');
%     
%     % component Button
%     if (~strcmpi(modalityType, 'smri'))
%         buttonWidth = (1 - 2*xOffset - 5*xOffset) / 4;
%     else
%         buttonWidth = (1 - 2*xOffset - 5*xOffset) / 3;
%     end
%     buttonHeight = 0.05;
%     componentButtonPos = [buttonFramePos(1) + xOffset buttonFramePos(2) +  buttonFramePos(4) - yOffset - 0.5*buttonHeight ...
%         buttonWidth buttonHeight];
%     
%     componentButtonH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'pushbutton', ...
%         'position', componentButtonPos, 'string', 'Component', 'tag', 'component_button', ...
%         'callback', {@componentExplorerCallback, graphicsHandle});
%     % subject explorer button
%     subjectButtonPos = componentButtonPos;
%     
%     if (~strcmpi(modalityType, 'smri'))
%         subjectButtonPos(1) = subjectButtonPos(1) + subjectButtonPos(3) + xOffset;
%         subjectButtonH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'pushbutton', ...
%             'position', subjectButtonPos, 'string', 'Subject', 'tag', 'subject_button', 'callback', ...
%             {@subjectExplorerCallback, graphicsHandle});
%     end
%     
%     % Orthogonal Viewer button
%     orthButtonPos = subjectButtonPos;
%     orthButtonPos(1) = orthButtonPos(1) + orthButtonPos(3) + xOffset;
%     orthoButtonH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'pushbutton', ...
%         'position', orthButtonPos, 'string', 'Orthogonal', 'tag', 'ortho_button', ...
%         'callback', {@orthoViewerCallback, graphicsHandle});
%     
%     % Orthogonal Viewer button
%     compositeButtonPos = orthButtonPos;
%     compositeButtonPos(1) = compositeButtonPos(1) + compositeButtonPos(3) + xOffset;
%     compositeButtonH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'pushbutton', ...
%         'position', compositeButtonPos, 'string', 'Composite', 'tag', 'composite_button', ...
%         'callback', {@compositeViewerCallback, graphicsHandle});
%     
%     % Component Explorer Picture
%     componentPicPos = componentButtonPos;
%     componentPicPos(2) = buttonFramePos(2);
%     componentPicPos(4) = componentButtonPos(2) - 0.5*componentButtonPos(4) - componentPicPos(2);
%     componentPicture = axes('Parent', graphicsHandle, 'units','normalized', 'position', componentPicPos);
%     pic1 = imread(COMPONENT_EXPLORER_PIC);
%     ImageAxis1 = image(pic1, 'parent', componentPicture, 'CDataMapping', 'scaled');
%     axis(componentPicture, 'off');
%     
%     if (~strcmpi(modalityType, 'smri'))
%         % Subject Explorer Picture
%         subjectPicPos = componentPicPos;
%         subjectPicPos(1) = subjectButtonPos(1);
%         subjectPicture = axes('Parent', graphicsHandle, 'units','normalized', 'position', subjectPicPos);
%         pic2 = imread(COMPONENT_EXPLORER_PIC);
%         ImageAxis2 = image(pic2, 'parent', subjectPicture, 'CDataMapping', 'scaled');
%         axis(subjectPicture, 'off');
%     end
%     
%     % Orthogonal Viewer Picture
%     orthoPicPos = componentPicPos;
%     orthoPicPos(1) = orthButtonPos(1);
%     orthoPicture = axes('Parent', graphicsHandle, 'units','normalized', 'position', orthoPicPos);
%     pic3 = imread(ORTHOGONAL_VIEWER_PIC);
%     ImageAxis3 = image(pic3, 'parent', orthoPicture, 'CDataMapping', 'scaled');
%     axis(orthoPicture, 'off');
%     
%     % Composite Viewer Picture
%     compositePicPos = componentPicPos;
%     compositePicPos(1) = compositeButtonPos(1);
%     compositePicture = axes('Parent', graphicsHandle, 'units','normalized', 'position', compositePicPos);
%     pic4 = imread(COMPOSITE_VIEWER_PIC);
%     ImageAxis4 = image(pic4, 'parent', compositePicture, 'CDataMapping', 'scaled');
%     axis(compositePicture, 'off');
%     
%     dispParameters.slicePlane = 'axial';
%     dispParameters.compList = zeros(dispParameters.numOfComp, 1);
%     dispParameters.displayType = 'component explorer';
%     
%     % Plot sort components followed by listboxes for viewing set and
%     % component number
%     
%     % plot sort components here
%     textHeight = 0.05; textWidth = 0.35;
%     control_width = 0.2; control_height = 0.05;
%     % text origin
%     textYOrigin = parameterFramePos(2) + parameterFramePos(4) - xOffset - textHeight;
%     textPos = [parameterFramePos(1), textYOrigin, textWidth, textHeight];
%     
%     % draw listbox
%     listWidth = 0.5; listHeight = 0.3;
%     
%     if (~strcmpi(modalityType, 'smri'))
%         
%         % plot text
%         textH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'text', 'position', ...
%             textPos, 'string', 'Sort Components', 'HorizontalAlignment', 'center');
%         
%         % horizontal alignment - center, vertical alignment - middle
%         align(textH,'center','middle');
%         
%         popupPos = [textPos(1) + textPos(3) + 2*xOffset, textPos(2), ...
%             control_width, control_height];
%         
%         clear options;
%         
%         % Sort Options
%         options(1).str =  SORT_COMPONENTS;
%         sortOptions = {'No', 'Yes'};
%         % Apply defaults from icatb_defaults
%         sortOptions = checkDefaults_gui(options(1).str, sortOptions, 'exact');
%         
%         for jj = 1:length(sortOptions)
%             options(jj).str = sortOptions{jj};
%         end
%         
%         popupH = icatb_getUIPopUp(graphicsHandle, str2mat(options.str), popupPos, '', 'on', 'sort_components');
%         
%         clear options;
%         
%         % plot component listbox and viewing set listbox
%         textPos(2) = textPos(2) - textHeight - yOffset;
%         
%     end
%     
%     textWidth = 0.25; textHeight = 0.05;
%     
%     textPos = [textPos(1) + 0.5*listWidth - 0.5*textWidth textPos(2) textWidth textHeight];
%     
%     % plot text
%     textH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'text', 'position', ...
%         textPos, 'string', 'Viewing Set', 'HorizontalAlignment', 'center');
%     
%     % horizontal alignment - center, vertical alignment - middle
%     align(textH,'center','middle');
%     
%     outputFiles = chkOutputFiles(dispParameters.icaOutputFiles, dispParameters.outputDir);
%     counter = 1;
%     numOfSets = length(outputFiles);
%     % loop over number of sets
%     for jj = 1 : numOfSets
%         % loop over sessions
%         for kk = 1 : length(outputFiles(jj).ses)
%             str = deblank(outputFiles(jj).ses(kk).name(1, :));
%             [pathstr fileName] = fileparts(str);
%             underScoreIndex = icatb_findstr(fileName, '_');
%             str = fileName(1:underScoreIndex(end) - 1);
%             str = [num2str(jj),'-', num2str(kk), ' ', str];
%             options(counter).str = str;
%             counter = counter + 1;
%         end
%     end
%     
%     dispParameters.icaOutputFiles2 = outputFiles;
%     
%     listboxPos = [parameterFramePos(1) textPos(2) - listHeight - yOffset  listWidth listHeight];
%     % list box position
%     listH = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'listbox', 'position', ...
%         listboxPos, 'HorizontalAlignment', 'center', 'string', str2mat(options.str), 'value', 1, 'tag', ...
%         'viewing_set', 'min', 0, 'max', 1);
%     
%     
%     listWidth = 0.25;
%     
%     listboxPos = [parameterFramePos(1) + parameterFramePos(3) - 2*xOffset - listWidth, listboxPos(2), listWidth, ...
%         listHeight];
%     textPos = [listboxPos(1) + 0.5*listWidth - 0.5*textWidth textPos(2) textWidth textHeight];
%     
%     text2H = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'text', 'position', ...
%         textPos, 'string', 'Component No:', 'HorizontalAlignment', 'center');
%     
%     % horizontal alignment - center, vertical alignment - middle
%     align(text2H, 'center', 'middle');
%     
%     % number of components
%     numComp = dispParameters.numOfComp;
%     
%     clear options;
%     
%     % return component index
%     for ii = 1:numComp
%         options(ii).str = icatb_returnFileIndex(ii);
%     end
%     
%     % list box position
%     list2H = icatb_uicontrol('parent', graphicsHandle, 'units', 'normalized', 'style', 'listbox', 'position', ...
%         listboxPos, 'string', str2mat(options.str), 'HorizontalAlignment', 'center', ...
%         'tag', 'component_number', 'min', 0, 'max', 2);
%     
%     clear options
%     % store the data to handles data
%     %handles_data.dispParameters = dispParameters;
%     
%     [dispParameters, inputText] = icatb_displayGUI_defaults('init', [], dispParameters, 'off');
%     %dispParameters.visualizationmethods = 'component explorer';
%     handles_data.dispParameters = dispParameters; handles_data.inputText = inputText;
%     
%     % set the figure data
%     set(graphicsHandle, 'userdata', handles_data);
%     
%     clear handles_data;
%     
%     % by default execute the component explorer callback
%     componentExplorerCallback(componentButtonH, [], graphicsHandle);
%     
%     try
%         delete(helpHandle);
%     catch
%     end
%     
%     % Make the figure visible
%     set(graphicsHandle, 'visible', 'on');
%% from original icab_sortComponentsGUI.m
% Sorts the components using a GUI. Presently, the available
% criteria are Multiple Regression, Kurtosis, Correlation, Maximum Voxel
% Criteria
%
% Input:
% dispGUI_Parameters - structure containing the necessary information for
% sorting components
% Some of the fields are:
% 1. spmMatrices - the spm2 design matrices names
% 2. icaOutputFiles - contains the mean, t-map, subject files
% 3. numOfSub - total number of subjects
% 4. numOfSess - total number of sessions
% 5. numOfComp - number of components
% 6. outputDir - output directory
% 7. paramFile - Parameter file
% 8. displayGUI - Display GUI handle
% 9. inputPrefix - Input prefix
% 10. zipContents - structure containing zip files and files in zip
% information
% 11. spmMatFlag - SPM mat flag for selecting regressors
% 12. sortingTextFile - Text file containing regressor information
%
% Output:
% sortParameters structure containing sorted indices, sorted criteria values;
% regression coefficients are passed only for Multiple Regression
% detrended ICA time course for all components if specified, regressor
% names, SPM.mat file name, component images
% 1. sortedIndices - sorted indices
% 2. sortedValues - Values in descending order
% 3. sortingCriteria - sorting criteria as passed in input Parameter
% 4. sortingType - spatial or temporal
% 4. regressCoeff - regression coefficients only for multiple regression
% 5. icaTimecourse - sorted icaTimecourse
% 6. modelTimecourse - model time course selected. In case no model
% timecourse is selected modelTimecourse = [];
% 7. refInfo - reference information selected includes the number of
% subjects, sessions, regressor indices , regressor names selected in a column vector. In case
% no regressor is selected refInfo = [];
% 8. icasig - component images (components by voxels). In case of temporalundetrendICA
% sorting icasig = [];
% 9. diffTimePoints - length of the time points for each data set used to
% concatenate. In case of spatial sorting diffTimePoints = [];
% 10. compLabels - component labels which will be used in displaying
% components in component explorer
% 11. undetrend_ICA - ICA time courses prior to detrending

meanICAFiles(1).name = [];
tmapICAFiles(1).name = [];
subjectICAFiles(1).ses(1).name = [];
meanALL_ICAFile(1).name = [];
spatialTemplateFiles(1).name = [];
spmMatrices(1).name = [];
refInfo = [];
diffTimePoints = [];

spmMatrices = dispGUI_Parameters.spmMatrices;
icaOutputFiles = dispGUI_Parameters.icaOutputFiles;
numOfSub = dispGUI_Parameters.numOfSub;
numOfSess = dispGUI_Parameters.numOfSess;
numOfComp = dispGUI_Parameters.numOfComp;
outputDir = dispGUI_Parameters.outputDir; % output directory
paramFile = dispGUI_Parameters.paramFile; % parameter file
displayGUIHandle = dispGUI_Parameters.displayGUI;
inputPrefix = dispGUI_Parameters.inputPrefix;
zipContents = dispGUI_Parameters.zipContents;

sortingTextFile = [];

visibility = 'on';

if isfield(dispGUI_Parameters, 'sortingGUI_visibility')
    visibility = dispGUI_Parameters.sortingGUI_visibility;
end

% check the flag
if isfield(dispGUI_Parameters, 'spmMatFlag')
    spmMatFlag = dispGUI_Parameters.spmMatFlag;
else
    spmMatFlag = 'not_specified';
end

% Check if spmMatflag contains 'no'
if strcmpi(spmMatFlag, 'no')
    spmMatFlag = 'not_specified';
end

if isfield(dispGUI_Parameters, 'sortingTextFile')
    sortingTextFile = dispGUI_Parameters.sortingTextFile;
end

% remove the fields
dispGUI_parameters = rmfield(dispGUI_Parameters, {'spmMatrices', 'icaOutputFiles', 'numOfSub', ...
    'numOfSess', 'numOfComp'});

% get the flag and count for time points
if isfield(dispGUI_Parameters, 'flagTimePoints')
    flagTimePoints = dispGUI_Parameters.flagTimePoints;
    % count is for each subject and session
    countTimePoints = dispGUI_Parameters.countTimePoints;
else
    flagTimePoints = 'same_time_points';
    % count is for each subject and session
    countTimePoints = dispGUI_Parameters.countTimePoints;
end

complexInfo = [];
% complex Info
if isfield(dispGUI_Parameters, 'complexInfo')
    complexInfo = dispGUI_Parameters.complexInfo;
end

dataType = 'real';
% data type
if isfield(dispGUI_Parameters, 'dataType')
    dataType = dispGUI_Parameters.dataType;
end

% load defaults
icatb_defaults;
global BG_COLOR;
global BG2_COLOR;
global BUTTON_COLOR;
global BUTTON_FONT_COLOR;
global HELP_FONT_COLOR;
global FG_COLOR;
global AXES_COLOR;
global FONT_COLOR;
global UI_FONTNAME;
global UI_FONTUNITS;
global UI_FS;
global SMOOTHPARA;
global  SMOOTHINGVALUE;

% Initialize variables from icaOutputFiles if it exists
if exist('icaOutputFiles', 'var')
    [subjectICAFiles, meanICAFiles, tmapICAFiles, meanALL_ICAFile] = ...
        icatb_parseOutputFiles('icaOutputFiles', icaOutputFiles, 'numOfSub', ...
        numOfSub, 'numOfSess', numOfSess, 'flagTimePoints', flagTimePoints);
    clear icaOutputFiles;
end

% determine the empty state of the files
isEmptyMean = isempty(meanICAFiles(1).name);
isEmptyTMap = isempty(tmapICAFiles(1).name);
isEmptySubject = isempty(subjectICAFiles(1).ses(1).name);
isEmptyMeanALL = isempty(meanALL_ICAFile(1).name);
% determine the empty state of the models
isEmptyTemplateFiles = isempty(spatialTemplateFiles(1).name);
isEmptySPMMatrices = isempty(spmMatrices(1).name);

stateDesignMatrix = 'no';
if (isEmptySPMMatrices)

    spmMatFlag =  'not_specified';

end

saveDesMat = 0;
% Loop over spm matrices
for nS = 1:length(spmMatrices)
    if ~isempty(spmMatrices(nS).name)
        if ~exist(deblank(spmMatrices(nS).name), 'file')
            tempFile = icatb_selectEntry('title', ['Select SPM2/SPM5/SPM8 design matrix for subject ', num2str(nS)], 'filter', '*.mat', ...
                'typeEntity', 'file', 'typeSelection', 'single');
            if isempty(tempFile)
                error('SPM design matrix is not selected');
            end
            spmMatrices(nS).name = tempFile;
            saveDesMat = 1;
        end
    end
end
% End loop over spm matrices

% Save design matrix
if saveDesMat
    dispGUI_Parameters.spmMatrices = spmMatrices;
    dispPara = get(displayGUIHandle, 'userdata');
    dispPara.dispParameters.spmMatrices = spmMatrices;
    set(displayGUIHandle, 'userdata', dispPara);
    clear dispPara;
    % Save parameter file
    load(paramFile);
    sesInfo.userInput.designMatrix = spmMatrices;
    icatb_save(paramFile, 'sesInfo');
    clear sesInfo;
    % Save subject file
    subjectFile = fullfile(outputDir, [inputPrefix, 'Subject.mat']);
    SPMFiles = spmMatrices;
    icatb_save(subjectFile, 'SPMFiles', '-append');
end
% End for saving design matrix

% Check if the design matrix is  selected or not
if strcmp(spmMatFlag, 'not_specified')
    if ~(isEmptySPMMatrices)
        % specify the flag
        if length(spmMatrices) > 1
            stateDesignMatrix = 'diff_sub_diff_sess';
        elseif length(spmMatrices) == 1
            stateDesignMatrix = 'same_sub_same_sess';
        end
    end

else
    stateDesignMatrix = lower(spmMatFlag);
end
% end for selection of the design matrix

if strcmp(stateDesignMatrix, 'diff_sub_diff_sess')
    % Temporal models
    if exist('spmMatrices', 'var')
        numOfSpmMat = length(spmMatrices);
        if numOfSub*numOfSess > 1
            if numOfSpmMat == numOfSub
                dataCount = 0;
                temp = spmMatrices;
                clear spmMatrices;
                for ii = 1:numOfSub
                    for jj = 1:numOfSess
                        dataCount = dataCount + 1;
                        spmMatrices(dataCount).name = temp(ii).name;
                    end
                end
                clear temp;
            end
        end
    end

end


% Open the graphics window
H = icatb_getGraphics('Sorting GUI', 'normal', 'sortinggui');

% Set no menu bar for the figure
set(H, 'Menubar', 'None');

% help menu
helpMenu = uimenu('parent', H, 'label', 'GIFT-Help');
htmlHelpMenu = uimenu(helpMenu, 'label', 'Sorting GUI', 'callback', ...
    'icatb_openHTMLHelpFile(''icatb_sorting_components.htm'');');

%%%%%%%%%%%%%%%%%%%%%% Parameters for sorting GUI %%%%%%%%%%%%%%%%%%%%%%%%
numParameters = 1;

inputText(numParameters).promptString = 'Select Sorting Criteria';
inputText(numParameters).answerString = str2mat('Multiple Regression', 'Correlation', 'Kurtosis', 'Maximum Voxel');
inputText(numParameters).uiType = 'popup';
inputText(numParameters).answerType = 'string';
inputText(numParameters).tag = 'sorting_criteria';
inputText(numParameters).helpString = 'icatb_new_directions(''sorting_criteria'');';
inputText(numParameters).enable = 'on';

numParameters = numParameters + 1;

% define the callback for this pop up (Yes is selected)
inputText(numParameters).promptString = 'Select Sorting Type';
inputText(numParameters).answerString = str2mat('Temporal', 'Spatial');
inputText(numParameters).uiType = 'popup';
inputText(numParameters).answerType = 'string';
inputText(numParameters).tag = 'sorting_type';
inputText(numParameters).helpString = 'icatb_new_directions(''sorting_type'');';
inputText(numParameters).enable = 'on';

numParameters = numParameters + 1;

% define the callback for this pop up (Yes is selected)
% What do you want to sort
if (numOfSub == 1 & numOfSess == 1)
    choiceString = 'All Datasets';
elseif ((numOfSub > 1 & numOfSess == 1) | (numOfSub == 1 & numOfSess > 1))
    choiceString = str2mat('All Datasets', 'A Dataset');
elseif(numOfSub > 1 & numOfSess > 1)
    choiceString = str2mat('All Datasets', 'A Dataset', ...
        'A Session', 'A Subject');
end

inputText(numParameters).promptString = 'What do you want to sort?';
inputText(numParameters).answerString = choiceString;
inputText(numParameters).uiType = 'popup';
inputText(numParameters).answerType = 'string';
inputText(numParameters).tag = 'what_to_sort';
inputText(numParameters).helpString = 'icatb_new_directions(''what_to_sort'');';
inputText(numParameters).enable = 'on';

clear choiceString;

numParameters = numParameters + 1;

% plot all the user interface controls and their options to the right
% plot a help button to the right

% offsets for x and y
xOffset = 0.02; yOffset = 0.04;

% UI control width and height
uicontrol_Width = 0.42; uicontrol_Height = 0.05;

% number of UIcontrols excluding the push buttons
numUIcontrols = length(inputText);

yPos = 0.9;

% Position of prompt string
promptPos = [0.02 yPos  0.4 0.1];

% Position of answer string
answerPos = promptPos;
answerPos(1) = promptPos(1) + promptPos(3) + xOffset; answerPos(3) = uicontrol_Width;
answerPos(4) = uicontrol_Height;

answerPrefix = 'answer';

sortingData.answerPrefix = answerPrefix;


%%%%%%%%%%% plot all the uicontrols %%%%%%%%%%
countTag = 0;
for ii = 1:numUIcontrols
    countTag = countTag + 1;
    % prompt string
    promptHandle(ii) = icatb_uicontrol('parent', H, 'units', 'normalized', 'style', 'text', 'position', ...
        promptPos, 'string', inputText(ii).promptString, 'tag', inputText(ii).tag);
    storeTag{countTag} = inputText(ii).tag;

    % check if the string is a cell array
    if ~iscell(inputText(ii).promptString)
        newTextString = {inputText(ii).promptString};
    end

    % wrap the prompt string and get the new position
    [newTextString, newPos] = textwrap(promptHandle(ii), newTextString);

    % select the same height as the text wrap
    promptPos(4) = newPos(4);

    promptPos(2) = newPos(2) - 0.5*promptPos(4);
    answerPos(2) = newPos(2) - 0.5*answerPos(4);

    % store all the initial positions
    initialYPositions(countTag) = promptPos(2);

    % define the help position here
    helpPos(2) = answerPos(2);

    % set the new position for the prompt handle
    set(promptHandle(ii), 'string', newTextString, 'position', promptPos);

    countTag = countTag + 1;

    storeTag{countTag} = [answerPrefix, inputText(ii).tag];

    % store all the initial positions
    initialYPositions(countTag) = answerPos(2);

    [pp] = icatb_uicontrol('parent', H, 'units', 'normalized', 'style', inputText(ii).uiType, ...
        'position', answerPos, 'string', inputText(ii).answerString, 'tag', storeTag{countTag}, 'enable', ...
        inputText(ii).enable);

    answerHandle(ii) = pp(end);
    % store all the positions of the prompt, edit and help strings
    textPos{ii} = promptPos;

    objPos{ii} = answerPos;

    %
    promptPos(2) = promptPos(2) - 0.5*promptPos(4) - yOffset;
    answerPos(2) = answerPos(2) - 0.5*answerPos(4) - yOffset;

end
%%%%%%%%%%% End for plotting all the uicontrols %%%%%%%%%%%

% % Ok Button push button position
okPos(3) = 0.15; okPos(4) = 0.055; okPos = [0.5 - 0.5*okPos(3) answerPos(2) - yOffset - 0.5*okPos(4) ...
    okPos(3) okPos(4)];

% Figure data
sortingData.numOfSub = numOfSub;
sortingData.numOfSess = numOfSess;
sortingData.numOfComp = numOfComp;
sortingData.stateDesignMatrix = stateDesignMatrix;
sortingData.subjectICAFiles = subjectICAFiles;
clear subjectICAFiles;
sortingData.meanICAFiles = meanICAFiles;
clear meanICAFiles;
sortingData.tmapICAFiles = tmapICAFiles;
clear tmapICAFiles;
sortingData.meanALL_ICAFile = meanALL_ICAFile;
clear meanALL_ICAFile;
sortingData.dispGUI_Parameters = dispGUI_Parameters;
clear dispGUI_Parameters;
sortingData.spmMatrices = spmMatrices;
clear spmMatrices;
sortingData.diffTimePoints = diffTimePoints;
clear diffTimePoints;
sortingData.flagTimePoints = flagTimePoints;
sortingData.countTimePoints = countTimePoints;
sortingData.outputDir = outputDir;
% sorting text file
sortingData.sortingTextFile = sortingTextFile;
% store complex info
sortingData.complexInfo = complexInfo;
sortingData.dataType = dataType;
sortingData.displayGUIHandle = displayGUIHandle;
sortingData.inputPrefix = inputPrefix;
sortingData.zipContents = zipContents;

set(H, 'userdata', sortingData);

% define push buttons
okHandle = icatb_uicontrol('parent', H, 'units', 'normalized', 'style', 'pushbutton', 'position', ...
    okPos, 'string', 'Done', 'tag', 'OK', 'BackgroundColor', BUTTON_COLOR,...
    'ForegroundColor', BUTTON_FONT_COLOR, 'fontunits', UI_FONTUNITS, 'fontname', UI_FONTNAME, 'FontSize', ...
    UI_FS, 'callback', {@applyCallback, H}, 'userdata', []);

% End for plotting push buttons

staticTextWidth = 0.8;
staticTextHeight = 0.05;

% position
staticTextPos = [0.5 - 0.5*staticTextWidth 0.2 staticTextWidth staticTextHeight];

% Plot text on the sorting figure
staticTextH = icatb_uicontrol('parent', H, 'units', 'normalized', 'style', 'text', 'position', ...
    staticTextPos, 'string', 'Press done after selection of parameters.', 'tag', 'static_text_H', ...
    'fontweight', 'bold');
% wrap the text
[staticTextH] = icatb_wrapStaticText(staticTextH);

% set callbacks here
set(findobj(H, 'tag', [answerPrefix 'sorting_criteria']), 'callback', {@criteriaCallback, H});
set(findobj(H, 'tag', [answerPrefix 'sorting_type']), 'callback', {@sortingTypeCallback, H});
set(findobj(H, 'tag', [answerPrefix 'what_to_sort']), 'callback', {@whatToSortCallback, H});

if strcmpi(visibility, 'off')
    % Execute apply callback
    applyCallback(okHandle, [], H);
end

try
    set(H, 'visible', 'on');
    waitfor(okHandle);
catch
    if ishandle(H)
        delete(H);
    end
end

% get the required sorting parameters
if isappdata(0, 'sortingAppData')
    % get the application data
    sortAppData = getappdata(0, 'sortingAppData');
    % get the ouput arguments
    if isfield(sortAppData, 'sortParameters')
        sortParameters = sortAppData.sortParameters;
        sortParameters.keywd = sortAppData.keywd;
        sortParameters.stateDesignMatrix = sortAppData.stateDesignMatrix;
    end
    if isfield(sortAppData, 'session_number')
        sortParameters.session_number = sortAppData.session_number;
    end
    if isfield(sortAppData, 'subject_number')
        sortParameters.subject_number = sortAppData.subject_number;
    end
    sortParameters.sortingTextFile = sortAppData.sortingTextFile;
    rmappdata(0, 'sortingAppData');

else
    sortParameters = [];
    disp('figure window was quit');
end


% Define callbacks here
% 1. define sorting criteria callback
function criteriaCallback(hObject, evd, handles)

% procedure :
% Multiple regression, temporal enable what to sort
% Multiple regression spatial disable what to sort
% Correlation, temporal enable what to sort
% Correlation spatial disable what to sort
% Kurtosis, temporal enable what to sort
% Kurtosis spatial disable what to sort
% Maximum Voxel , disable temporal, disable what to sort

% get the figure data
figureData = get(handles, 'userdata');

% Answer Prefix
answerPrefix = figureData.answerPrefix;

% get the required objects

% Sorting Type
tempObj1 = findobj(handles, 'tag', [answerPrefix, 'sorting_type']);
tempString = get(tempObj1, 'string');
getValue = get(tempObj1, 'value');
getString1 = deblank(tempString(getValue, :));

% What to Sort
tempObj2 = findobj(handles, 'tag', [answerPrefix, 'what_to_sort']);
tempString = get(tempObj2, 'string');
getValue = get(tempObj2, 'value');
getString2 = deblank(tempString(getValue, :));

% Sorting Criteria
tempString = get(hObject, 'string');
getValue = get(hObject, 'value');
getString3 = deblank(tempString(getValue, :));

set(tempObj1, 'enable', 'on');
set(tempObj2, 'enable', 'on');

if strcmpi(getString1, 'temporal')
    set(tempObj2, 'enable', 'on');
else
    set(tempObj2, 'enable', 'off');
end

if strcmpi(getString3, 'maximum voxel')
    set(tempObj1, 'enable', 'off');
    set(tempObj2, 'enable', 'off');
end

figureData.sortingCriteria = lower(getString3);

set(handles, 'userdata', figureData);

% 2. define sorting type
function sortingTypeCallback(hObject, evd, handles)

% get the answer data
figureData = get(handles, 'userdata');

% Prefix for detecting answer boxes
answerPrefix = figureData.answerPrefix;

tempString = get(hObject, 'string');
getValue = get(hObject, 'value');

% sorting type
getString = deblank(tempString(getValue, :));

% Other answer fields
tempObj1 = findobj(handles, 'tag', [answerPrefix, 'sorting_criteria']);
tempObj2 = findobj(handles, 'tag', [answerPrefix, 'what_to_sort']);

tempString = get(tempObj2, 'string');
getValue = get(tempObj2, 'value');

% sorting type
sortingCriteria = deblank(tempString(getValue, :));

% Spatial sorting
if strcmp(lower(getString), 'spatial')
    set(tempObj2, 'enable', 'off');
else
    set(tempObj2, 'enable', 'on');
end

figureData.sortingType = lower(getString);

set(handles, 'userdata', figureData);

% 3. define what to sort
function whatToSortCallback(hObject, evd, handles)

icatb_defaults;

global SUBJECT_ICA_AN3_FILE;

% get the answer data
figureData = get(handles, 'userdata');
answerPrefix = figureData.answerPrefix;
numOfSub = figureData.numOfSub;
numOfSess = figureData.numOfSess;
numOfComp = figureData.numOfComp;
subjectICAFiles = figureData.subjectICAFiles;
meanICAFiles = figureData.meanICAFiles;
tmapICAFiles = figureData.tmapICAFiles;
meanALL_ICAFile = figureData.meanALL_ICAFile;
countTimePoints = figureData.countTimePoints;
% initialise selected time points
diffTimePoints = [];

tempString = get(hObject, 'string');
getValue = get(hObject, 'value');
getString = deblank(tempString(getValue, :));

if figureData.numOfSub*figureData.numOfSess == 1
    getString = 'All DataSets';
end

% Pass the keywd for the data sets selected
if strcmp(lower(getString), 'a dataset')
    keywd = 'single_subject_session';
elseif strcmp(lower(getString), 'a session')
    keywd = 'single_session';
elseif strcmp(lower(getString), 'a subject')
    keywd = 'single_subject';
elseif strcmp(lower(getString), 'all datasets')
    keywd = 'all_subjects_sessions';
end

% get the selected string under consideration
% get the index of the data set
switch keywd

    case 'single_subject_session'

        % initialise selected design index to zero
        selectedDesignIndex = 0;

        % Subject Files
        % selectionStr = setAnswerString;
        % Initialize String
        count = 0;
        setSelectString = 'Select Component Set to Sort';
        setAnswerString = {''};
        for i=1:numOfSub
            for k=1:numOfSess
                count = count + 1;
                [pathstr name] = fileparts(subjectICAFiles(i).ses(k).name(1, :));
                underScoreIndex = icatb_findstr(name,'_');
                name = [name(1:underScoreIndex(end)),'*'];
                setSelectString = str2mat(setSelectString, name);
                setAnswerString{count} = subjectICAFiles(i).ses(k).name;
            end
        end

        %% Added this code to temporally sort the mean IC's

        if ~isempty(meanICAFiles(1).name)
            % add mean for each session to selection list
            for i = 1:numOfSess
                count = count + 1;
                [pathstr name] = fileparts( meanICAFiles(i).name(1, :) );
                underScoreIndex = icatb_findstr(name,'_');
                name = [name(1:underScoreIndex(end)),'*'];
                setSelectString = str2mat(setSelectString, name);
                setAnswerString{count} = meanICAFiles(i).name;
            end

        end

        if ~isempty(meanALL_ICAFile.name)
            % add mean for all sessions to selection list
            count = count + 1;
            [pathstr name] = fileparts( meanALL_ICAFile(1).name(1, :) );
            underScoreIndex = icatb_findstr(name,'_');
            name = [name(1:underScoreIndex(end)),'*'];
            setSelectString = str2mat(setSelectString, name);
            setAnswerString{count} = meanALL_ICAFile(1).name;

        end

        %prompt user to select component set to sort
        promptString = setSelectString(1, :);
        choiceString = setSelectString(2:end, :);

        % get the position of the normal figure
        [normalPos]=icatb_getfigPosition('normal');

        % width  and height of the list box
        listsize = [0.75*normalPos(3) 0.9*normalPos(4)];

        % Position for the component set to be selected
        latestPos = get(handles, 'position');

        % list size - defines the size, normal position - figure
        % position, latest position - places the listbox in that
        % position
        [index] = openListDialog(promptString, choiceString, normalPos, listsize, latestPos);

        compSetAnswer = setAnswerString{index};

        % read the formatted string with the delimiter '_'
        splitSelectedStr = strread(compSetAnswer(1, :), '%s', 'delimiter', '_');

        % number of strings
        numStrings = length(splitSelectedStr);

        % find the subject naming
        splitSubStr = strread(SUBJECT_ICA_AN3_FILE, '%s', 'delimiter', '_');

        % string to compare
        compareStr = deblank(splitSubStr{2});

        % loop over number of strings
        for ii = 1:numStrings
            currentStr = deblank(splitSelectedStr{ii});
            matchedIndex = icatb_findstr(currentStr, compareStr);
            if ~isempty(matchedIndex)
                % subject number
                subjectNumber = str2num(currentStr(matchedIndex + length(compareStr):end));
                % get the underscore positions
                underScorePositions = icatb_findstr(compSetAnswer(1, :), '_');
                sessionNumber = str2num(compSetAnswer(1, underScorePositions(end - 1) + 2 : underScorePositions(end) - 1));
                % design Matrix index
                selectedDesignIndex = numOfSess*(subjectNumber - 1) + sessionNumber;
                % store session number to pull session specific regressors
                figureData.session_number = sessionNumber;
                % store subject number
                figureData.subject_number = subjectNumber;
            end
        end

        % get the count of the time points for the first subject
        diffTimePoints = countTimePoints.sub(1).sess(1);

        if isempty(selectedDesignIndex)
            selectedDesignIndex = 0;
        else
            if exist('subjectNumber', 'var') & exist('sessionNumber', 'var')
                % get the count of the time points for the selected subject
                diffTimePoints = countTimePoints.sub(subjectNumber).sess(sessionNumber);
            end
        end

        clear setAnswerString; clear setSelectString;

        selectionStr = {compSetAnswer};

        viewingSet = deblank(choiceString(index, :));

        disp(['Component set selected for temporal sorting is ', viewingSet]);

        fprintf('\n');

        % Using the selected subject time course
        disp('');
        disp('');
        disp(['Using ' choiceString(index, :) ' Time Courses']);

    case 'single_session'
        % concatenate all subjects for a particular session
        % use pop up or list dialog for selecting
        str = cell(numOfSess, 1);
        for ses = 1:numOfSess
            str{ses} = ['Session ', num2str(ses)];
        end

        string1 = str2mat(str); clear str;

        % get the position of the normal figure
        [normalPos]=icatb_getfigPosition('normal');

        % width  and height of the list box
        listsize = [0.75*normalPos(3) 0.9*normalPos(4)];

        % Position for the component set to be selected
        latestPos = get(handles, 'position');

        [session_number] = openListDialog('Select a Session?', string1, normalPos, listsize, latestPos);

        viewingSet = ['Session ', num2str(session_number)];

        figureData.session_number = session_number;

        selectionStr = cell(numOfSub, 1);
        for sub = 1:numOfSub
            selectionStr{sub} = subjectICAFiles(sub).ses(session_number).name;
        end

        % selected design index
        selectedDesignIndex = session_number;
        diffTimePoints = zeros(1, numOfSub);
        for ii = 1:numOfSub
            diffTimePoints(ii) = countTimePoints.sub(ii).sess(session_number);
        end

    case 'single_subject'
        % initialise selected design index to zero
        selectedDesignIndex = 0;
        % concatenate all sessions for a particular subject
        str = cell(numOfSub, 1);
        for sub = 1:numOfSub
            str{sub} = ['Subject ', num2str(sub)];
        end

        string1 = str2mat(str); clear str;

        promptString = 'Select a Subject?';

        % get the position of the normal figure
        [normalPos]=icatb_getfigPosition('normal');

        % width  and height of the list box
        listsize = [0.75*normalPos(3) 0.9*normalPos(4)];

        % Position for the component set to be selected
        latestPos = get(handles, 'position');

        [subject_number] = openListDialog(promptString, string1, normalPos, listsize, latestPos);

        viewingSet = ['Subject ', num2str(subject_number)];

        % selected design index
        selectedDesignIndex = subject_number;

        figureData.subject_number = subject_number;

        % end for selecting pop up or list dialog box
        selectionStr = cell(numOfSess, 1);
        for ses = 1:numOfSess
            selectionStr{ses} = subjectICAFiles(subject_number).ses(ses).name;
        end

        diffTimePoints = zeros(1, numOfSess);
        for ii = 1:numOfSess
            diffTimePoints(ii) = countTimePoints.sub(subject_number).sess(ii);
        end

    case 'all_subjects_sessions'
        selectionStr = {};
        diffTimePoints = zeros(1, numOfSess*numOfSub);
        dataCount = 0;
        viewingSet = ['All data-sets'];
        % get the count of the time points
        for ii = 1:numOfSub
            for jj = 1:numOfSess
                dataCount = dataCount + 1;
                diffTimePoints(dataCount) = countTimePoints.sub(ii).sess(jj);
            end
        end
        % concatenate all the subjects and sessions for a particular
        % component
end

figureData.keywd = keywd;
figureData.selectionStr = selectionStr;
figureData.diffTimePoints = diffTimePoints;
figureData.viewingSet = viewingSet;
if exist('selectedDesignIndex', 'var')
    figureData.selectedDesignIndex = selectedDesignIndex;
end

set(handles, 'userdata', figureData);

% apply callback
function applyCallback(hObject, evd, handles)

try
    set(handles, 'pointer', 'watch');

    % find the static text handle
    staticTextH = findobj(handles, 'tag', 'static_text_H');

    set(staticTextH, 'string', 'Please wait ...');
    % wrap the text
    [staticTextH] = icatb_wrapStaticText(staticTextH);

    % get the userdata
    figureData = get(handles, 'userdata');

    if ~isfield(figureData, 'viewingSet')
        figureData.viewingSet = 'All data-sets';
    end

    % get the answer prefix
    answerPrefix = figureData.answerPrefix;
    numOfSub = figureData.numOfSub;
    numOfSess = figureData.numOfSess;
    numOfComp = figureData.numOfComp;
    spmMatrices = figureData.spmMatrices;
    stateDesignMatrix = figureData.stateDesignMatrix;
    inputPrefix = figureData.inputPrefix;

    subjectICAFiles = figureData.subjectICAFiles;
    meanICAFiles = figureData.meanICAFiles;
    meanALL_ICAFile = figureData.meanALL_ICAFile;
    countTimePoints = figureData.countTimePoints;
    refInfo = [];
    modelTimecourse = [];
    num_Regress = 0;
    spatialTemplate = [];
    spatialImage = '';
    icasig = [];
    outputDir = figureData.outputDir;
    % option for sorting using text file
    sortingTextFile = figureData.sortingTextFile;
    zipContents = figureData.zipContents;

    % data type and the complex info
    dataType = figureData.dataType;
    complexInfo = figureData.complexInfo;

    if isfield(figureData, 'selectedDesignIndex')
        selectedDesignIndex = figureData.selectedDesignIndex;
    end

    if isfield(figureData, 'sortingCriteria')
        sortingCriteria = figureData.sortingCriteria;
    else
        tempObj = findobj(handles, 'tag', [answerPrefix, 'sorting_criteria']);
        getSelectedVal = get(tempObj, 'value');
        getString = get(tempObj, 'string');
        sortingCriteria = lower(deblank(getString(getSelectedVal, :)));
        figureData.sortingCriteria = sortingCriteria;
    end

    if isfield(figureData, 'sortingType')
        sortingType = figureData.sortingType;
    else
        tempObj = findobj(handles, 'tag', [answerPrefix, 'sorting_type']);
        getSelectedVal = get(tempObj, 'value');
        getString = get(tempObj, 'string');
        sortingType = lower(deblank(getString(getSelectedVal, :)));
        figureData.sortingType = sortingType;
    end

    if strcmp(sortingCriteria, 'maximum voxel')
        sortingType = 'spatial';
    end

    if strcmp(lower(sortingType), 'temporal')
        figureData.dispGUI_Parameters = [];
    end

    tempObj = findobj(handles, 'tag', [answerPrefix, 'what_to_sort']);
    getSelectedVal = get(tempObj, 'value');
    getString = get(tempObj, 'string');
    getString = lower(deblank(getString(getSelectedVal, :)));

    if strcmp(lower(sortingType), 'spatial')
        getString =  'a dataset';
    end

    % Pass the keywd for the data sets selected
    if strcmp(lower(getString), 'a dataset')
        keywd = 'single_subject_session';
    elseif strcmp(lower(getString), 'a session')
        keywd = 'single_session';
    elseif strcmp(lower(getString), 'a subject')
        keywd = 'single_subject';
    elseif strcmp(lower(getString), 'all datasets')
        keywd = 'all_subjects_sessions';
    end

    figureData.keywd = keywd;

    % number of actual sorted subjects and sessions
    if strcmpi(keywd, 'single_subject_session')
        numSortSubjects = 1;
        numSortSessions = 1;
    elseif strcmpi(keywd, 'single_session')
        numSortSubjects = numOfSub;
        numSortSessions = 1;
    elseif strcmpi(keywd, 'single_subject')
        numSortSubjects = 1;
        numSortSessions = numOfSess;
    else
        numSortSubjects = numOfSub;
        numSortSessions = numOfSess;
    end
    % end for getting actual data sets

    % selection string
    if isfield(figureData, 'selectionStr')
        selectionStr = figureData.selectionStr;
    else
        selectionStr = {};
    end

    if strcmp(lower(sortingType), 'temporal')

        % selected time points
        if isfield(figureData,  'diffTimePoints')
            if isempty(figureData.diffTimePoints)
                dataCount = 0;
                % get the count of the time points
                for ii = 1:numOfSub
                    for jj = 1:numOfSess
                        dataCount = dataCount + 1;
                        figureData.diffTimePoints(dataCount) = countTimePoints.sub(ii).sess(jj);
                    end
                end
            end
        end

        if isfield(figureData, 'subject_number')
            subject_number = figureData.subject_number;
        end

        if isfield(figureData, 'session_number')
            session_number = figureData.session_number;
        end

        % Number of data sets
        switch keywd
            case 'single_subject_session'
                num_DataSets = 1;
            case 'single_session'
                num_DataSets = numOfSub;
            case 'single_subject'
                num_DataSets = numOfSess;
            case 'all_subjects_sessions'
                num_DataSets = numOfSub*numOfSess;
        end

        if ~strcmp(sortingCriteria, 'kurtosis')

            % option for selecting the design matrix
            if strcmpi(stateDesignMatrix, 'no')
                % select design matrix
                icatb_selectDesignMatrix(figureData.displayGUIHandle);
                displayGUIdata = get(figureData.displayGUIHandle, 'userdata');
                stateDesignMatrix = displayGUIdata.dispParameters.spmMatFlag;
                figureData.stateDesignMatrix = stateDesignMatrix;
                spmMatrices =  displayGUIdata.dispParameters.spmMatrices;
                figureData.spmMatrices = spmMatrices;
                clear displayGUIdata;

                % check design matrix
                if strcmp(stateDesignMatrix, 'diff_sub_diff_sess')
                    % Temporal models
                    numOfSpmMat = length(spmMatrices);
                    if numOfSub*numOfSess > 1
                        if numOfSpmMat == numOfSub
                            dataDesignCount = 0;
                            tempD = spmMatrices;
                            clear spmMatrices;
                            for iSub = 1:numOfSub
                                for iSess = 1:numOfSess
                                    dataDesignCount = dataDesignCount + 1;
                                    spmMatrices(dataDesignCount).name = tempD(iSub).name;
                                end
                            end
                            clear tempD;
                        end
                        % replicate the design matrix for sessions
                        figureData.spmMatrices = spmMatrices;
                    end
                    % end for checking data sets
                end
                % end for checking

            end

            sessionIndex = 0;
            if exist('session_number', 'var')
                sessionIndex =  session_number;
            end

            set(staticTextH, 'string', 'Select regressors ...');
            [staticTextH] = icatb_wrapStaticText(staticTextH);

            if exist('selectedDesignIndex', 'var')
                % depending upon the model select time model courses
                [modelTimecourse, num_Regress, num_DataSets, refInfo] = icatb_SelectModel_Criteria('sortingCriteria', sortingCriteria, ...
                    'stateDesignMatrix', stateDesignMatrix, 'keywd', keywd, 'numOfSess', numOfSess, 'numOfSub', numOfSub, 'graphicsHandle', ...
                    handles, 'spmMatrices', spmMatrices, 'selected_design_matrix', selectedDesignIndex, ...
                    'flagTimePoints', figureData.flagTimePoints, 'countTimePoints', figureData.diffTimePoints, ...
                    'all_time_points', countTimePoints, 'single_subject_session_number', sessionIndex, ...
                    'sortingTextFile', sortingTextFile);
            else
                % depending upon the model select time model courses
                [modelTimecourse, num_Regress, num_DataSets, refInfo] = icatb_SelectModel_Criteria('sortingCriteria', sortingCriteria, ...
                    'stateDesignMatrix', stateDesignMatrix, 'keywd', keywd, 'numOfSess', numOfSess, 'numOfSub', numOfSub, 'graphicsHandle', ...
                    handles, 'spmMatrices', spmMatrices, 'flagTimePoints', figureData.flagTimePoints, ...
                    'countTimePoints', figureData.diffTimePoints, 'all_time_points', countTimePoints, ...
                    'sortingTextFile', sortingTextFile);
            end

            % if the text file is changed set it to the figure data
            %             if isfield(refInfo, 'sortingTextFile')
            %                 if ~isempty(refInfo.sortingTextFile)
            %                     figureData.sortingTextFile = refInfo.sortingTextFile;
            %                 end
            %             end

            set(staticTextH, 'string', 'Model is concatenated to equal the ICA time course ...');
            [staticTextH] = icatb_wrapStaticText(staticTextH);
            figureData.refInfo = refInfo;
        end

        %%%%%%%%%%%%%%%%%%%%% Wrap the text %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        set(staticTextH, 'string', 'ICA time courses will be concatenated after loading...');
        [staticTextH] = icatb_wrapStaticText(staticTextH);

        % Concatenate ICA time courses as needed
        switch keywd

            case 'single_subject_session'

                % Replace icatb_loadICAData with icatb_loadICATimecourse
                % (Speeds up temporal sorting)
                % loadICATimecourse
                compFiles = selectionStr{1};

                [compFiles, statusFile] = icatb_checkOutPutFiles(compFiles, outputDir, inputPrefix);

                % Load from calibrated MAT files if possible
                if ~statusFile
                    % get the files from the zip file
                    [zipFileName, files_in_zip] = icatb_getViewingSet_zip(compFiles, complexInfo, dataType, zipContents);
                    compFiles = icatb_fullFile('directory', outputDir, 'files', compFiles);
                    [A] = icatb_loadICATimeCourse(compFiles, dataType, complexInfo, [1:1:numOfComp], zipFileName, files_in_zip);
                else
                    compFiles = icatb_fullFile('directory', outputDir, 'files', compFiles);
                    A = loadTC(compFiles, numOfComp);
                end

                icaTimecourse = detrend(A, 0); % remove the mean
                % store the detrended component time courses in a structure
                undetrend_ICA = A;
                clear A;

                %% Add model Time course later

            case 'single_session'

                totalScans = 0;
                % Load subjects for the particular session
                for sub = 1:numOfSub
                    disp(['Loading Subject ', num2str(sub), ' Session ', num2str(session_number), ' ICA Data']);
                    % loadICATimecourse
                    compFiles = selectionStr{sub};

                    [compFiles, statusFile] = icatb_checkOutPutFiles(compFiles, outputDir, inputPrefix);

                    if ~statusFile
                        % get the files from the zip file
                        [zipFileName, files_in_zip] = icatb_getViewingSet_zip(compFiles, complexInfo, dataType, ...
                            zipContents);
                        compFiles = icatb_fullFile('directory', outputDir, 'files', compFiles);
                        [A] = icatb_loadICATimeCourse(compFiles, dataType, complexInfo, [1:1:numOfComp], ...
                            zipFileName, files_in_zip);
                        clear('zipFileName', 'files_in_zip', 'compFiles');

                    else
                        compFiles = icatb_fullFile('directory', outputDir, 'files', compFiles);
                        A = loadTC(compFiles, numOfComp);
                    end

                    if sub == 1
                        statusH = icatb_statusBar('init', numOfSub, 'Loading Components', '', '');
                        statusH = icatb_statusBar('increment', 1);
                    elseif sub > 1 & sub < numOfSub
                        statusH = icatb_statusBar('increment', 1);
                    end
                    % loop over the components
                    for jj = 1:numOfComp
                        compTimecourses.sub(sub).sess(1).comp(jj).tc = A(:, jj);
                    end
                    totalScans = totalScans + size(A, 1);
                    clear A;
                end

                %clear HInfo; clear prefix;
                statusH = icatb_statusBar('increment', 1);
                icatb_statusBar('finished');
                icaTimecourse = zeros(totalScans, numOfComp);
                undetrend_ICA = zeros(totalScans, numOfComp);
                subjectTimecourse = zeros(1, totalScans);
                undetrendSubjectTimecourse = zeros(1, totalScans);

                % loop over components
                for j = 1:numOfComp
                    % loop over subjects
                    xStart = 1;
                    for i = 1:numOfSub
                        compTimecourse = compTimecourses.sub(i).sess(1).comp(j).tc;
                        compTimecourses.sub(i).sess(1).comp(j).tc = detrend(compTimecourse, 0);
                        subjectTimecourse(xStart:xStart + size(compTimecourse, 1) - 1) = ...
                            compTimecourses.sub(i).sess(1).comp(j).tc;
                        undetrendSubjectTimecourse(xStart:xStart + size(compTimecourse, 1) - 1) = compTimecourse;
                        xStart = xStart + size(compTimecourse, 1);
                    end
                    % end loop over subjects
                    icaTimecourse(:, j) = subjectTimecourse';
                    undetrend_ICA(:, j) = undetrendSubjectTimecourse';
                    clear subjectTimecourse; clear undetrendSubjectTimecourse;
                    disp(['Done Concatenating Every Subject''s Timecourse for Component ', num2str(j), ' Timecourse']);
                end
                clear compTimecourses;
                % end loop over components

            case 'single_subject'
                totalScans = 0;
                % Load sessions for the particular subject
                for ses = 1:numOfSess
                    disp(['Loading Subject ', num2str(subject_number), ' Session ', num2str(ses), ' ICA Data']);
                    % load ICA Time course
                    compFiles = selectionStr{ses};

                    [compFiles, statusFile] = icatb_checkOutPutFiles(compFiles, outputDir, inputPrefix);

                    if ~statusFile
                        % get the files from the zip file
                        [zipFileName, files_in_zip] = icatb_getViewingSet_zip(compFiles, complexInfo, dataType, ...
                            zipContents);
                        compFiles = icatb_fullFile('directory', outputDir, 'files', compFiles);
                        [A] = icatb_loadICATimeCourse(compFiles, dataType, complexInfo, [1:1:numOfComp], ...
                            zipFileName, files_in_zip);
                        clear('zipFileName', 'files_in_zip', 'compFiles');

                    else
                        compFiles = icatb_fullFile('directory', outputDir, 'files', compFiles);
                        A = loadTC(compFiles, numOfComp);
                    end

                    %clear icasig;
                    if ses == 1
                        statusH = icatb_statusBar('init', numOfSess, 'Loading Components', '', '');
                        statusH = icatb_statusBar('increment', 1);
                    elseif ses > 1 & ses < numOfSess
                        statusH = icatb_statusBar('increment', 1);
                    end
                    % loop over the components
                    for jj = 1:numOfComp
                        compTimecourses.sub(1).sess(ses).comp(jj).tc = A(:, jj);
                    end
                    totalScans = totalScans + size(A, 1);
                    clear A;
                end
                statusH = icatb_statusBar('increment', numOfSess);
                icatb_statusBar('finished');

                %clear HInfo; clear prefix;

                icaTimecourse = zeros(totalScans, numOfComp);
                undetrend_ICA = zeros(totalScans, numOfComp);
                subjectTimecourse = zeros(1, totalScans);
                undetrendSubjectTimecourse = zeros(1, totalScans);

                % loop over components
                for j = 1:numOfComp
                    % loop over sessions
                    xStart = 1;
                    for i = 1:numOfSess
                        compTimecourse = compTimecourses.sub(1).sess(i).comp(j).tc;
                        compTimecourses.sub(1).sess(i).comp(j).tc = detrend(compTimecourse, 0);
                        undetrendSubjectTimecourse(xStart:xStart + size(compTimecourse, 1) - 1) =  compTimecourse;
                        subjectTimecourse(xStart:xStart + size(compTimecourse, 1) - 1) = compTimecourses.sub(1).sess(i).comp(j).tc;
                        xStart = xStart + size(compTimecourse, 1);
                    end
                    % end loop over sessions
                    icaTimecourse(:, j) = subjectTimecourse';
                    undetrend_ICA(:, j) = undetrendSubjectTimecourse';
                    clear subjectTimecourse; clear undetrendSubjectTimecourse;
                    disp(['Done Concatenating Every Subject''s Timecourse for Component ', num2str(j), ' Timecourse']);
                end
                clear compTimecourses;
                % end loop over components

            case 'all_subjects_sessions'

                % Load each subject's ICA data
                totalScans = 0;
                dataCount = 0;
                for i=1:numOfSub
                    for k=1:numOfSess
                        dataCount = dataCount + 1;
                        disp(['Loading Subject ', num2str(i),' Session ',num2str(k), ' ICA Data']);
                        compFiles = subjectICAFiles(i).ses(k).name;

                        [compFiles, statusFile] = icatb_checkOutPutFiles(compFiles, outputDir, inputPrefix);

                        if ~statusFile
                            % get the files from the zip file
                            [zipFileName, files_in_zip] = icatb_getViewingSet_zip(compFiles, complexInfo, ...
                                dataType, zipContents);
                            compFiles = icatb_fullFile('directory', outputDir, 'files', compFiles);
                            [A] = icatb_loadICATimeCourse(compFiles, dataType, complexInfo, [1:1:numOfComp], ...
                                zipFileName, files_in_zip);
                            clear('zipFileName', 'files_in_zip', 'compFiles');

                        else
                            compFiles = icatb_fullFile('directory', outputDir, 'files', compFiles);
                            A = loadTC(compFiles, numOfComp);
                        end

                        if dataCount == 1
                            statusH = icatb_statusBar('init', numOfSub*numOfSess, 'Loading Components', '', '');
                            statusH = icatb_statusBar('increment', 1);
                        elseif dataCount > 1 & dataCount < numOfSub*numOfSess
                            statusH = icatb_statusBar('increment', 1);
                        end
                        for jj = 1:numOfComp
                            compTimecourses.sub(i).sess(k).comp(jj).tc = A(:, jj);
                        end
                        totalScans = totalScans + size(A, 1);
                        clear A;
                    end

                end
                statusH = icatb_statusBar('increment', numOfSub*numOfSess);
                icatb_statusBar('finished');
                icaTimecourse = zeros(totalScans, numOfComp);
                undetrend_ICA = zeros(totalScans, numOfComp);
                subjectTimecourse = zeros(1, totalScans);
                undetrendSubjectTimecourse =  subjectTimecourse;

                % loop over components
                for j = 1:numOfComp
                    sessStart = 1;
                    % loop over subjects
                    for i = 1:numOfSub
                        xStart = 1;
                        % loop over sessions
                        for k = 1:numOfSess
                            compTimecourse = compTimecourses.sub(i).sess(k).comp(j).tc;
                            compTimecourses.sub(i).sess(k).comp(j).tc = detrend(compTimecourse, 0);
                            sessionTimecourse(xStart:xStart + size(compTimecourse, 1) - 1) = compTimecourses.sub(i).sess(k).comp(j).tc;
                            untrendSessionTimecourse(xStart:xStart + size(compTimecourse, 1) - 1) = compTimecourse;
                            xStart = xStart + size(compTimecourse, 1);
                        end
                        % end loop over sessions
                        subjectTimecourse(sessStart: sessStart + length(sessionTimecourse) - 1) = sessionTimecourse;
                        undetrendSubjectTimecourse(sessStart: sessStart + length(sessionTimecourse) - 1) = untrendSessionTimecourse;
                        sessStart = sessStart + length(sessionTimecourse);
                        clear sessionTimecourse; clear untrendSessionTimecourse;
                    end
                    % end loop over subjects
                    icaTimecourse(:, j) = subjectTimecourse';
                    undetrend_ICA(:, j) = undetrendSubjectTimecourse';
                    clear subjectTimecourse; clear undetrendSubjectTimecourse;
                    disp(['Done Concatenating Every Subject''s Timecourse for Component ', num2str(j), ' Timecourse']);
                end
                clear compTimecourses;
        end
        % end for selection of sorting criteria
        set(staticTextH, 'string', 'Concatenated ICA time courses ...');
        [staticTextH] = icatb_wrapStaticText(staticTextH);

    elseif strcmp(lower(sortingType), 'spatial')

        icatb_defaults;
        global DETRENDNUMBER;

        % Threshold, Include Image values and convert to z scores accordingly
        % to the template image
        keywd = 'not-specified';
        figureData.diffTimePoints = [];

        numSortSubjects = 1;
        numSortSessions = 1;

        % Select template Map
        filterText = '*.img;*.nii';
        switch sortingCriteria

            case 'correlation'
                % end for selection of sorting criteria
                set(staticTextH, 'string', 'Select spatial template ...');
                [staticTextH] = icatb_wrapStaticText(staticTextH);

                promptString = 'Select Spatial Template';
                [spatialImage] = icatb_selectEntry('typeEntity', 'file', 'typeselection', 'single', ...
                    'title', promptString, 'filter', filterText, 'filetype', 'image', 'filenumbers', 1);
                % spatial image selected for sorting
                disp(['Spatial template selected is ', spatialImage]);

            case 'multiple regression'
                set(staticTextH, 'string', 'Select spatial template/templates ...');
                [staticTextH] = icatb_wrapStaticText(staticTextH);
                % Select template Map
                promptString = 'Select Spatial Template/Templates';
                [spatialImage] = icatb_selectEntry('typeEntity', 'file', 'typeselection', 'multiple', ...
                    'title', promptString, 'filter', filterText, 'filetype', 'image');
                disp(['Spatial templates selected is/are: ']);
                % print spatial templates
                for nSpTemp = 1:size(spatialImage, 1);
                    disp(spatialImage(nSpTemp, :));
                end

            case 'maximum voxel'
                set(staticTextH, 'string', 'Select spatial template ...');
                [staticTextH] = icatb_wrapStaticText(staticTextH);
                % Select template Map
                promptString = 'Select Spatial Template';
                [spatialImage] = icatb_selectEntry('typeEntity', 'file', 'typeselection', 'single', ...
                    'title', promptString, 'filter', filterText, 'filetype', 'image', 'filenumbers', 1);
                % spatial image selected for sorting
                disp(['Spatial template selected is ', spatialImage]);

        end


        % Subject Files
        % Initialize String
        count = 0;
        setSelectString = 'Select Component Set to Sort';
        set(staticTextH, 'string', [setSelectString,  '...']);
        [staticTextH] = icatb_wrapStaticText(staticTextH);
        setAnswerString = {''};
        for i = 1:numOfSub
            for k = 1:numOfSess
                count = count + 1;
                [pathstr name] = fileparts(subjectICAFiles(i).ses(k).name(1, :));
                underScoreIndex = icatb_findstr(name,'_');
                name = [name(1:underScoreIndex(end)),'*'];
                setSelectString = str2mat(setSelectString, name);
                setAnswerString{count} = subjectICAFiles(i).ses(k).name;
            end
        end

        %% Added this code to spatially sort the mean IC's

        if (~isempty(meanICAFiles(1).name) && chkFile(fullfile(outputDir, meanICAFiles(1).name(1, :))))
            % add mean for each session to selection list
            for i = 1:numOfSess
                count = count + 1;
                [pathstr name] = fileparts( meanICAFiles(i).name(1, :) );
                underScoreIndex = icatb_findstr(name,'_');
                name = [name(1:underScoreIndex(end)),'*'];
                setSelectString = str2mat(setSelectString, name);
                setAnswerString{count} = meanICAFiles(i).name;
            end

        end

        if (~isempty(meanALL_ICAFile.name) && chkFile(fullfile(outputDir, meanALL_ICAFile(1).name(1, :))))
            % add mean for all sessions to selection list
            count = count + 1;
            [pathstr name] = fileparts( meanALL_ICAFile(1).name(1, :) );
            underScoreIndex = icatb_findstr(name,'_');
            name = [name(1:underScoreIndex(end)),'*'];
            setSelectString = str2mat(setSelectString, name);
            setAnswerString{count} = meanALL_ICAFile(1).name;
        end

        %prompt user to select component set to sort
        promptString = setSelectString(1, :);
        choiceString = setSelectString(2:end, :);

        if size(choiceString, 1) == 1
            index = 1;
        else
            % get the position of the normal figure
            [normalPos]=icatb_getfigPosition('normal');

            % width  and height of the list box
            listsize = [0.75*normalPos(3) 0.9*normalPos(4)];

            % Position for the component set to be selected
            latestPos = get(handles, 'position');
            [index] = openListDialog(promptString, choiceString, normalPos, listsize, latestPos);
        end

        compSetAnswer = setAnswerString{index};

        selectionStr = {compSetAnswer};

        figureData.viewingSet = deblank(choiceString(index, :));

        disp(['Component set selected for spatial sorting is ', figureData.viewingSet]);

        figureData.selectedDataSet = figureData.viewingSet;

        fprintf('\n');

        set(staticTextH, 'string', 'Loading component images ...');
        [staticTextH] = icatb_wrapStaticText(staticTextH);

        % Load the images
        % Apply Z-scores, threshold and convert to z criteria
        % load ICA images and time courses
        compFiles = selectionStr{1};

        [zipFileName, files_in_zip] = icatb_getViewingSet_zip(compFiles, complexInfo, dataType, zipContents);

        compFiles = icatb_fullFile('directory', outputDir, 'files', compFiles);

        % Unzip files
        if ~isempty(zipFileName)
            icatb_unzip(zipFileName, fileparts(deblank(compFiles(1, :))));
        end

        drawnow;

        disp('Loading component data and applying display defaults ...');

        [icasig, HInfo, real_world_coords] = icatb_loadData(compFiles, 'real', [], [], [1:figureData.numOfComp]);

        % Reshape icasig to components by voxels
        icasig = permute(icasig, [4 1 2 3]);

        % Structural volume
        HInfo.V = HInfo.V(1);

        % Reshape to 2d
        icasig = reshape(icasig, [figureData.numOfComp, prod(HInfo.DIM(1:3))]);

        % Apply display parameters
        icasig = icatb_applyDispParameters(icasig, figureData.dispGUI_Parameters.convertToZ, figureData.dispGUI_Parameters.returnValue, ...
            figureData.dispGUI_Parameters.threshValue, HInfo.DIM(1:3), HInfo);

        % Load time course
        icaTimecourse = icatb_loadICATimeCourse(compFiles, dataType, [], [1:figureData.numOfComp]);

        % Spatial information
        spatialInfo.files = compFiles;
        spatialInfo.viewingSet = figureData.viewingSet;
        spatialInfo.zipFileName = zipFileName;
        spatialInfo.files_in_zip = files_in_zip;

        spatialTemplate = [];

        if exist('spatialImage', 'var') && ~isempty(spatialImage)

            tempV = icatb_get_vol_nifti(HInfo.V(1).fname);

            % Handle flip
            spatialTemplate = icatb_resizeData(tempV, spatialImage, 1);

            % New dimensions for the spatial template
            spatialTemplate = reshape(spatialTemplate, size(spatialTemplate, 1), prod(HInfo.DIM));

        end

        modelTimecourse = []; undetrend_ICA = icaTimecourse;
        icaTimecourse = icatb_detrend(icaTimecourse, 1, size(icaTimecourse, 1), DETRENDNUMBER);
        % num_regress corresponds to temporal regressors selected
        % num_Datasets corresponds to the number of data sets concatenated
        num_Regress = 0; num_DataSets = 1;

    end
    % end for checking

    if ~exist('icasig', 'var')
        icasig = [];
    end

    if ~exist('HInfo', 'var')
        HInfo = [];
    end

    if ~exist('real_world_coords', 'var')
        real_world_coords = [];
    end

    set(staticTextH, 'string', 'Calculating sorting parameters ...');
    [staticTextH] = icatb_wrapStaticText(staticTextH);

    [sortParameters] = icatb_sortComponents('sortingCriteria', sortingCriteria, 'sortingType', sortingType, ...
        'icaTimecourse', icaTimecourse, 'modelTimecourse', modelTimecourse, 'num_Regress', num_Regress, ...
        'num_DataSets', num_DataSets, 'refInfo', refInfo, 'diffTimePoints', figureData.diffTimePoints, ...
        'numcomp', numOfComp, 'spatialTemplate', spatialTemplate, 'icasig', icasig, 'structHInfo', ...
        HInfo, 'viewingSet', figureData.viewingSet, 'keywd', figureData.keywd, 'spatialImage', ...
        spatialImage, 'num_sort_subjects',  numSortSubjects, 'num_sort_sessions', numSortSessions, 'output_dir', ...
        outputDir, 'input_prefix', inputPrefix, 'real_world_coords', real_world_coords);

    %sortParameters.maxVoxelStr = maxVoxelStr;
    set(staticTextH, 'string', 'Sorting calculation is done ...');
    [staticTextH] = icatb_wrapStaticText(staticTextH);
    % naming the components
    tempUntrendICA = zeros(size(undetrend_ICA));
    for ii = 1:numOfComp
        string  = ['Component ', num2str(sortParameters.sortedIndices(ii)) , ' ', sortingType, ' ', ...
            sortingCriteria, ' = ', num2str(sortParameters.sortedValues(ii))];
        compLabels(ii).string = string;
        if ~isempty(icaTimecourse)
            tempUntrendICA(:, ii) = undetrend_ICA(:, sortParameters.sortedIndices(ii));
        end
    end

    % component labels
    sortParameters.compLabels = compLabels;
    sortParameters.icasig = [];

    % structure header information
    if exist('HInfo', 'var')
        sortParameters.structHInfo = HInfo;
    end
    % end for checking

    if exist('spatialInfo', 'var')
        sortParameters.spatialInfo = spatialInfo;
    end

    undetrend_ICA = tempUntrendICA;
    clear tempUntrendICA;
    sortParameters.undetrendICA = undetrend_ICA;
    clear tempUntrendICA;

    figureData.sortParameters = sortParameters;
    clear sortParameters;

    % application data
    setappdata(0, 'sortingAppData', figureData);

    % end for sorting type
    set(handles, 'pointer', 'arrow');

    delete(handles);

catch
    if ishandle(handles)
        set(handles, 'pointer', 'arrow');
        delete(handles);
    end
    % display error dialog
    %icatb_errorDialog(lasterr);
    icatb_displayErrorMsg;
end

function [index] = openListDialog(promptString, choiceString, normalPos, listsize, latestPos)

% Open list dialog box for selecting items

% load defaults
icatb_defaults;

global BG2_COLOR;
global FONT_COLOR;
global UI_FONTNAME;
global UI_FONTUNITS;
global UI_FS;


% Select Options using List Dialog Box
[index, name_button] = icatb_listdlg('PromptString', promptString, 'SelectionMode','single',...
    'ListString', choiceString, 'listsize', listsize, 'movegui', 'east', 'windowStyle', 'modal');

if name_button == 0
    error('Component set is not selected');
    %button = msgbox('By default: Selecting the first option', 'Component Set is not Selected', 'warn') ;
    %waitfor(button);
    %index = 1;
end


function tc = loadTC(compFiles, numOfComp)
% Load time course from calibrated MAT file

load(compFiles, 'tc');

if size(tc, 2) ~= numOfComp
    tc = tc';
end


function status = chkFile(file)

[pathstr, fN, extn] = fileparts(deblank(file));

lastPos = icatb_findstr(fN, '_');
fN2 = fN(1:lastPos(end));

status = 0;
if (exist(fullfile(pathstr, [fN, extn]), 'file') || exist(fullfile(pathstr, [fN2, '.zip']), 'file'))
    status = 1;
end




%% from icab_displayGUI.m

function [dispParameters] = icatb_getStructuralFile(dispParameters)
% get the structural file for plotting component images

currentFile = dispParameters.inputFiles(1).name(1, :);

[currentFile] = icatb_parseExtn(currentFile);

% check the existence of the input file
if ~exist(currentFile, 'file')
    msgString = [deblank(dispParameters.inputFiles(1).name(1, :)), ' file doesn''t exist.' ...
        ' Do you want to select the structural file?'];
    [answerQuestion] = icatb_questionDialog('title', 'Select Structural File', 'textbody', msgString);
    if answerQuestion == 1
        % structural file
        [structuralFile] = icatb_selectEntry('typeEntity', 'file', 'title', 'Select Structural File', 'filter', ...
            '*.img;*.nii', 'fileType', 'image');
    else
        error(deblank(dispParameters.inputFiles(1).name(1, :)), ' file doesn''t exist.');
    end
else
    % structural file
    structuralFile = dispParameters.inputFiles(1).name(1, :);
    % create magnitude image for complex data type
    if ~strcmpi(dispParameters.dataType, 'real')
        complexFile = dispParameters.inputFiles(1).name(1, :);
        [data, HInfo] = icatb_loadData(complexFile, dispParameters.dataType, ...
            dispParameters.complexInfoRead, 'read', 1);
        data = abs(data);
        structuralFile = fullfile(dispParameters.outputDir, [dispParameters.inputPrefix, 'structFile.img']);
        V = HInfo.V(1);
        V.fname = structuralFile;
        icatb_write_vol(V, data);
        clear data; clear V;
    end
    % create magnitude image
end

% add structural file to the dispParameters structure
dispParameters.structFile = structuralFile;



